import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/account/ui/my_account_page.dart';
import 'package:app_2i2i/pages/faq/faq_page.dart';
import 'package:app_2i2i/pages/home/widgets/username_bio_dialog.dart';
import 'package:app_2i2i/pages/locked_user/ui/locked_user_page.dart';
import 'package:app_2i2i/pages/my_user/ui/my_user_page.dart';
import 'package:app_2i2i/pages/qr_code/qr_code_page.dart';
import 'package:app_2i2i/pages/search_page/ui/search_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    TabItem(GlobalKey<NavigatorState>(), MyUserPage()),
    TabItem(GlobalKey<NavigatorState>(), MyAccountPage()),
    TabItem(GlobalKey<NavigatorState>(), FAQPage()),
    TabItem(GlobalKey<NavigatorState>(), QRCodePage()),
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
    Future.delayed(Duration(seconds: 7)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final user = ref.watch(userProvider(uid));
      bool isLoaded = !(user is AsyncLoading && user is AsyncError);
      if (isLoaded) {
        final UserModel myUser = user.data!.value;
        if (myUser.name.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => SetupBio(user: myUser),
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
        bottomNavigationBar: Container(
          color: Colors.transparent,
          child: Card(
            elevation: 6,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _tabSelectedIndex,
              onTap: (i) => _onTap(i),
              items: [
                BottomNavigationBarItem(
                  label: "",
                  icon: Icon(Icons.search_rounded),
                  tooltip: 'Search',
                ),
                BottomNavigationBarItem(
                  label: "",
                  icon: Icon(Icons.person_outlined),
                  tooltip: 'Profile',
                ),
                BottomNavigationBarItem(
                  label: "",
                  icon: Icon(Icons.attach_money_rounded),
                  tooltip: 'Account',
                ),
                BottomNavigationBarItem(
                  label: "",
                  icon: Icon(Icons.help_outline_rounded),
                  tooltip: 'FAQ',
                ),
                BottomNavigationBarItem(
                  label: "",
                  icon: Icon(Icons.qr_code_2_rounded),
                  tooltip: 'QR Code',
                ),
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

  submitReview(uid, meetingId) {
    CustomDialogs.inAppRatingDialog(context,
        onPressed: (rating, ratingFeedBack) {
      final database = ref.watch(databaseProvider);
      database.giveRating(uid, meetingId,
          RatingModel(rating: rating.toString(), comment: ratingFeedBack));
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
