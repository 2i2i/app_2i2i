import 'package:algorand_dart/algorand_dart.dart';

import 'package:dio/dio.dart' as dio;
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    AlgorandNet.mainnet: 67119462,
    AlgorandNet.testnet: 67119462,
    AlgorandNet.betanet: 67119462,
  };
  static const Map<AlgorandNet, String> SYSTEM_ACCOUNT = {
    AlgorandNet.mainnet:
        'PANC6WKDNNLXXKVXWPGUVCTYBPVNL66YCIRJELL2CQP4GKKCEIWQHJZCWU',
    AlgorandNet.testnet:
        'PANC6WKDNNLXXKVXWPGUVCTYBPVNL66YCIRJELL2CQP4GKKCEIWQHJZCWU',
    AlgorandNet.betanet:
        'PANC6WKDNNLXXKVXWPGUVCTYBPVNL66YCIRJELL2CQP4GKKCEIWQHJZCWU',
  };
  static const int MIN_TXN_FEE = 1000;

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

  // not using this method in the other methods due to naming clash
  Future<PendingTransaction> waitForConfirmation(
      {required String txId, required AlgorandNet net}) {
    log('AlgorandService - waitForConfirmation - txId=$txId');
    return algorandLib.client[net]!.waitForConfirmation(txId);
  }

  Future<String> lockCoins({
    required AbstractAccount account,
    required AlgorandNet net,
    required Quantity amount,
    required String note,
  }) async {
    final List<RawTransaction> txns = [];

    final params =
        await algorandLib.client[net]!.getSuggestedTransactionParams();

    final lockTxn = await (PaymentTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..receiver =
              Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = amount.num + 4 * MIN_TXN_FEE
          ..suggestedParams = params
          ..noteText = note)
        .build();
    txns.add(lockTxn);

    final arguments = 'str:LOCK'.toApplicationArguments();
    final appCallTxn = await (ApplicationCallTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: account.address)
          ..applicationId = SYSTEM_ID[net]!
          ..arguments = arguments
          ..suggestedParams = params)
        .build();
    txns.add(appCallTxn);

    AtomicTransfer.group(txns);
    log(J + 'lockALGO - grouped');

    final signedTxnsBytes = await account.sign(txns);
    log(J + 'lockALGO - signed');

    try {
      return algorandLib.client[net]!.sendRawTransactions(signedTxnsBytes);
    } on AlgorandException catch (ex) {
      final cause = ex.cause;
      if (cause is dio.DioError) {
        log('AlgorandException ' + cause.response?.data['message']);
      }
      throw ex;
    } on Exception catch (ex) {
      log('Exception ' + ex.toString());
      throw ex;
    }
  }
}
