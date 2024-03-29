import 'dart:collection';
import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final CHRONY_GAP = 0.01;

// bidInsPublic comes sorted by ts
List<BidInPublic> combineQueues(List<BidInPublic> bidInsPublic, List<Lounge> loungeHistory, int loungeHistoryIndex) {
  final loungeHistoryAsInts = loungeHistory.map((e) => Lounge.values.indexWhere((element) => element == e)).toList();
  List<List<BidInPublic>> sections = _splitByRules(bidInsPublic);
  final sortedSections = sections.map((e) => _combineQueuesCore(e, loungeHistoryAsInts, loungeHistoryIndex)).toList();
  final bidInsPublicSorted = sortedSections.expand((element) => element).toList();
  return bidInsPublicSorted;
}

List<List<BidInPublic>> _splitByRules(List<BidInPublic> bidInsPublic) {
  final List<List<BidInPublic>> bidInsPublicSections = [];
  if (bidInsPublic.isEmpty) return bidInsPublicSections;

  Rule currentRule = bidInsPublic.first.rule;
  List<BidInPublic> currentSection = [];
  for (final bidIn in bidInsPublic) {
    if (bidIn.rule == currentRule)
      currentSection.add(bidIn);
    else {
      bidInsPublicSections.add(currentSection);
      currentSection = [bidIn];
      currentRule = bidIn.rule;
    }
  }
  if (currentSection.isNotEmpty) bidInsPublicSections.add(currentSection);

  return bidInsPublicSections;
}

int speedNumInMicroALGO(BidInPublic bidIn) => (bidIn.speed.num * bidIn.FX).round();
// due to FX, it would be near impossible to be a Chrony with if CHRONY_GAP == 0
bool isChrony(BidInPublic bidIn) {
  final speedMicroAlgo = speedNumInMicroALGO(bidIn);
  final min = bidIn.rule.minSpeedMicroALGO * (1.0 - CHRONY_GAP);
  final max = bidIn.rule.minSpeedMicroALGO * (1.0 + CHRONY_GAP);
  return min <= speedMicroAlgo && speedMicroAlgo <= max;
}
bool isHighRoller(BidInPublic bidIn) {
  final speedMicroAlgo = speedNumInMicroALGO(bidIn);
  final max = bidIn.rule.minSpeedMicroALGO * (1.0 + CHRONY_GAP);
  return max < speedMicroAlgo;
}
bool isEccentric(BidInPublic bidIn) => bidIn.FX == null; // TODO FX can null for eccentric
bool isLurker(BidInPublic bidIn) {
  final speedMicroAlgo = speedNumInMicroALGO(bidIn);
  final min = bidIn.rule.minSpeedMicroALGO * (1.0 - CHRONY_GAP);
  return speedMicroAlgo < min;
}

