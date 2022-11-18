import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../ui/commons/custom_alert_widget.dart';
import '../../../ui/screens/my_user/widgets/bid_out_tile.dart';
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
    if (!bidIn.public.active) {
      // CustomAlertWidget.showToastMessage(context, "Bidder is not active");
      throw "!bidIn.public.active bidIn=${bidIn.public.id}";
    } else if (bidIn.user!.isInMeeting()) {
      CustomAlertWidget.showToastMessage(context, "Bidder is busy with another user");
      await cancelNoShow(bidIn: bidIn);
    } else {
      if (bidIn.public.speed.num != 0) {
        Map sessionWithAddress = await accountService.getAllWalletAddress();
        List<String> addresses = [];
        for (List<String> val in sessionWithAddress.values) {
          addresses.addAll(val);
        }
        if (!addresses.isEmpty) addressOfUserB = addresses.first;
      }
      CustomAlertWidget.loader(true, context);
      await acceptCall(bidIns, addressOfUserB, context);
      CustomAlertWidget.loader(false, context);
    }
  }

  Future acceptCall(List<BidIn> bidIns, String? addressOfUserB, BuildContext context) async {
    final bidIn = bidIns.first;
    final firstUser = bidIn.user;
    final firstUserTokenModels = await database.getTokenFromId(firstUser!.id);

    UserModel? secondUser;
    List<TokenModel> secondUserTokenModels = [];
    if (bidIns.length > 1) {
      secondUser = bidIns[1].user;
      secondUserTokenModels = await database.getTokenFromId(secondUser!.id);
    }

    bool camera = true;
    bool microphone = true;

    if (!kIsWeb) {
      try {
        // camera = await Permission.camera.request().isGranted;
        // microphone = await Permission.microphone.request().isGranted;
      } catch (e) {
        print(e);
      }
    }
    if (camera && microphone) {
      final meeting = Meeting.newMeeting(id: bidIn.public.id, B: user.id, addrB: addressOfUserB, bidIn: bidIn);
      await database.acceptBid(meeting);

      for (final tokenModel in firstUserTokenModels) {
        if (tokenModel.value.isEmpty) continue;
        final jsonDataCurrentUser = {
          'route': Routes.lock,
          'type': 'CALL',
          'title': user.name,
          'body': 'Incoming video call',
          'meetingInfo': {
            'meetingId': meeting.id,
            'meetingUserA': meeting.A,
            'meetingUserB': meeting.B,
          }
        };
        await FirebaseNotifications().sendNotification(tokenModel.value, jsonDataCurrentUser, tokenModel.operatingSystem == 'ios');
      }
      for (final tokenModel in secondUserTokenModels) {
        if (tokenModel.value.isEmpty) continue;
        Map jsonDataNextUser = {'title': 'hi ${secondUser?.name ?? ''}', "body": 'you are next in line'};
        await FirebaseNotifications().sendNotification(tokenModel.value, jsonDataNextUser, tokenModel.operatingSystem == 'ios');
      }
    }
  }

  Future cancelNoShow({required BidIn bidIn}) async {
    return database.cancelBid(A: bidIn.private!.A, B: user.id, bidId: bidIn.public.id);
  }

  Future cancelOwnBid({required BidOut bidOut, required BuildContext context}) async {
    try {
      if (!bidOut.active) return;

      if (bidOut.speed.num == 0) {
        return database.cancelBid(A: user.id, B: bidOut.B, bidId: bidOut.id);
      }
      final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
      await cancelBid.call({'bidId': bidOut.id});
    } on FirebaseFunctionsException catch (error) {
      CustomAlertWidget.showToastMessage(context, error.message ?? "");
      showLoaderIds.value.removeWhere((element) => element == bidOut.id);
      // print(error.message);
    }
  }

  Future updateHangout(UserModel user) => userChanger.updateSettings(user);
}
