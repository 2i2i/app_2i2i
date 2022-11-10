import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/screens/redeem_coin/widgets/redeem_tile.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class RedeemCoinViewModel {
  final FirebaseFunctions functions;

  RedeemCoinViewModel({required this.functions});

  Future redeemCoin({
    required int assetId,
    required String addr,
    required BuildContext context,
  }) async {
    try {
      final HttpsCallable redeemCoin = functions.httpsCallable('redeem');
      await redeemCoin.call({'assetId': assetId, 'addr': addr});
    } on FirebaseFunctionsException catch (error) {
      CustomAlertWidget.showToastMessage(context, error.message ?? "");
      showCoinLoaderIds.value.removeWhere((element) => element == assetId);
    } catch (e) {
      showCoinLoaderIds.value.removeWhere((element) => element == assetId);
      print(e);
    }
  }
}
