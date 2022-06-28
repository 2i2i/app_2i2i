import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/accounts/local_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../../data_access_layer/services/logging.dart';
import '../../models/social_links_model.dart';
import '../../models/user_model.dart';

class SetupUserViewModel with ChangeNotifier {
  SetupUserViewModel(
      {required this.auth,
      required this.database,
      required this.algorandLib,
      required this.accountService,
      required this.googleSignIn,
      required this.algorand,
      required this.storage});

  final FirebaseAuth auth;
  final FirestoreDatabase database;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;
  final GoogleSignIn googleSignIn;
  final AlgorandService algorand;

  bool signUpInProcess = false;

  UserModel? userInfoModel;

  SocialLinksModel? socialLinksModel;

  List<String> authList = [];

  Future<UserModel?> getUserInfoModel(String uid) async {
    userInfoModel = await database.getUser(uid);
    notifyListeners();
    return userInfoModel;
  }

  Future startAlgoRand(String uid) async {
    if (signUpInProcess) return;
    signUpInProcess = true;
    notifyListeners();

    await setupAlgorandAccount(uid);
    signUpInProcess = false;

    notifyListeners();
  }

  Future updateFirebaseMessagingToken(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return messaging
        .getToken(
      vapidKey: dotenv.env['TOKEN_KEY'].toString(),
    )
        .then((String? token) {
      if (token is String) return database.updateToken(uid, token);
    });
    // log(X + 'token=$token');
    // ref.read(firebaseMessagingTokenProvider.notifier).state = token ?? '';
  }

  Future signInProcess(String uid, {SocialLinksModel? socialLinkModel}) async {
    if (socialLinkModel is SocialLinksModel) {
      userInfoModel?.socialLinks.add(socialLinkModel);
      notifyListeners();
      if ((userInfoModel?.name ?? "").isNotEmpty) {
        await database.updateUser(userInfoModel!);
      }
    }
    final f1 = getUserInfoModel(uid);
    final f2 = updateFirebaseMessagingToken(uid);
    final f3 = startAlgoRand(uid);
    final f4 = updateDeviceInfo(uid);
    return Future.wait([f1, f2, f3, f4]);
  }

  Future<void> signInAnonymously() async {
    UserCredential firebaseUser = await FirebaseAuth.instance.signInAnonymously();
    String? uid = firebaseUser.user?.uid;
    if (uid is String) await signInProcess(uid);
  }

