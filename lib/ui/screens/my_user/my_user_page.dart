
import 'package:app_2i2i/ui/commons/custom_app_bar.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/commons/custom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../infrastructure/data_access_layer/repository/algorand_service.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/bid_model.dart';
import '../../../infrastructure/models/user_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_user_provider/my_user_page_view_model.dart';
import '../../../infrastructure/routes/app_routes.dart';
import '../history/history_page.dart';
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
    final uid = ref.watch(myUIDProvider)!;
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(uid));
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);

    return myUserPageViewModel == null
        ? WaitPage()
        : Scaffold(
      appBar: CustomAppbar(),
            body: _buildContents(context, ref, myUserPageViewModel,
                userPrivateAsyncValue, myUserPageViewModel.user),
          );
  }

  Widget _buildContents(
      BuildContext context,
      WidgetRef ref,
      MyUserPageViewModel? myUserPageViewModel,
      AsyncValue<UserModelPrivate> userPrivateAsyncValue,
      UserModel user) {
    if (myUserPageViewModel == null) return Container();
    if (userPrivateAsyncValue is AsyncLoading) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
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
              ),
              Tooltip(
                message: "History",
                child: InkResponse(
                  onTap: () => CustomNavigation.push(
                      context, HistoryPage(uid: user.id), Routes.HISTORY),
                  child: Container(
                    height: 40,
                    width: 40,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(
                        25.0,
                      ),
                    ),
                    child: Icon(
                      Icons.history_edu_rounded,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.transparent),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UserBidInsList(
                  uid: user.id,
                  titleWidget: Text('Bids In',
                      style: Theme.of(context).textTheme.headline6),
                  noBidsText: Strings().noBidFound,
                  onTap: (BidIn bid) async {
                    AbstractAccount? account;
                    if (0 < bid.speed.num) {
                      log('bid.speed.num=${bid.speed.num}');
                      account = await _acceptBid(context, myUserPageViewModel, bid);
                      if (account == null) return;
                    }
                    CustomDialogs.loader(true, context);
                    await myUserPageViewModel.acceptBid(bid, account);
                    CustomDialogs.loader(false, context);
                  },
                ),
                userPrivateAsyncValue.when(
                    data: (UserModelPrivate userPrivate) {
                  return UserBidOutsList(
                    uid: user.id,
                    titleWidget: Text('Bids Out',
                        style: Theme.of(context).textTheme.headline6),
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
                  );
                }, loading: () {
                  log('MyUserPage - _buildContents - loading');
                  return const CircularProgressIndicator();
                }, error: (_, __) {
                  log('MyUserPage - _buildContents - error');
                  return const Center(child: Text('error'));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<AbstractAccount?> _acceptBid(BuildContext context,
      MyUserPageViewModel myUserPageViewModel, BidIn bidIn) async {
    final accounts = await myUserPageViewModel.accountService.getAllAccounts();
    log('_acceptBid - accounts.length${accounts.length}');
    final accountsBoolFutures = accounts
        .map((a) => a.isOptedInToASA(
            assetId: bidIn.speed.assetId, net: AlgorandNet.testnet))
        .toList();
    final accountsBool = await Future.wait(accountsBoolFutures);
    log('_acceptBid - accountsBool=$accountsBool');

    // if only option is good, return it
    final numOptedInAccounts = accountsBool.where((a) => a).length;
    if (numOptedInAccounts == 1) {
      int firstOptedInAccountIndex = accountsBool.indexWhere((e) => e);
      return accounts[firstOptedInAccountIndex];
    }

    return showDialog<AbstractAccount>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Where to receive coins?'),
            children: [
              for (var i = 0; i < accounts.length; i++)
                accountsBool[i]
                    ? ListTile(
                        title: Text(accounts[i].address.substring(0, 4)),
                        onTap: () => Navigator.pop(context, accounts[i]),
                      )
                    : ListTile(
                        title: Text(accounts[i].address.substring(0, 4)),
                        enabled: false,
                        trailing: IconButton(
                            onPressed: () async {
                              CustomDialogs.loader(true, context);
                              log('about to optInToASA');
                              await accounts[i].optInToASA(
                                  assetId: bidIn.speed.assetId,
                                  net: AlgorandNet.testnet);
                              log('done optInToASA');
                              CustomDialogs.loader(false, context);
                              return Navigator.pop(context, accounts[i]);
                            },
                            icon: Icon(Icons.add_circle_outline)),
                      ),
            ],
          );
        });
  }
}
