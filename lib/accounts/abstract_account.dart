import 'dart:math';
import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';

import 'local_account.dart';

class Balance {
  const Balance({required this.assetHolding, required this.net});
  final AssetHolding assetHolding;
  final AlgorandNet net;
}

class AccountService {
  AccountService({required this.algorandLib, required this.storage});
  final AlgorandLib algorandLib;
  final SecureStorage storage;

  Future<int> getNumLocalAccounts() async {
    final numAccountsString = await storage.read('num_accounts');
    final numAccounts =
        numAccountsString == null ? 0 : int.parse(numAccountsString);
    return numAccounts;
  }

  Future<int> getNumAccounts() {
    return getNumLocalAccounts();
  }

  Future<AbstractAccount?> findAccount(String address) async {
    final accounts = await getAllAccounts();
    for (final account in accounts) {
      if (account.address == address) return account;
    }
    return null;
  }

  Future<List<LocalAccount>> getAllLocalAccounts() async {
    final int numAccounts = await getNumLocalAccounts();
    final List<Future<LocalAccount>> futures = [];
    for (var i = 0; i < numAccounts; i++) {
      final accountFuture = LocalAccount.fromNumAccount(
          numAccount: i,
          algorandLib: algorandLib,
          storage: storage,
          accountService: this);
      futures.add(accountFuture);
    }
    return Future.wait(futures);
  }

  Future<List<AbstractAccount>> getAllAccounts() {
    return getAllLocalAccounts();
  }

  Future<Balance?> extractBalance(
      List<Balance> balances, int assetId, AlgorandNet net) async {
    for (final balance in balances) {
      if (balance.assetHolding.assetId == assetId && balance.net == net)
        return balance;
    }
    return null;
  }

  Future<int?> calcBudget(
      {required int assetId,
      required AbstractAccount account,
      required AlgorandNet net}) async {
    final balances = account.balances;
    final balance = await extractBalance(balances, assetId, net);
    if (balance == null) return null;

    final feesForApp = assetId == 0 ? AlgorandService.LOCK_ALGO_FEE : 0;

    final feeForAlgorand = assetId == 0
        ? 2 * AlgorandService.MIN_TXN_FEE
        : 0; // 2 txns to lock ALGO

    final numAssets = balances.where((balance) => balance.net == net).length;

    final minBalance = assetId == 0
        ? AlgorandService.MIN_BALANCE_FOR_SYSTEM +
            numAssets * AlgorandService.MIN_ASA_BALANCE
        : 0;

    final budget =
        balance.assetHolding.amount - feesForApp - feeForAlgorand - minBalance;

    return max(budget, 0);
  }

  Future<bool> isOptedInToASA(
      {required String address,
      required int assetId,
      required AlgorandNet net}) async {
    if (assetId == 0) return true; // all accounts can use ALGO
    final accountInfo =
        await algorandLib.client[net]!.getAccountByAddress(address);
    final assetHoldings = accountInfo.assets;
    return assetHoldings.map((a) => a.assetId).contains(assetId);
  }
}

abstract class AbstractAccount {
  String get address;
  List<Balance> get balances;

  Future<String> optInToDapp(
      {required int dappId,
      required AlgorandNet net,
      bool waitForConfirmation = false});

  Future<String> optInToASA(
      {required int assetId,
      required AlgorandNet net,
      waitForConfirmation = true});

  Future<bool> isOptedInToASA({required int assetId, required AlgorandNet net});
  Future<Uint8List> sign(RawTransaction txn);

  Future updateBalances();
}
