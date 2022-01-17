import 'package:flutter/material.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoWidget extends StatelessWidget {
  final UserModel? user;

  const UserInfoWidget({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortBio =
        user!.bio; //user.bio.substring(shortBioStart, shortBioEnd);
    var statusColor = AppTheme().green;
    if (user!.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    } else if (user!.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    return Row(
      children: [
        ProfileWidget(
          stringPath: user?.name ?? "",
          statusColor: statusColor,
          radius: 80,
        ),
        Expanded(
          child: ListTile(
            title: Text(
              user?.name ?? "",
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
