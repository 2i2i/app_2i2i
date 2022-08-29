import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'no_bid_page.dart';
import 'no_bid_page_web.dart';

class NoBidPageHolder extends ConsumerWidget {
  final String noBidsText;

  const NoBidPageHolder({Key? key, required this.noBidsText}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => NoBidPage(noBidsText: noBidsText,),
      tablet: (BuildContext context) => NoBidPage(noBidsText: noBidsText,),
      desktop: (BuildContext context) => NoBidPageWeb(noBidsText: noBidsText,),
    );

  }
}
