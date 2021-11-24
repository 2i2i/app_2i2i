// TODO break up file into multiple files

import 'package:algorand_dart/algorand_dart.dart';
import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/account/ui/account_info.dart';
import 'package:app_2i2i/pages/account/provider/my_account_page_view_model.dart';
import 'package:app_2i2i/app/home/search/add_bid_page_view_model.dart';
import 'package:app_2i2i/app/home/search/user_page_view_model.dart';
import 'package:app_2i2i/app/locked_user/lock_watch_widget.dart';
import 'package:app_2i2i/app/locked_user/locked_user_view_model.dart';
import 'package:app_2i2i/pages/my_user/my_user_page_view_model.dart';
import 'package:app_2i2i/pages/ringing/ringing_page_view_model.dart';
import 'package:app_2i2i/pages/setup_user/provider/setup_user_view_model.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_2i2i/repository/firestore_database.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firebaseFunctionsProvider =
    Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider =
    Provider<FirestoreDatabase>((ref) => FirestoreDatabase());

final myAuthUserProvider = authStateChangesProvider;

final accountServiceProvider = Provider((ref) {
  final algorandLib = ref.watch(algorandLibProvider);
  final storage = ref.watch(storageProvider);
  return AccountService(algorandLib: algorandLib, storage: storage);
});

final myUIDProvider = Provider((ref) {
  final authUser = ref.watch(authStateChangesProvider);
  return authUser.when(
      data: (user) => user?.uid, loading: () => null, error: (_, __) => null);
});
final userProvider = StreamProvider.family<UserModel, String>((ref, uid) {
  // log('userProvider');
  final database = ref.watch(databaseProvider);
  // log('userProvider - database=$database');
  return database.userStream(uid: uid);
});
final userPrivateProvider =
    StreamProvider.autoDispose.family<UserModelPrivate, String>((ref, uid) {
  // log('userPrivateProvider');
  final database = ref.watch(databaseProvider);
  // log('userPrivateProvider - database=$database');
  return database.userPrivateStream(uid: uid);
});

final userPageViewModelProvider =
    Provider.family<UserPageViewModel?, String>((ref, uid) {
  // log('userPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('userPageViewModelProvider - functions=$functions');
  final user = ref.watch(userProvider(uid));
  // log('userPageViewModelProvider - user=$user');
  if (user is AsyncLoading) return null;
  return UserPageViewModel(functions: functions, user: user.data!.value);
});

final usersStreamProvider = StreamProvider.autoDispose<List<UserModel?>>((ref) {
  // log('usersStreamProvider');
  final database = ref.watch(databaseProvider);
  // log('usersStreamProvider - database=$database');
  return database.usersStream();
});
final searchFilterProvider = StateProvider((ref) => const <String>[]);
final searchUsersStreamProvider =
    StreamProvider.autoDispose<List<UserModel?>>((ref) {
  // log('usersStreamProvider');
  final database = ref.watch(databaseProvider);
  // log('usersStreamProvider - database=$database');
  final filter = ref.watch(searchFilterProvider).state;
  return database.usersStream(tags: filter);
});

final bidStreamProvider =
    StreamProvider.autoDispose.family<Bid, String>((ref, id) {
  // log('bidStreamProvider');
  final database = ref.watch(databaseProvider);
  // log('bidStreamProvider - database=$database');
  return database.bidStream(id: id);
});

final setupUserViewModelProvider =
    ChangeNotifierProvider<SetupUserViewModel>((ref) {
  // log('setupUserViewModelProvider');
  final auth = ref.watch(firebaseAuthProvider);
  // log('setupUserViewModelProvider - auth=$auth');
  final database = ref.watch(databaseProvider);
  // log('setupUserViewModelProvider - database=$database');
  final algorandLib = ref.watch(algorandLibProvider);
  final storage = ref.watch(storageProvider);
  final accountService = ref.watch(accountServiceProvider);
  final algorand = ref.watch(algorandProvider);
  // log('setupUserViewModelProvider - database=$database');
  return SetupUserViewModel(
      auth: auth,
      database: database,
      algorandLib: algorandLib,
      algorand: algorand,
      storage: storage,
      accountService: accountService);
});

final storageProvider = Provider((ref) => SecureStorage());

final algorandProvider = Provider((ref) {
  // log('algorandProvider');
  final storage = ref.watch(storageProvider);
  // log('algorandProvider - storage=$storage');
  final functions = ref.watch(firebaseFunctionsProvider);
  final accountService = ref.watch(accountServiceProvider);
  final algorandLib = ref.watch(algorandLibProvider);
  // log('algorandProvider - functions=$functions');
  return AlgorandService(
      storage: storage,
      functions: functions,
      accountService: accountService,
      algorandLib: algorandLib);
});

final algorandLibProvider = Provider((ref) => AlgorandLib());

