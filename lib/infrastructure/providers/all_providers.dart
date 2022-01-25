// TODO break up file into multiple files

import 'dart:collection';
import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/screens/locked_user/lock_watch_widget.dart';
import '../data_access_layer/accounts/abstract_account.dart';
import '../data_access_layer/accounts/local_account.dart';
import '../data_access_layer/repository/algorand_service.dart';
import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/repository/secure_storage_service.dart';
import '../data_access_layer/services/logging.dart';
import 'add_bid_provider/add_bid_page_view_model.dart';
import 'app_settings_provider/app_setting_model.dart';
import 'hangout_bid_provider/hangout_page_view_model.dart';
import 'history_provider/history_view_model.dart';
import 'locked_hangout_provider/locked_hangout_view_model.dart';
import 'my_account_provider/my_account_page_view_model.dart';
import 'my_hangout_provider/my_hangout_page_view_model.dart';
import 'ringing_provider/ringing_page_view_model.dart';
import 'setup_hangout_provider/setup_hangout_view_model.dart';
import 'web_rtc_provider/call_screen_provider.dart';

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
final hangoutProvider = StreamProvider.family<Hangout, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
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
    Provider.family<HangoutPageViewModel?, String>((ref, uid) {
  // log('userPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('userPageViewModelProvider - functions=$functions');
  final user = ref.watch(hangoutProvider(uid));
  // log('userPageViewModelProvider - user=$user');
  if (user is AsyncLoading) return null;
  return HangoutPageViewModel(
      functions: functions, hangout: user.asData!.value);
});

final usersStreamProvider = StreamProvider.autoDispose<List<Hangout?>>((ref) {
  // log('usersStreamProvider');
  final database = ref.watch(databaseProvider);
  // log('usersStreamProvider - database=$database');
  return database.usersStream();
});
final searchFilterProvider = StateProvider((ref) => const <String>[]);
final searchUsersStreamProvider =
    StreamProvider.autoDispose<List<Hangout?>>((ref) {
  // log('usersStreamProvider');
  final database = ref.watch(databaseProvider);
  // log('usersStreamProvider - database=$database');
  final filter = ref.watch(searchFilterProvider.state).state;
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
  final meetingChanger = ref.watch(meetingChangerProvider);
  // log('algorandProvider - functions=$functions');
  return AlgorandService(
      storage: storage,
      functions: functions,
      accountService: accountService,
      algorandLib: algorandLib,
      meetingChanger: meetingChanger);
});

final appSettingProvider = ChangeNotifierProvider<AppSettingModel>((ref) {
  final storage = ref.watch(storageProvider);
  return AppSettingModel(storage: storage);
});

final callScreenProvider =
    ChangeNotifierProvider<CallScreenModel>((ref) => CallScreenModel());

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

final myHangoutPageViewModelProvider = Provider((ref) {
  // log('myUserPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('myUserPageViewModelProvider - functions=$functions');
  final database = ref.watch(databaseProvider);
  // log('myUserPageViewModelProvider - database=$database');
  final uid = ref.watch(myUIDProvider)!;
  // log('myUserPageViewModelProvider - uid=$uid');
  final hangout = ref.watch(hangoutProvider(uid));
  // log('myUserPageViewModelProvider - user=$user');
  final hangoutChanger = ref.watch(hangoutChangerProvider);
  if (hangoutChanger == null) return null;

  if (hangoutChanger is AsyncError || hangoutChanger is AsyncLoading) {
    return null;
  }

  final accountService = ref.watch(accountServiceProvider);

  // log('myUserPageViewModelProvider - 2');

  return MyHangoutPageViewModel(
    database: database,
    functions: functions,
    hangout: hangout.asData?.value,
    accountService: accountService,
    hangoutChanger: hangoutChanger,
  );
});

final isUserLocked = IsUserLocked(false);
final myUserLockedProvider = Provider((ref) {
  // log('myUserLockedProvider');
  final uid = ref.watch(myUIDProvider)!;
  // log('myUserLockedProvider - uid=$uid');
  final user = ref.watch(hangoutProvider(uid));
  // log('myUserLockedProvider - user=$user');

  if (user is AsyncError || user is AsyncLoading) {
    isUserLocked.changeValue(false);
    return false;
  }
  // log('myUserLockedProvider - 2');
  final Hangout myUser = user.asData!.value;
  // log('myUserLockedProvider - myUser=$myUser');
  if (!myUser.isInMeeting()) {
    isUserLocked.changeValue(false);
    return false;
  }
  // log('myUserLockedProvider - 3');

  isUserLocked.changeValue(true);
  return true;
});

