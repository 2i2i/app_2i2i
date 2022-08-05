import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom_dialogs.dart';

class AccountInfo extends ConsumerStatefulWidget {
  final bool? shrinkwrap;
  final int index;

  AccountInfo(
    this.shrinkwrap, {
    Key? key,
    this.afterRefresh,
    required this.index,
    required this.address,
  }) : super(key: key);

  // final AbstractAccount account;
  final String address;

  // List<Balance> balances;
  final void Function()? afterRefresh;

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends ConsumerState<AccountInfo> {
  List<String> keyList = [];
  List<Balance> balances = [];

  @override
  void initState() {
    var myAccount = ref.read(myAccountPageViewModelProvider);
    myAccount.getBalanceFromAddress(widget.address).then((value) {
      balances = value;
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String assetName = Keys.ALGO.tr(context);
    String amount = '0';

    if (balances.isNotEmpty) {
      Balance balanceModel = balances.first;
      final assetId = balanceModel.assetHolding.assetId;
      amount = (balanceModel.assetHolding.amount / MILLION).toString();
      assetName = assetId == 0 ? '${Keys.ALGO.tr(context)}' : balanceModel.assetHolding.assetId.toString();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(top: 14, left: 14, right: 14, bottom: 8),
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
      child: Column(
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
                    Image.asset(
                      'assets/algo_logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.fill,
                    ),
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
                      bool camera = true;
                      bool microphone = true;
                      if (!kIsWeb) {
                        camera = await Permission.camera.request().isGranted;
                        microphone = await Permission.microphone.request().isGranted;
                      }
                      if (camera && microphone) {
                        context.pushNamed(Routes.webView.nameFromPath(), params: {'walletAddress': widget.address});
                      }
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
                      CustomDialogs.loader(true, context);
                      // await widget.account.updateBalances(net: AppConfig().ALGORAND_NET); //todo chandresh
                      if (widget.afterRefresh != null) widget.afterRefresh!();
                      CustomDialogs.loader(false, context);
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
                /*if (widget.account is LocalAccount)
                  Container(
                    height: 40,
                    width: 40,
                    child: Stack(
                      children: [
                        IconButton(
                          iconSize: 18,
                          icon: SvgPicture.asset(
                            'assets/icons/key.svg',
                            color: iconColor(context),
                          ),
                          onPressed: () async {
                            CustomDialogs.infoDialog(
                              context: context,
                              child: KeysWidget(account: widget.account as LocalAccount),
                            );
                            await appSettingModel.setTappedOnKey("1");
                          },
                          // onPressed: () => _showPrivateKey(context, widget.account as LocalAccount),
                        ),
                        Visibility(
                          visible: widget.index == 0 && !(appSettingModel.isTappedOnKey),
                          child: Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: new Icon(Icons.brightness_1, size: 12.0, color: Colors.redAccent),
                          ),
                        )
                      ],
                    ),
                  ),*/
              ],
            ),
          )
        ],
      ),
    );
  }

  Color? iconColor(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.secondary : Color(0XFF2D4E6C);
}
