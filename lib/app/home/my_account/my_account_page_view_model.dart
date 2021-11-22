import 'package:app_2i2i/services/algorand_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MyAccountPageViewModel {
  MyAccountPageViewModel({
    required this.functions,
    required this.algorand,
    required this.numAccounts,
  });
  // {
  //   init();
  // }
  final FirebaseFunctions functions;
  final AlgorandService algorand;
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
    final account = await algorand.createAccount();
    await algorand.saveAccountLocally(account);
  }
}
