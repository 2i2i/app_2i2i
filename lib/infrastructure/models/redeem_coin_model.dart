import 'package:flutter/material.dart';

@immutable
class RedeemCoinModel {
  final int assetId;
  final int value;
  final String uid;

  RedeemCoinModel({required this.assetId, required this.value, required this.uid});

  RedeemCoinModel.fromJson({required Map json, required String documentId})
      : assetId = json['assetId'],
        uid = documentId,
        value = json['value'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assetId'] = this.assetId;
    data['value'] = this.value;
    return data;
  }
}
