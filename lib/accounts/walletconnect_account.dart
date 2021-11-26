import 'dart:typed_data';
import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class WalletConnectAccount extends AbstractAccount {
  static List<WalletConnectAccount> cache = [];

  static WalletConnect newConnector() {
    return WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://walletconnect.org',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
  }

  int? _accountIndex; // will be null until session created
  set accountIndex(int a) => _accountIndex = a;

  late WalletConnect connector;

  factory WalletConnectAccount.fromNewConnector(
      {required AccountService accountService}) {
    final connector = newConnector();
    return WalletConnectAccount(
        accountService: accountService, connector: connector);
  }
  WalletConnectAccount(
      {required AccountService accountService, required this.connector})
      : super(accountService: accountService);
  factory WalletConnectAccount.fieldsGiven(
      {required AccountService accountService,
      required WalletConnect connector,
      required int accountIndex}) {
    final account = WalletConnectAccount(
        accountService: accountService, connector: connector);
    account._accountIndex = accountIndex;
    return account;
  }
  factory WalletConnectAccount.fromAccountIndex(int accountIndex) {
    // TODO error if not 0 <= accountIndex < cache.length
    List<String> addresses = [];
    int counter = 0;
    for (final account in cache) {
      if (counter == accountIndex) return account;
      if (addresses.contains(account.address)) continue;
      counter++;
    }
    throw Exception('WalletConnectAccount.fromAccountIndex - accountIndex bad');
  }

  // TODO cache management
  Future<void> save() async {
    if (_accountIndex != null) return;
    final List<WalletConnectAccount> accounts = [];
    final List<Future<void>> futures = [];
    for (int i = 0; i < connector.session.accounts.length; i++) {
      final account = WalletConnectAccount.fieldsGiven(
          accountService: accountService,
          connector: connector,
          accountIndex: i);
      accounts.add(account);
      futures.add(account.updateBalances());
    }
    await Future.wait(futures);
    cache.addAll(accounts);
  }

  static List<WalletConnectAccount> getAllAccounts() => cache;

  @override
  String get address => connector.session.accounts[_accountIndex!];

  @override
  Future<String> optInToASA(
      {required int assetId,
      required AlgorandNet net,
      waitForConfirmation = true}) {
    // TODO: implement optInToASA
    throw UnimplementedError();
  }

  @override
  Future<String> optInToDapp(
      {required int dappId,
      required AlgorandNet net,
      bool waitForConfirmation = false}) {
    // TODO: implement optInToDapp
    throw UnimplementedError();
  }

  @override
  Future<List<Uint8List>> sign(List<RawTransaction> txns) {
    final txnsBytes = txns
        .map((txn) => Encoder.encodeMessagePack(txn.toMessagePack()))
        .toList();
    return connector.signTransactions(txnsBytes);
  }
}
