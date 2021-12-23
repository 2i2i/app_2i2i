import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/pages/user_bid/ui/widgets/no_bid_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBidInsList extends ConsumerWidget {
  UserBidInsList({
    required this.uid,
    required this.titleWidget,
    required this.noBidsText,
    required this.onTap,
  });

  final String uid;
  final Widget titleWidget;
  final String noBidsText;

  final void Function(BidIn bid) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('UserBidInsList - build - uid=$uid');

    final accountService = ref.watch(accountServiceProvider);

    return StreamBuilder(
        stream: FirestoreDatabase().bidInsStream(uid: uid),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          log('UserBidInsList - build - snapshot.hasData=${snapshot.hasData}');
          if (snapshot.hasData) {
            log('UserBidInsList - build - snapshot.data.length=${snapshot.data.length}');
            if (snapshot.data.length == 0) {
              return NoBidPage(noBidsText: noBidsText);
            }

            return ListView.builder(
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, ix) {
                  BidIn bid = snapshot.data[ix];

                  // TODO make the status based on user a separate Widget, which can load independently
                  final bidInPrivateAsyncValue =
                      ref.watch(getBidInPrivate(bid.id)); 
                  if (bidInPrivateAsyncValue is AsyncLoading ||
                      bidInPrivateAsyncValue is AsyncError) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final bidInPrivate = bidInPrivateAsyncValue.data!.value!;

                  final userAsyncValue =
                      ref.watch(userProvider(bidInPrivate.A));
                  if (userAsyncValue is AsyncLoading ||
                      userAsyncValue is AsyncError) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final user = userAsyncValue.data!.value;

                  var statusColor = AppTheme().green;
                  if (user.status == 'OFFLINE') statusColor = AppTheme().gray;
                  if (user.locked) statusColor = AppTheme().red;

                  final String num = bid.speed.num.toString();
                  final int assetId = bid.speed.assetId;
                  final String assetIDString =
                      assetId == 0 ? 'ALGO' : assetId.toString();
                  final color = ix % 2 == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor;

                  return InkResponse(
                    onTap: () => CustomDialogs.bidInInfoDialog(
                        context: context,
                        user: user,
                        bidInModel: bid,
                        bidInPrivate: bidInPrivate,
                        onTapTalk: () => onTap(bid),
                        accountService: accountService,
                        ),
                    child: Card(
                        color: color,
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(Icons.circle, color: statusColor),
                            onPressed: null,
                          ),
                          title: Text('$num [$assetIDString/sec]'),
                        )),
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
