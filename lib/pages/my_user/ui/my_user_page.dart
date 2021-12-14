import 'dart:math';

import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
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

class _MyUserPageState extends ConsumerState<MyUserPage> {
  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUIDProvider)!;
    final userPrivateAsyncValue = ref.watch(userPrivateProvider(uid));
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);

    return myUserPageViewModel == null
        ? WaitPage()
        : Scaffold(
            appBar: AppBar(
              title: Text(myUserPageViewModel.user.name),
            ),
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

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
            child: ElevatedButton.icon(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => SetupBio(
                      user: myUserPageViewModel.user,
                    ),
                    barrierDismissible: false,
                  );
                },
                icon: Icon(Icons.edit),
                label: Text('Edit Name and Bio'),
            ),
        ),
        Divider(),
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: UserBidsList(
                  bidsIds: myUserPageViewModel.user.bidsIn,
              titleWidget:
                  Text('Bids In', style: Theme.of(context).textTheme.headline6),
              noBidsText: 'no bids in for user',
              leading: Icon(
                Icons.label_important,
                color: Colors.green,
              ),
              trailingIcon: Icon(Icons.check_circle, color: Colors.green),
              onTrailingIconClick: (Bid bid) async {
                CustomDialogs.loader(true, context);
                AbstractAccount? account;
                if (0 < bid.speed.num) {
                  log('bid.speed.num=${bid.speed.num}');
                  account = await _acceptBid(context, myUserPageViewModel, bid);
                  if (account == null) {
                    CustomDialogs.loader(false, context);
                    return;
                  }
                }
                await myUserPageViewModel.acceptBid(bid, account);
                CustomDialogs.loader(false, context);
              },
            )),
            VerticalDivider(),
            Expanded(
                child: userPrivateAsyncValue.when(
                    data: (UserModelPrivate userPrivate) {
              return UserBidsList(
                bidsIds: userPrivate.bidsOut.map((b) => b.bid).toList(),
                titleWidget: Text('Bids Out',
                    style: Theme.of(context).textTheme.headline6),
                noBidsText: 'no bids out for user',
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
            })),
          ],
        ))
      ],
    );
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
                                  assetId: bid.speed.assetId,
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
