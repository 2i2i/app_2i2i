import 'package:flutter/material.dart';

class WaitPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 200,
          ),
          Image.asset(
            'assets/logo.png',
            scale: 2,
          ),
          SizedBox(
            height: 100,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
