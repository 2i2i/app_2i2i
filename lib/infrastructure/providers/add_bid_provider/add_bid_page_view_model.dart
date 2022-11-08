import 'dart:async';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_path.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/services/firebase_notifications.dart';
import '../../data_access_layer/services/logging.dart';
import '../../models/token_model.dart';

class AddBidPageViewModel {
  AddBidPageViewModel({
    required this.A,
    required this.database,
    required this.functions,
    required this.algorand,
    required this.B,
    // required this.accounts,
    required this.accountService,
  });

  final String A;
  final FirebaseFunctions functions;
  final UserModel B;
  final AlgorandService algorand;
  final AccountService accountService;

  // final List<AbstractAccount> accounts;
  final FirestoreDatabase database;

  bool submitting = false;

  /* String duration(AbstractAccount account, Quantity speed, Quantity balance) {
    if (speed.num == 0) return 'forever';
    final seconds = balance.num / speed.num;
    return secondsToSensibleTimePeriod(seconds.round());
  }*/

  Future addBid({
    // required FireBaseMessagingService fireBaseMessaging,
    String? sessionId,
    required String? address,
    required Quantity amount,
    required Quantity speed,
    String? bidComment,
    BuildContext? context,
    Function? timeout,
  }) async {

    log(FX + 'addBid sessionId=$sessionId address=$address amount.assetId=${amount.assetId} amount.num=${amount.num} speed.assetId=${speed.assetId} speed.num=${speed.num} bidComment=$bidComment');

    FocusScope.of(context!).unfocus();
    if (B.blocked.contains(A)) {
      await CustomAlertWidget.showErrorDialog(context, Keys.errorWhileAddBid.tr(context), errorStacktrace: Keys.cantBidUser.tr(context));
    } else if (speed.num < B.rule.minSpeedALGO) {
      await CustomAlertWidget.showErrorDialog(context, Keys.errorWhileAddBid.tr(context), errorStacktrace: Keys.miniSupport.tr(context));
    } else if (speed.num != 0 && (sessionId?.isEmpty ?? true)) {
      await CustomAlertWidget.showErrorDialog(context, Keys.errorWhileAddBid.tr(context), errorStacktrace: Keys.noWalletFound.tr(context));
    } else {
      final net = AppConfig().ALGORAND_NET;
      final String? addrA = speed.num == 0 ? null : address;
      final bidId = database.newDocId(path: FirestorePath.meetings()); // new bid id comes from meetings to avoid collision

      log(FX + 'addBid net=$net addrA=$addrA bidId=$bidId');

      // lock coins
      Map<String, String> txns = {};
      try {
        if (speed.num != 0) {
          CustomAlertWidget.loader(true, context, title: Keys.weAreWaiting.tr(context), message: Keys.confirmInWallet.tr(context));
        } else {
          CustomAlertWidget.loader(true, context);
        }

        if (speed.num != 0 && sessionId is String) {
          final note = bidId + '.' + speed.num.toString() + '.' + speed.assetId.toString();

          if ((sessionId.isNotEmpty) && (address?.isNotEmpty ?? false)) {
            txns = await algorand.lockCoins(sessionId: sessionId, address: address!, net: net, amount: amount, note: note).timeout(Duration(seconds: 60));
          }
        }

        // FX
        double FXValue = 1;
        if (speed.assetId != 0) {
          final FX = await database.getFX(speed.assetId);
          FXValue = FX!.value; // crash if no FX
        }

        final bidOut = BidOut(
          id: bidId,
          B: B.id,
          speed: speed,
          net: net,
          txns: txns,
          active: true,
          addrA: addrA,
          energy: amount.num,
          comment: bidComment,
          FX: FXValue,
        );
        final bidInPublic = BidInPublic(
          id: bidId,
          speed: speed,
          net: net,
          active: true,
          ts: DateTime.now().toUtc(),
          rule: B.rule,
          energy: amount.num,
          FX: FXValue,
        );
        final bidInPrivate = BidInPrivate(
          id: bidId,
          active: true,
          A: A,
          addrA: addrA,
          comment: bidComment,
          txns: txns,
        );

        BidIn bidIn = BidIn(public: bidInPublic, private: bidInPrivate);
        await database.addBid(bidOut, bidIn);

        TokenModel? bUserTokenModel = await database.getTokenFromId(B.id);
        log(A + 'bUserTokenModel=$bUserTokenModel B.id=${B.id}');

        if (bUserTokenModel is TokenModel) {
          Map jsonDataCurrentUser = {"title": "2i2i", "body": Keys.someOneTalk.tr(context)};
          await FirebaseNotifications().sendNotification((bUserTokenModel.token ?? ""), jsonDataCurrentUser, bUserTokenModel.isIos ?? false);
        }

        CustomAlertWidget.loader(false, context);
        Navigator.pop(context);
      } on TimeoutException {
        timeout?.call();
        Navigator.pop(context);
      } on AlgorandException catch (ex) {
        final cause = ex.cause;
        if (cause is dio.DioError) {
          final message = cause.response?.data['message'];
          CustomAlertWidget.showErrorDialog(context, Keys.errorWhileAddBid.tr(context), errorStacktrace: '$message');
          Navigator.pop(context);
        }
      } on WalletConnectException catch (e) {
        await CustomAlertWidget.showErrorDialog(
          context,
          Keys.errorWhileAddBid.tr(context),
          errorStacktrace: '${e.message}',
        );
        Navigator.pop(context);
      } catch (e) {
        log('AlgorandException catch $e');
      }
    }
  }
}
