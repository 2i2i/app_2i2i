import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String? walletAddress;

  const WebViewScreen({Key? key, this.walletAddress}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(data: """
<iframe id='iframe-widget'
        src='https://changenow.io/embeds/exchange-widget/v2/widget.html?FAQ=true&amount=100&backgroundColor=FFFFFF&darkMode=false&from=usd&horizontal=false&lang=en-US&link_id=5cc8755972e91a&locales=true&logo=true&primaryColor=00C26F&to=algo&toTheMoon=true&topUpMode=true&topUpAddress=${widget.walletAddress}&topUpCurrency=algo&topUpNetwork=ALGO'
        style="height: 356px; width: 100%; border: none"></iframe>
<script defer type='text/javascript'
        src='https://changenow.io/embeds/exchange-widget/v2/stepper-connector.js'></script>
"""),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                transparentBackground: true,
                mediaPlaybackRequiresUserGesture: false,
                supportZoom: false,
                javaScriptEnabled: true,
                disableHorizontalScroll: true,
                disableVerticalScroll: true,
                preferredContentMode: UserPreferredContentMode.MOBILE,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                hardwareAcceleration: true
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              ),
            ),
            onLoadStop: (InAppWebViewController controller, Uri? url) {
              setState(() {
                isLoading = false;
              });
            },
          ),
          isLoading
              ? Center(
                  child: CupertinoActivityIndicator(),
                )
              : Stack(),
        ],
      ),
    );
  }
}
