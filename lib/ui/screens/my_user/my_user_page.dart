import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/setup_account/setup_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../block_and_friends/friends_list_page.dart';
import '../home/wait_page.dart';
import '../user_info/widgets/user_info_widget.dart';
import 'meeting_history_list.dart';
import 'user_bid_ins_list.dart';
import 'user_bid_outs_list.dart';

class MyUserPage extends ConsumerStatefulWidget {
  const MyUserPage({Key? key}) : super(key: key);

  @override
  _MyUserPageState createState() => _MyUserPageState();
}

class _MyUserPageState extends ConsumerState<MyUserPage>
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
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    if (myUserPageViewModel == null) return WaitPage();

    UserModel userModel = myUserPageViewModel.user;
    final totalRating = (userModel.rating * 5).toStringAsFixed(1);

    return Scaffold(
      floatingActionButton: InkResponse(
        onTap: () {
          final bidInsWithUsers =
              ref.watch(bidInsProvider(myUserPageViewModel.user.id));
          if (bidInsWithUsers == null || bidInsWithUsers.isEmpty) return;
          myUserPageViewModel.acceptBid(bidInsWithUsers.first);
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
          child: Icon(
            Icons.add_rounded,
            size: 30,
            color: Theme.of(context).cardColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  UserInfoWidget(
                    userModel: userModel,
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
                        SetupBio(),
                        Routes.USER,
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
                    uid: myUserPageViewModel.user.id,
                    titleWidget: Text(
                      'Bids In',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    noBidsText: Strings().noBidFound,
                    onTap: (x) => {}, //myUserPageViewModel.acceptBid,
                  ),
                  UserBidOutsList(
                    uid: myUserPageViewModel.user.id,
                    titleWidget: Text(
                      'Bids Out',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    noBidsText: Strings().noBidFound,
                    trailingIcon: Icon(
                      Icons.cancel,
                      color: Color.fromRGBO(104, 160, 242, 1),
                    ),
                    onTrailingIconClick: (BidOut bidOut) async {
                      CustomDialogs.loader(true, context);
                      await myUserPageViewModel.cancelBid(
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
