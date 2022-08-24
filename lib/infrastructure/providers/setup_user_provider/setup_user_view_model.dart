import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:app_2i2i/ui/screens/sign_in/choose_account_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_admin/firebase_admin.dart' as admin;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';

import '../../../ui/screens/home/bottom_nav_bar.dart';
import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/accounts/local_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../../data_access_layer/services/logging.dart';
import '../../models/social_links_model.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';

class SetupUserViewModel with ChangeNotifier {
  SetupUserViewModel(
      {required this.auth,
      required this.database,
      required this.algorandLib,
      required this.accountService,
      required this.googleSignIn,
      required this.algorand,
      required this.functions,
      required this.storage});

  final FirebaseAuth auth;
  final FirestoreDatabase database;
  final SecureStorage storage;
  final FirebaseFunctions functions;
  final AccountService accountService;
  final AlgorandLib algorandLib;
  final GoogleSignIn googleSignIn;
  final AlgorandService algorand;

  UserModel? userInfoModel;
  SocialLinksModel? socialLinksModel;

  List<String> authList = [];

  Future<UserModel?> getUserInfoModel(String uid) async {
    userInfoModel = await database.getUser(uid);
    return userInfoModel;
  }

  Future updateFirebaseMessagingToken(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return messaging.getToken(vapidKey: dotenv.env['TOKEN_KEY'].toString()).then((String? token) {
      if (token is String) return database.updateToken(uid, token);
    });
    // log(X + 'token=$token');
    // ref.read(firebaseMessagingTokenProvider.notifier).state = token ?? '';
  }

  Future signInProcess(String uid, {SocialLinksModel? socialLinkModel}) async {
    userInfoModel = await getUserInfoModel(uid);
    if (socialLinkModel is SocialLinksModel) {
      userInfoModel?.socialLinks.add(socialLinkModel);
      if ((userInfoModel?.name ?? "").isNotEmpty) {
        await database.updateUser(userInfoModel!);
      }
    } else {
      userInfoModel?.socialLinks = [];
    }
    final f2 = updateFirebaseMessagingToken(uid);
    // final f3 = setupAlgorandAccount(uid);
    final f4 = updateDeviceInfo(uid);
    return Future.wait([f2, /* f3,*/ f4]);
  }

  Future<void> signInAnonymously() async {
    UserCredential firebaseUser = await FirebaseAuth.instance.signInAnonymously();
    String? uid = firebaseUser.user?.uid;
    if (uid is String) await signInProcess(uid, socialLinkModel: null);
  }

