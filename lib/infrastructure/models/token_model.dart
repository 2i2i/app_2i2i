import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  String operatingSystem;
  String value;

  TokenModel({required this.operatingSystem, required this.value});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final operatingSystemVersion = json['operatingSystemVersion'];
    final operatingSystem = json['operatingSystem'];

    return TokenModel(operatingSystem: operatingSystem, value: value);
  }

  Map<String, dynamic> toJson() {
    return {
      'operatingSystem': operatingSystem,
      'value': value,
      'ts': FieldValue.serverTimestamp(),
    };
  }
}
