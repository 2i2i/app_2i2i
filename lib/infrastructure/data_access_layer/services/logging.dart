import 'package:app_2i2i/infrastructure/commons/utils.dart';

const String F = 'F - ';
const String G = 'G - ';
const String H = 'H - ';
const String I = 'I - ';
void log(String message) {
  // if (!message.startsWith(I)) return;
  final now = DateTime.now().toUtc();
  final N = epochSecsNow();
  print('************* - $now ($N): $message');
}