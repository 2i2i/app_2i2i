import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class OtherBidTile extends ConsumerWidget {
  final List<BidInPublic> otherBidList;
  final int index;

  const OtherBidTile(
      {Key? key, required this.otherBidList, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    num startAfter = 0;
    String bidSpeed = "0";
    BidInPublic otherBid = otherBidList[index];

    final userAsyncValue = ref.watch(hangoutProvider(otherBid.id));
    if (userAsyncValue is AsyncLoading || userAsyncValue is AsyncError) {
      return CupertinoActivityIndicator();
    }

    bidSpeed = otherBid.speed.num.toString();
    for (int i = 0; i <= index; i++) {
      var sum = getMaxDuration(budget: otherBidList[i].budget, speed: otherBidList[i].speed.num);
      startAfter += sum;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ListTile(
            leading: Image.asset(
              'assets/algo_logo.png',
              height: 34,
              width: 34,
            ),
            title: RichText(
              text: TextSpan(
                text: bidSpeed,
                children: [
                  TextSpan(
                    text: ' μAlgo/s',
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
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: 'Start After:',
                  children: [
                    TextSpan(
                        text: ' ${secondsToSensibleTimePeriod(startAfter)}',
                        children: [],
                        style: Theme.of(context).textTheme.bodyText2)
                  ],
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
            trailing: Icon(Icons.call_made_rounded, color: AppTheme().red),
          )),
    );
  }
}
