import 'package:dio/dio.dart' as dio;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/app/home/models/meeting.dart';
import 'package:app_2i2i/services/secure_storage_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:app_2i2i/app/logging.dart';

enum AlgorandNet { mainnet, testnet, betanet }

class AlgorandService {
  static const Map<AlgorandNet, String> API_URL = {
    AlgorandNet.mainnet: AlgoExplorer.MAINNET_ALGOD_API_URL,
    AlgorandNet.testnet: AlgoExplorer.TESTNET_ALGOD_API_URL,
    AlgorandNet.betanet: AlgoExplorer.BETANET_ALGOD_API_URL,
  };
  static const Map<AlgorandNet, int> SYSTEM_ID = {
    AlgorandNet.mainnet: -1,
    AlgorandNet.testnet: 32969536,
    AlgorandNet.betanet: 419713242,
  };
  static const Map<AlgorandNet, String> SYSTEM_ACCOUNT = {
    AlgorandNet.mainnet: '',
    AlgorandNet.testnet:
        'WUTGDFVYFLD7VMPDWOO2KOU2YCKIL4OSY43XSV4SBSDIXCRXIPOHUBBLOI',
    AlgorandNet.betanet:
        'Y3VM46DMHVME77SI3XEI2KIDJSDZQKSMOSGT55I5YO6UDPKDKUBHYY56AM',
  };
  static const Map<AlgorandNet, String> CREATOR = {
    AlgorandNet.mainnet: '',
    AlgorandNet.testnet:
        'KTNEHVYFHJIWSTWZ7SQJSSA24JHTX3KXUABO64ZQTRCBFIM3EMCXVMBD6M',
    AlgorandNet.betanet:
        'KTNEHVYFHJIWSTWZ7SQJSSA24JHTX3KXUABO64ZQTRCBFIM3EMCXVMBD6M',
  };
  static const Map<AlgorandNet, int> NOVALUE_ASSET_ID = {
    AlgorandNet.mainnet: -1,
    AlgorandNet.testnet: 29147319,
    AlgorandNet.betanet: 430512768,
  };
  // static const String STORAGE_ACCOUNT_KEY = 'account_1';
  static const int MIN_TXN_FEE = 1000;
  static const int MIN_ASA_BALANCE = 100000;
  static const int LOCK_ALGO_FEE = 4 * MIN_TXN_FEE;
  static const int LOCK_ASA_FEE = 5 * MIN_TXN_FEE;
  static const int MIN_BALANCE_FOR_SYSTEM = 3 * MIN_ASA_BALANCE;
  static const int OPT_IN_SYSTEM_TO_ASA_FEE = 2 * MIN_ASA_BALANCE + MIN_TXN_FEE;

  AlgorandService(
      {required this.net, required this.storage, required this.functions}) {
    algorandLib = Algorand(algodClient: AlgodClient(apiUrl: API_URL[net]!));
  }
  final AlgorandNet net;
  late final Algorand algorandLib;
  final FirebaseFunctions functions;
  final SecureStorage storage;

  Future<List<AssetHolding>> getAssetHoldings(String publicAddress) async {
    // log('AlgorandService - getAssetHoldings - publicAddress=$publicAddress');

    final balanceALGOFuture = algorandLib.getBalance(publicAddress);
    final accountInfoFuture = algorandLib.getAccountByAddress(publicAddress);
    final futureResults =
        await Future.wait([balanceALGOFuture, accountInfoFuture]);
    final balanceALGO = futureResults[0] as int;
    // log('AlgorandService - getAssetHoldings - balanceALGO=$balanceALGO');
    final assetHoldings = (futureResults[1] as AccountInformation).assets;
    // log('AlgorandService - getAssetHoldings - assetHoldings=$assetHoldings');

    final algoAssetHolding = AssetHolding(
        amount: balanceALGO, assetId: 0, creator: '', isFrozen: false);

    return [algoAssetHolding, ...assetHoldings];
  }

