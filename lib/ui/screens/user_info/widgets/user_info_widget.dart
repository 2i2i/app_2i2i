import 'package:flutter/material.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoWidget extends StatelessWidget {
  final UserModel? userModel;

  const UserInfoWidget({Key? key, this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortBio =
        userModel!.bio; //user.bio.substring(shortBioStart, shortBioEnd);
    var statusColor = AppTheme().green;
    if (userModel!.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    } else if (userModel!.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    return Row(
      children: [
        ProfileWidget(
          stringPath: userModel?.name ?? "",
          statusColor: statusColor,
          radius: 80,
        ),
        Expanded(
          child: ListTile(
            title: Text(
              userModel?.name ?? "",
              style: TextStyle(
                  fontFamily: 'SofiaPro',
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(shortBio.toString().trim(),
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
                Text(
                  Strings().seeMore,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
