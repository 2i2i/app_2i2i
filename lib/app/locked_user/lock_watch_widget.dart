import 'package:flutter/material.dart';

class IsUserLocked extends ValueNotifier {
  IsUserLocked(value) : super(value);

  void changeValue(newValue) {
    value = newValue;
  }
}
