int epochSecsNow() {
  DateTime n = DateTime.now().toUtc();
  var s = n.millisecondsSinceEpoch / 1000;
  return s.round();
}

String secondsToSensibleTimePeriod(num secs) {
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
