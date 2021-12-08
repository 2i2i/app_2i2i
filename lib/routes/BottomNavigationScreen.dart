import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/home/home_page.dart';
import 'package:app_2i2i/pages/home/tab_item.dart';
import 'package:app_2i2i/pages/search_page/ui/search_page.dart';
import 'package:app_2i2i/routes/TestOne.dart';
import 'package:app_2i2i/routes/TestTwo.dart';
import 'package:app_2i2i/routes/named_routes.dart';

import 'package:flutter/material.dart';

import 'multi_navigator_bottom_bar.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
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

class _MainScreenState extends State<MainScreen> {
  var _tabSelectedIndex = 0;


  static final List<TabItem> _tabItems = [
    TabItem(GlobalKey<NavigatorState>(), TestOneScreen()),
    TabItem(GlobalKey<NavigatorState>(), TestTwoScreen()),
  ];

  Widget _buildOffstageNavigator(TabItem? tabItem, int tabIndex) {
    return Offstage(
      offstage: _tabSelectedIndex != tabIndex,
      child: Opacity(
        opacity: _tabSelectedIndex == tabIndex ? 1.0 : 0.0,
        child: TabNavigator(
            tabItem: tabItem, popStack: false, selectedIndex: tabIndex),
      ),
    );
  }
  bool isPopLocking = false;
  @override
  Widget build(BuildContext context) {
    return MultiNavigatorBottomBar(
      pageWidgetDecorator: pageDecorator,
      routeFactory: NamedRoutes.generateRoute,
      initTabIndex: 0,
      tabs: [
        BottomBarTab(
          initPageBuilder: (_) => TestOneScreen(),
          tabIconBuilder: (_) => Icon(Icons.add),
          tabTitleBuilder: (_) => Text("Screen 1"),
        ),
        BottomBarTab(
          initPageBuilder: (_) => TestTwoScreen(),
          tabIconBuilder: (_) => Icon(Icons.add),
          tabTitleBuilder: (_) => Text("Screen 2"),
        ),
      ],
    );
    return Scaffold(
      body: Stack(
          children: _tabItems.asMap().map((index, value) => MapEntry(
              index, _buildOffstageNavigator(_tabItems[index], index),
          ),)
              .values
              .toList(),
      ),
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
            onTap: (i) {
              _tabSelectedIndex = i;
              setState(() {});
            },
            items: [
              BottomNavigationBarItem(label: "", icon: Icon(Icons.search_rounded)),
              BottomNavigationBarItem(label: "", icon: Icon(Icons.person_outlined)),
            ],
          ),
        ),
      ),
    );
  }
  Widget pageDecorator(pageWidget) => Column(
    children: <Widget>[
      Expanded(child: pageWidget),
      Container(
        alignment: AlignmentDirectional.center,
        height: 48.0,
        color: Colors.black,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "[PageWidgetDecorator] isPopLocking? $isPopLocking",
                style: TextStyle(color: Colors.white),
              ),
            ),
            MaterialButton(
              child: Text(isPopLocking ? "Unlock" : "Lock"),
              onPressed: () => setState(() => isPopLocking = !isPopLocking),
            )
          ],
        ),
      )
    ],
  );
}
