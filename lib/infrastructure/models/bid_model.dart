import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_access_layer/accounts/abstract_account.dart';
import '../data_access_layer/repository/algorand_service.dart';
import '../data_access_layer/services/logging.dart';

@immutable
class Quantity {
  const Quantity({required this.num, required this.assetId});
  final int num;
  final int assetId;
  factory Quantity.fromMap(Map<String, dynamic> data) {
    final int num = data['num'];
    final int assetId = data['assetId'];
    return Quantity(num: num, assetId: assetId);
  }
  Map<String, dynamic> toMap() {
    return {
      'num': num,
      'assetId': assetId,
    };
  }
}

@immutable
class BidOut extends Equatable {
  BidOut({
    required this.id,
    required this.B,
    required this.speed,
    required this.net,
    required this.txns,
    required this.addrA,
    required this.active,
    required this.budget,
  });

  final String id;
  final String B;
  final Quantity speed;
  final AlgorandNet net;
  final String? addrA;
  final Map<String, String> txns;
  final bool active;
  final int budget;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory BidOut.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidOut.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final bool active = data['active'];
    final String? addrA = data['addrA'];
    final String B = data['B'];
    final Quantity speed = Quantity.fromMap(data['speed']);
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);

    final Map<String, String> txns = {};
    for (final String k in data['txns'].keys) {
      txns[k] = data['txns'][k] as String;
    }

    final int budget = data['budget'];

    return BidOut(
      active: active,
      addrA: addrA,
      id: documentId,
      B: B,
      speed: speed,
      net: net,
      txns: txns,
      budget: budget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addrA': addrA,
      'txns': txns,
      'B': B,
      'speed': speed.toMap(),
      'net': net.toStringEnum(),
      'active': active,
      'budget': budget,
    };
  }
}

@immutable
class BidIn extends Equatable {
  BidIn({
    required this.public,
    this.private,
    this.hangout,
  });

  final BidInPublic public;
  final BidInPrivate? private;
  final Hangout? hangout;

  @override
  List<Object> get props => [public.id];

  @override
  bool get stringify => true;

  static List<BidIn> createList(
      List<BidInPublic> publics, List<BidInPrivate> privates) {
    if (publics.length != privates.length)
      throw Exception(
          'BidIn createList publics.length (${publics.length}) != privates.length (${privates.length})');

    List<BidIn> bidIns = [];
    for (int i = 0; i < publics.length; i++) {
      final bidInPublic = publics[i];
      final bidInPrivate =
          privates.firstWhere((element) => element.id == bidInPublic.id);
      BidIn bidIn = BidIn(public: bidInPublic, private: bidInPrivate);
      bidIns.add(bidIn);
    }
    return bidIns;
  }
}

@immutable
class BidInPublic extends Equatable {
  BidInPublic({
    required this.active,
    required this.id,
    required this.speed,
    required this.net,
    required this.ts,
    required this.rule,
    required this.budget,
  });

  final bool active;
  final String id;
  final Quantity speed;
  final AlgorandNet net;
  final DateTime ts;
  final HangOutRule rule;
  final int budget;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory BidInPublic.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidIn.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final bool active = data['active'];
    final Quantity speed = Quantity.fromMap(data['speed']);
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);
    final DateTime ts = data['ts'].toDate();
    final HangOutRule rule = HangOutRule.fromMap(data['rule']);
    int budget = data['budget'];

    return BidInPublic(
      id: documentId,
      active: active,
      speed: speed,
      net: net,
      ts: ts,
      rule: rule,
      budget: budget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.toMap(),
      'net': net.toStringEnum(),
      'active': active,
      'ts': FieldValue.serverTimestamp(),
      'rule': rule.toMap(),
      'budget': budget,
    };
  }

  Future<num> estMaxDuration(
      BidInPrivate bidInPrivate, AccountService accountService) async {
    if (bidInPrivate.addrA == null) return double.infinity;
    final balance = await accountService.getBalance(
        address: bidInPrivate.addrA!, assetId: speed.assetId, net: net);
    return (balance!.amount / speed.num).floor();
  }
}

@immutable
class BidInPrivate {
  BidInPrivate({
    required this.id,
    required this.active,
    required this.A,
    required this.addrA,
    required this.comment,
    required this.txId,
  });

  final String id;
  final bool active;
  final String A;
  final String? addrA;
  final String? comment;
  final String? txId;

  factory BidInPrivate.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidInPrivate.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    String? txId = data['txId'];
    String A = data['A'];
    String? addrA = data['addrA'];
    String? comment = data['comment'];
    bool active = data['active'];

    return BidInPrivate(
      id: documentId,
      txId: txId,
      active: active,
      A: A,
      addrA: addrA,
      comment: comment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'txId': txId,
      'A': A,
      'addrA': addrA,
      'comment': comment,
    };
  }
}
