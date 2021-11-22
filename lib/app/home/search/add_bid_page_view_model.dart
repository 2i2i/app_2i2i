import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/app/home/models/bid.dart';
import 'package:app_2i2i/app/home/models/user.dart';
import 'package:app_2i2i/app/utils.dart';
import 'package:app_2i2i/services/algorand_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:app_2i2i/app/logging.dart';

class AddBidPageViewModel {
  AddBidPageViewModel(
      {required this.functions,
      // required this.algorandMainnet,
      required this.algorandTestnet,
      required this.user,
      required this.balances}) {
    log('AddBidPageViewModel - balances=$balances - balancesStrings=$balancesStrings');
  }
  final FirebaseFunctions functions;
  final UserModel user;
  // final AlgorandService algorandMainnet;
  final AlgorandService algorandTestnet;
  final List<List<AssetHolding>> balances;
  List<String> balancesStrings(int numAccount) =>
      balances[numAccount - 1].map((AssetHolding b) {
        // log('balancesStrings - b=$b - (${balances.length})');
        return '${b.assetId} - ${b.amount}';
      }).toList();

  AlgorandService get currentAlgorandService => algorandTestnet;
  // net == AlgorandNet.mainnet ? algorandMainnet : algorandTestnet;

  AlgorandNet net = AlgorandNet.testnet;
  bool submitting = false;

  String duration(
      int numAccount, int speedNum, int assetIndex, double budgetPercentage) {
    if (speedNum == 0) return 'forever';
    final balance = balances[numAccount][assetIndex].amount;
    final budget = balance * budgetPercentage / 100;
    final seconds = budget / speedNum;
    return secondsToSensibleTimePeriod(seconds.round());
  }

  Future addBid({
    required int assetIndex,
    required int speedNum,
    required double budgetPercentage,
    required int numAccount,
  }) async {
    log('AddBidPageViewModel - addBid');

    if (submitting) return;
    submitting = true;

    final asset = balances[numAccount][assetIndex];
    log('AddBidPageViewModel - addBid - !submitting - asset=$asset');

    final speedAssetId = asset.assetId;
    log('AddBidPageViewModel - addBid - speedAssetId=$speedAssetId');

    final publicAddress =
        await currentAlgorandService.accountPublicAddress(numAccount);
    log('AddBidPageViewModel - addBid - publicAddress=$publicAddress');
    if (publicAddress == null) throw NullThrownError();

    final budget = await currentAlgorandService.calcBudget(
        assetId: speedAssetId, numAccount: numAccount);
    log('AddBidPageViewModel - addBid - budget=$budget');
    if (budget == null) throw NullThrownError(); // TODO show user something
    final actualBudget = budget * budgetPercentage / 100;

    final speed = Speed(num: speedNum, assetId: speedAssetId);
    log('AddBidPageViewModel - addBid - speed=$speed');

    final HttpsCallable addBid = functions.httpsCallable('addBid');
    final args = {
      'B': user.id,
      'speed': speed.toMap(),
      'net': AlgorandNet.testnet
          .toString(), //net.toString(), // HARDCODED TO TESTNET FOR NOW
      'addrA': publicAddress,
      'budget': actualBudget,
    };
    log('AddBidPageViewModel - addBid=$addBid - args=$args');
    await addBid(args);
    log('addBid after');
  }
}
