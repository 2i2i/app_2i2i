import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'bottom_nav_bar.dart';
import 'bottom_nav_bar_web.dart';

ValueNotifier<int> currentIndex = ValueNotifier(1);
String previousRoute = '';

class BottomNavBarHolder extends ConsumerStatefulWidget {
  const BottomNavBarHolder({Key? key}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBarHolder> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.watch(appSettingProvider).checkIfUpdateAvailable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => BottomNavBar(),
      tablet: (BuildContext context) => BottomNavBar(),
      desktop: (BuildContext context) => BottomNavBarWeb(),
    );
  }
}
