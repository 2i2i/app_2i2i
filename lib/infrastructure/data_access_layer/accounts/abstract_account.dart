import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';

import '../repository/algorand_service.dart';
import '../repository/secure_storage_service.dart';
import '../services/logging.dart';
import 'local_account.dart';
import 'walletconnect_account.dart';

class Balance {
  const Balance({required this.assetHolding, required this.net});

  final AssetHolding assetHolding;
  final AlgorandNet net;
}

class AccountService {
  AccountService({required this.algorandLib, required this.storage});

  final AlgorandLib algorandLib;
  final SecureStorage storage;

  Future setMainAccount(String address) => storage.write('main_account', address);

  /*Future<AbstractAccount?> getMainAccount() async {
    final mainAccountAddress = await storage.read('main_account');
    final allAccounts = await getAllAccounts();
    if (allAccounts.isNotEmpty) {
      if (mainAccountAddress == null) {
        return allAccounts.first;
      }
      final foundAccount = await findAccount(mainAccountAddress);
      if (foundAccount == null) {
        return allAccounts.first;
      }
      return foundAccount;
    }
    return null;
  }*/

  Future<int> getMinBalance({required String address, required AlgorandNet net}) async {
    try {
      final account = await algorandLib.client[net]!.getAccountByAddress(address);
      return account.minimumBalance?.toInt() ?? 0;
    } catch (e) {
      print(e);
    }
    return 0;
  }

  Future<AssetHolding> getALGOBalance({required String address, required AlgorandNet net}) async {
    int balance = 0;
    try {
      balance = await algorandLib.client[net]!.getBalance(address);
    } catch (e) {}

    return AssetHolding(amount: balance, assetId: 0, creator: '', isFrozen: false);
  }

  Future<AssetHolding?> getBalance({required String address, required int assetId, required AlgorandNet net}) async {
    final balances = await getAssetHoldings(address: address, net: net);
    return balances.where((b) => b.assetId == assetId).first; // better to use .only, but not implemented in dart
  }

  Future<List<AssetHolding>> getAssetHoldings({required String address, required AlgorandNet net}) async {
    int balanceALGO = 0;

    try {
      final balanceALGOFuture = algorandLib.client[net]!.getBalance(address);

      // final accountInfoFuture =
      //     algorandLib.client[net]!.getAccountByAddress(address);

      // final futureResults =
      //     await Future.wait([balanceALGOFuture, accountInfoFuture]);
      final futureResults = await Future.wait([balanceALGOFuture]);

      balanceALGO = futureResults[0];
    } catch (e) {}

    // final assetHoldings = (futureResults[1] as AccountInformation).assets;

    final algoAssetHolding = AssetHolding(amount: balanceALGO, assetId: 0, creator: '', isFrozen: false);

    return [algoAssetHolding];
    // return [algoAssetHolding, ...assetHoldings];
  }

  Future<int> getNumLocalAccounts() async {
    log('getNumLocalAccounts');
    final numAccountsString = await storage.read('num_accounts');
    log('getNumLocalAccounts numAccountsString=$numAccountsString');
    final numAccounts = numAccountsString == null ? 0 : int.parse(numAccountsString);
    log('getNumLocalAccounts numAccounts=$numAccounts');
    return numAccounts;
  }

  Future<int> getNumWalletConnectAccounts() async {
    String val = await storage.read('wallet_connect_accounts') ?? '';
    return int.tryParse(val) ?? 0;
  }

  Future<int> getNumAccounts() async {
    final numLocalAccounts = await getNumLocalAccounts();
    final numWalletConnectAccounts = await getNumWalletConnectAccounts();
    log('getNumAccounts - numLocalAccounts=$numLocalAccounts - numWalletConnectAccounts=$numWalletConnectAccounts');
    return numLocalAccounts + numWalletConnectAccounts;
  }

  /*Future<AbstractAccount?> findAccount(String address) async {
    final accounts = await getAllAccounts();
    for (final account in accounts) {
      if (account.address == address) return account;
    }
    return null;
  }*/

