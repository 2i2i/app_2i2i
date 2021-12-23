import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';

import '../../services/all_providers.dart';

class AuthWidget extends ConsumerWidget {
  AuthWidget({required this.homePageBuilder});

  final WidgetBuilder homePageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);
    return authStateChanges.when(data: (user) {
      if (user == null) {
        final signUpViewModel = ref.read(setupUserViewModelProvider);
        if (!signUpViewModel.signUpInProcess) {
          return SignInScreen(
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
                  redirectUri: 'https://my-app.firebaseapp.com/__/auth/handler')
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
          );
        }
        return WaitPage();
      }

      return homePageBuilder(context);
    }, loading: () {
      return  WaitPage();
    }, error: (_, __) {
      return const Scaffold(
        body: Center(
          child: Text('error'),
        ),
      );
    });
  }
}
