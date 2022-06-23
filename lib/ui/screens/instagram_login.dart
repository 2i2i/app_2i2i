import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../infrastructure/data_access_layer/repository/instagram_service.dart';
import '../../infrastructure/commons/instagram_config.dart';

class InstagramLogin extends StatefulWidget {
  const InstagramLogin({Key? key}) : super(key: key);

  @override
  State<InstagramLogin> createState() => _InstagramLoginState();
}

class _InstagramLoginState extends State<InstagramLogin> {
  InAppWebViewController? _webViewController;
  String url = "";
  double progress = 0;

  InstagramService instagram = InstagramService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(InstagramConfig.url),
        actions: [
          ElevatedButton(
              onPressed: () {
                _webViewController?.reload();
                _webViewController?.clearCache();
                _webViewController?.clearFocus();
                _webViewController?.clearMatches();
                _webViewController?.removeAllUserScripts();
              },
              child: Text("reload"))
        ],
      ),
      body: Container(
        child: Column(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(InstagramConfig.url)),
              initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions()),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onUpdateVisitedHistory: (InAppWebViewController controller, Uri? url, bool? androidIsReload) async {
                instagram.getAuthorizationCode(url.toString());
                if (url.toString().contains(InstagramConfig.redirectUri)) {
                  bool isDone = await instagram.getTokenAndUserID();
                  if (isDone) {
                    instagram.getUserProfile().then((isDone) async {
                      print('${instagram.username} logged in!');
                    });
                  }
                }
              },
              onProgressChanged: (InAppWebViewController controller, int progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
          ),
        ]),
      ),
    );
  }
}
