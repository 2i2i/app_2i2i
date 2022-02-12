import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/qr_card_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../../infrastructure/routes/named_routes.dart';
import '../../commons/custom_alert_widget.dart';
import '../home/wait_page.dart';
import '../user_info/widgets/user_info_widget.dart';
import 'chat_widget.dart';
import 'hangout_bid_in_list.dart';

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
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myHangoutPageViewModel = ref.watch(myHangoutPageViewModelProvider);
    if (haveToWait(myHangoutPageViewModel) || myHangoutPageViewModel?.hangout == null) {
      return WaitPage();
    }

    Hangout hangout = myHangoutPageViewModel!.hangout;
    return Scaffold(
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
                              child: Container(
                                decoration: Custom.getBoxDecoration(context,color: Colors.white),
                            height: 400,
                            width: 350,
                            child: QrCodeWidget(
                                message:
                                    'https://test.2i2i.app/user/${hangout.id}'),
                          ),
                        ),
                      );
                    },
                    onTapWallet: () {
                      context.pushNamed(Routes.account.nameFromPath());
                    },
                    onTapChat: () => CustomAlertWidget.showBidAlert(
                        context, ChatWidget(hangout: hangout),
                        backgroundColor: Colors.transparent),
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
                myHangoutPageViewModel: myHangoutPageViewModel,
                titleWidget: Text(
                  Keys.bidsIn.tr(context),
                  style: Theme.of(context).textTheme.headline6,
                ),
                noBidsText: Keys.noBidFound.tr(context),
                onTap: (x) => {}, //myUserPageViewModel.acceptBid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
