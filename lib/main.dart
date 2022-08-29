// change version in build.gradle and pubspec.yaml and app_setting_model
// flutter build appbundle --flavor production -t lib/main.dart
// flutter build ipa --flavor production -t lib/main.dart

// A -> B
// main actions:
// createBid - A
// acceptBid - B
// acceptMeeting - A
// createRoom - A
// import 'package:http/http.dart' as html;
// import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:firebase_admin/firebase_admin.dart' as admin;
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// DEBUG
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// DEBUG3

import 'common_main.dart';
import 'infrastructure/data_access_layer/services/firebase_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: "assets/.env");
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

  await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: '6LcASwUeAAAAAE354ZxtASprrBMOGULn4QoqUnze');

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseNotifications();

  //region DEBUG
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //endregion DEBUG
  await _initializeAdmin();
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

Future<admin.App> _initializeAdmin() async {
  final adminObj = admin.FirebaseAdmin.instance;
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/service-account.json');
  final data = jsonEncode({
    "type": "service_account",
    "project_id": "app-2i2i",
    "private_key_id": "374c16c7dd0cd1df705fb4ef65bbbecfe8965ab4",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDSVdQwYlgp5yth\noLSTUCitVqQWnXN4/9hv/WLOIJ7B4FNkCTIqJyAM5bSjxzax0LnX+1rONyqGcc8c\nxR3gX3ANtLA63j1JmdhuaIccogXKzF24EMfIK6jCIBmFvNAcusCdDvUFCLb0nEDi\nhAie1jL00UFDFHFiKF/p/Q2zxMbLuNYguv6sVYZI9KFrJjd8QE9GPZ4Z4fY4rsMo\n8uGR2L/wjA/9WriSdAGsfMyzDe1fULhVqTP0K9LAmNw+ilbdEAOg6RkpqIzZXFbF\nLE566E/UrBtP5QNTogsTzUm+C/Nrh4Yz+B1WdN/OX7FLfIu2y9XxHj9Id1LaS94B\nO16aquIjAgMBAAECggEAOgmTzKv+PsW6OyyQVwupxbaf/VuBxtP1wWUN8+mdVMrU\nx8gfzvDPz688amqoRWVeOmHxevBO7B0QNJSRe11qOmXusLes+peYWFLAYV61sXE1\ntPnwXmPpo3MfB7+DP0Iqrsu3QSXX8eQBpV8gT8+z7MimtN85sAeK+7InK0DzR7ff\nRm2aEZQ/xNXPG4wLE6+IEd1OGpFXp0sMbRMcxuEId9nUKnU+uRWkT1cVAWNrJKO5\nqfdzRruzHmjp2CyqZwhMyZjprWzGfo07Gokf+ugU1+8loHhq9DE+cJsaVpjcG9Yb\nLere8jQ3EQJZVkW1gsyeda3wzY8+rF8LI7stplbraQKBgQDuhbbmQu2Wxv9P7ibE\n0X5fiJEX1Wt+3faFkF9tHmnZuYeo/3LuyRBGvs31+Wk6cK9nNmOE5AA5LJkS+r85\nLM8zvkx88jVcL+uprm0x4OqZEh5QR+phnldDSdr6jBCVLanhQD3rInx5laF5APCu\n3iQel5PEC6ozRhTyXWZTLamDOQKBgQDhv18r7IpsT4Ry7Zb/xrq4WQlpw9gboAUt\nqTsK0Jmj25NpW+Yr/Gs00t1qf64wwwei2i/F7GPU8vtqUMn7e8PP76sYdsBsG5Er\nmFi1yDRKe74xh69FNSwqPiLEnSpZztGanhC5DqiPQiFKJBF0PIGshApSh8RAQCn9\nAZRYAzLEOwKBgAyqXQPtGeCfwH7mDnj1Btjbz5iMZKDf+G8vM2H/8270QxfeOKQl\nWQ/oodcl30iTIz0/zhkIYlqm25n+ZpkKoBYHTNh1pA+5G7Ju6K11W/+0zpdEulVk\nqw2PpmkXdun0+shTOPZ7ZlCueVyLiDxA33ogYmBOnkMKvaIBA6X3DsFBAoGBAIFu\nHpvpb+fvo2ndbPDTOSUO74WzYslb8vweBhsKRLyc3STQKuTXQYQ0zfwMnouYll05\nqaBaC1cBxUJMdbH5YOhsanWJSIPzPkV3gI0g71IxJnfxan1MojjKDVcbITgCi0yS\nCdaAYAZbDQkcKuGw+0w1HFH7Q3rvDuPfrvTTSJ0XAoGADuQMeunmgG2C/FImLDsQ\nin36z3AJt7KgdWPcqQtunGdc1flWcd1Ryr5NcRhdkpcXyoCTXRiqxCoT/2kx0nGF\nYwfJazxpz2EdywQaKKPz9LfILx9k+qdYEEJN2INhjDXpqSomwzUJows8R3P1PtkA\nq9sJZyzHiJB65tu2V9kWUUA=\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-kduve@app-2i2i.iam.gserviceaccount.com",
    "client_id": "116799576481512510519",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-kduve%40app-2i2i.iam.gserviceaccount.com"
  });
  await file.writeAsString(data);
  final cert = admin.FirebaseAdmin.instance.certFromPath(file.path);
  final app = adminObj.initializeApp(
    admin.AppOptions(
      credential: cert,
    ),
  );
  return app;
}
