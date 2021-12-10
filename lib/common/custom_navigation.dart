import 'package:app_2i2i/pages/home/home_page.dart';
import 'package:app_2i2i/pages/locked_user/ui/locked_user_page.dart';
import 'package:app_2i2i/routes/app_routes.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';

class CustomNavigation {
  static pop(BuildContext context) {
    Navigator.pop(context);
  }

  static push(BuildContext context, Widget page, String pageName) {
    log('============\n\n $pageName \n\n============');
    final locked = isUserLocked.value;
    final goingToLocked = pageName == Routes.LOCK;

    if (!locked && goingToLocked) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
    if (locked && goingToLocked) {
      return null;
    }
    if (locked){
     return LockedUserPage();
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  static pushReplacement(BuildContext context, Widget page, String pageName) {
    final locked = isUserLocked.value;
    final goingToLocked = pageName == Routes.LOCK;

    if (!locked && goingToLocked) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
    if (locked && goingToLocked) {
      return null;
    }
    if (locked){
      return LockedUserPage();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => page));
  }

  static pushAndRemoveUntil(
      BuildContext context, Widget page, String pageName) {
    final locked = isUserLocked.value;
    final goingToLocked = pageName == Routes.LOCK;

    if (!locked && goingToLocked) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
    if (locked && goingToLocked) {
      return null;
    }
    if (locked){
      return LockedUserPage();
    }
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => page),
        (Route<dynamic> route) => false);
  }
}
