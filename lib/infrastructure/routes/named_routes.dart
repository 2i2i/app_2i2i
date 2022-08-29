import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/app/error_page.dart';
import 'package:app_2i2i/ui/screens/block_list/block_list_page.dart';
import 'package:app_2i2i/ui/screens/favorites/favorite_list_page_holder.dart';
import 'package:app_2i2i/ui/screens/home/bottom_nav_bar.dart';
import 'package:app_2i2i/ui/screens/locked_user/locked_user_page.dart';
import 'package:app_2i2i/ui/screens/meeting_history/meeting_history_holder.dart';
import 'package:app_2i2i/ui/screens/my_account/recover_account_holder.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page_holder.dart';
import 'package:app_2i2i/ui/screens/my_user/user_bid_out_list_holder.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page_holder.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page_holder.dart';
import 'package:app_2i2i/ui/screens/web_view_screen/web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/screens/app_settings/app_settings_page_holder.dart';
import '../../ui/screens/app_settings/widgets/language_widget_holder.dart';
import '../../ui/screens/auth_screen/auth_screen_holder.dart';
import '../../ui/screens/create_bid/create_bid_page_Holder.dart';
import '../../ui/screens/faq/faq_screen_holder.dart';
import '../../ui/screens/my_account/create_local_account_holder.dart';
import '../../ui/screens/my_account/my_account_page_holder.dart';
import '../../ui/screens/my_user/my_user_page_holder.dart';
import '../../ui/screens/search/search_page_holder.dart';
import '../../ui/screens/sign_in/sign_in_page_holder.dart';
import '../../ui/screens/top/top_page_holder.dart';
import '../../ui/screens/user_setting/user_setting_holder.dart';
import 'app_routes.dart';

class NamedRoutes {
  static String? previousRouteLocation;
  static bool updateAvailable = false;
  static ValueNotifier<Map> showRating = ValueNotifier<Map>({'show': false});
  static GoRouter router = GoRouter(
    urlPathStrategy: UrlPathStrategy.path,
    refreshListenable: isUserLocked,
    redirect: (state) {
      if (state.location.contains(Routes.user.nameFromPath())) {
        currentIndex.value = 0;
      }
      final locked = isUserLocked.value;
      final goingToLocked = state.location == Routes.lock;
      bool validForPrevious = !goingToLocked && state.location != Routes.root && state.location != previousRouteLocation;
      if (validForPrevious) {
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
          String a = '$previousRouteLocation';
          previousRouteLocation = null;
          print('========== $a');
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
          child: getView(SearchPageHolder()),
          // child: getView(TestScreen()),
        ),
      ),
      GoRoute(
        name: Routes.myUser.nameFromPath(),
        path: Routes.myUser,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          // child: getView(TestScreen1()),
          child: getView(MyUserPageHolder()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.account.nameFromPath(),
        path: Routes.account,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(MyAccountPageHolder()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.faq.nameFromPath(),
        path: Routes.faq,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(FAQScreenHolder()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.setting.nameFromPath(),
        path: Routes.setting,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(AppSettingPageHolder()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.bidOut.nameFromPath(),
        path: Routes.bidOut,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(UserBidOutHolder()),
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
          String userId = '';
          if (state.extra is Map) {
            userId = (state.extra as Map)['uid'] ?? '';
          }
          if (state.params['uid'] is String) {
            userId = state.params['uid']!;
          }
          if (userId.trim().isNotEmpty) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(UserInfoPageHolder(B: userId)),
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
            child: getView(UserSettingHolder(fromBottomSheet: false)),
          );
        },
      ),
      GoRoute(
        name: Routes.language.nameFromPath(),
        path: Routes.language,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(LanguagePageHolder()),
          );
        },
      ),
      GoRoute(
        name: Routes.recover.nameFromPath(),
        path: Routes.recover,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(RecoverAccountPageHolder()),
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
              child: getView(RatingPageHolder(uid: state.params['uid']!)),
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
            child: getView(TopPageHolder()),
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
            child: getView(FavoriteListPageHolder()),
          );
        },
      ),
      GoRoute(
        name: Routes.createLocalAccount.nameFromPath(),
        path: Routes.createLocalAccount,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(CreateLocalAccountHolder()),
          );
        },
      ),
      GoRoute(
        name: Routes.meetingHistory.nameFromPath(),
        path: Routes.meetingHistory,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(MeetingHistoryHolder()),
          );
        },
      ),
      GoRoute(
        name: Routes.verifyPerhaps.nameFromPath(),
        path: Routes.verifyPerhaps,
        pageBuilder: (context, state) {
          if (state.extra is Map) {
            Map map = state.extra as Map;
            List<String> perhaps = map['perhaps'];
            if (map['account'] is LocalAccount) {
              LocalAccount account = map['account'];
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: getView(VerifyPerhapsPageHolder(account: account, perhaps: perhaps)),
              );
            }
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(NotFound()),
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
              child: getView(CreateBidPageHolder.fromObject(state.extra as CreateBidPageRouterObject)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: NotFound(),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: getView(Scaffold(body: ErrorPage(state.error))),
      );
    },
    errorBuilder: (context, state) {
      return getView(Scaffold(body: ErrorPage(state.error)));
    },
  );

  static Widget getView(Widget page) {
    Widget widget = SignInPageHolder(
      homePageBuilder: AuthScreenHolder(
        pageChild: page,
      ),
    );
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.watch(lockedUserViewModelProvider); // lockedUserViewModelProvider just needs to run
        /*if (kIsWeb && defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 500,
              height: 844,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget,
              ),
            ),
          );
        }*/
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
