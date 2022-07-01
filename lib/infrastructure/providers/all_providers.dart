// TODO break up file into multiple files

import 'dart:async';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/combine_queues.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../ui/screens/locked_user/lock_watch_widget.dart';
import '../data_access_layer/accounts/abstract_account.dart';
import '../data_access_layer/repository/algorand_service.dart';
import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/repository/secure_storage_service.dart';
import '../models/meeting_history_model.dart';
import 'add_bid_provider/add_bid_page_view_model.dart';
import 'app_settings_provider/app_setting_model.dart';
import 'faq_cv_provider/faq_provider.dart';
import 'locked_user_provider/locked_user_view_model.dart';
import 'my_account_provider/my_account_page_view_model.dart';
import 'my_user_provider/my_user_page_view_model.dart';
import 'ringing_provider/ringing_page_view_model.dart';
import 'setup_user_provider/setup_user_view_model.dart';
import 'user_bid_provider/user_page_view_model.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FirestoreDatabase>((ref) => FirestoreDatabase());

/*final fireBaseMessagingProvider = Provider<FireBaseMessagingService>((ref) => FireBaseMessagingService());*/

final accountServiceProvider = Provider((ref) {
  final algorandLib = ref.watch(algorandLibProvider);
  final storage = ref.watch(storageProvider);
  return AccountService(algorandLib: algorandLib, storage: storage);
});

final myUIDProvider = Provider((ref) {
  final authUser = ref.watch(authStateChangesProvider);
  return authUser.when(data: (user) => user?.uid, loading: () => null, error: (_, __) => null);
});
final userProvider = StreamProvider.family<UserModel, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.userStream(uid: uid);
});
final userPageViewModelProvider = Provider.family<UserPageViewModel?, String>((ref, uid) {
  // log('userPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('userPageViewModelProvider - functions=$functions');
  final user = ref.watch(userProvider(uid));
  // log('userPageViewModelProvider - user=$user');
  if (user is AsyncLoading) return null;
  return UserPageViewModel(functions: functions, user: user.asData!.value);
});

final searchFilterProvider = StateProvider((ref) => const <String>[]);
final searchUsersStreamProvider = StreamProvider.autoDispose<List<UserModel?>>((ref) {
  // log('usersStreamProvider');
  final database = ref.watch(databaseProvider);
  // log('usersStreamProvider - database=$database');
  final filter = ref.watch(searchFilterProvider.state).state;
  return database.usersStream(tags: filter);
});

final setupUserViewModelProvider = ChangeNotifierProvider<SetupUserViewModel>((ref) {
  // log('setupUserViewModelProvider');
  final auth = ref.watch(firebaseAuthProvider);
  // log('setupUserViewModelProvider - auth=$auth');
  final database = ref.watch(databaseProvider);
  // log('setupUserViewModelProvider - database=$database');
  final algorandLib = ref.watch(algorandLibProvider);
  final storage = ref.watch(storageProvider);
  final accountService = ref.watch(accountServiceProvider);
  final algorand = ref.watch(algorandProvider);

  final GoogleSignIn googleSignIn = GoogleSignIn();
  // final firebaseMessagingService  = ref.watch(fireBaseMessagingProvider);
  // log('setupUserViewModelProvider - database=$database');
  return SetupUserViewModel(
      auth: auth,
      database: database,
      algorandLib: algorandLib,
      algorand: algorand,
      storage: storage,
      googleSignIn: googleSignIn,
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
  final meetingChanger = ref.watch(meetingChangerProvider);
  // log('algorandProvider - functions=$functions');
  return AlgorandService(storage: storage, functions: functions, accountService: accountService, algorandLib: algorandLib, meetingChanger: meetingChanger);
});

final appSettingProvider = ChangeNotifierProvider<AppSettingModel>((ref) {
  final storage = ref.watch(storageProvider);
  final database = ref.watch(databaseProvider);
  return AppSettingModel(storage: storage, firebaseDatabase: database);
});

final faqProvider = ChangeNotifierProvider<FAQProviderModel>((ref) {
  return FAQProviderModel();
});

final algorandLibProvider = Provider((ref) => AlgorandLib());

final myUserPageViewModelProvider = Provider((ref) {
  // log('myUserPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('myUserPageViewModelProvider - functions=$functions');
  final database = ref.watch(databaseProvider);
  // log('myUserPageViewModelProvider - database=$database');
  final uid = ref.watch(myUIDProvider)!;
  // log('myUserPageViewModelProvider - uid=$uid');
  final user = ref.watch(userProvider(uid));
  if (user is AsyncError || user is AsyncLoading) {
    return null;
  }

  // log('myUserPageViewModelProvider - user=$user');
  final userChanger = ref.watch(userChangerProvider);
  if (userChanger == null) return null;

  if (userChanger is AsyncError || userChanger is AsyncLoading) {
    return null;
  }

  final accountService = ref.watch(accountServiceProvider);

  // log('myUserPageViewModelProvider - 2');

  return MyUserPageViewModel(
    database: database,
    functions: functions,
    user: user.asData!.value,
    accountService: accountService,
    userChanger: userChanger,
  );
});

final isUserLocked = IsUserLocked(false);

final meetingProvider = StreamProvider.family<Meeting, String>((ref, id) {
  final database = ref.watch(databaseProvider);
  return database.meetingStream(id: id);
});

final topSpeedsProvider = StreamProvider<List<TopMeeting>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.topSpeedsStream();
});
final topDurationsProvider = StreamProvider<List<TopMeeting>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.topDurationsStream();
});

