import 'package:flutter/material.dart';

class CustomNavigation {
  static pop(BuildContext context) {
    Navigator.pop(context);
  }

  static push(BuildContext context, Widget page) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) => page));
  }

  static pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
        context, new MaterialPageRoute(builder: (context) => page));
  }

  static pushAndRemoveUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => page),
        (Route<dynamic> route) => false);
  }
}
