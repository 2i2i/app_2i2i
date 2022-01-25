import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/hangout_setting/hangout_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/models/hangout_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../block_and_friends/friends_list_page.dart';
import '../home/wait_page.dart';
import '../user_info/widgets/user_info_widget.dart';
import 'hangout_bid_in_list.dart';
import 'hangout_bid_out_list.dart';
import 'meeting_history_list.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  UserInfoWidget(
                    hangout: hangout,
                    onTapFav: () {
                      CustomNavigation.push(
                        context,
                        FriendsListPage(
                          isForBlockedUser: false,
                        ),
                        Routes.FRIENDS,
                      );
                    },
                    onTapRules: (){
                      CustomNavigation.push(
                        context,
                        HangoutSetting(),
                        Routes.USER,
                        rootNavigator: true,
                      );
                    },
                    isFav: true,
                  ),
                  SizedBox(height: 14),
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(118, 118, 128, 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorPadding: EdgeInsets.all(3),
                      indicator: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      unselectedLabelColor:
                          Theme.of(context).tabBarTheme.unselectedLabelColor,
                      labelColor:
                          Theme.of(context).tabBarTheme.unselectedLabelColor,
                      tabs: [
                        Tab(
                          text: Strings().bidIn,
                        ),
                        Tab(
                          text: Strings().bidOut,
                        ),
                        Tab(
                          text: Strings().history,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBarView(
                controller: _tabController,
                children: [
                  UserBidInsList(
                    myHangoutPageViewModel: myHangoutPageViewModel,
                    titleWidget: Text(
                      Strings().bidIn,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    noBidsText: Strings().noBidFound,
                    onTap: (x) => {}, //myUserPageViewModel.acceptBid,
                  ),
                  UserBidOutsList(
                    uid: myHangoutPageViewModel.hangout!.id,
                    titleWidget: Text(
                      Strings().bidOut,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    noBidsText: Strings().noBidFound,
                    trailingIcon: Icon(
                      Icons.cancel,
                      color: Color.fromRGBO(104, 160, 242, 1),
                    ),
                    onTrailingIconClick: (BidOut bidOut) async {
                      CustomDialogs.loader(true, context);
                      await myHangoutPageViewModel.cancelBid(
                          bidId: bidOut.id, B: bidOut.B);
                      CustomDialogs.loader(false, context);
                    },
                  ),
                  MeetingHistoryList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
