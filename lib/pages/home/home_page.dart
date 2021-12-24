import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/faq/faq_page.dart';
import 'package:app_2i2i/pages/locked_user/ui/locked_user_page.dart';
import 'package:app_2i2i/pages/my_account/ui/my_account_page.dart';
import 'package:app_2i2i/pages/my_user/ui/my_user_page.dart';
import 'package:app_2i2i/pages/search/ui/search_page.dart';
import 'package:app_2i2i/pages/setup_account/ui/setup_account.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/strings.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var _tabSelectedIndex = 0;
  var _tabPopStack = false;

  static final List<TabItem> _tabItems = [
    TabItem(GlobalKey<NavigatorState>(), SearchPage()),
    TabItem(GlobalKey<NavigatorState>(), MyAccountPage()),
    TabItem(GlobalKey<NavigatorState>(), MyUserPage()),
    TabItem(GlobalKey<NavigatorState>(), FAQPage()),
    // TabItem(GlobalKey<NavigatorState>(), QRCodePage()),
  ];

//if the user double-clicked on any tab, all tab's sub-page is removed
  void _onTap(index) {
    setState(() {
      _tabPopStack = _tabSelectedIndex == index;
      _tabSelectedIndex = index;
    });
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final user = ref.watch(userProvider(uid));
      bool isLoaded = !(user is AsyncLoading && user is AsyncError);
      if (isLoaded) {
        final UserModel myUser = user.data!.value;
        if (myUser.name.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => WillPopScope(
                onWillPop: () {
                  return Future.value(true);
                },
                child: AlertDialog(
                  content: SetupBio(
                    isFromDialog: true,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                )),
            barrierDismissible: false,
          );
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var lockUser = ref.watch(lockedUserViewModelProvider);
    bool loading =
        lockUser == null || lockUser is AsyncLoading || lockUser is AsyncError;
    log('----------\n\n loading $loading \n\n-----------');
    if (!loading) {
      log('----------\n\n lockUser?.meeting ${lockUser.meeting} \n\n-----------');
      // if(lockUser.meeting is Meeting) {
      return LockedUserPage(
        onHangPhone: (uid, meetingId) {
          submitReview(uid, meetingId);
        },
      );
      // }
    }
    if (isUserLocked.value) {
      return LockedUserPage(
        onHangPhone: (uid, meetingId) {
          submitReview(uid, meetingId);
        },
      );
    }
    return WillPopScope(
      onWillPop: () async =>
          !await _tabItems[_tabSelectedIndex].key.currentState!.maybePop(),
      child: Scaffold(
        body: Stack(
          children: _tabItems
              .asMap()
              .map((index, value) => MapEntry(
                  index, _buildOffstageNavigator(_tabItems[index], index)))
              .values
              .toList(),
        ),
        bottomNavigationBar: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _tabSelectedIndex,
              onTap: (i) => _onTap(i),
              items: [
                BottomNavigationBarItem(
                  label: Strings().home,
                  icon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(_tabSelectedIndex == 0
                        ? 'assets/icons/house_fill.svg'
                        : 'assets/icons/house.svg'),
                  ),
                ),
                BottomNavigationBarItem(
                  label: Strings().account,
                  icon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      _tabSelectedIndex == 1
                          ? 'assets/icons/account_fill.svg'
                          : 'assets/icons/account.svg',
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  label: Strings().profile,
                  icon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(_tabSelectedIndex == 2
                        ? 'assets/icons/person_fill.svg'
                        : 'assets/icons/person.svg'),
                  ),
                ),
                BottomNavigationBarItem(
                  label: Strings().settings,
                  icon: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(_tabSelectedIndex == 3
                        ? 'assets/icons/setting_fill.svg'
                        : 'assets/icons/setting.svg'),
                  ),
                ),
                // BottomNavigationBarItem(
                //   label: "",
                //   icon: Icon(Icons.qr_code_2_rounded),
                //   tooltip: 'QR Code',
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem, int tabIndex) {
    return Offstage(
      offstage: _tabSelectedIndex != tabIndex,
      child: Opacity(
        opacity: _tabSelectedIndex == tabIndex ? 1.0 : 0.0,
        child: TabNavigator(
            tabItem: tabItem, popStack: _tabPopStack, selectedIndex: tabIndex),
      ),
    );
  }

  submitReview(otherUid, meetingId) {
    CustomDialogs.inAppRatingDialog(context,
        onPressed: (double rating, String? ratingFeedBack) {
      final database = ref.watch(databaseProvider);
      database.addRating(
          otherUid,
          RatingModel(
              rating: rating, comment: ratingFeedBack, meeting: meetingId));
    });
  }
}

class TabItem {
  final GlobalKey<NavigatorState> key;
  final Widget tab;

  const TabItem(this.key, this.tab);
}

class TabNavigator extends StatelessWidget {
  final TabItem? tabItem;
  final bool? popStack;
  final int? selectedIndex;

  TabNavigator(
      {Key? key, this.tabItem, this.popStack = false, this.selectedIndex})
      : super(key: key);

//if the user double-clicked on any tab, all tab's sub-page is removed
  _popStackIfRequired(BuildContext context) async {
    if (popStack!) {
      tabItem!.key.currentState!.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    log('selectedIndex= $selectedIndex, popStack= $popStack');

    _popStackIfRequired(context);

    return Navigator(
        key: tabItem!.key,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
              settings: settings, builder: (_) => tabItem!.tab);
        });
  }
}
