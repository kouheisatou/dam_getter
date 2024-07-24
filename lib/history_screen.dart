import 'dart:io';
import 'dart:math';

import 'package:dam_getter/app_database.dart';
import 'package:dam_getter/login_screen.dart';
import 'package:dam_getter/score_data_model.dart';
import 'package:dam_getter/list_model.dart';
import 'package:dam_getter/utils.dart';
import 'package:dam_getter/values_public.dart';
import 'package:dam_getter/values_static.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();

  ScreenState screenState = ScreenState.initialized;
  double progress = 0.0;
}

enum ScreenState { initialized, downloading, downloaded, cancelling }

class _HistoryScreenState extends State<HistoryScreen> {
  final ListModel<ScoreDataModel> _list = ListModel(listKey: GlobalKey<AnimatedListState>());

  Future<void> getScoresFromDb() async {
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
      if (cdmToken == null || cdmCardNo == null) throw Exception("invalid token");

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
    } catch (e) {
      print(e);
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
        child: AnimatedList(
          itemBuilder: (BuildContext context, int index, Animation<double> animation) {
            ScoreDataModel score = _list[index];

            bool requireDateSeparator = false;
            if (index > 0) {
              ScoreDataModel prevItem = _list[index - 1];
              if (parseDatetime(prevItem.scoringTime.toString()).copyWith(hour: 0, minute: 0, second: 0) != parseDatetime(score.scoringTime.toString()).copyWith(hour: 0, minute: 0, second: 0)) {
                requireDateSeparator = true;
              }
            } else {
              requireDateSeparator = true;
            }

            return SizeTransition(
              sizeFactor: animation,
              child: requireDateSeparator
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 7),
                          child: Text(DateFormat("yyyy/MM/dd").format(parseDatetime(score.scoringTime.toString()))),
                        ),
                        ScoreDataListItem(score),
                      ],
                    )
                  : ScoreDataListItem(score),
            );
          },
          key: _list.listKey,
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
        child: buildActionButton(),
      ),
    );
  }

  Widget buildActionButton() {
    switch (widget.screenState) {
      case ScreenState.initialized:
        return const Icon(Icons.download);
      case ScreenState.downloading:
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onSurface,
            strokeWidth: 0.8,
          ),
        );
      case ScreenState.downloaded:
        return const Icon(Icons.ios_share_outlined);
      case ScreenState.cancelling:
        return const Icon(Icons.close);
    }
  }

  @override
  void initState() {
    getScoresFromDb();
  }
}
