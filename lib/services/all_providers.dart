// TODO break up file into multiple files

import 'package:app_2i2i/accounts/abstract_account.dart';
import 'package:app_2i2i/accounts/local_account.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/pages/account/provider/my_account_page_view_model.dart';
import 'package:app_2i2i/pages/add_bid/provider/add_bid_page_view_model.dart';
import 'package:app_2i2i/pages/app_settings/ui/provider/app_setting_model.dart';
import 'package:app_2i2i/pages/locked_user/provider/locked_user_view_model.dart';
import 'package:app_2i2i/pages/locked_user/ui/lock_watch_widget.dart';
import 'package:app_2i2i/pages/my_user/provider/my_user_page_view_model.dart';
import 'package:app_2i2i/pages/ringing/provider/ringing_page_view_model.dart';
import 'package:app_2i2i/pages/setup_user/provider/setup_user_view_model.dart';
import 'package:app_2i2i/pages/user_bid/provider/user_page_view_model.dart';
import 'package:app_2i2i/repository/algorand_service.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firebaseFunctionsProvider =
    Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider =
    Provider<FirestoreDatabase>((ref) => FirestoreDatabase());

/*final fireBaseMessagingProvider = Provider<FireBaseMessagingService>((ref) => FireBaseMessagingService());*/

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
  // final firebaseMessagingService  = ref.watch(fireBaseMessagingProvider);
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

final appSettingProvider =
    ChangeNotifierProvider<AppSettingModel>((ref) {
  final storage = ref.watch(storageProvider);
  return AppSettingModel(storage: storage);
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
  final userModelChanger = ref.watch(userModelChangerProvider);
  if (userModelChanger == null) return null;

  if (user is AsyncError || user is AsyncLoading) {
    return null;
  }

  final accountService = ref.watch(accountServiceProvider);

  // log('myUserPageViewModelProvider - 2');

  return MyUserPageViewModel(
      database: database,
      functions: functions,
      user: user.data!.value,
      accountService: accountService,
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

final lockedUserViewModelProvider = Provider<LockedUserViewModel?>(
  (ref) {
    final uid = ref.watch(myUIDProvider)!;
    final user = ref.watch(userProvider(uid));
    log(F + ' $user');
    if (user is AsyncLoading || user is AsyncError) return null;

    if (user.data!.value.currentMeeting == null) return null;
    final String currentMeeting = user.data!.value.currentMeeting!;
    final meeting = ref.watch(meetingProvider(currentMeeting));
    if (meeting is AsyncLoading || meeting is AsyncError) return null;
    return LockedUserViewModel(
        user: user.data!.value, meeting: meeting.data!.value);
  },
);

final ringingPageViewModelProvider = Provider<RingingPageViewModel?>((ref) {
  // log('ringingPageViewModelProvider');
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

  final amA = meeting.data!.value.A == user.data!.value.id;
  final otherUserId = amA ? meeting.data!.value.B : meeting.data!.value.A;
  final otherUser = ref.watch(userProvider(otherUserId));
  if (otherUser is AsyncLoading || otherUser is AsyncError) return null;

  final functions = ref.watch(firebaseFunctionsProvider);
  // log('lockedUserViewModelProvider - functions=$functions');

  return RingingPageViewModel(
      user: user.data!.value,
      otherUser: otherUser.data!.value,
      algorand: algorand,
      functions: functions,
      meeting: meeting.data!.value);
});

final addBidPageViewModelProvider =
    StateProvider.family<AddBidPageViewModel?, String>((ref, uid) {
  // log('addBidPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('addBidPageViewModelProvider - functions=$functions');
  final algorand = ref.watch(algorandProvider);
  // log('addBidPageViewModelProvider - algorandTestnet=$algorand');
  final user = ref.watch(userProvider(uid));
  // log('addBidPageViewModelProvider - user=$user');
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

final myAccountPageViewModelProvider =
    ChangeNotifierProvider<MyAccountPageViewModel>(
        (ref) => MyAccountPageViewModel(ref));

final userModelChangerProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  final uid = ref.watch(myUIDProvider);
  if (uid == null) return null;
  return UserModelChanger(database, uid);
});

final numAccountsProvider = FutureProvider((ref) {
  log('numAccountsProvider');
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getNumAccounts();
});
