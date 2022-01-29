import 'package:app_2i2i/infrastructure/commons/utils.dart';

const String F = 'F - ';
const String G = 'G - ';
const String H = 'H - ';
const String I = 'I - ';
const String J = 'J - ';
const String X = 'X - ';
void log(String message) {
  if (!message.startsWith(X)) return;
  final now = DateTime.now().toUtc();
  final N = epochSecsNow();
  print('************* - $now ($N): $message');
}
