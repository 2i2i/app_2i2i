import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Speed {
  const Speed({required this.num, required this.assetId});
  final int num;
  final int assetId;
  factory Speed.fromMap(Map<String, dynamic> data) {
    final int num = data['num'];
    final int assetId = data['assetId'];
    return Speed(num: num, assetId: assetId);
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
  });

  final String id;
  final String B;
  final Speed speed;
  final AlgorandNet net;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory BidOut.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidOut.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final String B = data['B'];
    final Speed speed = Speed.fromMap(data['speed']);
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toString() == data['net']);

    return BidOut(
      id: documentId,
      B: B,
      speed: speed,
      net: net,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'B': B,
      'speed': speed.toMap(),
      'net': net.toString(),
      'active': true, // TODO should support false as well
    };
  }
}

@immutable
class BidIn extends Equatable {
  BidIn({
    required this.id,
    required this.speed,
    required this.net,
  });

  final String id;
  final Speed speed;
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

    final Speed speed = Speed.fromMap(data['speed']);
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toString() == data['net']);

    return BidIn(
      id: documentId,
      speed: speed,
      net: net,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speed': speed.toMap(),
      'net': net.toString(),
      'active': true, // TODO should support false as well
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
    this.addrA,
    this.comment,
  });

  final String A;
  final String? addrA;
  final String? comment;

  factory BidInPrivate.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidInPrivate.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    String A = data['A'];
    String? addrA = data['addrA'];
    String? comment = data['comment'];
    return BidInPrivate(
      A: A,
      addrA: addrA,
      comment: comment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'A': A,
      'addrA': addrA,
      'comment': comment,
    };
  }
}
