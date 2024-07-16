import 'dart:io';

import 'package:dam_getter/login_screen.dart';
import 'package:dam_getter/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import "package:http/http.dart" as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart' as xml;

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();

  String selectedScoreType = SCORE_TYPES.keys.first;
  bool downloading = false;
}

class _HistoryScreenState extends State<HistoryScreen> {
  InAppWebViewController? webView;

  Future<String> fetchScoring(String baseURL) async {
    String? cdmToken = await webView?.evaluateJavascript(source: "DamHistoryManager.getCdmToken()");
    String? cdmCardNo = await webView?.evaluateJavascript(source: "DamHistoryManager.getCdmCardNo()");

    if (cdmToken == null || cdmCardNo == null) throw Exception("failed to get token or card number");

    var hasNext = true;
    var pageNo = 1;
    List<String> dumpedResults = [];
    while (hasNext) {
      var url = baseURL.replaceAll("\${cdmCardNo}", cdmCardNo).replaceAll("\${cdmToken}", cdmToken).replaceAll("\${UTCserial}", DateTime.now().millisecondsSinceEpoch.toString()).replaceAll("\${pageNo}", pageNo.toString());
      print(url);
      var resp = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/xml'});
      var xmlDocument = xml.XmlDocument.parse(resp.body);
      hasNext = xmlDocument.findAllElements('page').first.getAttribute('hasNext') == "1";
      pageNo++;
      sleep(const Duration(seconds: 1));

      for (var score in xmlDocument.findAllElements("scoring")) {
        dumpedResults.add(score.toString());
      }
      break;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(80.0),
            child: IconButton(
              onPressed: widget.downloading
                  ? null
                  : () async {
                      if (SCORE_TYPES[widget.selectedScoreType] != null) {
                        setState(() {
                          widget.downloading = true;
                        });
                        try {
                          var result = await fetchScoring(SCORE_TYPES[widget.selectedScoreType]!);
                          print(result);

                          final directory = await getApplicationDocumentsDirectory();
                          var filePath = "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.xml";
                          var file = File(filePath);
                          await file.writeAsString(result);

                          Share.shareXFiles(
                            [XFile(filePath)],
                            subject: "ExportedScombMobileDB.json",
                            sharePositionOrigin: const Rect.fromLTWH(0, 0, 300, 300),
                          );
                        } finally {
                          setState(() {
                            widget.downloading = false;
                          });
                        }
                      }
                    },
              icon: widget.downloading ? const CircularProgressIndicator() : const Icon(Icons.download),
            ),
          ),
          DropdownButton<String>(
            value: widget.selectedScoreType,
            onChanged: (String? newValue) {
              setState(() {
                if (newValue != null) {
                  widget.selectedScoreType = newValue;
                }
              });
            },
            items: SCORE_TYPES.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: InAppWebView(
              onWebViewCreated: (controller) {
                webView = controller;
              },
              initialUrlRequest: URLRequest(url: WebUri(DAM_MYPAGE_URL)),
              initialSettings: InAppWebViewSettings(
                userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
                preferredContentMode: UserPreferredContentMode.DESKTOP,
              ),
              onLoadStop: (controller, url) async {
                if(url.toString() != DAM_MYPAGE_URL){
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginScreen();
                      },
                      fullscreenDialog: true,
                    ),
                  );
                  await webView?.loadUrl(urlRequest: URLRequest(url: WebUri(DAM_MYPAGE_URL)));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
