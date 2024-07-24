import 'dart:io';
import 'package:dam_getter/app_database.dart';
import 'package:dam_getter/exception.dart';
import 'package:dam_getter/login_screen.dart';
import 'package:dam_getter/score_data_model.dart';
import 'package:dam_getter/list_model.dart';
import 'package:dam_getter/utils.dart';
import 'package:dam_getter/values_public.dart';
import 'package:dam_getter/values_static.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import 'score_list_item.dart';

class ScoreListScreen extends StatefulWidget {
  @override
  State<ScoreListScreen> createState() => _ScoreListScreenState();

  ScreenState screenState = ScreenState.initialized;
  double progress = 0.0;
}

enum ScreenState { initialized, downloading, downloaded, cancelling }

class _ScoreListScreenState extends State<ScoreListScreen> {
  final ListModel<ScoreDataModel> _list = ListModel(listKey: GlobalKey<AnimatedListState>());

  Future<void> getScoresFromDb() async {
    // first launch
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString("dam_id") == null && prefs.getString("dam_password") == null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
          fullscreenDialog: true,
        ),
      );
      return;
    }

    var db = await AppDatabase.getDatabase();
    var scoresFromDb = await db.scoreDao.getAllScores();
    for (var scoreInDb in scoresFromDb) {
      insertToList(scoreInDb);
    }
  }

  Future<void> insertToList(ScoreDataModel insertTarget) async {
    if (_list.contains(insertTarget)) return;

    if (_list.length == 0) {
      setState(() {
        _list.insert(0, insertTarget);
      });
    } else {
      for (var i = 0; i < _list.length; i++) {
        ScoreDataModel score = _list[i];
        if (score.scoringTime < insertTarget.scoringTime) {
          setState(() {
            _list.insert(i, insertTarget);
          });
          return;
        }
      }
      _list.insert(_list.length, insertTarget);
    }

    var db = await AppDatabase.getDatabase();
    await db.scoreDao.insertScore(insertTarget);
  }

  Future<void> startDownload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      cdmToken = prefs.getString("cdm_token");
      cdmCardNo = prefs.getString("cdm_card_no");
      if (cdmToken == null || cdmCardNo == null) throw LoginException();

      setState(() {
        widget.screenState = ScreenState.downloading;
      });

      for (var scoreType in SCORE_TYPES.entries) {
        var baseUrl = scoreType.value;
        var hasNext = true;
        var pageNo = 1;
        while (hasNext) {
          var url = baseUrl.replaceAll("\${cdmCardNo}", cdmCardNo!).replaceAll("\${cdmToken}", cdmToken!).replaceAll("\${UTCserial}", DateTime.now().millisecondsSinceEpoch.toString()).replaceAll("\${pageNo}", pageNo.toString());
          print(url);
          var resp = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/xml'});
          var xmlDocument = xml.XmlDocument.parse(resp.body);
          hasNext = xmlDocument.findAllElements('page').first.getAttribute('hasNext') == "1";
          setState(() {
            widget.progress = pageNo.toDouble() / double.parse(xmlDocument.findAllElements('page').first.getAttribute('pageCount').toString());
          });
          pageNo++;
          for (var scoringXml in xmlDocument.findAllElements("scoring")) {
            await insertToList(ScoreDataModel.fromXml(scoringXml, scoreType.key));
          }
          await Future.delayed(const Duration(seconds: 1));
          if (widget.screenState == ScreenState.cancelling) {
            setState(() {
              widget.screenState = ScreenState.initialized;
            });
            return;
          }
        }
      }

      setState(() {
        widget.screenState = ScreenState.downloaded;
      });
    } on LoginException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ログインが必要です")));

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
          fullscreenDialog: true,
        ),
      );

      setState(() {
        widget.screenState = ScreenState.initialized;
      });
    } catch (e) {
      print(e);

      setState(() {
        widget.screenState = ScreenState.initialized;
      });
    }
  }

  Future<void> cancelDownload() async {
    widget.screenState = ScreenState.cancelling;
  }

  Future<void> shareScoresXml() async {
    final directory = await getApplicationDocumentsDirectory();
    var fileName = "dam_scores.xml";
    var filePath = "${directory.path}/$fileName";
    var file = File(filePath);

    var result = '<?xml version="1.0" encoding="UTF-8"?><scores>';
    for (var i = 0; i < _list.length; i++) {
      var score = _list[i];
      result += score.xml;
    }
    result += '<scores>';

    await file.writeAsString(result);

    Share.shareXFiles(
      [XFile(filePath)],
      subject: fileName,
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 300, 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: _list.length != 0
            ? AnimatedList(
                reverse: true,
                itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                  ScoreDataModel score = _list[index];

                  bool requireDateSeparator = false;
                  if (index != _list.length - 1) {
                    ScoreDataModel nextItem = _list[index + 1];
                    if (parseDatetime(nextItem.scoringTime.toString()).copyWith(hour: 0, minute: 0, second: 0) != parseDatetime(score.scoringTime.toString()).copyWith(hour: 0, minute: 0, second: 0)) {
                      requireDateSeparator = true;
                    }
                  } else {
                    requireDateSeparator = true;
                  }

                  List<Widget> children = [ScoreDataListItem(score)];

                  if (requireDateSeparator) {
                    children.insert(
                      0,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 7),
                        child: Text(DateFormat("yyyy/MM/dd").format(parseDatetime(score.scoringTime.toString()))),
                      ),
                    );
                  }

                  if (index == 0) {
                    children.add(
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: actionButton(),
                      ),
                    );
                  }

                  return SizeTransition(sizeFactor: animation, child: Column(children: children));
                },
                key: _list.listKey,
              )
            : Center(child: actionButton()),
      ),
    );
  }

  Widget actionButton() {
    Widget icon;
    switch (widget.screenState) {
      case ScreenState.initialized:
        icon = const Icon(Icons.download);
      case ScreenState.downloading:
        icon = CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onSurface,
          strokeWidth: 0.8,
        );
      case ScreenState.downloaded:
        icon = const Icon(Icons.ios_share_outlined);
      case ScreenState.cancelling:
        icon = const Icon(Icons.close);
    }

    return SizedBox(
      height: 40,
      width: 40,
      child: IconButton(
        onPressed: () async {
          switch (widget.screenState) {
            case ScreenState.initialized:
              await startDownload();
              break;
            case ScreenState.downloading:
              await cancelDownload();
              break;
            case ScreenState.downloaded:
              await shareScoresXml();
              break;
            case ScreenState.cancelling:
              await cancelDownload();
              break;
          }
        },
        icon: icon,
      ),
    );
  }

  @override
  void initState() {
    getScoresFromDb();
  }
}
