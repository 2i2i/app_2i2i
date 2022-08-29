import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'my_user_page.dart';
import 'my_user_page_web.dart';


class MyUserPageHolder extends ConsumerStatefulWidget {
  const MyUserPageHolder({Key? key}) : super(key: key);

  @override
  _MyUserPageHolderState createState() => _MyUserPageHolderState();
}

class _MyUserPageHolderState extends ConsumerState<MyUserPageHolder> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MyUserPage(),
      tablet: (BuildContext context) => MyUserPage(),
      desktop: (BuildContext context) => MyUserPageWeb(),
    );
  }
}
