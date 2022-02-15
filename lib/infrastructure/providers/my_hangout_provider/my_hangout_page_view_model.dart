import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../commons/keys.dart';
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
  final Hangout hangout;
  final FirestoreDatabase database;
  final FirebaseFunctions functions;
  final HangoutChanger hangoutChanger;
  final AccountService accountService;

  Future<bool> acceptBid(BidIn bidIn) async {
    if (!bidIn.public.active) return false;

    if (bidIn.hangout!.status == Keys.statusOFFLINE ||
        bidIn.hangout!.isInMeeting()) {
      await cancelNoShow(bidIn: bidIn);
      return false;
    }

    String? addrB;
    if (bidIn.public.speed.num != 0) {
      final account = await accountService.getMainAccount();
      addrB = account.address;
    }
    final meeting = Meeting.newMeeting(
        id: bidIn.public.id, B: hangout.id, addrB: addrB, bidIn: bidIn);
    await database.acceptBid(meeting);

    return true;
  }

  Future cancelNoShow({required BidIn bidIn}) async {
    return database.cancelBid(
        A: bidIn.private!.A, B: hangout.id, bidId: bidIn.public.id);
  }

  Future cancelOwnBid({required BidOut bidOut}) async {
    if (!bidOut.active) return;

    if (bidOut.speed.num == 0) {
      return database.cancelBid(A: hangout.id, B: bidOut.B, bidId: bidOut.id);
    }
    // 0 < speed
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({'bidId': bidOut.id});
  }

  Future updateHangout(Hangout hangout) =>
      hangoutChanger.updateSettings(hangout);
}