  Future<List<String>> getAuthList() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    List<UserInfo> userAuthList = firebaseUser?.providerData ?? [];
    authList = [];
    if (userAuthList.isNotEmpty) {
      userAuthList.forEach((element) {
        authList.add(element.providerId);
      });
    }
    List<String> list = userInfoModel?.socialLinks.map((e) => e.accountName??'').toList()??[];
    authList.addAll(list);
    Future.delayed(Duration.zero).then((value) => notifyListeners());
    return authList;
  }

  Future<void> signInWithGoogle(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      User? existingUser;
      UserCredential? firebaseUser;

      if (linkWithCredential) {
        existingUser = FirebaseAuth.instance.currentUser;
      }
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

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
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        await googleSignIn.signOut();
      }
      CustomAlertWidget.showToastMessage(context, '${e.message}');
      throw e;
    }
  }

  Future<void> unLink(BuildContext context) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      User? existingUser = await firebaseUser!.unlink('google.com');
      log("$existingUser");
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.showToastMessage(context, 'Error occurred using Google Sign In. Try again.');
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
        socialLinksModel?.userName = firebaseUser.user?.displayName ?? '';
        socialLinksModel?.userEmail = firebaseUser.user?.email ?? '';
        await signInProcess(uid, socialLinkModel: socialLinksModel);
      }
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.showToastMessage(context, "${e.message}");
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

        try {
          authResult = await twitterLogin.login();
          print(authResult.status);
          if (authResult.authToken is String && authResult.authTokenSecret is String) {
            twitterAuthCredential = TwitterAuthProvider.credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);}
        } catch (e) {
          print(e);
        }
      }
      if (linkWithCredential && existingUser != null) {
        if (kIsWeb) {
          firebaseUser = await existingUser.linkWithPopup(TwitterAuthProvider());
        } else if (twitterAuthCredential != null) {
          firebaseUser = await existingUser.linkWithCredential(twitterAuthCredential);
        }
      } else {
        if (kIsWeb) {
          firebaseUser = await FirebaseAuth.instance.signInWithPopup(TwitterAuthProvider());
        } else if (twitterAuthCredential != null) {
          firebaseUser = await auth.signInWithCredential(twitterAuthCredential);
        }
      }

      if (authResult?.user != null) {
        socialLinksModel = SocialLinksModel(
            userName: authResult?.user?.name ?? '',  accountName: 'Twitter', userId: "${authResult?.user?.id ?? ""}");}

      String? uid = firebaseUser?.user?.uid;
      if (uid is String) {
        await signInProcess(uid, socialLinkModel: socialLinksModel);
      }
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.showToastMessage(context, "${e.message}");
      throw e;
    }
  }

  Future<void> signInWithWalletConnect(context, address, account, myAccountPageViewModel) async {
    String? uid;

    try {
      final app = admin.FirebaseAdmin.instance.app();
      if (app is admin.App) {
        CustomDialogs.loader(true, context, rootNavigator: true);
        var result = await app.auth().createCustomToken(address);
        List ids = await database.checkAddressAvailable(address);
        if (ids.length > 1) {
          final id = await showDialog(
            context: context,
            builder: (context) => ChooseAccountDialog(
              userIds: ids,
              onSelectId: (String value) {
                Navigator.of(context).pop(value);
              },
            ),
            // barrierDismissible: false,
          );
          if (id is String) {
            uid = id;
          }
        }
        else if (ids.isNotEmpty) {
          uid = ids.first;
        }
        else {
          uid = address;
        }

        if (uid?.isNotEmpty ?? false) {
          result = await app.auth().createCustomToken(uid!);
          var firebaseUser = await auth.signInWithCustomToken(result);
          CustomDialogs.loader(false, context, rootNavigator: true);
          if (firebaseUser.user is User) {
            String? uid = firebaseUser.user?.uid;
            if (uid is String) {
              socialLinksModel = SocialLinksModel(accountName: 'WalletConnect',userId: uid);
              await signInProcess(uid, socialLinkModel: socialLinksModel).then((_) async{
                await account.save().then((_) {
                  myAccountPageViewModel.updateDBWithNewAccount(account.address, type: 'WC',userId:uid).then((_) {
                    myAccountPageViewModel.updateAccounts().then((_) {
                      account.setMainAccount();
                    });
                  });
                });
              });
            }
          }
        }
        else{
          CustomDialogs.loader(false, context, rootNavigator: true);
        }

      }
    } on FirebaseAuthException catch (e) {
      CustomDialogs.showToastMessage(context, "${e.message}");
      CustomDialogs.loader(false, context, rootNavigator: true);
      throw e;
    }
  }

  Future<void> signInWithInstagram(context, id,[bool forLink = false]) async {
    String? uid;
    socialLinksModel = SocialLinksModel(accountName: 'Instagram', userId: id);

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    try {
      if(userId is String && forLink){
        await signInProcess(userId, socialLinkModel: socialLinksModel);
      }else{
        final app = admin.FirebaseAdmin.instance.app();
        if (app is admin.App) {
          CustomDialogs.loader(true, context, rootNavigator: true);
          var result = await app.auth().createCustomToken(id);

          List ids = await database.checkInstaUserAvailable(socialLinksModel!);
          if (ids.length > 1) {
            final id = await showDialog(
              context: context,
              useRootNavigator: true,
              builder: (context) => ChooseAccountDialog(
                userIds: ids,
                onSelectId: (String value) {
                  Navigator.of(context,rootNavigator: true).pop(value);
                },
              ),
              // barrierDismissible: false,
            );
            if (id is String) {
              uid = id;
            }
          }
          else if (ids.isNotEmpty) {
            uid = ids.first;
          }
          else {
            uid = id;
          }

          if (uid?.isNotEmpty ?? false) {
            result = await app.auth().createCustomToken(uid!);
            var firebaseUser = await auth.signInWithCustomToken(result);
            CustomDialogs.loader(false, context, rootNavigator: true);
            if (firebaseUser.user is User) {
              String? uid = firebaseUser.user?.uid;
              if (uid is String) {
                await signInProcess(id, socialLinkModel: socialLinksModel);
              }
            }
          }
          else{
            CustomDialogs.loader(false, context, rootNavigator: true);
          }
        }
      }

    } on FirebaseAuthException catch (e) {
      CustomDialogs.showToastMessage(context, "${e.message}");
      CustomDialogs.loader(false, context, rootNavigator: true);
      throw e;
    }
  }

  Future<void> signOutFromAuth() async {
    socialLinksModel = null;
    await googleSignIn.signOut();
    await auth.signOut();
  }

  Future<void> deleteUser({required BuildContext mainContext, required String title, required String description}) async {
    await CustomAlertWidget.confirmDialog(
      mainContext,
      title: title,
      description: description,
      onPressed: () async {
        try {
          CustomAlertWidget.loader(true, mainContext);
          final HttpsCallable deleteUser = functions.httpsCallable('deleteMe');
          HttpsCallableResult result = await deleteUser.call();
          if (result.data is List) {
            List dataList = result.data;
            int mapIndex = dataList.indexWhere((element) => element.containsKey('successCount'));
            if (mapIndex > -1) {
              Map dataMap = dataList[mapIndex];
              if ((dataMap['successCount'] ?? 0) > 0) {
                await Future.delayed(Duration(milliseconds: 300));
                await signOutFromAuth();
                currentIndex.value = 1;
                mainContext.go(Routes.myUser);
                CustomAlertWidget.loader(false, mainContext);
              }
            }
          }
        } catch (e) {
          CustomAlertWidget.loader(false, mainContext);
          print(e);
        }
      },
      yesButtonTextStyle: TextStyle(color: Theme.of(mainContext).errorColor),
      noButtonTextStyle: TextStyle(color: Theme.of(mainContext).colorScheme.secondary),
    );
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
    if (0 < await accountService.getNumAccounts()) return;
    final LocalAccount account = await LocalAccount.create(algorandLib: algorandLib, storage: storage, accountService: accountService);
    await database.addAlgorandAccount(uid, account.address, 'LOCAL');
    await accountService.setMainAccount(account.address);
    log('SetupUserViewModel - setupAlgorandAccount - algorand.createAccount - my_account_provider=${account.address}');

    // TODO uncomment try
    // DEBUG - off for faster debugging
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
