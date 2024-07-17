import 'dart:io';

import 'package:dam_getter/history_screen.dart';
import 'package:dam_getter/values_secret.dart';
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
    await webView?.evaluateJavascript(source: """
document.getElementById('LoginID').value = '$user';
document.getElementById('LoginPassword').value = '$pass';
document.getElementById('LoginButton').click();
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(DAM_MYPAGE_URL)),
              onWebViewCreated: (InAppWebViewController controller) {
                webView = controller;
              },
              onLoadStop: (controller, url) {
                if (url.toString() == DAM_LOGIN_SUCCEEDED_PAGE) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      initialValue: widget.username,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: "D A M - I D",
                      ),
                      onChanged: (value) {
                        widget.username = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      initialValue: widget.password,
                      textAlign: TextAlign.center,
                      obscureText: true,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: "P A S S W O R D",
                      ),
                      onChanged: (value) {
                        widget.password = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                    child: IconButton(
                      onPressed: () async {
                        await login(widget.username, widget.password);
                      },
                      icon: const Icon(Icons.login),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
