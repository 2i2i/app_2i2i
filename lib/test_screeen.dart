import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TestScreen1 extends StatefulWidget {
  const TestScreen1({Key? key}) : super(key: key);

  @override
  _TestScreen1State createState() => _TestScreen1State();
}

class _TestScreen1State extends State<TestScreen1> {
  static const platform = MethodChannel('code');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                initialFile: "assets/html/i_frame",
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      supportZoom: true,
                      preferredContentMode: UserPreferredContentMode.RECOMMENDED),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
