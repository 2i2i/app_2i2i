import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/providers/combine_queues.dart';
import 'package:app_2i2i/infrastructure/routes/app_routes.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/create_bid/create_bid_page.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/qr_card_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../home/wait_page.dart';
import 'other_bid_list.dart';
import 'widgets/user_info_widget.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  UserInfoPage({required this.uid});

  final String uid;

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  var showBio = false;

  @override
  Widget build(BuildContext context) {
    print('url-------------- \n ${Uri.base.toString()}');
    final mainUserID = ref.watch(myUIDProvider);
    final userPageViewModel = ref.watch(userPageViewModelProvider(widget.uid));
    bool isFriend = false;
    bool isBlocked = false;
    final userModelChanger = ref.watch(hangoutChangerProvider);
    if (mainUserID != null) {
      final userPrivateAsyncValue = ref.watch(userPrivateProvider(mainUserID));
      isFriend = !haveToWait(userPrivateAsyncValue) &&
          userPrivateAsyncValue.value != null &&
          userPrivateAsyncValue.value!.friends.contains(widget.uid);
      isBlocked = !haveToWait(userPrivateAsyncValue) &&
          userPrivateAsyncValue.value != null &&
          userPrivateAsyncValue.value!.blocked.contains(widget.uid);
    }

    if (haveToWait(userPageViewModel)) {
      return WaitPage();
    }

    Hangout hangout = userPageViewModel!.hangout;

    final bidInsAsyncValue = ref.watch(bidInsPublicProvider(widget.uid));
    if (haveToWait(bidInsAsyncValue)) return WaitPage();
    final bidIns = bidInsAsyncValue.value!;
    final bidInsSorted = combineQueues(
        bidIns, hangout.loungeHistory, hangout.loungeHistoryIndex);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        actions: [
          if (userModelChanger != null)
            PopupMenuButton<int>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              onSelected: (item) =>
                  handleClick(item, userModelChanger, isBlocked),
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text(Strings().report)),
                PopupMenuItem<int>(
                  value: 1,
                  child: Text(
                    isBlocked ? Strings().unBlock : Strings().block,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              ],
            ),
          SizedBox(width: 6)
        ],
      ),
      floatingActionButton: Visibility(
          visible: !isBlocked,
          child: InkResponse(
            onTap: () => context.pushNamed(Routes.createBid.nameFromPath(),
                extra: CreateBidPageRouterObject(
                    hangout: hangout, bidIns: bidInsSorted)),
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
                    Icons.call_merge,
                    size: 30,
                    color: Theme.of(context).cardColor,
                  ),
                  SizedBox(height: 2),
                  Text(Strings().join,style: Theme.of(context).textTheme.button?.copyWith(
                      color: Theme.of(context).cardColor
                  ),)
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
                  right: 20, left: 20, bottom: 14, top: 16),
              child: UserInfoWidget(
                hangout: hangout,
                isFav: isFriend,
                onTapQr: (){
                  showDialog(
                    context: context,
                    builder: (context)=>FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        height: 400,
                        width: 350,
                        child: QrCodeWidget(message: 'https://test.2i2i.app/user/${hangout.id}'),
                      ),
                    ),
                  );
                },
                onTapFav: () {
                  if (userModelChanger != null) {
                    if (!isFriend) {
                      userModelChanger.addFriend(widget.uid);
                    } else {
                      userModelChanger.removeFriend(widget.uid);
                    }
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: OtherBidInList(
              hangout: hangout,
              bidIns: bidInsSorted,
            ),
          ),
        ],
      ),
    );
  }

  void handleClick(int item, HangoutChanger userModelChanger, bool isBlocked) {
    switch (item) {
      case 0:
        // userModelChanger.addFriend(widget.uid);
        break;
      case 1:
        if (isBlocked) {
          userModelChanger.removeBlocked(widget.uid);
        } else {
          userModelChanger.addBlocked(widget.uid);
        }
        break;
    }
  }

  String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
