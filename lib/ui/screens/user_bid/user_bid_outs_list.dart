
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../infrastructure/models/bid_model.dart';

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
    final bidOutList = ref.watch(getBidOutsProvider(uid));
    if(bidOutList is AsyncLoading || bidOutList is AsyncError || (bidOutList.asData?.value == null)){
      return WaitPage();
    }
    List<BidOut> bids =  bidOutList.asData!.value;
    return ListView.builder(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bids.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (_, ix) {
        BidOut bid = bids[ix];
        final String num = bid.speed.num.toString();
        final int assetId = bid.speed.assetId;
        final String assetIDString = assetId == 0 ? 'ALGO' : assetId.toString();
        final color = ix % 2 == 0 ? Theme.of(context).primaryColor : Theme.of(context).cardColor;

        final bUser = ref.watch(userProvider(bid.B));

        if(bUser.asData?.value is UserModel) {
          return Card(
            color: color,
            child: ListTile(
              trailing: trailingIcon == null
                  ? null
                  : IconButton(
                onPressed: () => onTrailingIconClick!(bid),
                icon: trailingIcon!,
              ),
              title: Text('$num'),
              subtitle: Text('[$assetIDString/sec]'),
              // tileColor: color,
              // onTap: () => onTap(bid),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.grey.shade300
                  )
              ),
              trailing: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 10,
                color: Colors.grey.shade300,
              ),
              subtitle: Container(
                height: 5,
                color: Colors.grey.shade300,
              ),
              // tileColor: color,
              // onTap: () => onTap(bid),
            ),
          ),
        );
        
      },
    );
  }
}
