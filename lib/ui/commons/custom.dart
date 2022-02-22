import 'package:app_2i2i/ui/screens/home/bottom_nav_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';

import '../../infrastructure/routes/app_routes.dart';

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

  static String validateValueData(String value) {
    Pattern pattern = r'[0-9][A-Z]\w+';
    RegExp regex = new RegExp(pattern.toString());
    if (value.isNotEmpty && regex.hasMatch(value)) {
      print(regex.firstMatch(value)?.group(0));
      return "88NxG5Op6tTBbH3qw8BGPDxjdgR2";
    }
    return "";
  }

  static Future<void> deepLinks(BuildContext context, bool mounted) async {
    if (!kIsWeb) {
      try {
        String mainUrl = '';

        bool _initialUriIsHandled = false;
        if (!_initialUriIsHandled) {
          _initialUriIsHandled = true;
          Uri? uri = await getInitialUri();
          print('uriLinkStream _initialUriIsHandled $uri');
          if (uri != null && uri.toString().isNotEmpty) {
            if (!mounted) return;
            mainUrl = uri.toString();
            navigate.value = mainUrl;
            // navigatePage(mainUrl, context);
            mainUrl = '';
          }
        }
        uriLinkStream.listen((Uri? uri) {
          print('uriLinkStream.listen $uri');
          if (!mounted) return;
          if (uri.toString().isNotEmpty) {
            mainUrl = uri.toString();
            navigate.value = mainUrl;
            // navigatePage(mainUrl, context);
          }
        });
      } catch (e) {
        print(e);
      }
    }
  }

  static void navigatePage(String mainUrl, BuildContext context) {
    String userId = Custom.validateValueData(mainUrl);
    if (userId.isNotEmpty) {
      Future.delayed(Duration(seconds: 1)).then((value) {
        try {
          print(context);
          context.pushNamed(Routes.user.nameFromPath(), params: {
            'uid': userId,
          });
        } catch (e) {
          print(e);
        }
      });
    }
  }
}