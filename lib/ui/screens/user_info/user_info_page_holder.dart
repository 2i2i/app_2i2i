import 'package:app_2i2i/ui/screens/user_info/user_info_page.dart';
import 'package:app_2i2i/ui/screens/user_info/user_info_page_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

class UserInfoPageHolder extends ConsumerStatefulWidget {
  UserInfoPageHolder({required this.B});

  final String B;

  @override
  _UserInfoPageHolderState createState() => _UserInfoPageHolderState();
}

class _UserInfoPageHolderState extends ConsumerState<UserInfoPageHolder> {
  var showBio = false;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => UserInfoPage(
        B: widget.B,
      ),
      tablet: (BuildContext context) => UserInfoPage(
        B: widget.B,
      ),
      desktop: (BuildContext context) => UserInfoPageWeb(
        B: widget.B,
      ),
    );
  }
}
