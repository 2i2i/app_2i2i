import 'package:app_2i2i/infrastructure/data_access_layer/accounts/abstract_account.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/providers/add_bid_provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:app_2i2i/ui/screens/home/wait_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/strings.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../commons/custom_alert_widget.dart';
import '../../../commons/custom_text_field.dart';
import '../../my_account/widgets/account_info.dart';
import '../../my_account/widgets/add_account_options_widget.dart';

class CreateBidWidget extends ConsumerStatefulWidget {
  final String uid;
  final double sliderHeight;
  final int min;
  final int max;
  final fullWidth;

  CreateBidWidget(
      {this.sliderHeight = 48,
      this.max = 10,
      required this.uid,
      this.min = 0,
      this.fullWidth = false});

  @override
  _CreateBidWidgetState createState() => _CreateBidWidgetState();
}

class _CreateBidWidgetState extends ConsumerState<CreateBidWidget>
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
    if (myAccountPageViewModel is AsyncLoading ||
        myAccountPageViewModel is AsyncError) {
      return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: WaitPage(
        isCupertino: true,
        height: MediaQuery.of(context).size.height / 2,
      ));
    }
    final addBidPageViewModel =
        ref.watch(addBidPageViewModelProvider(widget.uid).state).state;
    if (addBidPageViewModel == null) return WaitPage(isCupertino: true);
    if (addBidPageViewModel.submitting) return WaitPage(isCupertino: true);
    if (account == null && (myAccountPageViewModel.accounts?.length ?? 0) > 0)
      account = myAccountPageViewModel.accounts!.first;

    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      Strings().createABid,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ),
                  IconButton(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close),
                    iconSize: 18,
                  )
                ],
              ),
              Divider(thickness: 1),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
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
                              .subtitle2!
                              .copyWith(
                                  color: Theme.of(context).shadowColor,
                                  fontWeight: FontWeight.normal),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Est.max duration',
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: Theme.of(context).shadowColor)),
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
                                  activeTrackColor: Theme.of(context)
                                      .tabBarTheme
                                      .unselectedLabelColor,
                                  thumbShape: CustomSliderThumbRect(
                                      mainContext: context,
                                      thumbRadius: 15,
                                      max: 0,
                                      min: 100),
                                ),
                                child: Slider(
                                    value: _value,
                                    onChanged: (value) {
                                      setState(() {
                                        _value = value;
                                      });
                                    }),
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
              Visibility(
                  visible: speed.num != 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
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
                                  .subtitle2!
                                  .copyWith(
                                      color: Theme.of(context).shadowColor,
                                      fontWeight: FontWeight.normal),
                            ),
                          ),
                          SizedBox(width: 8)
                        ],
                      ),
                      onChanged: (String value) {
                        final num = int.tryParse(value) ?? 0;
                        amount = Quantity(num: num, assetId: amount.assetId);
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  )),
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
                              account = myAccountPageViewModel.accounts
                                  ?.elementAt(val);
                              if (mounted) {
                                setState(() {});
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
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                                SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 10),
                                  child: ElevatedButton(
                                    child: Text(Strings().addAccount),
                                    onPressed: () =>
                                        CustomAlertWidget.showBidAlert(context,
                                            AddAccountOptionsWidgets()),
                                  ),
                                )
                              ],
                            ),
                          ),
                  )),
              Visibility(
                visible: speed.num != 0 &&
                    (myAccountPageViewModel.accounts?.isNotEmpty ?? false),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_back_outlined),
                    ),
                    Expanded(
                      child: Text(
                        'Swipe Below Card Left or Right to change account',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_forward_outlined),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
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
      ),
    );
  }

  int? getBalanceOfAccount() => account?.balances.first.assetHolding.amount;

  onAddBid() async {
    if (isInsufficient()) {
      return;
    }
    final addBidPageViewModel =
        ref.read(addBidPageViewModelProvider(widget.uid).state).state;
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
      return 'Insufficient balance';
    }
    // return 'Swipe for bid';
    return 'Add bid';
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
      ..color = AppTheme().primaryTextColor
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
        style: Theme.of(mainContext).textTheme.subtitle1!.copyWith(
            color: Theme.of(mainContext).primaryColor,
            fontWeight: FontWeight.w800),
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