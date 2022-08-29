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
import 'package:cloud_functions/cloud_functions.dart';
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
  await dotenv.load(fileName: "assets/.env_dev");

  FirebaseApp app = await Firebase.initializeApp(
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: "AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs",
              authDomain: "i2i-test.firebaseapp.com",
              projectId: "i2i-test",
              storageBucket: "i2i-test.appspot.com",
              messagingSenderId: "453884442411",
              appId: "1:453884442411:web:dad8591e5125eb8998776e")
          : null);
  await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: '6LcASwUeAAAAAE354ZxtASprrBMOGULn4QoqUnze');
  FirebaseFunctions.instanceFor(app: app).useFunctionsEmulator('192.168.29.73', 5001);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseNotifications();

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
    "project_id": "i2i-test",
    "private_key_id": "cbd4940871b30452337d0d74af1eb414c52cd5ed",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCiApuROI4U/fVz\nxrtORfvGXL0iCe9Ne1FGR8YuCBlXlU0xIKzHiDfefaTzVcX5Pc/Qyzag7+6KoiYY\nwRmcJZ0uUAJUEp2NngXo7Z4W3RPTiPCiPlyqLmYbxkJRiPpXHg2lJWi7QWxgXwJx\n0zWwgyAatCEMjYDq+Xow8g7N5Fk0gaKgO7Nx8XaRla8o3kFnX2S/eIKFT/1kkogs\nAipx/Oy31UEGQHN4uQ1z+TGZifzGBy8a8qnF8QIaCCHOaBW0ZW3X9YiuXkSKPdBw\n8sYNLUl2imqWTr7w32XMssq7DWG7OHOyJlgiEKxbm5z3jj32tWdwB/gLjwYTkrl0\nN00cutUjAgMBAAECggEAOarz9R1MdexwEmYLBjGjDVi1eghPRiU/KOUjhf8cBjD+\n6R3YYq36NRhEPtmpPq7h6lBrgZ3mKzLMnMMfepVo/bM9IO//ZQl60Q7D1x+ajxGP\nljDcizc44WoQ8TTw51GrSb2nKgB/s04ecKXd1pbWNqsnmHBGE136QLHo0yEVH7r0\nOasswufzCtq0vMCC/waPel35zoR168RpGwD1u0L0vObI9hGsU/uXsPq2UTE+Qq8K\nv5UQqt1yWRj3P3TXhVyMY9sT71FHmtR+YJvVPhzK7fSt0is+2lmi5jdduJMk3GJo\nyJ0l03CJ687TfolO/421KWkftdcPjFj2VEvuI6HjAQKBgQDSQKju9aP/NMMJ3OzI\nkeGH/2Q93zALBy7YvDyhq55vPGGLX+pXTclFfryh0X+WGJWEymawMO/ZF4juFkFd\nxyK0uycExpmen7lWkfUD6+IFck/6eTYrV3hi8lmy5lDZoqVPwxTIPEgbdJgNNzsY\nsWAo+18Mrf3Ex7kY9eRI4FoOZwKBgQDFQsjGygi/fxYS9EUNYdppNN6rZ0j8BPUw\nrA/MPX6fMhuAqICTJqK/ZFqujaoDFDCNW8lAKswqKsG+g1f7ECgw2w6EflxzkQNS\nTxOkWO51abgzo1FHVbWz15oD/aNGm9TAbtPzGHUEeeGBjthwrJynjUKhR+V5y+6q\n4gfXHaaV5QKBgE+r1NgIGQbh9W5NWyR9sxqXumJ/qnLjW+shGVCh+b1pAgWQaPqA\nLV66MbyX6GL2GeJh2Bu3z4tSEb82i7p/dTVLHfP/VcL3/4FAebnsro8lzAy71b0C\nvkmwUDEseUKfEUlyQPPHdAODYQLRBQHMZQXiixgA7oKctBUzSDgdW8LNAoGBAJ45\nq4KIm+u+rJ4XgSvyyZaJ6fHirxA3idS4rxNMYDyhnJ3eiwN9gh2zCWnqB+zgTPGW\nJh9qNMm98ho2kGO52gMWMtbj5JRuRRPIiiDRlLRpUG9bGN73SQAweEGrOURxyn1w\naGIdw/8LJG8ffU0jp6ReEov7d33yrkYzd8Z86hphAoGBAMlgfrlVObzO+XiVgEar\nvIizlH83sjavS5rxuaFOkIbtRoVb0poPvCKdtOT2DrdGLa4M3+Ub4YiEJCFLlkay\n9foRThjbJYfZPuYrgzIsFtP5FmG+78qyYM24QXNqETcIXjktivvGQetUtr/fr2yW\nDuGWynz0OF4emG2LELVMivi3\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fwd7n@i2i-test.iam.gserviceaccount.com",
    "client_id": "110784426908109511374",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fwd7n%40i2i-test.iam.gserviceaccount.com"
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
