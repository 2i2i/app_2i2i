import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/accounts/local_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../../data_access_layer/services/logging.dart';

class SetupUserViewModel with ChangeNotifier {
  SetupUserViewModel(
      {required this.auth,
      required this.database,
      required this.algorandLib,
      required this.accountService,
      required this.algorand,
      required this.storage});
  // {
  // database.setTestA();
  // }

  final FirebaseAuth auth;
  final FirestoreDatabase database;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;
  final AlgorandService algorand;

  bool signUpInProcess = false;

  ////////
  Future createAuthAndStartAlgoRand({String? firebaseUserId}) async {
    if (signUpInProcess) return;
    signUpInProcess = true;
    notifyListeners();

    if (firebaseUserId == null) {
      await auth.signInAnonymously();
    }
    await setupAlgorandAccount();
    signUpInProcess = false;

    notifyListeners();
  }

  Future signInAnonymously() async {
    UserCredential firebaseUser =
        await FirebaseAuth.instance.signInAnonymously();
    String? userId = firebaseUser.user?.uid;
    if (userId is String) {
      createAuthAndStartAlgoRand(firebaseUserId: userId);
    }
  }

  // KEEP my_account_provider in local scope
  Future setupAlgorandAccount() async {
    notifyListeners();
    if (0 < await accountService.getNumAccounts()) return;
    final account = await LocalAccount.create(
        algorandLib: algorandLib,
        storage: storage,
        accountService: accountService);
    await accountService.setMainAcccount(account.address);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - my_account_provider=${account.address}');

    // TODO uncomment try
    // DEBUG - off for faster debugging
    notifyListeners();
    // await algorand.giftALGO(account);
    // await account.updateBalances();
    // log('SetupUserViewModel - setupAlgorandAccount - algorand.giftALGO');
    // final optInToASAFuture = my_account_provider.optInToASA(
    //     assetId: AlgorandService.NOVALUE_ASSET_ID[AlgorandNet.testnet]!,
    //     net: AlgorandNet.testnet);
    // final optInStateTxId = await optInToASAFuture
    //     .then((value) => algorand.giftASA(my_account_provider, waitForConfirmation: false));
    // log('SetupUserViewModel - setupAlgorandAccount - Future.wait - optInStateTxId=$optInStateTxId');
    // await algorand.waitForConfirmation(
    //     txId: optInStateTxId, net: AlgorandNet.testnet);
    // log('SetupUserViewModel - setupAlgorandAccount - algorand.waitForConfirmation - optInStateTxId=$optInStateTxId');
  }
}
