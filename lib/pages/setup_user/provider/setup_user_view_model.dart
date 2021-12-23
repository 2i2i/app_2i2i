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
  SetupUserViewModel(
      {required this.auth,
      required this.database,
      required this.algorandLib,
      required this.accountService,
      required this.algorand,
      required this.storage}) {
    database.setTestA();
  }

  final FirebaseAuth auth;
  final FirestoreDatabase database;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;
  final AlgorandService algorand;

  bool signUpInProcess = false;
  bool bioSet = false;
  bool nameSet = false;
  String? bio;
  String? uid;
  String? name;
  String? deviceToken;

  void setBio(String _bio) {
    log('SetupUserViewModel - setBio');
    bioSet = _bio.isNotEmpty;
    bio = _bio;
    notifyListeners();
  }

  void setName(String _name) {
    log('SetupUserViewModel - setName');
    nameSet = _name.isNotEmpty;
    name = _name;
    notifyListeners();
  }

  ////////
  Future createAuthAndStartAlgoRand({String? firebaseUserId}) async {
    if (signUpInProcess) return;
    signUpInProcess = true;
    notifyListeners();

    uid = firebaseUserId;
    if (firebaseUserId == null) {
      final userCredential = await auth.signInAnonymously();
      uid = userCredential.user!.uid;
    }
    await setupAlgorandAccount();
    signUpInProcess = false;

    notifyListeners();
  }


  Future updateBio() async {
    log('SetupUserViewModel - createDatabaseUser');
    notifyListeners();
    // log('SetupUserViewModel - createDatabaseUser - notifyListeners - uid=$uid - name=$name - bio=$bio');
    final tags = UserModel.tagsFromBio(bio!);
    // log('SetupUserViewModel - createDatabaseUser - tags=$tags');
    await database.updateUserNameAndBio(
        uid!, name!, bio!, [name!, ...tags]);
    // log('SetupUserViewModel - createDatabaseUser - UserModel');
  }

  // KEEP my_account in local scope
  Future setupAlgorandAccount() async {
    notifyListeners();
    if (0 < await accountService.getNumAccounts()) return;
    final account = await LocalAccount.create(
        algorandLib: algorandLib,
        storage: storage,
        accountService: accountService);
    await accountService.setMainAcccount(account.address);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - my_account=${account.address}');

    // TODO uncomment try
    // DEBUG - off for faster debugging
    notifyListeners();
    // await algorand.giftALGO(my_account);
    // log('SetupUserViewModel - setupAlgorandAccount - algorand.giftALGO');
    // final optInToASAFuture = my_account.optInToASA(
    //     assetId: AlgorandService.NOVALUE_ASSET_ID[AlgorandNet.testnet]!,
    //     net: AlgorandNet.testnet);
    // final optInStateTxId = await optInToASAFuture
    //     .then((value) => algorand.giftASA(my_account, waitForConfirmation: false));
    // log('SetupUserViewModel - setupAlgorandAccount - Future.wait - optInStateTxId=$optInStateTxId');
    // await algorand.waitForConfirmation(
    //     txId: optInStateTxId, net: AlgorandNet.testnet);
    // log('SetupUserViewModel - setupAlgorandAccount - algorand.waitForConfirmation - optInStateTxId=$optInStateTxId');
  }
}
