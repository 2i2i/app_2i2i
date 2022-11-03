import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/cupertino.dart';

const String F = 'F - ';
const String G = 'G - ';
const String H = 'H - ';
const String I = 'I - ';
const String J = 'J - ';
const String E = 'ERROR - ';
const String K = 'K - ';
const String X = 'X - ';
const String Y = 'Y - ';
const String FX = 'FX - ';
const String A = 'A - ';
const String B = 'B - ';

void log(String message) {
  // if (!message.startsWith(B)) return;
  final now = DateTime.now().toUtc();
  final N = epochSecsNow();
  debugPrint('************* - $now ($N): $message');
}
