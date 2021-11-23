import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/app/home/models/user.dart';
import 'package:app_2i2i/services/algorand_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AddBidPageViewModel {
  AddBidPageViewModel({
    required this.functions,
    required this.algorand,
    required this.user,
    required this.accounts,
    required this.accountService,
  });
  final FirebaseFunctions functions;
  final UserModel user;
  final AlgorandService algorand;
  final AccountService accountService;
  final List<AbstractAccount> accounts;

  // List<String> balancesStrings({required int numAccount}) =>
  //     accounts[numAccount].assetHoldings[net]!.map((AssetHolding b) {
  //       // log('balancesStrings - b=$b - (${balances.length})');
  //       return '${b.assetId} - ${b.amount}';
  //     }).toList();

  bool submitting = false;

  // String duration(
  //     int numAccount, int speedNum, int assetIndex, double budgetPercentage) {
  //   if (speedNum == 0) return 'forever';
  //   final balance = accounts[numAccount].assetHoldings[net]![assetIndex].amount;
  //   final budget = balance * budgetPercentage / 100;
  //   final seconds = budget / speedNum;
  //   return secondsToSensibleTimePeriod(seconds.round());
  // }

  // Future addBid({
  //   required int assetIndex,
  //   required int speedNum,
  //   required double budgetPercentage,
  //   required int numAccount,
  // }) async {
  //   log('AddBidPageViewModel - addBid');

  //   if (submitting) return;
  //   submitting = true;

  //   final AssetHolding asset =
  //       accounts[numAccount].assetHoldings[net]![assetIndex];
  //   log('AddBidPageViewModel - addBid - !submitting - asset=$asset');

  //   final int speedAssetId = asset.assetId;
  //   log('AddBidPageViewModel - addBid - speedAssetId=$speedAssetId');

  //   final publicAddress = accounts[numAccount].address;
  //   final budget = await accountService.calcBudget(
  //       assetId: speedAssetId, account: accounts[numAccount], net: net);
  //   log('AddBidPageViewModel - addBid - budget=$budget');
  //   if (budget == null) throw NullThrownError(); // TODO show user something
  //   final actualBudget = budget * budgetPercentage / 100;

  //   final speed = Speed(num: speedNum, assetId: speedAssetId);
  //   log('AddBidPageViewModel - addBid - speed=$speed');

  //   final HttpsCallable addBid = functions.httpsCallable('addBid');
  //   final args = {
  //     'B': user.id,
  //     'speed': speed.toMap(),
  //     'net': AlgorandNet.testnet
  //         .toString(), //net.toString(), // HARDCODED TO TESTNET FOR NOW
  //     'addrA': publicAddress,
  //     'budget': actualBudget,
  //   };
  //   log('AddBidPageViewModel - addBid=$addBid - args=$args');
  //   await addBid(args);
  //   log('addBid after');
  // }
}
