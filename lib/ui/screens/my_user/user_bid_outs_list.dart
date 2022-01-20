import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/bid_model.dart';
import 'widgets/bid_info_tile.dart';

class UserBidOutsList extends ConsumerWidget {
  UserBidOutsList({
    required this.uid,
    required this.titleWidget,
    required this.noBidsText,
    // required this.onTap,
    this.trailingIcon,
    this.onTrailingIconClick,
  });

  final String uid;
  final Widget titleWidget;
  final String noBidsText;

  // final void Function(Bid bid) onTap;
  final Icon? trailingIcon;
  final void Function(BidOut bid)? onTrailingIconClick;

  Widget build(BuildContext context, WidgetRef ref) {
    final bidOutList = ref.watch(bidOutsProvider(uid));
    if(bidOutList is AsyncLoading || bidOutList is AsyncError || (bidOutList.asData?.value == null)){
      return WaitPage();
    }
    List<BidOut> bids =  bidOutList.asData!.value;
    return ListView.separated(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bids.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, ix) {
        BidOut bid = bids[ix];
        final bUser = ref.watch(userProvider(bid.B));

        if(bUser.asData?.value is UserModel) {
          final userModel = bUser.asData!.value;

          return BidInfoTile(
            bidSpeed: bid.speed.num.toString(),
            userModel: userModel,
          );
        }
        return Center(child: CupertinoActivityIndicator());
      },
      separatorBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(left: 85),
          child: Divider(),
        );
      },
    );
  }
}
