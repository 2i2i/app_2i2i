import 'dart:math';

import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom_navigation.dart';
import '../create_bid/create_bid_page.dart';
import '../home/wait_page.dart';
import 'other_bid_list.dart';
import 'widgets/friend_button_widget.dart';
import 'widgets/user_info_widget.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  UserInfoPage({required this.uid});

  final String uid;

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  var showBio = false;

  @override
  Widget build(BuildContext context) {
    final mainUserID = ref.watch(myUIDProvider)!;
    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(mainUserID));
    final userModelChanger = ref.watch(userModelChangerProvider)!;

    if (userPageViewModel == null ||
        userPageViewModel is AsyncError ||
        userPageViewModel is AsyncLoading) {
      return WaitPage();
    }

    UserModel userModel = userPageViewModel.user;

    final isFriend = !(userPrivateAsyncValue is AsyncError) &&
        !(userPrivateAsyncValue is AsyncLoading) &&
        userPrivateAsyncValue.value != null &&
        userPrivateAsyncValue.value!.friends.contains(widget.uid);

    final isBlocked = !(userPrivateAsyncValue is AsyncError) &&
        !(userPrivateAsyncValue is AsyncLoading) &&
        userPrivateAsyncValue.value != null &&
        userPrivateAsyncValue.value!.blocked.contains(widget.uid);

    final totalRating = (userModel.rating * 5).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        actions: [
          PopupMenuButton<int>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            onSelected: (item) =>
                handleClick(item, userModelChanger, isBlocked),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text(Strings().report)),
              PopupMenuItem<int>(
                value: 1,
                child: Text(
                  isBlocked ? Strings().unBlock : Strings().block,
                  style: TextStyle(color: Theme.of(context).errorColor),
                ),
              ),
            ],
          ),
          SizedBox(width: 6)
        ],
      ),
      floatingActionButton: InkResponse(
        onTap: () => CustomNavigation.push(context, CreateBidPage(uid: userModel.id), Routes.CreateBid),
        child: Container(
          width: kToolbarHeight * 1.15,
          height: kToolbarHeight * 1.15,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 8,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary // changes position of shadow
                  ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            size: 30,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(020),
                  bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 14,top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserInfoWidget(
                    userModel: userModel,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => CustomNavigation.push(context, RatingPage(userModel: user), Routes.RATING),
                            child: Column(
                              children: [
                                Text(
                                  '$totalRating',
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1,
                                ),
                                SizedBox(height: 4),
                                IgnorePointer(
                                  ignoring: true,
                                  child: RatingBar.builder(
                                    initialRating: userModel.rating * 5,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemSize: 20,
                                    tapOnlyMode: true,
                                    updateOnDrag: false,
                                    allowHalfRating: true,
                                    glowColor: Colors.white,
                                    unratedColor: Colors.grey.shade300,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: FriendButtonWidget(
                            value: isFriend,
                            onTap: (value) => value
                                ? userModelChanger.addFriend(widget.uid)
                                : userModelChanger.removeFriend(widget.uid),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: OtherBidInList(
              B: userModel,
            ),
          ),
        ],
      ),
    );
  }

  void handleClick(
      int item, UserModelChanger userModelChanger, bool isBlocked) {
    switch (item) {
      case 0:
        // userModelChanger.addFriend(widget.uid);
        break;
      case 1:
        if (isBlocked) {
          userModelChanger.removeBlocked(widget.uid);
        } else {
          userModelChanger.addBlocked(widget.uid);
        }

        break;
    }
  }
}
