import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/pages/user_bid/ui/widgets/no_bid_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBidInsList extends ConsumerWidget {
  UserBidInsList({
    required this.uid,
    // required this.bidInsIds,
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
  // final List<String> bidInsIds;

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
                  log('UserBidInsList - build - itemBuilder - ix=$ix');
                  BidIn bid = snapshot.data[ix];
                  final String num = bid.speed.num.toString();
                  final int assetId = bid.speed.assetId;
                  final String assetIDString =
                      assetId == 0 ? 'ALGO' : assetId.toString();
                  final color = ix % 2 == 0
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor;

                  return Card(
                      color: color,
                      child: ListTile(
                        leading: leading,
                        trailing: trailingIcon == null
                            ? null
                            : IconButton(
                                onPressed: () => onTrailingIconClick!(bid),
                                icon: trailingIcon!),
                        title: Text('$num'),
                        subtitle: Text('[$assetIDString/sec]'),
                        // tileColor: color,
                        // onTap: () => onTap(bid),
                      ));
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}