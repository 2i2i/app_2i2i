import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/models/hangout_model.dart';
import 'widgets/other_bid_tile.dart';

class OtherBidInList extends ConsumerWidget {
  OtherBidInList({required this.B});
  final Hangout B;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _bidsListView(ref, context);
  }

  Widget _bidsListView(WidgetRef ref, BuildContext context) {
    final bidInsAsyncValue = ref.watch(bidInsPublicProvider(B.id));
    if (haveToWait(bidInsAsyncValue)) return WaitPage();
    final bidIns = bidInsAsyncValue.value!;
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
          hangout: B,
        );
      },
    );

    // return StreamBuilder<List<BidInPublic>>(
    //     stream: bidInsPublicProvider(uid: B.id).stream,
    //     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //       if (snapshot.hasData) {
    //         return ListView.builder(
    //             shrinkWrap: true,
    //             padding:
    //                 const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    //             itemCount: snapshot.data.length,
    //             itemBuilder: (_, ix) {
    //               return OtherBidTile(
    //                 otherBidList: snapshot.data,
    //                 index: ix,
    //                 hangout: B,
    //               );
    //             });
    //       }
    //       return Center(child: CircularProgressIndicator());
    //     });
  }
}
