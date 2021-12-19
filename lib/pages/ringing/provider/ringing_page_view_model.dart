import 'dart:async';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RingingPageViewModel {
  RingingPageViewModel(
      {required this.user,
      required this.otherUser,
      required this.meeting,
      required this.algorand,
      required this.functions}) {
    if (meeting.currentStatus() == MeetingValue.LOCK_COINS_STARTED)
      _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
          txId: meeting.lockTxId, net: meeting.net);
  }

  final FirebaseFunctions functions;
  final AlgorandService algorand;
  final UserModel user;
  final UserModel otherUser;
  final Meeting meeting;

  bool amA() {
    final x = meeting.A == user.id;
    log('RingingPageViewModel - amA - x=$x');
    return x;
  }

  Future cancelMeeting({String? reason}) async {
    log('RingingPageViewModel - cancelMeeting - meeting.id=${meeting.id} - reason=$reason');
    final HttpsCallable endMeeting = functions.httpsCallable('endMeeting');
    final args = {'meetingId': meeting.id};
    if (reason != null) args['reason'] = reason + (amA() ? '_A' : '_B');
    await endMeeting(args);
  }

  Future acceptMeeting() async {
    try {
      log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id}');

      Map<String, String> txnsIds = {};

      if (meeting.speed.num != 0) {
        try {
          txnsIds = await algorand.lockCoins(
              meeting: meeting, waitForConfirmation: false);
          log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id} - txId=$txnsIds');
        } catch (ex) {
          final HttpsCallable meetingTxnFailed =
              functions.httpsCallable('meetingTxnFailed');
          await meetingTxnFailed({'meetingId': meeting.id});
          return;
        }
      }

      // update meeting
      await _updateMeetingAsLockCoinsStarted(
          txId:
              txnsIds['GROUP']); // TODO quickfix. needs change for ASA support

      // TODO quickfix. needs change for ASA support
      await _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
          txId: txnsIds['GROUP'], net: meeting.net, paymentTxnId: txnsIds['LOCK']);
    } catch (e) {
      log(e.toString());
    }
  }

  Future _updateMeetingAsLockCoinsStarted({required String? txId}) async {
    log('RingingPageViewModel - _updateMeetingAsLockCoinsStarted - txId=$txId');

    final HttpsCallable meetingLockCoinsStarted =
        functions.httpsCallable('meetingLockCoinsStarted');
    await meetingLockCoinsStarted({'meetingId': meeting.id, 'lockTxId': txId});
  }

  Future _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
      {required String? txId,
      required AlgorandNet net,
      String? paymentTxnId}) async {
    // wait for transaction to confirm
    log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - txId=$txId');
    // int budget = 0;
    if (txId != null) {
      await algorand.waitForConfirmation(txId: txId, net: net);
      // if (paymentTxnId != null) {
      //   final txn = await algorand.getTransactionResponse(paymentTxnId, net);
      //   budget = txn.transaction.paymentTransaction!.amount;
      // }
      // final rawTxn = txn.transaction.transaction;
      // final a = rawTxn is PaymentTransaction;
      // final b = rawTxn is ApplicationBaseTransaction;
      // final paymentTxn = txn.transaction.transaction as PaymentTransaction;
      // budget = paymentTxn.amount! -
      //     AlgorandService.LOCK_ALGO_FEE; // TODO incorrect for ASA
      // log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - budget=$budget');
      // log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - txn.transaction.toJson()=${txn.transaction.toJson()}');
      // for (int i = 0; i < txn.innerTxns.length; i++)
      //   log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - txn.innerTxns[i].transaction.toJson()=${txn.innerTxns[i].transaction.toJson()}');
    }

    // update meeting
    // message = 'updating meeting';
    // notifyListeners();
    final HttpsCallable meetingLockCoinsConfirmed =
        functions.httpsCallable('meetingLockCoinsConfirmed');
    await meetingLockCoinsConfirmed(
        {'meetingId': meeting.id});
  }
}
