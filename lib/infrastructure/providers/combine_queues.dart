import 'dart:collection';
import 'dart:math';

import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

BidInPublic bTest(speed, minSpeed, importChrony, importHighroller, ts) {
  final t = Timestamp.fromMicrosecondsSinceEpoch(ts);
  log('ts=$ts - t.microsecondsSinceEpoch=${t.microsecondsSinceEpoch}');
  final x = BidInPublic.fromMap({
    'speed': Quantity.fromMap({
      'num': speed,
      'assetId': 0,
    }).toMap(),
    'rule': HangOutRule.fromMap({
      'maxMeetingDuration': 300,
      'minSpeed': minSpeed,
      'importance': {
        'chrony': importChrony,
        'highroller': importHighroller,
      },
    }).toMap(),
    'net': AlgorandNet.testnet.toStringEnum(),
    'active': true,
    'ts': Timestamp.fromMicrosecondsSinceEpoch(ts),
    'budget': 50,
  }, (speed == minSpeed ? 'C' : 'H') + '_' + ts.toString());
  return x;
}

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

void combineQueuesTestRun() {
  final testData = combineQueuesTestCreate_7();
  final bidInsPublic = testData['public'];
  final loungeHistory = testData['loungeHistory'];
  final loungeHistoryIndex = testData['loungeHistoryIndex'];
  final bidIns =
      combineQueuesCore(bidInsPublic, loungeHistory, loungeHistoryIndex);
  log('C: ${bidIns.where((e) => e.public.speed.num == e.public.rule.minSpeed).length}');
  log('H: ${bidIns.where((e) => e.public.speed.num != e.public.rule.minSpeed).length}');
  log('bidIns: ${bidIns.length}');
  final result = bidIns
      .map((e) =>
          (e.public.speed.num == e.public.rule.minSpeed ? 'C' : 'H') +
          '_' +
          e.public.ts.microsecondsSinceEpoch.toString())
      .join(' ');
  log(result);
}

List<BidIn> combineQueuesCore(List<BidInPublic> bidInsPublic,
    List<int> loungeHistory, int loungeHistoryIndex) {
  // create bid ins
  List<BidIn> bidIns =
      bidInsPublic.map((e) => BidIn(public: e, private: null)).toList();

  List<BidIn> bidInsChronies = bidIns
      .where((bidIn) => bidIn.public.speed.num == bidIn.public.rule.minSpeed)
      .toList();
  List<BidIn> bidInsHighRollers = bidIns
      .where((bidIn) => bidIn.public.rule.minSpeed < bidIn.public.speed.num)
      .toList();
  if (bidInsChronies.length + bidInsHighRollers.length != bidIns.length)
    throw Exception(
        'UserBidInsList: bidInsChronies.length + bidInsHighRollers.length != bidIns.length');

  bidInsHighRollers.sort((b1, b2) {
    return b2.public.speed.num.compareTo(b1.public.speed.num);
  });

  // if one side empty, return other side
  if (bidInsHighRollers.isEmpty)
    return bidInsChronies;
  else if (bidInsChronies.isEmpty) return bidInsHighRollers;

  List<BidIn> bidInsSorted = [];
  Queue<int> recentLoungesHistory = Queue(); // need size?
  int chronyIndex = 0;
  int highRollerIndex = 0;
  int loungeSum = 0;
  while (
      bidInsSorted.length < bidInsChronies.length + bidInsHighRollers.length) {
    BidIn nextChrony = bidInsChronies[chronyIndex];
    BidIn nextHighroller = bidInsHighRollers[highRollerIndex];

    // next rule comes from the earlier guest if different
    HangOutRule nextRule = nextChrony.public.rule == nextHighroller.public.rule
        ? nextChrony.public.rule
        : (nextChrony.public.ts.microsecondsSinceEpoch <
                nextHighroller.public.ts.microsecondsSinceEpoch
            ? nextChrony.public.rule
            : nextHighroller.public.rule);
    final N = nextRule.importance.values
        .fold(0, (int previousValue, int element) => previousValue + element);
    double targetChronyRatio = nextRule.importance[Lounge.chrony]! / N;

    // is nextChrony eligible according to nextRule
    if (nextChrony.public.speed.num < nextRule.minSpeed) {
      // choose HighRoller
      bidInsSorted.add(nextHighroller);

      // next
      highRollerIndex += 1;

      // if highrollers done, add remaining chronies and done
      if (highRollerIndex == bidInsHighRollers.length) {
        for (int i = chronyIndex; i < bidInsChronies.length; i++) {
          bidInsSorted.add(bidInsChronies[i]);
          return bidInsSorted;
        }
      }

      // move to next index
      continue;
    }

    // first calc  of loungeSum
    if (recentLoungesHistory.isEmpty) {
      // should only arrive here first time

      // my hangout
      if (loungeHistory.isNotEmpty) {
        final loungeHistoryList = loungeHistory;
        // .map((l) => Lounge.values.indexWhere((e) => e.toStringEnum() == l))
        // .toList();
        // final loungeHistoryIndex = hangout.loungeHistoryIndex;
        final end = loungeHistoryIndex;
        final start = (end - N + 1) % loungeHistoryList.length;

        final N_tile = min(loungeHistoryList.length, N);
        int i = start;
        while (recentLoungesHistory.length < N_tile) {
          recentLoungesHistory.addLast(loungeHistoryList[i]);
        }

        loungeSum = recentLoungesHistory.fold(
            0, (int previousValue, int element) => previousValue + element);
      }
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
