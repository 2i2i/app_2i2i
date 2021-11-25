import 'package:flutter/material.dart';

class TestBanner extends StatelessWidget {
  const TestBanner(this.w, {Key? key}) : super(key: key);
  final Widget w;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        w,
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
