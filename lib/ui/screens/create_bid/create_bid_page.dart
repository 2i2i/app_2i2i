import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/infrastructure/providers/combine_queues.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/create_bid/widgets/account_tile.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_text_field.dart';
import '../my_account/widgets/add_account_options_widget.dart';
import 'top_card_widget.dart';

ValueNotifier<bool> accountBottomSheet = ValueNotifier(false);

class CreateBidPageRouterObject {
  CreateBidPageRouterObject(
      {required this.bidIns,
      required this.B,
      this.sliderHeight,
      this.min,
      this.max,
      this.fullWidth});

  final String B;
  final List<BidInPublic> bidIns;
  final double? sliderHeight;
  final int? min;
  final int? max;
  final bool? fullWidth;
}

class CreateBidPage extends ConsumerStatefulWidget {
  late final String B;
  late final List<BidInPublic> bidIns;
  late final double sliderHeight;
  late final int min;
  late final int max;
  late final fullWidth;

  CreateBidPage(
      {this.sliderHeight = 48,
      this.max = 10,
      required this.B,
      required this.bidIns,
      this.min = 0,
      this.fullWidth = false});
  CreateBidPage.fromObject(CreateBidPageRouterObject obj) {
    B = obj.B;
    bidIns = obj.bidIns;
    sliderHeight = obj.sliderHeight ?? 48;
    min = obj.min ?? 0;
    max = obj.max ?? 10;
    fullWidth = obj.fullWidth ?? false;
  }

  @override
  _CreateBidPageState createState() => _CreateBidPageState();
}

