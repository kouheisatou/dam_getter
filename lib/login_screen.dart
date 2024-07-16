import 'dart:io';

import 'package:dam_getter/history_screen.dart';
import 'package:dam_getter/secret.dart';
import 'package:dam_getter/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();

  // String username = "";
  // String password = "";
  String username = SAMPLE_USER;
  String password = SAMPLE_PASS;
}

class _LoginScreenState extends State<LoginScreen> {
  InAppWebViewController? webView;

  Future<void> login(String user, String pass) async {
    // await webView?.loadUrl(urlRequest: URLRequest(url: WebUri(DAM_MYPAGE_URL)));
    // CookieManager.instance().deleteAllCookies();
    await webView?.evaluateJavascript(source: "document.getElementById('LoginID').value = '$user'; document.getElementById('LoginPassword').value = '$pass';");
    await webView?.evaluateJavascript(source: "document.getElementById('LoginButton').click();");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextFormField(
            initialValue: widget.username,
            onChanged: (value) {
              widget.username = value;
            },
          ),
          TextFormField(
            initialValue: widget.password,
            onChanged: (value) {
              widget.password = value;
            },
          ),
          FloatingActionButton(
            onPressed: () async {
              await login(widget.username, widget.password);
            },
            child: const Text("login"),
          ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(DAM_MYPAGE_URL)),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStop: (controller, url) {
                print(url);
                print(DAM_LOGIN_SUCCEEDED_PAGE);
                if (url.toString() == DAM_LOGIN_SUCCEEDED_PAGE || url.toString() == DAM_MYPAGE_URL) {
                  webView?.loadUrl(urlRequest: URLRequest(url: WebUri(DAM_MYPAGE_URL)));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HistoryScreen();
                      },
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
