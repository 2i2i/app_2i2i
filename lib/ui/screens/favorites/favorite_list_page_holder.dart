import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'favorite_list_page.dart';
import 'favorite_list_page_web.dart';

class FavoriteListPageHolder extends ConsumerStatefulWidget {
  const FavoriteListPageHolder({Key? key}) : super(key: key);

  @override
  _FavoriteListPageHolderState createState() => _FavoriteListPageHolderState();
}

class _FavoriteListPageHolderState extends ConsumerState<FavoriteListPageHolder> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => FavoriteListPage(),
      tablet: (BuildContext context) => FavoriteListPage(),
      desktop: (BuildContext context) => FavoriteListPageWeb(),
    );
  }
}
