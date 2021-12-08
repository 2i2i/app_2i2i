library multi_navigator_bottom_bar;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomBarTab {
  final WidgetBuilder initPageBuilder;
  final WidgetBuilder tabIconBuilder;
  final WidgetBuilder? routePageBuilder;
  final WidgetBuilder? tabTitleBuilder;
  final GlobalKey<NavigatorState> _navigatorKey;

  BottomBarTab({
    required this.initPageBuilder,
    required this.tabIconBuilder,
    this.tabTitleBuilder,
    this.routePageBuilder,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
}

class MultiNavigatorBottomBar extends StatefulWidget {
  final int initTabIndex;
  final List<BottomBarTab> tabs;
  final PageRoute<dynamic>? pageRoute;
  final RouteFactory? routeFactory;
  final ValueChanged<int>? onTap;
  final Widget Function(Widget)? pageWidgetDecorator;
  final BottomNavigationBarType? type;
  final Color? fixedColor;
  final double iconSize;
  final ValueGetter shouldHandlePop;

  MultiNavigatorBottomBar({
    required this.initTabIndex,
    required this.tabs,
    this.onTap,
    this.pageRoute,
    this.pageWidgetDecorator,
    this.type,
    this.fixedColor,
    this.iconSize = 24.0,
    this.shouldHandlePop = _defaultShouldHandlePop, this.routeFactory,
  });

  static bool _defaultShouldHandlePop() => true;

  @override
  State<StatefulWidget> createState() =>
      _MultiNavigatorBottomBarState(initTabIndex);
}

class _MultiNavigatorBottomBarState extends State<MultiNavigatorBottomBar> {
  int currentIndex;

  _MultiNavigatorBottomBarState(this.currentIndex);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if(widget.shouldHandlePop()){
            bool val = await widget.tabs[currentIndex]._navigatorKey.currentState?.maybePop()??false;
            return !val;
          }
          return false;
        },
        child: Scaffold(
          body: widget.pageWidgetDecorator == null
              ? _buildPageBody()
              : widget.pageWidgetDecorator!(_buildPageBody()),
          bottomNavigationBar: _buildBottomBar(),
        ),
      );

  Widget _buildPageBody() => Stack(
        children:
            widget.tabs.map((tab) => _buildOffstageNavigator(tab)).toList(),
      );

  Widget _buildOffstageNavigator(BottomBarTab tab) => Offstage(
        offstage: widget.tabs.indexOf(tab) != currentIndex,
        child: TabPageNavigator(
          navigatorKey: tab._navigatorKey,
          initPageBuilder: tab.initPageBuilder,
          pageRoute: widget.pageRoute,
        ),
      );

  Widget _buildBottomBar() => BottomNavigationBar(
        type: widget.type,
        fixedColor: widget.fixedColor,
        items: widget.tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: tab.tabIconBuilder(context),
                  title: tab.tabTitleBuilder?.call(context),
                ))
            .toList(),
        onTap: (index) {
          if (widget.onTap != null) widget.onTap!(index);
          setState(() => currentIndex = index);
        },
        currentIndex: currentIndex,
      );
}

class TabPageNavigator extends StatelessWidget {
  TabPageNavigator(
      {required this.navigatorKey,
      required this.initPageBuilder,
      this.pageRoute,
      this.routeFactory,
      });

  final GlobalKey<NavigatorState> navigatorKey;
  final WidgetBuilder initPageBuilder;
  final PageRoute? pageRoute;
  final RouteFactory? routeFactory;

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        observers: [HeroController()],
        onGenerateRoute: routeFactory??(RouteSettings settings) =>
            pageRoute ??
            MaterialPageRoute(
              settings: RouteSettings(),
              builder: (context) => _defaultPageRouteBuilder(settings.name??'')(context),
            ),
      );

  WidgetBuilder _defaultPageRouteBuilder(String routName, {String? heroTag}) => (context) => initPageBuilder(context);
}
