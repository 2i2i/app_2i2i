import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum MeetingValue {
  INIT,
  LOCK_COINS_STARTED,
  LOCK_COINS_CONFIRMED,
  ACTIVE,
  END_A,
  END_B,
  END_SYSTEM,
  END_BUDGET,
  END_NO_PICKUP,
  SETTLED,
}

@immutable
class MeetingStatus {
  const MeetingStatus({required this.value, required this.ts});
  final MeetingValue value;
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
    required this.A,
    required this.B,
    required this.speed,
    required this.budget,
    required this.net,
    required this.txns,
    required this.addrA,
    required this.addrB,
    required this.status,
    required this.currentRoom,
  });

  final String id;
  final String A;
  final String B;
  final Speed speed;
  final int? budget;
  final AlgorandNet net;

  // null in free call
  final MeetingTxns txns;
  final String? addrA;
  final String? addrB;

  final List<MeetingStatus> status;
  final String? currentRoom;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  String peerId(String uid) => uid == A ? B : A;

  bool isDone() {
    final st = status.last.value;
    return st == MeetingValue.END_A ||
        st == MeetingValue.END_B ||
        st == MeetingValue.END_SYSTEM;
  }

  int? maxDuration() {
    if (budget == null) return null;
    return (budget! / speed.num).floor();
  }

  bool isInit() {
    final st = status.last.value;
    return st == MeetingValue.INIT;
  }

  MeetingValue currentStatus() {
    return status.last.value;
  }

  int? activeTime() {
    for (final st in status) {
      if (st.value == MeetingValue.ACTIVE) return st.ts;
    }
    return null;
  }

  int? initTime() {
    for (final st in status) {
      if (st.value == MeetingValue.INIT) return st.ts;
    }
    return null;
  }

  factory Meeting.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('Meeting.fromMap - data == null');
      throw StateError('missing data for id: $documentId');
    }

    final String A = data['A'];
    final String B = data['B'];
    final Speed speed = Speed.fromMap(data['speed']);
    final int? budget = data['budget'];
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toString() == data['net']);
    final MeetingTxns txns = MeetingTxns.fromMap(data['txns']);
    final String? addrA = data['addrA'];
    final String? addrB = data['addrB'];
    final List<MeetingStatus> status =
        List<MeetingStatus>.from(data['status'].map((item) {
      final value = MeetingValue.values
          .firstWhere((e) => e.toString().endsWith(item['value']));
      final ts = item['ts'] as int;
      return MeetingStatus(value: value, ts: ts);
    }));
    final String? currentRoom = data['currentRoom'];

    return Meeting(
      id: documentId,
      A: A,
      B: B,
      speed: speed,
      budget: budget,
      net: net,
      txns: txns,
      addrA: addrA,
      addrB: addrB,
      status: status,
      currentRoom: currentRoom,
    );
  }

  Map<String, dynamic> toMap() {
    log('Meeting - toMap - net=$net');
    return {
      'A': A,
      'B': B,
      'speed': speed.toMap(),
      'budget': budget,
      'net': net.toString(),
      'txns': txns.toMap(),
      'addrA': addrA,
      'addrB': addrB,
      'status': status,
      'currentRoom': currentRoom,
    };
  }
}

@immutable
class RatingModel {
  double? rating;
  String? comment;
  String? meeting;
  String? userId;

  RatingModel({this.rating, this.comment, this.meeting, this.userId});

  RatingModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('rating') && json['rating'] != null) {
      rating = json['rating'];
    }
    if (json.containsKey('comment') && json['comment'] != null) {
      comment = json['comment'];
    }
    if (json.containsKey('meeting') && json['meeting'] != null) {
      meeting = json['meeting'];
    }
    if (json.containsKey('userId') && json['userId'] != null) {
      userId = json['userId'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['meeting'] = this.meeting;
    data['userId'] = this.userId;
    return data;
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
