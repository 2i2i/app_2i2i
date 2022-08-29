import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page_web.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TopPageHolder extends StatefulWidget {
  const TopPageHolder({Key? key}) : super(key: key);

  @override
  _TopPageHolderState createState() => _TopPageHolderState();
}

class _TopPageHolderState extends State<TopPageHolder> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller =  TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => TopPage(),
      tablet: (BuildContext context) => TopPage(),
      desktop: (BuildContext context) => TopPageWeb(),
    );
  }
}
