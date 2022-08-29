import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom.dart';
import '../app/no_internet_screen.dart';
import '../app/wait_page.dart';
import 'package:lottie/lottie.dart';

class SignInPageWeb extends ConsumerStatefulWidget {
  final Widget homePageBuilder;

  SignInPageWeb({required this.homePageBuilder});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPageWeb> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (uid.isNotEmpty) {
        return await FirebaseMessaging.instance
            .getToken(
          vapidKey: dotenv.env['TOKEN_KEY'].toString(),
        )
            .then((String? token) {
          if (token is String) return FirestoreDatabase().updateToken(uid, token);
        });
      }
    });

    userIdNav.addListener(() {
      if (userIdNav.value.isNotEmpty) {
        context.pushNamed(Routes.user.nameFromPath(), params: {'uid': userIdNav.value});
        userIdNav.value = '';
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final signUpViewModel = ref.watch(setupUserViewModelProvider);
    final authStateChanges = ref.watch(authStateChangesProvider);
    var appSettingModel = ref.watch(appSettingProvider);
    if (!appSettingModel.isInternetAvailable) {
      return NoInternetScreen();
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Lottie.asset(
                'assets/background/web_bg.json',
                fit: BoxFit.fill,
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return authStateChanges.when(data: (firebaseUser) {
                  if (firebaseUser != null) {
                    // signUpViewModel.updateFirebaseMessagingToken(firebaseUser.uid);
                    return widget.homePageBuilder;
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: kToolbarHeight * 2),

                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: kToolbarHeight),
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
                                  Text(
                                    Keys.loginMsg3.tr(context),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .overline
                                        ?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: kToolbarHeight * 1),
                                  RichText(
                                    text: TextSpan(
                                      text: Keys.about.tr(context),
                                      style: Theme.of(context).textTheme.button,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: '  2i2i',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                if (!await launchUrl(Uri.parse('https://about.2i2i.app/'), mode: LaunchMode.externalApplication))
                                                  throw 'Could not launch https://about.2i2i.app/';
                                              },
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary, decoration: TextDecoration.underline)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: kToolbarHeight * 1.25),

                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(height: kToolbarHeight * 3),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 400,minHeight: 50),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          await ref.read(setupUserViewModelProvider).signInWithGoogle(context);
                                        },
                                        dense: true,
                                        leading: Image.asset('assets/google.png', height: 25, width: 25),
                                        title: Text(Keys.signInWithGoogle.tr(context),
                                            style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !kIsWeb && Platform.isIOS,
                                    child: Card(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      color: Theme.of(context).iconTheme.color,
                                      child: ListTile(
                                        onTap: () async {
                                          await ref.read(setupUserViewModelProvider).signInWithApple(context);
                                        },
                                        dense: true,
                                        leading: Image.asset('assets/apple.png', height: 30, width: 30, color: Theme.of(context).cardColor),
                                        title: Text(Keys.signInWithApple.tr(context),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                ?.copyWith(color: Theme.of(context).cardColor, fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !kIsWeb,
                                    child: Card(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      child: ListTile(
                                          onTap: () async {
                                            await ref.read(setupUserViewModelProvider).signInWithTwitter(context);
                                          },
                                          dense: true,
                                          leading: Image.asset('assets/twitter.png', height: 30, width: 30),
                                          title: Text(
                                            Keys.signInWithTwitter.tr(context),
                                            style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500),
                                          )),
                                    ),
                                  ),
                                  SizedBox(height: kToolbarHeight * 0.50),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 400, minHeight: 50),
                                    child: Card(
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                      color: Theme.of(context).colorScheme.secondary,
                                      child: ListTile(
                                        minVerticalPadding: 0,
                                        onTap: () async {
                                          await ref.read(setupUserViewModelProvider).signInAnonymously();
                                        },
                                        dense: true,
                                        leading: Icon(Icons.account_circle_rounded, color: Theme.of(context).cardColor),
                                        title: Text(
                                          Keys.signInAnonymously.tr(context),
                                          style: Theme.of(context).textTheme.subtitle1?.copyWith(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: kToolbarHeight * 2),

                          ],
                        ),
                        SizedBox(height: kToolbarHeight * 1.25),
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
            )
          ],
        ),
      ),
    );
  }
}
