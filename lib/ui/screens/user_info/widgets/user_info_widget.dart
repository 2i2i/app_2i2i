import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/hangout_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoWidget extends StatefulWidget {
  final Hangout hangout;
  final GestureTapCallback? onTapFav;
  final bool isFav;

  final onTapQr;
  final onTapWallet;
  final GestureTapCallback? onTapRules;

  final int? estWaitTime;

  const UserInfoWidget({
    Key? key,
    required this.hangout,
    this.onTapFav,
    required this.isFav,
    this.onTapRules,
    this.onTapQr,
    this.onTapWallet,
    this.estWaitTime,
  }) : super(key: key);

  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  ValueNotifier<bool> seeMore = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final shortBio =
        widget.hangout.bio; //user.bio.substring(shortBioStart, shortBioEnd);

    var statusColor = AppTheme().green;
    if (widget.hangout.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    } else if (widget.hangout.isInMeeting()) {
      statusColor = AppTheme().red;
    }

    final totalRating = removeDecimalZeroFormat(widget.hangout.rating * 5);

    return Column(
      children: [
        Row(
          children: [
            ProfileWidget(
              stringPath: widget.hangout.name,
              statusColor: statusColor,
              radius: 80,
            ),
            Expanded(
              child: ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.hangout.name,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Visibility(
                      visible: widget.onTapWallet != null,
                      child: IconButton(
                        onPressed: widget.onTapWallet,
                        icon: Icon(Icons.attach_money),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onTapQr,
                      icon: Icon(Icons.qr_code),
                    ),
                    if (widget.onTapFav != null)
                      IconButton(
                        onPressed: widget.onTapFav,
                        icon: Icon(
                          widget.isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: widget.isFav ? Colors.red : Colors.grey,
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 2),
                    InkWell(
                      onTap: () => context.pushNamed(Routes.ratings.nameFromPath(),params: {'uid':widget.hangout.id}),
                      child: Row(
                        children: [
                          IgnorePointer(
                            ignoring: true,
                            child: RatingBar.builder(
                              initialRating: widget.hangout.rating * 5,
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
                            value ? Keys.less.tr(context) : Keys.seeMore.tr(context),
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
        widget.estWaitTime is int ? SizedBox(height: 5) : Container(),
        widget.estWaitTime is int
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    size: 17,
                    color: Theme.of(context).textTheme.caption?.color,
                  ),
                  SizedBox(width: 2),
                  Text(
                    '${Keys.estWaitTime.tr(context)} ${secondsToSensibleTimePeriod(widget.estWaitTime!)}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )
            : Container(),
        SizedBox(height: 20),
        UserRulesWidget(
          hangout: widget.hangout,
          onTapRules: widget.onTapRules,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}

class UserRulesWidget extends StatelessWidget {
  final Hangout hangout;

  final GestureTapCallback? onTapRules;
  const UserRulesWidget({Key? key, required this.hangout, this.onTapRules})
      : super(key: key);

  String importanceString() {
    final c = hangout.rule.importance[Lounge.chrony]!;
    final h = hangout.rule.importance[Lounge.highroller]!;
    final N = c + h;
    final isChrony = c <= h;
    final lounge = isChrony ? Lounge.chrony : Lounge.highroller;
    final ratio = (isChrony ? N / c : N / h).round();
    final postfix = ordinalIndicator(ratio);
    return '~ every $ratio$postfix is a ${lounge.name()}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: () => onTapRules?.call(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${(hangout.rule.minSpeed/1000000).toStringAsFixed(2)} A/sec',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 17,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        Keys.minSpeed.tr(context),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 25,
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: 3),
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    secondsToSensibleTimePeriod(
                        hangout.rule.maxMeetingDuration),
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 17,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        Keys.maxDuration.tr(context),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 25,
              width: 1,
              margin: EdgeInsets.symmetric(horizontal: 3),
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${importanceString()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 17,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        Keys.importance.tr(context),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }
}
