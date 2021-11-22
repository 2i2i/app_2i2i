import 'package:app_2i2i/services/algorand_service.dart';
import 'package:flutter/material.dart';
import 'package:app_2i2i/app/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_2i2i/services/firestore_database.dart';
import 'package:app_2i2i/app/home/models/user.dart';

class SetupUserViewModel with ChangeNotifier {
  SetupUserViewModel(
      {required this.auth, required this.database, required this.algorand}) {
    log('SignUpViewModel');
  }
  final FirebaseAuth auth;
  final FirestoreDatabase database;
  final AlgorandService algorand;

  bool signUpInProcess = false;
  String message = '';
  bool bioSet = false;
  bool workDone = false;
  String? bio;
  String? uid;
  String name = '';

  void setBio(String _bio) {
    log('SetupUserViewModel - setBio');
    bioSet = _bio.isNotEmpty;
    bio = _bio;
    name = UserModel.nameFromBio(_bio);
    notifyListeners();
  }

  ////////
  Future createAuthAndStartAlgorand() async {
    if (signUpInProcess) return;
    signUpInProcess = true;

    log('SetupUserViewModel - createAuthAndStartAlgorand');

    message = 'creating auth user';
    notifyListeners();
    final userCredentialFuture = auth.signInAnonymously();
    final setupAlgorandAccountFuture = setupAlgorandAccount();

    final futureResults =
        await Future.wait([userCredentialFuture, setupAlgorandAccountFuture]);

    final userCredential = futureResults[0];
    uid = userCredential.user!.uid;
    log('SetupUserViewModel - createAuthAndStartAlgorand - userCredential isNewUser: ${userCredential.additionalUserInfo?.isNewUser}');
    log('SetupUserViewModel - createAuthAndStartAlgorand - userCredential uid: ${userCredential.user?.uid}');

    message = 'done';
    workDone = true;
    notifyListeners();
  }

  Future createDatabaseUser() async {
    message = 'creating database user';
    notifyListeners();
    final user = UserModel(id: uid!, bio: bio!);
    await database.setUser(user);
    // await Future.delayed(Duration(seconds: FAKE_WAIT));
    log('SetupUserViewModel - createDatabaseUser - setUser');
    final userPrivate = UserModelPrivate();
    await database.setUserPrivate(uid!, userPrivate);
    // await Future.delayed(Duration(seconds: FAKE_WAIT));
    log('SetupUserViewModel - createDatabaseUser - setUserPrivate');
  }

  // KEEP account in local scope
  Future setupAlgorandAccount() async {
    message = 'creating algorand account';
    notifyListeners();
    final account = await algorand.createAccount();
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - account=${account.publicAddress}');

    message = 'saving account locally in secure storage';
    notifyListeners();
    await algorand.saveAccountLocally(account);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.saveAccountLocally');

    // TODO uncomment try
    // try {
    message = 'gifting your some (test) ALGOs and TESTCOINs';
    notifyListeners();
    // await algorand.giftALGO(account.publicAddress);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.giftALGO');
    // DEBUG - off for faster debugging
    // final optInToStateAppFuture =
    //     algorand.optInToApp(account: account, appId: AlgorandService.SYSTEM_ID[algorand.net]!);
    // final optInAndGiftASAFuture = algorand
    //     .optInToASA(account: account, assetId: AlgorandService.NOVALUE_ASSET_ID[algorand.net]!)
    //     .then((_) => algorand.giftASA(account.publicAddress,
    //         waitForConfirmation: false));
    // final algorandResults =
    //     await Future.wait([optInToStateAppFuture, optInAndGiftASAFuture]);
    // final optInStateTxId = algorandResults[0];
    // log('SetupUserViewModel - setupAlgorandAccount - Future.wait - algorandResults=$algorandResults - optInStateTxId=$optInStateTxId');
    // await algorand.waitForConfirmation(txId: optInStateTxId);
    // log('SetupUserViewModel - setupAlgorandAccount - algorand.waitForConfirmation - optInStateTxId=$optInStateTxId');
    // } catch (e) {
    //   // TODO - we can continue the app; this was a luxury
    // }
  }
}