List<BidInPublic> _combineQueuesCore(List<BidInPublic> bidInsPublic, List<int> loungeHistory, int loungeHistoryIndex) {
  // split into chronies and highrollers
  List<BidInPublic> bidInsChronies = bidInsPublic.where(isChrony).toList();
  List<BidInPublic> bidInsHighRollers = bidInsPublic.where(isHighRoller).toList();
  List<BidInPublic> bidInsEccentrics = bidInsPublic.where(isEccentric).toList();
  List<BidInPublic> bidInsLurkers = bidInsPublic.where(isLurker).toList();
  if (bidInsChronies.length + bidInsHighRollers.length + bidInsEccentrics.length + bidInsLurkers.length != bidInsPublic.length)
    throw Exception('UserBidInsList: bidInsChronies.length + bidInsHighRollers.length + bidInsEccentrics.length + bidInsLurkers.length != bidIns.length');

  // sort highrollers by speed
  bidInsHighRollers.sort((b1, b2) {
    return b2.speed.num.compareTo(b1.speed.num);
  });

  Rule rule = bidInsPublic.first.rule; // same for all bids
  // if one side empty, return other side
  if (bidInsHighRollers.isEmpty || rule.importance[Lounge.highroller]! == 0)
    return bidInsChronies;
  else if (bidInsChronies.isEmpty || rule.importance[Lounge.chrony]! == 0) return bidInsHighRollers;
  final N = rule.importance.values.fold(0, (int previousValue, int element) => previousValue + element);
  double targetChronyRatio = rule.importance[Lounge.chrony]! / N;

  // loop
  List<BidInPublic> bidInsSorted = [];
  Queue<int> recentLoungesHistory = Queue(); // need size?
  int chronyIndex = 0;
  int highRollerIndex = 0;
  int loungeSum = 0;
  while (bidInsSorted.length < bidInsChronies.length + bidInsHighRollers.length) {
    BidInPublic nextChrony = bidInsChronies[chronyIndex];
    BidInPublic nextHighroller = bidInsHighRollers[highRollerIndex];

    // first calc  of loungeSum
    if (recentLoungesHistory.isEmpty && loungeHistory.isNotEmpty) {
      final end = loungeHistoryIndex;
      final N_tile = min(loungeHistory.length, N - 1);
      int i = end;
      while (recentLoungesHistory.length < N_tile) {
        recentLoungesHistory.addFirst(loungeHistory[i]);
        i--;
        i %= loungeHistory.length;
      }

      loungeSum = recentLoungesHistory.fold(0, (int previousValue, int element) => previousValue + element);
    }

    // update loungeSum
    if (recentLoungesHistory.length == N) {
      loungeSum -= recentLoungesHistory.removeFirst();
    }
    final M = recentLoungesHistory.length + 1;
    int loungeSumChrony = loungeSum + 0;
    int loungeSumHighroller = loungeSum + 1;
    double ifChronyRatio = 1.0 - loungeSumChrony / M;
    double ifHighrollerRatio = 1.0 - loungeSumHighroller / M;
    double ifChronyError = (ifChronyRatio - targetChronyRatio).abs();
    double ifHighrollerError = (ifHighrollerRatio - targetChronyRatio).abs();
    if (ifChronyError <= ifHighrollerError) {
      // choose chrony
      bidInsSorted.add(nextChrony);
      final value = 0;
      recentLoungesHistory.addLast(value);
      // loungeSum += value;
      chronyIndex += 1;

      // if chronies done, add remaining highrollers and done
      if (chronyIndex == bidInsChronies.length) {
        for (int i = highRollerIndex; i < bidInsHighRollers.length; i++) {
          bidInsSorted.add(bidInsHighRollers[i]);
        }
        return bidInsSorted;
      }
    } else {
      // choose highroller
      bidInsSorted.add(nextHighroller);
      final value = 1;
      recentLoungesHistory.addLast(value);
      loungeSum += value;
      highRollerIndex += 1;

      // if highrollers done, add remaining chronies and done
      if (highRollerIndex == bidInsHighRollers.length) {
        for (int i = chronyIndex; i < bidInsChronies.length; i++) {
          bidInsSorted.add(bidInsChronies[i]);
        }
        return bidInsSorted;
      }
    }
  } // while

  return bidInsSorted;
}

// TESTS

BidInPublic bTest(speed, minSpeed, importChrony, importHighroller, ts) => BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': speed,
        'assetId': 0,
      }).toMap(),
      'rule': Rule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': minSpeed,
        'importance': {
          'chrony': importChrony,
          'highroller': importHighroller,
        },
      }).toMap(),
      'net': AppConfig().ALGORAND_NET.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(ts),
      'budget': 50,
    }, (speed == minSpeed ? 'C' : 'H') + '_' + ts.toString());

