// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'dart:math';

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

  final void Function(BidIn bidIn) onTap;

  // assume 0 < c+h
  Lounge betterLounge(List<Lounge> louges, HangOutRule rule) {
    int c = rule.importance[Lounge.chrony]!;
    if (c == 0) return Lounge.highroller;
    int h = rule.importance[Lounge.highroller]!;
    if (h == 0) return Lounge.chrony;

    double r = c / h;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // my user
    final userAsyncValue = ref.watch(userProvider(uid));
    if (userAsyncValue is AsyncLoading ||
        userAsyncValue is AsyncError ||
        userAsyncValue.value == null) {
      return WaitPage();
    }
    final user = userAsyncValue.value!;

    // public bid ins
    final bidInsPublicAsyncValue = ref.watch(bidInsPublicProvider(uid));
    if (bidInsPublicAsyncValue is AsyncLoading ||
        bidInsPublicAsyncValue is AsyncError ||
        bidInsPublicAsyncValue.value == null) {
      return WaitPage();
    }
    if (bidInsPublicAsyncValue.value?.isEmpty ?? false) {
      return NoBidPage(noBidsText: noBidsText);
    }
    List<BidInPublic> bidInsPublic = bidInsPublicAsyncValue.value!;

    // private bid ins
    final bidInsPrivateAsyncValue = ref.watch(bidInsPrivateProvider(uid));
    if (bidInsPrivateAsyncValue is AsyncLoading ||
        bidInsPrivateAsyncValue is AsyncError ||
        bidInsPrivateAsyncValue.value == null) {
      return WaitPage();
    }
    if (bidInsPrivateAsyncValue.value?.isEmpty ?? false) {
      return NoBidPage(noBidsText: noBidsText);
    }
    List<BidInPrivate> bidInsPrivate = bidInsPrivateAsyncValue.value!;

    // create bid ins
    final bidIns = BidIn.createList(bidInsPublic, bidInsPrivate);
    final bidInsWithUsers = bidIns
        .map((bid) => ref.watch(bidInAndUserProvider(bid)))
        .map((e) => e!)
        .toList();

    // store for notification
    SecureStorage().read(Keys.myReadBids).then((value) {
      List localBids = [];
      if (value?.isNotEmpty ?? false) {
        localBids = value!.split(',').toList();
      }
      localBids.addAll(bidInsWithUsers.map((e) => e.public.id).toList());
      SecureStorage()
          .write(Keys.myReadBids, localBids.toSet().toList().join(','));
    });

    // List<BidIn> bidInsChronies = bidIns
    //     .where((bidIn) => bidIn.public.speed.num == user.rule.minSpeed)
    //     .toList();
    // List<BidIn> bidInsHighRollers = bidIns
    //     .where((bidIn) => user.rule.minSpeed < bidIn.public.speed.num)
    //     .toList();
    // if (bidInsChronies.length + bidInsHighRollers.length != bidIns.length)
    //   throw Exception(
    //       'UserBidInsList: bidInsChronies.length + bidInsHighRollers.length != bidIns.length');

    // bidInsHighRollers.sort((b1, b2) {
    //   return b1.public.speed.num.compareTo(b2.public.speed.num);
    // });

    // List<BidIn> bidInsSorted = [];
    // if (bidInsHighRollers.isEmpty)
    //   bidInsSorted = bidInsChronies;
    // else if (bidInsChronies.isEmpty)
    //   bidInsSorted = bidInsHighRollers;
    // else {
    //   // meeting history
    //   final meetingHistoryAsyncValue = ref.watch(meetingHistoryB(uid));
    //   if (meetingHistoryAsyncValue is AsyncLoading ||
    //       meetingHistoryAsyncValue is AsyncError ||
    //       meetingHistoryAsyncValue.value == null) {
    //     return WaitPage();
    //   }
    //   final meetingHistory = meetingHistoryAsyncValue.value!;

    //   // order bidIns
    //   int N = user.rule.importanceSize();
    //   final recentMeetings = meetingHistory.getRange(0, N - 1).toList();
    //   final recentLounges = recentMeetings.map((m) => m.lounge).toList();

    //   int chronyIndex = 0;
    //   int highRollerIndex = 0;
    //   int historyIndex = min(N - 1, recentLounges.length); // -1 => do not use recentLounges

    //   // mean lounge value



    //   BidIn nextChrony = bidInsChronies[chronyIndex];
    //   BidIn nextHighroller = bidInsChronies[highRollerIndex];

    //   // next rule comes from the earlier guest if different
    //   HangOutRule nextRule =
    //       nextChrony.public.rule == nextHighroller.public.rule
    //           ? nextChrony.public.rule
    //           : (nextChrony.public.ts.microsecondsSinceEpoch <
    //                   nextHighroller.public.ts.microsecondsSinceEpoch
    //               ? nextChrony.public.rule
    //               : nextHighroller.public.rule);

    //   // is nextChrony eligible according to nextRule
    //   if (nextChrony.public.speed.num < nextRule.minSpeed) {
    //     // choose HighRoller
    //     bidInsSorted.add(nextHighroller);

    //     // next

    //   }
    // }

    return ListView.builder(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bidInsWithUsers.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, ix) {
        BidIn bidIn = bidInsWithUsers[ix];

        return BidInfoTile(
          onTap: () => CustomDialogs.infoDialog(
            context: context,
            child: BidDialogWidget(
              bidIn: bidIn,
              onTapTalk: () => onTap(bidIn),
              userModel: userModel,
            ),
          ),
          bidSpeed: bid.speed.num.toString(),
          userModel: userModel,
        );
      },
    );
  }
}
