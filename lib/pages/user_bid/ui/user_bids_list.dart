import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBidsList extends ConsumerWidget {
  UserBidsList({
    required this.bidsIds,
    required this.titleWidget,
    required this.noBidsText,
    // required this.onTap,
    required this.leading,
    this.trailingIcon,
    this.onTrailingIconClick,
  });

  final Widget titleWidget;
  final String noBidsText;
  final List<String> bidsIds;

  // final void Function(Bid bid) onTap;
  final Widget leading;
  final Icon? trailingIcon;
  final void Function(Bid bid)? onTrailingIconClick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO add sorting
    if (bidsIds.isEmpty)
      return Center(
        child: Text(noBidsText),
      );
    log('UserBids - bidsIds=$bidsIds');
    log('UserBids - bidsIds.length=${bidsIds.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.only(top: 20, left: 25),
            child: titleWidget),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 10, left: 20, right: 20, bottom: 10),
                child: _bidsListView(ref, context))),
      ],
    );
  }

  ListView _bidsListView(WidgetRef ref, BuildContext context) {
    return ListView.builder(
      itemCount: bidsIds.length,
      itemBuilder: (_, ix) {
        return StreamBuilder(
          stream: FirestoreDatabase().bidStream(id: bidsIds[ix]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              Bid bid = snapshot.data;
              final String num = bid.speed.num.toString();
              final int assetId = bid.speed.assetId;
              final String assetIDString = assetId == 0 ? 'ALGO' : assetId.toString();
              final color = ix % 2 == 0
                  ? Color.fromRGBO(223, 239, 223, 1)
                  : Color.fromRGBO(197, 234, 197, 1);

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
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
