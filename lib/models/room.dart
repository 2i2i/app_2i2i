import 'package:app_2i2i/services/logging.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meta/meta.dart';

@immutable
class Room extends Equatable {
  Room({
    required this.meetingId,
    required this.offer,
    required this.answer,
  });

  final String meetingId;
  final RTCSessionDescription offer;
  final RTCSessionDescription answer;

  @override
  List<Object> get props => [meetingId];

  @override
  bool get stringify => true;

  factory Room.fromMap(Map<String, dynamic>? data, String meetingId) {
    if (data == null) {
      log('Room.fromMap - data == null');
      throw StateError('missing data for room for meetingId: $meetingId');
    }

    final offer = RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
    final answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);

    return Room(
      meetingId: meetingId,
      offer: offer,
      answer: answer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offer': {'sdp': offer.sdp, 'type': offer.type},
      'answer': {'sdp': answer.sdp, 'type': answer.type},
    };
  }
}