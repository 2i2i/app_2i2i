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
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://walletconnect.org',
        icons: ['https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'],
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

    address = connector.session.accounts[0];
    await updateBalances(net: AppConfig().ALGORAND_NET);
    // futures.add(updateBalances());

    int alreadyExistIndex = cache.indexWhere((element) => element.address == address);
    if (alreadyExistIndex < 0) {
      cache.add(this);
    } else {
      cache[alreadyExistIndex] = this;
    }
    // }
    // await Future.wait(futures);
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
