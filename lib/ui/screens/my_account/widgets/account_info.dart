import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/walletconnect_account.dart';
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
import '../../../../infrastructure/data_access_layer/accounts/local_account.dart';
import '../../../../infrastructure/routes/app_routes.dart';
import '../../../commons/custom_dialogs.dart';
import 'keys_widget.dart';

class AccountInfo extends ConsumerStatefulWidget {
  final bool? shrinkwrap;

  AccountInfo(this.shrinkwrap, {Key? key, required this.account, this.afterRefresh}) : super(key: key);

  final AbstractAccount account;
  final void Function()? afterRefresh;

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends ConsumerState<AccountInfo> {
  List<String> keyList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Balance balanceModel = widget.account.balances.first;
    final assetId = balanceModel.assetHolding.assetId;
    final amount = balanceModel.assetHolding.amount / MILLION;
    String assetName = assetId == 0 ? '${Keys.ALGO.tr(context)}' : balanceModel.assetHolding.assetId.toString();

    return Container(
      constraints: widget.shrinkwrap == true
          ? null
          : BoxConstraints(
              minHeight: 200,
            ),
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
                        style:
                            Theme.of(context).textTheme.subtitle1?.copyWith(color: AppTheme().lightSecondaryTextColor),
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
              widget.account is WalletConnectAccount
                  ? Image.asset(
                      'assets/wc_logo.png',
                      height: 20,
                      fit: BoxFit.fill,
                    )
                  : Container(),
              SizedBox(height: 8),
              Text(
                widget.account.address,
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
                        context.pushNamed(Routes.webView.nameFromPath(),
                            params: {'walletAddress': widget.account.address});
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
                      await widget.account.updateBalances(net: AppConfig().ALGORAND_NET);
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
                      Clipboard.setData(ClipboardData(text: widget.account.address));
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
                Visibility(
                    child: Container(
                      height: 40,
                      width: 40,
                      child: IconButton(
                          iconSize: 18,
                          icon: SvgPicture.asset(
                            'assets/icons/key.svg',
                            color: iconColor(context),
                          ),
                          onPressed: () => CustomDialogs.infoDialog(
                                context: context,
                                child: KeysWidget(account: widget.account as LocalAccount),
                              )
                          // onPressed: () => _showPrivateKey(context, widget.account as LocalAccount),
                          ),
                    ),
                    visible: widget.account is LocalAccount),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color? iconColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.secondary : Color(0XFF2D4E6C);

  Widget balancesList(List<Balance> balances) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: balances.length,
      itemBuilder: (_, ix) {
        final assetId = balances[ix].assetHolding.assetId;
        final assetName = assetId == 0 ? 'μALGO' : balances[ix].assetHolding.assetId.toString();
        final assetAmount = balances[ix].assetHolding.amount;
        final net = balances[ix].net;
        return Container(
          // margin: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          // color: Color.fromRGBO(197, 234, 197, 1),
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          child: ListTile(
            title: Text('$assetName - $assetAmount - $net'),
          ),
        );
      },
    );
  }

// Future<int?> _optInToASA(BuildContext context) async {
//   final TextEditingController asaId = TextEditingController(text: '');
//   return showDialog<int>(
//       context: context,
//       builder: (BuildContext context) => SimpleDialog(
//             title: const Text('Enter ASA ID'),
//             children: <Widget>[
//               Container(
//                   padding: const EdgeInsets.only(
//                       top: 5, left: 20, right: 20, bottom: 10),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'ASA ID',
//                       border: OutlineInputBorder(),
//                       label: Text('ASA ID'),
//                     ),
//                     minLines: 1,
//                     maxLines: 1,
//                     controller: asaId,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: <TextInputFormatter>[
//                       FilteringTextInputFormatter.digitsOnly
//                     ], // Only numbers can be entered
//                   )),
//               Container(
//                   padding: const EdgeInsets.only(
//                       top: 10, left: 50, right: 50, bottom: 10),
//                   child: ElevatedButton(
//                       // style: ElevatedButton.styleFrom(primary: Color.fromRGBO(237, 124, 135, 1)),
//                       child: Text('Opt In'),
//                       onPressed: () => Navigator.pop(
//                           context,
//                           asaId.text.isEmpty
//                               ? null
//                               : int.parse(asaId.text)))),
//             ],
//           ));
// }
}