final meetingProvider = StreamProvider.family<Meeting, String>((ref, id) {
  final database = ref.watch(databaseProvider);
  return database.meetingStream(id: id);
});

final topSpeedsProvider = FutureProvider((ref) async {
  final functions = ref.watch(firebaseFunctionsProvider);
  final HttpsCallable topSpeedMeetings =
      functions.httpsCallable('topSpeedMeetings');
  final topMeetingsData = await topSpeedMeetings();
  final topMeetings = topMeetingsData.data as List;
  return topMeetings
      .map((topMeeting) => TopMeeting.fromMap(topMeeting))
      .toList();
});
final topDurationsProvider = FutureProvider((ref) async {
  final functions = ref.watch(firebaseFunctionsProvider);
  final HttpsCallable topDurationMeetings =
      functions.httpsCallable('topDurationMeetings');
  final topMeetingsData = await topDurationMeetings();
  final topMeetings = topMeetingsData.data as List;
  return topMeetings
      .map((topMeeting) => TopMeeting.fromMap(topMeeting))
      .toList();
});

final meetingHistoryA =
    StreamProvider.family<List<Meeting>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.meetingHistoryA(uid);
});

final meetingHistoryB =
    StreamProvider.family<List<Meeting>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.meetingHistoryB(uid);
});

// class IntString {
//   final int
// }
final meetingHistoryBLimited =
    StreamProvider.family<List<Meeting>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.meetingHistoryB(uid);
});

final bidInProvider = StreamProvider.family<BidInPublic?, String>((ref, bidIn) {
  final uid = ref.watch(myUIDProvider)!;
  final database = ref.watch(databaseProvider);
  return database.getBidInPublic(uid: uid, bidId: bidIn);
});
final bidInPrivateProvider =
    StreamProvider.family<BidInPrivate?, String>((ref, bidIn) {
  final uid = ref.watch(myUIDProvider)!;
  final database = ref.watch(databaseProvider);
  return database.getBidInPrivate(uid: uid, bidId: bidIn);
});

final bidInAndUserProvider = Provider.family<BidIn?, BidIn>((ref, bidIn) {
  final A = bidIn.private?.A;
  if (A == null) return null;
  final userAsyncValue = ref.watch(hangoutProvider(A));
  if (userAsyncValue is AsyncLoading || userAsyncValue is AsyncError) {
    return null;
  }
  final hangout = userAsyncValue.asData!.value;
  return BidIn(public: bidIn.public, private: bidIn.private, hangout: hangout);
});

final bidOutsProvider = StreamProvider.family<List<BidOut>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.bidOutsStream(uid: uid);
});
final bidInsPublicProvider =
    StreamProvider.family<List<BidInPublic>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.bidInsPublicStream(uid: uid);
});
final bidInsPrivateProvider =
    StreamProvider.family<List<BidInPrivate>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.bidInsPrivateStream(uid: uid);
});

