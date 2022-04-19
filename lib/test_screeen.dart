import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestScreen1 extends StatefulWidget {
  const TestScreen1({Key? key}) : super(key: key);

  @override
  _TestScreen1State createState() => _TestScreen1State();
}

class _TestScreen1State extends State<TestScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialFile: "assets/html/i_frame",
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            supportZoom: false,
            javaScriptEnabled: true,
            disableHorizontalScroll: true,
            disableVerticalScroll: true,
            preferredContentMode: UserPreferredContentMode.MOBILE,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
            hardwareAcceleration: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
          ),
        ),
      ),
    );
  }
}
