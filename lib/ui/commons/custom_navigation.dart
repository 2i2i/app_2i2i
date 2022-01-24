
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomNavigation {

  /*
    final locked = isHangoutLocked.value;
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
    }*/
  static push(BuildContext context, Widget page, String pageName,{bool rootNavigator = false}) {
    if (kIsWeb) {
      var pageRouteBuilder = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      );
      Navigator.of(context,rootNavigator: rootNavigator).push( pageRouteBuilder);
    } else {
      Navigator.of(context,rootNavigator: rootNavigator).push(MaterialPageRoute(builder: (context) => page));
    }
  }

  static pushReplacement(BuildContext context, Widget page, String pageName,{bool rootNavigator = false}) {
    if(kIsWeb) {
      var pageRouteBuilder = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      );
      Navigator.of(context,rootNavigator: rootNavigator).pushReplacement(pageRouteBuilder);
    } else{
      Navigator.of(context,rootNavigator: rootNavigator).pushReplacement( MaterialPageRoute(builder: (context) => page));
    }
  }

  static pushAndRemoveUntil(BuildContext context, Widget page, String pageName,{bool rootNavigator = false}) {
    if(kIsWeb) {
      var pageRouteBuilder = PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,

        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      );
      Navigator.of(context,rootNavigator: rootNavigator).pushAndRemoveUntil( pageRouteBuilder, (Route<dynamic> route) => false);
    }else {
      Navigator.of(context,rootNavigator: rootNavigator).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => page),
              (Route<dynamic> route) => false);
    }
  }
}
