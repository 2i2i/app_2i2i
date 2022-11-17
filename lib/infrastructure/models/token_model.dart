import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TokenModel {
  String? operatingSystem;
  String? operatingSystemVersion;
  String value;
  Timestamp ts;

  TokenModel({required this.value, required this.ts, this.operatingSystem, this.operatingSystemVersion});

  TokenModel.fromJson(Map<String, dynamic> json)
      : this.value = '',
        this.ts = Timestamp.now() {
    if (json['operatingSystemVersion'] is String) {
      operatingSystemVersion = json['operatingSystemVersion'];
    }
    if (json['operatingSystem'] is String) {
      operatingSystem = json['operatingSystem'];
    }
    if (json['value'] is String) {
      value = json['value'];
    }
    if (json['ts'] is String) {
      DateTime? date = json['ts'].toString().toDate();
      if (date != null) {
        ts = Timestamp.fromDate(date);
      }
    }
    if (json['ts'] is Timestamp) {
      ts = json['ts'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'operatingSystem': operatingSystem,
      'operatingSystemVersion': operatingSystemVersion,
      'value': value,
      'ts': ts,
    };
  }
}
