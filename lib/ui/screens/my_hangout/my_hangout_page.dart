import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_alert_widget.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/qr_card_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../home/wait_page.dart';
import '../user_info/widgets/user_info_widget.dart';
import 'meeting_history_list.dart';
import 'hangout_bid_in_list.dart';
import 'hangout_bid_out_list.dart';

class MyHangoutPage extends ConsumerStatefulWidget {
  const MyHangoutPage({Key? key}) : super(key: key);

  @override
  _MyHangoutPageState createState() => _MyHangoutPageState();
}

class _MyHangoutPageState extends ConsumerState<MyHangoutPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myHangoutPageViewModel = ref.watch(myHangoutPageViewModelProvider);
    if (haveToWait(myHangoutPageViewModel) || myHangoutPageViewModel?.hangout == null) {
      return WaitPage();
    }

    Hangout hangout = myHangoutPageViewModel!.hangout!;
    return Scaffold(
      floatingActionButton: InkResponse(
        onTap: () {
          final bidInsWithUsers = ref.watch(bidInsProvider(myHangoutPageViewModel.hangout!.id));
          if (bidInsWithUsers == null || bidInsWithUsers.isEmpty) return;
          myHangoutPageViewModel.acceptBid(bidInsWithUsers.first);
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
              Text(Strings().talk,style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Theme.of(context).cardColor,
              ))
            ],
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
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12)),
            ),
            child: Padding(
              padding: EdgeInsets.only(right: 20,left: 20, bottom: 8,top: kIsWeb?8:31),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  UserInfoWidget(
                    hangout: hangout,
                    onTapRules: (){
                      context.pushNamed(Routes.hangoutSetting.nameFromPath());
                    },
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
                    isFav: true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              child: UserBidInsList(
                uid: myHangoutPageViewModel.hangout!.id,
                titleWidget: Text(
                  'Bids In',
                  style: Theme.of(context).textTheme.headline6,
                ),
                noBidsText: Strings().noBidFound,
                onTap: (x) => {}, //myUserPageViewModel.acceptBid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
