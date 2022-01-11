import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_database.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_access_layer/repository/algorand_service.dart';
import '../data_access_layer/services/logging.dart';

enum MeetingStatus {
  INIT, // B accepts bid
  // check that enough time passed
  // currently, 3 timers: 30s after INIT / 60s after TXN_CREATED / MAX_DURATION after A/B_RECEIVED_REMOTE
  ACCEPTED, // A accepts meeting after B accepts bid
  TXN_CREATED, // A created txn
  TXN_SIGNED, // A created txn
  TXN_SENT, // A confirmed txn
  TXN_CONFIRMED, // algorand confirmed txn
  ROOM_CREATED, // rtc room created
  A_RECEIVED_REMOTE, // A received remote stream of B
  B_RECEIVED_REMOTE, // B received remote stream of A
  CALL_STARTED, // REMOTE_A_RECEIVED && REMOTE_B_RECEIVED
  END_TXN_FAILED, // txn failed
  END_TIMER,
  END_A, // A hangs up
  END_B, // B hangs up
  END_DISCONNECT, // disconnected
}

// INIT -> END_TIMER
// INIT -> END_A
// INIT -> END_B
// INIT -> ACCEPTED -> TXN_CREATED -> END_TIMER
// INIT -> ACCEPTED -> TXN_CREATED -> TXN_SENT -> END_TXN_FAILED
// INIT -> ACCEPTED -> TXN_CREATED -> TXN_SIGNED -> TXN_SENT -> TXN_CONFIRMED -> ROOM_CREATED -> A_RECEIVED_REMOTE -> B_RECEIVED_REMOTE -> CALL_STARTED -> END_A
// INIT -> ACCEPTED -> TXN_CREATED -> TXN_SIGNED -> TXN_SENT -> TXN_CONFIRMED -> ROOM_CREATED -> A_RECEIVED_REMOTE -> B_RECEIVED_REMOTE -> CALL_STARTED-> END_B
// INIT -> ACCEPTED -> TXN_CREATED -> TXN_SIGNED -> TXN_SENT -> TXN_CONFIRMED -> ROOM_CREATED -> A_RECEIVED_REMOTE -> B_RECEIVED_REMOTE -> CALL_STARTED -> END_TIMER
// always possible to get END_DISCONNECT_*
extension ParseToString on MeetingStatus {
  String toStringEnum() {
    return this.toString().split('.').last;
  }
}

@immutable
class MeetingStatusWithTS {
  const MeetingStatusWithTS({required this.value, required this.ts});
  final MeetingStatus value;
  final int ts;

  Map<String, dynamic> toMap() {
    return {
      'value': value.toStringEnum(),
      'ts': ts,
    };
  }

  @override
  String toString() {
    return 'MeetingStatus{value: $value, ts: $ts}';
  }
}

@immutable
class TopMeeting extends Equatable {
  TopMeeting({
    required this.id,
    required this.B,
    required this.name,
    required this.duration,
    required this.speed,
  });

  final String id;
  final String B;
  final String name;
  final int duration;
  final Quantity speed;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory TopMeeting.fromMap(Map<String, dynamic> data) {
    final id = data['id'] as String;
    final B = data['B'] as String;
    final name = data['name'] as String;
    final duration = data['duration'] as int;
    final speed = Quantity.fromMap(data['speed']);
    return TopMeeting(
        id: id, B: B, name: name, duration: duration, speed: speed);
  }
}

class MeetingChanger {
  MeetingChanger(this.database);

  final FirestoreDatabase database;

  Future endMeeting(Meeting meeting, MeetingStatus status) async {
    final now = FieldValue.serverTimestamp();
    final Map<String, dynamic> data = {
      'status': status.toStringEnum(),
      'statusHistory': FieldValue.arrayUnion([{'value': status, 'ts': now}]),
      'isActive': false,
      'end': now,
    };
    return database.updateMeeting(meeting.id, data);
  }

