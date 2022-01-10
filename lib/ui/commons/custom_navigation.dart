
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/data_access_layer/services/logging.dart';
import '../../infrastructure/providers/all_providers.dart';
import '../../infrastructure/routes/app_routes.dart';
import '../screens/home/home_page.dart';
import '../screens/locked_user/locked_user_page.dart';

class CustomNavigation {


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
    if(kIsWeb) {
      var pageRouteBuilder = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      );
      Navigator.push(context, pageRouteBuilder);
    }else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
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

    if(kIsWeb) {
      var pageRouteBuilder = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,

        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      );
      Navigator.pushReplacement(context, pageRouteBuilder);
    } else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  static pushAndRemoveUntil(BuildContext context, Widget page, String pageName) {
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

    if(kIsWeb) {
      var pageRouteBuilder = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,

        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      );
      Navigator.pushAndRemoveUntil(context, pageRouteBuilder, (Route<dynamic> route) => false);
    }else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => page),
              (Route<dynamic> route) => false);
    }
  }
}
