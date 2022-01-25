import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_path.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/firestore_database.dart';

class MyHangoutPageViewModel {
  MyHangoutPageViewModel(
      {required this.database,
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
    if (hangout is Hangout &&
        hangout?.status != 'OFFLINE' &&
        hangout!.isInMeeting()) {
      final meeting = Meeting.newMeeting(
          id: bidIn.public.id, uid: hangout!.id, addrB: addrB, bidIn: bidIn);
      database.acceptBid(meeting);
    } else {
      cancelBid(bidId: bidIn.public.id, B: bidIn.hangout!.id);
    }
  }

  // TODO clean separation into firestore_service and firestore_database
  Future cancelBid({required String bidId, required String B}) async {
    if (hangout is Hangout) {
      final bidOutRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidOuts(hangout!.id))
          .doc(bidId);
      final bidInPublicRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidInsPublic(B))
          .doc(bidId);
      final bidInPrivateRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidInsPrivate(B))
          .doc(bidId);
      final obj = {'active': false};
      final setOptions = SetOptions(merge: true);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(bidOutRef, obj, setOptions);
        transaction.set(bidInPublicRef, obj, setOptions);
        transaction.set(bidInPrivateRef, obj, setOptions);
      });
      final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
      await cancelBid({bidId: bidId});
    }
  }

  Future changeNameAndBio(String name, String bio) async {
    await hangoutChanger.updateNameAndBio(name, bio);
  }

  Future updateHangout(Hangout hangout) async {
    await hangoutChanger.updateHangout(hangout);
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
