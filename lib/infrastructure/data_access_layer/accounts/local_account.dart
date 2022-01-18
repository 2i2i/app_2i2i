import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:algorand_dart/algorand_dart.dart';

import '../repository/algorand_service.dart';
import '../repository/secure_storage_service.dart';
import 'abstract_account.dart';

class LocalAccount extends AbstractAccount {
  Account? account;
  LocalAccount._create({
    required this.algorandLib,
    required this.storage,
    required accountService,
    this.account
  }) : super(accountService: accountService);

  static Future<LocalAccount> create({
    required AlgorandLib algorandLib,
    required SecureStorage storage,
    required AccountService accountService,
  }) async {
    log('LocalAccount.create');
    final account = LocalAccount._create(
        accountService: accountService,
        algorandLib: algorandLib,
        storage: storage);
    await account._createAndStoreAccount();
    await account.updateBalances();
    return account;
  }

  static Future<LocalAccount> createWithoutStore({
    required AlgorandLib algorandLib,
    required SecureStorage storage,
    required AccountService accountService,
  }) async {
    log('LocalAccount.create');
    final account = LocalAccount._create(
        accountService: accountService,
        algorandLib: algorandLib,
        storage: storage,
    );
    await account.createLocalAccountWithoutStore();
    return account;
  }

  static Future<LocalAccount> fromNumAccount({
    required AlgorandLib algorandLib,
    required SecureStorage storage,
    required AccountService accountService,
    required int numAccount,
  }) async {
    log('LocalAccount.fromNumAccount');
    final account = LocalAccount._create(
        accountService: accountService,
        algorandLib: algorandLib,
        storage: storage);
    await account._loadAccountFromStorage(numAccount);
    await account.updateBalances();
    return account;
  }

  static Future<LocalAccount> fromMnemonic({
    required AlgorandLib algorandLib,
    required SecureStorage storage,
    required AccountService accountService,
    required List<String> mnemonic,
  }) async {
    log('LocalAccount.fromMnemonic');
    final account = LocalAccount._create(
        accountService: accountService,
        algorandLib: algorandLib,
        storage: storage);
    await account._loadAccountFromMnemonic(mnemonic);
    await account.updateBalances();
    return account;
  }

  @override
  Future<String> optInToASA(
      {required int assetId,
      required AlgorandNet net,
      waitForConfirmation = true}) async {
    final account = await _libAccount();
    final String txId = await algorandLib.client[net]!.assetManager.optIn(
      account: account,
      assetId: assetId,
    );

    if (waitForConfirmation)
      await algorandLib.client[net]!.waitForConfirmation(txId);

    return txId;
  }

  @override
  Future<String> optInToDapp(
      {required int dappId,
      required AlgorandNet net,
      bool waitForConfirmation = false}) async {
    final account = await _libAccount();
    final String txId = await algorandLib.client[net]!.applicationManager.optIn(
      account: account,
      applicationId: dappId,
    );
    if (waitForConfirmation)
      await algorandLib.client[net]!.waitForConfirmation(txId);
    return txId;
  }

  @override
  Future<List<Uint8List>> sign(List<RawTransaction> txns) async {
    final account = await _libAccount();
    final signFutures = txns.map((txn) => txn.sign(account)).toList();
    final txnsSigned = await Future.wait(signFutures);
    return txnsSigned.map((txn) => txn.toBytes()).toList();
  }

  Future<List<String>> mnemonic() async {
    final account = await _libAccount();
    return account.seedPhrase;
  }

  Future<Account> _libAccount() async {
    final privateKey = await storage.read('account_$_numAccount');
    final Uint8List seed = base64Decode(privateKey!);
    return algorandLib.client[AlgorandNet.mainnet]!
        .loadAccountFromSeed(seed); // mainnet as it does not matter
  }

  Future _loadAccountFromMnemonic(List<String> mnemonic) async {
    final account =
        await algorandLib.client[AlgorandNet.mainnet]!.restoreAccount(mnemonic);
    address = account.publicAddress;
    await storeAccount(account);
  }

  Future _loadAccountFromStorage(int numAccount) async {
    _numAccount = numAccount;
    final account = await _libAccount();
    address = account.publicAddress;
  }

  Future<Account> createLocalAccountWithoutStore() async{
    final Account account = await algorandLib.client[AlgorandNet.mainnet]!.createAccount(); // use mainnet bc it does not matter
    address = account.publicAddress;
    this.account = account;
    return account;
  }

  Future _createAndStoreAccount() async {
    final Account account = await algorandLib.client[AlgorandNet.mainnet]!.createAccount(); // use mainnet bc it does not matter
    address = account.publicAddress;
    await storeAccount(account);
  }

  Future storeAccount(Account? account) async {
    if(this.account is Account){
      account ??= this.account;
    }
    if(account is Account) {
      final List<int> privateKeyBytes = await account.keyPair.extractPrivateKeyBytes();
      final String privateKey = base64Encode(privateKeyBytes);
      // set
      _numAccount = await accountService.getNumLocalAccounts();
      final storageAccountKey = 'account_$_numAccount';
      final newNumAccounts = _numAccount + 1;
      await storage.write('num_accounts', newNumAccounts.toString());
      await storage.write(storageAccountKey, privateKey);
    }
  }

  late int _numAccount;
  final SecureStorage storage;
  final AlgorandLib algorandLib;
}
