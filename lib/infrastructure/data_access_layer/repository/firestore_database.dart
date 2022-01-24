import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/bid_model.dart';
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

  Future<void> setTestA() => _service.setData(
        path: FirestorePath.testA(),
        data: {},
        merge: true,
      );

  Future acceptBid(Meeting meeting) async {
    return _service.runTransaction((transaction) {

      final meetingDocRef =
          _service.firestore.collection(FirestorePath.meetings()).doc(meeting.id);

      final lockObj = {'meeting': meeting.id};

      // log(H + 'meeting.toMap()=${meeting.toMap()}');
      // log(H + 'lockObj()=$lockObj');

      transaction.set(meetingDocRef, meeting.toMap());
      final userADocRef = _service.firestore.doc(FirestorePath.user(meeting.A));
      transaction.update(userADocRef, lockObj);
      final userBDocRef = _service.firestore.doc(FirestorePath.user(meeting.B));
      transaction.update(userBDocRef, lockObj);

      return Future.value();
    });
  }

  Future<void> updateUserHeartbeat(String uid, String status) =>
      _service.setData(
        path: FirestorePath.user(uid),
        data: {'heartbeat': FieldValue.serverTimestamp(), 'status': status},
        merge: true,
      );
  Future<void> unlockUser(String uid) => _service.setData(
        path: FirestorePath.user(uid),
        data: {'meeting': null},
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

  Future<void> updateUserNameAndBio(String uid, Map<String, dynamic> data) =>
      _service.setData(
        path: FirestorePath.user(uid),
        data: data,
        merge: true,
      );

  Future<void> setUser(Hangout hangout) async {
    log('setUser - user=$hangout - map=${hangout.toMap()}');
    _service.setData(
      path: FirestorePath.user(hangout.id),
      data: hangout.toMap(),
      merge: true,
    );
    log('setUser - done');
  }

  //<editor-fold desc="Rating module">
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

  //</editor-fold>

  Future<void> addBlocked(String uid, String targetUid) => _service.setData(
        path: FirestorePath.userPrivate(uid),
        data: {
          'blocked': FieldValue.arrayUnion([targetUid])
        },
        merge: true,
      );

  Future<void> addFriend(String uid, String targetUid) => _service.setData(
        path: FirestorePath.userPrivate(uid),
        data: {
          'friends': FieldValue.arrayUnion([targetUid])
        },
        merge: true,
      );

  Future<void> removeBlocked(String uid, String targetUid) => _service.setData(
        path: FirestorePath.userPrivate(uid),
        data: {
          'blocked': FieldValue.arrayRemove([targetUid])
        },
        merge: true,
      );
  Future<void> removeFriend(String uid, String targetUid) => _service.setData(
        path: FirestorePath.userPrivate(uid),
        data: {
          'friends': FieldValue.arrayRemove([targetUid])
        },
        merge: true,
      );

  Future<void> setUserPrivate(
          {required String uid, required UserModelPrivate userPrivate}) =>
      _service.setData(
          path: FirestorePath.userPrivate(uid),
          data: userPrivate.toMap(),
          merge: true);

  Stream<Hangout> userStream({required String uid}) =>
      _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) {
          data ??= {};
          return Hangout.fromMap(data, documentId);
        },
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

  Stream<UserModelPrivate> userPrivateStream({required String uid}) =>
      _service.documentStream(
        path: FirestorePath.userPrivate(uid),
        builder: (data, documentId) =>
            UserModelPrivate.fromMap(data, documentId),
      );

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

  //<editor-fold desc="Meeting Module">\
  Stream<BidInPublic?> getBidInPublic(
          {required String uid, required String bidId}) =>
      _service.documentStream(
        path: FirestorePath.bidInPublic(uid, bidId),
        builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      );

  Stream<BidInPrivate?> getBidInPrivate(
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

  Stream<List<Meeting?>> topMeetingStream() => _service
          .collectionStream(
        path: FirestorePath.topMeetings(),
        builder: (data, documentId) => Meeting.fromMap(data, documentId),
      )
          .handleError((onError) {
        print(onError);
        return [];
      });

  Future<void> setMeeting(Meeting meeting) => _service.setData(
        path: FirestorePath.meeting(meeting.id),
        data: meeting.toMap(),
        merge: true,
      );

  Stream<List<Meeting>> meetingHistoryA(String uid) =>
      _meetingHistoryX(uid, 'A');

  Stream<List<Meeting>> meetingHistoryB(String uid, {int? limit}) =>
      _meetingHistoryX(uid, 'B', limit: limit);

  Stream<List<Meeting>> _meetingHistoryX(String uid, String field,
      {int? limit}) {
    return _service.collectionStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) => Meeting.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where(field, isEqualTo: uid).orderBy('end');
        if (limit != null) query = query.limit(limit);
        return query;
      },
    );
  }
//</editor-fold>
}
