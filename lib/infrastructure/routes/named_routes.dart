import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/profile_icon.dart';
import 'package:app_2i2i/ui/screens/app/auth_widget.dart';
import 'package:app_2i2i/ui/screens/app_settings/app_settings_page.dart';
import 'package:app_2i2i/ui/screens/block_list/block_list_page.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/faq/faq_page.dart';
import 'package:app_2i2i/ui/screens/favorites/favorite_list_page.dart';
import 'package:app_2i2i/ui/screens/hangout_setting/hangout_setting.dart';
import 'package:app_2i2i/ui/screens/home/error_page.dart';
import 'package:app_2i2i/ui/screens/locked_user/locked_user_page.dart';
import 'package:app_2i2i/ui/screens/my_account/create_local_account.dart';
import 'package:app_2i2i/ui/screens/my_account/my_account_page.dart';
import 'package:app_2i2i/ui/screens/my_account/recover_account.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page.dart';
import 'package:app_2i2i/ui/screens/my_hangout/hangout_bid_out_list.dart';
import 'package:app_2i2i/ui/screens/my_hangout/meeting_history_list.dart';
import 'package:app_2i2i/ui/screens/my_hangout/my_hangout_page.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/search/search_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

class NamedRoutes {
  static ValueNotifier<Map> showRating = ValueNotifier<Map>({'show': false});
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
        name: Routes.hangoutSetting.nameFromPath(),
        path: Routes.hangoutSetting,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: getView(HangoutSetting(fromBottomSheet: false)),
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
            child: getView(MeetingHistoryList()),
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

  static ValueNotifier<int> currentIndex = ValueNotifier(0);

  static Widget getView(Widget page) {
    var feedbackController = TextEditingController();
    Widget widget = AuthWidget(
      homePageBuilder: (context) => Scaffold(
        appBar: AppBar(
          leading: Container(),
          toolbarHeight: 20,
          title: Text(AlgorandNet.testnet.name),
          titleTextStyle: Theme.of(context).textTheme.bodyText2?.copyWith(
            color: Theme.of(context).cardColor
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: page,
        bottomSheet: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final uid = ref.watch(myUIDProvider);
            if (uid != null) {
              final hangoutProviderVal = ref.watch(hangoutProvider(uid));
              bool isLoaded = !(haveToWait(hangoutProviderVal));
              if (isLoaded && hangoutProviderVal.asData?.value is Hangout) {
                final Hangout hangout = hangoutProviderVal.asData!.value;
                if (hangout.name.trim().isEmpty) {
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
                          child: HangoutSetting(
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
            return ValueListenableBuilder(
              valueListenable: showRating,
              builder: (BuildContext context, Map value, Widget? child) {
                child ??= Container();
                return Visibility(
                  visible: value['show'] ?? false,
                  child: child,
                );
              },
              child: BottomSheet(
                backgroundColor: Theme.of(context).cardColor,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                onClosing: () {},
                builder: (BuildContext context) {
                  var otherUid = showRating.value['otherUid'];
                  var meetingId = showRating.value['meetingId'];
                  double rating = 1.0;
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Strings().appRatingTitle,
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        SizedBox(height: 8),
                        Text(
                          Strings().appRatingMessage,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20, top: 8),
                          child: RatingBar.builder(
                            initialRating: rating * 5.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            glowColor: Colors.white,
                            unratedColor: Colors.grey.shade300,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (starRating) {
                              rating = starRating / 5.0;
                            },
                          ),
                        ),
                        TextFormField(
                          controller: feedbackController,
                          minLines: 5,
                          maxLines: 5,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withAlpha(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => {
                                showRating.value = {'show': false}
                              },
                              child: Text(
                                Strings().cancel,
                              ),
                            ),
                            SizedBox(width: 10),
                            TextButton(
                              onPressed: () async {
                                if (otherUid is String && meetingId is String) {
                                  final database = ref.watch(databaseProvider);
                                  database.addRating(
                                    otherUid,
                                    meetingId,
                                    RatingModel(
                                      rating: rating,
                                      comment: feedbackController.text,
                                    ),
                                  );
                                }
                                showRating.value = {'show': false};
                              },
                              child: Text(
                                Strings().appRatingSubmitButton,
                              ),
                              style: TextButton.styleFrom(
                                primary:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: isUserLocked,
          builder: (BuildContext context, value, Widget? child) {
            if (value == false) {
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
                            context.go(Routes.bidOut);
                            break;
                          case 3:
                            context.go(Routes.favorites);
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
                            child: SvgPicture.asset('assets/icons/house.svg',
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          icon: SvgPicture.asset('assets/icons/house.svg'),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().profile,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset('assets/icons/person.svg',
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          icon: ProfileIcon(),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().bidOut,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.call_made,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.call_made),
                          ),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().favorites,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.favorite,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          icon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.favorite),
                          ),
                        ),
                        BottomNavigationBarItem(
                          label: Strings().settings,
                          activeIcon: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SvgPicture.asset('assets/icons/setting.svg',
                                color: Theme.of(context).colorScheme.secondary),
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
        ref.watch(
            lockedHangoutViewModelProvider); // lockedHangoutViewModelProvider just needs to run
        if (kIsWeb) {
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
