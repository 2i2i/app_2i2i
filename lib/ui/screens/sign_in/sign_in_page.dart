import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom.dart';
import '../home/wait_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  final WidgetBuilder homePageBuilder;

  SignInPage({required this.homePageBuilder});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {

  @override
  void initState() {
    userIdNav.addListener(() {
      if(userIdNav.value.isNotEmpty){
        context.pushNamed(Routes.user.nameFromPath(),params: {
          'uid':userIdNav.value
        });
        userIdNav.value = '';
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = ref.read(setupUserViewModelProvider);
    final authStateChanges = ref.watch(authStateChangesProvider);
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
                  if (firebaseUser != null) {
                    signUpViewModel.updateFirebaseMessagingToken(firebaseUser.uid);
                    return widget.homePageBuilder(context);
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                'The place for you to Hangout',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              SizedBox(height: 8),
                              Text(
                                  '2i2i provides a safe and private space for Guests and Host to meet in the form of video calls',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.caption),
                              SizedBox(height: 8),
                              Text('>305 MEETINGS SINCE LAUNCH',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: ListTile(
                            onTap: () async {
                              await signUpViewModel.signInWithGoogle(context);
                            },
                            dense: true,
                            leading: Image.asset('assets/google.png',
                                height: 25, width: 25),
                            title: Text('Sign in with Google',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                          ),
                        ),
                        Visibility(
                          visible: Platform.isIOS,
                          child: Card(
                            margin: EdgeInsets.only(top: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            color: Theme.of(context).iconTheme.color,
                            child: ListTile(
                              onTap: () async {
                                await signUpViewModel.signInWithApple(context);
                              },
                              dense: true,
                              leading: Image.asset('assets/apple.png',
                                  height: 30, width: 30 ,color: Theme.of(context).cardColor),
                              title: Text('Sign in with Apple',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                    color: Theme.of(context).cardColor,
                                          fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),

                        Card(
                          margin: EdgeInsets.only(top: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: ListTile(
                            onTap: () async {
                              await signUpViewModel.signInWithTwitter(context);
                            },
                              dense: true,
                              leading: Image.asset('assets/twitter.png',
                                  height: 30, width: 30),
                              title: Text(
                                'Sign in with Twitter',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              )),
                        ),
                        Card(
                          margin: EdgeInsets.only(top: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          color: Theme.of(context).colorScheme.secondary,
                          child: ListTile(
                              onTap: () async {
                                await signUpViewModel.signInAnonymously();
                              },
                              dense: true,
                              leading: Icon(Icons.account_circle_rounded,color: Theme.of(context).cardColor),
                              title: Text(
                                'Sign in Anonymously',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              )),
                        ),
                        SizedBox(height: kToolbarHeight * 1.25),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'About ',
                              style: Theme.of(context).textTheme.caption,
                              children: <TextSpan>[
                                TextSpan(
                                    text: '2i2i',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (!await launch(
                                            'https://about.2i2i.app/'))
                                          throw 'Could not launch https://about.2i2i.app/';
                                      },
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        decoration: TextDecoration.underline)),
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
                      child: Text(Keys.error.tr(context),
                          style: Theme.of(context).textTheme.subtitle1),
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
}
