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

  Future setMainAcccount(String address) =>
      storage.write('main_account', address);
  Future<AbstractAccount> getMainAccount() async {
    final mainAccountAddress = await storage.read('main_account');
    if (mainAccountAddress == null) {
      final allAccounts = await getAllAccounts();
      return allAccounts.first;
    }
    final foundAccount = await findAccount(mainAccountAddress);
    if (foundAccount == null) {
      final allAccounts = await getAllAccounts();
      return allAccounts.first;
    }
    return foundAccount;
  }

  Future<AssetHolding> getALGOBalance(
      {required String address, required AlgorandNet net}) async {
    final balance = await algorandLib.client[net]!.getBalance(address);
    return AssetHolding(
        amount: balance, assetId: 0, creator: '', isFrozen: false);
  }

  Future<AssetHolding?> getBalance(
      {required String address,
      required int assetId,
      required AlgorandNet net}) async {
    final balances = await getAssetHoldings(address: address, net: net);
    return balances
        .where((b) => b.assetId == assetId)
        .first; // better to use .only, but not implemented in dart
  }

  Future<List<AssetHolding>> getAssetHoldings(
      {required String address, required AlgorandNet net}) async {
    final balanceALGOFuture = algorandLib.client[net]!.getBalance(address);

    // final accountInfoFuture =
    //     algorandLib.client[net]!.getAccountByAddress(address);

    // final futureResults =
    //     await Future.wait([balanceALGOFuture, accountInfoFuture]);
    final futureResults = await Future.wait([balanceALGOFuture]);

    final balanceALGO = futureResults[0];

    // final assetHoldings = (futureResults[1] as AccountInformation).assets;

    final algoAssetHolding = AssetHolding(
        amount: balanceALGO, assetId: 0, creator: '', isFrozen: false);

    return [algoAssetHolding];
    // return [algoAssetHolding, ...assetHoldings];
  }

  Future<int> getNumLocalAccounts() async {
    final numAccountsString = await storage.read('num_accounts');
    final numAccounts =
        numAccountsString == null ? 0 : int.parse(numAccountsString);
    log('Number of Local Accounts ========= $numAccounts');
    return numAccounts;
  }

  int getNumWalletConnectAccounts() {
    log('getNumWalletConnectAccounts - WalletConnectAccount.cache=${WalletConnectAccount.cache}');
    return WalletConnectAccount.cache.length;
  }

  Future<int> getNumAccounts() async {
    final numLocalAccounts = await getNumLocalAccounts();
    final numWalletConnectAccounts = getNumWalletConnectAccounts();
    log('getNumAccounts - numLocalAccounts=$numLocalAccounts - numWalletConnectAccounts=$numWalletConnectAccounts');
    return numLocalAccounts + numWalletConnectAccounts;
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

  List<WalletConnectAccount> getAllWalletConnectAccounts() =>
      WalletConnectAccount.getAllAccounts();

  Future<List<AbstractAccount>> getAllAccounts() async {
    final localAccounts = await getAllLocalAccounts();
    final walletConnectAccounts = getAllWalletConnectAccounts();
    return [...localAccounts, ...walletConnectAccounts];
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

  Future<bool> isOptedInToDApp(
      {required String address,
      required int dAppId,
      required AlgorandNet net}) async {
    final accountInfo =
        await algorandLib.client[net]!.getAccountByAddress(address);
    for (final ApplicationLocalState localState in accountInfo.appsLocalState) {
      if (localState.id == dAppId) return true;
      // TODO do we need to maybe care about 'deleted' or 'closed-out-at-round'
    }
    return false;
  }
}

abstract class AbstractAccount {
  AbstractAccount({required this.accountService});
  final AccountService accountService;

  late String address;
  List<Balance> balances = [];

  Future setMainAccount() => accountService.setMainAcccount(address);

  Future<String> optInToDapp(
      {required int dappId,
      required AlgorandNet net,
      bool waitForConfirmation = false});
  Future<String> optInToASA(
      {required int assetId,
      required AlgorandNet net,
      waitForConfirmation = true});
  Future<List<Uint8List>> sign(List<RawTransaction> txns);

  int balanceALGO() {
    for (final b in balances) {
      if (b.assetHolding.assetId == 0) return b.assetHolding.amount;
    }
    throw Exception('balanceALGO - b.assetHolding.assetId == 0 not found');
  }

  int minBalance() {
    int asaCount = 0;
    for (final b in balances) {
      if (b.assetHolding.assetId != 0) asaCount++;
    }
    return 100000 * (1 + asaCount);
  }

  Future<void> updateBalances() async {
    log('updateBalances');
    // final mainnetAssetHoldings = await accountService.getAssetHoldings(
    //     address: address, net: AlgorandNet.mainnet);
    // final mainnetBalances = mainnetAssetHoldings
    //     .map((assetHolding) =>
    //         Balance(assetHolding: assetHolding, net: AlgorandNet.mainnet))
    //     .toList();
    final testnetAssetHoldings = await accountService.getAssetHoldings(
        address: address, net: AlgorandNet.testnet);
    final testnetBalances = testnetAssetHoldings
        .map((assetHolding) =>
            Balance(assetHolding: assetHolding, net: AlgorandNet.testnet))
        .toList();
    balances = testnetBalances;
  }

  Future<bool> isOptedInToASA(
          {required int assetId, required AlgorandNet net}) =>
      accountService.isOptedInToASA(
          address: address, assetId: assetId, net: net);
  Future<bool> isOptedInToDApp(
          {required int dAppId, required AlgorandNet net}) =>
      accountService.isOptedInToDApp(
          address: address, dAppId: dAppId, net: net);
}
