import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:dio/dio.dart' as dio;
import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/app/home/models/meeting.dart';
import 'package:app_2i2i/services/secure_storage_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:app_2i2i/app/logging.dart';

enum AlgorandNet { mainnet, testnet, betanet }

class AlgorandLib {
  static const Map<AlgorandNet, String> API_URL = {
    AlgorandNet.mainnet: AlgoExplorer.MAINNET_ALGOD_API_URL,
    AlgorandNet.testnet: AlgoExplorer.TESTNET_ALGOD_API_URL,
    AlgorandNet.betanet: AlgoExplorer.BETANET_ALGOD_API_URL,
  };
  AlgorandLib() {
    client[AlgorandNet.mainnet] = Algorand(
        algodClient: AlgodClient(apiUrl: API_URL[AlgorandNet.mainnet]!));
    client[AlgorandNet.testnet] = Algorand(
        algodClient: AlgodClient(apiUrl: API_URL[AlgorandNet.testnet]!));
  }
  final Map<AlgorandNet, Algorand> client = {};
}

class AlgorandService {
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
      {required this.storage,
      required this.functions,
      required this.accountService,
      required this.algorandLib});
  final FirebaseFunctions functions;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;

  Future<String> giftALGO(AbstractAccount account,
      {waitForConfirmation = true}) async {
    log('AlgorandService - giftALGO - account=${account.address} - waitForConfirmation=$waitForConfirmation');
    final giftALGO = functions.httpsCallable('giftALGO');
    final result = await giftALGO({'account': account.address});
    log('AlgorandService - giftALGO - result=$result');
    final String txId = result.data;
    if (waitForConfirmation)
      await algorandLib.client[AlgorandNet.testnet]!.waitForConfirmation(txId);
    log('AlgorandService - giftALGO - done - txId=$txId');
    return txId;
  }

  Future<String> giftASA(AbstractAccount account,
      {waitForConfirmation = true}) async {
    log('AlgorandService - giftASA - account=${account.address} - waitForConfirmation=$waitForConfirmation');
    final giftASA = functions.httpsCallable('giftASA');
    final result = await giftASA({'account': account.address});
    log('AlgorandService - giftASA - result=$result');
    final String txId = result.data;
    if (waitForConfirmation)
      await algorandLib.client[AlgorandNet.testnet]!.waitForConfirmation(txId);
    log('AlgorandService - giftASA - done - txId=$txId');
    return txId;
  }

  // not using this method in the other methods due to naming clash
  Future waitForConfirmation({required txId, required AlgorandNet net}) async {
    log('AlgorandService - waitForConfirmation - txId=$txId');
    await algorandLib.client[net]!.waitForConfirmation(txId);
    log('AlgorandService - waitForConfirmation - done');
  }

  Future<String> lockCoins(
      {required Meeting meeting, waitForConfirmation = true}) async {
    log('lock - meeting.speed.assetId=${meeting.speed.assetId}');
    final net = meeting.net;
    final address = meeting.addrA;
    final account = await accountService.findAccount(address);
    if (meeting.speed.assetId == 0)
      return _lockALGO(
          B: meeting.addrB,
          speed: meeting.speed.num,
          budget: meeting.budget,
          account: account!,
          net: net,
          waitForConfirmation: waitForConfirmation);
    return _lockASA(
        B: meeting.addrB,
        speed: meeting.speed.num,
        budget: meeting.budget,
        assetId: meeting.speed.assetId,
        account: account!,
        net: net,
        waitForConfirmation: waitForConfirmation);
  }

  Future<String> _lockALGO(
      {required String B,
      required int speed,
      required int budget,
      required AbstractAccount account,
      required AlgorandNet net,
      waitForConfirmation = true}) async {
    log('lockALGO - B=$B - speed=$speed - budget=$budget - waitForConfirmation=$waitForConfirmation');

    log('lockALGO - account=${account.address}');

    final params =
        await algorandLib.client[net]!.getSuggestedTransactionParams();
    log('lockALGO - params=$params');

    final lockTxn = await (PaymentTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = LOCK_ALGO_FEE + budget
          ..suggestedParams = params)
        .build();
    log('lockALGO - lockTxn=$lockTxn');

    final arguments = 'str:LOCK,int:$speed'.toApplicationArguments();
    log('lockALGO - arguments=$arguments');
    final stateTxn = await (ApplicationCallTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..applicationId = SYSTEM_ID[net]!
          ..arguments = arguments
          ..accounts = [Address.fromAlgorandAddress(address: B)]
          ..suggestedParams = params)
        .build();
    log('lockALGO - stateTxn=$stateTxn');

    AtomicTransfer.group([lockTxn, stateTxn]);
    log('lockALGO - grouped');

    // TODO in parallel
    final lockTxnBytes = await account.sign(lockTxn);
    log('lockALGO - signed 2');
    final stateTxnBytes = await account.sign(stateTxn);
    log('lockALGO - signed 1');

    try {
      final txId = await algorandLib.client[net]!
          .sendRawTransactions([lockTxnBytes, stateTxnBytes]);
      // await algorandLib[net]!.sendTransactions([lockTxnSigned, stateTxnSigned]);
      log('lockALGO - txId=$txId');

      if (waitForConfirmation)
        await algorandLib.client[net]!.waitForConfirmation(txId);
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
      required AbstractAccount account,
      required AlgorandNet net,
      waitForConfirmation = true}) async {
    log('lockASA - B=$B - speed=$speed - budget=$budget - assetId=$assetId - waitForConfirmation=$waitForConfirmation');
    log('lockASA - account=${account.address}');

    // calc LOCK_ASA_TOTAL_FEE depending on whether SYSTEM is opted-in to ASA or not
    final systemOptedIn = await accountService.isOptedInToASA(
        address: SYSTEM_ACCOUNT[net]!, assetId: assetId, net: net);
    log('lockASA - systemOptedIn=$systemOptedIn');
    final lockAsaTotalFee =
        LOCK_ASA_FEE + (systemOptedIn ? 0 : OPT_IN_SYSTEM_TO_ASA_FEE);
    log('lockASA - lockAsaTotalFee=$lockAsaTotalFee');

    final params =
        await algorandLib.client[net]!.getSuggestedTransactionParams();
    log('lockASA - params=$params');

    final lockALGOTxn = await (PaymentTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = lockAsaTotalFee
          ..suggestedParams = params)
        .build();
    // log('lockASA - lockALGOTxn=$lockALGOTxn');
    final arguments = 'str:LOCK,int:$speed'.toApplicationArguments();
    log('lockASA - arguments=$arguments');
    final stateTxn = await (ApplicationCallTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
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
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..assetId = assetId
          ..amount = budget
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..suggestedParams = params)
        .build();
    // log('lockASA - lockASATxn=$lockASATxn');
    // TODO in parallel
    AtomicTransfer.group([lockALGOTxn, stateTxn, lockASATxn]);
    log('lockASA - grouped');
    final lockALGOTxnBytes = await account.sign(lockALGOTxn);
    log('lockASA - signed 1');
    final stateTxnBytes = await account.sign(stateTxn);
    log('lockASA - signed 2');
    final lockASATxnBytes = await account.sign(lockASATxn);
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
      final txId = await algorandLib.client[net]!.sendRawTransactions(
          [lockALGOTxnBytes, stateTxnBytes, lockASATxnBytes]);
      log('lockASA - txId=$txId');
      if (waitForConfirmation)
        await algorandLib.client[net]!.waitForConfirmation(txId);
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
}
