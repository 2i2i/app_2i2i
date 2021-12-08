import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  String duration(AbstractAccount account, int speedNum, Balance balance, double budgetPercentage) {
    if (speedNum == 0) {
      return 'forever';
    }
    final budget = balance.assetHolding.amount * budgetPercentage / 100;
    final seconds = budget / speedNum;
    return secondsToSensibleTimePeriod(seconds.round());
  }

  Future addBid({
    // required FireBaseMessagingService fireBaseMessaging,
    required AbstractAccount? account,
    required Balance? balance,
    required int speedNum,
    required double budgetPercentage,
  }) async {
    log('AddBidPageViewModel - addBid');

    final int speedAssetId = speedNum == 0 ? 0 : balance!.assetHolding.assetId;
    log('AddBidPageViewModel - addBid - speedAssetId=$speedAssetId');

    final budget = speedNum == 0 ? 0 : await accountService.calcBudget(assetId: speedAssetId, account: account!, net: balance!.net);
    log('AddBidPageViewModel - addBid - budget=$budget');
    final actualBudget = (budget * budgetPercentage / 100).floor();

    final speed = Speed(num: speedNum, assetId: speedAssetId);

    final HttpsCallable addBid = functions.httpsCallable('addBid');
    // fireBaseMessaging.sendNotification(user.deviceToken!, "Test", "Text body", "routeName");
    final args = {
      'B': user.id,
      'speed': speed.toMap(),
      'net': AlgorandNet.testnet.toString(),
      'addrA': account?.address,
      'budget': actualBudget,
    };
    await addBid(args);
  }
}
