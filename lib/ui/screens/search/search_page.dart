import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:app_2i2i/ui/screens/setup_account/setup_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../user_bid/user_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {

  @override
  void initState() {
    initMethod();
    super.initState();
  }

  void initMethod() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final uid = ref.watch(myUIDProvider)!;
      final user = ref.watch(userProvider(uid));
      bool isLoaded = !(user is AsyncLoading && user is AsyncError);
      if (isLoaded && user.asData?.value is UserModel) {
        final UserModel myUser = user.asData!.value;
        if (myUser.name.isEmpty) {
          CustomAlertWidget.showBidAlert(
            context,
            WillPopScope(
              onWillPop: () {
                return Future.value(true);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SetupBio(
                  isFromDialog: true,
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
      appBar: CustomAppbar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: Strings().searchUserHint,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.mic),
              ),
              onChanged: (value) {
                value = value.trim();
                ref.watch(searchFilterProvider.state).state = value.isEmpty ? <String>[] : value.split(RegExp(r'\s'));
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildContents(context, ref)),
        ],
      ),
    );
  }

  int usersSort(
      UserModel u1,
      UserModel u2,
      List<String> keywords) {
    if (u1.status == 'ONLINE' && u2.status != 'ONLINE') return -1;
    if (u1.status != 'ONLINE' && u2.status == 'ONLINE') return 1;
    // both ONLINE xor OFFLINE
    if (u1.isInMeeting() && !u2.isInMeeting()) return 1;
    if (!u1.isInMeeting() && u2.isInMeeting()) return -1;
    // both inMeeting xor not

    if (keywords.isNotEmpty) {
      final u1Tags = UserModel.tagsFromBio(u1.bio).toSet();
      final u2Tags = UserModel.tagsFromBio(u2.bio).toSet();
      final keywordsSet = keywords.toSet();
      final u1Match = keywordsSet.intersection(u1Tags).length;
      final u2Match = keywordsSet.intersection(u2Tags).length;
      if (u2Match < u1Match) return -1;
      if (u1Match < u2Match) return 1;
    }

    if (u1.rating != null && u2.rating == null) return -1;
    if (u1.rating == null && u2.rating != null) return 1;
    if (u1.rating == null && u2.rating == null) return -1;
    if (u2.rating! < u1.rating!) return -1;
    if (u1.rating! < u2.rating!) return 1;

    return -1;
  }

  Widget _buildContents(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(searchFilterProvider.state).state;
    final mainUserID = ref.watch(myUIDProvider)!;
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(mainUserID));
    final userModelChanger = ref.watch(userModelChangerProvider)!;

    return StreamBuilder(
      stream: FirestoreDatabase().usersStream(tags: filter),
      builder:
          (BuildContext contextMain, AsyncSnapshot<List<UserModel>> snapshot) {
        if (snapshot.hasData) {
          log(I +
              '_buildContents - snapshot.hasData - snapshot.data.length=${snapshot.data!.length}');

          final users = snapshot.data!;
          users.sort((u1, u2) => usersSort(u1, u2, filter));
          users.removeWhere((element) => element.id == mainUserID);
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            itemCount: users.length,
            itemBuilder: (_, ix) {
              final user = users[ix];
              if (user.name.isEmpty) return Container();

              final name = user.name;
              final bio = user.bio;
              final rating = user.rating.toString();
              /*  final shortBioStart = bio.indexOf(RegExp(r'\s')) + 1;
                int aPoint = shortBioStart + 10;
                int bPoint = bio.length;
                final shortBioEnd = min(aPoint, bPoint);
                final shortBio = user.bio.substring(shortBioStart, shortBioEnd);*/

              var statusColor = AppTheme().green;
              if (user.status == 'OFFLINE') statusColor = AppTheme().gray;
              if (user.isInMeeting()) statusColor = AppTheme().red;

              final isFriend = !(userPrivateAsyncValue is AsyncError) &&
                  !(userPrivateAsyncValue is AsyncLoading) &&
                  userPrivateAsyncValue.value != null &&
                  userPrivateAsyncValue.value!.friends.contains(user.id);
              String firstNameChar = user.name;
              if (firstNameChar.isNotEmpty) {
                firstNameChar = firstNameChar.substring(0, 1);
              }
              return Visibility(
                visible: user.id != mainUserID,
                child: Container(
                  decoration: Custom.getBoxDecoration(context,radius: 12),
                  child: GestureDetector(
                    onTap:(){
                      CustomNavigation.push(context, UserPage(uid: user.id), Routes.USER);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 55,
                            width: 55,
                            child: Stack(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                      Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 20,
                                          spreadRadius: 0.5,
                                        )
                                      ]),
                                  alignment: Alignment.center,
                                  child: Text(
                                    firstNameChar,
                                    style: Theme.of(context).textTheme.headline5,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border:
                                      Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                        RatingBar.builder(
                                          initialRating: (user.rating ?? 0) * 5,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          itemCount: 5,
                                          itemSize: 16,
                                          glowColor: Colors.white,
                                          unratedColor: Colors.grey.shade300,
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star_rounded,
                                            color: Colors.grey,
                                          ),
                                          onRatingUpdate: (rating) {
                                            print(rating);
                                          },
                                        ),
                                        SizedBox(width: 6),
                                        Text('${(user.rating ?? 0) * 5}',
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                          fontWeight: FontWeight.w400,
                                          color:
                                          Theme.of(context).disabledColor,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () => isFriend
                                          ? userModelChanger
                                          .removeFriend(user.id)
                                          : userModelChanger
                                          .addFriend(user.id),
                                      icon: Icon(isFriend
                                          ? Icons.favorite_rounded
                                          : Icons
                                          .favorite_border_rounded),
                                      color: isFriend
                                          ? Colors.red
                                          : Colors.grey,
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
            },
            separatorBuilder: (BuildContext context, int index) {
              final user = users[index];
              if (user.id == mainUserID) {
                return Container();
              }
              return Divider(
                color: Colors.transparent,
              );
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget ratingWidget(score, name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            0 <= score
                ? Icon(Icons.change_history, color: Colors.green)
                : Transform.rotate(
                    angle: pi,
                    child: Icon(Icons.change_history,
                        color: Color.fromRGBO(211, 91, 122, 1))),
            SizedBox(height: 4),
            Text(score.toString(), style: Theme.of(context).textTheme.caption)
          ],
        ),
        SizedBox(width: 10),
        CustomImageProfileView(text: name)
      ],
    );
  }
}
