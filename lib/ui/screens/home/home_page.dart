import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../faq/faq_page.dart';
import '../locked_user/locked_user_page.dart';
import '../my_account/my_account_page.dart';
import '../my_user/my_user_page.dart';
import '../search/search_page.dart';
import '../setup_account/setup_account.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>{
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
        final UserModel myUser = user.asData!.value;
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
    if (!loading) {
      return LockedUserPage(
        onHangPhone: (uid, meetingId) {
          submitReview(uid, meetingId);
        },
      );
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
              .toList()
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
                  activeIcon:
                      selectedIcon('assets/icons/house.svg', isSelected: true),
                  icon: selectedIcon('assets/icons/house.svg'),
                ),
                BottomNavigationBarItem(
                  label: Strings().account,
                  activeIcon: selectedIcon('assets/icons/account.svg',
                      isSelected: true),
                  icon: selectedIcon('assets/icons/account.svg'),
                ),
                BottomNavigationBarItem(
                  label: Strings().profile,
                  activeIcon:
                      selectedIcon('assets/icons/person.svg', isSelected: true),
                  icon: selectedIcon('assets/icons/person.svg'),
                ),
                BottomNavigationBarItem(
                  label: Strings().settings,
                  activeIcon: selectedIcon('assets/icons/setting.svg',
                      isSelected: true),
                  icon: selectedIcon('assets/icons/setting.svg'),
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

  Widget selectedIcon(String iconPath, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SvgPicture.asset(iconPath,
          color: isSelected ? Theme.of(context).colorScheme.secondary : null),
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
          meetingId,
          RatingModel(
              rating: rating, comment: ratingFeedBack));
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