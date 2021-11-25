import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:app_2i2i/services/logging.dart';

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
class Bid extends Equatable {
  Bid({
    required this.id,
    required this.status,
    required this.B,
    required this.speed,
    required this.net,
  });

  final String id;
  final String status;
  final String B;
  final Speed speed;
  final AlgorandNet net;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory Bid.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('Bid.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final String status = data['status'];
    final String B = data['B'];
    final Speed speed = Speed.fromMap(data['speed']);
    final AlgorandNet net = AlgorandNet.values
        .firstWhere((e) => e.toString() == data['net']);

    return Bid(
      id: documentId,
      status: status,
      B: B,
      speed: speed,
      net: net,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'B': B,
      'speed': speed.toMap(),
      'net': net.toString(),
    };
  }
}

@immutable
class BidPrivate {
  BidPrivate({
    required this.A,
    required this.B,
    required this.addrA,
    required this.budget,
  });

  final String A;
  final String B;
  final String? addrA;
  final int budget;

  factory BidPrivate.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('BidPrivate.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final String A = data['A'];
    final String B = data['B'];
    final String? addrA = data['addrA'];
    final int budget = data['budget'];

    return BidPrivate(
      A: A,
      B: B,
      addrA: addrA,
      budget: budget,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'A': A,
      'B': B,
      'addrA': addrA,
      'budget': budget,
    };
  }
}