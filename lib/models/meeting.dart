import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:app_2i2i/services/logging.dart';

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
    required this.lockTxId,
    required this.unlockTxId,
    required this.addrA,
    required this.addrB,
    required this.status,
    required this.currentRoom,
  });

  final String id;
  final String A;
  final String B;
  final Speed speed;
  final int budget;
  final AlgorandNet net;

  // null in free call
  final String? lockTxId;
  final String? unlockTxId;
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
    final int budget = data['budget'];
    final AlgorandNet net =
        AlgorandNet.values.firstWhere((e) => e.toString() == data['net']);
    final String? lockTxId = data['lockTxId'];
    final String? unlockTxId = data['unlockTxId'];
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
      lockTxId: lockTxId,
      unlockTxId: unlockTxId,
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
      'lockTxId': lockTxId,
      'unlockTxId': unlockTxId,
      'addrA': addrA,
      'addrB': addrB,
      'status': status,
      'currentRoom': currentRoom,
    };
  }
}
