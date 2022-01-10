import 'package:flutter/material.dart';

class Custom{
  static getBoxDecoration(BuildContext context){
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 0.2,
          blurRadius: 4,
        ),
      ],
    );
  }
}