import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_admin/firebase_admin.dart' as admin;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
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

      socialLinksModel =
          SocialLinksModel(userName: googleSignInAccount.email, userEmail: googleSignInAccount.email, accountName: 'Google', userId: googleSignInAccount.id);

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

      socialLinksModel = SocialLinksModel(userName: credential.email, userEmail: credential.email, accountName: 'Apple', userId: credential.userIdentifier);

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

  Future<void> signInWithWalletConnect(BuildContext context, String address) async {
    try {
      admin.App app = await initializeAdmin();
      var result = await app.auth().createCustomToken(address);
      String? uid = await database.checkAddressAvailable(address);
      print(uid);
      if (uid is String) {
        result = await app.auth().createCustomToken(uid);
      }
      var firebaseUser = await auth.signInWithCustomToken(result);
      if (firebaseUser is UserModel) {
        String? uid = firebaseUser.user?.uid;
        if (uid is String) {
          await signInProcess(uid, socialLinkModel: socialLinksModel);
        }
      }
    } on FirebaseAuthException catch (e) {
      CustomDialogs.showToastMessage(context, "${e.message}");
      throw e;
    }
  }

  Future<admin.App> initializeAdmin() async {
    final adminObj = admin.FirebaseAdmin.instance;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/service-account.json');
    final data = jsonEncode({
      "type": "service_account",
      "project_id": "i2i-test",
      "private_key_id": "cbd4940871b30452337d0d74af1eb414c52cd5ed",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCiApuROI4U/fVz\nxrtORfvGXL0iCe9Ne1FGR8YuCBlXlU0xIKzHiDfefaTzVcX5Pc/Qyzag7+6KoiYY\nwRmcJZ0uUAJUEp2NngXo7Z4W3RPTiPCiPlyqLmYbxkJRiPpXHg2lJWi7QWxgXwJx\n0zWwgyAatCEMjYDq+Xow8g7N5Fk0gaKgO7Nx8XaRla8o3kFnX2S/eIKFT/1kkogs\nAipx/Oy31UEGQHN4uQ1z+TGZifzGBy8a8qnF8QIaCCHOaBW0ZW3X9YiuXkSKPdBw\n8sYNLUl2imqWTr7w32XMssq7DWG7OHOyJlgiEKxbm5z3jj32tWdwB/gLjwYTkrl0\nN00cutUjAgMBAAECggEAOarz9R1MdexwEmYLBjGjDVi1eghPRiU/KOUjhf8cBjD+\n6R3YYq36NRhEPtmpPq7h6lBrgZ3mKzLMnMMfepVo/bM9IO//ZQl60Q7D1x+ajxGP\nljDcizc44WoQ8TTw51GrSb2nKgB/s04ecKXd1pbWNqsnmHBGE136QLHo0yEVH7r0\nOasswufzCtq0vMCC/waPel35zoR168RpGwD1u0L0vObI9hGsU/uXsPq2UTE+Qq8K\nv5UQqt1yWRj3P3TXhVyMY9sT71FHmtR+YJvVPhzK7fSt0is+2lmi5jdduJMk3GJo\nyJ0l03CJ687TfolO/421KWkftdcPjFj2VEvuI6HjAQKBgQDSQKju9aP/NMMJ3OzI\nkeGH/2Q93zALBy7YvDyhq55vPGGLX+pXTclFfryh0X+WGJWEymawMO/ZF4juFkFd\nxyK0uycExpmen7lWkfUD6+IFck/6eTYrV3hi8lmy5lDZoqVPwxTIPEgbdJgNNzsY\nsWAo+18Mrf3Ex7kY9eRI4FoOZwKBgQDFQsjGygi/fxYS9EUNYdppNN6rZ0j8BPUw\nrA/MPX6fMhuAqICTJqK/ZFqujaoDFDCNW8lAKswqKsG+g1f7ECgw2w6EflxzkQNS\nTxOkWO51abgzo1FHVbWz15oD/aNGm9TAbtPzGHUEeeGBjthwrJynjUKhR+V5y+6q\n4gfXHaaV5QKBgE+r1NgIGQbh9W5NWyR9sxqXumJ/qnLjW+shGVCh+b1pAgWQaPqA\nLV66MbyX6GL2GeJh2Bu3z4tSEb82i7p/dTVLHfP/VcL3/4FAebnsro8lzAy71b0C\nvkmwUDEseUKfEUlyQPPHdAODYQLRBQHMZQXiixgA7oKctBUzSDgdW8LNAoGBAJ45\nq4KIm+u+rJ4XgSvyyZaJ6fHirxA3idS4rxNMYDyhnJ3eiwN9gh2zCWnqB+zgTPGW\nJh9qNMm98ho2kGO52gMWMtbj5JRuRRPIiiDRlLRpUG9bGN73SQAweEGrOURxyn1w\naGIdw/8LJG8ffU0jp6ReEov7d33yrkYzd8Z86hphAoGBAMlgfrlVObzO+XiVgEar\nvIizlH83sjavS5rxuaFOkIbtRoVb0poPvCKdtOT2DrdGLa4M3+Ub4YiEJCFLlkay\n9foRThjbJYfZPuYrgzIsFtP5FmG+78qyYM24QXNqETcIXjktivvGQetUtr/fr2yW\nDuGWynz0OF4emG2LELVMivi3\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fwd7n@i2i-test.iam.gserviceaccount.com",
      "client_id": "110784426908109511374",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fwd7n%40i2i-test.iam.gserviceaccount.com"
    });
    await file.writeAsString(data);
    final cert = admin.FirebaseAdmin.instance.certFromPath(file.path);
    final app = adminObj.initializeApp(
      admin.AppOptions(
        credential: cert,
      ),
    );
    return app;
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

        twitterAuthCredential = TwitterAuthProvider.credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);
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
            userName: authResult?.user?.name ?? '', userEmail: authResult?.user?.email ?? '', accountName: 'Twitter', userId: "${authResult?.user?.id ?? ""}");

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
    final LocalAccount account = await LocalAccount.create(algorandLib: algorandLib, storage: storage, accountService: accountService);
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
