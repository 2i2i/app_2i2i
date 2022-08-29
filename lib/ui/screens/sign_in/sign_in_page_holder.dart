import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom.dart';
import 'sign_in_page.dart';
import 'sign_in_page_web.dart';

class SignInPageHolder extends ConsumerStatefulWidget {
  final Widget homePageBuilder;

  SignInPageHolder({required this.homePageBuilder});

  @override
  _SignInPageHolderState createState() => _SignInPageHolderState();
}

class _SignInPageHolderState extends ConsumerState<SignInPageHolder> {
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
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => SignInPage(homePageBuilder: widget.homePageBuilder),
      tablet: (BuildContext context) => SignInPage(homePageBuilder: widget.homePageBuilder),
      desktop: (BuildContext context) => SignInPageWeb(homePageBuilder: widget.homePageBuilder),
    );
  }
}
