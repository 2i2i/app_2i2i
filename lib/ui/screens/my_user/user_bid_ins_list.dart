// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import '../user_info/widgets/bid_dialog_widget.dart';
import '../user_info/widgets/no_bid_page.dart';
import 'widgets/bid_info_tile.dart';

class BidAndUser {
  const BidAndUser(this.bid, this.bidInPrivate, this.user, {this.bidOut});

  final BidIn bid;
  final BidInPrivate bidInPrivate;
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

  final void Function(BidIn bid, BidInPrivate bidInPrivate) onTap;

  int bidAndUserSort(BidAndUser b1, BidAndUser b2,
      AsyncValue<UserModelPrivate> myPrivateUserAsyncValue) {
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
    if (bidInList is AsyncLoading ||
        bidInList is AsyncError ||
        (bidInList.asData?.value == null)) {
      return WaitPage();
    }
    if (bidInList.asData?.value.isEmpty ?? false) {
      NoBidPage(noBidsText: noBidsText);
    }
    final myPrivateUserAsyncValue = ref.watch(userPrivateProvider(uid));
    List<BidIn> bids = bidInList.asData!.value;
    List<BidAndUser> bidInsWithUser = sortAndFilterList(bids, ref, myPrivateUserAsyncValue);
    SecureStorage().read(Keys.myReadBids).then((value) {
      List localBids = [];
      if(value?.isNotEmpty??false){
        localBids = value!.split(',').toList();
      }
      localBids.addAll(bids.map((e) => e.id).toList());
      SecureStorage().write(Keys.myReadBids, localBids.toSet().toList().join(','));
    });
    return ListView.builder(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bidInsWithUser.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, ix) {
        BidAndUser bidAndUser = bidInsWithUser[ix];

        if (bidAndUser.user == null) return Container();

        BidIn bid = bidAndUser.bid;
        BidInPrivate bidInPrivate = bidAndUser.bidInPrivate;
        UserModel userModel = bidAndUser.user!;

        return BidInfoTile(
          onTap: () => CustomDialogs.infoDialog(
            context: context,
            child: BidDialogWidget(
              bidIn: bid,
              onTapTalk: () => onTap(bid, bidInPrivate),
              userModel: userModel,
            ),
          ),
          bidSpeed: bid.speed.num.toString(),
          userModel: userModel,
        );
      },
    );
  }

  List<BidAndUser> sortAndFilterList(List<BidIn> bidIns, WidgetRef ref,
      AsyncValue<UserModelPrivate> myPrivateUserAsyncValue) {
    List<BidAndUser> bidInsWithUserNoNulls = [];

    var bidInsWithUser =
        bidIns.map((bid) => ref.watch(bidAndUserProvider(bid))).toList();
    // filter out blocked users
    if (!(myPrivateUserAsyncValue is AsyncError) &&
        !(myPrivateUserAsyncValue is AsyncLoading)) {
      final myPrivateUser = myPrivateUserAsyncValue.value;
      if (myPrivateUser != null && myPrivateUser.blocked.isNotEmpty) {
        bidInsWithUser = bidInsWithUser
            .where((BidAndUser? b) =>
                b != null && !myPrivateUser.blocked.contains(b.user!.id))
            .toList();
      }
    }

    if (bidInsWithUser.isNotEmpty) {
      bidInsWithUser.removeWhere((e) => e == null);
      bidInsWithUserNoNulls =
          bidInsWithUser.map((element) => element!).toList();
      bidInsWithUserNoNulls
          .sort((b1, b2) => bidAndUserSort(b1, b2, myPrivateUserAsyncValue));
    }

    return bidInsWithUserNoNulls;
  }
}
