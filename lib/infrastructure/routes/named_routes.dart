import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/screens/app/error_page.dart';
import 'package:app_2i2i/ui/screens/app_settings/app_settings_page.dart';
import 'package:app_2i2i/ui/screens/app_settings/widgets/language_widget.dart';
import 'package:app_2i2i/ui/screens/block_list/block_list_page.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/faq/faq_screen.dart';
import 'package:app_2i2i/ui/screens/favorites/favorite_list_page.dart';
import 'package:app_2i2i/ui/screens/home/bottom_nav_bar.dart';
import 'package:app_2i2i/ui/screens/locked_user/locked_user_page.dart';
import 'package:app_2i2i/ui/screens/meeting_history/meeting_history.dart';
import 'package:app_2i2i/ui/screens/my_account/my_account_page.dart';
import 'package:app_2i2i/ui/screens/my_user/my_user_page.dart';
import 'package:app_2i2i/ui/screens/my_user/user_bid_out_list.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/search/search_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:app_2i2i/ui/screens/user_setting/user_setting.dart';
import 'package:app_2i2i/ui/screens/web_view_screen/web_view_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/screens/auth_screen/auth_screen.dart';
import '../../ui/screens/redeem_coin/redeem_coin_page.dart';
import '../../ui/screens/sign_in/sign_in_page.dart';
import 'app_routes.dart';

class NamedRoutes {
  static String? previousRouteLocation;
  static bool updateAvailable = false;
  static ValueNotifier<Map> showRating = ValueNotifier<Map>({'show': false});
  static GoRouter router = GoRouter(
    // urlPathStrategy: UrlPathStrategy.path,
    refreshListenable: isUserLocked,
    redirect: (context, state) {
      bool isTrue = previousRouteLocation != '/user/${userIdNav.value}' && previousRouteLocation != Routes.user;
      if (isTrue && userIdNav.value.isNotEmpty) {
        previousRouteLocation = Routes.user;
        return '/user/${userIdNav.value}';
      }
      if (state.location.contains(Routes.user.nameFromPath())) {
        currentIndex.value = 0;
      }
      final locked = isUserLocked.value;
      final goingToLocked = state.location == Routes.lock;
      bool validForPrevious = !goingToLocked /*&& state.location != Routes.root*/ && state.location != previousRouteLocation;
      if (validForPrevious && state.location.nameFromPath().isNotEmpty) {
        previousRouteLocation = state.location;
      }
      if (locked && goingToLocked) {
        return null;
      } else if (!locked && goingToLocked) {
        if (previousRouteLocation?.isNotEmpty ?? false) {
          return previousRouteLocation;
        }
        return Routes.root;
      } else if (locked) {
        return Routes.lock;
      }
      if (previousRouteLocation is String) {
        if (showRating.value['show'] == true) {
          previousRouteLocation = null;
          return null;
        }
      }
      return null;
    },
    initialLocation: Routes.myUser,
    routes: [
      GoRoute(
        name: Routes.root.nameFromPath(),
        path: Routes.root,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(SearchPage()),
          // child: getView(TestScreen()),
          // child: getView(InstagramLogin()),
        ),
      ),
      GoRoute(
        name: Routes.myUser.nameFromPath(),
        path: Routes.myUser,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          // child: getView(TestScreen()),
          child: getView(MyUserPage()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.account.nameFromPath(),
        path: Routes.account,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(MyAccountPage()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.faq.nameFromPath(),
        path: Routes.faq,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(FAQScreen()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.setting.nameFromPath(),
        path: Routes.setting,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(AppSettingPage()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.bidOut.nameFromPath(),
        path: Routes.bidOut,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(UserBidOut()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.lock.nameFromPath(),
        path: Routes.lock,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(LockedUserPage(
            onHangPhone: (uid, meetingId) async {
              await Future.delayed(Duration(milliseconds: 500));
              showRating.value = {
                'show': true,
                'otherUid': uid,
                'meetingId': meetingId,
              };
            },
          )),
        ),
      ),
      GoRoute(
        name: Routes.user.nameFromPath(),
        path: Routes.user,
        pageBuilder: (context, state) {
          previousRouteLocation = state.location;
          String userId = '';
          if (userIdNav.value.isNotEmpty) {
            userId = userIdNav.value;
            userIdNav.value = '';
          }
          if (state.extra is Map) {
            userId = (state.extra as Map)['uid'] ?? '';
          }
          if (state.params['uid'] is String) {
            userId = state.params['uid']!;
          }
          print('uri userId $userId');
          if (userId.trim().isNotEmpty) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(UserInfoPage(B: userId)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.userSetting.nameFromPath(),
        path: Routes.userSetting,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(UserSetting(fromBottomSheet: false)),
          );
        },
      ),
      GoRoute(
        name: Routes.language.nameFromPath(),
        path: Routes.language,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(LanguagePage()),
          );
        },
      ),
      GoRoute(
        name: Routes.webView.nameFromPath(),
        path: Routes.webView,
        pageBuilder: (context, state) {
          if (state.params['walletAddress'] is String) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(WebViewScreen(walletAddress: state.params['walletAddress']!)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.ratings.nameFromPath(),
        path: Routes.ratings,
        pageBuilder: (context, state) {
          if (state.params['uid'] is String) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(RatingPage(uid: state.params['uid']!)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.top.nameFromPath(),
        path: Routes.top,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(TopPage()),
          );
        },
      ),
      GoRoute(
        name: Routes.blocks.nameFromPath(),
        path: Routes.blocks,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(BlockListPage()),
          );
        },
      ),
      GoRoute(
        name: Routes.favorites.nameFromPath(),
        path: Routes.favorites,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(FavoriteListPage()),
          );
        },
      ),
      GoRoute(
        name: Routes.meetingHistory.nameFromPath(),
        path: Routes.meetingHistory,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(MeetingHistory()),
          );
        },
      ),
      GoRoute(
        name: Routes.createBid.nameFromPath(),
        path: Routes.createBid,
        pageBuilder: (context, state) {
          if (state.extra is CreateBidPageRouterObject) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(CreateBidPage.fromObject(state.extra as CreateBidPageRouterObject)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: NotFound(),
          );
        },
      ),
      GoRoute(
        name: Routes.redeemCoin.nameFromPath(),
        path: Routes.redeemCoin,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(RedeemCoinPage()),
        ),
      ),
    ],
    errorPageBuilder: (context, state) {
      print('error ${state.error?.toString()}');
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: getView(Scaffold(body: ErrorPage(state.error))),
      );
    },
    errorBuilder: (context, state) {
      print('error ${state.error?.toString()}');
      return getView(Scaffold(body: ErrorPage(state.error)));
    },
  );

  static Widget getView(Widget page) {
    Widget widget = SignInPage(
      homePageBuilder: (context) => AuthScreen(pageChild: page, updateAvailable: updateAvailable),
    );
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.watch(lockedUserViewModelProvider); // lockedUserViewModelProvider just needs to run
        if (defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android && kIsWeb) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: Custom.webWidth(context),
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget,
              ),
            ),
          );
        }
        return widget;
      },
    );
  }
}

class NotFound extends StatelessWidget {
  const NotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404 - Page Not Found'),
      ),
    );
  }
}
