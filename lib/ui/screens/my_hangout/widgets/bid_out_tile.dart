import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/models/bid_model.dart';
import '../../../../infrastructure/models/hangout_model.dart';
import '../../../../infrastructure/providers/all_providers.dart';

class BidOutTile extends ConsumerWidget {
  final List<BidOut> bidOutList;
  final int index;

  const BidOutTile({Key? key, required this.bidOutList, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var statusColor = AppTheme().green;
    var budgetCount = 0;
    String bidSpeed = "0";
    BidOut bidOut = bidOutList[index];

    final userAsyncValue = ref.watch(hangoutProvider(bidOut.B));
    if (userAsyncValue is AsyncLoading || userAsyncValue is AsyncError) {
      return CupertinoActivityIndicator();
    }

    Hangout hangout = userAsyncValue.asData!.value;

    bidSpeed = bidOut.speed.num.toString();

    for (int i = 0; i <= index; i++) {
      budgetCount += bidOutList[i].budget;
    }

    if (hangout.status == 'OFFLINE') {
      statusColor = AppTheme().gray;
    }
    if (hangout.isInMeeting()) {
      statusColor = AppTheme().red;
    }
    String firstNameChar = hangout.name;
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
                          style: Theme.of(context).textTheme.headline6!.copyWith(
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
                              border: Border.all(color: Colors.white, width: 2)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        hangout.name,
                        maxLines: 2,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        hangout.bio,
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
                  Spacer(),
                  Expanded(
                    child: RichText(
                      textAlign: TextAlign.end,
                      text: TextSpan(
                        text: 'Total Budget:',
                        children: [
                          TextSpan(
                            text: ' $budgetCount',
                            children: [],
                            style: Theme.of(context).textTheme.bodyText2
                          )
                        ],
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
