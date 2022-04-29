// order of bid ins: status (online->locked->offline), friends->non-friends, speed
// do not show bid ins of blocked users

import 'package:app_2i2i/infrastructure/data_access_layer/repository/secure_storage_service.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_user_provider/my_user_page_view_model.dart';
import '../app/no_bid_page.dart';
import '../home/wait_page.dart';
import 'widgets/bid_in_tile.dart';

class UserBidInsList extends ConsumerStatefulWidget {
  UserBidInsList({
    required this.titleWidget,
    required this.onTap,
    required this.myHangoutPageViewModel,
    required this.showOnTalk,
    required this.showOnBidIn,
  });

  final Widget titleWidget;
  final MyUserPageViewModel myHangoutPageViewModel;
  final GlobalObjectKey showOnTalk;
  final GlobalObjectKey showOnBidIn;

  final void Function(BidIn bidIn) onTap;

  @override
  ConsumerState<UserBidInsList> createState() => _UserBidInsListState();
}

class _UserBidInsListState extends ConsumerState<UserBidInsList> {
  @override
  Widget build(BuildContext context) {
    final bidInsWithUsers = ref
        .watch(bidInsWithUsersProvider(widget.myHangoutPageViewModel.user.id));
    if (bidInsWithUsers == null) return WaitPage();

    // store for notification
    markAsRead(bidInsWithUsers);
    List<BidIn> bidIns = bidInsWithUsers.toList();
    return Scaffold(
      floatingActionButton: Visibility(
        visible: bidInsWithUsers.isNotEmpty,
        child: Showcase(
          key: widget.showOnTalk,
          description: 'Host can 1-on-1 meeting with the Guest.',
          title: Keys.talk.tr(context),
          radius: BorderRadius.circular(18),
          child: InkResponse(
            onTap: () async {
              bool camera = true;
              bool microphone = true;
              if (!kIsWeb) {
                camera = await Permission.camera.request().isGranted;
                microphone = await Permission.microphone.request().isGranted;
              }

              if (camera && microphone) {
                for (BidIn bidIn in bidIns) {
                  UserModel? user = bidIn.user;
                  if (user == null) {
                    return;
                  }
                  String? token;
                  bool isIos = false;
                  try {
                    final database = ref.watch(databaseProvider);
                    Map map =
                        await database.getTokenFromId(bidIn.user!.id) ?? {};
                    token = map['token'];
                    isIos = map['isIos'] ?? false;
                  } catch (e) {
                    print(e);
                  }

                  final acceptedBid = await widget.myHangoutPageViewModel
                      .acceptBid(bidIn, token: token, isIos: isIos);
                  if (acceptedBid) break;
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
                  BoxShadow(
                      offset: Offset(2, 2),
                      blurRadius: 8,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary // changes position of shadow
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
      ),
      body: bidInsWithUsers.isNotEmpty
          ? ListView.builder(
              itemCount: bidInsWithUsers.length,
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              itemBuilder: (_, index) {
                Widget bidInTile = BidInTile(
                  bidInList: bidInsWithUsers,
                  index: index,
                );
                if (index == 0)
                  return Showcase(
                    title: 'Bid In',
                    description: 'Share your time with your Guest and you will be rewarded with coins.',
                    key: widget.showOnBidIn,
                    radius: BorderRadius.circular(12),
                    child: BidInTile(
                      bidInList: bidInsWithUsers,
                      index: index,
                    ),
                  );
                return bidInTile;
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
