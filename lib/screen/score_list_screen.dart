import 'dart:io';
import 'package:dam_getter/common/database/app_database.dart';
import 'package:dam_getter/common/exception.dart';
import 'package:dam_getter/screen/login_screen.dart';
import 'package:dam_getter/common/list_model.dart';
import 'package:dam_getter/common/utils.dart';
import 'package:dam_getter/common/values_public.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import '../common/database/score_data_model.dart';
import '../common/values_static.dart';
import 'score_list_item.dart';

class ScoreListScreen extends StatefulWidget {
  @override
  State<ScoreListScreen> createState() => _ScoreListScreenState();

  /// State of the screen
  ScreenState screenState = ScreenState.initialized;

  /// Download progress (unused)
  double progress = 0.0;
}

/// State of the screen
/// [initialized] : After the screen is initialized
/// [downloading] : From when [_ScoreListScreenState.startDownload] is called to completion
/// [downloaded] : After [_ScoreListScreenState.startDownload] is finished
/// [cancelling] : From when [_ScoreListScreenState.cancelDownload] is called to break is called in [_ScoreListScreenState.startDownload]
enum ScreenState { initialized, downloading, downloaded, cancelling }

class _ScoreListScreenState extends State<ScoreListScreen> {
  final ListModel<ScoreDataModel> _list = ListModel(listKey: GlobalKey<AnimatedListState>());

  /// Recover score [_list] from local database
  /// The method is called only when the screen initialized
  Future<void> getScoresFromDb() async {
    // If first launch, open LoginScreen
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

  /// Insert new instance of [ScoreDataModel] to [_list] in sorted position
  /// The [_list] is arranged in ascending order by [ScoreDataModel.scoringTime]
  Future<void> insertToList(ScoreDataModel insertTarget) async {
    if (_list.contains(insertTarget)) return;

    var db = await AppDatabase.getDatabase();

    // if the first item
    if (_list.length == 0) {
      _list.insert(0, insertTarget);
      await db.scoreDao.insertScore(insertTarget);
      setState(() {});
      return;
    }

    // seek until appropriate position
    for (var i = 0; i < _list.length; i++) {
      ScoreDataModel score = _list[i];

      // if appropriate position is found until last
      if (score.scoringTime < insertTarget.scoringTime) {
        _list.insert(i, insertTarget);
        await db.scoreDao.insertScore(insertTarget);
        setState(() {});
        return;
      }
    }

    // if appropriate position is not found until last
    _list.insert(_list.length, insertTarget);
    await db.scoreDao.insertScore(insertTarget);
    setState(() {});
  }

  /// Starts download score data from DAM
  /// Download sources are defined in [SCORE_TYPES]
  Future<void> startDownload() async {
    try {
      // get saved authentication information from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      cdmToken = prefs.getString("cdm_token");
      cdmCardNo = prefs.getString("cdm_card_no");

      // if authentication information does not exists, throw LoginException and open LoginScreen
      if (cdmToken == null || cdmCardNo == null) throw LoginException();

      // update screen state as downloading
      setState(() {
        widget.screenState = ScreenState.downloading;
      });

      // get all scores from predefined urls
      for (var scoreType in SCORE_TYPES.entries) {
        var baseUrl = scoreType.value;
        var hasNext = true;
        var pageNo = 1;

        // access next page until the next does not exists
        while (hasNext) {
          // inject authentication information and number of page to url as url parameters
          var url = baseUrl.replaceAll("\${cdmCardNo}", cdmCardNo!).replaceAll("\${cdmToken}", cdmToken!).replaceAll("\${UTCserial}", DateTime.now().millisecondsSinceEpoch.toString()).replaceAll("\${pageNo}", pageNo.toString());
          print(url);

          // fetch score data from hidden api in my page of DAM
          var resp = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/xml'});

          // parse xml
          var xmlDocument = xml.XmlDocument.parse(resp.body);

          // find `hasNext` element in response and judge if the next page exists
          hasNext = xmlDocument.findAllElements('page').first.getAttribute('hasNext') == "1";

          // update download progress
          setState(() {
            widget.progress = pageNo.toDouble() / double.parse(xmlDocument.findAllElements('page').first.getAttribute('pageCount').toString());
          });
          pageNo++;

          // find all `scoring` elements in api response and insert to list
          for (var scoringXml in xmlDocument.findAllElements("scoring")) {
            await insertToList(ScoreDataModel.fromXml(scoringXml, scoreType.key));
          }

          // wait 1 second for avoiding DDos attack
          await Future.delayed(const Duration(seconds: 1));

          // if cancelDownload() method is called, abort downloading
          if (widget.screenState == ScreenState.cancelling) {
            // update screen state
            setState(() {
              widget.screenState = ScreenState.initialized;
            });
            return;
          }
        }
      }

      // update screen state
      setState(() {
        widget.screenState = ScreenState.downloaded;
      });
    }
    // if LoginException was thrown, open LoginScreen
    on LoginException {
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

      // update screen state
      setState(() {
        widget.screenState = ScreenState.initialized;
      });
    }
    // if unexpected exception occurred, reset screen state
    catch (e) {
      print(e);

      setState(() {
        widget.screenState = ScreenState.initialized;
      });
    }
  }

  /// Abort downloading by exiting download loop
  Future<void> cancelDownload() async {
    widget.screenState = ScreenState.cancelling;
  }

  /// Save data in [_list] as xml string and open share dialog
  Future<void> shareScoresXml() async {
    // get application local directory
    final directory = await getApplicationDocumentsDirectory();

    // create temp file
    var fileName = "dam_scores.xml";
    var filePath = "${directory.path}/$fileName";
    var file = File(filePath);

    // build result xml
    var result = '<?xml version="1.0" encoding="UTF-8"?><scores>';
    for (var i = 0; i < _list.length; i++) {
      var score = _list[i];
      result += score.xml;
    }
    result += '<scores>';

    // write xml string to temp file
    await file.writeAsString(result);

    // open share dialog
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
        child: Stack(
          children: [
            AnimatedList(
              reverse: true,
              itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                ScoreDataModel score = _list[index];

                // if prev item's date is different, display date separator above of the item
                bool requireDateSeparator = false;
                if (index != _list.length - 1) {
                  ScoreDataModel nextItem = _list[index + 1];
                  if (parseDatetime(nextItem.scoringTime.toString()).copyWith(hour: 0, minute: 0, second: 0) != parseDatetime(score.scoringTime.toString()).copyWith(hour: 0, minute: 0, second: 0)) {
                    requireDateSeparator = true;
                  }
                } else {
                  requireDateSeparator = true;
                }

                // define default children
                List<Widget> children = [ScoreDataListItem(score)];

                // if date separator displaying
                if (requireDateSeparator) {
                  children.insert(
                    0,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 7),
                      child: Text(DateFormat("yyyy/MM/dd").format(parseDatetime(score.scoringTime.toString()))),
                    ),
                  );
                }

                // if the bottom of the list (the first item), show action button
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
            ),
            Visibility(visible: _list.length == 0, child: Center(child: actionButton())),
          ],
        ),
      ),
    );
  }

  /// Build action button widget
  /// Action of the button is depended on [ScoreListScreen.screenState]
  Widget actionButton() {
    // action button's icon
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
          // action of the button is depended on [ScoreListScreen.screenState]
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
  // on initialized screen
  void initState() {
    getScoresFromDb();
  }
}
