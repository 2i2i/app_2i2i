import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/screens/my_user/chat_widget_holder.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/qr_card_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../../commons/custom_alert_widget.dart';
import '../app/wait_page.dart';
import '../home/bottom_nav_bar.dart';
import '../user_info/widgets/user_info_widget_holder.dart';
import 'user_bid_in_list.dart';

class MyUserPage extends ConsumerStatefulWidget {
  const MyUserPage({Key? key}) : super(key: key);

  @override
  _MyUserPageState createState() => _MyUserPageState();
}

class _MyUserPageState extends ConsumerState<MyUserPage> with SingleTickerProviderStateMixin {
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

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 0.5,
                  offset: Offset(0.0, 1.0),
                )
              ],
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).cardColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                begin: FractionalOffset.bottomCenter,
                end: FractionalOffset.topCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            padding: EdgeInsets.only(right: 20, left: 20, bottom: 8, top: kIsWeb ? 8 : 31),
            child: Column(
              children: [
                SizedBox(height: 8),
                UserInfoWidgetHolder(
                  user: user,
                  onTapRules: () {
                    context.pushNamed(Routes.userSetting.nameFromPath());
                    currentIndex.value = 1;
                  },
                  onTapQr: () {
                    if (user.url?.isNotEmpty ?? false) {
                      CustomAlertWidget.showBottomSheet(
                        context,
                        child: QrCodeWidget(
                          userUrl: user.url!,
                        ),
                      );
                    }
                  },
                  onTapWallet: () {
                    context.pushNamed(Routes.account.nameFromPath());
                  },
                  onTapChat: () =>
                      CustomAlertWidget.showBottomSheet(context, child: ChatWidgetHolder(user: user), backgroundColor: Colors.transparent, isDismissible: true),
                  isFav: true,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: UserBidInsList(
                myHangoutPageViewModel: myHangoutPageViewModel,
                titleWidget: Text(
                  Keys.bidsIn.tr(context),
                  style: Theme.of(context).textTheme.headline6,
                ),
                onTap: (x) => {}, //myUserPageViewModel.acceptBid,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
