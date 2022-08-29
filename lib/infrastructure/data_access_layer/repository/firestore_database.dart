import 'dart:async';

import 'package:app_2i2i/infrastructure/models/app_version_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/bid_model.dart';
import '../../models/chat_model.dart';
import '../../models/meeting_history_model.dart';
import '../../models/meeting_model.dart';
import '../../models/room_model.dart';
import '../../models/token_model.dart';
import '../../models/user_model.dart';
import '../services/logging.dart';
import 'firestore_path.dart';
import 'firestore_service.dart';

class FirestoreDatabase {
  FirestoreDatabase._internal();

  static final FirestoreDatabase _singleton = FirestoreDatabase._internal();

  factory FirestoreDatabase() {
    return _singleton;
  }

  final _service = FirestoreService.instance;

  //create user function
  Future createUser(String uid) async {
    UserModel createdUserModel = UserModel(
        id: uid,
        status: Status.ONLINE,
        meeting: null,
        bio: "",
        name: "",
        rating: 1,
        numRatings: 0,
        tags: [],
        rule: Rule(
          maxMeetingDuration: 300,
          minSpeed: 0,
          importance: {
            Lounge.chrony: 1,
            Lounge.highroller: 4,
            Lounge.eccentric: 0,
            Lounge.lurker: 0,
          },
        ),
        loungeHistory: [],
        loungeHistoryIndex: -1,
        blocked: [],
        friends: [],
        imageUrl: '',
        heartbeatBackground: DateTime.now(),
        heartbeatForeground: DateTime.now(),
        socialLinks: []);
    Map userInfoMap = createdUserModel.toMap();
    userInfoMap['heartbeatBackground'] = FieldValue.serverTimestamp();
    userInfoMap['heartbeatForeground'] = FieldValue.serverTimestamp();
    return _service.runTransaction((transaction) {
      final userDocRef = _service.firestore.collection(FirestorePath.users()).doc(uid);
      transaction.set(userDocRef, userInfoMap);
      return Future.value();
    }).catchError((onError) {
      log("Exep[tiomn............");
    });
  }

  String newDocId({required String path}) => _service.newDocId(path: path);

  Future addAlgorandAccount(String uid, String algorandAccount, String type) => _service.setData(
        path: FirestorePath.algorandAccount(uid, algorandAccount),
        data: {
          'type': type,
          'ts': FieldValue.serverTimestamp(),
        },
        merge: false,
      );

  Future acceptBid(Meeting meeting) async {
    return _service.runTransaction((transaction) {
      // create meeting

      final meetingDocRef = _service.firestore.collection(FirestorePath.meetings()).doc(meeting.id);
      transaction.set(meetingDocRef, meeting.toMap());

      // lock users
      final lockObj = {'meeting': meeting.id};
      final userADocRef = _service.firestore.doc(FirestorePath.user(meeting.A));
      transaction.update(userADocRef, lockObj);
      final userBDocRef = _service.firestore.doc(FirestorePath.user(meeting.B));
      transaction.update(userBDocRef, lockObj);

      // deactivate bids
      final bidOutRef = _service.firestore.doc(FirestorePath.bidOut(meeting.A, meeting.id));
      final bidInPublicRef = _service.firestore.doc(FirestorePath.bidInPublic(meeting.B, meeting.id));
      final bidInPrivateRef = _service.firestore.doc(FirestorePath.bidInPrivate(meeting.B, meeting.id));
      final bidObj = {'active': false};
      transaction.update(bidOutRef, bidObj);
      transaction.update(bidInPublicRef, bidObj);
      transaction.update(bidInPrivateRef, bidObj);

      return Future.value();
    }).catchError((onError) {
      log(onError);
    });
  }