  Future<int?> extractBalance(
      List<AssetHolding> assetHoldings, int assetId) async {
    for (final assetHolding in assetHoldings) {
      if (assetHolding.assetId == assetId) return assetHolding.amount;
    }
  }

  // this is complicated -- ideally need method in algorand lib
  // maybe approximate for now and fail if budget too high
  Future<int?> calcBudget({int assetId = 0, required int numAccount}) async {
    log('AlgorandService - calcBudget - net=$net - assetId=$assetId');

    final publicAddress = await accountPublicAddress(numAccount);
    if (publicAddress == null) return null;
    final assetHoldings = await getAssetHoldings(publicAddress);
    final balance = await extractBalance(assetHoldings, assetId);
    if (balance == null) return null;

    final feesForApp = assetId == 0 ? LOCK_ALGO_FEE : 0;
    log('AlgorandService - calcBudget - assetId=$assetId - net=$net - feesForApp=$feesForApp');

    final feeForAlgorand =
        assetId == 0 ? 2 * MIN_TXN_FEE : 0; // 2 txns to lock ALGO
    log('AlgorandService - calcBudget - assetId=$assetId - net=$net - feeForAlgorand=$feeForAlgorand');

    final minBalance = assetId == 0
        ? MIN_BALANCE_FOR_SYSTEM + assetHoldings.length * MIN_ASA_BALANCE
        : 0;
    log('AlgorandService - calcBudget - assetId=$assetId - net=$net - minBalance=$minBalance');

    final budget = balance - feesForApp - feeForAlgorand - minBalance;
    log('AlgorandService - calcBudget - assetId=$assetId - net=$net - balance=$balance - budget=$budget');
    return max(budget, 0);
  }

  Future<Account> createAccount() {
    log('AlgorandService - createAccount');
    return algorandLib.createAccount();
  }

  Future<int> getNumAccounts() async {
    log('AlgorandService - getNumAccounts');
    final numAccountsString = await storage.read('num_accounts');
    log('AlgorandService - getNumAccounts - numAccountsString=$numAccountsString');
    final numAccounts =
        numAccountsString == null ? 0 : int.parse(numAccountsString);
    log('AlgorandService - getNumAccounts - numAccounts=$numAccounts');
    return numAccounts;
  }

  // TODO change for multiple accounts
  Future<String> saveAccountLocally(Account account) async {
    log('AlgorandService - saveAccountLocally - account=${account.publicAddress}');
    final List<int> privateKeyBytes =
        await account.keyPair.extractPrivateKeyBytes();
    log('AlgorandService - saveAccountLocally - extractPrivateKeyBytes');
    final String privateKey = base64Encode(privateKeyBytes);

    // how many accounts do we already have?
    final numAccounts = await getNumAccounts();
    final newAccountString = (numAccounts + 1).toString();
    final storageAccountKey = 'account_$newAccountString';

    await storage.write('num_accounts', newAccountString);
    await storage.write(storageAccountKey, privateKey);
    // final save3 = storage.write('main_account', '1');
    log('AlgorandService - saveAccountLocally - done');
    return storageAccountKey;
  }

  Future<String> giftALGO(String accountPublicAddress,
      {waitForConfirmation = true}) async {
    log('AlgorandService - giftALGO - account=$accountPublicAddress - waitForConfirmation=$waitForConfirmation');
    final giftALGO = functions.httpsCallable('giftALGO');
    final result = await giftALGO({'account': accountPublicAddress});
    log('AlgorandService - giftALGO - result=$result');
    final String txId = result.data;
    if (waitForConfirmation) await algorandLib.waitForConfirmation(txId);
    log('AlgorandService - giftALGO - done - txId=$txId');
    return txId;
  }

  Future<String> giftASA(String accountPublicAddress,
      {waitForConfirmation = true}) async {
    log('AlgorandService - giftASA - account=$accountPublicAddress - waitForConfirmation=$waitForConfirmation');
    final giftASA = functions.httpsCallable('giftASA');
    final result = await giftASA({'account': accountPublicAddress});
    log('AlgorandService - giftASA - result=$result');
    final String txId = result.data;
    if (waitForConfirmation) await algorandLib.waitForConfirmation(txId);
    log('AlgorandService - giftASA - done - txId=$txId');
    return txId;
  }

