import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../infrastructure/data_access_layer/services/logging.dart';
import '../../infrastructure/providers/all_providers.dart';

ValueNotifier<String> userIdNav = ValueNotifier("");
bool _initialUriIsHandled = false;

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

  static Future<void> deepLinks(
    BuildContext context,
    bool mounted,
  ) async {
    if (!kIsWeb) {
      try {
        if (!_initialUriIsHandled) {
          _initialUriIsHandled = true;
          String userId = '';
          PendingDynamicLinkData? pendingDynamicLinkData = await FirebaseDynamicLinks.instance.getInitialLink();
          if (pendingDynamicLinkData != null) {
            handleURI(pendingDynamicLinkData.link, userId);
          }
        }

        FirebaseDynamicLinks.instance.onLink.listen((event) {
          print(event.link);
          Uri uri = event.link;
          if (!mounted) return;
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

  static void handleURI(Uri? uri, String userId) {
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
