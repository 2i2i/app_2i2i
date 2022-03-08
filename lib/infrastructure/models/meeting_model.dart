import 'dart:math';

import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_database.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../data_access_layer/repository/algorand_service.dart';
import '../data_access_layer/services/logging.dart';

enum MeetingStatus {
  ACCEPTED_B, // B accepts bid
  // check that enough time passed
  // currently, 3 timers: 30s after INIT / 60s after TXN_CREATED / MAX_DURATION after A/B_RECEIVED_REMOTE
  ACCEPTED_A, // A accepts meeting after B accepts bid
  ROOM_CREATED, // rtc room created
  RECEIVED_REMOTE_A, // A received remote stream of B
  RECEIVED_REMOTE_B, // B received remote stream of A
  CALL_STARTED, // REMOTE_A_RECEIVED && REMOTE_B_RECEIVED
  END_TIMER_RINGING_PAGE,
  END_TIMER_CALL_PAGE,
  END_A, // A hangs up
  END_B, // B hangs up
  END_DISCONNECT, // disconnected
}

// ACCEPTED_B -> END_TIMER_RINGING_PAGE
// ACCEPTED_B -> ACCEPTED_A -> ROOM_CREATED -> END_A/B
// ACCEPTED_B -> ACCEPTED_A -> ROOM_CREATED -> RECEIVED_REMOTE_A/B -> END_A/B
// ACCEPTED_B -> ACCEPTED_A -> ROOM_CREATED -> RECEIVED_REMOTE_A/B -> RECEIVED_REMOTE_B/A -> END_A/B
// ACCEPTED_B -> ACCEPTED_A -> ROOM_CREATED -> RECEIVED_REMOTE_A/B -> RECEIVED_REMOTE_B/A -> CALL_STARTED -> END_A/B
// ACCEPTED_B -> ACCEPTED_A -> ROOM_CREATED -> RECEIVED_REMOTE_A/B -> RECEIVED_REMOTE_B/A -> CALL_STARTED -> END_TIMER_CALL_PAGE
// always possible to get END_DISCONNECT
extension ParseToString on MeetingStatus {
  String toStringEnum() {
    return this.toString().split('.').last;
  }
}

@immutable
class MeetingStatusWithTS {
  const MeetingStatusWithTS({required this.value, required this.ts});
  final MeetingStatus value;
  final DateTime ts;

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
    required this.ts,
  });

  final String id;
  final String B;
  final String name;
  final int duration;
  final Quantity speed;
  final DateTime ts;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory TopMeeting.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('TopMeeting.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final id = documentId;
    final B = data['B'] as String;
    final name = data['name'] as String;
    final duration = data['duration'] as int;
    final speed = Quantity.fromMap(data['speed']);
    final DateTime ts = data['ts'].toDate();

    return TopMeeting(
        id: id, B: B, name: name, duration: duration, speed: speed, ts: ts);
  }
}

class MeetingChanger {
  MeetingChanger(this.database);

  final FirestoreDatabase database;

  Future endMeeting(Meeting meeting, MeetingStatus status) async {
    log(J + 'endMeeting - status=$status');
    final now = FieldValue.serverTimestamp();
    final Map<String, dynamic> data = {
      'status': status.toStringEnum(),
      'statusHistory': FieldValue.arrayUnion([
        {'value': status.toStringEnum(), 'ts': DateTime.now().toUtc()}
      ]),
      'active': false,
      'end': now,
    };
    return database.meetingEndUnlockUser(meeting, data);
  }

  Future normalAdvanceMeeting(String meetingId, MeetingStatus status) async {
    log(F +
        'normalAdvanceMeeting - meetingId=$meetingId - status=${status.toStringEnum()}');
    final now = DateTime.now().toUtc();
    final statusString = status.toStringEnum();
    final Map<String, dynamic> data = {
      'status': statusString,
      'statusHistory': FieldValue.arrayUnion([
        {'value': statusString, 'ts': now}
      ]),
    };
    return database.updateMeeting(meetingId, data);
  }

  Future acceptMeeting(String meetingId) =>
      normalAdvanceMeeting(meetingId, MeetingStatus.ACCEPTED_A);

  Future roomCreatedMeeting(String meetingId, String room) {
    final now = DateTime.now().toUtc();
    final statusString = MeetingStatus.ROOM_CREATED.toStringEnum();
    final Map<String, dynamic> data = {
      'status': statusString,
      'statusHistory': FieldValue.arrayUnion([
        {'value': statusString, 'ts': now}
      ]),
      'room': room,
    };
    return database.updateMeeting(meetingId, data);
  }

  Future remoteReceivedByAMeeting(String meetingId) =>
      normalAdvanceMeeting(meetingId, MeetingStatus.RECEIVED_REMOTE_A);
  Future remoteReceivedByBMeeting(String meetingId) =>
      normalAdvanceMeeting(meetingId, MeetingStatus.RECEIVED_REMOTE_B);
}

@immutable
class Meeting extends Equatable {
  Meeting({
    required this.id,
    required this.active,
    required this.settled,
    required this.A,
    required this.B,
    required this.addrA,
    required this.addrB,
    required this.energy,
    required this.start,
    required this.end,
    required this.duration,
    required this.rule,
    required this.txns,
    required this.status,
    required this.statusHistory,
    required this.net,
    required this.speed,
    required this.room,
    required this.coinFlowsA,
    required this.coinFlowsB,
    required this.lounge,
  });