  Future<String> optInToApp(
      {required Account account,
      required int appId,
      waitForConfirmation = true}) async {
    log('AlgorandService - optInToApp - account=${account.publicAddress} - appId=$appId');
    final String txId = await algorandLib.applicationManager.optIn(
      account: account,
      applicationId: appId,
    );
    log('AlgorandService - optInToApp - txId=$txId');
    if (waitForConfirmation) await algorandLib.waitForConfirmation(txId);
    log('AlgorandService - optInToApp - done');
    return txId;
  }

  Future<String> optInUserAccountToASA(
      {required int assetId,
      required int numAccount,
      waitForConfirmation = true}) async {
    final account = await getAccount(numAccount);
    return optInToASA(
        account: account!,
        assetId: assetId,
        waitForConfirmation: waitForConfirmation);
  }

  Future<String> optInToASA(
      {required Account account,
      required int assetId,
      waitForConfirmation = true}) async {
    log('AlgorandService - optInToASA - account=${account.publicAddress} - assetId=$assetId');
    final String txId = await algorandLib.assetManager.optIn(
      account: account,
      assetId: assetId,
    );
    log('AlgorandService - optInToASA - txId=$txId');
    if (waitForConfirmation) await algorandLib.waitForConfirmation(txId);
    log('AlgorandService - optInToASA - done');
    return txId;
  }

  // not using this method in the other methods due to naming clash
  Future waitForConfirmation({required txId}) async {
    log('AlgorandService - waitForConfirmation - txId=$txId');
    await algorandLib.waitForConfirmation(txId);
    log('AlgorandService - waitForConfirmation - done');
  }

  // KEEP account in the local scope
  Future<Account?> getAccount(int numAccount) async {
    // log('_account - storage=$storage - numAccount=$numAccount');
    final privateKey = await storage.read('account_$numAccount');
    // log('_account - numAccount=$numAccount - privateKey==null=${privateKey == null}');
    if (privateKey == null) return null;
    // log('_account - numAccount=$numAccount - got privateKey='); // TODO DO NOT print privatekey
    final Uint8List seed = base64Decode(privateKey);
    // log('_account - numAccount=$numAccount - got seed='); // TODO DO NOT print seed
    final Account account = await algorandLib.loadAccountFromSeed(seed);
    // log('_account - numAccount=$numAccount - got account=${account.publicAddress}');
    return account;
  }

  Future<String?> accountPublicAddress(int numAccount) async {
    // log('accountPublicAddress - numAccount=$numAccount');
    final Account? account = await getAccount(numAccount);
    // log('accountPublicAddress - account=$account');
    return account?.publicAddress;
  }

  Future<bool> isAccountOptedInToASA(String accountAddress, int assetId) async {
    if (assetId == 0) return true; // all accounts can use ALGO
    final accountInfo = await algorandLib.getAccountByAddress(accountAddress);
    final assetHoldings = accountInfo.assets;
    return assetHoldings.map((a) => a.assetId).contains(assetId);
  }

  Future<int?> findNumAccount(String publicAddress) async {
    final numAccounts = await getNumAccounts();
    for (var i = 1; i <= numAccounts; i++) {
      final account = await getAccount(i);
      if (account?.publicAddress == publicAddress) return i;
    }
    return null;
  }

  Future<String> lockCoins(
      {required Meeting meeting, waitForConfirmation = true}) async {
    log('lock - meeting.speed.assetId=${meeting.speed.assetId}');
    final publicAddress = meeting.addrA;
    final numAccount = await findNumAccount(publicAddress);
    if (numAccount == null)
      throw ('lockCoins: account with publicAddress=$publicAddress not found on device');
    if (meeting.speed.assetId == 0)
      return _lockALGO(
          B: meeting.addrB,
          speed: meeting.speed.num,
          budget: meeting.budget,
          numAccount: numAccount,
          waitForConfirmation: waitForConfirmation);
    return _lockASA(
        B: meeting.addrB,
        speed: meeting.speed.num,
        budget: meeting.budget,
        assetId: meeting.speed.assetId,
        numAccount: numAccount,
        waitForConfirmation: waitForConfirmation);
  }

