import 'dart:async';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_path.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';

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
    required this.accounts,
    required this.accountService,
  });

  final String A;
  final FirebaseFunctions functions;
  final UserModel B;
  final AlgorandService algorand;
  final AccountService accountService;
  final List<AbstractAccount> accounts;
  final FirestoreDatabase database;

  bool submitting = false;

  String duration(AbstractAccount account, Quantity speed, Quantity balance) {
    if (speed.num == 0) return 'forever';
    final seconds = balance.num / speed.num;
    return secondsToSensibleTimePeriod(seconds.round());
  }

  Future addBid({
    // required FireBaseMessagingService fireBaseMessaging,
    required AbstractAccount? account,
    required Quantity amount,
    required Quantity speed,
    String? bidComment,
    BuildContext? context,
    Function? timeout,
  }) async {
    log('AddBidPageViewModel - addBid - amount.assetId=${amount.assetId}');

    if (speed.num < B.rule.minSpeed) return;
    // throw Exception('speed.num < B.rule.minSpeed');

    if (B.blocked.contains(A)) return;

    final net = AppConfig().ALGORAND_NET;
    final String? addrA = speed.num == 0 ? null : account!.address;
    final bidId = database.newDocId(path: FirestorePath.meetings()); // new bid id comes from meetings to avoid collision

    // lock coins
    Map<String, String> txns = {};
    if (speed.num != 0) {
      final note = bidId + '.' + speed.num.toString() + '.' + speed.assetId.toString();
      try {
        txns = await algorand.lockCoins(account: account!, net: net, amount: amount, note: note).timeout(Duration(seconds: 60));
      } on TimeoutException catch (e) {
        log('AlgorandException  ${e.message}');
        timeout?.call();
        return;
      } on AlgorandException catch (ex) {
        final cause = ex.cause;
        if (cause is dio.DioError) {
          final message = cause.response?.data['message'];
          if (context != null) {
            CustomAlertWidget.showErrorDialog(context, Keys.errorWhileAddBid.tr(context), errorStacktrace: '$message');
          }
          log('AlgorandException ' + message);
        }
        return;
      } catch (e) {
        log('AlgorandException catch $e');
      }
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
    );
    final bidInPublic = BidInPublic(
      id: bidId,
      speed: speed,
      net: net,
      active: true,
      ts: DateTime.now().toUtc(),
      rule: B.rule,
      energy: amount.num,
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

    if (bUserTokenModel is TokenModel) {
      Map jsonDataCurrentUser = {"title": "2i2i", "body": 'Someone wants to talk with you'};
      await FirebaseNotifications().sendNotification((bUserTokenModel.token ?? ""), jsonDataCurrentUser, bUserTokenModel.isIos ?? false);
    }
  }
}