final bidInsProvider =
    Provider.autoDispose.family<List<BidIn>?, String>((ref, uid) {
  // public bid ins
  final bidInsPublicAsyncValue = ref.watch(bidInsPublicProvider(uid));
  if (haveToWait(bidInsPublicAsyncValue) ||
      bidInsPublicAsyncValue.value == null) {
    return null;
  }
  if (bidInsPublicAsyncValue.value!.isEmpty) {
    return <BidIn>[];
  }
  List<BidInPublic> bidInsPublic = bidInsPublicAsyncValue.value!;

  // private bid ins
  final bidInsPrivateAsyncValue = ref.watch(bidInsPrivateProvider(uid));
  if (haveToWait(bidInsPrivateAsyncValue) ||
      bidInsPrivateAsyncValue.value == null) {
    return null;
  }
  List<BidInPrivate> bidInsPrivate = bidInsPrivateAsyncValue.value!;

  // create bid ins
  final bidIns = BidIn.createList(bidInsPublic, bidInsPrivate);
  final bidInsWithUsersTrial =
      bidIns.map((bid) => ref.watch(bidInAndUserProvider(bid))).toList();
  if (bidInsWithUsersTrial.any((element) => element == null)) return null;
  final bidInsWithUsers = bidInsWithUsersTrial.map((e) => e!).toList();

  List<BidIn> bidInsChronies = bidInsWithUsers
      .where((bidIn) => bidIn.public.speed.num == bidIn.public.rule.minSpeed)
      .toList();
  List<BidIn> bidInsHighRollers = bidInsWithUsers
      .where((bidIn) => bidIn.public.rule.minSpeed < bidIn.public.speed.num)
      .toList();
  if (bidInsChronies.length + bidInsHighRollers.length != bidIns.length)
    throw Exception(
        'UserBidInsList: bidInsChronies.length + bidInsHighRollers.length != bidIns.length');

  bidInsHighRollers.sort((b1, b2) {
    return b1.public.speed.num.compareTo(b2.public.speed.num);
  });

  // if one side empty, return other side
  if (bidInsHighRollers.isEmpty)
    return bidInsChronies;
  else if (bidInsChronies.isEmpty) return bidInsHighRollers;

  // my hangout
  final hangoutAsyncValue = ref.watch(hangoutProvider(uid));
  if (haveToWait(hangoutAsyncValue) || hangoutAsyncValue.value == null) {
    return null;
  }
  final hangout = hangoutAsyncValue.value!;

  List<BidIn> bidInsSorted = [];
  Queue<int> recentLoungesHistory = Queue();
  int chronyIndex = 0;
  int highRollerIndex = 0;
  int loungeSum = 0;
  while (
      bidInsSorted.length < bidInsChronies.length + bidInsHighRollers.length) {
    BidIn nextChrony = bidInsChronies[chronyIndex];
    BidIn nextHighroller = bidInsHighRollers[highRollerIndex];

    // next rule comes from the earlier guest if different
    HangOutRule nextRule = nextChrony.public.rule == nextHighroller.public.rule
        ? nextChrony.public.rule
        : (nextChrony.public.ts.microsecondsSinceEpoch <
                nextHighroller.public.ts.microsecondsSinceEpoch
            ? nextChrony.public.rule
            : nextHighroller.public.rule);
    final N = nextRule.importance.values
        .fold(0, (int previousValue, int element) => previousValue + element);
    double targetChronyRatio = nextRule.importance[Lounge.chrony]! / N;

    // is nextChrony eligible according to nextRule
    if (nextChrony.public.speed.num < nextRule.minSpeed) {
      // choose HighRoller
      bidInsSorted.add(nextHighroller);
      final value = 1;
      recentLoungesHistory.addLast(value);
      loungeSum += value;
      highRollerIndex += 1;

      // if highrollers done, add remaining chronies and done
      if (highRollerIndex == bidInsHighRollers.length) {
        for (int i = chronyIndex; i < bidInsChronies.length; i++) {
          bidInsSorted.add(bidInsChronies[i]);
          return bidInsSorted;
        }
      }

      // move to next index
      continue;
    }

    // first calc  of loungeSum
    if (recentLoungesHistory.length < N) {
      // should only arrive here first time
      if (hangout.loungeHistory.isNotEmpty) {
        final loungeHistoryList = hangout.loungeHistory
            .map((l) => Lounge.values.indexWhere((e) => e.toStringEnum() == l))
            .toList();
        final loungeHistoryIndex = hangout.loungeHistoryIndex;
        final end = loungeHistoryIndex;
        final start = (end - N + 1) % loungeHistoryList.length;

        final N_tile = min(loungeHistoryList.length, N);
        int i = start;
        while (recentLoungesHistory.length < N_tile) {
          recentLoungesHistory.addLast(loungeHistoryList[i]);
          i--;
          i %= loungeHistoryList.length;
        }

        loungeSum = recentLoungesHistory.fold(
            0, (int previousValue, int element) => previousValue + element);
      }
    }

    // update loungeSum
    if (recentLoungesHistory.length == N) {
      loungeSum -= recentLoungesHistory.removeFirst();
    }
    final M = recentLoungesHistory.length + 1;
    int loungeSumChrony = loungeSum + 0;
    int loungeSumHighroller = loungeSum + 1;
    double ifChronyRatio = 1.0 - loungeSumChrony / M;
    double ifHighrollerRatio = 1.0 - loungeSumHighroller / M;
    double ifChronyError = (ifChronyRatio - targetChronyRatio).abs();
    double ifHighrollerError = (ifHighrollerRatio - targetChronyRatio).abs();
    if (ifChronyError <= ifHighrollerError) {
      // choose chrony
      bidInsSorted.add(nextChrony);
      final value = 0;
      recentLoungesHistory.addLast(value);
      // loungeSum += value;
      chronyIndex += 1;

      // if chronies done, add remaining highrollers and done
      if (chronyIndex == bidInsChronies.length) {
        for (int i = highRollerIndex; i < bidInsHighRollers.length; i++) {
          bidInsSorted.add(bidInsHighRollers[i]);
        }
        return bidInsSorted;
      }
    } else {
      // choose highroller
      bidInsSorted.add(nextHighroller);
      final value = 1;
      recentLoungesHistory.addLast(value);
      loungeSum += value;
      highRollerIndex += 1;

      // if highrollers done, add remaining chronies and done
      if (highRollerIndex == bidInsHighRollers.length) {
        for (int i = chronyIndex; i < bidInsChronies.length; i++) {
          bidInsSorted.add(bidInsChronies[i]);
        }
        return bidInsSorted;
      }
    }
  } // while

  return bidInsSorted;
});

