import 'package:flutter/material.dart';

@immutable
class ImportanceModel {
  final int lurker; // uint lurker = 0;
  final int chrony; // uint
  final int highroller; // uint
  final int eccentric; // uint

  ImportanceModel({this.lurker = 0, required this.chrony, required this.highroller, this.eccentric = 0});

  ImportanceModel.fromJson(Map<String, dynamic> json)
      : lurker = json['lurker'],
        chrony = json['chrony'],
        highroller = json['highroller'],
        eccentric = json['eccentric'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lurker'] = this.lurker;
    data['chrony'] = this.chrony;
    data['highroller'] = this.highroller;
    data['eccentric'] = this.eccentric;
    return data;
  }
}