class _CreateBidPageState extends ConsumerState<CreateBidPage>
    with SingleTickerProviderStateMixin {
  AbstractAccount? account;
  Quantity amount = Quantity(num: 0, assetId: 0);
  Quantity speed = Quantity(num: 0, assetId: 0);
  String? comment;
  int maxDuration = 300;
  int maxMaxDuration = 300;
  int minMaxDuration = 10;

  int _minAccountBalance = 0;
  int _accountBalance = 0;

  ValueNotifier<bool> isAddSupportVisible = ValueNotifier(false);
  TextEditingController speedController = TextEditingController();
  PageController controller = PageController(initialPage: 0);
  int _index = 0;
  UserModel? userB;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        var val = int.tryParse(speedController.text) ?? 0;
        if (val < speed.num) {
          speedController.text = speed.num.toString();
          var myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
          updateAccountBalance(myAccountPageViewModel);
        }
      }
    });
    ref.read(myAccountPageViewModelProvider).initMethod();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    final userPageBViewModel = ref.watch(userPageViewModelProvider(widget.B));

    if (haveToWait(myAccountPageViewModel) ||
        haveToWait(userPageBViewModel) ||
        userPageBViewModel == null) {
      return WaitPage(
        isCupertino: true,
        height: MediaQuery.of(context).size.height / 2,
      );
    }

    userB = userPageBViewModel.user;

    final addBidPageViewModel = ref
        .watch(addBidPageViewModelProvider(userPageBViewModel.user).state)
        .state;

    if (addBidPageViewModel == null || (addBidPageViewModel.submitting))
      return WaitPage(isCupertino: true);

    updateAccountBalance(myAccountPageViewModel);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TopCard(minWait: calcWaitTime(), B: userB!),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        Keys.estMaxDuration.tr(context),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            SizedBox(width: 6),
                            Text(
                              '$minMaxDuration ${Keys.secs.tr(context)}',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor:
                                        Theme.of(context).cardColor,
                                    inactiveTrackColor:
                                        Theme.of(context).disabledColor,
                                    thumbShape: CustomSliderThumbRect(
                                      mainContext: context,
                                      thumbRadius: 15,
                                      valueMain: "${maxDuration.toString()}s",
                                      min: minMaxDuration,
                                      max: maxMaxDuration,
                                    ),
                                  ),
                                  child: Slider(
                                    min: minMaxDuration.toDouble(),
                                    max: maxMaxDuration.toDouble(),
                                    divisions: maxMaxDuration == minMaxDuration
                                        ? null
                                        : min(100,
                                            maxMaxDuration - minMaxDuration),
                                    value: maxDuration.toDouble(),
                                    onChanged: (value) {
                                      maxDuration = value.round();
                                      updateAccountBalance(
                                          myAccountPageViewModel);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Text('$maxMaxDuration ${Keys.secs.tr(context)}',
                                style: Theme.of(context).textTheme.subtitle1),
                            SizedBox(width: 6),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CustomTextField(
                      title: Keys.note.tr(context),
                      hintText: Keys.bidNote.tr(context),
                      onChanged: (String value) {
                        comment = value;
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                            ((myAccountPageViewModel.accounts?.length ?? 0) +
                                1), (index) {
                          if (index ==
                              ((myAccountPageViewModel.accounts?.length ??
                                  0))) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 8),
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 4),
                                width:
                                    MediaQuery.of(context).size.height * 0.175,
                                height:
                                    MediaQuery.of(context).size.height * 0.145,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(2, 4),
                                        blurRadius: 8,
                                        color: Color.fromRGBO(0, 0, 0,
                                            0.12) // changes position of shadow
                                        ),
                                  ],
                                ),
                            child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: Center(
                                            child: Icon(
                                      Icons.add,
                                      size: 25,
                                    ))),
                                    Text(
                                      Keys.addAccount.tr(context),
                                      style: Theme.of(context).textTheme.button,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: AccountTile(
                              false,
                              key: ObjectKey(myAccountPageViewModel
                                  .accounts![index].address),
                              account: myAccountPageViewModel.accounts![index],
                              afterRefresh: () =>
                                  updateAccountBalance(myAccountPageViewModel),
                            ),
                          );
                        }),
                      )),
                  /*Visibility(
                    visible:
                        (myAccountPageViewModel.accounts?.isNotEmpty ?? false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Keys.swipeAndChangeAccount.tr(context),
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              primary: Theme.of(context).colorScheme.secondary),
                          onPressed: () => CustomAlertWidget.showBidAlert(
                            context,
                            AddAccountOptionsWidgets(),
                          ),
                          child: Text(
                            Keys.addAccount.tr(context),
                          ),
                        )
                      ],
                    ),
                  ),*/
                  ValueListenableBuilder(
                    valueListenable: isAddSupportVisible,
                    builder: (BuildContext context, bool value, Widget? child) {
                      if (value) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 8, left: 10, right: 10),
                          child: CustomTextField(
                            focusNode:focusNode,
                            autovalidateMode: AutovalidateMode.always,
                            controller: speedController,
                            title: Keys.speed.tr(context),
                            hintText: "0",
                            suffixIcon: GestureDetector(
                              onTap: () {
                                isAddSupportVisible.value = false;
                                updateAccountBalance(myAccountPageViewModel);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      '${Keys.algoSec.tr(context)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ValueListenableBuilder(
                                    valueListenable: isAddSupportVisible,
                                    builder: (BuildContext context, bool value,
                                        Widget? child) {
                                      if (value) {
                                        return child!;
                                      }
                                      return Container();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.remove_circle,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (String value) {
                              final num = int.tryParse(value) ?? 0;
                              print('num $num = ${(num >= (userB?.rule.minSpeed ?? 0))}');
                              if (num >= (userB?.rule.minSpeed ?? 0)) {
                                speed = Quantity(num: num, assetId: speed.assetId);
                              }
                              updateAccountBalance(myAccountPageViewModel);
                            },
                            validator: (value) {
                              int num = int.tryParse(value ?? '') ?? 0;
                              if (num < userB!.rule.minSpeed) {
                                return '${Keys.minSupportIs.tr(context)} ${userB!.rule.minSpeed}';
                              }
                              return null;
                            },
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isInsufficient() ? null : () => onAddBid(),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(isInsufficient()
                      ? Theme.of(context).errorColor
                      : Theme.of(context).colorScheme.secondary),
                ),
                child: Text(getConfirmSliderText(),style: TextStyle(
                  color: isInsufficient()?Theme.of(context).primaryColorDark:Theme.of(context).primaryColor
                )),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: isAddSupportVisible,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: !value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        isAddSupportVisible.value = !isAddSupportVisible.value;
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 15,
                          ),
                          SizedBox(width: 3),
                          Text(Keys.waitLess.tr(context)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void updateAccountBalance(MyAccountPageViewModel myAccountPageViewModel) {
    var val = int.tryParse(speedController.text)??0;
    bool isLessVal = speed.num < (userB?.rule.minSpeed??0) || val < (userB?.rule.minSpeed??0);
    if(isLessVal){
      speed = Quantity(num: userB?.rule.minSpeed ?? 0, assetId: 0);
    }else{
      speed = Quantity(num: val, assetId: 0);
    }
    if(!focusNode.hasFocus) {
      speedController.text = speed.num.toString();
    }
    if (account == null && (myAccountPageViewModel.accounts?.length ?? 0) > 0) {
      account = myAccountPageViewModel.accounts!.first;
    }

    if (account != null) {
      _minAccountBalance = account!.minBalance();
      _accountBalance = account!.balanceALGO();
    }

    final availableBalance = _accountBalance - _minAccountBalance;
    maxMaxDuration = userB?.rule.maxMeetingDuration ?? 0;
    if (val != 0) {
      final availableMaxDuration = max(0, ((availableBalance - 4 * AlgorandService.MIN_TXN_FEE) / speed.num).floor());
      maxMaxDuration = min(availableMaxDuration, maxMaxDuration);
      maxMaxDuration = max(minMaxDuration, maxMaxDuration);
    }
    maxDuration = min(maxDuration, maxMaxDuration);
    amount = Quantity(num: (maxDuration * speed.num).round(), assetId: 0);
    var amountStr = '${(amount.num / 1000000).toString()} A';
    print('ammount $amountStr');
    setState(() {});
  }

  String calcWaitTime() {
    if (amount.assetId != speed.assetId)
      throw Exception('amount.assetId != speed.assetId');

    final now = DateTime.now().toUtc();
    final tmpBidIn = BidInPublic(
        active: false,
        id: now.microsecondsSinceEpoch.toString(),
        speed: speed,
        net: AppConfig().ALGORAND_NET,
        ts: now,
        energy: amount.num,
        rule: userB!.rule);

    final sortedBidIns = combineQueues([...widget.bidIns, tmpBidIn],
        userB?.loungeHistory ?? [], userB?.loungeHistoryIndex ?? 0);

    int waitTime = 0;
    for (final bidIn in sortedBidIns) {
      if (bidIn.id == tmpBidIn.id) break;
      int bidDuration = userB?.rule.maxMeetingDuration ?? 0;
      if (bidIn.speed.num != 0)
        bidDuration =
            min((bidIn.energy / bidIn.speed.num).round(), bidDuration);
      waitTime += bidDuration;
    }

    final waitTimeString = secondsToSensibleTimePeriod(waitTime);
    return waitTimeString;
  }

  Future onAddBid() async {
    if (isInsufficient() && userB == null) {
      return;
    }
    final addBidPageViewModel =
        ref.read(addBidPageViewModelProvider(userB!).state).state;
    if (addBidPageViewModel is AddBidPageViewModel) {
      if (!addBidPageViewModel.submitting) {
        await addBid(addBidPageViewModel: addBidPageViewModel);
        Navigator.of(context).maybePop();
      }
    }
  }

  double getWidthForSlider(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 200;
    if (width <= 250) {
      return 250;
    }
    return width;
  }

  String getConfirmSliderText() {
    var amountStr = '${(amount.num / 1000000).toString()} A';
    if (isInsufficient()) {
      var val = int.tryParse(speedController.text)??0;
      bool isLessVal = speed.num < (userB?.rule.minSpeed??0) || val < (userB?.rule.minSpeed??0);
      if(isLessVal){
        return Keys.addBid.tr(context) + ' : ' + amountStr;
      }else {
        return Keys.insufficientBalance.tr(context) + ' : ' + amountStr;
      }
    }
    return Keys.addBid.tr(context) + ' : ' + amountStr;
  }

  bool isInsufficient() {
    var val = int.tryParse(speedController.text)??0;
    bool isLessVal = speed.num < (userB?.rule.minSpeed??0) || val < (userB?.rule.minSpeed??0);
    print('isLessVal $isLessVal');
    if(isLessVal) return true;
    if (speed.num == 0) return false;
    if (account == null) return true;
    final minCoinsNeeded = speed.num * 10;
    if (amount.num < minCoinsNeeded) return true; // at least 10 seconds
    final minAccountBalanceNeeded =
        _minAccountBalance + amount.num + 4 * AlgorandService.MIN_TXN_FEE;
    if (_accountBalance < minAccountBalanceNeeded) return true;

    return false;
  }

  Future addBid({required AddBidPageViewModel addBidPageViewModel}) async {
    if (account is WalletConnectAccount) {
      CustomDialogs.loader(true, context,
          title: Keys.weAreWaiting.tr(context),
          message: Keys.confirmInWallet.tr(context));
    } else {
      CustomDialogs.loader(true, context);
    }
    await addBidPageViewModel.addBid(
      account: account,
      amount: amount,
      speed: speed,
      bidComment: comment,
    );
    CustomDialogs.loader(false, context);
  }
}