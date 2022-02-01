import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/models/bid_model.dart';
import 'widgets/bid_out_tile.dart';

class UserBidOut extends ConsumerWidget {

  Widget build(BuildContext context, WidgetRef ref) {
    var userId = ref.watch(myUIDProvider);
    if (haveToWait(userId)){
      return WaitPage();
    }
    final bidInsWithUsers = ref.watch(bidOutsProvider(userId!));
    if (haveToWait(bidInsWithUsers) ||
        (bidInsWithUsers.asData?.value == null)) {
      return WaitPage();
    }
    List<BidOut> bidOutList = bidInsWithUsers.asData!.value;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: 10,top: kIsWeb?10:31),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 30,left: 30),
              child: Text(
                Strings().bidOut,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                //primary: false,
                //physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: bidOutList.length,
                itemBuilder: (_, ix) {
                  return BidOutTile(
                    bidOut: bidOutList[ix],
                    onCancelClick: (bidOut) async{
                      CustomDialogs.loader(true, context);
                      final myHangoutPageViewModel = ref.read(myHangoutPageViewModelProvider);
                      await myHangoutPageViewModel?.cancelOwnBid(bidOut: bidOut);
                      CustomDialogs.loader(false, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
