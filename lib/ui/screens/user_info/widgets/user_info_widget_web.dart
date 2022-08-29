import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../commons/custom_profile_image_view.dart';

class UserInfoWidgetWeb extends StatefulWidget {
  final UserModel user;
  final bool isFav;
  final int? estWaitTime;

  final GestureTapCallback? onTapFav;
  final GestureTapCallback? onTapWallet;
  final GestureTapCallback? onTapRules;
  final GestureTapCallback? onTapQr;
  final GestureTapCallback? onTapChat;

  const UserInfoWidgetWeb({
    Key? key,
    required this.user,
    this.onTapFav,
    required this.isFav,
    this.onTapRules,
    this.onTapQr,
    this.onTapWallet,
    this.estWaitTime,
    this.onTapChat,
  }) : super(key: key);

  @override
  _UserInfoWidgetWebState createState() => _UserInfoWidgetWebState();
}

class _UserInfoWidgetWebState extends State<UserInfoWidgetWeb> {
  ValueNotifier<bool> seeMore = ValueNotifier(false);

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    String shortBio = widget.user.bio;
    var statusColor = AppTheme().green;
    if (widget.user.status == Status.OFFLINE) {
      statusColor = AppTheme().gray;
    } else if (widget.user.status == Status.IDLE) {
      statusColor = Colors.amber;
    } else if (widget.user.isInMeeting()) {
      statusColor = AppTheme().red;
    }

    final totalRating = removeDecimalZeroFormat(widget.user.rating * 5);

    return Column(
      children: [
        Column(
          children: [
            ProfileWidget(
              stringPath: (widget.user.imageUrl?.isNotEmpty ?? false) ? widget.user.imageUrl! : widget.user.name,
              imageType: (widget.user.imageUrl?.isNotEmpty ?? false) ? ImageType.NETWORK_IMAGE : ImageType.NAME_IMAGE,
              statusColor: statusColor,
              radius: 80,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.user.name,
                  style: Theme.of(context).textTheme.headline6,
                ),
                Visibility(
                  visible: widget.user.isVerified(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Tooltip(
                      triggerMode: TooltipTriggerMode.tap,
                      message: 'Connected with social account',
                      child: SvgPicture.asset('assets/icons/done_tick.svg', width: 14, height: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () => context.pushNamed(Routes.ratings.nameFromPath(), params: {'uid': widget.user.id}),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IgnorePointer(
                    ignoring: true,
                    child: RatingBar.builder(
                      initialRating: widget.user.rating * 5,
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
                        log("$rating");
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '($totalRating/5)',
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CupertinoScrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: ValueListenableBuilder(
                    valueListenable: seeMore,
                    builder: (BuildContext context, bool value, Widget? child) {
                      var socialLinks = widget.user.socialLinks.map((e) {
                        if ((e.userName ?? "").isNotEmpty) {
                          return TextSpan(
                            text: "\n${e.accountName}: ",
                            children: [
                              TextSpan(
                                text: e.userName,
                                style: Theme.of(context).textTheme.caption?.copyWith(height: 1.2, color: Theme.of(context).colorScheme.secondary),
                              ),
                            ],
                            style: Theme.of(context).textTheme.caption,
                          );
                        } else {
                          return TextSpan();
                        }
                      }).toList();
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 30),
                        child: RichText(
                          textAlign: TextAlign.start,
                          maxLines: value ? null : 2,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: shortBio.toString().trim() + "\n\n",
                                style: Theme.of(context).textTheme.caption,
                              )
                            ]..addAll(socialLinks),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            InkResponse(
              onTap: () {
                seeMore.value = !seeMore.value;
              },
              child: ValueListenableBuilder(
                valueListenable: seeMore,
                builder: (BuildContext context, bool value, Widget? child) {
                  return Text(
                    value ? Keys.less.tr(context) : Keys.seeMore.tr(context),
                    style: Theme.of(context).textTheme.caption,
                  );
                },
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: kToolbarHeight * 1.5,
            ),
            InkResponse(
              onTap: widget.onTapChat,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Icon(Icons.chat_outlined, size: 30),
              ),
            ),
            Visibility(
              visible: widget.onTapWallet != null,
              child: InkResponse(
                onTap: widget.onTapWallet,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Icon(Icons.attach_money, size: 30),
                ),
              ),
            ),
            InkResponse(
              onTap: widget.onTapQr,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.qr_code, size: 30),
              ),
            ),
            if (widget.onTapFav != null)
              InkResponse(
                onTap: widget.onTapFav,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                  child: Icon(
                    widget.isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: widget.isFav ? Colors.red : Colors.grey,
                    size: 25,
                  ),
                ),
              ),
          ],
        ),
        UserRulesWidget(
          user: widget.user,
          onTapRules: widget.onTapRules,
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
            : SizedBox(),
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

  String importanceString() {
    final c = user.rule.importance[Lounge.chrony]!;
    final h = user.rule.importance[Lounge.highroller]!;
    final N = c + h;
    final isChrony = c <= h;
    final lounge = isChrony ? Lounge.chrony : Lounge.highroller;
    final ratio = (isChrony ? N / c : N / h).round();
    final postfix = ordinalIndicator(ratio);
    return 'every $ratio$postfix is a ${lounge.name()}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapRules?.call(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${(user.rule.minSpeed / MILLION)} A/sec',
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.secondary),
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
                    Flexible(
                      child: Text(
                        Keys.minSpeed.tr(context),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
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
                  secondsToSensibleTimePeriod(user.rule.maxMeetingDuration),
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.secondary),
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
                    Flexible(
                      child: Text(
                        Keys.maxDuration.tr(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
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
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(color: Theme.of(context).colorScheme.secondary),
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
                    Flexible(
                      child: Text(
                        Keys.importance.tr(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
  }
}
