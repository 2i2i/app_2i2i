import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import '../../infrastructure/data_access_layer/services/logging.dart';
import '../../infrastructure/providers/all_providers.dart';

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
          String userId = '';
          Uri? uri = await getInitialUri();
          if (uri?.queryParameters['link'] is String) {
            var link = uri!.queryParameters['link'];
            if (link?.isNotEmpty ?? false) {
              uri = Uri.parse(link!);
            }
          }
          if (uri != null) {
            print('uri init ${uri.pathSegments}');
            if (uri.queryParameters['uid'] is String) {
              userId = uri.queryParameters['uid'] as String;
              userIdNav.value = userId;
              isUserLocked.notifyListeners();
            } else if (uri.pathSegments.contains('share') || uri.pathSegments.contains('user')) {
              String userId = uri.pathSegments.last;
              print(userId);
              userIdNav.value = userId;
              isUserLocked.notifyListeners();
            }
          }
        }
        uriLinkStream.listen((Uri? uri) {
          print('uri $uri');
          if (!mounted || uri == null) return;
          String userId = '';
          if (uri.queryParameters['link'] is String) {
            var link = uri.queryParameters['link'];
            if (link?.isNotEmpty ?? false) {
              uri = Uri.parse(link!);
            }
          }
          if (uri.queryParameters['uid'] is String) {
            userId = uri.queryParameters['uid'] as String;
            userIdNav.value = userId;
            isUserLocked.notifyListeners();
          } else if (uri.pathSegments.contains('share') || uri.pathSegments.contains('user')) {
            String userId = uri.pathSegments.last;
            userIdNav.value = userId;
            isUserLocked.notifyListeners();
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
