import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'custom_app_bar.dart';
import 'custom_app_bar_web.dart';

class CustomAppbarHolder extends ConsumerWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Color backgroundColor;
  final Widget? title;

  const CustomAppbarHolder({this.title,this.actions, this.backgroundColor = Colors.transparent});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 50);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => CustomAppbar(),
      tablet: (BuildContext context) => CustomAppbar(),
      desktop: (BuildContext context) => CustomAppbarWeb(),
    );
  }
}
