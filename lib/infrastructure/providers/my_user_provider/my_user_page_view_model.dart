import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../../ui/commons/custom_alert_widget.dart';
import '../../../ui/screens/my_user/widgets/wallet_connect_dialog.dart';
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

  Future<bool> acceptBid(List<BidIn> bidIns, BuildContext context) async {
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
      Map sessionWithAddress = await accountService.getAllWalletAddress();
      List<String> addresses = [];
      for (List<String> val in sessionWithAddress.values) {
        addresses.addAll(val);
      }
      if (addresses.isNotEmpty) {
        addressOfUserB = addresses.first;
      } else {
        await CustomAlertWidget.showBottomSheet(context, child: WalletConnectDialog(), isDismissible: true);
        return true;
      }
      /*final account = await accountService.getMainAccount();
      if (account is AbstractAccount) {
        addressOfUserB = account.address;
      } else {
        CustomAlertWidget.showBottomSheet(context, child: WalletConnectDialog(), isDismissible: true);
        return true;
      }*/
    }
    final meeting = Meeting.newMeeting(id: bidIn.public.id, B: user.id, addrB: addressOfUserB, bidIn: bidIn);
    await database.acceptBid(meeting);

    if ((firstUserTokenModel is TokenModel)) {
      Map jsonDataCurrentUser = {
        'route': Routes.lock,
        'type': 'CALL',
        "title": user.name,
        "body": 'Incoming video call',
        "meetingId": bidIn.public.id,
        "meetingData": meeting.toMap(),
      };
      await FirebaseNotifications().sendNotification((firstUserTokenModel.token ?? ""), jsonDataCurrentUser, firstUserTokenModel.isIos ?? false);

      if (secondUserTokenModel is TokenModel) {
        Map jsonDataNextUser = {"title": 'Hey ${secondUser?.name ?? ""} don\'t wait', "body": 'You are next in line'};
        await FirebaseNotifications().sendNotification((secondUserTokenModel.token ?? ""), jsonDataNextUser, secondUserTokenModel.isIos ?? false);
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
    final HttpsCallableResult result = await cancelBid.call({'bidId': bidOut.id});
  }

  Future updateHangout(UserModel user) => userChanger.updateSettings(user);
}
