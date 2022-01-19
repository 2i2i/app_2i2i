
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
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
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => CustomNavigation.push(context, RatingPage(userModel: userModel), Routes.RATING),
                          child: Column(
                            children: [
                              Text(
                                '$totalRating',
                                maxLines: 2,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: Theme.of(context).disabledColor),
                              ),
                              SizedBox(height: 4),
                              IgnorePointer(
                                ignoring: true,
                                child: RatingBar.builder(
                                  initialRating: userModel.rating * 5,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 20,
                                  tapOnlyMode: true,
                                  updateOnDrag: false,
                                  allowHalfRating: true,
                                  glowColor: Colors.white,
                                  unratedColor: Colors.grey.shade300,
                                  itemBuilder: (context, _) => Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => CustomNavigation.push(
                              context,
                              FriendsListPage(
                                isForBlockedUser: false,
                              ),
                              Routes.FRIENDS),
                          child: Text(Strings().friendList),
                        ),
                      ),
                    ],
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
                    onTap: myUserPageViewModel.acceptBid,
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
