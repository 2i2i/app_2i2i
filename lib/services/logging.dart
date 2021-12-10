import 'package:app_2i2i/common/utils.dart';

const String F = 'ONLY - PROVIDER - ';
const String G = '2ONLY - ';
void log(String message) {
  if (!message.startsWith(G)) return;
  final now = DateTime.now().toUtc();
  final N = epochSecsNow();
  print('************* - $now ($N): $message');
}
