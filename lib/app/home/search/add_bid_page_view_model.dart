import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
    final balance = balances[numAccount - 1][assetIndex].amount;
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
    try {
      log('AddBidPageViewModel - addBid');

      // if (submitting) return;
      // submitting = true;
      AssetHolding? asset;
      List list = [];
      if(balances.length > numAccount){
        list = balances[numAccount];
      }else if(balances.length > (numAccount-1)){
        list = balances[numAccount-1];
      }
      if(list.length > assetIndex){
        asset = list[assetIndex];
      }else if(list.length > (assetIndex-1)){
        asset = list[assetIndex-1];
      }


      if(asset is AssetHolding) {
        final speedAssetId = asset.assetId;
        final publicAddress = await currentAlgorandService.accountPublicAddress(numAccount);

        if (publicAddress == null) throw NullThrownError();

        final budget = await currentAlgorandService.calcBudget(assetId: speedAssetId, numAccount: numAccount);

        if (budget == null) throw NullThrownError(); // TODO show user something
        final actualBudget = budget * budgetPercentage / 100;

        final speed = Speed(num: speedNum, assetId: speedAssetId);


        final HttpsCallable addBid = functions.httpsCallable('addBid');
        final args = {
          'B': user.id,
          'speed': speed.toMap(),
          'net': AlgorandNet.testnet
              .toString(), //net.toString(), // HARDCODED TO TESTNET FOR NOW
          'addrA': publicAddress,
          'budget': actualBudget,
        };
        await addBid(args);
      }
    } catch (e) {
      print(e);
    }
  }
}
