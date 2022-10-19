import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom_alert_widget.dart';

class AccountAssetInfo extends ConsumerStatefulWidget {
  final bool? shrinkwrap;
  final int index;

  AccountAssetInfo(
    this.shrinkwrap, {
    Key? key,
    this.afterRefresh,
    required this.index,
    required this.address,
    required this.initBalance,
  }) : super(key: key);

  final String address;
  final Balance initBalance;

  final void Function()? afterRefresh;

  @override
  _AccountAssetInfoState createState() => _AccountAssetInfoState(initBalance);
}

class _AccountAssetInfoState extends ConsumerState<AccountAssetInfo> {
  _AccountAssetInfoState(this.balance);

  List<String> keyList = [];

  String assetName = '-';

  // String iconUrl = 'assets/algo_logo.png';
  int decimals = 0;

  Balance balance;

  @override
  void initState() {
    getAsset().then((_) {
      // asset = value;
      if (mounted) {
        setState(() {});
      }
    });

    ref.read(myAccountPageViewModelProvider).getAssetIdInfo(assetID: balance.assetHolding.assetId.toString());
    super.initState();
  }

  int get assetId => balance.assetHolding.assetId;

  Future<Balance> getBalance() async {
    final myAccount = ref.read(myAccountPageViewModelProvider);
    final balances = await myAccount.getBalanceFromAddress(widget.address);
    for (final b in balances) {
      if (b.assetHolding.assetId == assetId) {
        return b;
      }
    }
    throw "_AccountAssetInfoState - getBalance error - assetId=$assetId";
  }

  Future<void> getAsset() async {
    log('getAsset assetId=$assetId');

    if (assetId == 0) {
      assetName = 'ALGO';
      decimals = 6;
      return;
    }

    final myAccount = ref.read(myAccountPageViewModelProvider);
    log('await myAccount.getAsset assetId=$assetId');
    final asset = await myAccount.getAsset(balance.assetHolding.assetId);
    assetName = asset.params.unitName ?? (asset.params.name ?? asset.index.toString());
    decimals = asset.params.decimals;
    // iconUrl = // TODO

    log('getAsset assetName=$assetName decimals=$decimals');
  }

  @override
  Widget build(BuildContext context) {
    final myAccount = ref.read(myAccountPageViewModelProvider);
    // set assetName and amount
    final divisor = pow(10, decimals);
    final a = balance.assetHolding.amount / divisor;
    String amount = doubleWithoutDecimalToInt(a).toString();

    final ccyLogo = Image.network(
      'https://asa-list.tinyman.org/assets/$assetId/icon.png',
      width: 40,
      height: 40,
      fit: BoxFit.fill,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/algo_logo.png',
        width: 40,
        height: 40,
        fit: BoxFit.fill,
      ),
    );

    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: 10),
                  // Image.asset(
                  //   'assets/algo_logo.png',
                  //   width: 40,
                  //   height: 40,
                  //   fit: BoxFit.fill,
                  // ),
                  ccyLogo,
                  SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      assetName,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(color: AppTheme().lightSecondaryTextColor),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "$amount",
              style: Theme.of(context).textTheme.headline4,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Visibility(
              visible: true, //widget.account is WalletConnectAccount
              child: Image.asset(
                'assets/wc_logo.png',
                height: 20,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.address,
              maxLines: 4,
              style: Theme.of(context).textTheme.caption,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Divider(),
        Container(
          // color: Colors.amber,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: IconButton(
                  icon: Icon(Icons.credit_card_rounded, color: iconColor(context)),
                  onPressed: () async {
                    context.pushNamed(Routes.webView.nameFromPath(), params: {'walletAddress': widget.address});
                  },
                ),
              ),
              Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.symmetric(horizontal: 6),
                child: IconButton(
                  iconSize: 18,
                  icon: SvgPicture.asset(
                    'assets/icons/refresh.svg',
                    color: iconColor(context),
                  ),
                  onPressed: () async {
                    CustomAlertWidget.loader(true, context);
                    balance = await getBalance();
                    if (widget.afterRefresh != null) widget.afterRefresh!();
                    CustomAlertWidget.loader(false, context);
                    setState(() {});
                  },
                ),
              ),
              Container(
                height: 40,
                width: 40,
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  iconSize: 18,
                  icon: SvgPicture.asset(
                    'assets/icons/copy.svg',
                    color: iconColor(context),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.address));
                    showToast(Keys.copyMessage.tr(context),
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
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );

    if (!myAccount.isObjective) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          child,
          Text(
            'Subjective assets\nsupport coming late...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              shadows: <Shadow>[
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.white,
                  offset: Offset(4.0, 4.0),
                ),
                Shadow(
                  color: Colors.white,
                  blurRadius: 10.0,
                  offset: Offset(-9.0, 4.0),
                ),
              ],
            ),
          )
        ],
      );
    }

    return AbsorbPointer(
      absorbing: !myAccount.isObjective,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
        decoration: BoxDecoration(
          color: myAccount.isObjective ? Theme.of(context).cardColor : Color(0xFFd3d3d3),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              offset: Offset(2, 4),
              blurRadius: 8,
              color: Color.fromRGBO(0, 0, 0, 0.12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Color? iconColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.secondary : Color(0XFF2D4E6C);
}
