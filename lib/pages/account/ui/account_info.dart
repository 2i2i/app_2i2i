import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountInfo extends ConsumerWidget {
  const AccountInfo({Key? key, required this.numAccount}) : super(key: key);
  final int numAccount;

  Widget balancesList(List<AssetHolding> assetHoldings) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: assetHoldings.length,
        itemBuilder: (_, ix) {
          final assetId = assetHoldings[ix].assetId;
          final assetName =
              assetId == 0 ? 'ALGO' : assetHoldings[ix].assetId.toString();
          final assetAmount = assetHoldings[ix].amount;
          return Container(
              margin: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 10),
              color: Color.fromRGBO(197, 234, 197, 1),
              child: ListTile(
                title: Text('$assetName - $assetAmount'),
              ));
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountInfoViewModel =
        ref.watch(accountInfoViewModelProvider(numAccount));
    if (accountInfoViewModel == null) return Container();
    
    return Container(
      child: Column(
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
              margin: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 10),
              color: Color.fromRGBO(223, 239, 223, 1),
              child: ListTile(
                  title: Text(accountInfoViewModel.account.publicAddress),
                  trailing: IconButton(
                      onPressed: () => Clipboard.setData(ClipboardData(
                          text: accountInfoViewModel.account.publicAddress)),
                      icon: Icon(Icons.copy)))),
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
                onPressed: (){},//accountInfoViewModel.refreshBalances,
                icon: Icon(Icons.replay_circle_filled)),
          ),
          SizedBox(
            height: 20,
          ),
          balancesList(accountInfoViewModel.balances),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class AccountInfoViewModel {
  AccountInfoViewModel({required this.account, required this.algorand, required this.balances}) {
    // refreshBalances();
  }
  final AlgorandService algorand;
  final Account account;

  final List<AssetHolding> balances;
  // void refreshBalances() async {
  //   balances = await algorand.getAssetHoldings(account.publicAddress);
  // }
}
