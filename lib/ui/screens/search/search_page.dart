import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/user_setting/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom.dart';
import '../../commons/custom_profile_image_view.dart';
import 'widgtes/user_info_tile.dart';

class SearchPage extends ConsumerStatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  void initMethod() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final userProviderVal = ref.watch(userProvider(uid));
      bool isLoaded = !(haveToWait(userProviderVal));
      if (isLoaded && userProviderVal.asData?.value is UserModel) {
        final UserModel user = userProviderVal.asData!.value;
        if (user.name.isEmpty) {
          CustomAlertWidget.showBidAlert(
            context,
            WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserSetting(
                  fromBottomSheet: true,
                ),
              ),
            ),
            isDismissible: false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppbar(
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              style: TextStyle(color: AppTheme().cardDarkColor),
              autofocus: false,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: Keys.searchUserHint.tr(context),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.text = '';
                          _searchController.clear();
                          ref.watch(searchFilterProvider.state).state =
                              <String>[];
                        },
                        iconSize: 20,
                        icon: Icon(
                          Icons.close,
                        ),
                      )
                    : IconButton(icon: Container(), onPressed: null),
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                prefixIcon: Icon(Icons.search_rounded),
                // suffixIcon: Icon(Icons.mic),
              ),
              onChanged: (value) {
                value = value.trim().toLowerCase();
                ref.watch(searchFilterProvider.state).state =
                    value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          SizedBox(height: 10),
          Expanded(child: _buildContents(context, ref)),
        ],
      ),
    );
  }

  int usersSort(UserModel u1, UserModel u2, List<String> keywords) {
    // status
    if (u1.status == Status.ONLINE && u2.status != Status.ONLINE) return -1;
    if (u1.status != Status.ONLINE && u2.status == Status.ONLINE) return 1;
    if (u1.status == Status.IDLE && u2.status != Status.IDLE) return -1;
    if (u1.status != Status.IDLE && u2.status == Status.IDLE) return 1;
    // both ONLINE xor neither
    if (u1.isInMeeting() && !u2.isInMeeting()) return 1;
    if (!u1.isInMeeting() && u2.isInMeeting()) return -1;
    // both inMeeting xor not

    // keywords
    if (keywords.isNotEmpty) {
      final u1Tags = UserModel.tagsFromBio(u1.bio).toSet();
      final u2Tags = UserModel.tagsFromBio(u2.bio).toSet();
      final keywordsSet = keywords.toSet();
      final u1Match = keywordsSet.intersection(u1Tags).length;
      final u2Match = keywordsSet.intersection(u2Tags).length;
      if (u2Match < u1Match) return -1;
      if (u1Match < u2Match) return 1;
    }

    // rating
    if (u2.rating < u1.rating) return -1;
    if (u1.rating < u2.rating) return 1;

    // name
    return u1.name.compareTo(u2.name);
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider.state).state;
    final mainUserID = ref.watch(myUIDProvider)!;
    var userListProvider = ref.watch(searchUsersStreamProvider);
    if (haveToWait(userListProvider)) {
      return WaitPage(isCupertino: true);
    }

    List<UserModel?> userList = userListProvider.value!;
    userList.removeWhere((element) => element == null);
    userList.removeWhere((element) => element?.id == mainUserID);
    userList.sort((u1, u2) => usersSort(u1!, u2!, filter));
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),// physics: ClampingScrollPhysics(),
        itemCount: userList.length,
        itemBuilder: (context, index) {
        Widget userTileWidget = UserInfoTile(
          user: userList[index]!,
          myUid: mainUserID,
          isForBlockedUser: false,
          marginBottom: 10,
        );

        if (-1 == index) {
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Showcase(
              // key: userTile,
              key: GlobalKey(),
              description: 'Tap to check mail',
              title: '2i2i User',

              shapeBorder: const CircleBorder(),
              radius: BorderRadius.circular(10),
              child: Container(
                decoration: Custom.getBoxDecoration(context, radius: 12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
                  child: Row(
                    children: [
                      ProfileWidget(
                        stringPath: (userList[index]!.imageUrl ?? "").isEmpty
                            ? userList[index]!.name
                            : userList[index]!.imageUrl!,
                        imageType: (userList[index]!.imageUrl ?? "").isEmpty
                            ? ImageType.NAME_IMAGE
                            : ImageType.NETWORK_IMAGE,
                        radius: 62,
                        hideShadow: true,
                        showBorder: false,
                        statusColor: Colors.red,
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
                                    userList[index]!.name,
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
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
                                        initialRating:
                                            userList[index]!.rating * 5,
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
                                    Text(
                                        '${(userList[index]!.rating * 5).toStringAsFixed(1)}',
                                        style:
                                            Theme.of(context).textTheme.caption)
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    userList[index]!.bio,
                                    maxLines: 2,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => null,
                                  icon: Icon(Icons.favorite_border_rounded),
                                  color: Colors.grey,
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
            ),
          );
        }
        return GestureDetector(
          onLongPress: (){
            ShowCaseWidget.of(context)!.startShowCase([userList[index]!.userTile]);
          },
          child: Showcase(
              description: 'Tap to check mail',
              key: userList[index]!.userTile,
              child: userTileWidget,
          ),
        );
      },
      ),
    );
  }
}
