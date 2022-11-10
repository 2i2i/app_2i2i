import 'package:flutter/material.dart';

@immutable
class RedeemCoinModel {
  final int assetId;
  final int value;
  final String uid;

  RedeemCoinModel({required this.assetId, required this.value, required this.uid});
}
