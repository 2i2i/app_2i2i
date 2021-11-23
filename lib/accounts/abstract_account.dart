import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/services/algorand_service.dart';
import 'package:app_2i2i/app/logging.dart';
import 'package:app_2i2i/services/secure_storage_service.dart';

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
    final localAccounts = <LocalAccount>[];
    for (var i = 0; i < numAccounts; i++) {
      final account = LocalAccount.fromNumAccount(
          numAccount: i,
          algorandLib: algorandLib,
          storage: storage,
          accountService: this);
      localAccounts.add(account);
    }
    return localAccounts;
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
}

class LocalAccount extends AbstractAccount {
  LocalAccount.create({
    required this.algorandLib,
    required this.storage,
    required this.accountService,
  }) {
    log('LocalAccount.create');
    _createAndStoreAccount();
    log('LocalAccount.create - _createAndStoreAccount');
    updateBalanaces();
    log('LocalAccount.create - updateBalanaces');
  }

  LocalAccount.fromNumAccount({
    required int numAccount,
    required this.algorandLib,
    required this.storage,
    required this.accountService,
  }) {
    _loadAccountFromStorage(numAccount);
    updateBalanaces();
  }

  Future<bool> isOptedInToASA(
      {required int assetId, required AlgorandNet net}) async {
    if (assetId == 0) return true; // all accounts can use ALGO
    return _balances
        .where((balance) => balance.net == net)
        .map((balance) => balance.assetHolding.assetId)
        .contains(assetId);
  }

  Future<Uint8List> sign(RawTransaction txn) async {
    final account = await _libAccount();
    final txnSigned = await txn.sign(account);
    return txnSigned.toBytes();
  }

  Future<String> optInToASA(
      {required int assetId,
      required AlgorandNet net,
      waitForConfirmation = true}) async {
    final account = await _libAccount();
    final String txId = await algorandLib.client[net]!.assetManager.optIn(
      account: account,
      assetId: assetId,
    );
    if (waitForConfirmation)
      await algorandLib.client[net]!.waitForConfirmation(txId);
    return txId;
  }

  Future<String> optInToDapp(
      {required int dappId,
      required AlgorandNet net,
      bool waitForConfirmation = false}) async {
    final account = await _libAccount();
    final String txId = await algorandLib.client[net]!.applicationManager.optIn(
      account: account,
      applicationId: dappId,
    );
    if (waitForConfirmation)
      await algorandLib.client[net]!.waitForConfirmation(txId);
    return txId;
  }

  Future<Account> _libAccount() async {
    final privateKey = await storage.read('account_$_numAccount');
    final Uint8List seed = base64Decode(privateKey!);
    return algorandLib.client[AlgorandNet.mainnet]!
        .loadAccountFromSeed(seed); // mainnet as it does not matter
  }

  Future _loadAccountFromStorage(int numAccount) async {
    _numAccount = numAccount;
    final account = await _libAccount();
    _address = account.publicAddress;
  }

  Future _createAndStoreAccount() async {
    log('LocalAccount - _createAndStoreAccount');
    final Account account = await algorandLib.client[AlgorandNet.mainnet]!
        .createAccount(); // use mainnet bc it does not matter
    log('LocalAccount - _createAndStoreAccount - createAccount');
    final List<int> privateKeyBytes =
        await account.keyPair.extractPrivateKeyBytes();
    log('LocalAccount - _createAndStoreAccount - privateKeyBytes');
    final String privateKey = base64Encode(privateKeyBytes);
    log('LocalAccount - _createAndStoreAccount - privateKey');

    // set
    _numAccount = await accountService.getNumLocalAccounts();
    log('LocalAccount - _createAndStoreAccount - _numAccount=$_numAccount');
    _address = account.publicAddress;
    log('LocalAccount - _createAndStoreAccount - _address=$_address');

    final storageAccountKey = 'account_$_numAccount';
    log('LocalAccount - _createAndStoreAccount - storageAccountKey=$storageAccountKey');
    final newNumAccounts = _numAccount + 1;
    log('LocalAccount - _createAndStoreAccount - newNumAccounts=$newNumAccounts');
    await storage.write('num_accounts', newNumAccounts.toString());
    log('LocalAccount - _createAndStoreAccount - storage.write');
    await storage.write(storageAccountKey, privateKey);
    log('LocalAccount - _createAndStoreAccount - done');
  }

  late int _numAccount;
  final AlgorandLib algorandLib;
  final SecureStorage storage;
  final AccountService accountService;

  late String _address;
  String get address => _address;

  late List<Balance> _balances;
  List<Balance> get balances => _balances;

  void updateBalanaces() async {
    log('LocalAccount - updateBalanaces');
    final mainnetAssetHoldings =
        await _getAssetHoldings(address: _address, net: AlgorandNet.mainnet);
    log('LocalAccount - updateBalanaces - mainnetAssetHoldings.length=${mainnetAssetHoldings.length}');
    final mainnetBalances = mainnetAssetHoldings
        .map((assetHolding) =>
            Balance(assetHolding: assetHolding, net: AlgorandNet.mainnet))
        .toList();
    final testnetAssetHoldings =
        await _getAssetHoldings(address: _address, net: AlgorandNet.testnet);
    log('LocalAccount - updateBalanaces - testnetAssetHoldings.length=${testnetAssetHoldings.length}');
    final testnetBalances = testnetAssetHoldings
        .map((assetHolding) =>
            Balance(assetHolding: assetHolding, net: AlgorandNet.testnet))
        .toList();
    _balances = [...mainnetBalances, ...testnetBalances];
  }

  Future<List<AssetHolding>> _getAssetHoldings(
      {required String address, required AlgorandNet net}) async {
    log('LocalAccount - _getAssetHoldings - address=$address - net=$net');
    final balanceALGOFuture = algorandLib.client[net]!.getBalance(address);
    log('LocalAccount - _getAssetHoldings - balanceALGOFuture=$balanceALGOFuture');
    final accountInfoFuture =
        algorandLib.client[net]!.getAccountByAddress(address);
    log('LocalAccount - _getAssetHoldings - accountInfoFuture=$accountInfoFuture');
    final futureResults =
        await Future.wait([balanceALGOFuture, accountInfoFuture]);
    final balanceALGO = futureResults[0] as int;
    log('LocalAccount - _getAssetHoldings - balanceALGO=$balanceALGO');
    final assetHoldings = (futureResults[1] as AccountInformation).assets;
    log('LocalAccount - _getAssetHoldings - assetHoldings=$assetHoldings');

    final algoAssetHolding = AssetHolding(
        amount: balanceALGO, assetId: 0, creator: '', isFrozen: false);
    log('LocalAccount - _getAssetHoldings - algoAssetHolding=$algoAssetHolding');

    return [algoAssetHolding, ...assetHoldings];
  }
}
