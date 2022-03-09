import 'package:flutter/material.dart';

class BGImageWidget extends StatelessWidget {
  final Widget child;
  const BGImageWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/login_bg.png',
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        child
      ],
    );
  }
}
