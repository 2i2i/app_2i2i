import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAccountPageViewModel extends ChangeNotifier {
  ProviderRefBase? ref;

  MyAccountPageViewModel(this.ref);

  /*MyAccountPageViewModel({
    required this.functions,
    required this.algorandLib,
    required this.accountService,
    required this.storage,
    required this.numAccounts,
  });*/

  // {
  //   init();
  // }
  /*final FirebaseFunctions functions;*/
  AlgorandLib? algorandLib;
  SecureStorage? storage;
  AccountService? accountService;
  int? numAccounts;
  bool isLoading = true;

  // void init() async {
  //   numAccounts = await algorand.numAccountsStored();
  // }

  // Future optIn(int assetId, int numAccount) async {
  //   // is user account opted in?
  //   final accountPublicAddress =
  //       await algorand.accountPublicAddress(numAccount);
  //   final userOptedIn =
  //       await algorand.isAccountOptedInToASA(accountPublicAddress!, assetId);

  //   log('MyAccountPageViewModel - optIn - userOptedIn=$userOptedIn');

  //   return algorand.optInUserAccountToASA(
  //       assetId: assetId, numAccount: numAccount);
  // }

  initMethod() async {
    try {
      algorandLib = await ref!.watch(algorandLibProvider);
      storage = await ref!.watch(storageProvider);
      accountService = await ref!.watch(accountServiceProvider);
      numAccounts = await accountService!.getNumAccounts();
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }

  Future addAccount() async {
    await LocalAccount.create(
        accountService: accountService!,
        algorandLib: algorandLib!,
        storage: storage!);
    numAccounts = await accountService!.getNumAccounts();
    notifyListeners();
  }
}
