import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/ui/screens/app_settings/app_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../faq/faq_page.dart';
import '../locked_user/locked_user_page.dart';
import '../my_account/my_account_page.dart';
import '../my_hangout/my_hangout_page.dart';
import '../search/search_page.dart';

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
    TabItem(GlobalKey<NavigatorState>(), AppSettingPage()),
    // TabItem(GlobalKey<NavigatorState>(), QRCodePage()),
  ];

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<Map> showRating = ValueNotifier<Map>({'show': false});

  TextEditingController ratingFeedBack = TextEditingController();

//if the user double-clicked on any tab, all tab's sub-page is removed
  void _onTap(index) {
    setState(() {
      _tabPopStack = _tabSelectedIndex == index;
      _tabSelectedIndex = index;
    });
  }

  double rating = 1;

  @override
  Widget build(BuildContext context) {
    var lockHangout = ref.watch(lockedHangoutViewModelProvider);
    if (!(haveToWait(lockHangout))) {
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
        key: scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 20,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Text('testnet'),
          titleTextStyle: Theme.of(context).textTheme.bodyText2,
          centerTitle: true,
        ),
        body: Stack(
          children: _tabItems
              .asMap()
              .map((index, value) => MapEntry(
                  index, _buildOffstageNavigator(_tabItems[index], index)))
              .values
              .toList(),
        ),
        bottomNavigationBar: Container(
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
                label: Strings().profile,
                activeIcon:
                    selectedIcon('assets/icons/person.svg', isSelected: true),
                icon: ProfileIcon(),
              ),
              BottomNavigationBarItem(
                label: Strings().account,
                activeIcon:
                    selectedIcon('assets/icons/account.svg', isSelected: true),
                icon: selectedIcon('assets/icons/account.svg'),
              ),
              BottomNavigationBarItem(
                label: Strings().faq,
                activeIcon:
                    selectedIcon('assets/icons/help.svg', isSelected: true),
                icon: selectedIcon('assets/icons/help.svg'),
              ),
              BottomNavigationBarItem(
                label: Strings().settings,
                activeIcon:
                    selectedIcon('assets/icons/setting.svg', isSelected: true),
                icon: selectedIcon('assets/icons/setting.svg'),
              ),
            ],
          ),
        ),
        bottomSheet: ValueListenableBuilder(
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
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            onClosing: () {},
            builder: (BuildContext context) {
              var otherUid = showRating.value['otherUid'];
              var meetingId = showRating.value['meetingId'];
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
                        initialRating: this.rating * 5,
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
                          this.rating = starRating / 5;
                        },
                      ),
                    ),
                    TextFormField(
                      controller: ratingFeedBack,
                      minLines: 5,
                      maxLines: 5,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0))),
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
                                      comment: ratingFeedBack.text));
                            }
                            showRating.value = {'show': false};
                          },
                          child: Text(
                            Strings().appRatingSubmitButton,
                          ),
                          style: TextButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
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
    if (mounted) {
      Future.delayed(Duration(milliseconds: 300)).then((value) {
        showRating.value = {
          'show': true,
          'otherUid': otherUid,
          'meetingId': meetingId
        };
        /*CustomDialogs.inAppRatingDialog(
          context,
          onPressed: (double rating, String? ratingFeedBack) {
            final database = ref.watch(databaseProvider);
            database.addRating(otherUid, meetingId, RatingModel(rating: rating, comment: ratingFeedBack));
          },
        );*/
      });
    }
  }
}

class ProfileIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final normalReturn = selectedIcon('assets/icons/person.svg', context);

    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final userId = ref.watch(myUIDProvider);
      if (userId == null) return normalReturn;

      final bidInList = ref.watch(bidInsPublicProvider(userId));
      if (bidInList.value == null)
        return selectedIcon('assets/icons/person.svg', context);
      List<BidInPublic> bids = bidInList.asData!.value;
      if (bids.isEmpty) return normalReturn;

      return FutureBuilder(
          future: SecureStorage().read(Keys.myReadBids),
          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
            if (snapshot.data == null) return normalReturn;
            log('snapshot.data=${snapshot.data}');
            List<String> localIds = snapshot.data!.split(',').toSet().toList();
            List serverIds = bids.map((e) => e.id).toSet().toList();
            bool anyNew =
                serverIds.any((element) => !localIds.contains(element));
            if (!anyNew) return normalReturn;

            return SizedBox(
              height: 30,
              width: 30,
              child: Stack(
                children: [
                  selectedIcon('assets/icons/person.svg', context),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    });
  }

  Widget selectedIcon(String iconPath, BuildContext context,
      {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SvgPicture.asset(iconPath,
          color: isSelected ? Theme.of(context).colorScheme.secondary : null),
    );
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
        },
    );
  }
}
