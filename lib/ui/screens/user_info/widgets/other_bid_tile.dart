import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/commons/utils.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class OtherBidTile extends ConsumerWidget {
  final BidInPublic bidIn;

  const OtherBidTile({Key? key, required this.bidIn})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(myUIDProvider);
    int duration = bidIn.speed.num == 0
        ? bidIn.rule.maxMeetingDuration
        : (bidIn.energy / bidIn.speed.num).round();

    Widget userItem = Card(
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
                text: bidIn.speed.num.toString(),
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
                  text: '${Keys.duration.tr(context)}:',
                  children: [
                    TextSpan(
                        text: ' ${secondsToSensibleTimePeriod(duration)}',
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
    return userItem;

  }

  Widget coverWidget(Widget child, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Your Bid',
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.end,
            ),
          )
        ],
      ),
    );
  }
}