  Future<List<LocalAccount>> getAllLocalAccounts() async {
    log('AccountService getAllLocalAccounts');
    final int numAccounts = await getNumLocalAccounts();
    log('AccountService numAccounts=$numAccounts');
    final List<Future<LocalAccount>> futures = [];
    for (var i = 0; i < numAccounts; i++) {
      log('AccountService i=$i');
      final accountFuture = LocalAccount.fromNumAccount(numAccount: i, algorandLib: algorandLib, storage: storage, accountService: this);
      futures.add(accountFuture);
    }
    log('AccountService done');
    return Future.wait(futures);
  }

  Future<List<String>> getAllWalletConnectAccounts() async {
    String? val = await storage.read('wallet_connect_accounts');
    if (val != null) {
      return val.split(',');
    }
    return [];
  }

  Future<Map<String, List<String>>> getAllWalletAddress() async {
    Map<String, List<String>> map = {};
    List<String> val = await getAllWalletConnectAccounts();
    for (String id in val) {
      var connector = await WalletConnectAccount.newConnector(id);
      map[id] = connector.session.accounts;
      // addresses.addAll(connector.session.accounts);
    }
    return map;
  }

  // WalletConnectAccount.getAllAccounts();

  /*Future<List<AbstractAccount>> getAllAccounts() async {
    log('AccountService getAllAccounts');
    final localAccounts = await getAllLocalAccounts();
    final walletConnectAccounts = getAllWalletConnectAccounts();
    return [...localAccounts, ...walletConnectAccounts];
  }*/

  Future<bool> isOptedInToASA({required String address, required int assetId, required AlgorandNet net}) async {
    if (assetId == 0) return true; // all accounts can use ALGO

    List<AssetHolding> assetHoldings = [];
    try {
      final accountInfo = await algorandLib.client[net]!.getAccountByAddress(address);
      assetHoldings = accountInfo.assets;
    } catch (e) {
      return false;
    }

    return assetHoldings.map((a) => a.assetId).contains(assetId);
  }

  Future<bool> isOptedInToDApp({required String address, required int dAppId, required AlgorandNet net}) async {
    try {
      final accountInfo = await algorandLib.client[net]!.getAccountByAddress(address);
      for (final ApplicationLocalState localState in accountInfo.appsLocalState) {
        if (localState.id == dAppId) return true;
        // TODO do we need to maybe care about 'deleted' or 'closed-out-at-round'
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

abstract class AbstractAccount {
  AbstractAccount({required this.accountService});

  final AccountService accountService;

  String address = '';
  List<Balance> balances = [];

  Future setMainAccount() => accountService.setMainAccount(address);

  Future<String> optInToDapp({required int dappId, required AlgorandNet net, bool waitForConfirmation = false});

  Future<String> optInToASA({required int assetId, required AlgorandNet net, waitForConfirmation = true});

  Future<List<Uint8List>> sign(List<RawTransaction> txns);

  int balanceALGO() {
    for (final b in balances) {
      if (b.assetHolding.assetId == 0) return b.assetHolding.amount;
    }
    throw Exception('balanceALGO - b.assetHolding.assetId == 0 not found');
  }

  Future<int> minBalance({required AlgorandNet net}) => accountService.getMinBalance(address: address, net: net);

  Future<void> updateBalances({required AlgorandNet net}) async {
    log('updateBalances');
    final assetHoldings = await accountService.getAssetHoldings(address: address, net: net);
    balances = assetHoldings.map((assetHolding) => Balance(assetHolding: assetHolding, net: net)).toList();
  }

  Future<bool> isOptedInToASA({required int assetId, required AlgorandNet net}) => accountService.isOptedInToASA(address: address, assetId: assetId, net: net);

  Future<bool> isOptedInToDApp({required int dAppId, required AlgorandNet net}) => accountService.isOptedInToDApp(address: address, dAppId: dAppId, net: net);
}
