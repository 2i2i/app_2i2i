import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import '../../ui/screens/my_user/widgets/bid_out_tile.dart';

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
      showLoaderIds.value.removeWhere((element) => element == assetId);
    } catch (e) {
      showLoaderIds.value.removeWhere((element) => element == assetId);
      print(e);
    }
  }
}
