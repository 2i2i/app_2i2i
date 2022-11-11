import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:algorand_dart/algorand_dart.dart';
import '../repository/algorand_service.dart';
import '../repository/secure_storage_service.dart';
import '../services/logging.dart';
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
    log('getAssetHoldings address=$address net=$net');

    // int balanceALGO = 0;

    try {
      final balanceALGOFuture = algorandLib.client[net]!.getBalance(address);

      final accountInfoFuture =
          algorandLib.client[net]!.getAccountByAddress(address);

      final futureResults =
          await Future.wait([balanceALGOFuture, accountInfoFuture]);
      // final futureResults = await Future.wait([balanceALGOFuture]);

      final balanceALGO = futureResults[0] as int;


    final assetHoldings = (futureResults[1] as AccountInformation).assets;

    log('assetHoldings=$assetHoldings');

    final algoAssetHolding = AssetHolding(amount: balanceALGO, assetId: 0, creator: '', isFrozen: false);

    // return [algoAssetHolding];
    return [algoAssetHolding, ...assetHoldings]; // ALGO always first
    } on AlgorandException catch (ex) {
      final cause = ex.cause;
      if (cause is dio.DioError) {
        log(FX + 'AlgorandException ' + cause.response?.data['message']);
      }
      // throw ex;
      return [AssetHolding(amount: 0, assetId: 0, creator: '', isFrozen: false)];
    } on Exception catch (ex) {
      log(FX + 'Exception ' + ex.toString());
      throw ex;
    }
  }

  Future<int> getNumWalletConnectAccounts() async {
    String val = await storage.read(WalletConnectAccount.STORAGE_KEY) ?? '';
    return int.tryParse(val) ?? 0;
  }

  Future<int> getNumAccounts() async {
    final numWalletConnectAccounts = await getNumWalletConnectAccounts();
    log('getNumAccounts - numWalletConnectAccounts=$numWalletConnectAccounts');
    return numWalletConnectAccounts;
  }

  /*Future<AbstractAccount?> findAccount(String address) async {
    final accounts = await getAllAccounts();
    for (final account in accounts) {
      if (account.address == address) return account;
    }
    return null;
  }*/

  Future<List<String>> getAllWalletConnectAccounts() async {
    String? val = await storage.read(WalletConnectAccount.STORAGE_KEY);
    return val == null ? [] : val.split(',');
  }

  Future<Map<String, List<String>>> getAllWalletAddress() async {
    Map<String, List<String>> map = {};
    List<String> val = await getAllWalletConnectAccounts();
    log(K + ' session ids $val');
    for (String id in val) {
      final connector = await WalletConnectAccount.newConnector(id);
      // print('connector.connected ${connector.connected}');
      // print('connector.session.accounts ${connector.session.accounts}');
      map[id] = connector.session.accounts;
      // addresses.addAll(connector.session.accounts);
    }
    return map;
  }

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
