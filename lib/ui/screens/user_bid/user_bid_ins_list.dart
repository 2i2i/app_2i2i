// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import 'widgets/bid_dialog_widget.dart';
import 'widgets/no_bid_page.dart';

class BidAndUser {
  const BidAndUser(this.bid, this.user, {this.bidOut});
  final BidIn bid;
  final BidOut? bidOut;
  final UserModel? user;
}

class UserBidInsList extends ConsumerWidget {
  UserBidInsList({
    required this.uid,
    required this.titleWidget,
    required this.noBidsText,
    required this.onTap,
  });

  final String uid;
  final Widget titleWidget;
  final String noBidsText;

  final void Function(BidIn bid) onTap;

  int bidAndUserSort(BidAndUser b1, BidAndUser b2, AsyncValue<UserModelPrivate> myPrivateUserAsyncValue) {
    if (b1.user == null && b2.user != null) return 1;
    if (b1.user != null && b2.user == null) return -1;
    if (b1.user == null && b2.user == null) return -1;
    if (b1.user!.status == 'ONLINE' && b2.user!.status != 'ONLINE') return -1;
    if (b1.user!.status != 'ONLINE' && b2.user!.status == 'ONLINE') return 1;
    // both ONLINE xor OFFLINE
    if (b1.user!.isInMeeting() && !b2.user!.isInMeeting()) return 1;
    if (!b1.user!.isInMeeting() && b2.user!.isInMeeting()) return -1;
    // both in meeting xor neither
    if (!(myPrivateUserAsyncValue is AsyncError) &&
        !(myPrivateUserAsyncValue is AsyncLoading)) {
      final myPrivateUser = myPrivateUserAsyncValue.value;
      if (myPrivateUser != null) {
        if (myPrivateUser.friends.contains(b1.user!.id) &&
            !myPrivateUser.friends.contains(b2.user!.id)) return -1;
        if (!myPrivateUser.friends.contains(b1.user!.id) &&
            myPrivateUser.friends.contains(b2.user!.id)) return 1;
        // both friends xor not
      }
    }
    if (b1.bid.speed.num < b2.bid.speed.num) return 1;
    if (b2.bid.speed.num < b1.bid.speed.num) return -1;
    return -1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidInList = ref.watch(getBidInsProvider(uid));
    if(bidInList is AsyncLoading || bidInList is AsyncError || (bidInList.asData?.value == null)){
      return CircularProgressIndicator();
    }
    if(bidInList.asData?.value.isEmpty??false){
      NoBidPage(noBidsText: noBidsText);
    }
    final myPrivateUserAsyncValue = ref.watch(userPrivateProvider(uid));
    List<BidIn> bids = bidInList.asData!.value;
    List<BidAndUser> bidInsWithUser = sortAndFilterList(bids, ref, myPrivateUserAsyncValue);
    return ListView.separated(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bidInsWithUser.length,
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 10),
      separatorBuilder: (_, ix) {
        return Padding(
          padding: EdgeInsets.only(left: 85),
          child: Divider(),);
      },
      itemBuilder: (_, ix) {
        BidAndUser bidAndUser = bidInsWithUser[ix];

        if (bidAndUser.user == null) return Container();

        BidIn bid = bidAndUser.bid;
        UserModel userModel = bidAndUser.user!;

        var statusColor = AppTheme().green;
        if (userModel.status == 'OFFLINE') {
          statusColor = AppTheme().gray;
        }
        if (userModel.isInMeeting()) {
          statusColor = AppTheme().red;
        }
        String firstNameChar = userModel.name;
        if(firstNameChar.isNotEmpty){
          firstNameChar = firstNameChar.substring(0,1);
        }
        return ListTile(
          onTap: (){
            CustomDialogs.infoDialog(
              context: context,
              child: BidDialogWidget(
                bidIn: bid,
                onTapTalk: () => onTap(bid),
                userModel: userModel,
              ),
            );
          },
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
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            spreadRadius: 0.5,
                          )
                        ]
                    ),
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
                          border: Border.all(color: Colors.white,width: 2)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Text(userModel.name),
          subtitle: Text(userModel.bio),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(bid.speed.num.toString() + ' μAlgo/s'),
              SizedBox(width: 8),
              Image.asset(
                'assets/algo_logo.png',
                height: 30,
                width: 30,
              )
            ],
          ),
        );
      },
    );
  }

  List<BidAndUser> sortAndFilterList(List<BidIn> bidIns, WidgetRef ref, AsyncValue<UserModelPrivate> myPrivateUserAsyncValue) {
    var bidInsWithUser = bidIns.map((bid) {
      final user = ref.watch(bidUserProvider(bid.id));
      return BidAndUser(bid, user);
    }).toList();

    // filter out blocked users
    if (!(myPrivateUserAsyncValue is AsyncError) && !(myPrivateUserAsyncValue is AsyncLoading)) {
      final myPrivateUser = myPrivateUserAsyncValue.value;
      if (myPrivateUser != null) {
        bidInsWithUser = bidInsWithUser
            .where((bidAndUser) =>
                bidAndUser.user != null &&
                !myPrivateUser.blocked.contains(bidAndUser.user!.id))
            .toList();
      }
    }

    // sort
    bidInsWithUser.sort((b1, b2) => bidAndUserSort(b1, b2, myPrivateUserAsyncValue));
    return bidInsWithUser;
  }
}
