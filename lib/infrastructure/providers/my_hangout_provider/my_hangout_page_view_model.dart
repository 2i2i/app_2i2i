import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/firestore_database.dart';

class MyHangoutPageViewModel {
  MyHangoutPageViewModel({
    required this.database,
    required this.functions,
    required this.hangout,
    required this.accountService,
    required this.hangoutChanger,
  });
  final Hangout? hangout;
  final FirestoreDatabase database;
  final FirebaseFunctions functions;
  final HangoutChanger hangoutChanger;
  final AccountService accountService;

  Future acceptBid(BidIn bidIn) async {
    String? addrB;
    if (bidIn.public.speed.num != 0) {
      final account = await accountService.getMainAccount();
      addrB = account.address;
    }
    if (hangout is Hangout) {
      final meeting = Meeting.newMeeting(
          id: bidIn.public.id, B: hangout!.id, addrB: addrB, bidIn: bidIn);
      database.acceptBid(meeting);
    }
  }

  // TODO clean separation into firestore_service and firestore_database
  Future cancelBid({required BidOut bidOut}) async {
    if (hangout != null && bidOut.speed.num == 0) {
      return database.cancelBid(bidOut, hangout!.id);
    }
    // 0 < speed
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({'bidId': bidOut.id});
  }

  Future changeNameAndBio(String name, String bio) async {
    await hangoutChanger.updateNameAndBio(name, bio);
  }

  Future updateHangout(Hangout hangout) async {
    await hangoutChanger.updateHangout(hangout);
  }
}
