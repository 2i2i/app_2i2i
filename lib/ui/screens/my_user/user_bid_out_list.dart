import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:app_2i2i/ui/screens/my_user/widgets/bid_out_tile_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../commons/custom_app_bar_holder.dart';

class UserBidOut extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    var userId = ref.watch(myUIDProvider);
    if (haveToWait(userId)) {
      return WaitPage();
    }
    final bidInsWithUsers = ref.watch(bidOutsProvider(userId!));
    if (haveToWait(bidInsWithUsers) || (bidInsWithUsers.value == null)) {
      return WaitPage();
    }
    List<BidOut> bidOutList = bidInsWithUsers.value!;

    return Scaffold(
      appBar: CustomAppbarHolder(
        title: Text(
          Keys.waitingGuest.tr(context),
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: bidOutList.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              shrinkWrap: true,
              itemCount: bidOutList.length,
              itemBuilder: (_, ix) {
                return BidOutTileHolder(
                  bidOut: bidOutList[ix],
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 16,
                    child: Image.asset(
                      'assets/join_host.png',
                      fit: BoxFit.fitWidth,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 50,
                  ),
                  Text(Keys.joinOtherRoom.tr(context),
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).disabledColor)),
                ],
              ),
            ),
    );
  }
}
