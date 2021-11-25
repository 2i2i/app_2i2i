import 'package:app_2i2i/pages/add_bid/ui/add_bid_page.dart';
import 'package:app_2i2i/pages/app/auth_widget.dart';
import 'package:app_2i2i/pages/home/error_page.dart';
import 'package:app_2i2i/pages/home/home_page.dart';
import 'package:app_2i2i/pages/user_bid/ui/user_page.dart';
import 'package:app_2i2i/pages/about/about_page.dart';
import 'package:app_2i2i/pages/app_settings/ui/app_settings_page.dart';
import 'package:app_2i2i/pages/cv/cv_page.dart';
import 'package:app_2i2i/pages/locked_user/ui/locked_user_page.dart';
import 'package:app_2i2i/pages/setup_user/ui/setup_user_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class NamedRoutes{
  static const INITIAL = Routes.ROOT;

  static final router = GoRouter(
    urlPathStrategy: UrlPathStrategy.path, // turn off the # in the URLs on the web
    refreshListenable: isUserLocked, // redirect to the login page if the user is not logged in
    redirect: (state) {
      log('GoRouter - redirect');
      final locked = isUserLocked.value;
      final goingToLocked = state.location == Routes.LOCK;
      log('GoRouter - redirect - locked=$locked goingToLocked=$goingToLocked');

      if (!locked && goingToLocked) return '/home';
      // if (!locked && goingToLocked) return '/home/search';
      if (locked && goingToLocked) return null;
      if (locked) return Routes.LOCK;

      return null;
    },
    routes: [
      GoRoute(
        path: INITIAL,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AuthWidget(
            homePageBuilder: (_) => HomePage(),
            setupPageBuilder: (_) => SetupUserPage(),
          ),
        ),
      ),
      GoRoute(
        name: 'home',
        path: Routes.HOME,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: HomePage(),
        ),
      ),
      GoRoute(
        name: 'app_setting',
        path: Routes.AppSetting,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AppSettingPage(),
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
        path: Routes.USER,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: UserPage(uid: state.params['uid']!),
        ),
      ),
      GoRoute(
        name: 'addbidpage',
        path: Routes.BIDPAGE,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: AddBidPage(uid: state.params['uid']!),
        ),
      ),
      GoRoute(
        name: 'lock',
        path: Routes.LOCK,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: LockedUserPage(),
        ),
      ),
      GoRoute(
        name: 'imi',
        path: Routes.IMI,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: CVPage(person: CVPerson.imi),
        ),
      ),
      GoRoute(
        name: 'solli',
        path: Routes.SOLLI,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: CVPage(person: CVPerson.solli),
        ),
      ),
      GoRoute(
        name: 'about',
        path: Routes.ABOUT,
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