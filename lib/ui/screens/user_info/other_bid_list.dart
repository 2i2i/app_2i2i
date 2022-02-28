import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (bidIns.isEmpty) return Container();
    return ListView.builder(
      itemCount: bidIns.length,
      padding: const EdgeInsets.only(top: 10,left: 10,right: 10,bottom: kToolbarHeight),
      itemBuilder: (_, ix) {
        return OtherBidTile(
          bidIn: bidIns[ix],
        );
      },
    );
  }
}
