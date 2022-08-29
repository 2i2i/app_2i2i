import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'faq_keywords_list.dart';
import 'faq_keywords_list_web.dart';

class FAQKeywordsListHolder extends ConsumerWidget {
  const FAQKeywordsListHolder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => FAQKeywordsList(),
      tablet: (BuildContext context) => FAQKeywordsList(),
      desktop: (BuildContext context) => FAQKeywordsListWeb(),
    );
  }
}
