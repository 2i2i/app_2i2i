// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_hangout_provider/my_hangout_page_view_model.dart';
import '../home/wait_page.dart';
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
    final bidInsWithUsers = ref
        .watch(bidInsWithHangoutsProvider(myHangoutPageViewModel.hangout.id));
    if (bidInsWithUsers == null) return WaitPage();

    // store for notification
    markAsRead(bidInsWithUsers);
    List<BidIn> bidIns = bidInsWithUsers.toList();
    return Scaffold(
      floatingActionButton: InkResponse(
        onTap: () async {
          for (BidIn bidIn in bidIns) {
            Hangout? hangout = bidIn.hangout;
            if (hangout == null) {
              return;
            }

            final acceptedBid = await myHangoutPageViewModel.acceptBid(bidIn);
            if (acceptedBid) break;
          }
        },
        child: Container(
          width: kToolbarHeight * 1.15,
          height: kToolbarHeight * 1.15,
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
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                size: 30,
                color: Theme.of(context).cardColor,
              ),
              SizedBox(height: 2),
              Text(Keys.talk.tr(context),
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(context).cardColor,
                      ))
            ],
          ),
        ),
      ),
      body: ListView.builder(
        //primary: false,
        //physics: NeverScrollableScrollPhysics(),
        itemCount: bidInsWithUsers.length,
        padding: const EdgeInsets.only(top: 10, bottom: 80),
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
      SecureStorage().write(Keys.myReadBids, localBidIds);
    });
  }
}
