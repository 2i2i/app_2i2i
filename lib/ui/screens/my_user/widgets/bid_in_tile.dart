import 'dart:math';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/routes/app_routes.dart';

class BidInTile extends StatelessWidget {
  final List<BidIn> bidInList;
  final int index;

  const BidInTile({Key? key, required this.bidInList, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var statusColor = AppTheme().green;

    BidIn bidIn = bidInList[index];

    UserModel user = bidInList[index].user!;

    int budgetCountInt = 0;
    int totalDuration = 0;
    for (int i = 0; i < index; i++) {
      budgetCountInt += bidInList[i].public.energy;
      int thisBidMaxDuration = bidInList[i].public.rule.maxMeetingDuration;
      if (0 < bidInList[i].public.speed.num) {
        final thisBidMaxDurationTmp =
            (bidInList[i].public.energy / bidInList[i].public.speed.num)
                .floor();
        thisBidMaxDuration = min(thisBidMaxDuration, thisBidMaxDurationTmp);
      }
      totalDuration += thisBidMaxDuration;
    }
    budgetCountInt += bidInList[index].public.energy;
    final budgetCount = budgetCountInt / 1000000;

    if (user.status == Status.OFFLINE) {
      statusColor = AppTheme().gray;
    }
    if (user.status == Status.IDLE) {
      statusColor = Colors.amber;
    }
    if (user.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    String firstNameChar = user.name;
    if (firstNameChar.isNotEmpty) {
      firstNameChar = firstNameChar.substring(0, 1);
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 4),
                InkResponse(
                  onTap: () => context.pushNamed(Routes.user.nameFromPath(), params: {
                    'uid': user.id,
                  }),
                  child: SizedBox(
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
                                  color: Theme.of(context).disabledColor),
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
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                fontWeight: FontWeight.w600, fontSize: 20),
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
                                Border.all(color: Colors.white, width: 2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.bio,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: bidIn.public.speed.num.toString(),
                    children: [
                      TextSpan(
                        text: '\nμAlgo/s',
                        children: [],
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      )
                    ],
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ),
                // Text(bid.speed.num.toString() + ' μAlgo/s'),
                SizedBox(width: 8),
                Image.asset(
                  'assets/algo_logo.png',
                  height: 34,
                  width: 34,
                ),
                SizedBox(width: 4),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${Keys.accumulatedSupport.tr(context)} ',
                        children: [
                          TextSpan(
                              text: ' $budgetCount',
                              children: [],
                              style: Theme.of(context).textTheme.bodyText2)
                        ],
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                  Container(
                    child: VerticalDivider(),
                    height: 20,
                  ),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '${Keys.startsIn.tr(context)} ',
                        children: [
                          TextSpan(
                              text:
                              ' ${secondsToSensibleTimePeriod(totalDuration)}',
                              style: Theme.of(context).textTheme.bodyText2)
                        ],
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
