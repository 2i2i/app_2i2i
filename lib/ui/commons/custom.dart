import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import '../../infrastructure/data_access_layer/services/logging.dart';

ValueNotifier<String> userIdNav = ValueNotifier("");

class Custom {
  static getBoxDecoration(BuildContext context, {Color? color, double radius = 10}) {
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
          Uri? uri = await getInitialUri();
          if (uri?.pathSegments.contains('user') ?? false) {
            log("user");
            String userId = '';
            if (uri!.pathSegments.contains('user')) {
              log("userId");
              userId = uri.pathSegments.last;
              userIdNav.value = userId;
            }
          }
        }
        uriLinkStream.listen((Uri? uri) {
          if (!mounted) return;
          String userId = '';
          if (uri!.pathSegments.contains('user')) {
            log("user go");
            userId = uri.pathSegments.last;
            userIdNav.value = userId;
          }
        });
      } catch (e) {
        log("$e");
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
