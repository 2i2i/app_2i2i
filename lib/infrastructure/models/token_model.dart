import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class TokenModel {
  final String operatingSystem = Platform.operatingSystem;
  final String operatingSystemVersion = Platform.operatingSystemVersion;
  String value;

  TokenModel({required this.value});

  TokenModel.fromJson(Map<String, dynamic> json) : value = json['value'];

  Map<String, dynamic> toJson() {
    return {
      'operatingSystem': operatingSystem,
      'operatingSystemVersion': operatingSystemVersion,
      'value': value,
      'ts': FieldValue.serverTimestamp(),
    };
  }
}
