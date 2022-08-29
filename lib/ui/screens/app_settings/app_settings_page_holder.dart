import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../infrastructure/providers/all_providers.dart';
import 'app_settings_page.dart';
import 'app_settings_page_web.dart';

class AppSettingPageHolder extends ConsumerStatefulWidget {
  @override
  _AppSettingPageHolderState createState() => _AppSettingPageHolderState();
}

class _AppSettingPageHolderState extends ConsumerState<AppSettingPageHolder> with TickerProviderStateMixin {
  List<String> networkList = ["Main", "Test", "Both"];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(setupUserViewModelProvider).getAuthList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => AppSettingPage(),
      tablet: (BuildContext context) => AppSettingPage(),
      desktop: (BuildContext context) => AppSettingPageWeb(),
    );
  }
}
