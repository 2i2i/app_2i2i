import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/infrastructure/providers/combine_queues.dart';
import 'package:app_2i2i/ui/commons/custom.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:app_2i2i/ui/screens/user_info/widgets/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_text_field.dart';
import '../my_account/widgets/account_info.dart';
import '../my_account/widgets/add_account_options_widget.dart';

class CreateBidPageRouterObject {
  CreateBidPageRouterObject(
      {required this.bidIns,
      required this.B,
      this.sliderHeight,
      this.min,
      this.max,
      this.fullWidth});
  final Hangout B;
  final List<BidInPublic> bidIns;
  final double? sliderHeight;
  final int? min;
  final int? max;
  final bool? fullWidth;
}

class CreateBidPage extends ConsumerStatefulWidget {
  late final Hangout B;
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

class _CreateBidPageState extends ConsumerState<CreateBidPage> with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    ref.read(myAccountPageViewModelProvider).initMethod();
    speed = Quantity(num: widget.B.rule.minSpeed, assetId: 0);
    speedController.text = speed.num.toString();
    updateAccountBalance();
    super.initState();
  }

  void updateAccountBalance() {
    if (account != null) {
      _minAccountBalance = account!.minBalance();
      _accountBalance = account!.balanceALGO();
    }
    update();
  }

  void update() {
    final availableBalance = _accountBalance - _minAccountBalance;
    maxMaxDuration = widget.B.rule.maxMeetingDuration;
    if (speed.num != 0) {
      final availableMaxDuration = max(
          0,
          ((availableBalance - 4 * AlgorandService.MIN_TXN_FEE) / speed.num)
              .floor());
      maxMaxDuration = min(availableMaxDuration, maxMaxDuration);
      maxMaxDuration = max(minMaxDuration, maxMaxDuration);
      maxDuration = min(maxDuration, maxMaxDuration);
    }
    amount = Quantity(num: (maxDuration * speed.num).round(), assetId: 0);
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
        net: AlgorandNet.testnet,
        ts: now,
        energy: amount.num,
        rule: widget.B.rule);

    final sortedBidIns = combineQueues([...widget.bidIns, tmpBidIn],
        widget.B.loungeHistory, widget.B.loungeHistoryIndex);

    int waitTime = 0;
    for (final bidIn in sortedBidIns) {
      if (bidIn.id == tmpBidIn.id) break;
      int bidDuration = widget.B.rule.maxMeetingDuration;
      if (bidIn.speed.num != 0)
        bidDuration =
            min((bidIn.energy / bidIn.speed.num).round(), bidDuration);
      waitTime += bidDuration;
    }

    final waitTimeString = secondsToSensibleTimePeriod(waitTime);
    return waitTimeString;
  }

  final controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    if (haveToWait(myAccountPageViewModel)) {
      return WaitPage(
        isCupertino: true,
        height: MediaQuery.of(context).size.height / 2,
      );
    }
    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(widget.B).state).state;
    if (addBidPageViewModel == null) return WaitPage(isCupertino: true);
    if (addBidPageViewModel.submitting) return WaitPage(isCupertino: true);
    if (account == null && (myAccountPageViewModel.accounts?.length ?? 0) > 0) {
      account = myAccountPageViewModel.accounts!.first;
      updateAccountBalance();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TopCard(minWait: calcWaitTime(), B: widget.B),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Strings().estMaxDuration,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.20),
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 6),
                              Text(
                                '$minMaxDuration secs',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor:
                                      Theme.of(context).cardColor,
                                      inactiveTrackColor:
                                      Theme.of(context).disabledColor,
                                      thumbShape: CustomSliderThumbRect(
                                        mainContext: context,
                                        thumbRadius: 15,
                                        min: minMaxDuration,
                                        max: maxMaxDuration,
                                      ),
                                    ),
                                    child: Slider(
                                      min: minMaxDuration.toDouble(),
                                      max: maxMaxDuration.toDouble(),
                                      divisions:
                                      maxMaxDuration == minMaxDuration
                                          ? null
                                          : min(
                                          100,
                                          maxMaxDuration -
                                              minMaxDuration),
                                      value: maxDuration.toDouble(),
                                      onChanged: (value) {
                                        maxDuration = value.round();
                                        update();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Text('$maxMaxDuration secs',
                                  style:
                                  Theme.of(context).textTheme.subtitle1),
                              SizedBox(width: 6),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: CustomTextField(
                      title: Strings().note,
                      hintText: Strings().bidNote,
                      onChanged: (String value) {
                        comment = value;
                      },
                    ),
                  ),

                  Container(
                    constraints:
                        (myAccountPageViewModel.accounts?.length ?? 0) > 0
                            ? BoxConstraints(
                                minHeight: 150,
                                maxHeight: 200,
                              )
                            : null,
                    child: (myAccountPageViewModel.accounts?.length ?? 0) > 0
                        ? PageView.builder(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                myAccountPageViewModel.accounts?.length ?? 0,
                            itemBuilder: (_, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AccountInfo(
                                  false,
                                  key: ObjectKey(myAccountPageViewModel
                                      .accounts![index].address),
                                  account:
                                      myAccountPageViewModel.accounts![index],
                                  afterRefresh: updateAccountBalance,
                                ),
                              );
                            },
                            onPageChanged: (int val) {
                              final newAccount = myAccountPageViewModel
                                  .accounts
                                  ?.elementAt(val);
                              if (account == newAccount) return;
                              account = newAccount;
                              if (mounted) {
                                updateAccountBalance();
                              }
                            },
                          )
                        : Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .shadowColor
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 12),
                                Text(
                                  'No account added',
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                  child: IconButton(
                                    onPressed: () =>
                                        CustomAlertWidget.showBidAlert(
                                            context,
                                            AddAccountOptionsWidgets()),
                                    iconSize: 30,
                                    icon: Icon(
                                      Icons.add_circle_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ) /*ElevatedButton(
                                      child: Text(Strings().addAccount),
                                    )*/
                                  ,
                                )
                              ],
                            ),
                          ),
                  ),

                  Visibility(
                    visible: (myAccountPageViewModel.accounts?.isNotEmpty ?? false),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            Strings().swipeAndChangeAccount,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              primary:
                                  Theme.of(context).colorScheme.secondary),
                          onPressed: () => CustomAlertWidget.showBidAlert(
                            context,
                            AddAccountOptionsWidgets(),
                          ),
                          child: Text(
                            Strings().addAccount,
                          ),
                        )
                      ],
                    ),
                  ),

                  ValueListenableBuilder(
                    valueListenable: isAddSupportVisible,
                    builder: (BuildContext context, bool value, Widget? child) {
                      if(value) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8,left: 10,right: 10),
                          child: CustomTextField(
                            autovalidateMode: AutovalidateMode.always,
                            controller: speedController,
                            title: Strings().speed,
                            hintText: "0",
                            suffixIcon: GestureDetector(
                              onTap: (){
                                isAddSupportVisible.value = false;
                                resetSpeed();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      '${Strings().algoSec}',
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .subtitle2
                                          ?.copyWith(
                                        color: Theme.of(context).iconTheme.color,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ValueListenableBuilder(
                                    valueListenable: isAddSupportVisible,
                                    builder: (BuildContext context, bool value, Widget? child) {
                                      if(value){
                                        return child!;
                                      }
                                      return Container();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.remove_circle,color: Theme.of(context).iconTheme.color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (String value) {
                              final num = int.tryParse(value) ?? 0;
                              if(num >= widget.B.rule.minSpeed) {
                                speed =
                                    Quantity(num: num, assetId: speed.assetId);
                                update();
                              }
                            },
                            validator: (value){
                              int num = int.tryParse(value??'')??0;
                              if(num < widget.B.rule.minSpeed){
                                return 'Min support is ${widget.B.rule.minSpeed}';
                              }
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: isInsufficient() ? null : () => onAddBid(),
                child: Text(getConfirmSliderText()),
              ),
            ),
            ValueListenableBuilder(
            valueListenable: isAddSupportVisible,
              builder: (BuildContext context, bool value, Widget? child) {
                return Visibility(
                  visible: !value,
                  child: Padding(
                    padding: const EdgeInsets.only(left:10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: (){
                        isAddSupportVisible.value = !isAddSupportVisible.value;
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add,size: 15,),
                          SizedBox(width: 3),
                          Text('Wait Less'),
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

  onAddBid() async {
    if (isInsufficient()) {
      return;
    }
    final addBidPageViewModel =
        ref.read(addBidPageViewModelProvider(widget.B).state).state;
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
      return Strings().insufficientBalance + ' : ' + amountStr;
    }
    return Strings().addBid + ' : ' + amountStr;
  }

  isInsufficient() {
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
    if(account is WalletConnectAccount) {
      CustomDialogs.loader(true, context, title: 'We are waiting!', message: 'Please confirm in your wallet');
    }else{
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

  void resetSpeed() {
    speed = Quantity(num: widget.B.rule.minSpeed, assetId: 0);
    speedController.text = speed.num.toString();
    updateAccountBalance();
  }
}

class TopCard extends StatelessWidget {
  final String minWait;
  final Hangout B;

  const TopCard({Key? key, required this.minWait, required this.B}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Custom.getBoxDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Strings().createABid,
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 17,
                color: Theme.of(context).errorColor,
              ),
              SizedBox(width: 2),
              Text(
                'Est. Wait Time is $minWait',
                style: Theme.of(context).textTheme.caption?.copyWith(
                  color: Theme.of(context).errorColor
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          UserRulesWidget(
            hangout: B,
            onTapRules: null,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CustomSliderThumbRect extends SliderComponentShape {
  final double? thumbRadius;
  final BuildContext mainContext;
  final int? min;
  final int? max;

  const CustomSliderThumbRect({
    required this.mainContext,
    this.thumbRadius,
    this.min,
    this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius!);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: kToolbarHeight, height: kToolbarHeight * 0.6),
      Radius.circular(thumbRadius!),
    );

    final paint = Paint()
      ..color = Theme.of(mainContext).cardColor
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
        style: Theme.of(mainContext).textTheme.subtitle1,
        text: '${getValue(value!)}s');

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));
    canvas.drawRRect(rRect, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min! + (max! - min!) * value).round().toString();
  }
}
