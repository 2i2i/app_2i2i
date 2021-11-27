import 'package:app_2i2i/common/utils.dart';

const String F = 'ONLY - PROVIDER - ';
void log(String message) {
  if (!message.startsWith(F)) return;
  final now = DateTime.now().toUtc();
  final N = epochSecsNow();
  print('************* - $now ($N): $message');
}
