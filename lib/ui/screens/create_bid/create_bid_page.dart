import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_text_field.dart';
import '../my_account/widgets/account_info.dart';
import '../my_account/widgets/add_account_options_widget.dart';

class CreateBidPage extends ConsumerStatefulWidget {
  final Hangout hangout;
  final double sliderHeight;
  final int min;
  final int max;
  final fullWidth;

  CreateBidPage(
      {this.sliderHeight = 48,
      this.max = 10,
      required this.hangout,
      this.min = 0,
      this.fullWidth = false});

  @override
  _CreateBidPageState createState() => _CreateBidPageState();
}

class _CreateBidPageState extends ConsumerState<CreateBidPage>
    with SingleTickerProviderStateMixin {
  AbstractAccount? account;
  Quantity amount = Quantity(num: 0, assetId: 0);
  Quantity speed = Quantity(num: 0, assetId: 0);
  String? note;

  double _value = 0;

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
        ref.watch(addBidPageViewModelProvider(widget.hangout.id).state).state;
    if (addBidPageViewModel == null) return WaitPage(isCupertino: true);
    if (addBidPageViewModel.submitting) return WaitPage(isCupertino: true);
    if (account == null && (myAccountPageViewModel.accounts?.length ?? 0) > 0)
      account = myAccountPageViewModel.accounts!.first;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Strings().createABid,
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      title: Strings().speed,
                      hintText: "0",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              '${Strings().algoSec}',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.5),
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                          SizedBox(width: 8)
                        ],
                      ),
                      onChanged: (String value) {
                        final num = int.tryParse(value) ?? 0;
                        speed = Quantity(num: num, assetId: speed.assetId);
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  Visibility(
                      visible: speed.num != 0,
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: CustomTextField(
                            title: Strings().bidAmount,
                            hintText: "0",
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    '${Strings().algoSec}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color
                                              ?.withOpacity(0.5),
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ),
                                SizedBox(width: 8)
                              ],
                            ),
                            onChanged: (String value) {
                              final num = int.tryParse(value) ?? 0;
                              amount =
                                  Quantity(num: num, assetId: amount.assetId);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: CustomTextField(
                title: Strings().note,
                hintText: Strings().bidNote,
                onChanged: (String value) {
                  note = value;
                },
              ),
            ),
            Visibility(
              visible: speed.num != 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
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
                          color:
                              Theme.of(context).shadowColor.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 6),
                          Text(
                            '0 secs',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Theme.of(context).cardColor,
                                  inactiveTrackColor:
                                      Theme.of(context).disabledColor,
                                  thumbShape: CustomSliderThumbRect(
                                    mainContext: context,
                                    thumbRadius: 15,
                                    max: 0,
                                    min: 100,
                                  ),
                                ),
                                child: Slider(
                                  value: _value,
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text('100 secs',
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
              ),
            ),
            Visibility(
                visible: speed.num != 0,
                child: Container(
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
                              ),
                            );
                          },
                          onPageChanged: (int val) {
                            account =
                                myAccountPageViewModel.accounts?.elementAt(val);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        )
                      : Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).shadowColor.withOpacity(0.2),
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
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10),
                                child: IconButton(
                                  onPressed: () =>
                                      CustomAlertWidget.showBidAlert(
                                          context, AddAccountOptionsWidgets()),
                                  iconSize: 30,
                                  icon: Icon(
                                    Icons.add_circle_rounded,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ) /*ElevatedButton(
                                  child: Text(Strings().addAccount),
                                )*/
                                ,
                              )
                            ],
                          ),
                        ),
                )),
            Visibility(
              visible: speed.num != 0 &&
                  (myAccountPageViewModel.accounts?.isNotEmpty ?? false),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                          primary: Theme.of(context).colorScheme.secondary),
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: ElevatedButton(
                onPressed: isInsufficient() ? null : () => onAddBid(),
                child: Text(getConfirmSliderText()),
              ),
            ),
            /*Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ConfirmationSlider(
                  onConfirmation: () {
                    onAddBid();
                  },
                  height: 50,
                  width: getWidthForSlider(context),
                  backgroundShape: BorderRadius.circular(12),
                  backgroundColor: Color(0xffD2D2DF),
                  thumbColor: isInsufficient(account)?Theme.of(context).errorColor:Theme.of(context).primaryColorDark,
                  shadow: BoxShadow(
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                  text: getConfirmSliderText(),
                  textStyle: isInsufficient(account)
                      ? Theme.of(context)
                          .textTheme
                          .bodyText2
                          ?.copyWith(color: Theme.of(context).errorColor)
                      : null,
                ),
              ),*/
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  int? getBalanceOfAccount() => account?.balances.first.assetHolding.amount;

  onAddBid() async {
    if (isInsufficient()) {
      return;
    }
    final addBidPageViewModel =
        ref.read(addBidPageViewModelProvider(widget.hangout.id).state).state;
    if (addBidPageViewModel is AddBidPageViewModel) {
      if (!addBidPageViewModel.submitting) {
        await connectCall(addBidPageViewModel: addBidPageViewModel);
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
    if (isInsufficient()) {
      return Strings().insufficientBalance;
    }
    return Strings().addBid;
  }

  isInsufficient() {
    if (speed.num == 0) return false;
    if (account == null) return true;
    final minCoinsNeeded = speed.num * 10;
    if (amount.num < minCoinsNeeded) return true; // at least 10 seconds
    final accountBalance = getBalanceOfAccount();
    if (accountBalance == null) return true;
    final minAccountBalanceNeeded =
        amount.num + 2 * AlgorandService.MIN_TXN_FEE;
    if (accountBalance < minAccountBalanceNeeded) return true;
    return false;
  }

  Future connectCall({required AddBidPageViewModel addBidPageViewModel}) async {
    CustomDialogs.loader(true, context);
    await addBidPageViewModel.addBid(
      hangout: widget.hangout,
      account: account,
      amount: amount,
      speed: speed,
      bidNote: note,
    );
    CustomDialogs.loader(false, context);
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
