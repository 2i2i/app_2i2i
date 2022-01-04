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
    if (meeting.status == MeetingStatus.TXN_SENT)
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

  Future endMeeting(MeetingStatus reason) async {
    final HttpsCallable endMeeting = functions.httpsCallable('endMeeting');
    final args = {'meetingId': meeting.id, 'reason': reason.toStringEnum()};
    await endMeeting(args);
  }

  Future acceptMeeting() async {
    try {
      log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id}');

      // ACCEPT
      final HttpsCallable advanceMeeting =
          functions.httpsCallable('advanceMeeting');
      await advanceMeeting({
        'reason': meeting.speed.num != 0 ? MeetingStatus.ACCEPTED.toStringEnum() : 'ACCEPTED_FREE_CALL',
        'meetingId': meeting.id
      });

      MeetingTxns txns = MeetingTxns();
      if (meeting.speed.num != 0) {
        try {
          txns = await algorand.lockCoins(meeting: meeting);
          log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id} - txns=$txns');
        } catch (ex) {
          final HttpsCallable endMeeting =
              functions.httpsCallable('endMeeting');
          await endMeeting({
            'meetingId': meeting.id,
            'reason': MeetingStatus.END_TXN_FAILED.toStringEnum()
          });
          return;
        }
      }

      await _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
          txns: txns, net: meeting.net);
    } catch (e) {
      log(e.toString());
    }
  }

  Future _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
      {required MeetingTxns txns, required AlgorandNet net}) async {
    log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - txns=$txns');

    if (txns.group != null) {
      await algorand.waitForConfirmation(txId: txns.group!, net: net);
    }

    int budget = 0;
    if (txns.lockALGO != null) {
      final isALGO = meeting.speed.assetId == 0;
      final txnResponse = await algorand.getTransactionResponse(
          txns.lockId(isALGO: isALGO)!, net);
      budget = isALGO
          ? txnResponse.transaction.paymentTransaction!.amount -
              AlgorandService.LOCK_ALGO_FEE
          : txnResponse.transaction.assetTransferTransaction!.amount;
    }
    log('RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - budget=$budget');

    final HttpsCallable advanceMeeting =
        functions.httpsCallable('advanceMeeting');
    await advanceMeeting({
      'reason': MeetingStatus.TXN_CONFIRMED.toStringEnum(),
      'budget': budget,
      'meetingId': meeting.id
    });
  }
}
