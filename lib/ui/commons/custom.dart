import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../infrastructure/commons/app_config.dart';
import '../../infrastructure/commons/utils.dart';
import '../../infrastructure/data_access_layer/services/logging.dart';
import '../../infrastructure/providers/all_providers.dart';
import '../screens/my_account/widgets/qr_image_widget.dart';

ValueNotifier<String> userIdNav = ValueNotifier("");
bool _initialUriIsHandled = false;

class Custom {
  static getBoxDecoration(BuildContext context, {Color? color, double radius = 10, BorderRadiusGeometry? borderRadius}) {
    return BoxDecoration(
      color: color ?? Theme.of(context).cardColor,
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          offset: Offset(2, 4),
          blurRadius: 8,
          color: Colors.black12.withOpacity(0.1),
        ),
      ],
    );
  }

  // static double webWidth(BuildContext context) => (MediaQuery.of(context).size.width / 2.5);
  static double webWidth(BuildContext context) => 500;

  static double webHeight(BuildContext context) => 844;

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

  static Future<String> createDeepLinkUrl(String uid) async {
    try {
      if (kIsWeb) {
        return '${AppConfig.hostUrl}/users/$uid';
      }
      final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
      final link = dotenv.env['DYNAMIC_LINK_HOST'].toString();
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: link,
        link: Uri.parse('${AppConfig.hostUrl}/users/$uid'),
        androidParameters: AndroidParameters(
          packageName: AppConfig.androidAppId,
          fallbackUrl: Uri.parse('${AppConfig.hostUrl}'),
        ),
        iosParameters: IOSParameters(
          bundleId: AppConfig.iosAppId,
          fallbackUrl: Uri.parse('${AppConfig.hostUrl}'),
          ipadFallbackUrl: Uri.parse('${AppConfig.hostUrl}'),
          ipadBundleId: AppConfig.iosAppId,
          appStoreId: AppConfig.appStoreId,
        ),
        navigationInfoParameters: const NavigationInfoParameters(
          forcedRedirectEnabled: false,
        ),
      );
      final shortUri = await dynamicLinks.buildShortLink(parameters);
      if (shortUri.shortUrl.toString().isNotEmpty) {
        FirebaseAuth.instance.currentUser!.updatePhotoURL(shortUri.shortUrl.toString());
      }
      return shortUri.shortUrl.toString();
    } catch (e) {
      print(e);
    }
    return "";
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

  static Future changeDisplayUri(BuildContext context, String url, {required ValueNotifier<bool> isDialogOpen}) async {
    bool isAvailable = false;
    if (kIsWeb) {
      isDialogOpen.value = true;
      await showDialog(
        context: context,
        builder: (context) => ValueListenableBuilder(
          valueListenable: isDialogOpen,
          builder: (BuildContext context, bool value, Widget? child) {
            if (!value) {
              Navigator.of(context).pop();
            }
            return QrImagePage(
              imageUrl: url,
              color: Colors.black,
            );
          },
        ),
        barrierDismissible: true,
      );
    } else {
      var launchUri;
      try {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          final bridge = await getWCBridge();
          launchUri = Uri(
            scheme: 'algorand-wc',
            host: 'wc',
            queryParameters: {'uri': url, 'bridge': bridge}, //"https://wallet-connect-d.perawallet.app"},
          );
        } else {
          launchUri = Uri.parse(url);
        }
        isAvailable = await launchUrl(launchUri);
      } on PlatformException catch (err) {
        print(err);
      }
      if (!isAvailable) {
        await launchUrl(
            Uri.parse(!kIsWeb && Platform.isAndroid
                ? 'https://play.google.com/store/apps/details?id=com.algorand.android'
                : 'https://apps.apple.com/us/app/pera-algo-wallet/id1459898525'),
            mode: LaunchMode.externalApplication);
      }
    }
  }

  static Widget signInButton({VoidCallback? onPressed, required String label, required String icon, bool isVisibleIf = true, bool noFlex = false}) {
    Widget buttonWidget = Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      child: ListTile(
        onTap: onPressed,
        minLeadingWidth: 10,
        title: Text(label),
        leading: Image.asset(icon, height: 35, width: 30),
      ),
    );
    if (!isVisibleIf) {
      return Container();
    }

    if (noFlex) {
      return buttonWidget;
    }
    return Expanded(
      child: buttonWidget,
    );
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
