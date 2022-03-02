import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

    // if (firebaseUserId == null) {
    //   await auth.signInAnonymously();
    // }
    await setupAlgorandAccount();
    signUpInProcess = false;

    notifyListeners();
  }

  Future updateFirebaseMessagingToken(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    // NotificationSettings settings = await messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );
    // log(X + 'about to get token');
    // log(X + 'settings=$settings');
    return messaging
        .getToken(
      vapidKey:
          'BJAuI8w0710AHhIbunDcq8QnCf1QRKDoWjs5e665AIt5pwPBV1D4GovUBx__W2jbyYWABVSqxhfthjkHY5lCN5g',
    )
        .then((String? token) {
      if (token is String) return database.updateToken(uid, token);
    });
    // log(X + 'token=$token');
    // ref.read(firebaseMessagingTokenProvider.notifier).state = token ?? '';
  }

  Future<String?> signInAnonymously() async {
    UserCredential firebaseUser =
        await FirebaseAuth.instance.signInAnonymously();
    String? userId = firebaseUser.user?.uid;
    if (userId is String) {
      updateFirebaseMessagingToken(userId);
      createAuthAndStartAlgoRand(firebaseUserId: userId);
      updateDeviceInfo(userId);
    }
    return userId;
  }

  Future updateDeviceInfo(String uid) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    final Map<String, String?> data = {
      'web.userAgent': webBrowserInfo.userAgent,
      'web.browserName': webBrowserInfo.browserName.name,
    };
    return database.updateDeviceInfo(uid, data);
  }

  // KEEP my_account_provider in local scope
  Future setupAlgorandAccount() async {
    notifyListeners();
    if (0 < await accountService.getNumAccounts()) return;
    LocalAccount account = await LocalAccount.create(
        algorandLib: algorandLib,
        storage: storage,
        accountService: accountService);
    await accountService.setMainAcccount(account.address);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - my_account_provider=${account.address}');

    // TODO uncomment try
    // DEBUG - off for faster debugging
    notifyListeners();
    final HttpsCallable giftALGO =
        FirebaseFunctions.instance.httpsCallable('giftALGO');
    await giftALGO({'account': account.address});
    return account.updateBalances();
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
