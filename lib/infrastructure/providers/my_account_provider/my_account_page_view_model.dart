
import 'package:flutter/cupertino.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/accounts/local_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../all_providers.dart';

class MyAccountPageViewModel extends ChangeNotifier {
  var ref;

  MyAccountPageViewModel(this.ref);

  AlgorandLib? algorandLib;
  SecureStorage? storage;
  AccountService? accountService;
  bool isLoading = true;
  List<AbstractAccount>? accounts;

  Future<void> initMethod() async {
    try {
      algorandLib = await ref!.watch(algorandLibProvider);
      storage = await ref!.watch(storageProvider);
      accountService = await ref!.watch(accountServiceProvider);
      accounts = await accountService!.getAllAccounts();
      isLoading = false;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> addLocalAccount() async {
    await LocalAccount.create(
        accountService: accountService!,
        algorandLib: algorandLib!,
        storage: storage!,
    );
    await updateAccounts();
  }

  Future recoverAccount(List<String> mnemonic) async {
    await LocalAccount.fromMnemonic(
      accountService: accountService!,
      algorandLib: algorandLib!,
      storage: storage!,
      mnemonic: mnemonic,
    );
    await updateAccounts();
  }

  Future<void> updateAccounts() async {
    accounts = await accountService!.getAllAccounts();
    notifyListeners();
  }
}