  Future addBid(BidOut bidOut, BidIn bidIn) async {
    return _service.runTransaction((transaction) {
      final bidOutRef = _service.firestore.doc(FirestorePath.bidOut(bidIn.private!.A, bidOut.id));
      final bidInPublicRef = _service.firestore.doc(FirestorePath.bidInPublic(bidOut.B, bidOut.id));
      final bidInPrivateRef = _service.firestore.doc(FirestorePath.bidInPrivate(bidOut.B, bidOut.id));

      transaction.set(bidOutRef, bidOut.toMap(), SetOptions(merge: false));
      transaction.set(bidInPublicRef, bidIn.public.toMap(), SetOptions(merge: false));
      transaction.set(bidInPrivateRef, bidIn.private!.toMap(), SetOptions(merge: false));

      return Future.value();
    });
  }

  Future cancelBid({required String A, required String B, required String bidId}) async {
    return _service.runTransaction((transaction) {
      final bidOutRef = _service.firestore.doc(FirestorePath.bidOut(A, bidId));
      final bidInPublicRef = _service.firestore.doc(FirestorePath.bidInPublic(B, bidId));
      final bidInPrivateRef = _service.firestore.doc(FirestorePath.bidInPrivate(B, bidId));

      final obj = {'active': false};

      transaction.update(bidOutRef, obj);
      transaction.update(bidInPublicRef, obj);
      transaction.update(bidInPrivateRef, obj);

      return Future.value();
    });
  }

  Future<void> updateDeviceInfo(String uid, Map<String, String?> data) => _service.setData(
        path: FirestorePath.device(uid),
        data: data,
        merge: true,
      );

  Future<void> updateToken(String uid, String token) {
    _service.setData(
      path: FirestorePath.token(uid),
      data: {
        'token': token,
        'isIos': false /*Platform.isIOS*/,
        'ts': FieldValue.serverTimestamp(),
      },
      merge: true,
    );
    return Future.value();
  }

  Future<void> updateUserHeartbeatFromForeground(String uid, {bool setStatus = false}) =>
      setStatus ? _updateUserHeartbeat(uid, 'heartbeatForeground', newStatus: 'ONLINE') : _updateUserHeartbeat(uid, 'heartbeatForeground');

  Future<void> updateUserHeartbeatFromBackground(String uid, {bool setStatus = false}) =>
      setStatus ? _updateUserHeartbeat(uid, 'heartbeatBackground', newStatus: 'IDLE') : _updateUserHeartbeat(uid, 'heartbeatBackground');

