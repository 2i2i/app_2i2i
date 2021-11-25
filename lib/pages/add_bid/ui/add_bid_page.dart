import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddBidPage extends ConsumerStatefulWidget {
  const AddBidPage({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  _AddBidPageState createState() => _AddBidPageState(uid: uid);
}

class _AddBidPageState extends ConsumerState<AddBidPage> {
  _AddBidPageState({required this.uid});
  final String uid;
  AbstractAccount? account;
  Balance? balance;
  int speedNum = 0;
  double budgetPercentage = 100.0;

  AppBar appBar(String name) {
    return AppBar(
      title: Text('Add bid for $name'),
      leading: IconButton(
          onPressed: () => context.goNamed('user', params: {'uid': uid}),
          icon: Icon(
            Icons.navigate_before,
            size: 40,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('_AddBidPageState - build');

    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(uid)).state;
    log('_AddBidPageState - addBidPageViewModel=$addBidPageViewModel');
    if (addBidPageViewModel == null) return WaitPage();
    if (addBidPageViewModel.submitting) return WaitPage();

    return Scaffold(
      appBar: appBar(addBidPageViewModel.user.name),
      body: ListView(
        children: [
          Container(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      'How many coin/sec? (in base units, e.g. microAlgo)',
                  border: OutlineInputBorder(),
                  label: Text('Speed'),
                ),
                onChanged: (value) {
                  setState(() {
                    speedNum = int.parse(value);
                  });
                },
              )),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Account',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
              padding: const EdgeInsets.only(
                  top: 0, left: 20, right: 20, bottom: 100),
              child: DropdownButton<AbstractAccount>(
                onChanged: (AbstractAccount? newAccount) {
                  setState(() {
                    if (newAccount != null && account != newAccount) {
                      account = newAccount;
                      balance = account!.balances[0];
                    }
                  });
                },
                value: account,
                items: [
                  for (var i = 0; i < addBidPageViewModel.accounts.length; i++)
                    DropdownMenuItem<AbstractAccount>(
                      child: Text(addBidPageViewModel.accounts[i].address
                          .substring(0, 4)),
                      value: addBidPageViewModel.accounts[i],
                    )
                ],
              )),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Asset',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          balance == null
              ? Container()
              : Container(
                  padding: const EdgeInsets.only(
                      top: 0, left: 20, right: 20, bottom: 100),
                  child: DropdownButton<Balance>(
                    onChanged: (Balance? newBalance) {
                      setState(() {
                        balance = newBalance;
                      });
                    },
                    value: balance,
                    items: [
                      for (var i = 0; i < account!.balances.length; i++)
                        DropdownMenuItem<Balance>(
                          child: Text(account!.balances[i].assetHolding.assetId
                                  .toString() +
                              ' - ' +
                              account!.balances[i].assetHolding.amount
                                  .toString() +
                              ' - ' +
                              account!.balances[i].net.toString()),
                          value: account!.balances[i],
                        )
                    ],
                  )),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Budget',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            child: Slider(
                min: 0,
                max: 100,
                divisions: 100,
                value: budgetPercentage,
                onChanged: (x) {
                  setState(() {
                    budgetPercentage = x;
                  });
                }),
          ),
          Container(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Text(
              'Max duration: ' +
                  (account == null
                      ? '<choose account>'
                      : addBidPageViewModel.duration(
                          account!, speedNum, balance!, budgetPercentage)),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          account == null ? Container() : ElevatedButton(
            onPressed: addBidPageViewModel.submitting
                ? null
                : () async {
                    // log('await addBidPageViewModel.addBid() - assetIndex=$assetIndex - speedNum=$speedNum');
                    ProgressDialog.loader(true, context);
                    await addBidPageViewModel.addBid(
                        account: account!,
                        balance: balance!,
                        speedNum: speedNum,
                        budgetPercentage: budgetPercentage).then((value) {
                          print('$value');
                    });
                    ProgressDialog.loader(false, context);
                    context.goNamed('user', params: {'uid': uid});
                  },
            child: Text('Add', style: Theme.of(context).textTheme.headline6),
          ),
        ],
      ),
    );
  }
}
