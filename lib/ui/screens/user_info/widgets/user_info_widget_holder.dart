import 'package:app_2i2i/ui/screens/user_info/widgets/user_info_widget.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/user_info_widget_web.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../../infrastructure/models/user_model.dart';

class UserInfoWidgetHolder extends StatefulWidget {
  final UserModel user;
  final bool isFav;
  final int? estWaitTime;

  final GestureTapCallback? onTapFav;
  final GestureTapCallback? onTapWallet;
  final GestureTapCallback? onTapRules;
  final GestureTapCallback? onTapQr;
  final GestureTapCallback? onTapChat;

  const UserInfoWidgetHolder({
    Key? key,
    required this.user,
    this.onTapFav,
    required this.isFav,
    this.onTapRules,
    this.onTapQr,
    this.onTapWallet,
    this.estWaitTime,
    this.onTapChat,
  }) : super(key: key);

  @override
  _UserInfoWidgetHolderState createState() => _UserInfoWidgetHolderState();
}

class _UserInfoWidgetHolderState extends State<UserInfoWidgetHolder> {
  ValueNotifier<bool> seeMore = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => UserInfoWidget(
          isFav: widget.isFav,
          user: widget.user,
          estWaitTime: widget.estWaitTime,
          onTapChat: widget.onTapChat,
          onTapFav: widget.onTapFav,
          onTapQr: widget.onTapQr,
          onTapRules: widget.onTapRules,
          onTapWallet: widget.onTapWallet),
      tablet: (BuildContext context) => UserInfoWidget(
          isFav: widget.isFav,
          user: widget.user,
          estWaitTime: widget.estWaitTime,
          onTapChat: widget.onTapChat,
          onTapFav: widget.onTapFav,
          onTapQr: widget.onTapQr,
          onTapRules: widget.onTapRules,
          onTapWallet: widget.onTapWallet),
      desktop: (BuildContext context) => UserInfoWidgetWeb(
          isFav: widget.isFav,
          user: widget.user,
          estWaitTime: widget.estWaitTime,
          onTapChat: widget.onTapChat,
          onTapFav: widget.onTapFav,
          onTapQr: widget.onTapQr,
          onTapRules: widget.onTapRules,
          onTapWallet: widget.onTapWallet),
    );
  }
}
