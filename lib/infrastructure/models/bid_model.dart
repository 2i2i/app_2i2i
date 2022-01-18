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
    required this.active,
    required this.id,
    required this.speed,
    required this.net,
  });

  final bool active;
  final String id;
  final Quantity speed;
  final AlgorandNet net;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory BidIn.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidIn.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final bool active = data['active'];
    final Quantity speed = Quantity.fromMap(data['speed']);
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);

    return BidIn(
      id: documentId,
      active: active,
      speed: speed,
      net: net,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.toMap(),
      'net': net.toStringEnum(),
      'active': active,
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
    required this.A,
    required this.addrA,
    required this.comment,
    required this.txId,
    required this.budget,
  });

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
