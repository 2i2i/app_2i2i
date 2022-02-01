import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/infrastructure/routes/profile_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
ValueNotifier<int> currentIndex = ValueNotifier(0);

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
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
    );
  }
}
