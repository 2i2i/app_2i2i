import 'package:flutter/material.dart';

class Custom{
  static getBoxDecoration(BuildContext context, {Color? color ,double radius = 10}) {
    return BoxDecoration(
      color: color??Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          offset: Offset(2, 4),
          blurRadius: 8,
          color: Colors.black12.withOpacity(0.1),
        ),
      ],
    );
  }

  static String validateValueData(String value) {
    Pattern pattern = r'[0-9][A-Z]\w+';
    RegExp regex = new RegExp(pattern.toString());
    if (regex.hasMatch(value)) {
      return regex.firstMatch(value)?.group(0) ?? "";
    }
    return "";
  }
}