import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/pages/user_bid/ui/widgets/no_bid_page.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBidOutsList extends ConsumerWidget {
  UserBidOutsList({
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
  final void Function(BidOut bid)? onTrailingIconClick;

  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: FirestoreDatabase().bidOutsStream(uid: uid),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return NoBidPage(noBidsText: noBidsText);
            }

            return ListView.builder(
                itemCount: snapshot.data.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, ix) {
                  BidOut bid = snapshot.data[ix];
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
