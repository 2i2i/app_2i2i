import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/services/logging.dart';

class AddBidPageViewModel {
  AddBidPageViewModel({
    required this.uid,
    required this.database,
    required this.functions,
    required this.algorand,
    required this.B,
    required this.accounts,
    required this.accountService,
  });

  final String uid;
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
    String? bidNote,
    BuildContext? context,
  }) async {
    log('AddBidPageViewModel - addBid - amount.assetId=${amount.assetId}');

    final net = AlgorandNet.testnet;
    final String? addrA = speed.num == 0 ? null : account!.address;
    final bidId = database.newDocId(path: 'users/$uid/bidOuts');

    // lock coins
    String? txId;
    if (speed.num != 0) {
      final note =
          bidId + '.' + speed.num.toString() + '.' + speed.assetId.toString();
      try {
        txId = await algorand.lockCoins(
            account: account!, net: net, amount: amount, note: note);
      } on AlgorandException catch (ex) {
        final cause = ex.cause;
        if (cause is dio.DioError) {
          final message = cause.response?.data['message'];
          if(context != null) {
            CustomAlertWidget.showErrorDialog(
              context,
              Strings().errorWhileAddBid,
              errorStacktrace: '$message'
            );
          }
          log('AlgorandException ' + message);
        }
        return;
      }
    }

    // TODO clean separation into firestore_service and firestore_database
    final bidOutRef =
        FirebaseFirestore.instance.collection('users/$uid/bidOuts').doc(bidId);
    final bidOut = BidOut(
      id: bidId,
      B: B.id,
      speed: speed,
      net: net,
      txId: txId,
      active: true,
      addrA: addrA,
      budget: amount.num,
    );
    final bidInRef = FirebaseFirestore.instance
        .collection('users/${B.id}/bidIns')
        .doc(bidId);
    final bidIn = BidInPublic(id: bidId, speed: speed, net: net, active: true);
    final bidInPrivateRef = FirebaseFirestore.instance
        .collection('users/${B.id}/bidIns')
        .doc(bidId)
        .collection('private')
        .doc('main');
    final bidInPrivate = BidInPrivate(
        A: uid, addrA: addrA, comment: bidNote, txId: txId, budget: amount.num);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(bidOutRef, bidOut.toMap(), SetOptions(merge: false));
      transaction.set(bidInRef, bidIn.toMap(), SetOptions(merge: false));
      transaction.set(
          bidInPrivateRef, bidInPrivate.toMap(), SetOptions(merge: false));
    });
  }
}
