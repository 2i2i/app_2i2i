import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  String operatingSystem;
  String operatingSystemVersion;
  String value;

  TokenModel({required this.operatingSystem, required this.operatingSystemVersion, required this.value});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final operatingSystemVersion = json['operatingSystemVersion'];
    final operatingSystem = json['operatingSystem'];

    return TokenModel(operatingSystem: operatingSystem, operatingSystemVersion: operatingSystemVersion, value: value);
  }

  Map<String, dynamic> toJson() {
    return {
      'operatingSystem': operatingSystem,
      'operatingSystemVersion': operatingSystemVersion,
      'value': value,
      'ts': FieldValue.serverTimestamp(),
    };
  }
}
