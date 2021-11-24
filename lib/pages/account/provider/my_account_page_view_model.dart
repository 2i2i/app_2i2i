import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/all_providers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyAccountPageViewModel extends ChangeNotifier {
  ProviderRefBase ref;

  MyAccountPageViewModel(this.ref);

  bool isLoading = true;
  int? numAccounts;
  FirebaseFunctions? functions;
  AlgorandService? algorand;

  /*MyAccountPageViewModel({
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
  // }*/

  initMethod() async {
    try {
      algorand = await ref.read(algorandProvider(AlgorandNet.testnet));
      numAccounts = await algorand!.getNumAccounts();
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }

  Future addAccount() async {
    try {
      final account = await algorand!.createAccount();
      await algorand!.saveAccountLocally(account);
      numAccounts = await algorand!.getNumAccounts();
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
}