  Future normalAdvanceMeeting(String meetingId, MeetingStatus status) async {
    final now = FieldValue.serverTimestamp();
    final statusString = status.toStringEnum();
    final Map<String, dynamic> data = {
      'status': statusString,
      'statusHistory': FieldValue.arrayUnion([{'value': statusString, 'ts': now}]),
    };
    return database.updateMeeting(meetingId, data);
  }
  Future acceptMeeting(String meetingId) => normalAdvanceMeeting(meetingId, MeetingStatus.ACCEPTED);
  Future acceptFreeCallMeeting(String meetingId) async {
    final now = FieldValue.serverTimestamp();
    final Map<String, dynamic> data = {
      'status': MeetingStatus.TXN_CONFIRMED.toStringEnum(),
      'statusHistory': FieldValue.arrayUnion([
        {'value': MeetingStatus.ACCEPTED.toStringEnum(), 'ts': now},
        {'value': MeetingStatus.TXN_CREATED.toStringEnum(), 'ts': now},
        {'value': MeetingStatus.TXN_SIGNED.toStringEnum(), 'ts': now},
        {'value': MeetingStatus.TXN_SENT.toStringEnum(), 'ts': now},
        {'value': MeetingStatus.TXN_CONFIRMED.toStringEnum(), 'ts': now},
      ]),
    };
    return database.updateMeeting(meetingId, data);
  }
  Future txnCreatedMeeting(String meetingId) => normalAdvanceMeeting(meetingId, MeetingStatus.TXN_CREATED);
  Future txnSignedMeeting(String meetingId) => normalAdvanceMeeting(meetingId, MeetingStatus.TXN_SIGNED);
  Future txnSentMeeting(String meetingId, MeetingTxns txns) {
    final now = FieldValue.serverTimestamp();
    final statusString = MeetingStatus.TXN_SENT.toStringEnum();
    final Map<String, dynamic> data = {
      'status': statusString,
      'statusHistory': FieldValue.arrayUnion([{'value': statusString, 'ts': now}]),
      'txns': txns.toMap(),
    };
    return database.updateMeeting(meetingId, data);
  }
  Future txnConfirmedMeeting(String meetingId, int budget) {
    final now = FieldValue.serverTimestamp();
    final statusString = MeetingStatus.TXN_CONFIRMED.toStringEnum();
    final Map<String, dynamic> data = {
      'status': statusString,
      'statusHistory': FieldValue.arrayUnion([{'value': statusString, 'ts': now}]),
      'budget': budget,
    };
    return database.updateMeeting(meetingId, data);
  }
  Future roomCreatedMeeting(String meetingId, String room) {
    final now = FieldValue.serverTimestamp();
    final statusString = MeetingStatus.ROOM_CREATED.toStringEnum();
    final Map<String, dynamic> data = {
      'status': statusString,
      'statusHistory': FieldValue.arrayUnion([{'value': statusString, 'ts': now}]),
      'room': room,
    };
    return database.updateMeeting(meetingId, data);
  }
  Future remoteReceivedByAMeeting(String meetingId) => normalAdvanceMeeting(meetingId, MeetingStatus.A_RECEIVED_REMOTE);
  Future remoteReceivedByBMeeting(String meetingId) => normalAdvanceMeeting(meetingId, MeetingStatus.B_RECEIVED_REMOTE);
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
    required this.start,
    required this.end,
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
  final int? start; // MeetingStatus.CALL_STARTED ts
  final int? end; // MeetingStatus.END_* ts
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
    final int? start = data['start'];
    final int? end = data['end'];
    final int? duration = data['duration'];

    final MeetingTxns txns = MeetingTxns.fromMap(data['txns']);

    final MeetingStatus status = MeetingStatus.values
        .firstWhere((e) => e.toStringEnum() == data['status']);
    final List<MeetingStatusWithTS> statusHistory =
        List<MeetingStatusWithTS>.from(data['statusHistory'].map((item) {
      final value = MeetingStatus.values
          .firstWhere((e) => e.toStringEnum() == item['value']);
      final ts = item['ts'] as int;
      return MeetingStatusWithTS(value: value, ts: ts);
    }));

    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);
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
      start: start,
      end: end,
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
      'start': start,
      'end': end,
      'duration': duration,
      'txns': txns.toMap(),
      'status': status.toStringEnum(),
      'statusHistory': statusHistory,
      'net': net.toStringEnum(),
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

  RatingModel({required this.rating, this.comment});

  factory RatingModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('RatingModel.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final double rating = data['rating'];
    final String? comment = data['comment'];

    return RatingModel(
      rating: rating,
      comment: comment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'comment': comment,
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
