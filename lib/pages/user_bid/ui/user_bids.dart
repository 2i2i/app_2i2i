import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserBids extends ConsumerWidget {
  UserBids({
    required this.bidsIds,
    required this.title,
    required this.noBidsText,
    // required this.onTap,
    required this.leading,
    this.trailingIcon,
    this.onTrailingIconClick,
  });
  final String title;
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
      children: [
        Container(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
                child:
                    Text(title, style: Theme.of(context).textTheme.headline6))),
        Expanded(
            child: Container(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 10),
                child: _bidsListView(ref))),
      ],
    );
  }

  ListView _bidsListView(WidgetRef ref) {
    return ListView.builder(
      itemCount: bidsIds.length,
      // itemCount: 2,
      itemBuilder: (_, ix) {
        log('UserBidUserBidssIn - ListView.builder - itemBuilder');
        final bidAsyncValue = ref.watch(bidStreamProvider(bidsIds[ix]));
        log('UserBids - ListView.builder - itemBuilder - ix=$ix');
        log('UserBids - ListView.builder - itemBuilder - bidsInIds[ix]=${bidsIds[ix]}');
        log('UserBids - ListView.builder - itemBuilder - bidAsyncValue=$bidAsyncValue');

        return bidAsyncValue.when(
            data: (Bid bid) {
              log('UserBids - ListView.builder - itemBuilder - when - data - bid=$bid');
              final String num = bid.speed.num.toString();
              final int assetId = bid.speed.assetId;
              final String assetIDString =
                  assetId == 0 ? 'ALGO' : assetId.toString();

              final color = ix % 2 == 0
                  ? Color.fromRGBO(223, 239, 223, 1)
                  : Color.fromRGBO(197, 234, 197, 1);

              return Container(
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(100),
                  // ),
                  child: Card(
                      color: color,
                      child: Column(children: [
                        ListTile(
                          leading: leading,
                          trailing: trailingIcon == null
                              ? null
                              : IconButton(
                                  onPressed: () => onTrailingIconClick!(bid),
                                  icon: trailingIcon!),
                          title: Text('$num'),
                          // subtitle: Text('[$assetIDString/sec]'),
                          // tileColor: color,
                          // onTap: () => onTap(bid),
                        ),
                        Text('[$assetIDString/sec]'),
                      ])));
            },
            loading: () => const Text('loading'),
            error: (_, __) => const Text('error'));
      },
    );
  }
}
