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
    // required this.onTap,
    required this.leading,
    this.trailingIcon,
    this.onTrailingIconClick,
  });

  final String uid;
  final Widget titleWidget;
  final String noBidsText;

  // final void Function(Bid bid) onTap;
  final Widget leading;
  final Icon? trailingIcon;
  final void Function(BidIn bid)? onTrailingIconClick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('UserBidInsList - build - uid=$uid');
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

                  final bidInPrivate = ref.watch(getBidInPrivate(bid.id));
                  if (bidInPrivate is AsyncLoading ||
                      bidInPrivate is AsyncError) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final user =
                      ref.watch(userProvider(bidInPrivate.data!.value!.A));
                  if (user is AsyncLoading || user is AsyncError) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var statusColor = AppTheme().green;
                  if (user.data!.value.status == 'OFFLINE')
                    statusColor = AppTheme().gray;
                  if (user.data!.value.locked) statusColor = AppTheme().red;

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
                        bidInModel: bid,
                        bidInPrivate: bidInPrivate.data!.value!,
                        onTapTalk: () => onTrailingIconClick!(bid)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                              color: color,
                              child: ListTile(
                                leading: leading,
                                trailing: Icon(Icons.circle, color: statusColor),
                                title: Text('$num'),
                                subtitle: Text('[$assetIDString/sec]'),
                                // tileColor: color,
                                // onTap: () => onTap(bid),
                              )),
                        ),
                        trailingIcon != null?Card(
                          color: color,
                          child: Container(
                            width: kToolbarHeight,
                            height: kToolbarHeight,
                            child: IconButton(
                                onPressed: () =>
                                    onTrailingIconClick!(bid),
                                icon: trailingIcon!),
                          ),
                        ):Container(),
                      ],
                    ),
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
