import 'dart:async';

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
          txns: meeting.txns, net: meeting.net);
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

      MeetingTxns txns = MeetingTxns();

      if (meeting.speed.num != 0) {
        try {
          txns = await algorand.lockCoins(
              meeting: meeting, waitForConfirmation: false);
          log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id} - txns=$txns');
        } catch (ex) {
          final HttpsCallable meetingTxnFailed =
              functions.httpsCallable('meetingTxnFailed');
          await meetingTxnFailed({'meetingId': meeting.id});
          return;
        }
      }

      // update meeting
      await _updateMeetingAsLockCoinsStarted(txns);

      await _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
          txns: txns, net: meeting.net);
    } catch (e) {
      log(e.toString());
    }
  }

  Future _updateMeetingAsLockCoinsStarted(MeetingTxns txns) async {
    log('RingingPageViewModel - _updateMeetingAsLockCoinsStarted - txns=$txns');

    final data = {'meetingId': meeting.id, 'txns': txns.toMap()};
    final HttpsCallable meetingLockCoinsStarted =
        functions.httpsCallable('meetingLockCoinsStarted');
    await meetingLockCoinsStarted(data);
  }

  Future _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
      {required MeetingTxns txns, required AlgorandNet net}) async {
    // wait for transaction to confirm
    log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - txns=$txns');
    // int budget = 0;

    final meetingLockCoinsConfirmedData = <String, dynamic>{
      'meetingId': meeting.id
    };

    await algorand.waitForConfirmation(txId: txns.group, net: net);

    final isALGO = meeting.speed.assetId == 0;
    final txnResponse = await algorand.getTransactionResponse(
        txns.lockId(isALGO: isALGO)!, net);
    final budget = isALGO
        ? txnResponse.transaction.paymentTransaction!.amount -
            AlgorandService.LOCK_ALGO_FEE
        : txnResponse.transaction.assetTransferTransaction!.amount;
    meetingLockCoinsConfirmedData['budget'] = budget;
    log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - budget=$budget');

    // update meeting
    // message = 'updating meeting';
    // notifyListeners();
    final HttpsCallable meetingLockCoinsConfirmed =
        functions.httpsCallable('meetingLockCoinsConfirmed');
    await meetingLockCoinsConfirmed(meetingLockCoinsConfirmedData);
  }
}
