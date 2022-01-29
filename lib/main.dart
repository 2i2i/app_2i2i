import 'dart:async';

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'infrastructure/commons/strings.dart';
import 'infrastructure/providers/all_providers.dart';
import 'infrastructure/routes/named_routes.dart';

// DEBUG
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// DEBUG

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  // await FirebaseAppCheck.instance.activate(
  //   webRecaptchaSiteKey: '6LcASwUeAAAAAE354ZxtASprrBMOGULn4QoqUnze',
  // );
  // await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  //region DEBUG
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  return FlutterSecureStorage().read(key: 'theme_mode').then((value) {
    return runApp(
      ProviderScope(
        child: MainWidget(themeMode: value ?? "AUTO"),
      ),
    );
  });
  //endregion DEBUG

  // await SentryFlutter.init((options) {
  //   options.dsn =
  //       'https://4a4d45710a98413eb686d20da5705ea0@o1014856.ingest.sentry.io/5980109';
  // }, appRunner: () {
  //   FlutterSecureStorage().read(key: 'theme_mode').then((value) {
  //     return runApp(
  //       ProviderScope(
  //         child: MainWidget(themeMode: value ?? "AUTO"),
  //       ),
  //     );
  //   });
  // }).onError((error, stackTrace) {
  //   print(error);
  // });

  // return FlutterSecureStorage().read(key: 'theme_mode').then((value) {
  //   return runApp(
  //     ProviderScope(
  //       child: MainWidget(themeMode: value ?? "AUTO"),
  //     ),
  //   );
  // });
}

class MainWidget extends ConsumerStatefulWidget {
  final String themeMode;

  const MainWidget({required this.themeMode, Key? key}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends ConsumerState<MainWidget> {
  var timer;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (timer == null) {
        timer = Timer.periodic(Duration(seconds: 10), (timer) async {
          final hangoutChanger = ref.watch(hangoutChangerProvider);
          if (hangoutChanger == null) return;
          await hangoutChanger.updateHeartbeat();
        });
      }
      ref.watch(appSettingProvider).getTheme(widget.themeMode);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);
    return MaterialApp.router(
      scrollBehavior: AppScrollBehavior(),
      title: Strings().appName,
      debugShowCheckedModeBanner: false,
      themeMode: appSettingModel.currentThemeMode,
      theme: AppTheme().mainTheme(context),
      darkTheme: AppTheme().darkTheme(context),
      routeInformationParser: NamedRoutes.router.routeInformationParser,
      routerDelegate: NamedRoutes.router.routerDelegate,
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
