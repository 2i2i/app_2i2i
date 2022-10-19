import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

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
    required this.energy,
    required this.comment,
    required this.FX,
  });

  final String id;
  final String B;
  final Quantity speed;
  final AlgorandNet net;
  final String? addrA;
  final Map<String, String> txns;
  final bool active;
  final int energy;
  final String? comment;
  final bool isLoading = false;
  final double FX;

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
    final AlgorandNet net = AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);

    final Map<String, String> txns = {};
    for (final String k in data['txns'].keys) {
      txns[k] = data['txns'][k] as String;
    }

    final int energy = data['energy'];
    final double FX = double.parse(data['FX'].toString());

    String? comment = data['comment'];

    return BidOut(
      active: active,
      addrA: addrA,
      id: documentId,
      B: B,
      speed: speed,
      net: net,
      txns: txns,
      energy: energy,
      comment: comment,
      FX: FX,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'B': B,
      'speed': speed.toMap(),
      'net': net.toStringEnum(),
      'addrA': addrA,
      'active': active,
      'txns': txns,
      'energy': energy,
      'comment': comment,
      'FX': FX,
    };
  }
}

@immutable
class BidIn extends Equatable {
  BidIn({
    required this.public,
    this.private,
    this.user,
  });

  final BidInPublic public;
  final BidInPrivate? private;
  final UserModel? user;

  @override
  List<Object> get props => [public.id];

  @override
  bool get stringify => true;

  static List<BidIn> createList(List<BidInPublic> publics, List<BidInPrivate> privates) {
    if (publics.length != privates.length) {
      return [];
      // throw Exception('BidIn createList publics.length (${publics.length}) != privates.length (${privates.length})');
    }

    List<BidIn> bidIns = [];
    for (int i = 0; i < publics.length; i++) {
      final bidInPublic = publics[i];
      final bidInPrivate = privates.firstWhere((element) => element.id == bidInPublic.id);
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
    required this.energy,
    required this.FX,
  });

  final bool active;
  final String id;
  final Quantity speed;
  final AlgorandNet net;
  final DateTime ts;
  final Rule rule;
  final int energy;
  final double FX;

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
    final AlgorandNet net = AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);
    final DateTime ts = data['ts'].toDate();
    final Rule rule = Rule.fromMap(data['rule']);
    int energy = data['energy'];
    final double FX = double.parse(data['FX'].toString());

    return BidInPublic(
      id: documentId,
      active: active,
      speed: speed,
      net: net,
      ts: ts,
      rule: rule,
      energy: energy,
      FX: FX,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.toMap(),
      'net': net.toStringEnum(),
      'active': active,
      'ts': FieldValue.serverTimestamp(),
      'rule': rule.toMap(),
      'energy': energy,
      'FX': FX,
    };
  }

  Future<int> estMaxDuration(BidInPrivate bidInPrivate, AccountService accountService) async {
    if (bidInPrivate.addrA == null) return rule.maxMeetingDuration;
    final balance = await accountService.getBalance(address: bidInPrivate.addrA!, assetId: speed.assetId, net: net);
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
    required this.txns,
  });

  final String id;
  final bool active;
  final String A;
  final String? addrA;
  final String? comment;
  final Map<String, String> txns;

  factory BidInPrivate.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidInPrivate.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final Map<String, String> txns = {};
    for (final String k in data['txns'].keys) {
      txns[k] = data['txns'][k] as String;
    }

    String A = data['A'];
    String? addrA = data['addrA'];
    String? comment = data['comment'];
    bool active = data['active'];

    return BidInPrivate(
      id: documentId,
      txns: txns,
      active: active,
      A: A,
      addrA: addrA,
      comment: comment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'active': active,
      'txns': txns,
      'A': A,
      'addrA': addrA,
      'comment': comment,
    };
  }
}
