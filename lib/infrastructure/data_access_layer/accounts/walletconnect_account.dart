import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:walletconnect_secure_storage/walletconnect_secure_storage.dart';

import '../../commons/utils.dart';
import '../repository/algorand_service.dart';
import '../repository/secure_storage_service.dart';
import 'abstract_account.dart';

class WalletConnectAccount extends AbstractAccount {
  static List<WalletConnectAccount> cache = [];

  static const String STORAGE_KEY = 'wallet_connect_accounts';

  static Future<WalletConnect> newConnector([String key = '0']) async {
    final sessionStorage = WalletConnectSecureStorage(storageKey: key);
    final session = await sessionStorage.getSession();
    final bridge = await getWCBridge();
    return WalletConnect(
      bridge: bridge,
      session: session,
      sessionStorage: sessionStorage,
      clientMeta: const PeerMeta(
        name: '2i2i',
        description: 'receive coins by talking',
        url: 'https://2i2i.app',
        icons: ['https://firebasestorage.googleapis.com/v0/b/app-2i2i.appspot.com/o/logo.png?alt=media&token=851a5941-50f5-466c-91ec-10868ff27423'],
      ),
    );
  }

  final SecureStorage storage = SecureStorage();

  late WalletConnect connector;
  late AlgorandWalletConnectProvider provider;

  WalletConnectAccount({required AccountService accountService, required this.connector, required this.provider}) : super(accountService: accountService);

  factory WalletConnectAccount.fromNewConnector({required AccountService accountService, required WalletConnect connector}) {
    final provider = AlgorandWalletConnectProvider(connector);
    return WalletConnectAccount(accountService: accountService, connector: connector, provider: provider);
  }

  // TODO cache management
  Future<void> save(String sessionId) async {
    log('save sessionId=$sessionId');
    // final List<Future<void>> futures = [];
    // for (int i = 0; i < connector.session.accounts.length; i++) {
    // final account = WalletConnectAccount(
    //     accountService: accountService,
    //     connector: connector,
    // );

    List<String> accounts = await accountService.getAllWalletConnectAccounts();
    accounts.add(sessionId);
    storage.write(STORAGE_KEY, accounts.join(','));

    if (connector.session.accounts.isNotEmpty) {
      address = connector.session.accounts[0];
      await updateBalances(net: AppConfig().ALGORAND_NET);
      // futures.add(updateBalances());
      int alreadyExistIndex = cache.indexWhere((element) => element.address == address);
      if (alreadyExistIndex == -1) {
        cache.add(this);
      } else {
        cache[alreadyExistIndex] = this;
      }
    }
  }

  static List<WalletConnectAccount> getAllAccounts() => cache;

  static List<String> getAllAccountAddresses(WalletConnect connector) => connector.session.accounts;

  @override
  Future<String> optInToASA({required int assetId, required AlgorandNet net, waitForConfirmation = true}) {
    // TODO: implement optInToASA
    throw UnimplementedError();
  }

  @override
  Future<String> optInToDapp({required int dappId, required AlgorandNet net, bool waitForConfirmation = false}) {
    // TODO: implement optInToDapp
    throw UnimplementedError();
  }

  @override
  Future<List<Uint8List>> sign(List<RawTransaction> txns) {
    final txnsBytes = txns.map((txn) => Encoder.encodeMessagePack(txn.toMessagePack())).toList();
    return provider.signTransactions(txnsBytes);
  }
}
