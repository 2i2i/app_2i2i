import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/services/firebase_notifications.dart';
import '../../models/token_model.dart';
import '../../routes/app_routes.dart';

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

  Future<bool> acceptBid(List<BidIn> bidIns) async {
    BidIn bidIn = bidIns.first;

    UserModel? firstUser;
    UserModel? secondUser;

    TokenModel? firstUserTokenModel;
    TokenModel? secondUserTokenModel;

    firstUser = bidIn.user;
    if (firstUser == null) {
      return false;
    }

    firstUserTokenModel = await database.getTokenFromId(firstUser.id);

    if (bidIns.length > 1) {
      secondUser = bidIns[1].user;
      secondUserTokenModel = await database.getTokenFromId(secondUser!.id);
    }

    if (!bidIn.public.active) return false;

    if (bidIn.user!.isInMeeting()) {
      await cancelNoShow(bidIn: bidIn);
      return false;
    }

    String? addressOfUserB;
    if (bidIn.public.speed.num != 0) {
      final account = await accountService.getMainAccount();
      addressOfUserB = account.address;
    }
    final meeting = Meeting.newMeeting(id: bidIn.public.id, B: user.id, addrB: addressOfUserB, bidIn: bidIn);
    await database.acceptBid(meeting);

    if ((firstUserTokenModel is TokenModel)) {
      Map jsonDataCurrentUser = {
        'route': Routes.lock,
        'type': 'CALL',
        "title": firstUser.name,
        "body": 'Incoming video call',
        "meetingData": meeting.toMap(),
      };

      print(jsonDataCurrentUser);

      await FirebaseNotifications()
          .sendNotification((firstUserTokenModel.token ?? ""), jsonDataCurrentUser, firstUserTokenModel.isIos ?? false);

      if (secondUserTokenModel is TokenModel) {
        Map jsonDataNextUser = {"title": 'Hey ${secondUser?.name ?? ""} don\'t wait', "body": 'You are next in line'};
        await FirebaseNotifications().sendNotification(
            (secondUserTokenModel.token ?? ""), jsonDataNextUser, secondUserTokenModel.isIos ?? false);
      }
    }
    return true;
  }

  Future cancelNoShow({required BidIn bidIn}) async {
    return database.cancelBid(A: bidIn.private!.A, B: user.id, bidId: bidIn.public.id);
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

  Future updateHangout(UserModel user) => userChanger.updateSettings(user);
}
