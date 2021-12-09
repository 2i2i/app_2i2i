import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/common/progress_dialog.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
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
              margin: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 10),
              color: Color.fromRGBO(197, 234, 197, 1),
              child: ListTile(
                title: Text('$assetName - $assetAmount - $net'),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        ListTile(
          title: Text(
            'Algorand address',
            style: Theme.of(context).textTheme.headline6,
          ),
          leading: Icon(
            Icons.paid,
            size: 35,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            margin:
                const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
            color: Color.fromRGBO(223, 239, 223, 1),
            child: ListTile(
              title: Text(widget.account.address),
              trailing:
                  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.account is LocalAccount
                      ? IconButton(
                          onPressed: () => _showPrivateKey(
                              context, widget.account as LocalAccount),
                          icon: Icon(Icons.keyboard))
                      : Container(),
                  IconButton(
                      onPressed: () async {
                        final asaId = await _optInToASA(context);
                        if (asaId == null) return;
                        ProgressDialog.loader(true, context);
                        await widget.account.optInToASA(
                            assetId: asaId, net: AlgorandNet.testnet);
                        ProgressDialog.loader(false, context);
                      },
                      icon: Icon(Icons.opacity)),
                  IconButton(
                      onPressed: () => Clipboard.setData(
                          ClipboardData(text: widget.account.address)),
                      icon: Icon(Icons.copy)),
                ],
              ),
            )),
        SizedBox(
          height: 50,
        ),
        ListTile(
          title: Text(
            'Balances',
            style: Theme.of(context).textTheme.headline6,
          ),
          leading: IconButton(
              color: Color.fromRGBO(116, 117, 109, 1),
              iconSize: 35,
              onPressed: () async {
                ProgressDialog.loader(true, context);
                await widget.account.updateBalances();
                ProgressDialog.loader(false, context);
                setState(() {});
              },
              icon: Icon(Icons.replay_circle_filled)),
        ),
        SizedBox(
          height: 20,
        ),
        balancesList(widget.account.balances),
        SizedBox(
          height: 20,
        ),
      ],
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
