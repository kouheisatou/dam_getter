import 'package:dam_getter/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();

  // String username = "";
  // String password = "";

  TextEditingController damID = TextEditingController();
  TextEditingController damPassword = TextEditingController();
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
  void initState() {
    setSavedUserAndPass();
    super.initState();
  }

  Future<void> setSavedUserAndPass() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.damID.text = prefs.getString("dam_id") ?? "";
      widget.damPassword.text = prefs.getString("dam_password") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          primaryFocus?.unfocus();
        },
        child: Stack(
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
                        controller: widget.damID,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "D A M - I D",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: widget.damPassword,
                        textAlign: TextAlign.center,
                        obscureText: true,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "P A S S W O R D",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
                      child: IconButton(
                        onPressed: () async {
                          await login(widget.damID.text, widget.damPassword.text);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString("dam_id", widget.damID.text);
                          await prefs.setString("dam_password", widget.damPassword.text);
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
      ),
    );
  }
}
