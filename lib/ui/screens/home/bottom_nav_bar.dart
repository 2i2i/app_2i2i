import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/profile_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

ValueNotifier<int> currentIndex = ValueNotifier(1);
String previousRoute = '';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.watch(appSettingProvider).checkIfUpdateAvailable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);
    return ValueListenableBuilder(
      valueListenable: isUserLocked,
      builder: (BuildContext context, value, Widget? child) {
        if (value == false) {
          return Container(
            padding: const EdgeInsets.all(4.0),
            color: Colors.transparent,
            child: ValueListenableBuilder(
              valueListenable: currentIndex,
              builder: (BuildContext context, int value, Widget? child) {
                return BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: value,
                  onTap: (i) {
                    currentIndex.value = i;
                    switch (i) {
                      case 0:
                        context.go(Routes.root);
                        break;
                      case 1:
                        context.go(Routes.myUser);
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
                      label: Keys.home.tr(context),
                      activeIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset('assets/icons/house.svg', color: Theme.of(context).colorScheme.secondary),
                      ),
                      icon: SvgPicture.asset('assets/icons/house.svg'),
                    ),
                    BottomNavigationBarItem(
                      label: Keys.profile.tr(context),
                      activeIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SvgPicture.asset('assets/icons/person.svg', color: Theme.of(context).colorScheme.secondary),
                      ),
                      icon: ProfileIcon(),
                    ),
                    BottomNavigationBarItem(
                      label: Keys.bidOut.tr(context),
                      activeIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.call_made, color: Theme.of(context).colorScheme.secondary),
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.call_made),
                      ),
                    ),
                    BottomNavigationBarItem(
                      label: Keys.favorites.tr(context),
                      activeIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.favorite, color: Theme.of(context).colorScheme.secondary),
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.favorite),
                      ),
                    ),
                    BottomNavigationBarItem(
                      label: Keys.settings.tr(context),
                      activeIcon: settingIcons(
                          updateRequired: appSettingModel.updateRequired,
                          color: Theme.of(context).colorScheme.secondary),
                      icon: settingIcons(
                          updateRequired: appSettingModel.updateRequired),
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

  Widget settingIcons({required bool updateRequired, Color? color}) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: updateRequired
              ? RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    Icons.arrow_circle_left_rounded,
                    color: Colors.amber,
                  ),
                )
              : SvgPicture.asset('assets/icons/setting.svg', color: color),
        ),
        Visibility(
          // visible: !isTappedOnKey,
          visible: false,
          child: Positioned(
            top: 0.0,
            right: 0.0,
            child: new Icon(Icons.brightness_1,
                size: 12.0, color: Colors.redAccent),
          ),
        )
      ],
    );
  }
}
