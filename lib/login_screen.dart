import 'package:dam_getter/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
  String username = "";
  String password = "";
}

class _LoginScreenState extends State<LoginScreen> {
  InAppWebViewController? webView;

  Future<void> login(String user, String pass) async {
    CookieManager.instance().deleteAllCookies();
    await webView?.evaluateJavascript(source: "document.getElementById('LoginID').value = '$user'; document.getElementById('LoginPassword').value = '$pass';  document.getElementById('LoginButton').click();");
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
              onLoadStop: (controller, url){
                if(url == DAM_LOGIN_SUCCEEDED_PAGE || url == DAM_MYPAGE_URL){
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
