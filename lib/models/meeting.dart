import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum MeetingStatus {
  INIT,
  // check that enough time passed
  // currently, 3 timers: 30s after INIT / 60s after TXN_CREATED / MAX_DURATION after REMOTE_A/B_RECEIVED
  END_TIMER,
  END_A, // A hangs up
  END_B, // B hangs up
  ACCEPT, // A accepts meeting after B accepts bid
  TXN_CREATED, // A created txn
  TXN_SENT, // A confirmed txn
  END_TXN_FAILED, // txn failed
  TXN_CONFIRMED, // algorand confirmed txn
  ROOM_CREATED, // rtc room created
  REMOTE_A_RECEIVED, // A received remote stream of B
  REMOTE_B_RECEIVED, // B received remote stream of A
  CALL_STARTED, // REMOTE_A_RECEIVED && REMOTE_B_RECEIVED
  END_DISCONNECT_A, // A disconnected
  END_DISCONNECT_B, // B disconnected
  END_DISCONNECT_AB, // both disconnected
}
// INIT -> END_TIMER
// INIT -> END_A
// INIT -> END_B
// INIT -> ACCEPT -> TXN_CREATED -> END_TIMER
// INIT -> ACCEPT -> TXN_CREATED -> TXN_SENT -> END_TXN_FAILED
// INIT -> ACCEPT -> TXN_CREATED -> TXN_SENT -> TXN_CONFIRMED -> ROOM_CREATED -> REMOTE_A_RECEIVED -> REMOTE_B_RECEIVED -> CALL_STARTED -> END_A
// INIT -> ACCEPT -> TXN_CREATED -> TXN_SENT -> TXN_CONFIRMED -> ROOM_CREATED -> REMOTE_A_RECEIVED -> REMOTE_B_RECEIVED -> CALL_STARTED-> END_B
// INIT -> ACCEPT -> TXN_CREATED -> TXN_SENT -> TXN_CONFIRMED -> ROOM_CREATED -> REMOTE_A_RECEIVED -> REMOTE_B_RECEIVED -> CALL_STARTED -> END_TIMER
// always possible to get END_DISCONNECT_*

@immutable
class MeetingStatusWithTS {
  const MeetingStatusWithTS({required this.value, required this.ts});
  final MeetingStatus value;
  final int ts;

  @override
  String toString() {
    return 'MeetingStatus{value: $value, ts: $ts}';
  }
}

@immutable
class Meeting extends Equatable {
  Meeting({
    required this.id,
    required this.isActive,
    required this.isSettled,
    required this.A,
    required this.B,
    required this.addrA,
    required this.addrB,
    required this.budget,
    required this.duration,
    required this.txns,
    required this.status,
    required this.statusHistory,
    required this.net,
    required this.speed,
    required this.bid,
    required this.room,
    required this.coinFlowsA,
    required this.coinFlowsB,
  });

  final String id;

  final bool isActive; // status is not END_*
  final bool isSettled; // after END

  final String A;
  final String B;
  final String? addrA; // set if 0 < speed
  final String? addrB; // set if 0 < speed

  final int? budget; // [coins]; 0 for speed == 0
  final int? duration; // realised duration of the call

  // null in free call
  final MeetingTxns txns;

  final MeetingStatus status;
  final List<MeetingStatusWithTS> statusHistory;

  final AlgorandNet net;
  final Quantity speed;
  final String bid;
  final String? room;

  final List<Quantity> coinFlowsA;
  final List<Quantity> coinFlowsB;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  bool amA(String uid) => uid == A;
  bool amB(String uid) => uid == B;
  String peerId(String uid) => uid == A ? B : A;

  int? maxDuration() {
    if (budget == null) return null;
    return (budget! / speed.num).floor();
  }

  bool isInit() => status == MeetingStatus.INIT;

  int? activeTime() {
    for (final st in statusHistory) {
      if (st.value == MeetingStatus.CALL_STARTED) return st.ts;
    }
    return null;
  }

