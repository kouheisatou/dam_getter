import 'dart:io';

import 'package:dam_getter/values.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import "package:http/http.dart" as http;
import 'package:xml/xml.dart' as xml;

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  InAppWebViewController? webView;

  Future<String> fetchScores(String scoreType) async {
    String? cdmToken = await webView?.evaluateJavascript(source: "DamHistoryManager.getCdmToken()");
    String? cdmCardNo = await webView?.evaluateJavascript(source: "DamHistoryManager.getCdmCardNo()");

    if (cdmToken == null || cdmCardNo == null) throw Exception("failed to get token or card number");

    var hasNext = true;
    var pageNo = 1;
    while (hasNext) {
      var url = "https://www.clubdam.com/app/damtomo/scoring/$scoreType.do?cdmCardNo=$cdmCardNo&cdmToken=$cdmToken&enc=sjis&pageNo=$pageNo&detailFlg=1&dxgType=1&UTCserial=${DateTime.now().millisecondsSinceEpoch}";
      var resp = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/xml'});
      hasNext = xml.XmlDocument.parse(resp.body).findAllElements('page').first.getAttribute('hasNext') == "1";
      pageNo++;
      sleep(const Duration(seconds: 3));
      print(resp.body);
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(80.0),
            child: IconButton(
              onPressed: () async {
                await fetchScores("GetScoringAiListXML");
              },
              icon: const Icon(Icons.download),
            ),
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
            ),
          )
        ],
      ),
    );
  }
}
