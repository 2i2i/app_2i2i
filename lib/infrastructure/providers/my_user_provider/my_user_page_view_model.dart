import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/firestore_database.dart';

class MyUserPageViewModel {
  MyUserPageViewModel(
      {required this.database,
      required this.functions,
      required this.user,
      required this.accountService,
      required this.userModelChanger});
  final UserModel user;
  final FirestoreDatabase database;
  final FirebaseFunctions functions;
  final UserModelChanger userModelChanger;
  final AccountService accountService;

  Future acceptBid(BidInPublic bidIn, BidInPrivate bidInPrivate) async {
    String? addrB;
    if (bidIn.speed.num != 0) {
      final account = await accountService.getMainAccount();
      addrB = account.address;
    }
    final meeting = Meeting.newMeeting(
        uid: user.id, addrB: addrB, bidIn: bidIn, bidInPrivate: bidInPrivate);
    database.acceptBid(meeting);
  }

  // TODO clean separation into firestore_service and firestore_database
  Future cancelBid({required String bidId, required String B}) async {
    final bidOutRef = FirebaseFirestore.instance
        .collection('users/${user.id}/bidOuts')
        .doc(bidId);
    final bidInRef =
        FirebaseFirestore.instance.collection('users/$B/bidIns').doc(bidId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(bidOutRef, {'active': false}, SetOptions(merge: true));
      transaction.set(bidInRef, {'active': false}, SetOptions(merge: true));
    });
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({bidId: bidId});
  }

  Future changeNameAndBio(String name, String bio) async {
    await userModelChanger.updateNameAndBio(name, bio);
  }

  Future setUserPrivate(
      {required BuildContext context,
      required String uid,
      required UserModelPrivate userPrivate}) async {
    CustomDialogs.loader(true, context);
    await database.setUserPrivate(uid: uid, userPrivate: userPrivate);
    CustomDialogs.loader(false, context);
  }
}
