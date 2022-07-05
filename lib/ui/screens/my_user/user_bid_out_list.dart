import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/bid_model.dart';
import 'widgets/bid_out_tile.dart';

class UserBidOut extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    var userId = ref.watch(myUIDProvider);
    if (haveToWait(userId)) {
      return WaitPage();
    }
    final bidInsWithUsers = ref.watch(bidOutsProvider(userId!));
    if (haveToWait(bidInsWithUsers) ||
        (bidInsWithUsers.asData?.value == null)) {
      return WaitPage();
    }
    List<BidOut> bidOutList = bidInsWithUsers.asData!.value;
    return Scaffold(
      appBar: CustomAppbar(
        title: Text(
          Keys.waitingGuest.tr(context),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body:bidOutList.isNotEmpty? ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shrinkWrap: true,
        itemCount: bidOutList.length,
        itemBuilder: (_, ix) {
          return BidOutTile(
            bidOut: bidOutList[ix],
            onCancelClick: (bidOut) {
              // CustomDialogs.loader(true, context);
              ref.read(myUserPageViewModelProvider)?.cancelOwnBid(bidOut: bidOut);
              // CustomDialogs.loader(false, context);
            },
          );
        },
      ):Center(
        child: Text(
            Keys.joinOtherRoom.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .subtitle1?.copyWith(
              color: Theme.of(context).disabledColor
            )),
      ),
    );
  }
}
