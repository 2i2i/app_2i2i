import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

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

  Future acceptBid(Bid bid, AbstractAccount? account) async {
    final HttpsCallable acceptBid = functions.httpsCallable('acceptBid');
    // TODO only get algorandAddress if bid.speed.num != 0
    await acceptBid({
      'addrB': account?.address,
      'bid': bid.id,
    });
  }

  Future cancelBid(Bid bid) async {
    final HttpsCallable cancelBid = functions.httpsCallable('cancelBid');
    await cancelBid({
      'bid': bid.id,
    });
  }

  Future changeNameAndBio(String name, String bio) async {
    await userModelChanger.updateNameAndBio(name, bio);
  }

  Future setUserPrivate({required BuildContext context,required String uid, required UserModelPrivate userPrivate}) async {
    CustomDialogs.loader(true, context);
    await database.setUserPrivate(uid: uid,userPrivate: userPrivate);
    CustomDialogs.loader(false, context);
  }
}
