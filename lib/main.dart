import 'dart:async';

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/ui/test_screen.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'infrastructure/commons/strings.dart';
import 'infrastructure/providers/all_providers.dart';
import 'ui/screens/app/auth_widget.dart';
import 'ui/screens/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb) {
    await Firebase.initializeApp();
  }
  // await Firebase.initializeApp(
  //     /*options: DefaultFirebaseConfig.platformOptions*/);
  // await FirebaseAppCheck.instance.activate(
  //   webRecaptchaSiteKey: '6LcASwUeAAAAAE354ZxtASprrBMOGULn4QoqUnze',
  // );
  // await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  //region DEBUG
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //endregion DEBUG
  await SentryFlutter.init((options) {
    options.dsn =
        'https://4a4d45710a98413eb686d20da5705ea0@o1014856.ingest.sentry.io/5980109';
  }, appRunner: () {
    FlutterSecureStorage().read(key: 'theme_mode').then((value) {
      return runApp(
        ProviderScope(
          child: MainWidget(themeMode: value ?? "AUTO"),
        ),
      );
    });
  });
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
          final userModelChanger = ref.watch(userModelChangerProvider);
          if (userModelChanger == null) return;
          await userModelChanger.updateHeartbeat();
        });
      }
      ref.watch(appSettingProvider).getTheme(widget.themeMode);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var appSettingModel = ref.watch(appSettingProvider);
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      home: getView(),
      // home:TestScreen(),
      title: Strings().appName,
      debugShowCheckedModeBanner: false,
      // themeMode: appSettingModel.currentThemeMode,
      themeMode: ThemeMode.light,

      theme: AppTheme().mainTheme(context),
      darkTheme: AppTheme().darkTheme(context),
    );
  }

  Widget getView() {
    if (kIsWeb) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 390,
          height: 844,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AuthWidget(
              homePageBuilder: (_) => HomePage(),
            ),
          ),
        ),
      );
    }
    return AuthWidget(
      homePageBuilder: (_) => HomePage(),
      // homePageBuilder: (_) => TestScreen(),
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
