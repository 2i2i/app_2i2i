import 'dart:math';

import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_alert_widget.dart';
import '../home/wait_page.dart';
import 'other_bid_list.dart';
import 'widgets/create_bid_widget.dart';

class UserPage extends ConsumerStatefulWidget {
  UserPage({required this.uid});

  final String uid;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  var showBio = false;



  @override
  Widget build(BuildContext context) {
    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));

    if (userPageViewModel == null ||
        userPageViewModel is AsyncError ||
        userPageViewModel is AsyncLoading) {
      return WaitPage();
    }

    var user = userPageViewModel.user;

    final shortBioStart = user.bio.indexOf(RegExp(r'\s')) + 1;
    int aPoint = shortBioStart + 10;
    int bPoint = user.bio.length;
    final shortBioEnd = min(aPoint, bPoint);
    final shortBio = user.bio;//user.bio.substring(shortBioStart, shortBioEnd);
    // var statusColor = AppTheme().green;
    // if (user.status == 'OFFLINE') {
    //   statusColor = AppTheme().gray;
    // } else if (user.isInMeeting()) {
    //   statusColor = AppTheme().red;
    // }

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Add as Friend')),
              PopupMenuItem<int>(value: 1, child: Text('Block user')),
            ],
          ),
          SizedBox(width: 6)
        ],
      ),
      floatingActionButton: InkResponse(
        onTap: () {
          CustomAlertWidget.showBidAlert(
            context,
            CreateBidWidget(
              uid: user.id,
            ),
          );
        },
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              children: [
                TextProfileView(
                  text: user.name,
                  statusColor: Colors.green,
                  radius: 70,
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6,left: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            direction: Axis.horizontal,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                shortBio.toString().trim(),
                                maxLines: showBio?null:2,
                                softWrap: showBio?null:false,
                                overflow: showBio?null:TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.caption!.copyWith(
                                          color: Theme.of(context).disabledColor,
                                        ),
                              ),
                              GestureDetector(
                                onTap: (){
                                  showBio = !showBio;
                                  if(mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Icon(showBio?Icons.expand_less:Icons.expand_more,
                                    color: Theme.of(context).disabledColor
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IgnorePointer(
                                ignoring: true,
                                child: RatingBar.builder(
                                  initialRating: user.rating * 5,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 16,
                                  tapOnlyMode: true,
                                  updateOnDrag: false,
                                  allowHalfRating: true,
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
                              ),
                              SizedBox(width: 4),
                              TextButton(
                                 onPressed: () => CustomNavigation.push(context, RatingPage(userModel: user,), Routes.RATING),
                                child: Text('(view all)',
                                    style: Theme.of(context).textTheme.caption),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: OtherBidInList(
                B: user,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ratingWidget(score, name, context) {
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
        Container(
          height: 40,
          width: 40,
          child: Center(
            child: Text(
              "${name.toString().isNotEmpty ? name : "X"}"
                  .substring(0, 1)
                  .toUpperCase(),
            ),
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(214, 219, 134, 1),
          ),
        )
      ],
    );
  }

  void handleClick(int item) {
    final userModelChanger = ref.watch(userModelChangerProvider)!;
    switch (item) {
      case 0:
        userModelChanger.addFriend(widget.uid);
        break;
      case 1:
        userModelChanger.addBlocked(widget.uid);
        break;
    }
  }
}
