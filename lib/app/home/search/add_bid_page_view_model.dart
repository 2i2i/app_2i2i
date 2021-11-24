import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/app/logging.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
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

  bool submitting = false;

  String duration(AbstractAccount account, int speedNum, Balance balance,
      double budgetPercentage) {
    if (speedNum == 0) return 'forever';
    final budget = balance.assetHolding.amount * budgetPercentage / 100;
    final seconds = budget / speedNum;
    return secondsToSensibleTimePeriod(seconds.round());
  }

  Future addBid({
    required AbstractAccount account,
    required Balance balance,
    required int speedNum,
    required double budgetPercentage,
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

    final int speedAssetId = balance.assetHolding.assetId;
    log('AddBidPageViewModel - addBid - speedAssetId=$speedAssetId');

    final publicAddress = account.address;
    final budget = await accountService.calcBudget(
        assetId: speedAssetId, account: account, net: balance.net);
    log('AddBidPageViewModel - addBid - budget=$budget');
    if (budget == null) throw NullThrownError(); // TODO show user something
    final actualBudget = (budget * budgetPercentage / 100).floor();

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
