import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/models/fx_model.dart';
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

  Balance balance;

  int get assetId => balance.assetHolding.assetId;

  // only used on refresh
  Future<Balance> getBalance() async {
    final myAccount = ref.read(myAccountPageViewModelProvider);
    return myAccount.getBalanceFromAddressAndAssetId(widget.address, assetId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FXModel?>(
      future: ref.read(myAccountPageViewModelProvider).getFXValue(balance.assetHolding.assetId),
      builder: (BuildContext context, AsyncSnapshot<FXModel?> snapshot) {
        if (snapshot.hasData) {
          final ccyLogo = Image.network(
            snapshot.data?.iconUrl ?? '',
            width: 35,
            height: 35,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/algo_logo.png',
              width: 35,
              height: 35,
              fit: BoxFit.fill,
            ),
          );

          // if (FXValue == null) return subjectiveOverlay(cont(ccyLogo, '', ''));

          // set assetName and amount
          String amount = '';
          if (snapshot.data != null) {
            final divisor = pow(10, snapshot.data!.decimals);
            final a = balance.assetHolding.amount / divisor;
            amount = doubleWithoutDecimalToInt(a).toString();
          }

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
                        ccyLogo,
                        SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            snapshot.data?.getName ?? "",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme().lightSecondaryTextColor),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount.isNotEmpty ? "${amount}" : "-",
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: iconColor(context)),
                        onPressed: () async {
                          var dialog = AlertDialog(
                            title: Text('Disconnect?'),
                            content: Text(
                              'Are you sure want to disconnect this wallet connect account?\n\n${widget.address}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            actions: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).errorColor,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Disconnect'),
                              ),
                            ],
                          );
                          final isSure = await showDialog(context: context, builder: (context) => dialog);
                          if (isSure) {
                            CustomAlertWidget.loader(true, context);
                            await ref.read(myAccountPageViewModelProvider).disconnectAccount(widget.address);
                            CustomAlertWidget.loader(false, context);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    width: 38,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: IconButton(
                        icon: Icon(Icons.credit_card_rounded, color: iconColor(context)),
                        onPressed: () async {
                          context.pushNamed(Routes.webView.nameFromPath(), params: {'walletAddress': widget.address});
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    width: 42,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/refresh.svg',
                          height: 42,
                          width: 42,
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
                  ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
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
                  ),
                ],
              )
            ],
          );

          if (snapshot.data?.value == null) {
            child = Stack(
              alignment: Alignment.center,
              children: [
                child,
                Text(
                  'subjective assets\nsupport coming later...',
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
            absorbing: snapshot.data?.value == null,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
              decoration: BoxDecoration(
                color: (snapshot.data?.value != null) ? Theme.of(context).cardColor : Theme.of(context).cardColor.withOpacity(0.5) /*Color(0xFFd3d3d3)*/,
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

        return Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                offset: Offset(2, 4),
                blurRadius: 8,
                color: Color.fromRGBO(0, 0, 0, 0.12),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  ListTile(
                    title: Text(''),
                  ),
                  ListTile(
                    title: Text(''),
                  ),
                  ListTile(
                    title: Text(''),
                  ),
                ],
              ),
              CupertinoActivityIndicator()
            ],
          ),
        );
      },
    );
  }

  Color? iconColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.secondary : Color(0XFF2D4E6C);
}
