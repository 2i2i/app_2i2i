import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'my_account_page.dart';
import 'my_account_page_web.dart';

class MyAccountPageHolder extends ConsumerStatefulWidget {
  const MyAccountPageHolder({Key? key}) : super(key: key);

  @override
  _MyAccountPageHolderState createState() => _MyAccountPageHolderState();
}

class _MyAccountPageHolderState extends ConsumerState<MyAccountPageHolder> {


  @override
  void initState() {
    super.initState();
  }
  ValueNotifier<bool> showBottomSheet = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MyAccountPage(),
      tablet: (BuildContext context) => MyAccountPage(),
      desktop: (BuildContext context) => MyAccountPageWeb(),
    );
  }
}
