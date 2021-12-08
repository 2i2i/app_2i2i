import 'package:flutter/material.dart';

class TestBanner extends StatelessWidget {
  const TestBanner({Key? key, this.widget}) : super(key: key);
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget!,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: EdgeInsets.only(top: 55, right: 50),
            child: Banner(
              message: "testnet",
              location: BannerLocation.bottomStart,
            ),
          ),
        ),
      ],
    );
  }
}
