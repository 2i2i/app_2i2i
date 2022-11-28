import 'dart:async';
import 'dart:convert';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
import 'package:universal_html/html.dart' as ht;

import 'infrastructure/data_access_layer/services/firebase_notifications.dart';
import 'infrastructure/models/meeting_model.dart';
import 'infrastructure/providers/all_providers.dart';
import 'infrastructure/providers/ringing_provider/ringing_page_view_model.dart';
import 'infrastructure/routes/named_routes.dart';
import 'ui/commons/custom.dart';
import 'ui/screens/app/wait_page.dart';
import 'ui/screens/localization/app_localization.dart';

final platform = MethodChannel('app.2i2i/notification');

Future<void> main() async {
  log('common main');

  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  if (!kIsWeb) {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(webRecaptchaSiteKey: '6LcASwUeAAAAAE354ZxtASprrBMOGULn4QoqUnze');
  } else {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs",
            authDomain: "i2i-test.firebaseapp.com",
            projectId: "i2i-test",
            storageBucket: "i2i-test.appspot.com",
            messagingSenderId: "453884442411",
            appId: "1:453884442411:web:dad8591e5125eb8998776e"));
  }

  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

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

class MainWidget extends ConsumerStatefulWidget {
  final String themeMode;
  final String local;

  const MainWidget(this.local, {required this.themeMode, Key? key}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends ConsumerState<MainWidget> with WidgetsBindingObserver {
  Timer? timer;
  RingingPageViewModel? ringingPageViewModel;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    if (kIsWeb) {
      ht.window.addEventListener('focus', onFocus);
      ht.window.addEventListener('blur', onBlur);
    }

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await updateHeartbeat(Status.ONLINE);
      ref.read(appSettingProvider).getTheme(widget.themeMode);
      ref.read(appSettingProvider).getLocal(widget.local);
      await ref.read(appSettingProvider).checkIfUpdateAvailable();

      if (!kIsWeb) {
        platform.setMethodCallHandler((MethodCall methodCall) async {
          Map<String, dynamic> notificationData = jsonDecode(methodCall.arguments['meetingInfo']) as Map<String, dynamic>;
          try {
            if (notificationData.isNotEmpty) {
              final meetingChanger = ref.read(meetingChangerProvider);
              switch (methodCall.method) {
                case 'CUT':
                  meetingChanger.endMeeting(notificationData, MeetingStatus.END_A);
                  break;
                case 'ANSWER':
                  await meetingChanger.acceptMeeting(notificationData['meetingId']);
                  ref.read(lockedUserViewModelProvider);
                  break;
                case 'MUTE':
                  break;
                default:
                  throw MissingPluginException('notImplemented');
              }
            }
          } catch (e) {
            log("$e");
          }
        });
      }
    });
    Custom.deepLinks(context, mounted);
    super.initState();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    ref.read(appSettingProvider).setInternetStatus(result != ConnectivityResult.none);
  }

  void onFocus(ht.Event e) {
    didChangeAppLifecycleState(AppLifecycleState.resumed);
  }

  void onBlur(ht.Event e) {
    didChangeAppLifecycleState(AppLifecycleState.paused);
  }

  Future<void> updateHeartbeat(Status status) async {
    // log(X + 'updateHeartbeat status=$status');
    final userChanger = ref.read(userChangerProvider);
    timer?.cancel();

    if (status == Status.IDLE) {
      userChanger?.updateHeartbeatBackground(setStatus: true); // immediate
      timer = Timer.periodic(Duration(seconds: 10), (timer) async {
        final userChanger = ref.read(userChangerProvider);
        userChanger?.updateHeartbeatBackground();
      });
    } else if (status == Status.ONLINE) {
      userChanger?.updateHeartbeatForeground(setStatus: true); // immediate
      timer = Timer.periodic(Duration(seconds: 10), (timer) async {
        final userChanger = ref.read(userChangerProvider);
        userChanger?.updateHeartbeatForeground(setStatus: true);
      });
    }
  }

  @override
  void dispose() {
    // html.document.removeEventListener('visibilitychange', (event) => null);
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
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
        log(X + 'didChangeAppLifecycleState state=$state');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);
    log(Y + 'Balance: refresh main');
    return MaterialApp.router(
      scrollBehavior: AppScrollBehavior(),
      title: '2i2i',
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        // return TestScreen();
        return widget ?? WaitPage();
      },
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
      routeInformationProvider: NamedRoutes.router.routeInformationProvider,
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
