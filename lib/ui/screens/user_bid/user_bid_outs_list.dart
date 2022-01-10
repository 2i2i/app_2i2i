
import 'package:app_2i2i/infrastructure/commons/theme.dart';
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
    return ListView.separated(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bids.length,
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
      itemBuilder: (_, ix) {
        BidOut bid = bids[ix];
        final bUser = ref.watch(userProvider(bid.B));

        if(bUser.asData?.value is UserModel) {
          final user = bUser.asData!.value;
          var statusColor = AppTheme().green;
          if (user.status == 'OFFLINE') {
            statusColor = AppTheme().gray;
          }
          if (user.isInMeeting()) {
            statusColor = AppTheme().red;
          }
          String firstNameChar = user.name;
          if (firstNameChar.isNotEmpty) {
            firstNameChar = firstNameChar.substring(0, 1);
          }
          return ListTile(
            onTap: () {},
            leading: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                height: 55,
                width: 55,
                child: Stack(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 0.5,
                            )
                          ]),
                      alignment: Alignment.center,
                      child: Text(
                        firstNameChar,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 15,
                        width: 15,
                        decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            title: Text(
              user.name,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              user.bio,
              maxLines: 2,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(bid.speed.num.toString() + ' Algo/Sec'),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: (){
                    onTrailingIconClick?.call(bid);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close,color: Theme.of(context).cardColor,size: 15,),
                  ),
                ),
              ],
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
      separatorBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(left: 85),
          child: Divider(),
        );
      },
    );
  }
}
