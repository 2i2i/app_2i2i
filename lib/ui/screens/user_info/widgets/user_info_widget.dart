import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoWidget extends StatefulWidget {
  final UserModel userModel;
  final GestureTapCallback onTapFav;
  final bool isFav;

  final GestureTapCallback? onTapRules;

  const UserInfoWidget(
      {Key? key,
      required this.userModel,
      required this.onTapFav,
      required this.isFav, this.onTapRules})
      : super(key: key);

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
    final totalRating = removeDecimalZeroFormat(widget.userModel.rating * 5);
    return Column(
      children: [
        Row(
          children: [
            ProfileWidget(
              stringPath: widget.userModel.name,
              statusColor: statusColor,
              radius: 80,
            ),
            Expanded(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.userModel.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    InkWell(
                      onTap: widget.onTapFav,
                      child: Icon(
                        widget.isFav ? Icons.favorite : Icons.favorite_border,
                      ),
                    )
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 2),
                    Row(
                      children: [
                        IgnorePointer(
                          ignoring: true,
                          child: RatingBar.builder(
                            initialRating: widget.userModel.rating * 5,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 15,
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
                        SizedBox(width: 5),
                        Text(
                          '($totalRating/5)',
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ValueListenableBuilder(
                        valueListenable: seeMore,
                        builder:
                            (BuildContext context, bool value, Widget? child) {
                          return Text(
                            shortBio.toString().trim(),
                            maxLines: value ? null : 2,
                            style: Theme.of(context).textTheme.bodyText1,
                          );
                        },
                      ),
                    ),
                    InkResponse(
                      onTap: () {
                        seeMore.value = !seeMore.value;
                      },
                      child: ValueListenableBuilder(
                        valueListenable: seeMore,
                        builder:
                            (BuildContext context, bool value, Widget? child) {
                          return Text(
                            value ? Strings().less : Strings().seeMore,
                            style: Theme.of(context).textTheme.caption,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        UserRulesWidget(user:widget.userModel,onTapRules: widget.onTapRules,),
        SizedBox(height: 10),
      ],
    );
  }

  String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}

class UserRulesWidget extends StatelessWidget {
  final UserModel user;

  final GestureTapCallback? onTapRules;
  const UserRulesWidget({Key? key, required this.user, this.onTapRules}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: ()=>onTapRules?.call(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ListTile.divideTiles(
            tiles: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${user.rule.minSpeed}',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                      color: Theme.of(context).colorScheme.secondary
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 17,
                      ),
                      SizedBox(width: 2),
                      Text(
                        Strings().minSpeed,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 25,
                width: 1,
                color: Theme.of(context).dividerColor,
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    getDuration(Duration(
                        seconds: user.rule.maxMeetingDuration)),
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 17,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        Strings().maxDuration,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 25,
                width: 1,
                color: Theme.of(context).dividerColor,
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${user.rule.importance[Lounge.highroller]}',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 17,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '${Lounge.highroller.name}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                height: 25,
                width: 1,
                color: Theme.of(context).dividerColor,
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${user.rule.importance[Lounge.chrony]}',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 17,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        Lounge.highroller.name,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ],
            color: Colors.transparent,
            context: context,
          ).toList(),
        ),
      ),
    );
  }

  String getDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    // String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }
}