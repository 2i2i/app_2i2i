import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/app/auth_widget.dart';
import 'package:app_2i2i/ui/screens/block_and_friends/friends_list_page.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/hangout_setting/hangout_setting.dart';
import 'package:app_2i2i/ui/screens/home/error_page.dart';
import 'package:app_2i2i/ui/screens/home/home_page.dart';
import 'package:app_2i2i/ui/screens/locked_user/locked_user_page.dart';
import 'package:app_2i2i/ui/screens/my_account/create_local_account.dart';
import 'package:app_2i2i/ui/screens/my_account/recover_account.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/search/search_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        path: Routes.root,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: getView(
            AuthWidget(
              homePageBuilder: (_) => SearchPage(),
            ),
          ),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.lock.nameFromPath(),
        path: Routes.lock,
        pageBuilder: (context, state) => MaterialPage<void>(
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
            return MaterialPage<void>(
              key: state.pageKey,
              child: getView(UserInfoPage(uid: userId)),
            );
          }
          return MaterialPage<void>(
            key: state.pageKey,
            child: getView(NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.hangoutSetting.nameFromPath(),
        path: Routes.hangoutSetting,
        pageBuilder: (context, state) {
          return MaterialPage<void>(
            key: state.pageKey,
            child: getView( HangoutSetting(fromBottomSheet: false)),
          );
        },
      ),
      GoRoute(
        name: Routes.recover.nameFromPath(),
        path: Routes.recover,
        pageBuilder: (context, state) {
          return MaterialPage<void>(
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
            return MaterialPage<void>(
              key: state.pageKey,
              child: getView( RatingPage(uid: state.params['uid']!)),
            );
          }
          return MaterialPage<void>(
            key: state.pageKey,
            child: getView( NotFound()),
          );
        },
      ),
      GoRoute(
        name: Routes.top.nameFromPath(),
        path: Routes.top,
        pageBuilder: (context, state) {
          return MaterialPage<void>(
            key: state.pageKey,
            child: getView( TopPage()),
          );
        },
      ),
      GoRoute(
        name: Routes.blocks.nameFromPath(),
        path: Routes.blocks,
        pageBuilder: (context, state) {
          return MaterialPage<void>(
            key: state.pageKey,
            child: getView( FriendsListPage(isForBlockedUser: true)),
          );
        },
      ),
      GoRoute(
        name: Routes.favorites.nameFromPath(),
        path: Routes.favorites,
        pageBuilder: (context, state) {
          return MaterialPage<void>(
            key: state.pageKey,
            child: getView(FriendsListPage(isForBlockedUser: false)),
          );
        },
      ),
      GoRoute(
        name: Routes.createLocalAccount.nameFromPath(),
        path: Routes.createLocalAccount,
        pageBuilder: (context, state) {
          return MaterialPage<void>(
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
              return MaterialPage<void>(
                key: state.pageKey,
                child: getView(VerifyPerhapsPage(perhaps, account)),
              );
            }
          }
          return MaterialPage<void>(
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
            return MaterialPage<void>(
              key: state.pageKey,
              child: getView(CreateBidPage(hangout: state.extra as Hangout)),
            );
          }
          return MaterialPage<void>(
            key: state.pageKey,
            child: NotFound(),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) {
      print('state.error ${state.error}');
      return MaterialPage<void>(
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
    bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    if (kIsWeb && !isMobile) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 500,
          height: 844,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scaffold(
              body: page,
              bottomNavigationBar: Container(
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
                            context.go(Routes.favorites);
                            break;
                          case 2:
                            context.go(Routes.blocks);
                            break;
                          case 3:
                            context.go(Routes.user);
                            break;
                          case 4:
                            context.go(Routes.root);
                            break;
                        }
                      },
                      items: [
                        BottomNavigationBarItem(
                          label: Strings().home,
                          icon: SvgPicture.asset('assets/icons/house.svg'),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().profile,
                          icon: ProfileIcon(),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().account,
                          icon: SvgPicture.asset('assets/icons/account.svg'),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().faq,
                          icon: SvgPicture.asset('assets/icons/help.svg'),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().settings,
                          icon: SvgPicture.asset('assets/icons/setting.svg'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }
    return page;
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
