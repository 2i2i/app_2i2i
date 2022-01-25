import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String shortString(String string, {int maxLength = 10}) {
  if (maxLength < string.length)
    return string.substring(0, maxLength - 3) + '...';
  return string;
}

String ordinalIndicator(int x) {
  if (x == 1) return 'st';
  if (x == 2) return 'nd';
  if (x == 3) return 'rd';
  return 'th';
}

String microALGOToLargerUnit(int microALGO, {int maxDigits = 2}) {
  final N = microALGO.toString().length;
  log(X + 'microALGOToLargerUnit - microALGO=$microALGO - N=$N');
  if (N <= maxDigits) return '$microALGO μALGO';
  if (N <= maxDigits + 3) return '~${(microALGO / 1000).round()} mALGO';
  if (N <= maxDigits + 4) return '~${(microALGO / 10000).round()} cALGO';
  if (N <= maxDigits + 5) return '~${(microALGO / 100000).round()} dALGO';
  if (N <= maxDigits + 6) return '~${(microALGO / 1000000).round()} ALGO';
  if (N <= maxDigits + 7) return '~${(microALGO / 10000000).round()} decaALGO';
  if (N <= maxDigits + 8) return '~${(microALGO / 100000000).round()} hectoALGO';
  if (N <= maxDigits + 9) return '~${(microALGO / 1000000000).round()} kALGO';
  if (N <= maxDigits + 10) return '~${(microALGO / 10000000000).round()} MALGO';
  if (N <= maxDigits + 11) return '~${(microALGO / 100000000000).round()} GALGO';
  if (N <= maxDigits + 12)
    return '~${(microALGO / 1000000000000).round()} MALGO';
  throw Exception(
      'microALGOToLargerUnit - amount too large: microALGO=$microALGO - maxDigits=$maxDigits');
}

int epochSecsNow() {
  DateTime n = DateTime.now().toUtc();
  var s = n.millisecondsSinceEpoch / 1000;
  return s.round();
}

String secondsToSensibleTimePeriod(num secs) {
  if (secs == 0) return 'zero';
  if (secs == double.infinity) return 'foreever';

  String currentBestTimePeriod = 'secs';
  double currentBestNum = secs.toDouble();
  // int currentBestNumDigits = mainPartLength(currentBestNum);

  // minutes
  final minutesNum = currentBestNum / 60;
  if (minutesNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'minutes';
  currentBestNum = minutesNum;
  // final minutesLength = mainPartLength(minutesNum);

  // hours
  final hoursNum = currentBestNum / 60;
  if (hoursNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'hours';
  currentBestNum = hoursNum;

  // days
  final daysNum = currentBestNum / 24;
  if (daysNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'days';
  currentBestNum = daysNum;

  // weeks
  final weeksNum = currentBestNum / 7;
  if (weeksNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'weeks';
  currentBestNum = weeksNum;

  // months
  final monthsNum = currentBestNum / 4.35;
  if (monthsNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'months';
  currentBestNum = monthsNum;

  // years
  final yearsNum = currentBestNum / 12;
  if (yearsNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'years';
  currentBestNum = yearsNum;

  // decades
  final decadesNum = currentBestNum / 10;
  if (decadesNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = 'decades';
  currentBestNum = decadesNum;

  final bestNum = currentBestNum.round();
  return '~ $bestNum $currentBestTimePeriod';
}

num getMaxDuration({required num budget, required num speed}) {
  if (speed <= 0) {
    return double.infinity;
  }
  return (budget / speed).floor();
}

String getDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
}

bool haveToWait(var provider) {
  if (provider is AsyncError) {
    log('\n\n\n\n\n\n\n\n\n\n${provider.stackTrace.toString()}\n\n\n\n\n\n\n\n\n\n');
  }
  return provider == null || provider is AsyncLoading || provider is AsyncError;
}
