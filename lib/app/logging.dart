import 'package:app_2i2i/app/utils.dart';

const String F = 'ONLY - ';
void log(String message) {
  // if (!message.startsWith(F)) return;
  final now = DateTime.now().toUtc();
  final N = epochSecsNow();
  print('************* - $now ($N): $message');
}