final algorandAddressProvider =
    FutureProvider.family<String, int>((ref, numAccount) async {
  // does not matter which net we use here
  // log('algorandAddressProvider');
  final accountService = ref.watch(accountServiceProvider);
  final algorandLib = ref.watch(algorandLibProvider);
  final storage = ref.watch(storageProvider);
  final account = await LocalAccount.fromNumAccount(
      numAccount: numAccount,
      algorandLib: algorandLib,
      storage: storage,
      accountService: accountService);
  return account.address;
});

final myUserPageViewModelProvider = Provider((ref) {
  // log('myUserPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('myUserPageViewModelProvider - functions=$functions');
  final database = ref.watch(databaseProvider);
  // log('myUserPageViewModelProvider - database=$database');
  final uid = ref.watch(myUIDProvider)!;
  // log('myUserPageViewModelProvider - uid=$uid');
  final user = ref.watch(userProvider(uid));
  // log('myUserPageViewModelProvider - user=$user');
  final algorandAddress = ref.watch(algorandAddressProvider(0));
  // log('myUserPageViewModelProvider - algorandAddress=$algorandAddress');
  final userModelChanger = ref.watch(userModelChangerProvider);
  if (userModelChanger == null) return null;

  if (algorandAddress is AsyncError ||
      user is AsyncError ||
      algorandAddress is AsyncLoading ||
      user is AsyncLoading) {
    return null;
  }

  // log('myUserPageViewModelProvider - 2');

  return MyUserPageViewModel(
      database: database,
      functions: functions,
      user: user.data!.value,
      algorandAddress: algorandAddress.data!.value,
      userModelChanger: userModelChanger);
});

final isUserLocked = IsUserLocked(false);
final myUserLockedProvider = Provider((ref) {
  // log('myUserLockedProvider');
  final uid = ref.watch(myUIDProvider)!;
  // log('myUserLockedProvider - uid=$uid');
  final user = ref.watch(userProvider(uid));
  // log('myUserLockedProvider - user=$user');

  if (user is AsyncError || user is AsyncLoading) {
    isUserLocked.changeValue(false);
    return false;
  }
  // log('myUserLockedProvider - 2');
  final UserModel myUser = user.data!.value;
  // log('myUserLockedProvider - myUser=$myUser');
  if (!myUser.locked) {
    isUserLocked.changeValue(false);
    return false;
  }
  // log('myUserLockedProvider - 3');

  isUserLocked.changeValue(true);
  return true;
});

final meetingProvider = StreamProvider.family<Meeting, String>((ref, id) {
  // log('meetingProvider');
  final database = ref.watch(databaseProvider);
  // log('meetingProvider - database=$database');
  return database.meetingStream(id: id);
});

// final currentMeetingIdProvider = Provider((ref) {
//   final uid = ref.watch(myUIDProvider);
//   if (uid == null) return null;

//   final user = ref.watch(userProvider(uid));
//   if (user is AsyncLoading) return null;

//   return user.data?.value.currentMeeting;
// });

final lockedUserViewModelProvider = Provider<LockedUserViewModel?>((ref) {
  // log('lockedUserViewModelProvider');
  // final database = ref.watch(databaseProvider);
  // log('lockedUserViewModelProvider - database=$database');
  // final algorand = ref.watch(algorandProvider(AlgorandNet.testnet));
  // log('lockedUserViewModelProvider - algorand=$algorand');
  final uid = ref.watch(myUIDProvider)!;
  // log('lockedUserViewModelProvider - uid=$uid');
  final user = ref.watch(userProvider(uid));
  // log('lockedUserViewModelProvider - user=$user');

  if (user is AsyncLoading || user is AsyncError) return null;

  // log('lockedUserViewModelProvider - user.data=${user.data}');
  // log('lockedUserViewModelProvider - user.data!.value=${user.data!.value}');
  // log('lockedUserViewModelProvider - user.data!.value.currentMeeting=${user.data!.value.currentMeeting}');
  if (user.data!.value.currentMeeting == null) return null;
  final String currentMeeting = user.data!.value.currentMeeting!;
  // log('lockedUserViewModelProvider - currentMeeting=$currentMeeting');
  final meeting = ref.watch(meetingProvider(currentMeeting));
  // log('lockedUserViewMrodelProvider - meeting=$meeting');

  if (meeting is AsyncLoading || meeting is AsyncError) return null;

  return LockedUserViewModel(
      user: user.data!.value, meeting: meeting.data!.value);
});