  Future<String> _lockALGO(
      {required String B,
      required int speed,
      required int budget,
      required int numAccount,
      waitForConfirmation = true}) async {
    log('lockALGO - B=$B - speed=$speed - budget=$budget - waitForConfirmation=$waitForConfirmation');

    final Account? account = await getAccount(numAccount);
    if (account == null) return '';
    log('lockALGO - account=${account.publicAddress}');

    final params = await algorandLib.getSuggestedTransactionParams();
    log('lockALGO - params=$params');

    final lockTxn = await (PaymentTransactionBuilder()
          ..sender = account.address
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = LOCK_ALGO_FEE + budget
          ..suggestedParams = params)
        .build();
    log('lockALGO - lockTxn=$lockTxn');

    final arguments = 'str:LOCK,int:$speed'.toApplicationArguments();
    log('lockALGO - arguments=$arguments');
    final stateTxn = await (ApplicationCallTransactionBuilder()
          ..sender = account.address
          ..applicationId = SYSTEM_ID[net]!
          ..arguments = arguments
          ..accounts = [Address.fromAlgorandAddress(address: B)]
          ..suggestedParams = params)
        .build();
    log('lockALGO - stateTxn=$stateTxn');

    AtomicTransfer.group([lockTxn, stateTxn]);
    log('lockALGO - grouped');

    final lockTxnSigned = await lockTxn.sign(account);
    log('lockALGO - signed 2');
    final stateTxnSigned = await stateTxn.sign(account);
    log('lockALGO - signed 1');

    try {
      final txId =
          await algorandLib.sendTransactions([lockTxnSigned, stateTxnSigned]);
      log('lockALGO - txId=$txId');

      if (waitForConfirmation) await algorandLib.waitForConfirmation(txId);
      log('lockALGO - done');

      return txId;
    } on AlgorandException catch (ex) {
      final cause = ex.cause;
      if (cause is dio.DioError) {
        log('AlgorandException ' + cause.response?.data['message']);
      }
      return 'error';
    } on Exception catch (ex) {
      log('Exception ' + ex.toString());
      return 'error';
    }
  }

  Future<String> _lockASA(
      {required String B,
      required int speed,
      required int budget,
      required int assetId,
      required int numAccount,
      waitForConfirmation = true}) async {
    log('lockASA - B=$B - speed=$speed - budget=$budget - assetId=$assetId - waitForConfirmation=$waitForConfirmation');
    final Account? account = await getAccount(numAccount);
    if (account == null) return '';
    log('lockASA - account=${account.publicAddress}');

    // calc LOCK_ASA_TOTAL_FEE depending on whether SYSTEM is opted-in to ASA or not
    final systemOptedIn =
        await isAccountOptedInToASA(SYSTEM_ACCOUNT[net]!, assetId);
    log('lockASA - systemOptedIn=$systemOptedIn');
    final lockAsaTotalFee =
        LOCK_ASA_FEE + (systemOptedIn ? 0 : OPT_IN_SYSTEM_TO_ASA_FEE);
    log('lockASA - lockAsaTotalFee=$lockAsaTotalFee');

    final params = await algorandLib.getSuggestedTransactionParams();
    log('lockASA - params=$params');

    final lockALGOTxn = await (PaymentTransactionBuilder()
          ..sender = account.address
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = lockAsaTotalFee
          ..suggestedParams = params)
        .build();
    // log('lockASA - lockALGOTxn=$lockALGOTxn');
    final arguments = 'str:LOCK,int:$speed'.toApplicationArguments();
    log('lockASA - arguments=$arguments');
    final stateTxn = await (ApplicationCallTransactionBuilder()
          ..sender = account.address
          ..applicationId = SYSTEM_ID[net]!
          ..arguments = arguments
          ..accounts = [
            Address.fromAlgorandAddress(address: B),
            Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!),
            Address.fromAlgorandAddress(address: CREATOR[net]!)
          ]
          ..foreignAssets = [assetId]
          ..flatFee = 3000
          ..suggestedParams = params)
        .build();
    // log('lockASA - stateTxn=$stateTxn');

