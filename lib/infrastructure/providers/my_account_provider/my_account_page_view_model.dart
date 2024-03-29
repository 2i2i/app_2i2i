import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_database.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

import '../../data_access_layer/accounts/abstract_account.dart';
import '../../data_access_layer/accounts/walletconnect_account.dart';
import '../../data_access_layer/repository/algorand_service.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../all_providers.dart';

class MyAccountPageViewModel extends ChangeNotifier {
  var ref;

  MyAccountPageViewModel({required this.ref, required this.uid, required this.database});

  AlgorandLib? algorandLib;
  SecureStorage? storage;
  AccountService? accountService;
  bool isLoading = true;

  FXModel? FXValue;

  // List<AbstractAccount>? accounts;
  Map<String, List<String>> walletConnectAccounts = {};

  String? uid;
  FirestoreDatabase database;

  int selectedAccountIndex = 0;

  List<Tuple2<String, Balance>> addressWithASABalance = [];

  void setSelectedIndexValue(int index) {
    selectedAccountIndex = index;
    notifyListeners();
  }

  Future<void> initMethod() async {
    try {
      print("get list method");
      algorandLib = await ref!.watch(algorandLibProvider);
      storage = await ref!.watch(storageProvider);
      accountService = await ref!.watch(accountServiceProvider);
      // accounts = await accountService!.getAllAccounts();
      walletConnectAccounts = await accountService!.getAllWalletAddress();
      addressWithASABalance = await addressBalanceCombos;
      isLoading = false;
    } catch (e) {
      log("$e");
    }
    notifyListeners();
  }

  Future<FXModel?> getFXValue(int assetId) async {
    log('getFX assetId=$assetId');

    if (assetId == 0) {
      return FXModel.ALGO();
    }
    return await getFX(assetId);
  }

  Future<void> getWalletAccount() async {
    walletConnectAccounts = await accountService!.getAllWalletAddress();
    notifyListeners();
  }

  Future<List<Balance>> getBalancesFromAddress(String address) async {
    log(Y + 'getBalanceFromAddress address=$address accountService=$accountService');
    // if (accountService != null) {
    final assetHoldings = await accountService!.getAssetHoldings(address: address, net: AppConfig().ALGORAND_NET);
    final balances = assetHoldings.map((assetHolding) => Balance(assetHolding: assetHolding, net: AppConfig().ALGORAND_NET)).toList();
    return balances;
    // }
    // return [];
  }

  Future<Balance> getBalanceFromAddressAndAssetId(String address, int assetId) async {
    log(Y + 'getBalanceFromAddressAndAssetId address=$address assetId=$assetId accountService=$accountService');
    final balances = await getBalancesFromAddress(address);
    for (final b in balances) {
      if (b.assetHolding.assetId == assetId) {
        return b;
      }
    }
    throw "getBalanceFromAddressAndAssetId - error - address=$address assetId=$assetId";
  }

  Future<int> getMinBalance({required String address}) => accountService!.getMinBalance(address: address, net: AppConfig().ALGORAND_NET);

  Future<int> getAlgoBalance({required String address}) async {
    final assetHolding = await accountService!.getALGOBalance(address: address, net: AppConfig().ALGORAND_NET);
    return assetHolding.amount;
  }

  Future<int> getAlgoBalanceFromAsaList({required String address}) async {
    // try {
    for (final b in addressWithASABalance) {
      if (b.item1 == address && b.item2.assetHolding.assetId == 0) return b.item2.assetHolding.amount;
    }
    throw "getAlgoBalance - ALGO balance not found - should never happen - address=$address";
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
    // return 0;
  }

  Future<List<Tuple2<String, Balance>>> get addressBalanceCombos async {
    List<Tuple2<String, Balance>> values = [];
    for (List<String> addressList in walletConnectAccounts.values) {
      for (final address in addressList) {
        final balanceList = await getBalancesFromAddress(address);
        for (final balance in balanceList) {
          final t = Tuple2<String, Balance>(address, balance);
          values.add(t);
        }
      }
    }
    addressWithASABalance = values;
    return values;
  }

  String getSessionId(String address) {
    var list = walletConnectAccounts.entries.toList();
    for (MapEntry<String, List<String>> val in list) {
      if (val.value.contains(address)) {
        return val.key;
      }
    }
    return '';
  }

  Future disconnectAccount(String address) async {
    String sessionId = getSessionId(address);
    print('removed session $sessionId');
    var connector = await WalletConnectAccount.newConnector(sessionId);

    connector.killSession();
    List<String> accounts = await accountService?.getAllWalletConnectAccounts() ?? [];
    accounts.remove(sessionId);
    await storage?.write(WalletConnectAccount.STORAGE_KEY, accounts.join(','));
    // storage?.remove(WalletConnectAccount.STORAGE_KEY);
    await initMethod();
    notifyListeners();
  }

  Future updateDBWithNewAccount(String address, {String userId = '', String type = 'LOCAL'}) => database.addAlgorandAccount(uid ?? userId, address, type);

  Future<void> updateAccounts({bool notify = true}) async {
    await accountService?.getNumAccounts();
    if (notify) notifyListeners();
  }

  Future<FXModel?> getFX(int assetId) async {
    // log(Y + 'getFX assetId=$assetId');
    if (assetId == 0) return FXModel.ALGO();
    return database.getFX(assetId);
  }
}
