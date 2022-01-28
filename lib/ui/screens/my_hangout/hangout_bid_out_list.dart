import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/bid_model.dart';
import 'widgets/bid_out_tile.dart';

class UserBidOutsList extends ConsumerWidget {
  UserBidOutsList({
    required this.uid,
    required this.titleWidget,
    required this.noBidsText,
    // required this.onTap,
    this.trailingIcon,
    required this.onTrailingIconClick,
  });

  final String uid;
  final Widget titleWidget;
  final String noBidsText;

  // final void Function(Bid bid) onTap;
  final Icon? trailingIcon;
  final void Function(BidOut bid) onTrailingIconClick;

  Widget build(BuildContext context, WidgetRef ref) {
    final bidInsWithUsers = ref.watch(bidOutsProvider(uid));
    if (haveToWait(bidInsWithUsers) ||
        (bidInsWithUsers.asData?.value == null)) {
      return WaitPage();
    }
    List<BidOut> bidOutList = bidInsWithUsers.asData!.value;
    return ListView.builder(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bidOutList.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, ix) {
        return BidOutTile(
          bidOut: bidOutList[ix],
          onCancelClick: onTrailingIconClick,
        );
      },
    );
  }
}
