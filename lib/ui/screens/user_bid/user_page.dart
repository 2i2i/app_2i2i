import 'dart:math';

import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
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
    final shortBio = user.bio.substring(shortBioStart, shortBioEnd);
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
              PopupMenuItem<int>(value: 0, child: Text('Add To Favorite')),
              PopupMenuItem<int>(value: 1, child: Text('Add To Block')),
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
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6,left: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            shortBio.toString().trim(),
                            style: Theme.of(context).textTheme.bodyText2!.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Theme.of(context).disabledColor,
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
                                tapOnlyMode: true,
                                updateOnDrag: false,
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
