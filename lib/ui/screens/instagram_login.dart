import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../infrastructure/commons/instagram_config.dart';
import '../../infrastructure/data_access_layer/repository/instagram_service.dart';

class InstagramLogin extends StatefulWidget {
  final ValueChanged<InAppWebViewController?> onWebViewCreated;
  final Function(InAppWebViewController controller, Uri? url, bool? androidIsReload) onUpdateVisitedHistory;
  const InstagramLogin({Key? key, required this.onUpdateVisitedHistory, required this.onWebViewCreated}) : super(key: key);

  @override
  State<InstagramLogin> createState() => _InstagramLoginState();
}

class _InstagramLoginState extends State<InstagramLogin> {
  String url = '';
  double progress = 0;

  InstagramService instagram = InstagramService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(padding: EdgeInsets.all(10.0), child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(InstagramConfig.url)),
              initialOptions: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions()),
              onWebViewCreated: (InAppWebViewController controller) {
                widget.onWebViewCreated.call(controller);
              },
              onUpdateVisitedHistory: widget.onUpdateVisitedHistory,
              onProgressChanged: (InAppWebViewController controller, int progress) {
                this.progress = progress / 100;
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
