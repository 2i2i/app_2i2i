import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/profile_icon.dart';
import 'package:app_2i2i/ui/screens/app/auth_widget.dart';
import 'package:app_2i2i/ui/screens/app_settings/app_settings_page.dart';
import 'package:app_2i2i/ui/screens/block_and_friends/friends_list_page.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/faq/faq_page.dart';
import 'package:app_2i2i/ui/screens/hangout_setting/hangout_setting.dart';
import 'package:app_2i2i/ui/screens/home/error_page.dart';
import 'package:app_2i2i/ui/screens/locked_user/locked_user_page.dart';
import 'package:app_2i2i/ui/screens/my_account/create_local_account.dart';
import 'package:app_2i2i/ui/screens/my_account/my_account_page.dart';
import 'package:app_2i2i/ui/screens/my_account/recover_account.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page.dart';
import 'package:app_2i2i/ui/screens/my_hangout/my_hangout_page.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/search/search_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

class NamedRoutes {
  static GoRouter router = GoRouter(
    urlPathStrategy: UrlPathStrategy.path,
    refreshListenable: isUserLocked,
    redirect: (state) {
      final locked = isUserLocked.value;

      final goingToLocked = state.location == Routes.lock;

      if (locked && goingToLocked) {
        return null;
      } else if (!locked && goingToLocked) {
        return Routes.root;
      } else if (locked) {
        return Routes.lock;
      }
      return null;
    },
    initialLocation: Routes.root,
    routes: [
      GoRoute(
        name: Routes.root.nameFromPath(),
        path: Routes.root,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(SearchPage()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.myHangout.nameFromPath(),
        path: Routes.myHangout,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(MyHangoutPage()),
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
          child: getView(FAQPage()),
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
        name: Routes.lock.nameFromPath(),
        path: Routes.lock,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(LockedUserPage()),
        ),
      ),
      GoRoute(
        name: Routes.user.nameFromPath(),
        path: Routes.user,
        pageBuilder: (context, state) {
          String userId = '';
          if(state.extra is Map){
            userId = (state.extra as Map)['uid']??'';
          }
          if (state.params['uid'] is String) {
            userId = state.params['uid']!;
          }
          if(userId.trim().isNotEmpty){
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(UserInfoPage(uid: userId)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.hangoutSetting.nameFromPath(),
        path: Routes.hangoutSetting,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView( HangoutSetting(fromBottomSheet: false)),
          );
        },
      ),
      GoRoute(
        name: Routes.recover.nameFromPath(),
        path: Routes.recover,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView( RecoverAccountPage()),
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
              child: getView( RatingPage(uid: state.params['uid']!)),
            );
          }
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView( NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.top.nameFromPath(),
        path: Routes.top,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView( TopPage()),
          );
        },
      ),
      GoRoute(
        name: Routes.blocks.nameFromPath(),
        path: Routes.blocks,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView( FriendsListPage(isForBlockedUser: true)),
          );
        },
      ),
      GoRoute(
        name: Routes.favorites.nameFromPath(),
        path: Routes.favorites,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(FriendsListPage(isForBlockedUser: false)),
          );
        },
      ),
      GoRoute(
        name: Routes.createLocalAccount.nameFromPath(),
        path: Routes.createLocalAccount,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(CreateLocalAccount()),
          );
        },
      ),

      GoRoute(
        name: Routes.verifyPerhaps.nameFromPath(),
        path: Routes.verifyPerhaps,
        pageBuilder: (context, state) {
          print('state ${state.extra}');
          if(state.extra is Map){
            Map map = state.extra as Map;
            List<String> perhaps = map['perhaps'];
            if(map['account'] is LocalAccount) {
              LocalAccount account = map['account'];
              return NoTransitionPage<void>(
                key: state.pageKey,
                child: getView(VerifyPerhapsPage(perhaps, account)),
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
          if (state.extra is Hangout) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(CreateBidPage(hangout: state.extra as Hangout)),
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
      print('state.error ${state.error}');
      return NoTransitionPage<void>(
        key: state.pageKey,
        child: getView(Scaffold(body: ErrorPage(state.error))),
      );
    },
    errorBuilder: (context, state) {
      print('state.error ${state.error}');
      return getView(Scaffold(body: ErrorPage(state.error)));
    },
  );

  static ValueNotifier<int> currentIndex = ValueNotifier(0);

  static Widget getView(Widget page) {
    bool isMobile = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
    Widget widget = AuthWidget(
      homePageBuilder: (_) => Scaffold(
        body: page,
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: isUserLocked,
          builder: (BuildContext context, value, Widget? child) {
            if(value == false){
              return Container(
                padding: const EdgeInsets.all(4.0),
                child: ValueListenableBuilder(
                  valueListenable: currentIndex,
                  builder: (BuildContext context, int value, Widget? child) {
                    return BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: value,
                      onTap: (i) {
                        currentIndex.value = i;
                        switch (i) {
                          case 0:
                            context.go(Routes.root);
                            break;
                          case 1:
                            context.go(Routes.myHangout);
                            break;
                          case 2:
                            context.go(Routes.account);
                            break;
                          case 3:
                            context.go(Routes.faq);
                            break;
                          case 4:
                            context.go(Routes.setting);
                            break;
                        }
                      },
                      items: [
                        BottomNavigationBarItem(
                          label: Strings().home,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                                'assets/icons/house.svg',
                                color: Theme.of(context).colorScheme.secondary
                            ),
                          ),
                          icon: SvgPicture.asset('assets/icons/house.svg'),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().profile,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                                'assets/icons/person.svg',
                                color: Theme.of(context).colorScheme.secondary
                            ),
                          ),
                          icon: ProfileIcon(),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().account,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                                'assets/icons/account.svg',
                                color: Theme.of(context).colorScheme.secondary
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset('assets/icons/account.svg'),
                          ),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().faq,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                                'assets/icons/help.svg',
                                color: Theme.of(context).colorScheme.secondary
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset('assets/icons/help.svg'),
                          ),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().settings,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset(
                                'assets/icons/setting.svg',
                                color: Theme.of(context).colorScheme.secondary
                            ),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset('assets/icons/setting.svg'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }
            return Container(
              height: 0,
            );
          },
        ),
      ),
    );
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        if (kIsWeb && !isMobile) {
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
