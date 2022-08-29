import 'package:app_2i2i/ui/screens/search/widgtes/user_info_tile.dart';
import 'package:app_2i2i/ui/screens/search/widgtes/user_info_tile_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../infrastructure/models/user_model.dart';

class UserInfoTileHolder extends ConsumerWidget {

  final UserModel user;
  final String myUid;
  final bool isForBlockedUser;
  final double? marginBottom;

  const UserInfoTileHolder(
      {Key? key,
        required this.user,
        this.marginBottom,
        required this.myUid,
        this.isForBlockedUser = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => UserInfoTile(user: user, myUid: myUid,),
      tablet: (BuildContext context) => UserInfoTile(user: user, myUid: myUid,),
      desktop: (BuildContext context) => UserInfoTileWeb(user: user, myUid: myUid),
    );
  }
}
