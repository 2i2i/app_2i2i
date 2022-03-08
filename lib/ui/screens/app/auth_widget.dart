import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import 'package:go_router/go_router.dart';

bool showed = false;
class AuthWidget extends ConsumerStatefulWidget {
  final WidgetBuilder homePageBuilder;
  AuthWidget({required this.homePageBuilder});

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends ConsumerState<AuthWidget> {
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
    final authStateChanges = ref.watch(authStateChangesProvider);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return authStateChanges.when(data: (firebaseUser) {
            final signUpViewModel = ref.read(setupUserViewModelProvider);

            if (firebaseUser != null) {
              signUpViewModel.updateFirebaseMessagingToken(firebaseUser.uid);
              return widget.homePageBuilder(context);
            }

            // if (firebaseUser == null) {
            // if (!signUpViewModel.signUpInProcess) {
            // final token = ref.read(firebaseMessagingTokenProvider);
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
                      (context, user) {
                        Future.delayed(Duration.zero).then(
                          (value) {
                            ref
                                .read(setupUserViewModelProvider)
                                .createAuthAndStartAlgoRand(
                                    firebaseUserId: user.user?.uid);
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
                      label: Text('Sign Anonymously'),
                    ),
                  ),
                );*/
            // }
            return WaitPage();
            // }
          }, loading: () {
            return WaitPage();
          }, error: (_, __) {
            return Scaffold(
              body: Center(
                child: Text(Keys.error.tr(context),style: Theme.of(context).textTheme.subtitle1),
              ),
            );
          });
        },
      ),
    );
  }
}
