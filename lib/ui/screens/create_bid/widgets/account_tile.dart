import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';

class AccountTile extends ConsumerStatefulWidget {
  final bool? shrinkwrap;

  AccountTile(this.shrinkwrap,
      {Key? key, required this.account, this.afterRefresh})
      : super(key: key);

  final AbstractAccount account;
  final void Function()? afterRefresh;

  @override
  _AccountTileState createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<AccountTile> {
  List<String> keyList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Balance balanceModel = widget.account.balances.first;
    final assetId = balanceModel.assetHolding.assetId;
    final amount = balanceModel.assetHolding.amount / 1000000;
    String assetName = assetId == 0
        ? '${Keys.ALGO.tr(context)}'
        : balanceModel.assetHolding.assetId.toString();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.height * 0.175,
        height: MediaQuery.of(context).size.height * 0.145,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                offset: Offset(2, 4),
                blurRadius: 8,
                color:
                    Color.fromRGBO(0, 0, 0, 0.12) // changes position of shadow
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
                Image.asset(
                  'assets/algo_logo.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.fill,
                ),
                Flexible(
                  child: Text(
                    assetName,
                    textAlign: TextAlign.start,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(color: AppTheme().lightSecondaryTextColor),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  size: 15,
                )
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
              child: widget.account is WalletConnectAccount
                  ? Image.asset(
                      'assets/wc_logo.png',
                      height: 16,
                      fit: BoxFit.contain,
                    )
                  : Text('LOCAL', style: Theme.of(context).textTheme.overline),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "$amount",
                  style: Theme.of(context).textTheme.headline6,
                  softWrap: false,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color? iconColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.secondary
          : null;

  Widget balancesList(List<Balance> balances) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: balances.length,
      itemBuilder: (_, ix) {
        final assetId = balances[ix].assetHolding.assetId;
        final assetName = assetId == 0
            ? 'μALGO'
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
}
