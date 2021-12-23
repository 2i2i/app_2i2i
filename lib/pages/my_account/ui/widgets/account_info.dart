import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/common/theme.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).primaryColorDark,
                Theme.of(context).primaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(15.0)),
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
                        .copyWith(color: Theme.of(context).cardColor),
                  ),
                  SizedBox(width: 6),
                  Text(
                    assetName,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(color: Theme.of(context).cardColor),
                  ),
                ],
              ),
              leading: Container(
                height: 40,
                width: 40,
                child: Center(
                    child: Text(
                  "X".substring(0, 1).toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: AppTheme().black),
                )),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(214, 219, 134, 1),
                ),
              ),
              trailing: Text(
                "$amount",
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: Theme.of(context).cardColor, shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 1.9,
                    color: Theme.of(context).iconTheme.color!,
                  ),
                ]),
              ),
            ),
            ListTile(
              tileColor: Theme.of(context).cardColor,
              title: Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    size: 18,
                    color: Theme.of(context).cardColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "Local Account",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Theme.of(context).cardColor),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(widget.account.address,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Theme.of(context).cardColor)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                      child: InkResponse(
                        onTap: () => _showPrivateKey(
                            context, widget.account as LocalAccount),
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(6)),
                            child: Icon(
                              Icons.vpn_key,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      visible: widget.account is LocalAccount),
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
                  InkResponse(
                    onTap: () => Clipboard.setData(
                        ClipboardData(text: widget.account.address)),
                    child: Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(6)),
                        child: Icon(
                          Icons.copy,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
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
