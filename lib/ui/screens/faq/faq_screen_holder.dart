import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'faq_screen.dart';
import 'faq_screen_web.dart';

class FAQScreenHolder extends ConsumerStatefulWidget {
  @override
  _FAQScreenHolderState createState() => _FAQScreenHolderState();
}

class _FAQScreenHolderState extends ConsumerState<FAQScreenHolder> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => FAQScreen(),
      tablet: (BuildContext context) => FAQScreen(),
      desktop: (BuildContext context) => FAQScreenWeb(),
    );
  }
}
