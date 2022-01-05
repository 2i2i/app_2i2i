// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';

import '../../../infrastructure/data_access_layer/repository/firestore_database.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/bid_model.dart';
import 'widgets/no_bid_page.dart';

import 'widgets/bid_dialog_widget.dart';

class BidAndUser {
  const BidAndUser(this.bid, this.user);
  final BidIn bid;
  final UserModel user;
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

  Stream<List<BidAndUser>> sortBidInStream(
      WidgetRef ref, String uid, Future<List<BidIn>> bidInsFuture) async* {
    final bidIns = await bidInsFuture;
    var bidInsWithUser = bidIns.map((bid) {
      final user = ref.watch(bidUserProvider(bid.id))!;
      return BidAndUser(bid, user);
    }).toList();

    final myPrivateUserAsyncValue = ref.watch(userPrivateProvider(uid));

    // filter out blocked users
    if (!(myPrivateUserAsyncValue is AsyncError) &&
        !(myPrivateUserAsyncValue is AsyncLoading)) {
      final myPrivateUser = myPrivateUserAsyncValue.value!;
      bidInsWithUser = bidInsWithUser
          .where((bidAndUser) =>
              !myPrivateUser.blocked.contains(bidAndUser.user.id))
          .toList();
    }

    // sort
    bidInsWithUser.sort((BidAndUser b1, BidAndUser b2) {
      if (b1.user.status == 'ONLINE' && b2.user.status != 'ONLINE') return -1;
      if (b1.user.status != 'ONLINE' && b2.user.status == 'ONLINE') return 1;
      // both ONLINE xor OFFLINE
      if (b1.user.isInMeeting() && !b2.user.isInMeeting()) return 1;
      if (!b1.user.isInMeeting() && b2.user.isInMeeting()) return -1;
      // both in meeting xor neither
      if (!(myPrivateUserAsyncValue is AsyncError) &&
          !(myPrivateUserAsyncValue is AsyncLoading)) {
        final myPrivateUser = myPrivateUserAsyncValue.value!;
        if (myPrivateUser.friends.contains(b1.user.id) &&
            !myPrivateUser.friends.contains(b2.user.id)) return -1;
        if (!myPrivateUser.friends.contains(b1.user.id) &&
            myPrivateUser.friends.contains(b2.user.id)) return 1;
        // both friends xor not
      }
      if (b1.bid.speed.num < b2.bid.speed.num) return 1;
      if (b2.bid.speed.num < b1.bid.speed.num) return -1;
      return -1;
    });

    yield bidInsWithUser;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: sortBidInStream(
            ref, uid, FirestoreDatabase().bidInsStream(uid: uid).first),
        builder:
            (BuildContext context, AsyncSnapshot<List<BidAndUser>> snapshot) {
          log('UserBidInsList - build - uid=$uid - snapshot.hasData=${snapshot.hasData}');
          if (snapshot.hasData) {
            log('UserBidInsList - build - snapshot.data.length=${snapshot.data!.length}');
            if (snapshot.data!.length == 0) {
              return NoBidPage(noBidsText: noBidsText);
            }

            return ListView.builder(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (_, ix) {
                  BidAndUser bidAndUser = snapshot.data![ix];
                  BidIn bid = bidAndUser.bid;
                  UserModel userModel = bidAndUser.user;

                  var statusColor = AppTheme().green;
                  if (userModel.status == 'OFFLINE')
                    statusColor = AppTheme().gray;
                  if (userModel.locked) statusColor = AppTheme().red;

                  return InkResponse(
                    onTap: () => CustomDialogs.infoDialog(
                        context: context,
                        child: BidDialogWidget(
                          bidInModel: bid,
                          onTapTalk: () => onTap(bid),
                          userModel: userModel,
                        )),
                    child: Card(
                        child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextProfileView(
                            radius: 50,
                            text: "${userModel.name}",
                            statusColor: statusColor,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${userModel.name} - ${bid.speed.num} ALGO/sec',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    )),
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
