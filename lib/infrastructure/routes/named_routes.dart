import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/app_settings/app_settings_page.dart';
import 'package:app_2i2i/ui/screens/app_settings/widgets/language_widget.dart';
import 'package:app_2i2i/ui/screens/block_list/block_list_page.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/cv/cv_page.dart';
import 'package:app_2i2i/ui/screens/cv/cv_page_data.dart';
import 'package:app_2i2i/ui/screens/faq/faq_page.dart';
import 'package:app_2i2i/ui/screens/favorites/favorite_list_page.dart';
import 'package:app_2i2i/ui/screens/user_setting/user_setting.dart';
import 'package:app_2i2i/ui/screens/home/bottom_nav_bar.dart';
import 'package:app_2i2i/ui/screens/home/error_page.dart';
import 'package:app_2i2i/ui/screens/locked_user/locked_user_page.dart';
import 'package:app_2i2i/ui/screens/my_account/create_local_account.dart';
import 'package:app_2i2i/ui/screens/my_account/my_account_page.dart';
import 'package:app_2i2i/ui/screens/my_account/recover_account.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page.dart';
import 'package:app_2i2i/ui/screens/my_user/user_bid_out_list.dart';
import 'package:app_2i2i/ui/screens/meeting_history/meeting_history.dart';
import 'package:app_2i2i/ui/screens/my_user/my_user_page.dart';
import 'package:app_2i2i/ui/screens/rating/add_rating_page.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/search/search_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ui/screens/sign_in/sign_in_page.dart';
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
      bool validForPrevious = !goingToLocked &&
          state.location != Routes.root &&
          state.location != previousRouteLocation;
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
    initialLocation: Routes.root,
    routes: [
      GoRoute(
        name: Routes.root.nameFromPath(),
        path: Routes.root,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(SearchPage()),
          // child: getView(WaitPage()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.myUser.nameFromPath(),
        path: Routes.myUser,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
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
          child: getView(FAQPage()),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.imi.nameFromPath(),
        path: Routes.imi,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(CVPage(
            person: CVPerson.imi,
          )),
          // child: Scaffold(),
        ),
      ),
      GoRoute(
        name: Routes.solli.nameFromPath(),
        path: Routes.solli,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: getView(CVPage(
            person: CVPerson.solli,
          )),
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
            onHangPhone: (uid, meetingId) {
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
        name: Routes.recover.nameFromPath(),
        path: Routes.recover,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(RecoverAccountPage()),
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
        name: Routes.verifyPerhaps.nameFromPath(),
        path: Routes.verifyPerhaps,
        pageBuilder: (context, state) {
          print('state ${state.extra}');
          if (state.extra is Map) {
            Map map = state.extra as Map;
            List<String> perhaps = map['perhaps'];
            if (map['account'] is LocalAccount) {
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
          if (state.extra is CreateBidPageRouterObject) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: getView(CreateBidPage.fromObject(
                  state.extra as CreateBidPageRouterObject)),
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

  static Widget getView(Widget page) {
    Widget widget = SignInPage(
      homePageBuilder: (context) => Scaffold(
        appBar: AppConfig().ALGORAND_NET == AlgorandNet.mainnet
            ? null
            : AppBar(
                leading: Container(),
                toolbarHeight: 20,
                title: Text(AlgorandNet.testnet.name +
                    ' - v39' +
                    (updateAvailable ? ' - update: reload page' : '')),
                titleTextStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(color: Theme.of(context).cardColor),
                centerTitle: true,
                backgroundColor: Colors.green,
              ),
        body: page,
        bottomSheet: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final uid = ref.watch(myUIDProvider);
            if (uid != null) {
              final userProviderVal = ref.watch(userProvider(uid));
              bool isLoaded = !(haveToWait(userProviderVal));
              if (isLoaded && userProviderVal.asData?.value is UserModel) {
                final UserModel user = userProviderVal.asData!.value;
                if (user.name.trim().isEmpty) {
                  return BottomSheet(
                    enableDrag: true,
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    elevation: 12,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        onWillPop: () {
                          return Future.value(true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: UserSetting(
                            fromBottomSheet: true,
                          ),
                        ),
                      );
                    },
                    onClosing: () {},
                  );
                }
              }
            }
            return AddRatingPage(showRating: showRating);
          },
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.watch(lockedUserViewModelProvider); // lockedUserViewModelProvider just needs to run
        if (kIsWeb && defaultTargetPlatform != TargetPlatform.iOS && defaultTargetPlatform != TargetPlatform.android) {
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
