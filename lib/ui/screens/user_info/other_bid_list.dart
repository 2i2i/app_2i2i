import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import 'widgets/other_bid_tile.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.user, required this.bidIns});
  final UserModel user;
  final List<BidInPublic> bidIns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _bidsListView(ref, context);
  }

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
    final userId = ref.watch(myUIDProvider);
    if (userId == null) return CupertinoActivityIndicator();
    final bidOutsAsyncValue = ref.watch(bidOutsProvider(userId));
    if (haveToWait(bidOutsAsyncValue) || (bidOutsAsyncValue.value == null)) {
      return CupertinoActivityIndicator();
    }
    final List<BidOut> bidOuts = bidOutsAsyncValue.value!;
    final bidOutIdsList = bidOuts.map((e) => e.id).toList();

    if (bidIns.isEmpty)
      return Center(
        child: Text(Keys.beFirstJoin.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(color: Theme.of(context).disabledColor)),
      );
    return ListView.builder(
      itemCount: bidIns.length,
      padding: const EdgeInsets.only(
          top: 10, left: 10, right: 10, bottom: kToolbarHeight),
      itemBuilder: (_, ix) {
        final myBidOut = bidOutIdsList.contains(bidIns[ix].id);

        return OtherBidTile(
          bidIn: bidIns[ix],
          user: user,
          myBidOut: myBidOut,
        );
      },
    );
  }
}
