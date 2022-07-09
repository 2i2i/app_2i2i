import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/infrastructure/commons/app_config.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../repository/algorand_service.dart';
import 'abstract_account.dart';

class WalletConnectAccount extends AbstractAccount {
  static List<WalletConnectAccount> cache = [];

  static WalletConnect newConnector() {
    return WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: '2i2i',
        description: 'earn coins by talking',
        url: 'https://2i2i.app',
        icons: ['https://firebasestorage.googleapis.com/v0/b/app-2i2i.appspot.com/o/logo.png?alt=media&token=851a5941-50f5-466c-91ec-10868ff27423'],
      ),
    );
  }

  late WalletConnect connector;
  late AlgorandWalletConnectProvider provider;

  WalletConnectAccount({required AccountService accountService, required this.connector, required this.provider}) : super(accountService: accountService);

  factory WalletConnectAccount.fromNewConnector({required AccountService accountService}) {
    final connector = newConnector();
    final provider = AlgorandWalletConnectProvider(connector);
    return WalletConnectAccount(accountService: accountService, connector: connector, provider: provider);
  }

  // TODO cache management
  Future<void> save() async {
    // final List<Future<void>> futures = [];
    // for (int i = 0; i < connector.session.accounts.length; i++) {
    // final account = WalletConnectAccount(
    //     accountService: accountService,
    //     connector: connector,
    // );

    if (connector.session.accounts.isNotEmpty) {
      address = connector.session.accounts[0];
      await updateBalances(net: AppConfig().ALGORAND_NET);
      // futures.add(updateBalances());

      int alreadyExistIndex = cache.indexWhere((element) => element.address == address);
      if (alreadyExistIndex < 0) {
        cache.add(this);
      } else {
        cache[alreadyExistIndex] = this;
      }
    }
  }

  static List<WalletConnectAccount> getAllAccounts() => cache;

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
