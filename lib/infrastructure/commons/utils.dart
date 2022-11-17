import 'dart:convert';
import 'dart:math';

import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'keys.dart';

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

int epochSecsNow() {
  DateTime n = DateTime.now().toUtc();
  var s = n.millisecondsSinceEpoch / 1000;
  return s.round();
}

extension DateTimeExtension on DateTime {
  DateTime toLocalDateTime({String format = "yyyy-MM-dd hh:mm:ss"}) {
    var dateTime = DateFormat(format).parse(this.toString(), false);
    return dateTime.toLocal();
  }
}

extension ParseToDate on Object {
  DateTime? toDate() {
    if (this is String) {
      return DateTime.tryParse(this as String)?.toLocal();
    } else if (this is num) {
      var n = (this as num).toInt();
      return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
    } else if (this is int) {
      var n = (this as int);
      return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
    } else if (this is Timestamp) {
      return (this as Timestamp).toDate().toLocal();
    }
    return null;
  }
}

extension ParseToTimeStamp on Timestamp {
  DateTime? toDate() {
    return this.toDate().toLocal();
  }
}

String secondsToSensibleTimePeriod(num secs, BuildContext context) {
  if (secs == 0) return Keys.zero.tr(context);
  if (secs == double.infinity) return Keys.forever.tr(context);

  String currentBestTimePeriod = Keys.secs.tr(context);
  double currentBestNum = secs.toDouble();
  // int currentBestNumDigits = mainPartLength(currentBestNum);

  // minutes
  final minutesNum = currentBestNum / 60;
  if (minutesNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = Keys.minutes.tr(context);
  currentBestNum = minutesNum;
  // final minutesLength = mainPartLength(minutesNum);

  // hours
  final hoursNum = currentBestNum / 60;
  if (hoursNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = Keys.hours.tr(context);
  currentBestNum = hoursNum;

  // days
  final daysNum = currentBestNum / 24;
  if (daysNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = Keys.days.tr(context);
  currentBestNum = daysNum;

  // weeks
  final weeksNum = currentBestNum / 7;
  if (weeksNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = Keys.weeks.tr(context);
  currentBestNum = weeksNum;

  // months
  final monthsNum = currentBestNum / 4.35;
  if (monthsNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = Keys.months.tr(context);
  currentBestNum = monthsNum;

  // years
  final yearsNum = currentBestNum / 12;
  if (yearsNum < 1) {
    final bestNum = currentBestNum.round();
    return '~ $bestNum $currentBestTimePeriod';
  }
  currentBestTimePeriod = Keys.years.tr(context);
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

num doubleWithoutDecimalToInt(double val) {
  return val % 1 == 0 ? val.toInt() : val;
}

bool haveToWait(var provider) {
  if (provider is AsyncError) {
    log('\n\n\n\n\n\n\n\n\n\n${provider.stackTrace.toString()}\n\n\n\n\n\n\n\n\n\n');
  }
  return provider == null || provider is AsyncLoading || provider is AsyncError;
}

Future<String> getWCBridge() async {
  try {
    final r = await http.get(Uri.parse('https://wc.perawallet.app/servers.json'));
    final jsonResponse = jsonDecode(r.body);
    if (jsonResponse is Map && jsonResponse['servers'] is List) {
      final bridges = jsonResponse["servers"];
      final rng = Random();
      final ix = rng.nextInt(bridges.length);
      return bridges[ix];
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return 'https://bridge.walletconnect.org';
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
/*
class MyBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => ClampingScrollPhysics();
}*/
