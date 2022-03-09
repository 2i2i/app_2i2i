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
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import 'ui/commons/custom.dart';
import 'ui/screens/localization/app_localization.dart';

final platform = MethodChannel('app.2i2i/notification');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseNotifications();

  if (AppConfig().ALGORAND_NET == AlgorandNet.mainnet) {
    return SentryFlutter.init((options) {
      options.dsn =
          'https://4a4d45710a98413eb686d20da5705ea0@o1014856.ingest.sentry.io/5980109';
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

class MainWidget extends ConsumerStatefulWidget {
  final String themeMode;
  final String local;

  const MainWidget(this.local, {required this.themeMode, Key? key})
      : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends ConsumerState<MainWidget>
    with WidgetsBindingObserver {
  Timer? timer;
  RingingPageViewModel? ringingPageViewModel;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      window.addEventListener('focus', onFocus);
      window.addEventListener('blur', onBlur);
    }

    WidgetsBinding.instance?.addObserver(this);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await updateHeartbeat(Status.ONLINE);
      ref.watch(appSettingProvider).getTheme(widget.themeMode);
      ref.watch(appSettingProvider).getLocal(widget.local);
      await ref.watch(appSettingProvider).checkIfUpdateAvailable();

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // TODO the following is not working yet
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }

        if (message.data['action'] == 'update') {
          NamedRoutes.updateAvailable = true;
        }
      });
      // if (kIsWeb) {
      //   html.document.addEventListener('visibilitychange', (event) {
      //     if (html.document.visibilityState != 'visible') {
      //       //check after for 2 sec that is it still in background
      //       Future.delayed(Duration(seconds: 2)).then((value) async {
      //         if (html.document.visibilityState != 'visible') {
      //           await updateHeartbeat(Status.IDLE);
      //         }
      //       });
      //     } else {
      //       updateHeartbeat(Status.ONLINE);
      //     }
      //   });
      // }
      await Custom.deepLinks(context, mounted);
    });
  }

  void onFocus(Event e) {
    didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  void onBlur(Event e) {
    didChangeAppLifecycleState(AppLifecycleState.paused);
  }

  Future<void> updateHeartbeat(Status status) async {
    if (status == Status.IDLE) {
      if (timer?.isActive ?? false) timer!.cancel();
      final userChanger = ref.watch(userChangerProvider);
      if (userChanger == null) return;
      await userChanger.updateHeartbeatBackground();
    } else {
      if (timer?.isActive ?? false) timer!.cancel();
      timer = Timer.periodic(Duration(seconds: 10), (timer) async {
        final userChanger = ref.watch(userChangerProvider);
        if (userChanger == null) return;
        await userChanger.updateHeartbeatForeground();
      });
    }
  }

  @override
  void dispose() {
    // html.document.removeEventListener('visibilitychange', (event) => null);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        //region foreground
        updateHeartbeat(Status.ONLINE);
        //endregion
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        updateHeartbeat(Status.IDLE);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);

    return MaterialApp.router(
      scrollBehavior: AppScrollBehavior(),
      title: '2i2i',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', ''),
        Locale('es', ''),
        Locale('ar', ''),
        Locale("de", ''),
        Locale("ja", ''),
        Locale('ko', ''),
      ],
      locale: appSettingModel.locale,
      localizationsDelegates: [
        ApplicationLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
