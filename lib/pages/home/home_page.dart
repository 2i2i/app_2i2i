import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/account/ui/my_account_page.dart';
import 'package:app_2i2i/pages/faq/faq_page.dart';
import 'package:app_2i2i/pages/my_user/ui/my_user_page.dart';
import 'package:app_2i2i/pages/qr_code/qr_code_page.dart';
import 'package:app_2i2i/pages/search_page/ui/search_page.dart';
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
      !await _tabItems[_tabSelectedIndex].key.currentState!.maybePop(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
            children: _tabItems
                .asMap()
                .map((index, value) => MapEntry(
                index, _buildOffstageNavigator(_tabItems[index], index)))
                .values
                .toList()),
        bottomNavigationBar: Container(
          color: Colors.transparent,
          child: Card(
            elevation: 6,
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _tabSelectedIndex,
              unselectedItemColor: AppTheme().black,
              selectedItemColor: AppTheme().secondary,
              onTap: (i) => _onTap(i),
              items: [
                BottomNavigationBarItem(
                    label: "", icon: Icon(Icons.search_rounded)),
                BottomNavigationBarItem(
                    label: "", icon: Icon(Icons.person_outlined)),
                BottomNavigationBarItem(
                    label: "", icon: Icon(Icons.attach_money_rounded)),
                BottomNavigationBarItem(
                    label: "", icon: Icon(Icons.help_outline_rounded)),
                BottomNavigationBarItem(
                    label: "", icon: Icon(Icons.qr_code_2_rounded)),
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
    print('selectedIndex= $selectedIndex, popStack= $popStack');

    _popStackIfRequired(context);

    return Navigator(
        key: tabItem!.key,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
              settings: settings, builder: (_) => tabItem!.tab);
        });
  }
}
