import 'package:flutter/material.dart';

import '../../../infrastructure/commons/keys.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage(this.exception);
  final Exception? exception;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 200,
          ),
          Image.asset(
            'assets/logo_sad.png',
            scale: 2,
          ),
          SizedBox(
            height: 100,
          ),
          Text(Keys.error.toUpperCase()),
        ],
      ),
    );
  }
}
