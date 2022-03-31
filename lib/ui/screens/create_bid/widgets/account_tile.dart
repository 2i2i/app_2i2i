import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/commons/keys.dart';
import '../../../../infrastructure/commons/theme.dart';
import '../../../../infrastructure/data_access_layer/accounts/abstract_account.dart';
import '../../../../infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import '../../../../infrastructure/providers/all_providers.dart';
import '../../home/wait_page.dart';

class SelectAccount extends ConsumerStatefulWidget {
  @override
  _SelectAccountState createState() => _SelectAccountState();
}

class _SelectAccountState extends ConsumerState<SelectAccount> {
  @override
  Widget build(BuildContext context) {
    final myAccountPageViewModel = ref.watch(myAccountPageViewModelProvider);
    return Builder(builder: (context) {
      if (myAccountPageViewModel.isLoading) {
        return WaitPage(
          isCupertino: true,
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 6,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemBuilder: (BuildContext context, int index) {
          index = 0;
          return AccountTile(
            true,
            key: ObjectKey(myAccountPageViewModel.accounts![index].address),
            account: myAccountPageViewModel.accounts![index],
          );
        },
      );
    });
  }
}

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

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            dense: true,
            // contentPadding: EdgeInsets.all(4),
            secondary:  Text(
              "$amount",
              style: Theme.of(context).textTheme.headline5,
              softWrap: false,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
            title: Text(
              assetName,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme().lightSecondaryTextColor),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text( widget.account is WalletConnectAccount?'WalletConnect':'Local Account',
                style: Theme.of(context)
                    .textTheme
                    .button
                    ?.copyWith(color: Colors.blue)),
            groupValue: 1,
            value: 1,
            onChanged: (int? value) {},
          ),
          Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.fromLTRB(10,4,4,4),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.account.address,
                    maxLines: 4,
                    style: Theme.of(context).textTheme.caption,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(child: Icon(Icons.more_vert,size: 20,),padding: EdgeInsets.all(4))
              ],
            ),
          ),
          SizedBox(height: 6)
        ],
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
