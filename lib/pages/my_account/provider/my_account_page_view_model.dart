import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/cupertino.dart';

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
        storage: storage!);
    await updateAccounts();
  }

  Future<void> updateAccounts() async {
    accounts = await accountService!.getAllAccounts();
    notifyListeners();
  }
}
