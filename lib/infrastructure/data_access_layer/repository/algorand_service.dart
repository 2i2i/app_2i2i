import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/accounts/walletconnect_account.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  };
  static const Map<AlgorandNet, String> INDEXER_URL = {
    AlgorandNet.mainnet: AlgoExplorer.MAINNET_INDEXER_API_URL,
    AlgorandNet.testnet: AlgoExplorer.TESTNET_INDEXER_API_URL,
  };
  static const Map<AlgorandNet, String> API_KEY = {
    AlgorandNet.mainnet: '',
    AlgorandNet.testnet: '',
  };

  // static const Map<AlgorandNet, String> API_KEY = {
  //   AlgorandNet.mainnet: 'MqL3AY7X9O4VCPFjW2XvE1jpjrF87i2B95pXlsoD',
  //   AlgorandNet.testnet: 'MqL3AY7X9O4VCPFjW2XvE1jpjrF87i2B95pXlsoD',
  // };
  AlgorandLib() {
    client[AppConfig().ALGORAND_NET] = Algorand(
        algodClient: AlgodClient(apiUrl: API_URL[AppConfig().ALGORAND_NET]!, apiKey: API_KEY[AppConfig().ALGORAND_NET]!),
        indexerClient: IndexerClient(apiUrl: INDEXER_URL[AppConfig().ALGORAND_NET]!));
  }

  final Map<AlgorandNet, Algorand> client = {};
}

class AlgorandService {
  static Map<AlgorandNet, int> SYSTEM_ID = {
    AlgorandNet.mainnet: int.parse(dotenv.env['ALGORAND_SYSTEM_ID_MAINNET']!),
    AlgorandNet.testnet: int.parse(dotenv.env['ALGORAND_SYSTEM_ID_TESTNET']!),
  };
  static Map<AlgorandNet, String> SYSTEM_ACCOUNT = {
    AlgorandNet.mainnet: dotenv.env['ALGORAND_SYSTEM_ACCOUNT_MAINNET']!,
    AlgorandNet.testnet: dotenv.env['ALGORAND_SYSTEM_ACCOUNT_TESTNET']!,
  };
  static const int MIN_TXN_FEE = 1000;

  AlgorandService({required this.storage, required this.functions, required this.accountService, required this.algorandLib, required this.meetingChanger});

  final MeetingChanger meetingChanger;
  final FirebaseFunctions functions;
  final SecureStorage storage;
  final AccountService accountService;
  final AlgorandLib algorandLib;

  // TODO: needs a try-catch ==> Removed
  // Future<TransactionResponse> getTransactionResponse(
  //         String transactionId, AlgorandNet net) =>
  //     algorandLib.client[net]!.indexer().getTransactionById(transactionId);

  // not using this method in the other methods due to naming clash
  Future<PendingTransaction> waitForConfirmation({required String txId, required AlgorandNet net}) {
    log('AlgorandService - waitForConfirmation - txId=$txId');
    return algorandLib.client[net]!.waitForConfirmation(txId);
  }

  Future<Map<String, String>> lockCoins({
    required String sessionId,
    required String address,
    required AlgorandNet net,
    required Quantity amount,
    required String note,
  }) async {

    log('lockCoins - sessionId=$sessionId address=$address net=$net amount.num=${amount.num} amount.assetId=${amount.assetId} note=$note');

    final List<RawTransaction> txns = [];
    
    final params = await algorandLib.client[net]!.getSuggestedTransactionParams();

    final Map<String, String> result = {};

    final payTxn = await (PaymentTransactionBuilder()
          ..sender = Address.fromAlgorandAddress(address: address)
          ..receiver = Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = 3 * MIN_TXN_FEE + (amount.assetId == 0 ? amount.num : 0)
          ..suggestedParams = params
          ..noteText = note)
        .build();
    txns.add(payTxn);
    result['pay'] = payTxn.id;

    log('lockCoins - payTxn.id=${payTxn.id}');

    if (amount.assetId != 0) {
      final axferTxn = await (AssetTransferTransactionBuilder()
          ..assetSender = Address.fromAlgorandAddress(address: address)
          ..receiver = Address.fromAlgorandAddress(address: SYSTEM_ACCOUNT[net]!)
          ..amount = amount.num
          ..assetId = amount.assetId
          ..suggestedParams = params
          ..noteText = note)
        .build();
        txns.add(axferTxn);
        result['axfer'] = axferTxn.id;
        log('lockCoins - axferTxn.id=${axferTxn.id}');
    }

    final connector = await WalletConnectAccount.newConnector(sessionId);
    log('lockCoins - connector=$connector');
    final account = WalletConnectAccount.fromNewConnector(accountService: accountService, connector: connector);
    log('lockCoins - account=$account');

    final signedTxnsBytes = await account.sign(txns);
    log('lockCoins - signed $signedTxnsBytes');

    try {
      final groupTxId = await algorandLib.client[net]!.sendRawTransactions(signedTxnsBytes);
      log('lockCoins - groupTxId $groupTxId');
      result['group'] = groupTxId;
      return result;
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