  Future<void> getAuthList() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    List<UserInfo> userAuthList = firebaseUser?.providerData ?? [];
    authList = [];
    if (userAuthList.isNotEmpty) {
      userAuthList.forEach((element) {
        authList.add(element.providerId);
      });
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      User? existingUser;
      UserCredential? firebaseUser;

      if (linkWithCredential) {
        existingUser = FirebaseAuth.instance.currentUser;
      }
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      if (linkWithCredential && existingUser != null) {
        firebaseUser = await existingUser.linkWithCredential(credential);
      } else {
        firebaseUser = await auth.signInWithCredential(credential);
      }

      socialLinksModel = SocialLinksModel(
          userName: googleSignInAccount.email,
          userEmail: googleSignInAccount.email,
          accountName: 'Google',
          userId: googleSignInAccount.id);

      String? uid = firebaseUser.user?.uid;
      if (uid is String) await signInProcess(uid, socialLinkModel: socialLinksModel);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        await googleSignIn.signOut();
      }
      CustomDialogs.showToastMessage(context, '${e.message}');
      throw e;
    }
  }

  Future<void> unLink(BuildContext context) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      User? existingUser = await firebaseUser!.unlink('google.com');
      log("$existingUser");
    } on FirebaseAuthException catch (e) {
      CustomDialogs.showToastMessage(context, 'Error occurred using Google Sign In. Try again.');
      throw e;
    }
  }

  Future<void> signInWithApple(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      User? existingUser;
      UserCredential? firebaseUser;
      if (linkWithCredential) {
        existingUser = FirebaseAuth.instance.currentUser;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final rawNonce = generateNonce();
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
      );

      if (linkWithCredential && existingUser != null) {
        firebaseUser = await existingUser.linkWithCredential(oauthCredential);
      } else {
        firebaseUser = await auth.signInWithCredential(oauthCredential);
      }

      socialLinksModel = SocialLinksModel(
          userName: credential.email,
          userEmail: credential.email,
          accountName: 'Apple',
          userId: credential.userIdentifier);

      String? uid = firebaseUser.user?.uid;
      if (uid is String) {
        socialLinksModel!.userName = firebaseUser.user?.displayName ?? '';
        socialLinksModel!.userEmail = firebaseUser.user?.email ?? '';
        await signInProcess(uid, socialLinkModel: socialLinksModel);
      }
    } on FirebaseAuthException catch (e) {
      CustomDialogs.showToastMessage(context, "${e.message}");
      throw e;
    }
  }

  Future<void> signInWithTwitter(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      User? existingUser;
      UserCredential? firebaseUser;
      AuthCredential? twitterAuthCredential;
      AuthResult? authResult;
      if (linkWithCredential) {
        existingUser = FirebaseAuth.instance.currentUser;
      }

      if (!kIsWeb) {
        final twitterLogin = TwitterLogin(
          apiKey: dotenv.env['TWITTER_API_key'].toString(),
          apiSecretKey: dotenv.env['TWITTER_API_SECRET_key'].toString(),
          redirectURI: "test://twoitwoi.com",
        );

        authResult = await twitterLogin.login();

        twitterAuthCredential =
            TwitterAuthProvider.credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);
      }
      if (linkWithCredential && existingUser != null) {
        if (kIsWeb) {
          firebaseUser = await existingUser.linkWithPopup(TwitterAuthProvider());
        } else {
          firebaseUser = await existingUser.linkWithCredential(twitterAuthCredential!);
        }
      } else {
        if (kIsWeb) {
          firebaseUser = await FirebaseAuth.instance.signInWithPopup(TwitterAuthProvider());
        } else {
          firebaseUser = await auth.signInWithCredential(twitterAuthCredential!);
        }
      }
      if (authResult?.user != null)
        socialLinksModel = SocialLinksModel(
            userName: authResult?.user?.name ?? '',
            accountName: 'Twitter',
            userId: "${authResult?.user?.id ?? ""}");

      String? uid = firebaseUser.user?.uid;
      if (uid is String) await signInProcess(uid, socialLinkModel: socialLinksModel);
    } on FirebaseAuthException catch (e) {
      CustomDialogs.showToastMessage(context, "${e.message}");
      throw e;
    }
  }

  Future<void> signOutFromAuth() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }

  Future updateDeviceInfo(String uid) async {
    if (!kIsWeb) {
      // TODO no device info for web?
      return;
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    final Map<String, String?> data = {
      'web.userAgent': webBrowserInfo.userAgent,
      'web.browserName': webBrowserInfo.browserName.name,
    };
    return database.updateDeviceInfo(uid, data);
  }

  // KEEP my_account_provider in local scope
  Future setupAlgorandAccount(String uid) async {
    notifyListeners();
    if (0 < await accountService.getNumAccounts()) return;
    final LocalAccount account =
        await LocalAccount.create(algorandLib: algorandLib, storage: storage, accountService: accountService);
    await database.addAlgorandAccount(uid, account.address, 'LOCAL');
    await accountService.setMainAcccount(account.address);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - my_account_provider=${account.address}');

    // TODO uncomment try
    // DEBUG - off for faster debugging
    notifyListeners();
    // final HttpsCallable giftALGO = FirebaseFunctions.instance.httpsCallable('giftALGO');

    if (AppConfig().ALGORAND_NET == AlgorandNet.testnet) {
      // await giftALGO({'account': account.address});
      return account.updateBalances(net: AlgorandNet.testnet);
    }
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

  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
