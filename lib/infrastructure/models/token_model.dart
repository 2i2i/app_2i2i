import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  String? operatingSystem;

  String? operatingSystemVersion;
  String? value;

  TokenModel({required this.value});

  TokenModel.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    operatingSystemVersion = json['operatingSystemVersion'];
    operatingSystem = json['operatingSystem'];
  }

  Map<String, dynamic> toJson() {
    return {
      'operatingSystem': operatingSystem ?? Platform.operatingSystem,
      'operatingSystemVersion': operatingSystemVersion ?? Platform.operatingSystemVersion,
      'value': value,
      'ts': FieldValue.serverTimestamp(),
    };
  }
}
