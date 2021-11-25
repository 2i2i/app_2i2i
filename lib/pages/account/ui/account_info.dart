import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountInfo extends ConsumerStatefulWidget {
  const AccountInfo({Key? key, required this.numAccount}) : super(key: key);
  final int numAccount;

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends ConsumerState<AccountInfo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ref.read(accountInfoViewModelProvider2).initMethod(widget.numAccount);
    });
  }

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
    var accountInfoViewModel = ref.watch(
        accountInfoViewModelProvider(widget.numAccount));
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
                  title: Text(accountInfoViewModel.account.address),
                  trailing: IconButton(
                      onPressed: () => Clipboard.setData(ClipboardData(
                          text: accountInfoViewModel.account.address)),
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
                onPressed: () {
                  accountInfoViewModel.updateBalances();
                  ref.watch(accountInfoViewModelProvider(widget.numAccount));
                },
                icon: Icon(Icons.replay_circle_filled)),
          ),
          SizedBox(
            height: 20,
          ),
          balancesList(accountInfoViewModel.account.balances),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class AccountInfoViewModel {
  AccountInfoViewModel({required this.account, required this.algorand});

  final AlgorandService algorand;
  final AbstractAccount account;

  Future updateBalances() {
    return account.updateBalances();
  }
}

class AccountInfoViewModel2 extends ChangeNotifier {
  // AccountInfoViewModel({required this.account, required this.algorand});
  ProviderRefBase ref;

  AccountInfoViewModel2(this.ref);

  AlgorandService? algorand;
  AbstractAccount? account;

  initMethod(int numAccount) async {
    try {
      algorand = ref.watch(algorandProvider);
      AbstractAccount accountData = ref
          .watch(accountProvider(numAccount))
          .data!
          .value;
      if (accountData is AsyncLoading) return null;
      print(accountData);
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  updateBalances() {
    account!.updateBalances();
    print(account);
    notifyListeners();
  }
}
