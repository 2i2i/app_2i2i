import 'dart:math';

import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/custom_app_bar.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/common/custom_profile_image_view.dart';
import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/constants/strings.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/pages/home/widgets/username_bio_dialog.dart';
import 'package:app_2i2i/pages/my_user/provider/my_user_page_view_model.dart';
import 'package:app_2i2i/pages/user_bid/ui/user_bids_list.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            appBar: CustomAppbar(
              title: Strings().myProfile,
              hideLeading: true,
            ),
            body: _buildContents(context, ref, myUserPageViewModel,
                userPrivateAsyncValue, myUserPageViewModel.user),
          );
  }

  Widget _buildContents(BuildContext context, WidgetRef ref, MyUserPageViewModel? myUserPageViewModel, AsyncValue<UserModelPrivate> userPrivateAsyncValue, UserModel user) {
    if (myUserPageViewModel == null) return Container();
    if (userPrivateAsyncValue is AsyncLoading) return Container();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: ListTile(
              leading: CustomImageProfileView(
                text: myUserPageViewModel.user.name,
                radius: MediaQuery.of(context).size.height * 0.07,
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit_rounded),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SetupBio(
                      model: myUserPageViewModel.user,
                    ),
                    barrierDismissible: false,
                  );
                },
              ),
              title: Text(myUserPageViewModel.user.name),
              subtitle: Text(myUserPageViewModel.user.bio),
            ),
          ),
          Divider(),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      color: AppTheme().lightGreen,
                    ),
                    labelColor: AppTheme().black,
                    unselectedLabelColor: Colors.black,
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
                Divider(color: Colors.transparent,),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      UserBidsList(
                        bidsIds: myUserPageViewModel.user.bidsIn,
                        titleWidget: HeadLineSixText(
                            title: 'Bids In', textColor: AppTheme().deepPurple),
                        noBidsText: Strings().noBidFound,
                        leading: Icon(
                          Icons.label_important,
                          color: Colors.green,
                        ),
                        trailingIcon:
                            Icon(Icons.check_circle, color: Colors.green),
                        onTrailingIconClick: (Bid bid) async {
                          AbstractAccount? account;
                          if (0 < bid.speed.num) {
                            log('bid.speed.num=${bid.speed.num}');
                            account = await _acceptBid(
                                context, myUserPageViewModel, bid);
                            if (account == null) return;
                          }
                          CustomDialogs.loader(true, context);
                          await myUserPageViewModel.acceptBid(bid, account);
                          CustomDialogs.loader(false, context);
                        },
                      ),
                      userPrivateAsyncValue.when(
                          data: (UserModelPrivate userPrivate) {
                        return UserBidsList(
                          bidsIds:
                              userPrivate.bidsOut.map((b) => b.bid).toList(),
                          titleWidget: HeadLineSixText(
                              title: 'Bids Out',
                              textColor: AppTheme().deepPurple),
                          noBidsText: Strings().noBidFound,
                          // onTap: myUserPageViewModel.cancelBid
                          leading: Transform.rotate(
                              angle: pi,
                              child: Icon(
                                Icons.label_important,
                                color: Color.fromRGBO(104, 160, 242, 1),
                              )),
                          trailingIcon: Icon(
                            Icons.cancel,
                            color: Color.fromRGBO(104, 160, 242, 1),
                          ),
                          onTrailingIconClick: (Bid bid) async {
                            CustomDialogs.loader(true, context);
                            await myUserPageViewModel.cancelBid(bid);
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
          ))
        ],
      ),
    );
  }

  Future<Map<String, String>?> _editNameAndBio(
      BuildContext context, String currentName, String currentBio) async {
    final TextEditingController name = TextEditingController(text: currentName);
    final TextEditingController bio = TextEditingController(text: currentBio);
    return showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Edit Name and Bio'),
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, right: 20, bottom: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'my cool username',
                      border: OutlineInputBorder(),
                      label: Text('Name'),
                    ),
                    minLines: 1,
                    maxLines: 1,
                    controller: name,
                  )),
              Container(
                  padding: const EdgeInsets.only(
                      top: 5, left: 20, right: 20, bottom: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'name i love to #talk and #cook. can also give #math #lessons',
                      border: OutlineInputBorder(),
                      label: Text('Bio'),
                    ),
                    minLines: 4,
                    maxLines: null,
                    controller: bio,
                  )),
              Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 50, right: 50, bottom: 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(173, 154, 178, 1)),
                      child: Text('Cancel'),
                      onPressed: () => Navigator.pop(context, null))),
              Container(
                  padding: const EdgeInsets.only(
                      top: 10, left: 50, right: 50, bottom: 10),
                  child: ElevatedButton(
                      // style: ElevatedButton.styleFrom(primary: Color.fromRGBO(237, 124, 135, 1)),
                      child: Text('Save'),
                      onPressed: () => Navigator.pop(
                          context, {'name': name.text, 'bio': bio.text}))),
            ],
          );
        });
  }

  Future<AbstractAccount?> _acceptBid(BuildContext context,
      MyUserPageViewModel myUserPageViewModel, Bid bid) async {
    final accounts = await myUserPageViewModel.accountService.getAllAccounts();
    log('_acceptBid - accounts.length${accounts.length}');
    final accountsBoolFutures = accounts
        .map((a) => a.isOptedInToASA(
            assetId: bid.speed.assetId, net: AlgorandNet.testnet))
        .toList();
    final accountsBool = await Future.wait(accountsBoolFutures);
    log('_acceptBid - accountsBool=$accountsBool');

    // if only option is good, return it
    final numOptedInAccounts = accountsBool.where((a) => a).length;
    if (numOptedInAccounts == 1) {
      int firstOptedInAccountIndex = accountsBool.indexWhere((e) => e);
      return accounts[firstOptedInAccountIndex];
    }

    AbstractAccount? chosenAccount;

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
                        onTap: () => Navigator.pop(context, chosenAccount),
                      )
                    : ListTile(
                        title: Text(accounts[i].address.substring(0, 4)),
                        enabled: false,
                        trailing: IconButton(
                            onPressed: () async {
                              CustomDialogs.loader(true, context);
                              log('about to optInToASA');
                              await accounts[i].optInToASA(
                                  assetId: bid.speed.assetId,
                                  net: AlgorandNet.testnet);
                              log('done optInToASA');
                              CustomDialogs.loader(false, context);
                              chosenAccount = accounts[i];
                              return Navigator.pop(context, chosenAccount);
                            },
                            icon: Icon(Icons.copy)),
                      ),
            ],
          );
        });
  }
}
