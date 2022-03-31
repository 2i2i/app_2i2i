import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_database.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:flutter/cupertino.dart';
import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/accounts/local_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../all_providers.dart';

class MyAccountPageViewModel extends ChangeNotifier {
  var ref;

  MyAccountPageViewModel(
      {required this.ref, required this.uid, required this.database});

  AlgorandLib? algorandLib;
  SecureStorage? storage;
  AccountService? accountService;
  bool isLoading = true;
  List<AbstractAccount>? accounts;

  String? uid;
  FirestoreDatabase database;

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

  Future updateDBWithNewAccount(String address, {String type = 'LOCAL'}) =>
      database.addAlgorandAccount(uid!, address, type);

  Future<void> saveLocalAccount(LocalAccount account) async {
    if (uid == null) return;
    await account.storeAccount(account.account);
    await account.updateBalances(net: AppConfig().ALGORAND_NET);
    await updateDBWithNewAccount(account.address);
    updateAccounts();
  }

  Future recoverAccount(List<String> mnemonic) async {
    if (uid == null) return;
    final account = await LocalAccount.fromMnemonic(
      accountService: accountService!,
      algorandLib: algorandLib!,
      storage: storage!,
      mnemonic: mnemonic,
    );
    await updateDBWithNewAccount(account.address);
    await updateAccounts();
    return account;
  }

  Future<void> updateAccounts() async {
    accounts = await accountService!.getAllAccounts();
    notifyListeners();
  }
}
