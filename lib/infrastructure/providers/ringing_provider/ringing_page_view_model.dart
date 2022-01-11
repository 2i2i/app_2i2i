import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';

import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/services/logging.dart';
import '../../models/meeting_model.dart';
import '../../models/user_model.dart';

class RingingPageViewModel {
  RingingPageViewModel(
      {required this.user,
      required this.otherUser,
      required this.meeting,
      required this.algorand,
      required this.functions,
      required this.meetingChanger}) {
    if (meeting.status == MeetingStatus.TXN_SENT)
      _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
          txns: meeting.txns, net: meeting.net);
  }

  final MeetingChanger meetingChanger;
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

  Future endMeeting(MeetingStatus reason) =>
      meetingChanger.endMeeting(meeting, reason);

  Future acceptMeeting() async {
    try {
      log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id}');

      // ACCEPT
      final HttpsCallable advanceMeeting =
          functions.httpsCallable('advanceMeeting');
      await advanceMeeting({
        'reason': meeting.speed.num != 0
            ? MeetingStatus.ACCEPTED.toStringEnum()
            : 'ACCEPTED_FREE_CALL',
        'meetingId': meeting.id
      });

      MeetingTxns txns = MeetingTxns();
      if (meeting.speed.num != 0) {
        try {
          txns = await algorand.lockCoins(meeting: meeting);
          log('RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id} - txns=$txns');
        } catch (ex) {
          return endMeeting(MeetingStatus.END_TXN_FAILED);
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
