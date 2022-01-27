import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/models/hangout_model.dart';
import 'widgets/other_bid_tile.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.hangout, required this.bidIns});
  final Hangout hangout;
  final List<BidInPublic> bidIns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _bidsListView(ref, context);
  }

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
    if (bidIns.isEmpty) return Container();
    return ListView.builder(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bidIns.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, ix) {
        return OtherBidTile(
          otherBidList: bidIns,
          index: ix,
          hangout: hangout,
        );
      },
    );
  }
}
