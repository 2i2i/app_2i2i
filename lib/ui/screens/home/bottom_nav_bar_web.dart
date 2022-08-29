import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/infrastructure/routes/profile_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

ValueNotifier<int> currentIndex = ValueNotifier(1);
String previousRoute = '';

class BottomNavBarWeb extends ConsumerStatefulWidget {
  const BottomNavBarWeb({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBarWeb> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.watch(appSettingProvider).checkIfUpdateAvailable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isUserLocked,
      builder: (BuildContext context, value, Widget? child) {
        if (value == false) {
          return Card(
            shadowColor: Theme.of(context).canvasColor,
            surfaceTintColor: Theme.of(context).cardColor,
            child: ValueListenableBuilder(
              valueListenable: currentIndex,
              builder: (BuildContext context, int value, Widget? child) {
                return ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 1.4,
                        color: Theme.of(context).cardColor,
                        child: RotatedBox(
                          quarterTurns: 5,
                          child: BottomNavigationBar(
                            iconSize: 25,
                            showSelectedLabels: false,
                            showUnselectedLabels: false,
                            backgroundColor: Theme.of(context).cardColor,
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
                                activeIcon: RotatedBox(
                                  quarterTurns: 3,
                                  child: SvgPicture.asset(
                                    'assets/icons/house.svg',
                                    height: 25,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                icon: RotatedBox(
                                  quarterTurns: 3,
                                  child: SvgPicture.asset(
                                    'assets/icons/house.svg',
                                    height: 25,
                                  ),
                                ),
                              ),
                              BottomNavigationBarItem(
                                label: Keys.profile.tr(context),
                                activeIcon: RotatedBox(
                                  quarterTurns: 3,
                                  child: SvgPicture.asset(
                                    'assets/icons/person.svg',
                                    height: 25,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                icon: RotatedBox(
                                  quarterTurns: 3,
                                  child: ProfileIcon(),
                                ),
                              ),
                              BottomNavigationBarItem(
                                label: Keys.bidOut.tr(context),
                                activeIcon: RotatedBox(
                                  quarterTurns: 2,
                                  child: Icon(
                                    Icons.call_made,
                                    size: 30,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                icon: RotatedBox(
                                  quarterTurns: 2,
                                  child: Icon(
                                    Icons.call_made,
                                    size: 30,
                                  ),
                                ),
                              ),
                              BottomNavigationBarItem(
                                label: Keys.favorites.tr(context),
                                activeIcon: RotatedBox(
                                  quarterTurns: 3,
                                  child: Icon(
                                    Icons.favorite,
                                    size: 25,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                icon: RotatedBox(
                                  quarterTurns: 3,
                                  child: Icon(
                                    Icons.favorite,
                                    size: 25,
                                  ),
                                ),
                              ),
                              BottomNavigationBarItem(
                                label: Keys.settings.tr(context),
                                activeIcon: RotatedBox(
                                  quarterTurns: 3,
                                  child: SvgPicture.asset(
                                    'assets/icons/setting.svg',
                                    height: 25,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                icon: RotatedBox(
                                  quarterTurns: 3,
                                  child: SvgPicture.asset(
                                    'assets/icons/setting.svg',
                                    height: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
