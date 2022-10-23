import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import 'widgets/other_bid_tile.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.userB, required this.bidInsB});

  final UserModel userB;
  final List<BidInPublic> bidInsB;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _bidsListView(ref, context);
  }

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
    log('_bidsListView');
    final myUid = ref.watch(myUIDProvider);
    if (myUid == null) return CupertinoActivityIndicator();
    final bidOutsAsyncValue = ref.watch(bidOutsProvider(myUid));
    if (haveToWait(bidOutsAsyncValue) || (bidOutsAsyncValue.value == null)) {
      return CupertinoActivityIndicator();
    }
    final List<BidOut> bidOuts = bidOutsAsyncValue.value!;
    final bidOutIdsList = bidOuts.map((e) => e.id).toList();
    log('_bidsListView bidOutIdsList=$bidOutIdsList');

    if (bidInsB.isEmpty)
      return Center(
        child: Text(Keys.beFirstJoin.tr(context),
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Theme.of(context).disabledColor)),
      );
    return ListView.builder(
      itemCount: bidInsB.length,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: kToolbarHeight),
      itemBuilder: (_, ix) {
        final myBidOut = bidOutIdsList.contains(bidInsB[ix].id);

        return OtherBidTile(
          bidInB: bidInsB[ix],
          userB: userB,
          myBidOut: myBidOut,
        );
      },
    );
  }
}
