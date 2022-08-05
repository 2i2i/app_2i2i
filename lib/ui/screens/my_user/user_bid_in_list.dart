// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_user_provider/my_user_page_view_model.dart';
import '../../commons/qr_image.dart';
import '../app/no_bid_page.dart';
import '../app/wait_page.dart';
import 'widgets/bid_in_tile.dart';

class UserBidInsList extends ConsumerStatefulWidget {
  UserBidInsList({
    required this.titleWidget,
    required this.onTap,
    required this.myHangoutPageViewModel,
  });

  final Widget titleWidget;
  final MyUserPageViewModel myHangoutPageViewModel;

  final void Function(BidIn bidIn) onTap;

  @override
  ConsumerState<UserBidInsList> createState() => _UserBidInsListState();
}

class _UserBidInsListState extends ConsumerState<UserBidInsList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bidInsWithUsers = ref.watch(bidInsWithUsersProvider(widget.myHangoutPageViewModel.user.id));
    if (bidInsWithUsers == null) return WaitPage();
    final logoHeight = 60.0;
    final logoWidth = logoHeight * 1.4;
    // store for notification
    markAsRead(bidInsWithUsers);
    List<BidIn> bidIns = bidInsWithUsers.toList();
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Visibility(
        visible: bidInsWithUsers.isNotEmpty,
        child: InkResponse(
          onTap: () async {
            bool camera = true;
            bool microphone = true;

            if (!kIsWeb) {
              camera = await Permission.camera.request().isGranted;
              microphone = await Permission.microphone.request().isGranted;
            }

            if (camera && microphone && bidIns.isNotEmpty) {
              if (_scaffoldKey.currentContext != null) {
                CustomDialogs.loader(true, _scaffoldKey.currentContext!);
              }
              bool hostStatus = await widget.myHangoutPageViewModel.acceptBid(bidIns);
              if (!hostStatus) {
                CustomDialogs.showToastMessage(context, 'Looks like user offline or not available right now');
              }
              if (_scaffoldKey.currentContext != null) {
                CustomDialogs.loader(false, _scaffoldKey.currentContext!);
              }
            }
          },
          child: Container(
            width: kToolbarHeight * 1.15,
            height: kToolbarHeight * 1.15,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(offset: Offset(2, 2), blurRadius: 8, color: Theme.of(context).colorScheme.secondary // changes position of shadow
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow,
                  size: 30,
                  color: Theme.of(context).cardColor,
                ),
                SizedBox(height: 2),
                Text(Keys.talk.tr(context),
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: Theme.of(context).cardColor,
                    ))
              ],
            ),
          ),
        ),
      ),
      body: bidInsWithUsers.isNotEmpty
          ? ListView.builder(
        itemCount: bidInsWithUsers.length,
        padding: const EdgeInsets.only(top: 10, bottom: 80),
        itemBuilder: (_, ix) {
          return BidInTile(
            bidInList: bidInsWithUsers,
            index: ix,
          );
        },
      )
          : NoBidPage(noBidsText: Keys.roomIsEmpty.tr(context)),
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
      SecureStorage().write(Keys.myReadBids, localBidIds);
    });
  }
}
