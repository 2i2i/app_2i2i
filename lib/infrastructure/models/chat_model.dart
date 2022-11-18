import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class ChatModel {
  final DateTime ts;
  final String message;
  final String writerUid;
  final String writerName;

  const ChatModel({required this.ts, required this.message, required this.writerUid, required this.writerName});

  factory ChatModel.fromMap(Map<String, dynamic> json) {
    final ts = toDateValue(json['ts']);
    final message = json['message'];
    final writerUid = json['writerUid'];
    final writerName = json['writerName'];

    return ChatModel(ts: ts!, message: message, writerUid: writerUid, writerName: writerName);
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'ts': FieldValue.serverTimestamp(),
      'writerUid': writerUid,
      'writerName': writerName,
    };
  }
}

DateTime? toDateValue(var value) {
  if (value is String) {
    return DateTime.tryParse(value)?.toLocal();
  } else if (value is num) {
    var n = value.toInt();
    return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
  } else if (value is int) {
    var n = value;
    return DateTime.fromMillisecondsSinceEpoch(n).toLocal();
  } else if (value is Timestamp) {
    return value.toDate().toLocal();
  }
  return null;
}
