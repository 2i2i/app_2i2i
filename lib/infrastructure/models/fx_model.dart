import 'package:flutter/material.dart';

@immutable
class FXModel {
  final int id;
  final int decimals;
  final DateTime? ts;
  final double? value;
  final String? name;
  final String? unitname;
  final String? iconUrl;

  FXModel({required this.id, required this.decimals, this.ts, this.value, this.name, this.unitname, this.iconUrl});

  FXModel.ALGO()
      : id = 0,
        ts = DateTime.fromMicrosecondsSinceEpoch(0),
        value = 1,
        decimals = 6,
        name = 'ALGO',
        unitname = 'ALGO',
        iconUrl = 'https://asa-list.tinyman.org/assets/0/icon.png';

  FXModel.subjective({required this.id})
      : ts = null,
        value = null,
        decimals = 0, // TODO wrong ~ better to get from internet
        name = '-', // TODO wrong ~ better to get from internet
        unitname = '-', // TODO wrong ~ better to get from internet
        iconUrl = 'https://asa-list.tinyman.org/assets/$id/icon.png';

  FXModel.objective(Map<String, dynamic> json, int docId)
      : id = docId,
        ts = json['ts'].toDate(),
        value = double.parse(json['value'].toString()),
        decimals = int.parse(json['decimals'].toString()),
        name = json['name'],
        unitname = json['unitname'],
        iconUrl = json['iconUrl'];

  String get getName => name ?? (unitname ?? id.toString());
  bool get isSubjective => value == null;
  bool get isObjective => !isSubjective;
}