  factory Meeting.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('Meeting.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final bool isActive = data['isActive'] as bool;
    final bool isSettled = data['isSettled'] as bool;

    final String A = data['A'];
    final String B = data['B'];
    final String? addrA = data['addrA'];
    final String? addrB = data['addrB'];

    final int? budget = data['budget'];
    final int? duration = data['duration'];

    final MeetingTxns txns = MeetingTxns.fromMap(data['txns']);

    final MeetingStatus status = MeetingStatus.values
        .firstWhere((e) => e.toString().endsWith(data['status']));
    final List<MeetingStatusWithTS> statusHistory =
        List<MeetingStatusWithTS>.from(data['statusHistory'].map((item) {
      final value = MeetingStatus.values
          .firstWhere((e) => e.toString().endsWith(item['value']));
      final ts = item['ts'] as int;
      return MeetingStatusWithTS(value: value, ts: ts);
    }));

    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toString() == data['net']);
    final Quantity speed = Quantity.fromMap(data['speed']);
    final String bid = data['bid'];
    final String? room = data['room'];

    final List<Quantity> coinFlowsA = List<Quantity>.from(
        data['coinFlowsA'].map((item) => Quantity.fromMap(data['coinFlowsA'])));
    final List<Quantity> coinFlowsB = List<Quantity>.from(
        data['coinFlowsB'].map((item) => Quantity.fromMap(data['coinFlowsB'])));

    return Meeting(
      id: documentId,
      isActive: isActive,
      isSettled: isSettled,
      A: A,
      B: B,
      addrA: addrA,
      addrB: addrB,
      budget: budget,
      duration: duration,
      txns: txns,
      status: status,
      statusHistory: statusHistory,
      net: net,
      speed: speed,
      bid: bid,
      room: room,
      coinFlowsA: coinFlowsA,
      coinFlowsB: coinFlowsB,
    );
  }

  Map<String, dynamic> toMap() {
    log('Meeting - toMap - net=$net');
    return {
      'isActive': isActive,
      'isSettled': isSettled,
      'A': A,
      'B': B,
      'addrA': addrA,
      'addrB': addrB,
      'budget': budget,
      'duration': duration,
      'txns': txns.toMap(),
      'status': status,
      'statusHistory': statusHistory,
      'net': net.toString(),
      'speed': speed.toMap(),
      'bid': bid,
      'room': room,
      'coinFlowsA': coinFlowsA,
      'coinFlowsB': coinFlowsB,
    };
  }
}

@immutable
class RatingModel {
  final double rating;
  final String? comment;
  final String meeting;

  RatingModel({required this.rating, this.comment, required this.meeting});

  factory RatingModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('RatingModel.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final double rating = data['rating'];
    final String? comment = data['comment'];
    final String meeting = data['meeting'];

    return RatingModel(
      rating: rating,
      comment: comment,
      meeting: meeting,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
      'meeting': meeting,
    };
  }
}

class MeetingTxns {
  MeetingTxns(
      {this.group,
      this.lockALGO,
      this.lockASA,
      this.state,
      this.unlock,
      this.optIn});
  String? group;
  String? lockALGO;
  String? lockASA;
  String? state;
  String? unlock;
  String? optIn;
  factory MeetingTxns.fromMap(Map<String, dynamic> data) {
    final String? group = data['group'];
    final String? lockALGO = data['lockALGO'];
    final String? lockASA = data['lockASA'];
    final String? state = data['state'];
    final String? unlock = data['unlock'];
    final String? optIn = data['optIn'];
    return MeetingTxns(
      group: group,
      lockALGO: lockALGO,
      lockASA: lockASA,
      state: state,
      unlock: unlock,
      optIn: optIn,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'group': group,
      'lockALGO': lockALGO,
      'lockASA': lockASA,
      'state': state,
      'unlock': unlock,
      'optIn': optIn,
    };
  }

  String? lockId({required bool isALGO}) => isALGO ? lockALGO : lockASA;
}