final lockedHangoutViewModelProvider = Provider<LockedHangoutViewModel?>(
  (ref) {
    final uid = ref.watch(myUIDProvider)!;
    final hangout = ref.watch(hangoutProvider(uid));
    log('lockedUserViewModelProvider - user=$hangout');
    if (hangout is AsyncLoading || hangout is AsyncError) return null;

    if (hangout.asData!.value.meeting == null) return null;
    final String userMeeting = hangout.asData!.value.meeting!;
    log('lockedHangoutViewModelProvider - userMeeting=$userMeeting');
    final meeting = ref.watch(meetingProvider(userMeeting));
    log('lockedHangoutViewModelProvider - meeting=$meeting');
    if (meeting is AsyncLoading || meeting is AsyncError) return null;
    return LockedHangoutViewModel(
        hangout: hangout.asData!.value, meeting: meeting.asData!.value);
  },
);

final ringingPageViewModelProvider = Provider<RingingPageViewModel?>((ref) {
  // log('ringingPageViewModelProvider');
  final algorand = ref.watch(algorandProvider);
  // log('lockedUserViewModelProvider - algorand=$algorand');
  final uid = ref.watch(myUIDProvider)!;
  // log('ringingPageViewModelProvider - uid=$uid');
  final hangout = ref.watch(hangoutProvider(uid));
  // log('ringingPageViewModelProvider - user=$user');

  if (hangout is AsyncLoading || hangout is AsyncError) return null;

  // log('ringingPageViewModelProvider - user.data=${user.data}');
  // log('ringingPageViewModelProvider - user.asData!.value=${user.asData!.value}');
  // log('ringingPageViewModelProvider - user.asData!.value.meeting=${user.asData!.value.meeting}');
  if (hangout.asData!.value.meeting == null) return null;
  final String hangoutMeeting = hangout.asData!.value.meeting!;
  // log('ringingPageViewModelProvider - userMeeting=$userMeeting');
  final meeting = ref.watch(meetingProvider(hangoutMeeting));
  // log('ringingPageViewModelProvider - meeting=$meeting');

  if (meeting is AsyncLoading || meeting is AsyncError) return null;

  final amA = meeting.asData!.value.A == hangout.asData!.value.id;
  final otherUserId = amA ? meeting.asData!.value.B : meeting.asData!.value.A;
  final otherUser = ref.watch(hangoutProvider(otherUserId));
  if (otherUser is AsyncLoading || otherUser is AsyncError) return null;

  final functions = ref.watch(firebaseFunctionsProvider);
  // log('lockedUserViewModelProvider - functions=$functions');

  final meetingChanger = ref.watch(meetingChangerProvider);

  return RingingPageViewModel(
      hangout: hangout.asData!.value,
      otherUser: otherUser.asData!.value,
      algorand: algorand,
      functions: functions,
      meetingChanger: meetingChanger,
      meeting: meeting.asData!.value);
});