    final lockASATxn = await (AssetTransferTransactionBuilder()
          ..sender = account.address
          ..assetId = assetId
          ..amount = budget
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..suggestedParams = params)
        .build();
    // log('lockASA - lockASATxn=$lockASATxn');
    AtomicTransfer.group([lockALGOTxn, stateTxn, lockASATxn]);
    log('lockASA - grouped');
    final lockALGOTxnSigned = await lockALGOTxn.sign(account);
    log('lockASA - signed 1');
    final stateTxnSigned = await stateTxn.sign(account);
    log('lockASA - signed 2');
    final lockASATxnSigned = await lockASATxn.sign(account);
    log('lockASA - signed 3');

    // DEBUG
    // log('lockASA - exporting files');
    // final lockALGOTxnSignedJSON = lockALGOTxnSigned.toJson();
    // log(lockALGOTxnSignedJSON);
    // // await lockALGOTxnSigned
    // //     .export('/Users/imi/Downloads/lockALGOTxnSigned.stxn');
    // log('lockASA - exporting files - 2');
    // final stateTxnSignedJSON = stateTxnSigned.toJson();
    // log(stateTxnSignedJSON);
    // // await stateTxnSigned.export('/Users/imi/Downloads/stateTxnSigned.stxn');
    // log('lockASA - exporting files - 3');
    // final lockASATxnSignedJSON = lockASATxnSigned.toJson();
    // log(lockASATxnSignedJSON);
    // // await lockASATxnSigned.export('/Users/imi/Downloads/lockASATxnSigned.stxn');
    // log('lockASA - exporting files done');
    // DEBUG

    try {
      final txId = await algorandLib.sendTransactions(
          [lockALGOTxnSigned, stateTxnSigned, lockASATxnSigned]);
      log('lockASA - txId=$txId');
      if (waitForConfirmation) await algorandLib.waitForConfirmation(txId);
      log('lockASA - done');

      // opt in CREATOR
      if (!systemOptedIn) {
        final HttpsCallable optInToASA = functions.httpsCallable('optInToASA');
        await optInToASA({
          'txId': txId,
          'assetId': assetId,
        });
      }

      return txId;
    } on AlgorandException catch (ex) {
      final cause = ex.cause;
      if (cause is dio.DioError) {
        log('AlgorandException ' + cause.response?.data['message']);
      }
      return 'error';
    } on Exception catch (ex) {
      log('Exception ' + ex.toString());
      return 'error';
    }
  }

  // TODO error handling if publicAddress is null
  Future<List<List<AssetHolding>>> getAllAssetHoldings() async {
    // log('AlgorandService - getAllAssetHoldings');
    final n = await getNumAccounts();
    // log('AlgorandService - getAllAssetHoldings - n=$n');
    final List<Future<List<AssetHolding>>> futures = [];
    for (int i = 1; i <= n; i++) {
      // log('AlgorandService - getAllAssetHoldings - i=$i');
      final publicAddressFuture = accountPublicAddress(i);
      // log('AlgorandService - getAllAssetHoldings - i=$i - publicAddressFuture=$publicAddressFuture');
      final assetHoldingsFuture =
          publicAddressFuture.then((String? publicAddress) {
        // log('AlgorandService - getAllAssetHoldings - i=$i = publicAddress=$publicAddress');
        return getAssetHoldings(publicAddress!);
      });
      futures.add(assetHoldingsFuture);
    }
    return Future.wait(futures);
  }
}
