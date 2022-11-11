import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/instagram_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/instagram_service.dart';
import 'package:app_2i2i/infrastructure/providers/setup_user_provider/setup_user_view_model.dart';
import 'package:app_2i2i/ui/screens/instagram_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom.dart';
import '../app/no_internet_screen.dart';
import '../app/wait_page.dart';
import '../home/bottom_nav_bar.dart';

class SignInPage extends ConsumerStatefulWidget {
  final WidgetBuilder homePageBuilder;

  SignInPage({required this.homePageBuilder});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  // String _displayUri = ''; // never used
  ValueNotifier<bool> isDialogOpen = ValueNotifier(false);

  InstagramService instagram = InstagramService();
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    ref.read(setupUserViewModelProvider).checkLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (uid.isNotEmpty) {
        return await FirebaseMessaging.instance
            .getToken(
          // vapidKey: dotenv.env['TOKEN_KEY'].toString(),
        )
            .then((String? token) {
          if (token is String) return FirestoreDatabase().updateToken(uid, token);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = ref.watch(setupUserViewModelProvider);
    final numMeetingsAsyncValue = ref.watch(numMeetingsProvider);
    final authStateChanges = ref.watch(authStateChangesProvider);
    var appSettingModel = ref.watch(appSettingProvider);
    if (!appSettingModel.isInternetAvailable) {
      return NoInternetScreen();
    }

    // log(D + 'build numMeetingsAsyncValue=$numMeetingsAsyncValue');
    final numMeetings = numMeetingsAsyncValue.asData?.value?.toString() ?? '?';
    // log(D + 'build numMeetings=$numMeetings');

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Container(
            width: double.maxFinite,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return authStateChanges.when(data: (firebaseUser) {
                  if (signUpViewModel.isLogged) {
                    return widget.homePageBuilder(context);
                  } else if (firebaseUser == null) {
                    Future.delayed(Duration(milliseconds: 500)).then((value) {
                      currentIndex.value = 1;
                      context.go(Routes.myUser);
                    });
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                height: kToolbarHeight * 2.25,
                                width: kToolbarHeight * 2.25,
                              ),
                              SizedBox(height: kToolbarHeight),
                              Text(
                                Keys.loginMsg.tr(context),
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              SizedBox(height: 8),
                              Text(Keys.loginMsg2.tr(context), textAlign: TextAlign.center, style: Theme.of(context).textTheme.caption),
                              SizedBox(height: 8),
                              Text(numMeetings + ' ' + Keys.loginMsg3.tr(context),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline
                                      ?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Custom.signInButton(
                                    label: 'Google',
                                    icon: 'assets/google.png',
                                    onPressed: () async {
                                      await ref.read(setupUserViewModelProvider).signInWithGoogle(context);
                                    },
                                  ),
                                  Custom.signInButton(
                                    label: 'Twitter',
                                    icon: 'assets/twitter.png',
                                    isVisibleIf: !kIsWeb,
                                    onPressed: () async {
                                      await ref.read(setupUserViewModelProvider).signInWithTwitter(context);
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Custom.signInButton(
                                    label: 'Instagram',
                                    isVisibleIf: false,
                                    icon: 'assets/icons/instagram_logo.png',
                                    onPressed: () async {
                                      MaterialPageRoute route = MaterialPageRoute(
                                        builder: (context) {
                                          return InstagramLogin(
                                            onUpdateVisitedHistory: (InAppWebViewController controller, Uri? url, bool? androidIsReload) async {
                                              instagram.getAuthorizationCode(url.toString());
                                              if (url?.host == InstagramConfig.redirectUriHost) {
                                                String idToken = await instagram.getTokenAndUserID();
                                                if (idToken.split(':').isNotEmpty) {
                                                  await _webViewController?.clearCache();
                                                  await _webViewController?.clearFocus();
                                                  await _webViewController?.clearMatches();
                                                  await _webViewController?.removeAllUserScripts();
                                                  Navigator.of(context).pop(idToken);
                                                }
                                              }
                                            },
                                            onWebViewCreated: (InAppWebViewController? value) {
                                              _webViewController = value;
                                            },
                                          );
                                        },
                                      );
                                      final result = await Navigator.of(context).push(route);
                                      if (result is String) {
                                        // String token = result.split(':').first; // never used
                                        String id = result.split(':').last;
                                        await signUpViewModel.signInWithInstagram(context, id);
                                      }
                                    },
                                  ),
                                  Custom.signInButton(
                                    label: 'Wallet connect',
                                    icon: 'assets/algo_logo.png',
                                    onPressed: () async {
                                      await onTapSignInWithAlgorand(signUpViewModel, context);
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.55),
                                child: Custom.signInButton(
                                  label: 'Sign in with Apple',
                                  icon: 'assets/apple.png',
                                  noFlex: true,
                                  isVisibleIf: !kIsWeb && Platform.isIOS,
                                  onPressed: () async {
                                    await ref.read(setupUserViewModelProvider).signInWithApple(context);
                                  },
                                ),
                              ),
                              Custom.signInButton(
                                noFlex: true,
                                label: Keys.signInAnonymously.tr(context),
                                icon: 'assets/icons/guest.png',
                                onPressed: () async {
                                  await ref.read(setupUserViewModelProvider).signInAnonymously(context);
                                },
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: kToolbarHeight * 0.25),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: Keys.about.tr(context),
                              style: Theme.of(context).textTheme.caption,
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' 2i2i',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (!await launchUrl(Uri.parse('https://about.2i2i.app/'), mode: LaunchMode.externalApplication))
                                          throw 'Could not launch https://about.2i2i.app/';
                                      },
                                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }, loading: () {
                  return WaitPage();
                }, error: (_, __) {
                  return Scaffold(
                    body: Center(
                      child: Text(Keys.error.tr(context), style: Theme.of(context).textTheme.subtitle1),
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onTapSignInWithAlgorand(SetupUserViewModel signUpViewModel, BuildContext context) async {
    var accountService = await ref.watch(accountServiceProvider);
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    String id = DateTime.now().toString();
    final connector = await WalletConnectAccount.newConnector(id);
    final account = WalletConnectAccount.fromNewConnector(accountService: accountService, connector: connector);
    String? address = await _createSession(accountService, account);
    if (address is String) {
      await signUpViewModel.signInWithWalletConnect(context, address, account, id, myAccountPageViewModel);
    }
  }

  Future<String?> _createSession(AccountService accountService, WalletConnectAccount account) async {
    if (!account.connector.connected) {
      SessionStatus sessionStatus = await account.connector.createSession(
        chainId: 4160,
        onDisplayUri: (uri) => Custom.changeDisplayUri(context, uri, isDialogOpen: isDialogOpen),
      );
      isDialogOpen.value = false;
      if (sessionStatus.accounts.isNotEmpty) {
        return sessionStatus.accounts.first;
      }
    }
    return account.address;
  }
}
