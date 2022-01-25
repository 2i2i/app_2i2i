// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_hangout_provider/my_hangout_page_view_model.dart';
import '../home/wait_page.dart';
import '../user_info/widgets/no_bid_page.dart';
import 'widgets/bid_in_tile.dart';

class UserBidInsList extends ConsumerWidget {
  UserBidInsList({
    required this.titleWidget,
    required this.noBidsText,
    required this.onTap,
    required this.myHangoutPageViewModel,
  });

  final Widget titleWidget;
  final String noBidsText;
  final MyHangoutPageViewModel myHangoutPageViewModel;

  final void Function(BidIn bidIn) onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidInsWithUsers =
        ref.watch(bidInsProvider(myHangoutPageViewModel.hangout!.id));
    if (bidInsWithUsers == null) return WaitPage();
    if (bidInsWithUsers.isEmpty) return NoBidPage(noBidsText: noBidsText);

    // store for notification
    markAsRead(bidInsWithUsers);

    return Scaffold(
      floatingActionButton: InkResponse(
        onTap: () async {
          for (BidIn bidIn in bidInsWithUsers) {
            Hangout? hangout = bidIn.hangout;
            if (hangout is Hangout && hangout.status == 'OFFLINE' ||
                (hangout?.isInMeeting() ?? false)) {
              await myHangoutPageViewModel.cancelBid(
                  bidId: bidIn.public.id, B: bidIn.hangout!.id);
            } else {
              await myHangoutPageViewModel.acceptBid(bidIn);
              break;
            }
          }
        },
        child: Container(
          width: kToolbarHeight * 1.125,
          height: kToolbarHeight * 1.125,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  offset: Offset(2, 2),
                  blurRadius: 8,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary // changes position of shadow
                  ),
            ],
          ),
          child: Icon(
            Icons.play_arrow,
            size: 30,
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
      body: ListView.builder(
        primary: false,
        physics: NeverScrollableScrollPhysics(),
        itemCount: bidInsWithUsers.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (_, ix) {
          return BidInTile(
            bidInList: bidInsWithUsers,
            index: ix,
          );
        },
      ),
    );
  }

  void markAsRead(List<BidIn> bidInsWithUsers) {
    SecureStorage().read(Keys.myReadBids).then((String? value) {
      List<String> localBids = [];
      if (value?.isNotEmpty ?? false) {
        localBids = value!.split(',').toList();
      }
      localBids.addAll(bidInsWithUsers.map((e) => e.public.id).toList());
      String localBidIds = localBids.toSet().toList().join(',');
      log('localBidIds=$localBidIds');
      SecureStorage().write(Keys.myReadBids, localBidIds);
    });
  }
}