final ringingPageViewModelProvider = Provider<RingingPageViewModel?>((ref) {
  // log('ringingPageViewModelProvider');
  // final database = ref.watch(databaseProvider);
  // log('ringingPageViewModelProvider - database=$database');
  final algorand = ref.watch(algorandProvider);
  // log('lockedUserViewModelProvider - algorand=$algorand');
  final uid = ref.watch(myUIDProvider)!;
  // log('ringingPageViewModelProvider - uid=$uid');
  final user = ref.watch(userProvider(uid));
  // log('ringingPageViewModelProvider - user=$user');

  if (user is AsyncLoading || user is AsyncError) return null;

  // log('ringingPageViewModelProvider - user.data=${user.data}');
  // log('ringingPageViewModelProvider - user.data!.value=${user.data!.value}');
  // log('ringingPageViewModelProvider - user.data!.value.currentMeeting=${user.data!.value.currentMeeting}');
  if (user.data!.value.currentMeeting == null) return null;
  final String currentMeeting = user.data!.value.currentMeeting!;
  // log('ringingPageViewModelProvider - currentMeeting=$currentMeeting');
  final meeting = ref.watch(meetingProvider(currentMeeting));
  // log('ringingPageViewModelProvider - meeting=$meeting');

  if (meeting is AsyncLoading || meeting is AsyncError) return null;

  final functions = ref.watch(firebaseFunctionsProvider);
  // log('lockedUserViewModelProvider - functions=$functions');

  return RingingPageViewModel(
      user: user.data!.value,
      algorand: algorand,
      functions: functions,
      meeting: meeting.data!.value);
});

final addBidPageViewModelProvider =
    StateProvider.family<AddBidPageViewModel?, String>((ref, uid) {
  log('addBidPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  log('addBidPageViewModelProvider - functions=$functions');
  // final algorandMainnet = ref.watch(algorandProvider(AlgorandNet.mainnet));
  // log('addBidPageViewModelProvider - algorandMainnet=$algorandMainnet');
  // if (algorandMainnet is AsyncLoading) return null;
  final algorand = ref.watch(algorandProvider);
  log('addBidPageViewModelProvider - algorandTestnet=$algorand');
  // if (algorandTestnet is AsyncLoading) return null;
  final user = ref.watch(userProvider(uid));
  log('addBidPageViewModelProvider - user=$user');
  if (user is AsyncLoading) return null;

  final accounts = ref.watch(accountsProvider);
  if (accounts is AsyncLoading) return null;

  final accountService = ref.watch(accountServiceProvider);

  return AddBidPageViewModel(
      functions: functions,
      algorand: algorand,
      accounts: accounts.data!.value,
      accountService: accountService,
      user: user.data!.value);
});

final accountsProvider = FutureProvider((ref) {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getAllAccounts();
});

// final balancesMainnetProvider = FutureProvider((ref) {
//   final algorandMainnet = ref.watch(algorandProvider(AlgorandNet.mainnet));
//   return algorandMainnet.getAssetHoldings();
// });
// final balancesTestnetProvider = FutureProvider<List<List<AssetHolding>>>((ref) {
//   // log('balancesTestnetProvider');
//   final algorandTestnet = ref.watch(algorandProvider);
//   // log('balancesTestnetProvider - algorandTestnet=$algorandTestnet');
//   return algorandTestnet.getAllAssetHoldings();
// });

final myAccountPageViewModelProvider = Provider((ref) {
  // log('myAccountPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('myAccountPageViewModelProvider - functions=$functions');
  final algorandLib = ref.watch(algorandLibProvider);

  // log('myAccountPageViewModelProvider - algorandTestnet=$algorandTestnet');
  final numAccounts = ref.watch(numAccountsProvider);
  // log('myAccountPageViewModelProvider - numAccounts=$numAccounts');
  if (numAccounts is AsyncLoading) return null;

  final storage = ref.watch(storageProvider);
  final accountService = ref.watch(accountServiceProvider);

  return MyAccountPageViewModel(
      functions: functions,
      algorandLib: algorandLib,
      storage: storage,
      accountService: accountService,
      numAccounts: numAccounts.data!.value);
});

final userModelChangerProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  final uid = ref.watch(myUIDProvider);
  if (uid == null) return null;
  return UserModelChanger(database, uid);
});

final accountInfoViewModelProvider =
    Provider.family<AccountInfoViewModel?, int>((ref, numAccount) {
  final algorand = ref.watch(algorandProvider);
  final account = ref.watch(accountProvider(numAccount));
  if (account is AsyncLoading) return null;
  return AccountInfoViewModel(account: account.data!.value, algorand: algorand);
});

final accountProvider =
    FutureProvider.family<AbstractAccount, int>((ref, numAccount) {
  final accountService = ref.watch(accountServiceProvider);
  final algorandLib = ref.watch(algorandLibProvider);
  final storage = ref.watch(storageProvider);
  return LocalAccount.fromNumAccount(
      numAccount: numAccount,
      algorandLib: algorandLib,
      storage: storage,
      accountService: accountService);
});

final numAccountsProvider = FutureProvider((ref) {
  log('numAccountsProvider');
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getNumAccounts();
});
