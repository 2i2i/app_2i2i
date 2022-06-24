// change version in build.gradle and pubspec.yaml
// flutter build appbundle --flavor main -t lib/main.dart ->
// flutter build ipa --flavor main -t lib/main.dart -> open archive in xcode and distribute

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
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'infrastructure/data_access_layer/services/firebase_notifications.dart';

// DEBUG
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// DEBUG3

import 'common_main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: ".env");
  // await Firebase.initializeApp(
  //     options: kIsWeb
  //         ? FirebaseOptions(
  //             apiKey: "AIzaSyDx8E8sAtlaDZveourRnfJcQkpJCF3pPcc",
  //             authDomain: "app-2i2i.firebaseapp.com",
  //             projectId: "app-2i2i",
  //             storageBucket: "app-2i2i.appspot.com",
  //             messagingSenderId: "347734179578",
  //             appId: "1:347734179578:web:f9c11616c64e12c643d343",
  //             measurementId: "G-BXKG3DRTJ4")
  //         : null);
  await Firebase.initializeApp(
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: "AIzaSyDx8E8sAtlaDZveourRnfJcQkpJCF3pPcc",
              authDomain: "app-2i2i.firebaseapp.com",
              projectId: "app-2i2i",
              storageBucket: "app-2i2i.appspot.com",
              messagingSenderId: "347734179578",
              appId: "1:347734179578:web:f9c11616c64e12c643d343")
          : null);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseNotifications();

  //region DEBUG
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //endregion DEBUG

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
