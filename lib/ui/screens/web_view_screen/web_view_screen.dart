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
            initialData: InAppWebViewInitialData(data: """<html>

<head>
<meta name="viewport" content="width=device-width">
</head>
<iframe id='iframe-widget'
        src='https://changenow.io/embeds/exchange-widget/v2/widget.html?FAQ=true&amount=100&backgroundColor=FFFFFF&darkMode=false&from=usd&horizontal=false&lang=en-US&link_id=5cc8755972e91a&locales=true&logo=true&primaryColor=00C26F&to=algo&toTheMoon=true&topUpMode=true&topUpAddress=${widget.walletAddress}&topUpCurrency=algo&topUpNetwork=ALGO'
        style="height: 356px; width: 100%; border: none"></iframe>
<script defer type='text/javascript'
        src='https://changenow.io/embeds/exchange-widget/v2/stepper-connector.js'></script>

</html>

"""),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                supportZoom: false,
                javaScriptEnabled: true,
                disableHorizontalScroll: false,
                disableVerticalScroll: false,
                transparentBackground: true,
              ),

              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                hardwareAcceleration: true,
                useWideViewPort: true,
                initialScale: 100,
                allowFileAccess: true,
                useShouldInterceptRequest: true,
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