final meetingHistoryProvider =
    StateProvider.family<HistoryViewModel?, String>((ref, uid) {
  final meetingHistoryAList = ref.watch(meetingHistoryA(uid));
  if (meetingHistoryAList is AsyncLoading || meetingHistoryAList is AsyncError)
    return null;
  final meetingHistoryBList = ref.watch(meetingHistoryB(uid));
  if (meetingHistoryBList is AsyncLoading || meetingHistoryBList is AsyncError)
    return null;

  var list = [
    ...meetingHistoryAList.asData!.value,
    ...meetingHistoryBList.asData!.value
  ];
  return HistoryViewModel(meetingList: list);
});

final addBidPageViewModelProvider =
    StateProvider.family<AddBidPageViewModel?, String>((ref, uid) {
  // log('addBidPageViewModelProvider');
  final functions = ref.watch(firebaseFunctionsProvider);
  // log('addBidPageViewModelProvider - functions=$functions');
  final algorand = ref.watch(algorandProvider);
  // log('addBidPageViewModelProvider - algorandTestnet=$algorand');
  final user = ref.watch(hangoutProvider(uid));
  // log('addBidPageViewModelProvider - user=$user');
  if (user is AsyncLoading) return null;

  final accounts = ref.watch(accountsProvider);
  if (accounts is AsyncLoading) return null;

  final accountService = ref.watch(accountServiceProvider);

  final database = ref.watch(databaseProvider);

  final myUid = ref.watch(myUIDProvider);
  if (myUid == null) return null;

  return AddBidPageViewModel(
      uid: myUid,
      database: database,
      functions: functions,
      algorand: algorand,
      accounts: accounts.asData!.value,
      accountService: accountService,
      B: user.asData!.value);
});

final accountsProvider = FutureProvider((ref) {
  final accountService = ref.watch(accountServiceProvider);
  return accountService.getAllAccounts();
});

final myAccountPageViewModelProvider =
    ChangeNotifierProvider<MyAccountPageViewModel>(
        (ref) => MyAccountPageViewModel(ref));

final createLocalAccountProvider = FutureProvider(
  (ref) async {
    final myAccountPageViewModel = ref.read(myAccountPageViewModelProvider);
    LocalAccount account = await myAccountPageViewModel.addLocalAccount();
    return account;
  },
);

final hangoutChangerProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  final uid = ref.watch(myUIDProvider);
  if (uid == null) return null;
  return HangoutChanger(database, uid);
});
final meetingChangerProvider = Provider((ref) {
  final database = ref.watch(databaseProvider);
  return MeetingChanger(database);
});

//Rating Module
final ratingListProvider =
    StreamProvider.family<List<RatingModel>, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database.getUserRatings(uid);
});

final estMaxDurationProvider =
    FutureProvider.family<double?, String>((ref, bidId) async {
  final bidInPrivateAsyncValue = ref.watch(bidInPrivateProvider(bidId));
  final bidInAsyncValue = ref.watch(bidInProvider(bidId));
  if (bidInAsyncValue is AsyncError || bidInAsyncValue is AsyncLoading)
    return null;
  final bidIn = bidInAsyncValue.value;
  if (bidIn == null) return null;

  final speed = bidIn.speed.num;
  if (speed == 0) return double.infinity;

  if (bidInPrivateAsyncValue is AsyncError ||
      bidInPrivateAsyncValue is AsyncLoading) return null;
  final bidInPrivate = bidInPrivateAsyncValue.value;
  if (bidInPrivate == null) return null;

  final addr = bidInPrivate.addrA!;
  final assetId = bidIn.speed.assetId;

  final accountService = ref.watch(accountServiceProvider);
  final assetHoldings = await accountService.getAssetHoldings(
      address: addr, net: AlgorandNet.testnet);

  for (final assetHolding in assetHoldings) {
    if (assetHolding.assetId == assetId) {
      return (assetHolding.amount / speed).floorToDouble();
    }
  }

  return null;
});

final isMainAccountEmptyProvider = FutureProvider((ref) async {
  final accountService = ref.watch(accountServiceProvider);
  final mainAccount = await accountService.getMainAccount();
  for (final balance in mainAccount.balances) {
    if (balance.assetHolding.assetId == 0) {
      if (balance.assetHolding.amount == 0)
        return true;
      else
        return false;
    }
  }
  throw Exception('');
});
