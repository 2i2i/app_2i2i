import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetupUserViewModel with ChangeNotifier {
  SetupUserViewModel({required this.auth,
      required this.database,
      required this.algorandLib,
      required this.accountService,
      required this.algorand,
      required this.storage}) {
    log('SignUpViewModel');
    // createAuthAndStartAlgorand();
  }

  final FirebaseAuth auth;
  final FirestoreDatabase database;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;
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
    try {
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
    } catch (e) {
      print(e);
    }
  }

  // KEEP account in local scope
  Future setupAlgorandAccount() async {
    message = 'creating algorand account';
    notifyListeners();
    if (0 < await accountService.getNumAccounts()) return;
    final account = await LocalAccount.create(
        algorandLib: algorandLib,
        storage: storage,
        accountService: accountService);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - account=${account.address}');

    // TODO uncomment try
    //   // DEBUG - off for faster debugging
    // try {
    //   message = 'gifting your some (test) ALGOs and TESTCOINs';
    //   notifyListeners();
    //   await algorand.giftALGO(account);
    //   log('SetupUserViewModel - setupAlgorandAccount - algorand.giftALGO');
    //   final optInToStateAppFuture = account.optInToDapp(
    //       dappId: AlgorandService.SYSTEM_ID[AlgorandNet.testnet]!,
    //       net: AlgorandNet.testnet);
    //   final optInToASAFuture = account.optInToASA(
    //       assetId: AlgorandService.NOVALUE_ASSET_ID[AlgorandNet.testnet]!,
    //       net: AlgorandNet.testnet);
    //   final optInAndGiftASAFuture = optInToASAFuture.then(
    //       (value) => algorand.giftASA(account, waitForConfirmation: false));
    //   final algorandResults =
    //       await Future.wait([optInToStateAppFuture, optInAndGiftASAFuture]);
    //   final optInStateTxId = algorandResults[0];
    //   log('SetupUserViewModel - setupAlgorandAccount - Future.wait - algorandResults=$algorandResults - optInStateTxId=$optInStateTxId');
    //   await algorand.waitForConfirmation(
    //       txId: optInStateTxId, net: AlgorandNet.testnet);
    //   log('SetupUserViewModel - setupAlgorandAccount - algorand.waitForConfirmation - optInStateTxId=$optInStateTxId');
    // } catch (e) {
    //   // TODO - we can continue the app; this was a luxury
    // }
  }
}
