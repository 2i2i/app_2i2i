import 'package:app_2i2i/infrastructure/models/user_model.dart';
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
    required this.txId,
    required this.addrA,
    required this.active,
    required this.budget,
  });

  final String id;
  final String B;
  final Quantity speed;
  final AlgorandNet net;
  final String? addrA;
  final String? txId;
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
    final txId = data['txId'] as String?;
    final int budget = data['budget'];

    return BidOut(
      active: active,
      addrA: addrA,
      id: documentId,
      B: B,
      speed: speed,
      net: net,
      txId: txId,
      budget: budget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addrA': addrA,
      'txId': txId,
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
    this.user,
  });

  final BidInPublic public;
  final BidInPrivate? private;
  final UserModel? user;

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
      BidIn bidIn = BidIn(public: publics[i], private: privates[i]);
      if (bidIn.public.id != bidIn.private!.id)
        throw Exception(
            'BidIn createList bidIn.public.id (${bidIn.public.id}) != bidIn.private!.id (${bidIn.private!.id})');
      bidIns.add(bidIn);
    }
    final futures = [];
    for (int i = 0; i < bidIns.length; i++) {
      final uid = bidIns[i].private!.A;
      
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
  });

  final bool active;
  final String id;
  final Quantity speed;
  final AlgorandNet net;
  final DateTime ts;
  final HangOutRule rule;

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

    return BidInPublic(
      id: documentId,
      active: active,
      speed: speed,
      net: net,
      ts: ts,
      rule: rule,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.toMap(),
      'net': net.toStringEnum(),
      'active': active,
      'ts': ts,
      'rule': rule,
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
    required this.A,
    required this.addrA,
    required this.comment,
    required this.txId,
    required this.budget,
  });

  final String id;
  final String A;
  final String? addrA;
  final String? comment;
  final String? txId;
  final int budget;

  factory BidInPrivate.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidInPrivate.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    String? txId = data['txId'];
    String A = data['A'];
    String? addrA = data['addrA'];
    String? comment = data['comment'];
    int budget = data['budget'];

    return BidInPrivate(
      id: documentId,
      txId: txId,
      A: A,
      addrA: addrA,
      comment: comment,
      budget: budget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'txId': txId,
      'A': A,
      'addrA': addrA,
      'comment': comment,
      'budget': budget,
    };
  }
}
