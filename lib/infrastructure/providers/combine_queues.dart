import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// expect id1
Map combineQueuesTestCreate_1() {
  List<BidInPublic> bidInsPublic = [
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 0,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 0,
        'importance': {
          'chrony': 1,
          'highroller': 5,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromDate(DateTime.now().toUtc()),
      'budget': 50,
    }, 'id'),
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
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 0,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 0,
        'importance': {
          'chrony': 1,
          'highroller': 5,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(10),
      'budget': 50,
    }, 'id1'),
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 1,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 0,
        'importance': {
          'chrony': 1,
          'highroller': 5,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(11),
      'budget': 50,
    }, 'id2'),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

// expect id2, id4, id3, id2
Map combineQueuesTestCreate_3() {
  List<BidInPublic> bidInsPublic = [
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 5,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 5,
        'importance': {
          'chrony': 2,
          'highroller': 1,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(10),
      'budget': 50,
    }, 'id1'),
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 10,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 5,
        'importance': {
          'chrony': 2,
          'highroller': 1,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(11),
      'budget': 50,
    }, 'id2'),
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 15,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 5,
        'importance': {
          'chrony': 2,
          'highroller': 1,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(12),
      'budget': 50,
    }, 'id3'),
    BidInPublic.fromMap({
      'speed': Quantity.fromMap({
        'num': 5,
        'assetId': 0,
      }).toMap(),
      'rule': HangOutRule.fromMap({
        'maxMeetingDuration': 300,
        'minSpeed': 5,
        'importance': {
          'chrony': 2,
          'highroller': 1,
        },
      }).toMap(),
      'net': AlgorandNet.testnet.toStringEnum(),
      'active': true,
      'ts': Timestamp.fromMicrosecondsSinceEpoch(13),
      'budget': 50,
    }, 'id4'),
  ];
  return {
    'public': bidInsPublic,
    'loungeHistory': <int>[],
    'loungeHistoryIndex': 0,
  };
}

void combineQueuesTestRun() {
  final testData = combineQueuesTestCreate_3();
  final bidInsPublic = testData['public'];
  final loungeHistory = testData['loungeHistory'];
  final loungeHistoryIndex = testData['loungeHistoryIndex'];
  final bidIns =
      combineQueuesCore(bidInsPublic, loungeHistory, loungeHistoryIndex);
  bidIns.forEach((x) => log(x.toString()));
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

  bool loungeSumSet = false;
  int loungeSum = 0;
  int loungeSumCount = 0;
  int tailLounge = 0;

  List<BidIn> bidInsSorted = [];
  int chronyIndex = 0;
  int highRollerIndex = 0;
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
    if (!loungeSumSet) {
      if (loungeHistory.length < N - 1) {
        loungeSum = loungeHistory.fold(
            0, (int previousValue, int element) => previousValue + element);
        loungeSumCount = loungeHistory.length;
      } else {
        int count = 0;
        for (; count < N - 1; count++) {
          loungeSum += loungeHistory[loungeHistoryIndex];
          loungeHistoryIndex--;
          loungeHistoryIndex %= loungeHistory.length;
        }
        tailLounge = loungeHistory[(loungeHistoryIndex + 1) % loungeHistory.length];
      }

      loungeSumSet = true;
    }

    // update loungeSum
    if (loungeSumCount == N) {
      loungeSum -= tailLounge;
      loungeSumCount--;
    }
    int loungeSumChrony = loungeSum + 0;
    int loungeSumHighroller = loungeSum + 1;
    loungeSumCount++;
    
    // calculate tailLounge
    if (bidInsSorted.length < loungeHistory.length) {
      tailLounge = 
    }


    double ifChronyRatio = 1 - loungeSumChrony / loungeSumCount;
    double ifHighrollerRatio = 1 - loungeSumHighroller / loungeSumCount;
    double ifChronyError = (ifChronyRatio - targetChronyRatio).abs();
    double ifHighrollerError = (ifHighrollerRatio - targetChronyRatio).abs();
    if (ifChronyError <= ifHighrollerError) {
      // choose chrony
      bidInsSorted.add(nextChrony);

      // next
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

      // next
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
