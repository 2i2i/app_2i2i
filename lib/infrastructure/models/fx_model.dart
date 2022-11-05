import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';

@immutable
class FXModel {
  final int id;
  final DateTime ts;
  final double? value;
  final int decimals;
  final String? name;
  final String? unitname;
  final String? iconUrl;

  FXModel({required this.id, required this.ts, required this.value, required this.decimals, this.name, this.unitname, this.iconUrl});

  FXModel.ALGO()
      : id = 0,
        ts = DateTime.now(),
        value = 1,
        decimals = 6,
        name = 'ALGO',
        unitname = 'ALGO',
        iconUrl = null;

  FXModel.fromJson(Map<String, dynamic> json, int docId)
      : id = docId,
        ts = (json['ts'] as Object).toDate() ?? DateTime.now(),
        value = json.containsKey('value') && json['value'] != null ? double.parse(json['value'].toString()) : null,
        decimals = int.parse(json['decimals'].toString()),
        name = json['name'],
        unitname = json['unitname'],
        iconUrl = json['iconUrl'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ts'] = this.ts;
    data['value'] = this.value;
    data['decimals'] = this.decimals;
    data['name'] = this.name;
    data['unitname'] = this.unitname;
    data['iconUrl'] = this.iconUrl;
    return data;
  }

  String get getName => name ?? (unitname ?? id.toString());
}
