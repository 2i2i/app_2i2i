import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/bid_model.dart';
import '../../models/comment_model.dart';
import '../../models/hangout_model.dart';
import '../../models/meeting_model.dart';
import '../../models/room_model.dart';
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

  String newDocId({required String path}) => _service.newDocId(path: path);

  // Future<void> setTestA() => _service.setData(
  //       path: FirestorePath.testA(),
  //       data: {},
  //       merge: true,
  //     );

  Future acceptBid(Meeting meeting) async {
    return _service.runTransaction((transaction) {
      final meetingDocRef = _service.firestore
          .collection(FirestorePath.meetings())
          .doc(meeting.id);

      final lockObj = {'meeting': meeting.id};

      transaction.set(meetingDocRef, meeting.toMap());
      final userADocRef = _service.firestore.doc(FirestorePath.user(meeting.A));
      transaction.update(userADocRef, lockObj);
      final userBDocRef = _service.firestore.doc(FirestorePath.user(meeting.B));
      transaction.update(userBDocRef, lockObj);

      return Future.value();
    });
  }

  Future addBid(BidOut bidOut, BidIn bidIn) async {
    return _service.runTransaction((transaction) {
      final bidOutRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidOuts(bidIn.private!.A))
          .doc(bidOut.id);

      final bidInPublicRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidInsPublic(bidOut.B))
          .doc(bidOut.id);

      final bidInPrivateRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidInsPrivate(bidOut.B))
          .doc(bidOut.id);

      transaction.set(bidOutRef, bidOut.toMap(), SetOptions(merge: false));
      transaction.set(
          bidInPublicRef, bidIn.public.toMap(), SetOptions(merge: false));
      transaction.set(
          bidInPrivateRef, bidIn.private!.toMap(), SetOptions(merge: false));

      return Future.value();
    });
  }

  Future cancelBid(
      {required String A, required String B, required String bidId}) async {
    return _service.runTransaction((transaction) {
      final bidOutRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidOuts(A))
          .doc(bidId);
      final bidInPublicRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidInsPublic(B))
          .doc(bidId);
      final bidInPrivateRef = FirebaseFirestore.instance
          .collection(FirestorePath.bidInsPrivate(B))
          .doc(bidId);
      final obj = {'active': false};
      final setOptions = SetOptions(merge: true);

      transaction.set(bidOutRef, obj, setOptions);
      transaction.set(bidInPublicRef, obj, setOptions);
      transaction.set(bidInPrivateRef, obj, setOptions);

      return Future.value();
    });
  }

  Future<void> updateDeviceInfo(String uid, Map<String, String?> data) =>
      _service.setData(
        path: FirestorePath.device(uid),
        data: data,
        merge: true,
      );

  Future<void> updateToken(String uid, String token) => _service.setData(
        path: FirestorePath.token(uid),
        data: {
          'token': token,
          'ts': FieldValue.serverTimestamp(),
        },
        merge: true,
      );

  Future<void> updateUserHeartbeat(String uid, String status) =>
      _service.setData(
        path: FirestorePath.user(uid),
        data: {'heartbeat': FieldValue.serverTimestamp(), 'status': status},
        merge: true,
      );

  Future<void> updateMeeting(String meetingId, Map<String, dynamic> data) {
    return _service
        .setData(
      path: FirestorePath.meeting(meetingId),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      print(onError);
    });
  }

  Future meetingEndUnlockUser(
      Meeting meeting, Map<String, dynamic> data) async {
    return _service.runTransaction((transaction) {
      final userARef =
          FirebaseFirestore.instance.doc(FirestorePath.user(meeting.A));
      final userBRef =
          FirebaseFirestore.instance.doc(FirestorePath.user(meeting.B));
      final meetingRef =
          FirebaseFirestore.instance.doc(FirestorePath.meeting(meeting.id));

      final obj = {'meeting': null};
      final setOptions = SetOptions(merge: true);

      transaction.set(meetingRef, data, setOptions);
      transaction.set(userARef, obj, setOptions);
      transaction.set(userBRef, obj, setOptions);

      return Future.value();
    });
  }

  Future<void> updateUserNameAndBio(String uid, Map<String, dynamic> data) =>
      _service.setData(
        path: FirestorePath.user(uid),
        data: data,
        merge: true,
      );

  // Future<void> setUser(Hangout hangout) async {
  //   log('setUser - user=$hangout - map=${hangout.toMap()}');
  //   _service.setData(
  //     path: FirestorePath.user(hangout.id),
  //     data: hangout.toMap(),
  //     merge: true,
  //   );
  //   log('setUser - done');
  // }

  Future<void> addRating(String uid, String meetingId, RatingModel rating) =>
      _service.setData(
        path: FirestorePath.newRating(uid, meetingId),
        data: rating.toMap(),
      );

  Stream<List<RatingModel>> getUserRatings(String uid) {
    return _service
        .collectionStream(
            path: FirestorePath.ratings(uid),
            builder: (data, documentId) =>
                RatingModel.fromMap(data, documentId))
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

  Stream<Hangout> userStream({required String uid}) => _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) {
          data ??= {};
          return Hangout.fromMap(data, documentId);
        },
      );

  Future<void> updateUser(Hangout user) => _service.setData(
        path: FirestorePath.user(user.id),
        data: user.toMap(),
        merge: true,
      );

  Future<Hangout?> getUser(String uid) async {
    DocumentSnapshot documentSnapshot =
        await _service.getData(path: FirestorePath.user(uid));
    if (documentSnapshot.exists) {
      String id = documentSnapshot.id;
      final data = documentSnapshot.data();
      if (data is Map) {
        try {
          return Hangout.fromMap(data.cast<String, dynamic>(), id);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  Stream<List<Hangout>> usersStream({List<String> tags = const <String>[]}) {
    log(I + 'usersStream - tags=$tags');
    return _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) => Hangout.fromMap(data, documentId),
      queryBuilder: tags.isEmpty
          ? null
          : (query) => query.where('tags', arrayContainsAny: tags),
    );
  }

  Stream<Room> roomStream({required String meetingId}) =>
      _service.documentStream(
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
        return RTCIceCandidate(
            data!['candidate'], data['sdpMid'], data['sdpMlineIndex']);
      },
    );
  }

  Stream<List<BidInPublic>> bidInsPublicStream({required String uid}) {
    return _service.collectionStream(
      path: FirestorePath.bidInsPublic(uid),
      builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      queryBuilder: (query) =>
          query.where('active', isEqualTo: true).orderBy('ts'),
    );
  }

  Stream<List<BidInPrivate>> bidInsPrivateStream({required String uid}) {
    return _service.collectionStream(
      path: FirestorePath.bidInsPrivate(uid),
      builder: (data, documentId) => BidInPrivate.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true),
    );
  }

  Stream<List<BidOut>> bidOutsStream({required String uid}) {
    return _service.collectionStream(
      path: FirestorePath.bidOuts(uid),
      builder: (data, documentId) => BidOut.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true),
    );
  }

  Stream<BidOut> getBidOut({required String uid, required String bidId}) =>
      _service.documentStream(
        path: FirestorePath.bidOut(uid, bidId),
        builder: (data, documentId) => BidOut.fromMap(data, documentId),
      );

  Stream<BidInPublic> getBidInPublic(
          {required String uid, required String bidId}) =>
      _service.documentStream(
        path: FirestorePath.bidInPublic(uid, bidId),
        builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      );

  Stream<BidInPrivate> getBidInPrivate(
          {required String uid, required String bidId}) =>
      _service.documentStream(
        path: FirestorePath.bidInPrivate(uid, bidId),
        builder: (data, documentId) => BidInPrivate.fromMap(data, documentId),
      );

  Stream<Meeting> meetingStream({required String id}) =>
      _service.documentStream(
          path: FirestorePath.meeting(id),
          builder: (data, documentId) {
            return Meeting.fromMap(data, documentId);
          });

  Stream<List<TopMeeting>> topSpeedsStream() => _service
          .collectionStream(
        path: FirestorePath.topSpeeds(),
        builder: (data, documentId) => TopMeeting.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('speed.num', descending: true),
      )
          .handleError((onError) {
        print(onError);
        return [];
      });
  Stream<List<TopMeeting>> topDurationsStream() => _service
          .collectionStream(
        path: FirestorePath.topDurations(),
        builder: (data, documentId) => TopMeeting.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('duration', descending: true),
      )
          .handleError((onError) {
        print(onError);
        return [];
      });

  // Future<void> setMeeting(Meeting meeting) => _service.setData(
  //       path: FirestorePath.meeting(meeting.id),
  //       data: meeting.toMap(),
  //       merge: true,
  //     );

  Stream<List<Meeting>> meetingHistoryA(String uid) =>
      _meetingHistoryX(uid, 'A');

  Stream<List<Meeting>> meetingHistoryB(String uid, {int? limit}) =>
      _meetingHistoryX(uid, 'B', limit: limit);

  Stream<List<Meeting>> _meetingHistoryX(String uid, String field,
      {int? limit}) {
    return _service
        .collectionStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) => Meeting.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where(field, isEqualTo: uid);
        if (limit != null) query = query.limit(limit);
        return query;
      },
    )
        .handleError((onError) {
      print(onError);
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
        path: FirestorePath.chat(uid) +
            '/' +
            _service.newDocId(path: FirestorePath.chat(uid)),
        data: chat.toMap(),
      );
}