// expect id1
Map combineQueuesTestCreate_1() {
  List<BidInPublic> bidInsPublic = [
    bTest(0, 0, 1, 5, 10),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

// expect id2, id1
Map combineQueuesTestCreate_2() {
  List<BidInPublic> bidInsPublic = [
    bTest(0, 0, 1, 5, 10),
    bTest(1, 0, 1, 5, 11),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

// expect id2, id3, id4, id2
Map combineQueuesTestCreate_3() {
  List<BidInPublic> bidInsPublic = [
    bTest(5, 5, 2, 1, 10),
    bTest(10, 5, 2, 1, 11),
    bTest(15, 5, 2, 1, 12),
    bTest(5, 5, 2, 1, 13),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

// expect id2, id3, id4, id2
Map combineQueuesTestCreate_4() {
  List<BidInPublic> bidInsPublic = [
    // bTest(speed, minSpeed, importChrony, importHighroller, ts)
    bTest(5, 5, 5, 1, 10),
    bTest(5, 5, 5, 1, 11),
    bTest(5, 5, 5, 1, 12),
    bTest(5, 5, 5, 1, 13),
    bTest(5, 5, 5, 1, 13),
    bTest(5, 5, 5, 1, 13),
    bTest(5, 5, 5, 1, 13),
    bTest(10, 5, 5, 1, 13),
    bTest(5, 5, 5, 1, 13),
    bTest(7, 5, 5, 1, 13),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

Map combineQueuesTestCreate_5() {
  int c = 3;
  int hr = 1;

  List<BidInPublic> bidInsPublic = [
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

Map combineQueuesTestCreate_6() {
  int c = 3;
  int hr = 5;

  List<BidInPublic> bidInsPublic = [
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(5, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
    bTest(6, 5, c, hr, 10),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

Map combineQueuesTestCreate_7() {
  List<BidInPublic> bidInsPublic = [
    bTest(5, 5, 10, 1, 10000),
    bTest(5, 5, 10, 1, 11000),
    bTest(5, 5, 10, 1, 12000),
    bTest(5, 5, 10, 1, 13000),
    bTest(5, 5, 10, 1, 14000),
    bTest(5, 5, 1, 3, 15000),
    bTest(5, 5, 1, 3, 16000),
    bTest(5, 5, 1, 3, 17000),
    bTest(5, 5, 1, 3, 18000),
    bTest(7, 5, 1, 3, 19000),
    bTest(5, 5, 1, 3, 20000),
    bTest(6, 5, 1, 3, 21000),
    bTest(5, 5, 1, 3, 22000),
    bTest(8, 5, 1, 3, 23000),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

Map combineQueuesTestCreate_8() {
  List<BidInPublic> bidInsPublic = [
    bTest(5, 5, 10, 1, 10000),
    bTest(5, 5, 1, 3, 15000),
    bTest(5, 5, 1, 3, 16000),
    bTest(5, 5, 1, 3, 17000),
    bTest(5, 5, 1, 3, 18000),
    bTest(7, 5, 1, 3, 19000),
    bTest(5, 5, 1, 3, 20000),
    bTest(6, 5, 1, 3, 21000),
    bTest(5, 5, 1, 3, 22000),
    bTest(8, 5, 1, 3, 23000),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    'loungeHistoryIndex': 5,
    // 'loungeHistory': <int>[],
    // 'loungeHistoryIndex': 0,
  };
}

Map combineQueuesTestCreate_random_single(double changeRuleProb, double highRollerProb, List<int> loungeHistory, int loungeHistoryIndex) {
  final rng = new Random();
  final N = rng.nextInt(1000);
  log('N=$N');
  List<BidInPublic> bidInsPublic = [];
  int c = rng.nextInt(10);
  int h = rng.nextInt(10);
  int minSpeed = 0;
  List<String> rulesStrings = ['c=$c - h=$h'];
  List<String> speedsStrings = [];

  for (int i = 0; i < N; i++) {
    final changeRule = rng.nextDouble() <= changeRuleProb;
    if (changeRule) {
      c = rng.nextInt(10);
      h = rng.nextInt(10);
      if (c + h == 0) continue;
      rulesStrings.add('i=$i - c=$c - h=$h');
    }

    bool highRoller = rng.nextDouble() <= highRollerProb;
    if (c == 0)
      highRoller = true;
    else if (h == 0) highRoller = false;
    int speed = minSpeed + (highRoller ? rng.nextInt(10) : 0);
    speedsStrings.add('i=$i - speed=$speed');

    final b = bTest(speed, minSpeed, c, h, 10000 + i * 1000);
    bidInsPublic.add(b);
  }
  return {
    'public': bidInsPublic,
    'loungeHistory': loungeHistory,
    'loungeHistoryIndex': loungeHistoryIndex,
  };
}

Map combineQueuesTestCreate_9() => combineQueuesTestCreate_random_single(0.1, 0.2, [1, 1, 1, 0, 0, 0, 1, 0], 4);

void combineQueuesTestRun() {
  final testData = combineQueuesTestCreate_9();
  final bidInsPublic = testData['public'];
  final loungeHistory = testData['loungeHistory']; // 0: chrony, 1: highroller
  final loungeHistoryIndex = testData['loungeHistoryIndex'];
  final bidIns = combineQueues(bidInsPublic, loungeHistory, loungeHistoryIndex);
  log('C: ${bidIns.where(isChrony).length}');
  log('H: ${bidIns.where(isHighRoller).length}');
  log('E: ${bidIns.where(isEccentric).length}');
  log('L: ${bidIns.where(isLurker).length}');
  log('bidIns: ${bidIns.length}');
  final result = bidIns.map((e) => (e.speed.num == e.rule.minSpeedMicroALGO ? 'C' : 'H') + '_' + e.ts.microsecondsSinceEpoch.toString()).join(' ');
  log(result);
}