  Future<void> _updateUserHeartbeat(String uid, String field, {String? newStatus}) {
    final data = <String, dynamic>{
      field: FieldValue.serverTimestamp(),
    };
    if (newStatus != null) data['status'] = newStatus;

    return _service
        .setData(
      path: FirestorePath.user(uid),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      log('_updateUserHeartbeat $onError');
    });
  }

  Future<void> updateMeeting(String meetingId, Map<String, dynamic> data) {
    return _service
        .setData(
      path: FirestorePath.meeting(meetingId),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      log(onError);
    });
  }

  Future<void> updateMeetingStatus(String meetingId, Map<String, dynamic> data) {
    return _service
        .setData(
      path: FirestorePath.meeting(meetingId),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      log(onError);
    });
  }

  Future meetingEndUnlockUser(Meeting meeting, Map<String, dynamic> data) async {
    return _service.runTransaction((transaction) {
      final userARef = _service.firestore.doc(FirestorePath.user(meeting.A));
      final userBRef = _service.firestore.doc(FirestorePath.user(meeting.B));
      final meetingRef = _service.firestore.doc(FirestorePath.meeting(meeting.id));

      final obj = {'meeting': null};

      transaction.update(meetingRef, data);
      transaction.update(userARef, obj);
      transaction.update(userBRef, obj);

      return Future.value();
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<void> updateUserNameAndBio(String uid, Map<String, dynamic> data) => _service.setData(
        path: FirestorePath.user(uid),
        data: data,
        merge: true,
      );

  Future<void> addRating(String uid, String meetingId, RatingModel rating) => _service.setData(
        path: FirestorePath.newRating(uid, meetingId),
        data: rating.toMap(),
      );

  Stream<List<RatingModel>> getUserRatings(String uid) {
    return _service
        .collectionStream(path: FirestorePath.ratings(uid), builder: (data, documentId) => RatingModel.fromMap(data, documentId))
        .handleError((value) {
      log(value);
    });
  }

  Future<void> addBlocked(String uid, String targetUid) => _service.setData(
        path: FirestorePath.user(uid),
        data: {
          'blocked': FieldValue.arrayUnion([targetUid])
        },
        merge: true,
      );

  Future<void> addFriend(String uid, String targetUid) => _service.setData(
        path: FirestorePath.user(uid),
        data: {
          'friends': FieldValue.arrayUnion([targetUid])
        },
        merge: true,
      );

  Future<void> removeBlocked(String uid, String targetUid) => _service.setData(
        path: FirestorePath.user(uid),
        data: {
          'blocked': FieldValue.arrayRemove([targetUid])
        },
        merge: true,
      );

  Future<void> removeFriend(String uid, String targetUid) => _service.setData(
        path: FirestorePath.user(uid),
        data: {
          'friends': FieldValue.arrayRemove([targetUid])
        },
        merge: true,
      );

  Stream<UserModel> userStream({required String uid}) {
    return _service
        .documentStream(
      path: FirestorePath.user(uid),
      builder: (data, documentId) {
        if (data == null) {
          return UserModel(id: documentId);
        }
        return UserModel.fromMap(data, documentId);
      },
    )
        .handleError((e) {
      print(e);
    });
  }

  Future<TokenModel?> getTokenFromId(String uid) async {
    DocumentSnapshot snapshot = await _service.getData(path: FirestorePath.token(uid));
    if (snapshot.data() is Map) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      return TokenModel.fromJson(data!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) {
    return _service
        .setData(
      path: FirestorePath.user(user.id),
      data: user.toMap(),
      merge: true,
    )
        .catchError((onError) {
      print(onError);
    });
  }

  Future<AppVersionModel?> getAppVersion() async {
    DocumentSnapshot snapshot = await _service.getData(path: FirestorePath.appVersion());
    if (snapshot.data() is Map) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      return AppVersionModel.fromJson(data!);
    }
    return null;
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot documentSnapshot = await _service.getData(path: FirestorePath.user(uid));
    if (documentSnapshot.exists) {
      String id = documentSnapshot.id;
      final data = documentSnapshot.data();
      if (data is Map) {
        try {
          return UserModel.fromMap(data.cast<String, dynamic>(), id);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Stream<List<UserModel>> usersStream({List<String> tags = const <String>[]}) {
    log(I + 'usersStream - tags=$tags');
    return _service
        .collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) {
        return UserModel.fromMap(data, documentId);
      },
      queryBuilder: tags.isEmpty ? null : (query) => query.where('tags', arrayContainsAny: tags),
    )
        .handleError((error) {
      log(error);
    });
  }

  Stream<Room> roomStream({required String meetingId}) => _service.documentStream(
        path: FirestorePath.room(meetingId),
        builder: (data, documentId) => Room.fromMap(data, meetingId),
      );

  Stream<List<RTCIceCandidate>> iceCandidatesStream({
    required String meetingId,
    required String subCollectionName,
  }) {
    return _service.collectionAddedStream(
      path: FirestorePath.iceCandidates(meetingId, subCollectionName),
      builder: (data, documentId) {
        return RTCIceCandidate(data!['candidate'], data['sdpMid'], data['sdpMlineIndex']);
      },
    );
  }

  Stream<List<BidInPublic>> bidInsPublicStream({required String uid}) {
    return _service
        .collectionStream(
      path: FirestorePath.bidInsPublic(uid),
      builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true).orderBy('ts'),
    )
        .handleError((onError) {
      log('\n\n\n\n ---=== ${onError} \n\n\n');
    });
  }

  Stream<List<BidInPrivate>> bidInsPrivateStream({required String uid}) {
    return _service
        .collectionStream(
      path: FirestorePath.bidInsPrivate(uid),
      builder: (data, documentId) => BidInPrivate.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true),
    )
        .handleError((err) {
      print("----------> $err");
    });
  }

  Stream<List<BidOut>> bidOutsStream({required String uid}) {
    return _service
        .collectionStream(
      path: FirestorePath.bidOuts(uid),
      builder: (data, documentId) => BidOut.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true),
    )
        .handleError((onError) {
      log(onError);
    });
  }

  Stream<BidOut> getBidOut({required String uid, required String bidId}) => _service.documentStream(
        path: FirestorePath.bidOut(uid, bidId),
        builder: (data, documentId) => BidOut.fromMap(data, documentId),
      );

  Stream<BidInPublic> getBidInPublic({required String uid, required String bidId}) => _service.documentStream(
        path: FirestorePath.bidInPublic(uid, bidId),
        builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      );

  Stream<BidInPrivate> getBidInPrivate({required String uid, required String bidId}) => _service.documentStream(
        path: FirestorePath.bidInPrivate(uid, bidId),
        builder: (data, documentId) => BidInPrivate.fromMap(data, documentId),
      );

  Stream<Meeting> meetingStream({required String id}) {
    return _service
        .documentStream(
            path: FirestorePath.meeting(id),
            builder: (data, documentId) {
              return Meeting.fromMap(data, documentId);
            })
        .handleError((onError) {
      log(onError);
    });
  }

  Stream<List<TopMeeting>> topSpeedsStream() => _service
          .collectionStream(
        path: FirestorePath.topSpeeds(),
        builder: (data, documentId) => TopMeeting.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('speed.num', descending: true),
      )
          .handleError((onError) {
        log(onError);
        return [];
      });

  Stream<List<TopMeeting>> topDurationsStream() => _service
          .collectionStream(
        path: FirestorePath.topDurations(),
        builder: (data, documentId) => TopMeeting.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('duration', descending: true),
      )
          .handleError((onError) {
        log(onError);
        return [];
      });

  // Future<void> setMeeting(Meeting meeting) => _service.setData(
  //       path: FirestorePath.meeting(meeting.id),
  //       data: meeting.toMap(),
  //       merge: true,
  //     );

  // Stream<Map> meetingHistory({required MeetingDataModel meetingDataModel}) =>
  //     _meetingHistoryX(meetingDataModel.uId!, meetingDataModel.userAorB!,lastDocument: meetingDataModel.lastDocument,limit: meetingDataModel.page!);

  Stream<Map> meetingHistory({required MeetingDataModel meetingDataModel}) {
    return _service
        .getDocumentStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) => Meeting.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where(meetingDataModel.userAorB!, isEqualTo: meetingDataModel.uId!);
        if (meetingDataModel.lastDocument != null) {
          query = query.startAfterDocument(meetingDataModel.lastDocument!).limit(meetingDataModel.page ?? 10);
        } else {
          query = query.limit(meetingDataModel.page ?? 10);
        }
        return query;
      },
    )
        .handleError((onError) {
      log(onError);
    });
  }

  //chat
  Stream<List<ChatModel>> getChat(String uid) {
    return _service.collectionStream(
      path: FirestorePath.chat(uid),
      builder: (data, documentId) => ChatModel.fromMap(data!),
      queryBuilder: (query) => query.orderBy('ts', descending: true).limit(100),
    );
  }

  Future<void> addChat(String uid, ChatModel chat) => _service.setData(
        path: FirestorePath.chat(uid) + '/' + _service.newDocId(path: FirestorePath.chat(uid)),
        data: chat.toMap(),
      );
}
