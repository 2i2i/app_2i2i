import 'package:app_2i2i/infrastructure/commons/utils.dart';
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
    final ts = (json['ts'] as Object?).toDateValue();
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
