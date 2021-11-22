import 'dart:async';

import 'package:app_2i2i/app/home/cv/cv_page.dart';
import 'package:app_2i2i/app/home/error_page.dart';
import 'package:app_2i2i/app/home/search/add_bid_page.dart';
import 'package:app_2i2i/app/home/search/user_page.dart';
import 'package:app_2i2i/app/locked_user/locked_user_page.dart';
import 'package:app_2i2i/providers/all_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:app_2i2i/app/setup_user/setup_user_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_2i2i/app/auth_widget.dart';
import 'package:app_2i2i/app/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_2i2i/app/logging.dart';
import 'app/home/about/about_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // DEBUG
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // DEBUG

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://4a4d45710a98413eb686d20da5705ea0@o1014856.ingest.sentry.io/5980109';
    },
    appRunner: () => runApp(ProviderScope(
      child: MainWidget(),
    )),
  );

  // runApp(ProviderScope(
  //   child: MainWidget(),
  // ));

  // runApp(ProviderScope(
  //   child: StaticHomePage(),
  // ));
}

class StaticHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text('2i2i'),
        ),
      ),
    );
  }
}

ThemeData mainTheme = ThemeData(
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color.fromRGBO(208, 226, 105, 1)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      primary: Color.fromRGBO(208, 226, 105, 1),
      onPrimary: Colors.black,
    ),
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.red,
  ),
  textTheme: const TextTheme(),
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme(
      primary: Color.fromRGBO(116, 117, 109, 1),
      primaryVariant: Color.fromRGBO(157, 193, 131, 1),
      secondary: Color.fromRGBO(199, 234, 70, 1),
      secondaryVariant: Color.fromRGBO(199, 234, 70, 1),
      surface: Colors.red,
      background: Colors.red,
      error: Colors.red,
      onPrimary: Color.fromRGBO(189, 239, 204, 1),
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.black,
      brightness: Brightness.light),
);

Widget AppPage() => AuthWidget(
      homePageBuilder: (_) => HomePage(),
      setupPageBuilder: (_) => SetupUserPage(),
    );

// class NoTransitionPage<T> extends CustomTransitionPage<T> {
//   const NoTransitionPage({required Widget child, LocalKey? key})
//       : super(transitionsBuilder: _transitionsBuilder, child: child, key: key);

//   static Widget _transitionsBuilder(
//           BuildContext context,
//           Animation<double> animation,
//           Animation<double> secondaryAnimation,
//           Widget child) =>
//       child;
// }

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

    return MaterialApp.router(
      routeInformationParser: _router.routeInformationParser,
      routerDelegate: _router.routerDelegate,
      title: '2i2i',
      debugShowCheckedModeBanner: false,
      theme: mainTheme,
    );
  }

  final _router = GoRouter(
    urlPathStrategy:
        UrlPathStrategy.path, // turn off the # in the URLs on the web
    refreshListenable: isUserLocked,
    // redirect to the login page if the user is not logged in
    redirect: (state) {
      log('GoRouter - redirect');
      final locked = isUserLocked.value;
      final goingToLocked = state.location == '/lock';
      log('GoRouter - redirect - locked=$locked goingToLocked=$goingToLocked');

      if (!locked && goingToLocked) return '/home';
      // if (!locked && goingToLocked) return '/home/search';
      if (locked && goingToLocked) return null;
      if (locked) return '/lock';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AppPage(),
        ),
      ),
      GoRoute(
        name: 'home',
        path: '/home',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: HomePage(),
        ),
      ),
      // GoRoute(
      //   name: 'home',
      //   path: '/home/:tab',
      //   pageBuilder: (context, state) {
      //     log('GoRoute - home - state.location=${state.location}');
      //     // if (state.location)
      //     return MaterialPage<void>(
      //       key: state.pageKey,
      //       child: HomePage(
      //           initialTab: EnumToString.fromString(
      //               HomePageTabs.values, state.params['tab']!)!),
      //     );
      //   },
      // ),
      GoRoute(
        name: 'user',
        path: '/user/:uid',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: UserPage(uid: state.params['uid']!),
        ),
      ),
      GoRoute(
        name: 'addbidpage',
        path: '/user/:uid/addbidpage',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AddBidPage(uid: state.params['uid']!),
        ),
      ),
      GoRoute(
        name: 'lock',
        path: '/lock',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: LockedUserPage(),
        ),
      ),
      GoRoute(
        name: 'imi',
        path: '/imi',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: CVPage(person: CVPerson.imi),
        ),
      ),
      GoRoute(
        name: 'solli',
        path: '/solli',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: CVPage(person: CVPerson.solli),
        ),
      ),
      GoRoute(
        name: 'about',
        path: '/about',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AboutPage(),
        ),
      ),
      // GoRoute(
      //   name: 'addbid',
      //   path: '/user/:uid/addbid',
      //   pageBuilder: (context, state) => NoTransitionPage<void>(
      //     key: state.pageKey,
      //     child: FutureBuilder(
      //       future: (state.extra! as AddBidPageViewModel).addBid(),
      //       builder: (context, snapshot) {
      //         if (snapshot.hasError)
      //           return ErrorPage(snapshot.error as Exception?);
      //         if (snapshot.hasData)
      //           return AddBidPage(uid: state.params['uid']!);
      //         return WaitPage();
      //       },
      //     ),
      //   ),
      // ),
    ],
    errorPageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: ErrorPage(state.error),
    ),
  );
}
