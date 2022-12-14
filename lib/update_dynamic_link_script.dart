import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'infrastructure/commons/app_config.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            print('A');
            final response = await FirebaseFunctions.instance.httpsCallable('updateDeepLinks').call();
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.abc),
      ),
      body: Center(
        child: FutureBuilder(
          initialData: '',
          future: FirebaseMessaging.instance.getToken(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.data.runtimeType != String) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return SelectableText(snapshot.data.toString());
          },
        ),
      ),
    );
  }

  Future<String> createDeepLinkUrl(String uid) async {
    try {
      final host = dotenv.env['host'].toString();
      final link = Uri.parse('$host/user/$uid');
      if (kIsWeb) {
        return link.toString();
      }

      final FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
      final uriPrefix = dotenv.env['DYNAMIC_LINK_HOST'].toString();

      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: uriPrefix,
        link: link,
        androidParameters: AndroidParameters(
          packageName: AppConfig.androidAppId,
          fallbackUrl: Uri.tryParse(host),
        ),
        iosParameters: IOSParameters(
          bundleId: AppConfig.iosAppId,
          fallbackUrl: Uri.tryParse(host),
          ipadFallbackUrl: Uri.tryParse(host),
          ipadBundleId: AppConfig.iosAppId,
          appStoreId: AppConfig.appStoreId,
        ),
        navigationInfoParameters: const NavigationInfoParameters(
          forcedRedirectEnabled: false,
        ),
      );
      final shortUri = await dynamicLinks.buildShortLink(parameters);
      return shortUri.shortUrl.toString();
    } catch (e) {
      print(e);
    }
    return "";
  }
}
