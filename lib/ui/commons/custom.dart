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
}