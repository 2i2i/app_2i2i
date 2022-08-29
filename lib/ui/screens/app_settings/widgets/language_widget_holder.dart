import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'language_widget.dart';
import 'language_widget_web.dart';

class LanguagePageHolder extends ConsumerStatefulWidget {
  @override
  _LanguagePageHolderState createState() => _LanguagePageHolderState();
}

class _LanguagePageHolderState extends ConsumerState<LanguagePageHolder> {


  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => LanguagePage(),
      tablet: (BuildContext context) => LanguagePage(),
      desktop: (BuildContext context) => LanguagePageWeb(),
    );
  }
}
