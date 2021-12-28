import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../common/theme.dart';

class AccountInfo extends ConsumerStatefulWidget {
  AccountInfo({Key? key, required this.account}) : super(key: key);

  final AbstractAccount account;

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends ConsumerState<AccountInfo> {
  Widget balancesList(List<Balance> balances) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: balances.length,
        itemBuilder: (_, ix) {
          final assetId = balances[ix].assetHolding.assetId;
          final assetName = assetId == 0
            ? 'ALGO'
            : balances[ix].assetHolding.assetId.toString();
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

  @override
  Widget build(BuildContext context) {
    Balance balanceModel = widget.account.balances.first;
    final assetId = balanceModel.assetHolding.assetId;
    final amount = balanceModel.assetHolding.amount;
    String assetName = assetId == 0
        ? 'ALGO'
        : balanceModel.assetHolding.assetId.toString();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
              offset: Offset(2, 4),
              blurRadius: 8,
              color: Color.fromRGBO(0, 0, 0, 0.12) // changes position of shadow
              ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Row(
              children: [
                Text(
                  'Algorand',
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 6),
                Text(assetName,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: Theme.of(context).disabledColor)),
              ],
            ),
            leading: Image.asset(
              'assets/algo_logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.fill,
            ),
            trailing: Text(
              "$amount",
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).tabBarTheme.unselectedLabelColor),
            ),
          ),
          SizedBox(height: 8),
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/wc_logo.png',
                  height: 20,
                  fit: BoxFit.fill,
                ),
                SizedBox(height: 8),
                Text(widget.account.address,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // InkResponse(
                //   onTap: () async {
                //     final asaId = await _optInToASA(context);
                //     if (asaId == null) return;
                //     CustomDialogs.loader(true, context);
                //     await widget.account
                //         .optInToASA(assetId: asaId, net: AlgorandNet.testnet);
                //     CustomDialogs.loader(false, context);
                //   },
                //   child: Card(
                //     margin: EdgeInsets.symmetric(horizontal: 4),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(6.0),
                //     ),
                //     elevation: 4,
                //     shadowColor: Theme.of(context).primaryColor,
                //     child: Container(
                //       height: 40,
                //       width: 40,
                //       decoration: BoxDecoration(
                //           color: Theme.of(context).cardColor,
                //           borderRadius: BorderRadius.circular(6)),
                //       child: Icon(
                //         Icons.add_circle_outline,
                //         size: 20,
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  height: 40,
                  width: 40,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/copy.svg',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.account.address));
                      showToast('Copied to Clipboard',
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
                        icon: SvgPicture.asset(
                          'assets/icons/key.svg',
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () => _showPrivateKey(
                            context, widget.account as LocalAccount),
                      ),
                    ),
                    visible: widget.account is LocalAccount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _showPrivateKey(BuildContext context, LocalAccount account) async {
    final pk = await account.mnemonic();
    log('_showPrivateKey - pk=$pk');
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('private key'),
              content: Table(
                children: [
                  for (var i = 1; i <= 13; i++)
                    TableRow(children: [
                      Text('$i ${pk[i - 1]}'),
                      i < 13 ? Text('${i + 13} ${pk[i + 12]}') : Container(),
                    ])
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: pk.join(' '))),
                    icon: Icon(Icons.copy))
              ],
            ));
  }

  Future<int?> _optInToASA(BuildContext context) async {
    final TextEditingController asaId = TextEditingController(text: '');
    return showDialog<int>(
        context: context,
        builder: (BuildContext context) => SimpleDialog(
              title: const Text('Enter ASA ID'),
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(
                        top: 5, left: 20, right: 20, bottom: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ASA ID',
                        border: OutlineInputBorder(),
                        label: Text('ASA ID'),
                      ),
                      minLines: 1,
                      maxLines: 1,
                      controller: asaId,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ], // Only numbers can be entered
                    )),
                Container(
                    padding: const EdgeInsets.only(
                        top: 10, left: 50, right: 50, bottom: 10),
                    child: ElevatedButton(
                        // style: ElevatedButton.styleFrom(primary: Color.fromRGBO(237, 124, 135, 1)),
                        child: Text('Opt In'),
                        onPressed: () => Navigator.pop(
                            context,
                            asaId.text.isEmpty
                                ? null
                                : int.parse(asaId.text)))),
              ],
            ));
  }
}
