// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/commons/keys.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../home/wait_page.dart';
import 'widgets/bid_in_tile.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bidInsWithUsers = ref.watch(bidInsWithHangoutsProvider(uid));
    if (bidInsWithUsers == null) return WaitPage();

    // store for notification
    markAsRead(bidInsWithUsers);

    return ListView.builder(
      primary: false,
      physics: NeverScrollableScrollPhysics(),
      itemCount: bidInsWithUsers.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (_, ix) {

        return BidInTile(
          bidInList: bidInsWithUsers,
          index: ix,
        );
      },
    );
  }

  void markAsRead(List<BidIn> bidInsWithUsers) {
    SecureStorage().read(Keys.myReadBids).then((String? value) {
      List<String> localBids = [];
      if (value?.isNotEmpty ?? false) {
        localBids = value!.split(',').toList();
      }
      localBids.addAll(bidInsWithUsers.map((e) => e.public.id).toList());
      String localBidIds = localBids.toSet().toList().join(',');
      log('localBidIds=$localBidIds');
      SecureStorage().write(Keys.myReadBids, localBidIds);
    });
  }
}
