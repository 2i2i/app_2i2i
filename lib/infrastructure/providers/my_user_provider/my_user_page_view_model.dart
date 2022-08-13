import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../ui/screens/my_user/widgets/wallet_connect_instruction_dialog.dart';
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

  Future<String?> setFirst(BidIn bidIn, BuildContext context) async {
    String? addressOfUserB;
    if (bidIn.public.speed.num != 0) {
      Map sessionWithAddress = await accountService.getAllWalletAddress();
      List<String> addresses = [];
      for (List<String> val in sessionWithAddress.values) {
        addresses.addAll(val);
      }
      if (addresses.isNotEmpty) {
        addressOfUserB = addresses.first;
      }
    }
    return addressOfUserB;
  }

  Future acceptBid(List<BidIn> bidIns, BuildContext context) async {
    String? addressOfUserB;
    BidIn bidIn = bidIns.first;
    if (!(bidIn.public.active)) {
      CustomAlertWidget.showToastMessage(context, "Bidder is not active");
    } else if (bidIn.user!.isInMeeting()) {
      CustomAlertWidget.showToastMessage(context, "Bidder is busy with another user");
      await cancelNoShow(bidIn: bidIn);
    } else if (bidIn.public.speed.num != 0) {
      Map sessionWithAddress = await accountService.getAllWalletAddress();
      List<String> addresses = [];
      for (List<String> val in sessionWithAddress.values) {
        addresses.addAll(val);
      }
      if (addresses.isEmpty) {
        final result = await showModalBottomSheet(context: context, builder: (context) => ConnectDialog());
        if (result is String) {
          addresses.add(result);
        } else {
          Navigator.of(context).maybePop();
          return false;
        }
      }
      if (addresses.isNotEmpty) {
        addressOfUserB = addresses.first;
      }
    }
  }

  Future acceptCall(List<BidIn> bidIns, String addressOfUserB, BuildContext context) async {
    BidIn bidIn = bidIns.first;

    UserModel? firstUser;
    UserModel? secondUser;

    TokenModel? firstUserTokenModel;
    TokenModel? secondUserTokenModel;

    firstUser = bidIn.user;
    firstUserTokenModel = await database.getTokenFromId(firstUser!.id);

    if (bidIns.length > 1) {
      secondUser = bidIns[1].user;
      secondUserTokenModel = await database.getTokenFromId(secondUser!.id);
    }

    bool camera = true;
    bool microphone = true;

    if (!kIsWeb) {
      camera = await Permission.camera.request().isGranted;
      microphone = await Permission.microphone.request().isGranted;
    }
    if (camera && microphone) {
      final meeting = Meeting.newMeeting(id: bidIn.public.id, B: user.id, addrB: addressOfUserB, bidIn: bidIn);
      await database.acceptBid(meeting);

      if (firstUserTokenModel is TokenModel) {
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
    }
  }

  Future cancelNoShow({required BidIn bidIn}) async {
    return database.cancelBid(A: bidIn.private!.A, B: user.id, bidId: bidIn.public.id);
  }

  Future cancelOwnBid({required BidOut bidOut}) async {
    if (!bidOut.active) return;

    if (bidOut.speed.num == 0) {
      return database.cancelBid(A: user.id, B: bidOut.B, bidId: bidOut.id);
    }
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid.call({'bidId': bidOut.id});
  }

  Future updateHangout(UserModel user) => userChanger.updateSettings(user);
}
