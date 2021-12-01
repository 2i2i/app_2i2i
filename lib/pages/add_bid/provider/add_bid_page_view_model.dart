import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AddBidPageViewModel {
  AddBidPageViewModel({
    required this.functions,
    required this.algorand,
    required this.user,
    required accounts,
    required this.accountService,
  }) {
    _accounts = accounts;
  }
  final FirebaseFunctions functions;
  final UserModel user;
  final AlgorandService algorand;
  final AccountService accountService;
  late List<AbstractAccount> _accounts;

  List<AbstractAccount> get accounts =>
      _accounts.where((a) => nonZeroBalances(a).isNotEmpty).toList();

  bool submitting = false;

  List<Balance> nonZeroBalances(AbstractAccount account) =>
      account.balances.where((b) => 0 < b.assetHolding.amount).toList();

  String duration(AbstractAccount account, int speedNum, Balance balance,
      double budgetPercentage) {
    if (speedNum == 0) return 'forever';
    final budget = balance.assetHolding.amount * budgetPercentage / 100;
    final seconds = budget / speedNum;
    return secondsToSensibleTimePeriod(seconds.round());
  }

  Future addBid({
    required AbstractAccount? account,
    required Balance? balance,
    required int speedNum,
    required double budgetPercentage,
  }) async {
    log('AddBidPageViewModel - addBid');

    final int speedAssetId = speedNum == 0 ? 0 : balance!.assetHolding.assetId;
    log('AddBidPageViewModel - addBid - speedAssetId=$speedAssetId');

    final budget = speedNum == 0
        ? 0
        : await accountService.calcBudget(
            assetId: speedAssetId, account: account!, net: balance!.net);
    log('AddBidPageViewModel - addBid - budget=$budget');
    final actualBudget = (budget * budgetPercentage / 100).floor();

    final speed = Speed(num: speedNum, assetId: speedAssetId);

    final HttpsCallable addBid = functions.httpsCallable('addBid');
    final args = {
      'B': user.id,
      'speed': speed.toMap(),
      'net': AlgorandNet.testnet
          .toString(), //net.toString(), // HARDCODED TO TESTNET FOR NOW
      'addrA': account?.address,
      'budget': actualBudget,
    };
    await addBid(args);
  }
}
