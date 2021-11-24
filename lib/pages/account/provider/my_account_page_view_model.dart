import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MyAccountPageViewModel {
  MyAccountPageViewModel({
    required this.functions,
    required this.algorandLib,
    required this.accountService,
    required this.storage,
    required this.numAccounts,
  });
  // {
  //   init();
  // }
  final FirebaseFunctions functions;
  final AlgorandLib algorandLib;
  final SecureStorage storage;
  final AccountService accountService;
  final int numAccounts;

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

  Future addAccount() async {
    LocalAccount.create(
        accountService: accountService,
        algorandLib: algorandLib,
        storage: storage);
  }
}
