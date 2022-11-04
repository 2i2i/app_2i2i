import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/user_model.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom_profile_image_view.dart';

class BidInTile extends ConsumerWidget {
  final List<BidIn> bidInList;
  final int index;

  const BidInTile({Key? key, required this.bidInList, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusColor = AppTheme().green;

    BidIn bidIn = bidInList[index];

    UserModel user = bidInList[index].user!;

    FXModel FXValue = FXModel.ALGO();
    if (bidIn.public.speed.assetId != 0) {
      final FXAsyncValue = ref.watch(FXProvider(bidIn.public.speed.assetId));
      if (FXAsyncValue is AsyncLoading || FXAsyncValue is AsyncError) {
        return CupertinoActivityIndicator();
      }
      FXValue = FXAsyncValue.value!;
    }

    int budgetCountInt = 0;
    int totalDuration = 0;
    for (int i = 0; i < index; i++) {
      budgetCountInt += bidInList[i].public.energy;
      int thisBidMaxDuration = bidInList[i].public.rule.maxMeetingDuration;
      if (0 < bidInList[i].public.speed.num) {
        final thisBidMaxDurationTmp = (bidInList[i].public.energy / bidInList[i].public.speed.num).floor();
        thisBidMaxDuration = min(thisBidMaxDuration, thisBidMaxDurationTmp);
      }
      totalDuration += thisBidMaxDuration;
    }
    budgetCountInt += bidInList[index].public.energy;
    final budgetCount = budgetCountInt / pow(10, FXValue.decimals);

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 4),
                ProfileWidget(
                  stringPath: (user.imageUrl ?? "").isEmpty ? user.name : user.imageUrl!,
                  imageType: (user.imageUrl ?? "").isEmpty ? ImageType.NAME_IMAGE : ImageType.NETWORK_IMAGE,
                  radius: 60,
                  borderRadius: 10,
                  hideShadow: true,
                  showBorder: false,
                  statusColor: statusColor,
                  style: Theme.of(context).textTheme.headline5,
                  onTap: () => context.pushNamed(Routes.user.nameFromPath(), params: {
                    'uid': user.id,
                  }),
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
                    text: (bidIn.public.speed.num / pow(10, FXValue.decimals)).toString(),
                    children: [
                      TextSpan(
                        text: '\n${FXValue.getName}/s',
                        children: [],
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                              color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.7),
                            ),
                      )
                    ],
                    style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: Theme.of(context).textTheme.headline6?.color?.withOpacity(0.7),
                        ),
                  ),
                ),
                SizedBox(width: 8),
                Image.network(
                  FXValue.iconUrl ?? '',
                  width: 34,
                  height: 34,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/algo_logo.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.fill,
                  ),
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
                        children: [TextSpan(text: ' $budgetCount', children: [], style: Theme.of(context).textTheme.bodyText2)],
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
                        children: [TextSpan(text: ' ${secondsToSensibleTimePeriod(totalDuration, context)}', style: Theme.of(context).textTheme.bodyText2)],
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
