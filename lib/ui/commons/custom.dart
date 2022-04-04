import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

ValueNotifier<String> userIdNav = ValueNotifier("");
class Custom {
  static getBoxDecoration(BuildContext context,
      {Color? color, double radius = 10}) {
    return BoxDecoration(
      color: color ?? Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          offset: Offset(2, 4),
          blurRadius: 8,
          color: Colors.black12.withOpacity(0.1),
        ),
      ],
    );
  }

  static Future<void> deepLinks(BuildContext context, bool mounted) async {
    if (!kIsWeb) {
      try {
        // String mainUrl = '';

        bool _initialUriIsHandled = false;
        if (!_initialUriIsHandled) {
          _initialUriIsHandled = true;
          print("load");
          Uri? uri = await getInitialUri();
          if(uri?.pathSegments.contains('user')??false) {
            print( "user");
            String userId = '';
            if(uri!.pathSegments.contains('user')){
              print( "userId");
              userId = uri.pathSegments.last;
              userIdNav.value = userId;
            }
          }
        }
        uriLinkStream.listen((Uri? uri) {
          print('uriLinkStream.listen $uri');
          print("load listen ==== ===== ===== \n ${uri.toString()} \n");
          if (!mounted) return;
          String userId = '';
          print( "user id load");
          if(uri!.pathSegments.contains('user')){
            print( "user go");
            userId = uri.pathSegments.last;
            userIdNav.value = userId;
          }
        });
      } catch (e) {
        print(e);
      }
    }
  }

  // static void navigatePage(String userId, BuildContext context) {
  //   return;
  //   if (userId.isNotEmpty) {
  //     Future.delayed(Duration(seconds: 1)).then((value) {
  //       try {
  //         context.pushNamed(Routes.user.nameFromPath(), params: {
  //           'uid': userId,
  //         });
  //       } catch (e) {
  //         print(e);
  //       }
  //     });
  //   }
  // }
}