final meetingHistory = ChangeNotifierProvider.autoDispose<MeetingHistoryModel>((ref) {
  final database = ref.watch(databaseProvider);
  return MeetingHistoryModel(database: database);
});

final bidOutProvider = StreamProvider.family<BidOut?, String>((ref, bidIn) {
  final uid = ref.watch(myUIDProvider)!;
  final database = ref.watch(databaseProvider);
  return database.getBidOut(uid: uid, bidId: bidIn);
});
final bidInPublicProvider = StreamProvider.family<BidInPublic?, String>((ref, bidIn) {
  final uid = ref.watch(myUIDProvider)!;
  final database = ref.watch(databaseProvider);
  return database.getBidInPublic(uid: uid, bidId: bidIn);
});
final bidInPrivateProvider = StreamProvider.family<BidInPrivate?, String>((ref, bidIn) {
  final uid = ref.watch(myUIDProvider)!;
  final database = ref.watch(databaseProvider);
  return database.getBidInPrivate(uid: uid, bidId: bidIn);
});

final getBidFromMeeting = StreamProvider.family<BidInPrivate?, Meeting>((ref, meeting) {
  final database = ref.watch(databaseProvider);
  return database.getBidInPrivate(uid: meeting.B, bidId: meeting.id);
});

final bidInAndUserProvider = Provider.family<BidIn?, BidIn>((ref, bidIn) {
  final A = bidIn.private?.A;
  if (A == null) return null;
  final userAsyncValue = ref.watch(userProvider(A));
  if (userAsyncValue is AsyncLoading || userAsyncValue is AsyncError) {
    return null;
  }
  final user = userAsyncValue.value;
  return BidIn(public: bidIn.public, private: bidIn.private, user: user);
});

final bidOutsProvider = StreamProvider.family<List<BidOut>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.bidOutsStream(uid: uid);
});
final bidInsPublicProvider = StreamProvider.autoDispose.family<List<BidInPublic>?, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.bidInsPublicStream(uid: uid);
});
final bidInsPrivateProvider = StreamProvider.autoDispose.family<List<BidInPrivate>, String>((ref, uid) {
  StreamSubscription? streamController;
  ref.onDispose(() {
    streamController?.cancel();
  });
  final database = ref.watch(databaseProvider);
  var stream = database.bidInsPrivateStream(uid: uid);
  streamController = stream.listen((event) { });
  return stream;
});

final bidInsWithUsersProvider = Provider.autoDispose.family<List<BidIn>?, String>((ref, uid) {
  final bidIns = ref.watch(bidInsProvider(uid));
  if (bidIns == null) {
    return null;
  }

  final bidInsWithUsersTrial = bidIns.map((bid) {
    final bidInAndUser = ref.watch(bidInAndUserProvider(bid));
    if (bidInAndUser == null) {
      return null;
    }
    return bidInAndUser;
  }).toList();

  if (bidInsWithUsersTrial.any((element) => element == null)) {
    return null;
  }

  final bidInsWithUsers = bidInsWithUsersTrial.map((e) => e!).toList();

  return bidInsWithUsers;
});

