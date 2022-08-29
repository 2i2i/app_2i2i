import 'package:app_2i2i/ui/screens/search/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'search_page_web.dart';

class SearchPageHolder extends ConsumerStatefulWidget {
  @override
  _SearchPageHolderState createState() => _SearchPageHolderState();
}

class _SearchPageHolderState extends ConsumerState<SearchPageHolder> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => SearchPage(),
      tablet: (BuildContext context) => SearchPage(),
      desktop: (BuildContext context) => SearchPageWeb(),
    );
  }
}
