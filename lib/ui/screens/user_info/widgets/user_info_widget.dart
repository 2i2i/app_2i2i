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

class UserInfoWidget extends StatefulWidget {
  final UserModel user;
  final bool isFav;
  final int? estWaitTime;

  final GestureTapCallback? onTapFav;
  final GestureTapCallback? onTapWallet;
  final GestureTapCallback? onTapRules;
  final GestureTapCallback? onTapQr;
  final GestureTapCallback? onTapChat;

  const UserInfoWidget({
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
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileWidget(
              stringPath: (widget.user.imageUrl?.isNotEmpty ?? false) ? widget.user.imageUrl! : widget.user.name,
              imageType: (widget.user.imageUrl?.isNotEmpty ?? false) ? ImageType.NETWORK_IMAGE : ImageType.NAME_IMAGE,
              statusColor: statusColor,
              radius: 80,
            ),
            Expanded(
              child: ListTile(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 6,
                      child: Text(
                        widget.user.name,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      flex: 2,
                      child: Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: Keys.connectedSocialAccount.tr(context),
                        child: SvgPicture.asset('assets/icons/done_tick.svg', width: 14, height: 14),
                      ),
                    )
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkResponse(
                      onTap: widget.onTapChat,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Icon(Icons.chat_outlined, size: 25),
                      ),
                    ),
                    Visibility(
                      visible: widget.onTapWallet != null,
                      child: InkResponse(
                        onTap: widget.onTapWallet,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Icon(Icons.attach_money, size: 25),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: widget.user.url?.isNotEmpty ?? false,
                      child: InkResponse(
                        onTap: widget.onTapQr,
                        child: Icon(Icons.qr_code, size: 25),
                      ),
                    ),
                    if (widget.onTapFav != null)
                      InkResponse(
                        onTap: widget.onTapFav,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Icon(widget.isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: widget.isFav ? Colors.red : Colors.grey, size: 25),
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
                      onTap: () => context.pushNamed(Routes.ratings.nameFromPath(), params: {'uid': widget.user.id}),
                      child: Row(
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
                          Flexible(
                            child: Text(
                              '($totalRating/5)',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 6),
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
                              return RichText(
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
                    '${Keys.estWaitTime.tr(context)} ${secondsToSensibleTimePeriod(widget.estWaitTime!, context)}',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )
            : Container(),
        SizedBox(height: 10),
        UserRulesWidget(
          user: widget.user,
          onTapRules: widget.onTapRules,
        ),
        SizedBox(height: 8),
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
              mainAxisAlignment: MainAxisAlignment.end,
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
                  secondsToSensibleTimePeriod(user.rule.maxMeetingDuration, context),
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
