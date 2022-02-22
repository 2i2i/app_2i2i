import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/infrastructure/providers/combine_queues.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/qr_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom_alert_widget.dart';
import '../home/wait_page.dart';
import '../my_user/chat_widget.dart';
import 'other_bid_list.dart';
import 'widgets/user_info_widget.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  UserInfoPage({required this.B});

  final String B;

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  var showBio = false;

  @override
  Widget build(BuildContext context) {
    // final userPageBViewModel = ref.watch(userPageViewModelProvider(widget.B));
    final userPageBDataViewModel = ref.watch(userProvider(widget.B));
    if (haveToWait(userPageBDataViewModel) || userPageBDataViewModel == null) {
      return WaitPage();
    }

    final userPageBViewModel = userPageBDataViewModel.value;

    final A = ref.watch(myUIDProvider);
    bool amBlocked =
        A == null || userPageBViewModel!.blocked.contains(A);

    UserModel? userA;
    if (A is String) {
      final userAAsyncValue = ref.watch(userProvider(A));
      if (!haveToWait(userAAsyncValue)) userA = userAAsyncValue.value;
    }
    final userModelChanger = ref.watch(userChangerProvider);
    bool isFriend = false;
    if (userA is UserModel && userA.friends.contains(widget.B))
      isFriend = true;

    final UserModel userB = userPageBViewModel!;

    final bidInsAsyncValue = ref.watch(bidInsPublicProvider(widget.B));
    if (haveToWait(bidInsAsyncValue)) return WaitPage();

    final bidIns = bidInsAsyncValue.value!;
    final bidInsSorted = combineQueues(
        bidIns, userB.loungeHistory, userB.loungeHistoryIndex);

    // show est. wait time?
    int? estWaitTime;
    if (A is String) {
      final bidOutsAsyncValue = ref.watch(bidOutsProvider(A));
      if (!haveToWait(bidOutsAsyncValue)) {
        final bidOuts = bidOutsAsyncValue.value!;
        int totalDuration = 0;
        for (int i = 0; i < bidInsSorted.length; i++) {
          final bidIn = bidInsSorted[i];

          if (bidOuts.any((bidOut) => bidOut.id == bidIn.id)) {
            estWaitTime = totalDuration;
            break;
          }

          int duration = bidIn.speed.num == 0
              ? userB.rule.maxMeetingDuration
              : (bidIn.energy / bidIn.speed.num).round();
          totalDuration += duration;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
      ),
      floatingActionButton: Visibility(
        visible: !amBlocked,
        child: InkResponse(
          onTap: () => context.pushNamed(
            Routes.createBid.nameFromPath(),
            extra: CreateBidPageRouterObject(
              B: widget.B,
              bidIns: bidInsSorted,
            ),
          ),
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
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.call_merge,
                  size: 30,
                  color: Theme.of(context).cardColor,
                ),
                SizedBox(height: 2),
                Text(
                  Keys.join.tr(context),
                  style: Theme.of(context).textTheme.button?.copyWith(
                        color: Theme.of(context).cardColor,
                      ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 20, left: 20, bottom: 14, top: 4),
              child: UserInfoWidget(
                user: userB,
                isFav: isFriend,
                estWaitTime: estWaitTime,
                onTapQr: () {
                  showDialog(
                    context: context,
                    builder: (context) => FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        height: 400,
                        width: 350,
                        decoration: Custom.getBoxDecoration(context,color: Colors.white),
                        child: QrCodeWidget(
                            message:
                                'https://test.2i2i.app/user/${userB.id}'),
                      ),
                    ),
                  );
                },
                onTapChat: () => CustomAlertWidget.showBidAlert(
                    context, ChatWidget(user: userB),
                    backgroundColor: Colors.transparent),
                onTapFav: () {
                  if (userModelChanger != null) {
                    if (!isFriend) {
                      userModelChanger.addFriend(widget.B);
                    } else {
                      userModelChanger.removeFriend(widget.B);
                    }
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: OtherBidInList(
              user: userB,
              bidIns: bidInsSorted,
            ),
          ),
        ],
      ),
    );
  }
}
