import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/common/custom_navigation.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/add_bid/provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

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

  @override
  Widget build(BuildContext context) {
    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(uid)).state;
    // final fireBaseMessaging = ref.watch(fireBaseMessagingProvider);
    if (addBidPageViewModel == null) return WaitPage();
    if (addBidPageViewModel.submitting) return WaitPage();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add bid for ${addBidPageViewModel.B.name}'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: speedNum == 0 && !addBidPageViewModel.submitting
                    ? () async {
                        await connectCall(
                            addBidPageViewModel: addBidPageViewModel);
                      }
                    : null,
                child: Row(
                  children: [
                    Expanded(
                        child: Text("Free Call")),
                    Icon(Icons.call),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        speedNum != 0
                            ? AppTheme().green
                            : AppTheme().green.withOpacity(0.5))),
                onPressed: speedNum != 0 && !addBidPageViewModel.submitting
                    ? () async {
                        final budget = balance!.assetHolding.amount;
                        final seconds = budget / speedNum;
                        if (seconds > 9) {
                          await connectCall(
                              addBidPageViewModel: addBidPageViewModel);
                        } else {
                          showToast('Set minimum 10 second duration',
                              context: context,
                              animation: StyledToastAnimation.slideFromTop,
                              reverseAnimation: StyledToastAnimation.slideToTop,
                              position: StyledToastPosition.top,
                              startOffset: Offset(0.0, -3.0),
                              reverseEndOffset: Offset(0.0, -3.0),
                              duration: Duration(seconds: 4),
                              animDuration: Duration(seconds: 1),
                              curve: Curves.elasticOut,
                              reverseCurve: Curves.fastOutSlowIn);
                        }
                      }
                    : null,
                child: Row(
                  children: [
                    Expanded(
                        child: Text("Bid Call")),
                    Icon(Icons.monetization_on_outlined,
                        color: AppTheme().white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
        child: ListView(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).primaryColorLight,
                hintText: 'How many coin/sec? (in base units, e.g. microAlgo)',
                border: OutlineInputBorder(),
                label:
                    Text('Speed', style: Theme.of(context).textTheme.bodyText1),
              ),
              onChanged: (value) {
                setState(() {
                  speedNum = value.isEmpty ? 0 : int.parse(value);
                });
              },
            ),
            Visibility(
              visible: speedNum == 0,
              child: Container(
                padding: EdgeInsets.only(top: 8),
                child: Text('Note: For Bid Call speed should greater than 0',
                    style: Theme.of(context).textTheme.caption),
              ),
            ),
            accountWidget(addBidPageViewModel),
            assetWidget(addBidPageViewModel),
            budgetWidget(addBidPageViewModel),
          ],
        ),
      ),
    );
  }

  Widget accountWidget(AddBidPageViewModel addBidPageViewModel) {
    if (addBidPageViewModel.accounts.isNotEmpty &&
        balance == null &&
        account == null) {
      account = addBidPageViewModel.accounts.first;
      balance = account!.balances.first;
    }
    return Visibility(
      visible: speedNum != 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Text(
            "Accounts: ",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 6),
          Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<AbstractAccount>(
                  isExpanded: true,
                  focusColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  underline: Container(),
                  hint: Text(
                    "Select Account",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onChanged: (AbstractAccount? newAccount) {
                    setState(() {
                      if (newAccount != null && account != newAccount) {
                        account = newAccount;
                        balance = account!.balances[0];
                      }
                    });
                  },
                  value: account,
                  items: List.generate(addBidPageViewModel.accounts.length,
                      (index) {
                    return DropdownMenuItem<AbstractAccount>(
                      child: Text(
                          addBidPageViewModel.accounts[index].address
                              .substring(0, 4),
                          style: Theme.of(context).textTheme.bodyText1),
                      value: addBidPageViewModel.accounts[index],
                    );
                  }),
                ),
              )),
          Divider(),
        ],
      ),
    );
  }

  Widget assetWidget(AddBidPageViewModel addBidPageViewModel) {
    log('assetWidget');
    return balance != null && speedNum != 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Text("Assets: ", style: Theme.of(context).textTheme.subtitle1),
              SizedBox(height: 6),
              Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButton<Balance>(
                    isExpanded: true,
                    focusColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    underline: Container(),
                    hint: Text("Select Asset",
                        style: Theme.of(context).textTheme.bodyText2),
                    onChanged: (Balance? newBalance) {
                      setState(() {
                        balance = newBalance;
                      });
                    },
                    value: balance,
                    items: [
                      for (var i = 0; i < account!.balances.length; i++)
                        DropdownMenuItem<Balance>(
                          child: Text(
                              (account!.balances[i].assetHolding.assetId == 0
                                      ? 'ALGO'
                                      : account!
                                          .balances[i].assetHolding.assetId
                                          .toString()) +
                                  ' - ' +
                                  account!.balances[i].assetHolding.amount
                                      .toString() +
                                  ' - ' +
                                  account!.balances[i].net.toString(),
                              style: Theme.of(context).textTheme.bodyText1),
                          value: account!.balances[i],
                        )
                    ],
                  ),
                ),
              ),
              Divider(),
            ],
          )
        : Container();
  }

  Widget budgetWidget(AddBidPageViewModel addBidPageViewModel) {
    return Visibility(
      visible: speedNum != 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Max duration: ',
                  style: Theme.of(context).textTheme.subtitle1),
              Text(
                  account == null
                      ? 'select account'
                      : addBidPageViewModel.duration(
                          account!, speedNum, balance!),
                  style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
          Divider()
        ],
      ),
    );
  }

  Future connectCall({AddBidPageViewModel? addBidPageViewModel}) async {
    CustomDialogs.loader(true, context);
    await addBidPageViewModel!
        .addBid(
            account: account,
            balance: balance,
            speedNum: speedNum,
            )
        .then((value) {
      log('$value');
    });
    CustomDialogs.loader(false, context);
    CustomNavigation.pop(context);
  }
}
