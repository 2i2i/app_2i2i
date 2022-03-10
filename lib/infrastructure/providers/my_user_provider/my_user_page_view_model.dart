import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/firestore_database.dart';

class MyUserPageViewModel {
  MyUserPageViewModel({
    required this.database,
    required this.functions,
    required this.user,
    required this.accountService,
    required this.userChanger,
  });
  final UserModel user;
  final FirestoreDatabase database;
  final FirebaseFunctions functions;
  final UserModelChanger userChanger;
  final AccountService accountService;

  Future<bool> acceptBid(BidIn bidIn, {String? token, bool isIos = false}) async {
    if (!bidIn.public.active) return false;

    if (/*bidIn.user!.status == Status.OFFLINE ||*/bidIn.user!.isInMeeting()) {
      await cancelNoShow(bidIn: bidIn);
      return false;
    }

    String? addrB;
    if (bidIn.public.speed.num != 0) {
      final account = await accountService.getMainAccount();
      addrB = account.address;
    }
    final meeting = Meeting.newMeeting(
        id: bidIn.public.id, B: user.id, addrB: addrB, bidIn: bidIn);
    await database.acceptBid(meeting);
    if(token != null) {

      Map data = {
        'route':Routes.lock,
        'type':'Call',
        "title": bidIn.user?.name ?? '',
        "body": 'Incoming video call'
      };
      // await FirebaseNotifications().sendNotification(token,data,isIos);
    }
    return true;
  }

  Future cancelNoShow({required BidIn bidIn}) async {
    return database.cancelBid(
        A: bidIn.private!.A, B: user.id, bidId: bidIn.public.id);
  }

  Future cancelOwnBid({required BidOut bidOut}) async {
    if (!bidOut.active) return;

    if (bidOut.speed.num == 0) {
      return database.cancelBid(A: user.id, B: bidOut.B, bidId: bidOut.id);
    }
    // 0 < speed
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({'bidId': bidOut.id});
  }

  Future updateHangout(UserModel user) =>
      userChanger.updateSettings(user);
}
