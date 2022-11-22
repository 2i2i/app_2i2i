import 'dart:math';

import 'package:app_2i2i/infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/screens/sign_in/choose_account_dialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../../data_access_layer/services/logging.dart';
import '../../models/social_links_model.dart';
import '../../models/user_model.dart';
import '../my_account_provider/my_account_page_view_model.dart';

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

  bool isLogged = false;

  List<String> authList = [];

  void setLoginValue(bool value) {
    isLogged = value;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    isLogged = await storage.read('isLogged') == "1";
    // notifyListeners();
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
    List<String> list = userInfoModel?.socialLinks.map((e) => e.accountName ?? '').toList() ?? [];
    authList.addAll(list);
    Future.delayed(Duration.zero).then((value) => notifyListeners());
    return authList;
  }

  Future<void> signInWithGoogle(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      CustomAlertWidget.loader(true, context);
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

        socialLinksModel = SocialLinksModel(
            userName: googleSignInAccount.displayName, userEmail: googleSignInAccount.email, accountName: 'Google', userId: googleSignInAccount.id);

        String? uid = firebaseUser.user?.uid;
        if (uid is String) await signInProcess(uid, socialLinkModel: socialLinksModel);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        await googleSignIn.signOut();
      }
      CustomAlertWidget.showToastMessage(context, '${e.message}');
      throw e;
    } catch (e) {
      print("Application Error == > $e");
    }
    CustomAlertWidget.loader(false, context);
  }

  Future<void> signInWithApple(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      CustomAlertWidget.loader(true, context, rootNavigator: true);
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
      CustomAlertWidget.loader(false, context, rootNavigator: true);
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.loader(false, context, rootNavigator: true);
      CustomAlertWidget.showToastMessage(context, "${e.message}");
      throw e;
    } catch (e) {
      CustomAlertWidget.loader(false, context, rootNavigator: true);
      throw e;
    }
  }

  Future<void> signInWithTwitter(BuildContext context, {bool linkWithCredential = false}) async {
    try {
      CustomAlertWidget.loader(true, context);
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
        if (authResult.status == TwitterLoginStatus.loggedIn) {
          if (authResult.authToken is String && authResult.authTokenSecret is String) {
            twitterAuthCredential = TwitterAuthProvider.credential(accessToken: authResult.authToken!, secret: authResult.authTokenSecret!);
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

          if (authResult.user != null) {
            socialLinksModel = SocialLinksModel(userName: authResult.user?.name ?? '', accountName: 'Twitter', userId: "${authResult.user?.id ?? ""}");
          }

          String? uid = firebaseUser?.user?.uid;
          if (uid is String) {
            await signInProcess(uid, socialLinkModel: socialLinksModel);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.showToastMessage(context, "${e.message}");
      throw e;
    }
    CustomAlertWidget.loader(false, context);
  }

  Future<void> signInAnonymously(BuildContext context) async {
    CustomAlertWidget.loader(true, context);
    UserCredential firebaseUser = await FirebaseAuth.instance.signInAnonymously();
    String? uid = firebaseUser.user?.uid;
    if (uid is String) await signInProcess(uid, socialLinkModel: null);
    CustomAlertWidget.loader(false, context);
  }

  Future<UserModel?> getUserInfoModel(String uid) async {
    userInfoModel = await database.getUser(uid);
    return userInfoModel;
  }

  Future updateFirebaseMessagingToken(String uid) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return messaging
        .getToken(
            // vapidKey: dotenv.env['TOKEN_KEY'].toString()
            )
        .then((String? token) {
      if (token is String) return database.updateToken(uid, token);
    });
  }

  Future signInProcess(String uid, {SocialLinksModel? socialLinkModel}) async {
    userInfoModel = await getUserInfoModel(uid);
    if (userInfoModel == null) {
      await database.createUser(uid);
    } else if (userInfoModel!.url?.isEmpty ?? true) {
      userInfoModel!.url = await createDeepLinkUrl(uid);
      await database.updateUser(userInfoModel!);
    }
    if (socialLinkModel is SocialLinksModel) {
      userInfoModel?.socialLinks.add(socialLinkModel);
      if ((userInfoModel?.name ?? "").isNotEmpty) {
        await database.updateUser(userInfoModel!);
      }
    } else {
      userInfoModel?.socialLinks = [];
    }
    await updateFirebaseMessagingToken(uid);
    await updateDeviceInfo(uid);
    isLogged = true;
    storage.write('isLogged', "1");
    notifyListeners();
  }

  Future<void> signInWithWalletConnect(
    BuildContext context,
    String address,
    WalletConnectAccount account,
    String sessionId,
    MyAccountPageViewModel myAccountPageViewModel,
  ) async {
    String? uid;

    try {
      CustomAlertWidget.loader(true, context, rootNavigator: true);
      var result = await getToken(address);
      if (result.isNotEmpty) {
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
        } else if (ids.isNotEmpty) {
          uid = ids.first;
        } else {
          uid = address;
          //For Don't show mark
          // socialLinksModel = SocialLinksModel(accountName: 'WalletConnect', userId: uid);
        }

        if (uid?.isNotEmpty ?? false) {
          result = await getToken(uid!);
          var firebaseUser = await auth.signInWithCustomToken(result);
          CustomAlertWidget.loader(false, context, rootNavigator: true);
          if (firebaseUser.user is User) {
            String? uid = firebaseUser.user?.uid;
            if (uid is String) {
              await signInProcess(uid, socialLinkModel: socialLinksModel).then((_) async {
                await account.save(sessionId).then((_) {
                  myAccountPageViewModel.updateDBWithNewAccount(account.address, type: 'WC', userId: uid).then((_) {
                    myAccountPageViewModel.updateAccounts(notify: false).then((_) {
                      account.setMainAccount();
                    });
                  });
                });
              });
            }
          }
        } else {
          CustomAlertWidget.loader(false, context, rootNavigator: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.showToastMessage(context, "${e.message}");
      CustomAlertWidget.loader(false, context, rootNavigator: true);
      throw e;
    } catch (exeption) {
      print(exeption);
      CustomAlertWidget.loader(false, context, rootNavigator: true);
    }
  }

  Future<String> getToken(String address) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'createToken',
    );
    final result = await callable.call({'token': address});
    if (result.data is Map) {
      bool isFail = result.data['result']?.toString().contains('Fail') ?? true;
      if (!isFail) {
        return result.data['result'];
      }
    }
    return '';
  }

  Future<void> signInWithInstagram(context, id, [bool forLink = false]) async {
    String? uid;
    socialLinksModel = SocialLinksModel(accountName: 'Instagram', userId: id);

    User? user = FirebaseAuth.instance.currentUser;
    try {
      if ((user?.uid is String) && forLink) {
        socialLinksModel = SocialLinksModel(accountName: 'Instagram', userId: id, userName: user!.displayName);
        await signInProcess(user.uid, socialLinkModel: socialLinksModel);
      } else {
        CustomAlertWidget.loader(true, context, rootNavigator: true);
        var result = await getToken(id);
        if (result.isNotEmpty) {
          // var firebaseUser = await auth.signInWithCustomToken(result);
          List ids = await database.checkInstaUserAvailable(socialLinksModel!);
          if (ids.length > 1) {
            final id = await showDialog(
              context: context,
              useRootNavigator: true,
              builder: (context) => ChooseAccountDialog(
                userIds: ids,
                onSelectId: (String value) {
                  Navigator.of(context, rootNavigator: true).pop(value);
                },
              ),
              // barrierDismissible: false,
            );
            if (id is String) {
              uid = id;
            }
          } else if (ids.isNotEmpty) {
            uid = ids.first;
          } else {
            uid = id;
          }

          if (uid?.isNotEmpty ?? false) {
            // await FirebaseAuth.instance.signOut();
            result = await getToken(uid!);
            var firebaseUser = await auth.signInWithCustomToken(result);
            CustomAlertWidget.loader(false, context, rootNavigator: true);
            if (firebaseUser.user is User) {
              String? uid = firebaseUser.user?.uid;
              if (uid is String) {
                await signInProcess(id, socialLinkModel: socialLinksModel);
              }
            }
          } else {
            CustomAlertWidget.loader(false, context, rootNavigator: true);
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      CustomAlertWidget.showToastMessage(context, "${e.message}");
      CustomAlertWidget.loader(false, context, rootNavigator: true);
      throw e;
    }
  }

  Future<void> signOutFromAuth() async {
    socialLinksModel = null;
    isLogged = false;
    if (auth.currentUser?.uid.isNotEmpty ?? false) {
      await FirestoreDatabase().removeToken(auth.currentUser!.uid);
    }
    await googleSignIn.signOut();
    await auth.signOut();
    await storage.clear();
    notifyListeners();
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
                CustomAlertWidget.loader(false, mainContext);
                await signOutFromAuth();
              }
            }
          }
        } catch (e) {
          CustomAlertWidget.loader(false, mainContext);
          throw e;
        }
      },
      yesButtonTextStyle: TextStyle(color: Theme.of(mainContext).errorColor),
      noButtonTextStyle: TextStyle(color: Theme.of(mainContext).colorScheme.secondary),
    );
  }

  Future<String> createDeepLinkUrl(String uid) async {
    try {
      final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
      final link = dotenv.env['DYNAMIC_LINK_HOST'].toString();
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: link,
        link: Uri.parse('https://about.2i2i.app?uid=$uid'),
        androidParameters: AndroidParameters(
          packageName: 'app.i2i2',
          fallbackUrl: Uri.parse('https://about.2i2i.app'),
        ),
        iosParameters: IOSParameters(
            bundleId: 'app.2i2i',
            fallbackUrl: Uri.parse('https://about.2i2i.app'),
            ipadFallbackUrl: Uri.parse('https://about.2i2i.app'),
            ipadBundleId: 'app.2i2i',
            appStoreId: '1609689141'),
        navigationInfoParameters: const NavigationInfoParameters(
          forcedRedirectEnabled: false,
        ),
      );
      final shortUri = await dynamicLinks.buildShortLink(parameters);
      if (shortUri.shortUrl.toString().isNotEmpty) {
        FirebaseAuth.instance.currentUser!.updatePhotoURL(shortUri.shortUrl.toString());
      }
      return shortUri.shortUrl.toString();
    } catch (e) {
      print(e);
    }
    return "";
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

  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }
}
