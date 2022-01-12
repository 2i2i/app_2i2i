import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:algorand_dart/algorand_dart.dart' as al;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart' as dio;

import '../../models/meeting_model.dart';
import '../accounts/abstract_account.dart';
import '../services/logging.dart';
import 'secure_storage_service.dart';

enum AlgorandNet { mainnet, testnet, betanet }

extension ParseToString on AlgorandNet {
  String toStringEnum() {
    return this.toString().split('.').last;
  }
}

class AlgorandLib {
  static const Map<AlgorandNet, String> API_URL = {
    AlgorandNet.mainnet: AlgoExplorer.MAINNET_ALGOD_API_URL,
    AlgorandNet.testnet: AlgoExplorer.TESTNET_ALGOD_API_URL,
    AlgorandNet.betanet: AlgoExplorer.BETANET_ALGOD_API_URL,
  };
  static const Map<AlgorandNet, String> INDEXER_URL = {
    AlgorandNet.mainnet: AlgoExplorer.MAINNET_INDEXER_API_URL,
    AlgorandNet.testnet: AlgoExplorer.TESTNET_INDEXER_API_URL,
    AlgorandNet.betanet: AlgoExplorer.BETANET_INDEXER_API_URL,
  };
  static const Map<AlgorandNet, String> API_KEY = {
    AlgorandNet.mainnet: '',
    AlgorandNet.testnet: '',
    AlgorandNet.betanet: '',
  };
  // static const Map<AlgorandNet, String> API_KEY = {
  //   AlgorandNet.mainnet: 'MqL3AY7X9O4VCPFjW2XvE1jpjrF87i2B95pXlsoD',
  //   AlgorandNet.testnet: 'MqL3AY7X9O4VCPFjW2XvE1jpjrF87i2B95pXlsoD',
  //   AlgorandNet.betanet: 'MqL3AY7X9O4VCPFjW2XvE1jpjrF87i2B95pXlsoD',
  // };
  AlgorandLib() {
    for (final net in [AlgorandNet.mainnet, AlgorandNet.testnet]) {
      client[net] = Algorand(
          algodClient:
              AlgodClient(apiUrl: API_URL[net]!, apiKey: API_KEY[net]!),
          indexerClient: IndexerClient(apiUrl: INDEXER_URL[net]!));
    }
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
      required this.algorandLib,
      required this.meetingChanger});
  final MeetingChanger meetingChanger;
  final FirebaseFunctions functions;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;

  Future<TransactionResponse> getTransactionResponse(
          String transactionId, AlgorandNet net) =>
      algorandLib.client[net]!.indexer().getTransactionById(transactionId);

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
  Future<PendingTransaction> waitForConfirmation(
      {required String txId, required AlgorandNet net}) {
    log('AlgorandService - waitForConfirmation - txId=$txId');
    return algorandLib.client[net]!.waitForConfirmation(txId);
  }

  Future<MeetingTxns> lockCoins({required Meeting meeting}) async {
    log('lock - meeting.speed.assetId=${meeting.speed.assetId}');
    final account = await accountService.findAccount(meeting.addrA!);

    if (meeting.speed.assetId == 0) {
      return _lockALGO(
        meetingId: meeting.id,
        B: meeting.addrB!,
        speed: meeting.speed.num,
        account: account!,
        net: meeting.net,
      );
    }
    throw Exception('no ASA for now');
    // return _lockASA(
    //   meetingId: meeting.id,
    //   B: meeting.addrB!,
    //   speed: meeting.speed.num,
    //   assetId: meeting.speed.assetId,
    //   account: account!,
    //   net: meeting.net,
    // );
  }

  Future<MeetingTxns> _lockALGO({
    required String meetingId,
    required String B,
    required int speed,
    required AbstractAccount account,
    required AlgorandNet net,
  }) async {
    log(J +
        'lockALGO - B=$B - speed=$speed - waitForConfirmation=$waitForConfirmation');

    log('lockALGO - account=${account.address}');

    final params =
        await algorandLib.client[net]!.getSuggestedTransactionParams();
    log('lockALGO - params=$params');

    final List<RawTransaction> txns = [];

    final optedIntoSystem =
        await account.isOptedInToDApp(dAppId: SYSTEM_ID[net]!, net: net);
    if (!optedIntoSystem) {
      final optInTxn = await (ApplicationOptInTransactionBuilder()
            ..sender = Address.fromAlgorandAddress(address: account.address)
            ..applicationId = SYSTEM_ID[net]!
            ..suggestedParams = params)
          .build();
      txns.add(optInTxn);
    }

    int budget =
        await accountService.calcBudget(assetId: 0, account: account, net: net);

    final lockTxn = await (PaymentTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = LOCK_ALGO_FEE + budget
          ..suggestedParams = params)
        .build();
    log('lockALGO - lockTxn=$lockTxn');
    txns.add(lockTxn);

    final arguments = 'str:LOCK,int:$speed'.toApplicationArguments();
    log(J + 'lockALGO - speed=$speed - arguments=$arguments');
    final stateTxn = await (ApplicationCallTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..applicationId = SYSTEM_ID[net]!
          ..arguments = arguments
          ..accounts = [Address.fromAlgorandAddress(address: B)]
          ..suggestedParams = params)
        .build();
    log(J + 'lockALGO - stateTxn=$stateTxn');
    txns.add(stateTxn);

    AtomicTransfer.group(txns);
    log(J + 'lockALGO - grouped');

    // TXN_CREATED
    await meetingChanger.txnCreatedMeeting(meetingId);

    // for (var i = 0; i < txns.length; i++) {
    //   await txns[i].export('/Users/imi/Downloads/txns_$i.txn');
    // }

    // TXN_SIGNED
    // TODO in parallel - together with previous
    final signedTxnsBytes = await account.sign(txns);
    await meetingChanger.txnSignedMeeting(meetingId);

    try {
      final txId =
          await algorandLib.client[net]!.sendRawTransactions(signedTxnsBytes);
      log(J + 'lockALGO - txId=$txId');

      // tx ids
      final txnsIds = MeetingTxns(
        group: txId,
        lockALGO: lockTxn.id,
        state: stateTxn.id,
      );
      log(J + 'lockALGO - txnsIds=$txnsIds - optedIntoSystem=$optedIntoSystem');
      if (!optedIntoSystem) txnsIds.optIn = txns[0].id;
      log(J + 'lockALGO - txnsIds=$txnsIds');

      await meetingChanger.txnSentMeeting(meetingId, txnsIds);
      log(J + 'lockALGO - TXN_SENT');

      return txnsIds;
    } on AlgorandException catch (ex) {
      final cause = ex.cause;
      if (cause is dio.DioError) {
        log(J + 'AlgorandException ' + cause.response?.data['message']);
      }
      throw ex;
    } on Exception catch (ex) {
      log(J + 'Exception ' + ex.toString());
      throw ex;
    }
  }

  // Future<MeetingTxns> _lockASA({
  //   required String meetingId,
  //   required String B,
  //   required int speed,
  //   required int assetId,
  //   required AbstractAccount account,
  //   required AlgorandNet net,
  // }) async {
  //   log('lockASA - B=$B - speed=$speed - assetId=$assetId - waitForConfirmation=$waitForConfirmation');
  //   log('lockASA - account=${account.address}');

  //   // calc LOCK_ASA_TOTAL_FEE depending on whether SYSTEM is opted-in to ASA or not
  //   final systemOptedIn = await accountService.isOptedInToASA(
  //       address: SYSTEM_ACCOUNT[net]!, assetId: assetId, net: net);
  //   log('lockASA - systemOptedIn=$systemOptedIn');
  //   final lockAsaTotalFee =
  //       LOCK_ASA_FEE + (systemOptedIn ? 0 : OPT_IN_SYSTEM_TO_ASA_FEE);
  //   log('lockASA - lockAsaTotalFee=$lockAsaTotalFee');

  //   final params =
  //       await algorandLib.client[net]!.getSuggestedTransactionParams();
  //   log('lockASA - params=$params');

  //   final List<RawTransaction> txns = [];

  //   final optedIntoSystem =
  //       await account.isOptedInToDApp(dAppId: SYSTEM_ID[net]!, net: net);
  //   if (!optedIntoSystem) {
  //     final optInTxn = await (ApplicationOptInTransactionBuilder()
  //           ..sender = Address.fromAlgorandAddress(address: account.address)
  //           ..applicationId = SYSTEM_ID[net]!
  //           ..suggestedParams = params)
  //         .build();
  //     txns.add(optInTxn);
  //   }

  //   final lockALGOTxn = await (PaymentTransactionBuilder()
  //         ..sender = Address.fromAlgorandAddress(address: account.address)
  //         ..receiver =
  //             Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
  //         ..amount = lockAsaTotalFee
  //         ..suggestedParams = params)
  //       .build();
  //   // log('lockASA - lockALGOTxn=$lockALGOTxn');
  //   txns.add(lockALGOTxn);

  //   final arguments = 'str:LOCK,int:$speed'.toApplicationArguments();
  //   log('lockASA - arguments=$arguments');
  //   final stateTxn = await (ApplicationCallTransactionBuilder()
  //         ..sender = Address.fromAlgorandAddress(address: account.address)
  //         ..applicationId = SYSTEM_ID[net]!
  //         ..arguments = arguments
  //         ..accounts = [
  //           Address.fromAlgorandAddress(address: B),
  //           Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!),
  //           Address.fromAlgorandAddress(address: CREATOR[net]!)
  //         ]
  //         ..foreignAssets = [assetId]
  //         ..flatFee = 3000
  //         ..suggestedParams = params)
  //       .build();
  //   // log('lockASA - stateTxn=$stateTxn');
  //   txns.add(stateTxn);

  //   int budget = await accountService.calcBudget(
  //       assetId: assetId, account: account, net: net);

  //   final lockASATxn = await (AssetTransferTransactionBuilder()
  //         ..sender = Address.fromAlgorandAddress(address: account.address)
  //         ..assetId = assetId
  //         ..amount = budget
  //         ..receiver =
  //             Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
  //         ..suggestedParams = params)
  //       .build();
  //   // log('lockASA - lockASATxn=$lockASATxn');
  //   txns.add(lockASATxn);

  //   // TODO in parallel
  //   AtomicTransfer.group(txns);
  //   log('lockASA - grouped');

  //   // TXN_CREATED
  //   await meetingChanger.txnCreatedMeeting(meetingId);

  //   final signedTxnsBytes = await account.sign(txns);
  //   await meetingChanger.txnSignedMeeting(meetingId);

  //   try {
  //     final txId =
  //         await algorandLib.client[net]!.sendRawTransactions(signedTxnsBytes);
  //     log('lockASA - txId=$txId');

  //     // opt in CREATOR
  //     if (!systemOptedIn) {
  //       final HttpsCallable optInToASA = functions.httpsCallable('optInToASA');
  //       await optInToASA({
  //         'txId': txId,
  //         'assetId': assetId,
  //       });
  //     }

  //     // tx ids
  //     final txnsIds = MeetingTxns(
  //       group: txId,
  //       lockALGO: lockALGOTxn.id,
  //       state: stateTxn.id,
  //       lockASA: lockASATxn.id,
  //     );
  //     if (!optedIntoSystem) txnsIds.optIn = txns[0].id;

  //     await meetingChanger.txnSentMeeting(meetingId, txns);

  //     return txnsIds;
  //   } on AlgorandException catch (ex) {
  //     final cause = ex.cause;
  //     if (cause is dio.DioError) {
  //       log('AlgorandException ' + cause.response?.data['message']);
  //     }
  //     throw ex;
  //   } on Exception catch (ex) {
  //     log('Exception ' + ex.toString());
  //     throw ex;
  //   }
  // }

  Future<void> setNetworkMode(String? mode) async {
    await storage.write('network_mode', mode!);
  }

  Future<String?> getNetworkMode() async {
    return await storage.read('network_mode');
  }
}
