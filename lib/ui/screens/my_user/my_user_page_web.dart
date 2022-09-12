import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/screens/my_user/chat_widget_holder.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/qr_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_app_bar_holder.dart';
import '../app/wait_page.dart';
import '../home/bottom_nav_bar.dart';
import '../user_info/widgets/user_info_widget_holder.dart';
import 'user_bid_in_list.dart';

class MyUserPageWeb extends ConsumerStatefulWidget {
  const MyUserPageWeb({Key? key}) : super(key: key);

  @override
  _MyUserPageState createState() => _MyUserPageState();
}

class _MyUserPageState extends ConsumerState<MyUserPageWeb> with SingleTickerProviderStateMixin {
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
    final myHangoutPageViewModel = ref.watch(myUserPageViewModelProvider);
    if (haveToWait(myHangoutPageViewModel) || myHangoutPageViewModel?.user == null) {
      return WaitPage();
    }

    UserModel user = myHangoutPageViewModel!.user;
    final domain = AppConfig().ALGORAND_NET == AlgorandNet.mainnet ? '2i2i.app' : 'test.2i2i.app';

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Card(
             // color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UserInfoWidgetHolder(
                    user: user,
                    onTapRules: () {
                      context.pushNamed(Routes.userSetting.nameFromPath());
                      currentIndex.value = 1;
                    },
                    onTapQr: () {
                      showDialog(
                        context: context,
                        builder: (context) => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            decoration: Custom.getBoxDecoration(context, color: Colors.white),
                            height: 400,
                            width: 350,
                            child: QrCodeWidget(userUrl: 'https://$domain/user/${user.id}'),
                          ),
                        ),
                      );
                    },
                    onTapWallet: () {
                      context.pushNamed(Routes.account.nameFromPath());
                    },
                    onTapChat: () => CustomAlertWidget.showBottomSheet(context, child: ChatWidgetHolder(user: user), backgroundColor: Colors.transparent),
                    isFav: true,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                CustomAppbarHolder(
                  backgroundColor: Colors.transparent,
                ),
                Expanded(
                  child: UserBidInsList(
                    myHangoutPageViewModel: myHangoutPageViewModel,
                    titleWidget: Text(
                      Keys.bidsIn.tr(context),
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onTap: (x) => {}, //myUserPageViewModel.acceptBid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
