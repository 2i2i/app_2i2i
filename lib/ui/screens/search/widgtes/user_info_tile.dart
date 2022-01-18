import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom.dart';
import '../../../commons/custom_navigation.dart';
import '../../../commons/custom_profile_image_view.dart';
import '../../user_info/user_info_page.dart';

class UserInfoTile extends ConsumerWidget {
  final UserModel userModel;
  final String myUIDProvider;
  final bool isForBlockedUser;

  const UserInfoTile(
      {Key? key,
      required this.userModel,
      required this.myUIDProvider,
      required this.isForBlockedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(myUIDProvider));
    final userModelChanger = ref.watch(userModelChangerProvider)!;
    if (userModel.name.isEmpty) return Container();

    final name = userModel.name;
    final bio = userModel.bio;

    var statusColor = AppTheme().green;
    if (userModel.status == 'OFFLINE') statusColor = AppTheme().gray;
    if (userModel.isInMeeting()) statusColor = AppTheme().red;

    final isFriend = !(userPrivateAsyncValue is AsyncError) &&
        !(userPrivateAsyncValue is AsyncLoading) &&
        userPrivateAsyncValue.value != null &&
        userPrivateAsyncValue.value!.friends.contains(userModel.id);


    return Container(
      decoration: Custom.getBoxDecoration(context, radius: 12),
      child: InkWell(
        onTap: () => CustomNavigation.push(
            context, UserInfoPage(uid: userModel.id), Routes.USER),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
          child: Row(
            children: [
              ProfileWidget(
                stringPath: userModel.name,
                radius: 62,
                hideShadow: true,
                showBorder: true,
                statusColor: statusColor,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontWeight: FontWeight.bold),
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
                                initialRating: userModel.rating * 5,
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
                                ), onRatingUpdate: (double value) {  },
                              ),
                            ),
                            SizedBox(width: 6),
                            Text('${(userModel.rating * 5).toStringAsFixed(1)}',
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
                            style:
                                Theme.of(context).textTheme.bodyText1!.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context).disabledColor,
                                    ),
                          ),
                        ),
                        isForBlockedUser
                            ? IconButton(
                                onPressed: () => userModelChanger.removeBlocked(userModel.id),
                                icon: Icon(Icons.remove_circle_rounded))
                            : IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => isFriend
                                    ? userModelChanger
                                        .removeFriend(userModel.id)
                                    : userModelChanger.addFriend(userModel.id),
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
