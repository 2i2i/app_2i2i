// A -> B
// main actions:
// createBid - A
// acceptBid - B
// acceptMeeting - A
// createRoom - A
// import 'package:http/http.dart' as html;
// import 'dart:html' as html;
import 'dart:async';
import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:universal_html/html.dart';
import 'infrastructure/data_access_layer/services/firebase_notifications.dart';
import 'infrastructure/providers/all_providers.dart';
import 'infrastructure/providers/ringing_provider/ringing_page_view_model.dart';
import 'infrastructure/routes/named_routes.dart';
// DEBUG
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// DEBUG3

import 'common_main.dart';
import 'ui/commons/custom.dart';
import 'ui/screens/localization/app_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
      options: kIsWeb?FirebaseOptions(
          apiKey: "AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs",
          authDomain: "i2i-test.firebaseapp.com",
          projectId: "i2i-test",
          storageBucket: "i2i-test.appspot.com",
          messagingSenderId: "453884442411",
          appId: "1:453884442411:web:dad8591e5125eb8998776e"
      ):null
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseNotifications();

  if (AppConfig().ALGORAND_NET == AlgorandNet.mainnet) {
    return SentryFlutter.init((options) {
      options.dsn = 'https://4a4d45710a98413eb686d20da5705ea0@o1014856.ingest.sentry.io/5980109';
    }, appRunner: () {
      FlutterSecureStorage().read(key: 'theme_mode').then((value) {
        FlutterSecureStorage().read(key: 'language').then((local) {
          return runApp(
            ProviderScope(
              child: MainWidget(local ?? 'en', themeMode: value ?? "AUTO"),
            ),
          );
        });
      });
    });
  } else {
    return FlutterSecureStorage().read(key: 'theme_mode').then((value) {
      FlutterSecureStorage().read(key: 'language').then((local) {
        return runApp(
          ProviderScope(
            child: MainWidget(local ?? 'en', themeMode: value ?? "AUTO"),
          ),
        );
      });
    });
  }
}