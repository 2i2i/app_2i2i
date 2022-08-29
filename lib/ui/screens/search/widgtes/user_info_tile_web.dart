import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoTileWeb extends ConsumerWidget {
  final UserModel user;
  final String myUid;
  final bool isForBlockedUser;
  final double? marginBottom;

  const UserInfoTileWeb({
    Key? key,
    required this.user,
    this.marginBottom,
    required this.myUid,
    this.isForBlockedUser = false,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelChanger = ref.watch(userChangerProvider)!;
    if (user.name.isEmpty) {
      return Container();
    }

    final name = user.name;
    final bio = user.bio;

    var statusColor = AppTheme().green;
    if (user.status == Status.OFFLINE) statusColor = AppTheme().gray;
    if (user.status == Status.IDLE) statusColor = Colors.amber;
    if (user.isInMeeting()) statusColor = AppTheme().red;

    final myUserAsyncValue = ref.watch(userProvider(myUid));
    bool isFriend = false;
    if (!haveToWait(myUserAsyncValue)) {
      final myUser = myUserAsyncValue.value!;
      isFriend = myUser.friends.contains(user.id);
    }

    return InkResponse(
      onTap: () => context.pushNamed(Routes.user.nameFromPath(), params: {
        'uid': user.id,
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom ?? 0),
        decoration: Custom.getBoxDecoration(context, radius: 15),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.004,
          vertical: MediaQuery.of(context).size.height * 0.009,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical:MediaQuery.of(context).size.height * 0.010, ),
              child: Expanded(
                flex: 1,
                child: ProfileWidget(
                  stringPath: (user.imageUrl ?? "").isEmpty ? user.name : user.imageUrl!,
                  imageType: (user.imageUrl ?? "").isEmpty ? ImageType.NAME_IMAGE : ImageType.NETWORK_IMAGE,
                  radius: MediaQuery.of(context).size.height * 0.075,
                  hideShadow: true,
                  showBorder: false,
                  statusColor: statusColor,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
            /*  SizedBox(
              height: MediaQuery.of(context).size.height * 0.020,
            ),*/
            Expanded(
              child: ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.subtitle1,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Visibility(
                      visible: user.isVerified(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Tooltip(
                          triggerMode: TooltipTriggerMode.tap,
                          message: 'Connected with social account',
                          child: SvgPicture.asset(
                            'assets/icons/done_tick.svg',
                            width: MediaQuery.of(context).size.width * 0.020,
                            height: MediaQuery.of(context).size.height * 0.020,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.010,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IgnorePointer(
                        ignoring: true,
                        child: RatingBar.builder(
                          initialRating: user.rating * 5,
                          minRating: 1,
                          direction: Axis.horizontal,
                          tapOnlyMode: true,
                          updateOnDrag: false,
                          itemCount: 5,
                          itemSize: MediaQuery.of(context).size.height * 0.015,
                          allowHalfRating: true,
                          glowColor: Colors.white,
                          ignoreGestures: false,
                          unratedColor: Colors.grey.shade300,
                          itemBuilder: (context, _) => Icon(
                            Icons.star_rounded,
                            color: Theme.of(context).colorScheme.secondary,
                            //color: Colors.amber,
                          ),
                          onRatingUpdate: (double value) {},
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.004,
                      ),
                      Text(
                        '(${(user.rating * 5).toStringAsFixed(1)}/5)',
                        style: Theme.of(context).textTheme.caption,
                      )
                    ],
                  ),
                ),
                trailing: isForBlockedUser
                    ? IconButton(
                        onPressed: () => userModelChanger.removeBlocked(user.id),
                        icon: Icon(
                          Icons.remove_circle_rounded,
                        ),
                      )
                    : IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => isFriend
                            ? userModelChanger.removeFriend(user.id)
                            : userModelChanger.addFriend(
                                user.id,
                              ),
                        icon: Icon(
                          isFriend ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        ),
                        color: isFriend ? Colors.red : Colors.grey,
                      ),

              ),
            ),
            Expanded(
              child: ListTile(
                leading: Padding(
                  padding: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width * 0.0035,
                    top: MediaQuery.of(context).size.height * 0.003,
                  ),
                  child: Text(
                    bio,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                trailing: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                    horizontal: MediaQuery.of(context).size.width * 0.0035,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: Theme.of(context).disabledColor,
                    size: MediaQuery.of(context).size.height * 0.020,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
