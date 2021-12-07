import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/custom_dialogs.dart';
import 'package:app_2i2i/common/text_utils.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/pages/add_bid/provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/pages/home/wait_page.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
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

  @override
  Widget build(BuildContext context) {
    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(uid)).state;
    // final fireBaseMessaging = ref.watch(fireBaseMessagingProvider);
    if (addBidPageViewModel == null) return WaitPage();
    if (addBidPageViewModel.submitting) return WaitPage();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme().lightGray,
        leading: IconButton(
            iconSize: 35,
            onPressed: () => context.goNamed('home'),
            icon: Icon(Icons.navigate_before, color: AppTheme().black)),
        centerTitle: true,
        title: TitleText(title: 'Add bid for ${addBidPageViewModel.user.name}'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        speedNum == 0
                            ? AppTheme().buttonBackground
                            : Theme.of(context).disabledColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ))),
                onPressed: speedNum == 0 && !addBidPageViewModel.submitting
                    ? () async {
                        await connectCall(
                            addBidPageViewModel: addBidPageViewModel);
                      }
                    : null,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: ButtonText(
                      title: "Free Call", textColor: AppTheme().black),
                  trailing: Icon(Icons.call, color: AppTheme().black),
                ),
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              flex: 5,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        speedNum != 0
                            ? AppTheme().green
                            : AppTheme().green.withOpacity(0.5)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ))),
                onPressed: speedNum != 0 && !addBidPageViewModel.submitting
                    ? () async {
                        final budget = (balance!.assetHolding.amount *
                            budgetPercentage /
                            100);
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
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: ButtonText(
                      title: "Bid Call", textColor: AppTheme().white),
                  trailing: Icon(Icons.monetization_on_outlined,
                      color: AppTheme().white),
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
                hintText: 'How many coin/sec? (in base units, e.g. microAlgo)',
                border: OutlineInputBorder(),
                label: BodyOneText(
                    title: 'Speed', textColor: AppTheme().hintColor),
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
                child: CaptionText(
                    title: 'Note: For Bid Call speed should greater than 0',
                    textColor: AppTheme().hintColor),
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
    return Visibility(
      visible: speedNum != 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          TitleText(
            title: "Accounts: ",
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
                  hint: BodyTwoText(title: "Select Account"),
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
                    for (var i = 0;
                        i < addBidPageViewModel.accounts.length;
                        i++)
                      DropdownMenuItem<AbstractAccount>(
                        child: BodyOneText(
                            title: addBidPageViewModel.accounts[i].address
                                .substring(0, 4),
                            textColor: AppTheme().brightBlue),
                        value: addBidPageViewModel.accounts[i],
                      )
                  ],
                ),
              )),
          Divider(),
        ],
      ),
    );
  }

  Widget assetWidget(AddBidPageViewModel addBidPageViewModel) {
    return balance != null && speedNum != 0
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              TitleText(title: "Assets: "),
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
                    hint: BodyTwoText(title: "Select Asset"),
                    onChanged: (Balance? newBalance) {
                      setState(() {
                        balance = newBalance;
                      });
                    },
                    value: balance,
                    items: [
                      for (var i = 0; i < account!.balances.length; i++)
                        DropdownMenuItem<Balance>(
                          child: BodyOneText(
                              title: account!.balances[i].assetHolding.assetId
                                      .toString() +
                                  ' - ' +
                                  account!.balances[i].assetHolding.amount
                                      .toString() +
                                  ' - ' +
                                  account!.balances[i].net.toString(),
                              textColor: AppTheme().brightBlue),
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
          SizedBox(height: 12),
          TitleText(title: 'Budget: '),
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                BodyOneText(title: "0"),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        thumbColor: AppTheme().green,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 10)),
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
                ),
                BodyOneText(title: "100"),
              ],
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              TitleText(title: 'Max duration: '),
              TitleText(
                textColor: AppTheme().brightBlue,
                title: (account == null
                    ? 'select account'
                    : addBidPageViewModel.duration(
                        account!, speedNum, balance!, budgetPercentage)),
              ),
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
            budgetPercentage: budgetPercentage)
        .then((value) {
      print('$value');
    });
    CustomDialogs.loader(false, context);
    context.goNamed('user', params: {'uid': uid});
  }
}
