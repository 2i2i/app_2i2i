import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterfire_ui/auth.dart';

import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';

class AuthWidget extends ConsumerWidget {
  AuthWidget({required this.homePageBuilder});

  final WidgetBuilder homePageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return authStateChanges.when(data: (user) {
            if (user == null) {
              final signUpViewModel = ref.read(setupUserViewModelProvider);
              if (!signUpViewModel.signUpInProcess) {
                signUpViewModel.signInAnonymously();
                /*return SignInScreen(
                  headerBuilder: (context, constraints, shrinkOffset) =>
                      SvgPicture.asset(
                    'assets/icons/appbar_icon.svg',
                    width: 55,
                    height: 65,
                  ),
                  showAuthActionSwitch: false,
                  actions: [
                    AuthStateChangeAction<SignedIn>(
                      (context, userModel) {
                        Future.delayed(Duration.zero).then(
                          (value) {
                            ref
                                .read(setupUserViewModelProvider)
                                .createAuthAndStartAlgoRand(
                                    firebaseUserId: userModel.user?.uid);
                          },
                        );
                      },
                    ),
                  ],
                  providerConfigs: [
                    GoogleProviderConfiguration(
                      clientId: '...',
                    ),
                    TwitterProviderConfiguration(
                        apiKey: '...',
                        apiSecretKey: '...',
                        redirectUri:
                            'https://my-app.firebaseapp.com/__/auth/handler')
                  ],
                  footerBuilder: (context, action) => Container(
                    margin: EdgeInsets.only(top: 4),
                    height: kTextTabBarHeight,
                    child: ElevatedButton.icon(
                      onPressed: () async => ref
                          .read(setupUserViewModelProvider)
                          .createAuthAndStartAlgoRand(),
                      icon: Icon(Icons.login),
                      label: Text('Sign in as Guest'),
                    ),
                  ),
                );*/
              }
              return WaitPage();
            }

            return homePageBuilder(context);
          }, loading: () {
            return WaitPage();
          }, error: (_, __) {
            return const Scaffold(
              body: Center(
                child: Text('error'),
              ),
            );
          });
        },
      ),
    );
  }
}
