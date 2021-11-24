import 'dart:async';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class RingingPageViewModel {
  RingingPageViewModel(
      {required this.user,
      required this.meeting,
      required this.algorand,
      required this.functions}) {
    if (meeting.currentStatus() == MeetingValue.LOCK_COINS_STARTED)
      _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
          txId: meeting.lockTxId!);
  }

  final FirebaseFunctions functions;
  final AlgorandService algorand;
  final UserModel user;
  final Meeting meeting;

  bool amA() {
    final x = meeting.A == user.id;
    log(F + 'RingingPageViewModel - amA - x=$x');
    return x;
  }

  Future cancelMeeting({String? reason}) async {
    log(F +
        'RingingPageViewModel - cancelMeeting - meeting.id=${meeting.id} - reason=$reason');
    final HttpsCallable endMeeting = functions.httpsCallable('endMeeting');
    final args = {'meetingId': meeting.id};
    if (reason != null) args['reason'] = reason + (amA() ? '_A' : '_B');
    await endMeeting(args);
  }

  Future acceptMeeting() async {
    log(F + 'RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id}');

    final String txId =
        await algorand.lockCoins(meeting: meeting, waitForConfirmation: false);

    log(F +
        'RingingPageViewModel - acceptMeeting - meeting.id=${meeting.id} - txId=$txId');
    if (txId == 'error') {
      final HttpsCallable meetingTxnFailed =
          functions.httpsCallable('meetingTxnFailed');
      await meetingTxnFailed({
        'meetingId': meeting.id,
      });
      return;
    }

    // update meeting
    await _updateMeetingAsLockCoinsStarted(txId: txId);
    await _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(txId: txId);
  }

  Future _updateMeetingAsLockCoinsStarted({required String txId}) async {
    log(F +
        'RingingPageViewModel - _updateMeetingAsLockCoinsStarted - txId=$txId');

    final HttpsCallable meetingLockCoinsStarted =
        functions.httpsCallable('meetingLockCoinsStarted');
    await meetingLockCoinsStarted({
      'meetingId': meeting.id,
      'lockTxId': txId,
    });
  }

  Future _waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed(
      {required String txId}) async {
    // wait for transaction to confirm
    log(F +
        'RingingPageViewModel - waitForAlgorandAndUpdateMeetingToLockCoinsConfirmed - txId=$txId');
    await algorand.waitForConfirmation(txId: txId);

    // update meeting
    // message = 'updating meeting';
    // notifyListeners();
    final HttpsCallable meetingLockCoinsConfirmed =
        functions.httpsCallable('meetingLockCoinsConfirmed');
    await meetingLockCoinsConfirmed({
      'meetingId': meeting.id,
    });
  }
}