  final String id;

  final bool active; // status is not END_*
  final bool settled; // after END

  final String A;
  final String B;
  final String? addrA; // set if 0 < speed
  final String? addrB; // set if 0 < speed

  final Map<String, int?> energy; // MAX = A + CREATOR + B

  final DateTime? start; // MeetingStatus.CALL_STARTED ts
  final DateTime? end; // MeetingStatus.END_* ts
  final int? duration; // realised duration of the call

  final Map<String, String> txns;

  final MeetingStatus status;
  final List<MeetingStatusWithTS> statusHistory;

  final AlgorandNet net;
  final Quantity speed;
  final String? room;

  final List<Quantity> coinFlowsA;
  final List<Quantity> coinFlowsB;

  final Lounge lounge;

  final Rule rule;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  bool amA(String uid) => uid == A;
  bool amB(String uid) => uid == B;
  String peerId(String uid) => uid == A ? B : A;

  int maxDuration() {
    if (speed.num == 0) return rule.maxMeetingDuration;
    final fundedMaxDuration = (energy['MAX']! / speed.num).round();
    return min(rule.maxMeetingDuration, fundedMaxDuration);
  }

  factory Meeting.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('Meeting.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final bool active = data['active'] as bool;
    final bool settled = data['settled'] as bool;

    final String A = data['A'];
    final String B = data['B'];
    final String? addrA = data['addrA'];
    final String? addrB = data['addrB'];

    final Map<String, int?> energy = {};
    for (final String k in data['energy'].keys) {
      energy[k] = data['energy'][k] as int?;
    }

    final DateTime? start = data['start']?.toDate();
    final DateTime? end = data['end']?.toDate();
    final int? duration = data['duration'];

    final Map<String, String> txns = {};
    for (final String k in data['txns'].keys) {
      txns[k] = data['txns'][k] as String;
    }

    final MeetingStatus status = MeetingStatus.values
        .firstWhere((e) => e.toStringEnum() == data['status']);
    final List<MeetingStatusWithTS> statusHistory =
        List<MeetingStatusWithTS>.from(data['statusHistory'].map((item) {
      final value = MeetingStatus.values
          .firstWhere((e) => e.toStringEnum() == item['value']);
      final DateTime ts = item['ts'].toDate();
      return MeetingStatusWithTS(value: value, ts: ts);
    }));

    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toStringEnum() == data['net']);
    final Quantity speed = Quantity.fromMap(data['speed']);
    final String? room = data['room'];

    final List<Quantity> coinFlowsA = List<Quantity>.from(
        data['coinFlowsA'].map((item) => Quantity.fromMap(data['coinFlowsA'])));
    final List<Quantity> coinFlowsB = List<Quantity>.from(
        data['coinFlowsB'].map((item) => Quantity.fromMap(data['coinFlowsB'])));

    final Lounge lounge =
        Lounge.values.firstWhere((e) => e.toStringEnum() == data['lounge']);

    final Rule rule = Rule.fromMap(data['rule']);

    return Meeting(
      id: documentId,
      lounge: lounge,
      active: active,
      settled: settled,
      A: A,
      B: B,
      addrA: addrA,
      addrB: addrB,
      energy: energy,
      start: start,
      end: end,
      duration: duration,
      txns: txns,
      status: status,
      statusHistory: statusHistory,
      net: net,
      speed: speed,
      room: room,
      coinFlowsA: coinFlowsA,
      coinFlowsB: coinFlowsB,
      rule: rule,
    );
  }

  // used by acceptBid, as B
  factory Meeting.newMeeting({
    required String id,
    required String B,
    required String? addrB,
    required BidIn bidIn,
  }) {
    return Meeting(
      id: id,
      lounge: bidIn.public.speed.num == bidIn.public.rule.minSpeed
          ? Lounge.chrony
          : Lounge.highroller,
      active: true,
      settled: false,
      A: bidIn.private!.A,
      B: B,
      addrA: bidIn.private!.addrA,
      addrB: addrB,
      energy: {
        'MAX': bidIn.public.energy,
        'A': null,
        'CREATOR': null,
        'B': null,
      },
      start: null,
      end: null,
      duration: null,
      txns: {},
      status: MeetingStatus.ACCEPTED_B,
      statusHistory: [
        MeetingStatusWithTS(
            value: MeetingStatus.ACCEPTED_B, ts: DateTime.now().toUtc())
      ],
      net: bidIn.public.net,
      speed: bidIn.public.speed,
      room: null,
      coinFlowsA: [],
      coinFlowsB: [],
      rule: bidIn.public.rule,
    );
  }

  Map<String, dynamic> toMap() {
    log('Meeting - toMap - net=$net');
    return {
      'active': active,
      'settled': settled,
      'A': A,
      'B': B,
      'addrA': addrA,
      'addrB': addrB,
      'energy': energy,
      'start': start,
      'end': end,
      'duration': duration,
      'txns': txns,
      'status': status.toStringEnum(),
      'statusHistory': statusHistory.map((s) => s.toMap()).toList(),
      'net': net.toStringEnum(),
      'speed': speed.toMap(),
      'room': room,
      'coinFlowsA': coinFlowsA,
      'coinFlowsB': coinFlowsB,
      'lounge': lounge.toStringEnum(),
      'rule': rule.toMap(),
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

    final double rating = double.parse(data['rating'].toString());
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
