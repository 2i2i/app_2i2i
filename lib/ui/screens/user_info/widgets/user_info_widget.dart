import 'package:flutter/material.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoWidget extends StatelessWidget {
  final UserModel userModel;

  const UserInfoWidget({Key? key, required this.userModel}) : super(key: key);

  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  ValueNotifier<bool> seeMore = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final shortBio =
        widget.userModel.bio; //user.bio.substring(shortBioStart, shortBioEnd);
    var statusColor = AppTheme().green;
    if (widget.userModel.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    } else if (widget.userModel.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    return Row(
      children: [
        ProfileWidget(
          stringPath: widget.userModel.name ?? "",
          statusColor: statusColor,
          radius: 80,
        ),
        Expanded(
          child: ListTile(
            title: Text(
              widget.userModel.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ValueListenableBuilder(
                    valueListenable: seeMore,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Text(
                        shortBio.toString().trim(),
                        maxLines: value ? null : 2,
                        style: Theme.of(context).textTheme.bodyText1,
                      );
                    },
                  ),
                ),
                InkResponse(
                  onTap: (){
                    seeMore.value = !seeMore.value;
                  },
                  child: ValueListenableBuilder(
                    valueListenable: seeMore,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Text(
                        value?Strings().less:Strings().seeMore,
                        style: Theme.of(context).textTheme.caption,
                      );
                    },
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
