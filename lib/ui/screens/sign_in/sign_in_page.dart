import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {

  @override
  Widget build(BuildContext context) {
    return SignInScreen(

      headerBuilder: (context, constraints, _) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: FlutterLogo(),
          ),
        );
      },
      sideBuilder: (context, constraints) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(constraints.maxWidth / 8),
            child: FlutterLogo(),
          ),
        );
      },
      providerConfigs: [
        const EmailProviderConfiguration(),
        const PhoneProviderConfiguration(),
        const GoogleProviderConfiguration(
          clientId: "GOOGLE_CLIENT_ID",
        ),
        const AppleProviderConfiguration(),
        const FacebookProviderConfiguration(
          clientId: "FACEBOOK_CLIENT_ID",
        ),
        const TwitterProviderConfiguration(
          apiKey: "TWITTER_API_KEY",
          apiSecretKey: "TWITTER_API_SECRET_KEY",
          redirectUri: "TWITTER_REDIRECT_URI",
        )
      ],
    );
  }
}
