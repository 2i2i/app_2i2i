import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
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
      log('MyAccountPageViewModel initMethod 1');
      algorandLib = await ref!.watch(algorandLibProvider);
      log('MyAccountPageViewModel initMethod 2');
      storage = await ref!.watch(storageProvider);
      log('MyAccountPageViewModel initMethod 3');
      accountService = await ref!.watch(accountServiceProvider);
      log('MyAccountPageViewModel initMethod 4');
      accounts = await accountService!.getAllAccounts();
      log('MyAccountPageViewModel initMethod 5');
      isLoading = false;
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<LocalAccount> addLocalAccount() async {
    LocalAccount localAccount = await LocalAccount.createWithoutStore(
      accountService: accountService!,
      algorandLib: algorandLib!,
      storage: storage!,
    );
    return localAccount;
  }

  Future<void> saveLocalAccount(LocalAccount account) async {
    await account.storeAccount(account.account);
    await account.updateBalances(net: AppConfig().ALGORAND_NET);
    updateAccounts();
  }

  Future<LocalAccount> recoverAccount(List<String> mnemonic) async {
    final account = await LocalAccount.fromMnemonic(
      accountService: accountService!,
      algorandLib: algorandLib!,
      storage: storage!,
      mnemonic: mnemonic,
    );
    await updateAccounts();
    return account;
  }

  Future<void> updateAccounts() async {
    accounts = await accountService!.getAllAccounts();
    notifyListeners();
  }
}
