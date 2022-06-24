import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String shortString(String string, {int maxLength = 10}) {
  if (maxLength < string.length) return string.substring(0, maxLength - 3) + '...';
  return string;
}

String ordinalIndicator(int x) {
  if (x == 1) return 'st';
  if (x == 2) return 'nd';
  if (x == 3) return 'rd';
  return 'th';
}

String microALGOToLargerUnit(int microALGO, {int maxDigits = 2, String unitALGO = 'ALGO'}) {
  final N = microALGO.toString().length;
  if (N <= maxDigits) return '$microALGO μ$unitALGO';
  if (N <= maxDigits + 3) return '~${(microALGO / 1000).round()} m$unitALGO';
  if (N <= maxDigits + 4) return '~${(microALGO / 10000).round()} c$unitALGO';
  if (N <= maxDigits + 5) return '~${(microALGO / 100000).round()} d$unitALGO';
  if (N <= maxDigits + 6) return '~${(microALGO / 1000000).round()} $unitALGO';
  if (N <= maxDigits + 7) return '~${(microALGO / 10000000).round()} deca$unitALGO';
  if (N <= maxDigits + 8) return '~${(microALGO / 100000000).round()} hecto$unitALGO';
  if (N <= maxDigits + 9) return '~${(microALGO / 1000000000).round()} k$unitALGO';
  if (N <= maxDigits + 10) return '~${(microALGO / 10000000000).round()} M$unitALGO';
  if (N <= maxDigits + 11) return '~${(microALGO / 100000000000).round()} G$unitALGO';
  if (N <= maxDigits + 12) return '~${(microALGO / 1000000000000).round()} MALGO';
  throw Exception('microALGOToLargerUnit - amount too large: microALGO=$microALGO - maxDigits=$maxDigits');
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

extension NoRoundingDecimal on double {
  String toDecimalAsFixed(int toDecimal) {
    var right;
    try {
      right = this.toString().split(".")[1].padRight(toDecimal, "0").substring(0, toDecimal);
    } catch (e) {
      right = "00";
    }
    var left = this.toString().split(".")[0];

    double number = double.parse(left + "." + right);
    return number.toStringAsFixed(toDecimal);
  }
}

String getDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
}

String prettyDuration(Duration duration) {
  var components = <String>[];

  var days = duration.inDays;
  if (days != 0) {
    components.add('${days}d ');
  }
  var hours = duration.inHours % 24;
  if (hours != 0) {
    components.add('${hours}h ');
  }
  var minutes = duration.inMinutes % 60;
  if (minutes != 0) {
    components.add('${minutes}m ');
  }

  var seconds = duration.inSeconds % 60;
  var centiseconds = (duration.inMilliseconds % 1000) ~/ 10;
  if (components.isEmpty || seconds != 0 || centiseconds != 0) {
    components.add('$seconds');
    if (centiseconds != 0) {
      components.add('.');
      components.add(centiseconds.toString().padLeft(2, '0'));
    }
    components.add('s');
  }
  return components.join();
}

bool haveToWait(var provider) {
  if (provider is AsyncError) {
    log('\n\n\n\n\n\n\n\n\n\n${provider.stackTrace.toString()}\n\n\n\n\n\n\n\n\n\n');
  }
  return provider == null || provider is AsyncLoading || provider is AsyncError;
}

class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => ClampingScrollPhysics();
}
