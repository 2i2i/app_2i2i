import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/meeting_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class MeetingHistoryTile extends ConsumerWidget {
  final GestureTapCallback? onTap;
  final String currentUid;
  final Meeting meetingModel;

  const MeetingHistoryTile(
      {Key? key,
      this.onTap,
      required this.currentUid,
      required this.meetingModel})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusColor = AppTheme().green;

    bool amA = meetingModel.A == currentUid;

    final user =
        ref.watch(userProvider(amA ? meetingModel.B : meetingModel.A)).value;
    if (haveToWait(user)) {
      return Container();
    }

    if (user?.status == Status.OFFLINE) {
      statusColor = AppTheme().gray;
    }
    if (user?.status == Status.IDLE) {
      statusColor = Colors.amber;
    }
    if (user?.isInMeeting() ?? false) {
      statusColor = AppTheme().red;
    }
    String firstNameChar = user?.name ?? '';
    if (firstNameChar.isNotEmpty) {
      firstNameChar = firstNameChar.substring(0, 1);
    }

    int amount = meetingModel.energy['B'] ?? 0;
    if (amA) amount += meetingModel.energy['CREATOR'] ?? 0;
    double amountInALGO = amount / MILLION;

    return InkResponse(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 4),
              SizedBox(
                height: 55,
                width: 55,
                child: Stack(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.3,
                            color: Theme.of(context).disabledColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .iconTheme
                                  .color!
                                  .withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 0.5,
                            )
                          ]),
                      alignment: Alignment.center,
                      child: Text(
                        firstNameChar,
                        style: Theme.of(context).textTheme.headline6,
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
                            border: Border.all(color: Colors.white, width: 2)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      user!.name,
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 6),
                    Text(
                      getTime(),
                      maxLines: 2,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$amountInALGO ${Keys.ALGO.tr(context)}'.toUpperCase(),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 4),
                    Visibility(
                      visible: meetingModel.settled,
                      child: Text(
                        'Settled',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SvgPicture.asset(
                amA ? 'assets/icons/upward.svg' : 'assets/icons/income.svg',
                height: 28,
                width: 28,
              ),
              SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  String getTime() {
    DateTime meetingTime = (meetingModel.end ?? DateTime.now()).toLocalDateTime();
    DateFormat formatDate = new DateFormat("yyyy-MM-dd\nhh:mm:a");
    String time = formatDate.format(meetingTime.toLocal());
    return time;
  }
}

extension DateTimeExtension on DateTime {
  DateTime toLocalDateTime({String format = "yyyy-MM-dd HH:mm:ss"}) {
    var dateTime = DateFormat(format).parse(this.toString(), true);
    return dateTime.toLocal();
  }
}
