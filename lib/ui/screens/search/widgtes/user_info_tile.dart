import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoTile extends ConsumerWidget {
  final UserModel user;
  final String myUid;
  final bool isForBlockedUser;
  final double? marginBottom;

  const UserInfoTile(
      {Key? key,
      required this.user,
      this.marginBottom,
      required this.myUid,
      this.isForBlockedUser = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelChanger = ref.watch(userChangerProvider)!;
    if (user.name.isEmpty) return Container();

    final name = user.name;
    final bio = user.bio;

    var statusColor = AppTheme().green;
    if (user.status == Keys.statusOFFLINE) statusColor = AppTheme().gray;
    if (user.status == Keys.statusIDLE) statusColor = Colors.amber;
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
        decoration: Custom.getBoxDecoration(context, radius: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
          child: Row(
            children: [
              ProfileWidget(
                stringPath: user.name,
                radius: 62,
                hideShadow: true,
                showBorder: true,
                statusColor: statusColor,
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.subtitle1,
                            maxLines: 2,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
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
                                itemSize: 16,
                                allowHalfRating: true,
                                glowColor: Colors.white,
                                ignoreGestures: false,
                                unratedColor: Colors.grey.shade300,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star_rounded,
                                  color: Colors.grey,
                                ),
                                onRatingUpdate: (double value) {},
                              ),
                            ),
                            SizedBox(width: 6),
                            Text('${(user.rating * 5).toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.caption)
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bio,
                            maxLines: 2,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        isForBlockedUser
                            ? IconButton(
                                onPressed: () =>
                                    userModelChanger.removeBlocked(user.id),
                                icon: Icon(Icons.remove_circle_rounded))
                            : IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => isFriend
                                    ? userModelChanger.removeFriend(user.id)
                                    : userModelChanger.addFriend(user.id),
                                icon: Icon(isFriend
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded),
                                color: isFriend ? Colors.red : Colors.grey,
                              )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
