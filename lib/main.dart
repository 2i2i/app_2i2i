import 'dart:async';

import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/app/auth_widget.dart';
import 'package:app_2i2i/pages/home/home_page.dart';
import 'package:app_2i2i/pages/setup_user/ui/setup_user_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'constants/strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //region DEBUG
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //endregion DEBUG
  await SentryFlutter.init((options) {
      options.dsn = 'https://4a4d45710a98413eb686d20da5705ea0@o1014856.ingest.sentry.io/5980109';
    },
    appRunner: () => runApp(
      ProviderScope(
        child: MainWidget(),
      ),
    ),
  );
}

// TODO MainWidget is not immutable anymore
class MainWidget extends ConsumerWidget {
  Timer? T;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // User heartbeat timer
    if (T == null) {
      T = Timer.periodic(Duration(seconds: 10), (timer) async {
        // log('UserModel Timer');
        final userModelChanger = ref.watch(userModelChangerProvider);
        if (userModelChanger == null) return;
        await userModelChanger.updateHeartbeat();
      });
    }
    return MaterialApp(
      home: AuthWidget(
        homePageBuilder: (_) => HomePage(),
        setupPageBuilder: (_) => SetupUserPage(),
      ),
      title: Strings().appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().mainTheme,
    );
  }
}