final bidInsProvider = Provider.autoDispose.family<List<BidIn>?, String>((ref, uid) {
  // public bid ins
  final bidInsPublicAsyncValue = ref.watch(bidInsPublicProvider(uid));
  if (haveToWait(bidInsPublicAsyncValue) || bidInsPublicAsyncValue.value == null) {
    return null;
  }
  if (bidInsPublicAsyncValue.value!.isEmpty) {
    return <BidIn>[];
  }
  List<BidInPublic> bidInsPublic = bidInsPublicAsyncValue.value!;

  // my user
  final userAsyncValue = ref.watch(userProvider(uid));
  if (haveToWait(userAsyncValue) || userAsyncValue.value == null) {
    return null;
  }
  final user = userAsyncValue.value!;
  final bidInsPublicSorted = combineQueues(bidInsPublic, user.loungeHistory, user.loungeHistoryIndex);

  // private bid ins
  List<BidInPrivate> bidInsPrivate = [];
  var userId =ref.watch(myUIDProvider);
  if(userId == uid) {
    final bidInsPrivateAsyncValue = ref.watch(bidInsPrivateProvider(uid));
    if (haveToWait(bidInsPrivateAsyncValue) || bidInsPrivateAsyncValue.value == null) {
      return null;
    }
    bidInsPrivate = bidInsPrivateAsyncValue.value!;
  }

  // create bid ins
  final bidIns = BidIn.createList(bidInsPublicSorted, bidInsPrivate);
  return bidIns;
});

final lockedUserViewModelProvider = Provider<LockedUserViewModel?>(
  (ref) {
    final uid = ref.watch(myUIDProvider);
    if (uid == null) {
      return null;
    }
    final user = ref.watch(userProvider(uid));
    if (user is AsyncLoading || user is AsyncError) return null;

    if (user.value!.meeting == null) {
      isUserLocked.value = false;
      return null;
    }
    final String userMeeting = user.value!.meeting!;
    final meeting = ref.watch(meetingProvider(userMeeting));
    if (meeting is AsyncLoading || meeting is AsyncError) {
      isUserLocked.value = false;
      return null;
    }

    if (meeting.value?.active ?? false) {
      isUserLocked.value = true;
    } else {
      isUserLocked.value = false;
    }
    return LockedUserViewModel(user: user.asData!.value, meeting: meeting.asData!.value);
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
  // log('ringingPageViewModelProvider - user.asData!.value=${user.asData!.value}');
  // log('ringingPageViewModelProvider - user.asData!.value.meeting=${user.asData!.value.meeting}');
  if (user.asData!.value.meeting == null) return null;
  final String userMeeting = user.value!.meeting!;
  final meeting = ref.watch(meetingProvider(userMeeting));
  // log('ringingPageViewModelProvider - meeting=$meeting');

  if (meeting is AsyncLoading || meeting is AsyncError) return null;

  final amA = meeting.asData!.value.A == user.asData!.value.id;
  final otherUserId = amA ? meeting.asData!.value.B : meeting.asData!.value.A;
  final otherUser = ref.watch(userProvider(otherUserId));
  if (otherUser is AsyncLoading || otherUser is AsyncError) return null;

  final functions = ref.watch(firebaseFunctionsProvider);
  // log('lockedUserViewModelProvider - functions=$functions');

  final userChanger = ref.watch(userChangerProvider);
  if (userChanger == null) return null;

  final meetingChanger = ref.watch(meetingChangerProvider);

  return RingingPageViewModel(
      user: user.asData!.value,
      otherUser: otherUser.asData!.value,
      algorand: algorand,
      functions: functions,
      meetingChanger: meetingChanger,
      userChanger: userChanger,
      meeting: meeting.asData!.value);
});

final addBidPageViewModelProvider = StateProvider.family<AddBidPageViewModel?, UserModel>((ref, B) {
  // log('addBidPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('addBidPageViewModelProvider - functions=$functions');
  final algorand = ref.watch(algorandProvider);
  // log('addBidPageViewModelProvider - algorandTestnet=$algorand');

  final accounts = ref.watch(accountsProvider);
  if (accounts is AsyncLoading) return null;

  final accountService = ref.watch(accountServiceProvider);

  final database = ref.watch(databaseProvider);

  final myUid = ref.watch(myUIDProvider);
  if (myUid == null) return null;

  return AddBidPageViewModel(
      A: myUid, database: database, functions: functions, algorand: algorand, accounts: accounts.value!, accountService: accountService, B: B);
});

final accountsProvider = FutureProvider((ref) {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getAllAccounts();
});

final myAccountPageViewModelProvider = ChangeNotifierProvider<MyAccountPageViewModel>((ref) {
  final database = ref.watch(databaseProvider);
  final uid = ref.watch(myUIDProvider);
  return MyAccountPageViewModel(ref: ref, uid: uid, database: database);
});

// final createLocalAccountProvider = FutureProvider(
//   (ref) async {
//     final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
//     LocalAccount account = await myAccountPageViewModel.addLocalAccount();
//     return account;
//   },
// );

final userChangerProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  final uid = ref.watch(myUIDProvider);
  if (uid == null) return null;
  return UserModelChanger(database, uid);
});
final meetingChangerProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return MeetingChanger(database);
});

//Rating Module
final ratingListProvider = StreamProvider.family<List<RatingModel>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.getUserRatings(uid);
});
