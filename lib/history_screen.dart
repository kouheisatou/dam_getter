import 'dart:io';
import 'dart:math';

import 'package:dam_getter/app_database.dart';
import 'package:dam_getter/login_screen.dart';
import 'package:dam_getter/score_data_model.dart';
import 'package:dam_getter/score_list_model.dart';
import 'package:dam_getter/values_public.dart';
import 'package:dam_getter/values_static.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:http/http.dart" as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();

  String selectedScoreType = SCORE_TYPES.keys.first;
  bool downloading = false;
  double progress = 0.0;
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ListModel<ScoreDataModel> _list = ListModel(listKey: GlobalKey<AnimatedListState>());

  Future<void> getScoresFromDb() async {
    var db = await AppDatabase.getDatabase();
    var scoresFromDb = await db.scoreDao.getAllScores();
    for (var scoreInDb in scoresFromDb) {
      insertToList(scoreInDb);
    }
  }

  void insertToList(ScoreDataModel insertTarget) {
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
  }

  Future<String> fetchScores(String baseURL) async {
    final prefs = await SharedPreferences.getInstance();
    cdmToken = prefs.getString("cdm_token");
    cdmCardNo = prefs.getString("cdm_card_no");

    if (cdmToken == null || cdmCardNo == null) throw Exception("invalid token");

    var hasNext = true;
    var pageNo = 1;
    List<String> dumpedResults = [];
    while (hasNext) {
      var url = baseURL.replaceAll("\${cdmCardNo}", cdmCardNo!).replaceAll("\${cdmToken}", cdmToken!).replaceAll("\${UTCserial}", DateTime.now().millisecondsSinceEpoch.toString()).replaceAll("\${pageNo}", pageNo.toString());
      print(url);
      var resp = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/xml'});
      var xmlDocument = xml.XmlDocument.parse(resp.body);
      hasNext = xmlDocument.findAllElements('page').first.getAttribute('hasNext') == "1";
      setState(() {
        widget.progress = pageNo.toDouble() / double.parse(xmlDocument.findAllElements('page').first.getAttribute('pageCount').toString());
      });
      pageNo++;
      for (var data in xmlDocument.findAllElements("data")) {
        dumpedResults.add(data.toString());
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    var resultXmlString = '<document xmlns="https://www.clubdam.com/${Uri.parse(baseURL).path}" type="2.2"><list count="${dumpedResults.length}">';
    for (var dumpedResult in dumpedResults) {
      resultXmlString += dumpedResult;
    }
    resultXmlString += "</list></document>";
    return resultXmlString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedList(
        itemBuilder: (BuildContext context, int index, Animation<double> animation) {
          var score = _list[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(score.contentsName),
                  subtitle: Text(score.scoringTime.toString()),
                  trailing: Text(score.score.toString()),
                ),
              ),
            ),
          );
        },
        key: _list.listKey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          insertToList(ScoreDataModel("id", ScoreType.ai, "contentsName", "artistName", 92.104, "xml", Random().nextInt(10)));
          return;

          if (SCORE_TYPES[widget.selectedScoreType] != null) {
            setState(() {
              widget.downloading = true;
            });
            try {
              var result = await fetchScores(SCORE_TYPES[widget.selectedScoreType]!);
              print(result);

              final directory = await getApplicationDocumentsDirectory();
              var fileName = "${widget.selectedScoreType}.xml";
              var filePath = "${directory.path}/$fileName";
              var file = File(filePath);
              await file.writeAsString(result);

              Share.shareXFiles(
                [XFile(filePath)],
                subject: fileName,
                sharePositionOrigin: const Rect.fromLTWH(0, 0, 300, 300),
              );
            } catch (e) {
              print(e);
              Fluttertoast.showToast(msg: "ログインが必要です");

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                  fullscreenDialog: true,
                ),
              );
            } finally {
              setState(() {
                widget.downloading = false;
              });
            }
          }
        },
      ),
    );
  }

  @override
  void initState() {
    getScoresFromDb();
  }
}
