
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:app_2i2i/ui/commons/custom_profile_image_view.dart';
import 'package:app_2i2i/ui/screens/rating/rating_page.dart';
import 'package:app_2i2i/ui/screens/top/top_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../home/wait_page.dart';
import '../user_bid/user_bid_ins_list.dart';
import '../user_bid/user_bid_outs_list.dart';

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
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    if (myUserPageViewModel == null) return WaitPage();
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              toolbarHeight: kToolbarHeight + 50,
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/icons/appbar_icon.svg',
                  fit: BoxFit.fill,
                  width: 55,
                  height: 65,
                ),
              ),
              centerTitle: false,
              actions: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RectangleBox(
                      onTap: () => CustomNavigation.push(context, RatingPage(
                        userModel: myUserPageViewModel.user,
                      ),Routes.RATING),
                      // onTap: () => AlertWidget.showBidAlert(context, CreateBidWidget()),
                      radius: 46,
                      icon: SvgPicture.asset(
                        'assets/icons/star.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    RectangleBox(
                      onTap: () => CustomNavigation.push(context, TopPage(), Routes.TOPPAGE),
                      radius: 46,
                      icon: SvgPicture.asset(
                        'assets/icons/crown.svg',
                        width: 16,
                        height: 16,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ],
              collapsedHeight: kIsWeb?(kToolbarHeight + 50):null,
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                )
              ),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: Size(
                  MediaQuery.of(context).size.width,
                  154,
                ),
                child: Builder(
                  builder: (context) {
                    var statusColor = AppTheme().green;
                    var userModel = myUserPageViewModel.user;
                    if (userModel.status == 'OFFLINE') {
                      statusColor = AppTheme().gray;
                    }
                    if (userModel.isInMeeting()) {
                      statusColor = AppTheme().red;
                    }
                    String firstNameChar = userModel.name;
                    if(firstNameChar.length>0){
                      firstNameChar = firstNameChar.substring(0,1);
                    }
                    return Container(
                      margin: EdgeInsets.only(left: 16,right: 16,bottom: 10),
                      child: Column(
                        children: [
                          ListTile(
                            leading: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                height: 105,
                                width: 105,
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.white, width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              Colors.black.withOpacity(0.08),
                                              blurRadius: 20,
                                              spreadRadius: 0.5,
                                            )
                                          ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        firstNameChar,
                                        style:
                                        Theme.of(context).textTheme.headline6,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.white, width: 2,
                                            ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            title: Text(userModel.name,style: Theme.of(context).textTheme.headline5,),
                            subtitle: Text(userModel.bio),
                            dense: false,
                            isThreeLine: true,
                            minVerticalPadding: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                indicatorPadding: EdgeInsets.all(2),
                                indicator: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelColor: Theme.of(context).colorScheme.secondary,
                                tabs: [
                                  Tab(
                                    text: Strings().bidIn,
                                  ),
                                  Tab(
                                    text: Strings().bidOut,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child:TabBarView(
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
            ],
          ),
        ),
      ),
    );
  }
}
