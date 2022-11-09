import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/infrastructure/providers/combine_queues.dart';
import 'package:app_2i2i/ui/screens/app/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/providers/my_account_provider/my_account_page_view_model.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_text_field.dart';
import '../my_account/widgets/account_asset_info.dart';
import '../my_account/widgets/add_account_options_widget.dart';
import '../my_user/widgets/wallet_connect_dialog.dart';
import 'top_card_widget.dart';

class CreateBidPageRouterObject {
  CreateBidPageRouterObject({required this.bidIns, required this.B, this.sliderHeight, this.min, this.max, this.fullWidth});

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

  CreateBidPage({this.sliderHeight = 48, this.max = 10, required this.B, required this.bidIns, this.min = 0, this.fullWidth = false});

  CreateBidPage.fromObject(CreateBidPageRouterObject obj) {
    log(C + 'fromObject');
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

class _CreateBidPageState extends ConsumerState<CreateBidPage> with SingleTickerProviderStateMixin {
  // AbstractAccount? account;
  String? addressA;
  Quantity amount = Quantity(num: 0, assetId: 0);
  Quantity speed = Quantity(num: 0, assetId: 0);
  String? comment;
  int maxDuration = 300;
  int maxMaxDuration = 300;
  int minMaxDuration = 10;

  int assetId = 0;
  FXModel FXValue = FXModel.ALGO();

  int minAccountALGOBalance = 0;
  int accountASABalance = 0;
  int accountALGOBalance = 0;

  ValueNotifier<bool> isAddSupportVisible = ValueNotifier(false);
  TextEditingController speedController = TextEditingController();
  PageController controller = PageController(initialPage: 0);
  int currentAccountIndex = 0;
  UserModel? userB;
  FocusNode focusNode = FocusNode();
  final dataKey = new GlobalKey();

  // @override
  // String toString({DiagnosticLevel minLevel = DiagnosticLevel.hidden}) {
  //   final A = 'C';
  //   log(A + 'addressA=$addressA amount=$amount ');
  // }

  @override
  void initState() {
    log(C + 'initState, this=$this');
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        final speedAsInt = getSpeedFromText(speedController.text);
        log(C + '!focusNode.hasFocus speedAsInt=$speedAsInt speed.num=${speed.num}');
        if (speedAsInt < speed.num) {
          // ?
          speedController.text = (speed.num / pow(10, FXValue.decimals)).toString();
          log(C + '!focusNode.hasFocus speedController.text=${speedController.text}');
          var myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
          updateAccountBalance(myAccountPageViewModel);
        }
      }
    });
    var providerObj = ref.read(myAccountPageViewModelProvider);
    providerObj.initMethod().then((value) {
      updateAccountBalance(providerObj);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    final userPageBViewModel = ref.watch(userPageViewModelProvider(widget.B));

    if (haveToWait(myAccountPageViewModel) || haveToWait(userPageBViewModel) || userPageBViewModel == null || myAccountPageViewModel.isLoading) {
      return WaitPage(
        isCupertino: true,
        height: MediaQuery.of(context).size.height / 2,
      );
    }

    userB = userPageBViewModel.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
            future: calcWaitTime(context, myAccountPageViewModel),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return TopCard(minWait: snapshot.data, B: userB!);
              }
              return Container();
            },
          ),
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
                        decoration: BoxDecoration(color: Theme.of(context).shadowColor.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Theme.of(context).cardColor,
                                    inactiveTrackColor: Theme.of(context).disabledColor,
                                    thumbShape: CustomSliderThumbRect(
                                      mainContext: context,
                                      thumbRadius: 15,
                                      min: minMaxDuration,
                                      showValue: true,
                                      valueMain: '$maxDuration',
                                      max: maxMaxDuration,
                                    ),
                                  ),
                                  child: Slider(
                                    min: minMaxDuration.toDouble(),
                                    max: maxMaxDuration.toDouble(),
                                    divisions: maxMaxDuration == minMaxDuration ? null : min(100, maxMaxDuration - minMaxDuration),
                                    value: maxDuration.toDouble(),
                                    onChanged: (value) {
                                      maxDuration = value.round();
                                      updateAccountBalance(myAccountPageViewModel);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Text('$maxMaxDuration ${Keys.secs.tr(context)}', style: Theme.of(context).textTheme.subtitle1),
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
                    padding: const EdgeInsets.only(top: 15),
                    child: CustomTextField(
                      capitalization: TextCapitalization.sentences,
                      title: Keys.note.tr(context),
                      hintText: Keys.bidNote.tr(context),
                      onChanged: (String value) {
                        comment = value;
                      },
                    ),
                  ),
                  Container(
                    constraints:
                        myAccountPageViewModel.walletConnectAccounts.length > 0 ? BoxConstraints(minHeight: 150, maxHeight: MediaQuery.of(context).size.width / 1.8) : null,
                    child: Builder(
                      builder: (BuildContext context) {
                        if (myAccountPageViewModel.walletConnectAccounts.isNotEmpty) {
                          final addressBalanceCombos = myAccountPageViewModel.addressWithASABalance;
                          return PageView.builder(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            itemCount: addressBalanceCombos.length,
                            itemBuilder: (_, index) {
                              // AbstractAccount? abstractAccount = accountsList[index];
                              final address = addressBalanceCombos[index].item1;
                              final balance = addressBalanceCombos[index].item2;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AccountAssetInfo(
                                      false,
                                      key: ObjectKey(address),
                                      // account: abstractAccount,
                                      afterRefresh: () => updateAccountBalance(myAccountPageViewModel),
                                      index: index,
                                      address: address,
                                      initBalance: balance,
                                      // balances: myAccountPageViewModel.accountBalancesMap[address]!,
                                    ),
                                  ),
                                ],
                              );
                            },
                            onPageChanged: (int val) {
                              if (mounted) {
                                currentAccountIndex = val;
                                updateAccountBalance(myAccountPageViewModel, accountIndex: val);
                              }
                            },
                          );
                        }
                        return Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).shadowColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 12),
                              Text(
                                Keys.noAccountAdded.tr(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                child: IconButton(
                                  // onPressed: () => showBidAlert(myAccountPageViewModel),
                                  onPressed: () async {
                                    await addWalletAccount(context, myAccountPageViewModel);
                                  },
                                  iconSize: 30,
                                  icon: Icon(
                                    Icons.add_circle_rounded,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: (myAccountPageViewModel.walletConnectAccounts.isNotEmpty),
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
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
                          // onPressed: () => showBidAlert(myAccountPageViewModel),
                          onPressed: () async {
                            await addWalletAccount(context, myAccountPageViewModel);
                          },
                          child: Text(
                            Keys.addAccount.tr(context),
                          ),
                        )
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: isAddSupportVisible,
                    builder: (BuildContext context, bool value, Widget? child) {
                      if (value) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
                          child: CustomTextField(
                            key: dataKey,
                            focusNode: focusNode,
                            autovalidateMode: AutovalidateMode.always,
                            controller: speedController,
                            title: Keys.speed.tr(context),
                            hintText: "0.01",
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
                            ],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                                      // '${Keys.algoPerSec.tr(context)}',
                                      '${FXValue.getName}/sec',
                                      style: Theme.of(context).textTheme.subtitle2?.copyWith(
                                            color: AppTheme().black,
                                            fontWeight: FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ValueListenableBuilder(
                                    valueListenable: isAddSupportVisible,
                                    builder: (BuildContext context, bool value, Widget? child) {
                                      if (value) {
                                        return child!;
                                      }
                                      return Container();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.remove_circle, color: AppTheme().black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (String speedInput) {
                              final speedAsInt = getSpeedFromText(speedInput);
                              // print('userB ==> ${FXValue.decimals} ==> ${(userB!.rule.minSpeedALGO / FXValue.value).ceil()}');
                              if (speedAsInt >= (userB!.rule.minSpeedALGO / FXValue.value).ceil()) {
                                speed = Quantity(num: speedAsInt, assetId: speed.assetId);
                              }
                              updateAccountBalance(myAccountPageViewModel);
                            },
                            validator: (String? value) {
                              final speedAsInt = getSpeedFromText(value ?? '');
                              if (speedAsInt < userB!.rule.minSpeedALGO) {
                                return '${Keys.minSupportIs.tr(context)} ${userB!.rule.minSpeedALGO / FXValue.value / pow(10, FXValue.decimals)}';
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
                onPressed: goodToAddBid() ? () => onAddBid(myAccountPageViewModel) : null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(goodToAddBid() ? Theme.of(context).colorScheme.secondary : Theme.of(context).errorColor),
                ),
                child: Text(getConfirmSliderText(),
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(color: goodToAddBid() ? Theme.of(context).primaryColor : Theme.of(context).primaryColorDark)),
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
                        foregroundColor: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        isAddSupportVisible.value = !isAddSupportVisible.value;
                        FocusScope.of(context).requestFocus(focusNode);
                        focusNode.requestFocus();
                        setState(() {
                          WidgetsBinding.instance.addPostFrameCallback((_) => Scrollable.ensureVisible(dataKey.currentContext!));
                        });
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

  int getAddressComboIndexByAddress(List<Tuple2<String, Balance>> addressBalanceCombos, String address) {
    log(C + 'getAddressComboIndexByAddress, address=$address');
    // int index = addressBalanceCombos.indexOf(addressOfAccount!);
    for (int i = 0; i < addressBalanceCombos.length; i++) {
      if (addressBalanceCombos[i].item1 == address) return i;
    }
    throw "getAddressComboIndexByAddress - address=$address";
  }

  Future<void> addWalletAccount(BuildContext context, MyAccountPageViewModel myAccountPageViewModel) async {
    String? addressOfAccount = await CustomAlertWidget.showBottomSheet(context, child: WalletConnectDialog(), isDismissible: true);
    if (addressOfAccount?.isNotEmpty ?? false) {
      final addressBalanceCombos = await myAccountPageViewModel.addressBalanceCombos;
      int index = getAddressComboIndexByAddress(addressBalanceCombos, addressOfAccount!);
      if (controller.hasClients) {
        controller.jumpToPage(index > 0 ? index : 0);
        controller.animateToPage(index, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
      }
    }
  }

  void showBidAlert(MyAccountPageViewModel myAccountPageViewModel) {
    CustomAlertWidget.showBottomSheet(
      context,
      child: AddAccountOptionsWidgets(
        accountAddListener: (String? address) async {
          Navigator.of(context, rootNavigator: true).pop();
          if (address is String) {
            final addressBalanceCombos = await myAccountPageViewModel.addressBalanceCombos;
            // int index = x.indexOf(address);
            int index = getAddressComboIndexByAddress(addressBalanceCombos, address);
            if (controller.hasClients) {
              controller.jumpToPage(index > 0 ? index : 0);
              controller.animateToPage(index, curve: Curves.decelerate, duration: Duration(milliseconds: 300));
            }
          }
        },
      ),
    );
  }

  void updateAccountBalance(MyAccountPageViewModel myAccountPageViewModel, {int? accountIndex}) async {
    log(C + 'updateAccountBalance accountIndex=$accountIndex assetId=$assetId');

    accountIndex ??= currentAccountIndex;
    // final addressBalanceCombos = await myAccountPageViewModel.addressBalanceCombos;
    final addressBalanceCombos = myAccountPageViewModel.addressWithASABalance;
    if (addressBalanceCombos.isNotEmpty) {
      final combo = accountIndex < addressBalanceCombos.length ? addressBalanceCombos[accountIndex] : addressBalanceCombos.first;
      addressA = combo.item1;
      assetId = combo.item2.assetHolding.assetId;
      accountASABalance = combo.item2.assetHolding.amount;
      accountALGOBalance = addressBalanceCombos[0].item2.assetHolding.amount;
    }
    log(C + 'accountIndex=$accountIndex');
    log(C + 'addressBalanceCombos=$addressBalanceCombos');
    log(C + 'address=$addressA');
    log(C + 'assetId=$assetId');
    log(C + 'accountBalance=$accountASABalance');
    log(C + 'accountALGOBalance=$accountALGOBalance');

    final FXValueTmp = await myAccountPageViewModel.getFX(assetId);
    // log(FX + 'FXValueTmp=$FXValueTmp');
    if (FXValueTmp == null) return;
    FXValue = FXValueTmp;
    log(C + 'FXValue=$FXValue');

    if (addressA != null) minAccountALGOBalance = await myAccountPageViewModel.getMinBalance(address: addressA!);
    log(C + 'minAccountALGOBalance=$minAccountALGOBalance');

    // final speedVal = getSpeedFromText(speedController.text);
    // log(FX + 'speedVal=$speedVal');
    
    log(C + 'speed.num=${speed.num} FXValue.value=${FXValue.value} userB?.rule.minSpeed=${userB?.rule.minSpeedALGO}');
    if (speedTooLow()) {
      speed = Quantity(num: (userB?.rule.minSpeedALGO ?? 0 / FXValue.value).ceil(), assetId: assetId);
    }
    // else {
    //   speed = Quantity(num: speedVal, assetId: assetId);
    // }
    // log(FX + 'speed=$speed speed.assetId=${speed.assetId} speed.num=${speed.num}');

    if (!focusNode.hasFocus) {
      speedController.text = (speed.num / pow(10, FXValue.decimals)).toString();
    }

    final feeALGO = (assetId == 0 ? 4 : 5) * AlgorandService.MIN_TXN_FEE; // 3 fess to unlock plus 1 xor 2 to send

    final availableALGOBalance = accountALGOBalance - minAccountALGOBalance - feeALGO;
    final availableASABalance = assetId == 0 ? availableALGOBalance : accountASABalance;
    log(C + 'availableALGOBalance=$availableALGOBalance');
    log(C + 'availableASABalance=$availableASABalance');

    maxMaxDuration = userB!.rule.maxMeetingDuration;
    log(C + 'maxMaxDuration=$maxMaxDuration');

    if (speed.num != 0) {
      final availableMaxDuration = max(0, (availableASABalance / speed.num).floor());
      log(C + 'availableMaxDuration=$availableMaxDuration');
      maxMaxDuration = min(availableMaxDuration, maxMaxDuration);
      log(C + 'maxMaxDuration=$maxMaxDuration');
      maxMaxDuration = max(minMaxDuration, maxMaxDuration);
      log(C + 'maxMaxDuration=$maxMaxDuration');
    }
    maxDuration = min(maxDuration, maxMaxDuration);
    log(C + 'maxDuration=$maxDuration');

    amount = Quantity(num: (maxDuration * speed.num).round(), assetId: assetId);
    log(C + 'amount=$amount amount.assetId=${amount.assetId} amount.num=${amount.num}');

    if (this.mounted) setState(() {});
  }

  int getSpeedFromText(String value) => ((num.tryParse(value) ?? 0) * pow(10, FXValue.decimals)).round();

  Future<String> calcWaitTime(BuildContext context, MyAccountPageViewModel myAccountPageViewModel) async {
    if (amount.assetId != speed.assetId) throw Exception('amount.assetId != speed.assetId');

    final now = DateTime.now().toUtc();
    final tmpBidIn = BidInPublic(
      active: false,
      id: now.microsecondsSinceEpoch.toString(),
      speed: speed,
      net: AppConfig().ALGORAND_NET,
      ts: now,
      energy: amount.num,
      rule: userB!.rule,
      FX: FXValue.value,
    );

    final sortedBidIns = combineQueues([...widget.bidIns, tmpBidIn], userB!.loungeHistory, userB!.loungeHistoryIndex);

    int waitTime = 0;
    for (final bidIn in sortedBidIns) {
      if (bidIn.id == tmpBidIn.id) break;
      int bidDuration = userB!.rule.maxMeetingDuration;
      if (bidIn.speed.num != 0) bidDuration = min((bidIn.energy / bidIn.speed.num).round(), bidDuration);
      waitTime += bidDuration;
    }

    final waitTimeString = secondsToSensibleTimePeriod(waitTime, context);
    return waitTimeString;
  }

  Future onAddBid(MyAccountPageViewModel myAccountPageViewModel) async {
    if (addressA?.isNotEmpty ?? false) {
      minAccountALGOBalance = await myAccountPageViewModel.getMinBalance(address: addressA!);
    }
    if (!goodToAddBid()) return;

    final addBidPageViewModel = ref.read(addBidPageViewModelProvider(widget.B));
    if (addBidPageViewModel is AddBidPageViewModel) {
      if (!addBidPageViewModel.submitting) {
        await addBid(addBidPageViewModel: addBidPageViewModel);
        // Navigator.of(context).maybePop();
      }
    }
  }

  String getConfirmSliderText() {
    log(C + 'getConfirmSliderText amount.num=${amount.num} FXValue.decimals=${FXValue.decimals} FXValue.getName=${FXValue.getName}');
    final amountStr = '${(amount.num / pow(10, FXValue.decimals)).toString()} ${FXValue.getName}';
    log(C + 'getConfirmSliderText amountStr=${amountStr}');

    if (goodToAddBid()) return Keys.addBid.tr(context) + ' : ' + amountStr;

    return Keys.insufficientBalance.tr(context) + ' : ' + amountStr;

    // log(C + 'getConfirmSliderText goodToAddBid()');
    // if (speedTooLow()) {
    //   log(C + 'getConfirmSliderText speedTooLow()');
    //   return Keys.addBid.tr(context) + ' : ' + amountStr;
    // } else {
    //   return Keys.insufficientBalance.tr(context) + ' : ' + amountStr;
    // }
  }

  // TODO userB?.rule.minSpeed ?? 0 is not good ~ if userB==null, need to catch that differently, not assume 0
  bool speedTooLow() => speed.num * FXValue.value < (userB?.rule.minSpeedALGO ?? 0) * (1.0 - CHRONY_GAP);

  bool goodToAddBid() {

    log(C + 'goodToAddBid 0');

    if (userB == null) return false;

    log(C + 'goodToAddBid 1');

    if (speedTooLow()) return false;

    log(C + 'goodToAddBid 2');

    if (speed.num == 0) return true;

    log(C + 'goodToAddBid 3');

    if (addressA == null) return false;

    log(C + 'goodToAddBid 4');

    if (accountASABalance * FXValue.value < amount.num) return false;

    log(C + 'goodToAddBid 5');

    final oneIfASA = speed.assetId == 0 ? 0 : 1;
    final minAccountALGOBalanceNeeded = minAccountALGOBalance + (4 + oneIfASA) * AlgorandService.MIN_TXN_FEE; // 3 fess to unlock plus 1 xor 2 for txns
    if (accountALGOBalance < minAccountALGOBalanceNeeded) return false;

    log(C + 'goodToAddBid 6');

    return true;
  }

  Future addBid({required AddBidPageViewModel addBidPageViewModel}) async {
    String? sessionId;

    var myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
    if (addressA is String) {
      sessionId = myAccountPageViewModel.getSessionId(addressA!);
    }
    await addBidPageViewModel.addBid(
      sessionId: sessionId,
      address: addressA,
      amount: amount,
      speed: speed,
      bidComment: comment,
      context: context,
    );
    // CustomAlertWidget.loader(false, context);
  }
}
