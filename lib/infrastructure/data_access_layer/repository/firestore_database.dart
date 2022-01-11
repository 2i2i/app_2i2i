import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../models/bid_model.dart';
import '../../models/meeting_model.dart';
import '../../models/room_model.dart';
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

  String newDocId({required String path}) => _service.newDocId(path: path);

  Future<void> setTestA() => _service.setData(
        path: FirestorePath.testA(),
        data: {},
        merge: true,
      );

  Future<void> updateUserHeartbeat(String uid, int heartbeat, String status) =>
      _service.setData(
        path: FirestorePath.user(uid),
        data: {'heartbeat': heartbeat, 'status': status},
        merge: true,
      );

  Future<void> endMeeting(String meetingId, Map<String, dynamic> data) {
    log(J + 'endMeeting in database - meetingId=$meetingId - data=$data');
    return _service.setData(
      path: FirestorePath.meeting(meetingId),
      data: data,
      merge: true,
    );
  }

  Future<void> updateUserNameAndBio(
          String uid, String name, String bio, List<String> tags) =>
      _service.setData(
        path: FirestorePath.user(uid),
        data: {'name': name, 'bio': bio, 'tags': tags},
        merge: true,
      );

  Future<void> setUser(UserModel user) async {
    log('setUser - user=$user - map=${user.toMap()}');
    _service.setData(
      path: FirestorePath.user(user.id),
      data: user.toMap(),
      merge: true,
    );
    log('setUser - done');
  }

  //<editor-fold desc="Rating module">
  Future<void> addRating(String uid, String meetingId, RatingModel rating) =>
      _service
          .createData(
        path: FirestorePath.newRating(uid, meetingId),
        data: rating.toMap(),
      )
          .onError((error, stackTrace) {
        print(error);
      });

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

  Stream<UserModel> userStream({required String uid}) =>
      _service.documentStream(
          path: FirestorePath.user(uid),
          builder: (data, documentId) => UserModel.fromMap(data, documentId));

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot documentSnapshot =
        await _service.getData(path: FirestorePath.user(uid));
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

  Stream<UserModelPrivate> userPrivateStream({required String uid}) =>
      _service.documentStream(
        path: FirestorePath.userPrivate(uid),
        builder: (data, documentId) =>
            UserModelPrivate.fromMap(data, documentId),
      );

  Stream<List<UserModel>> usersStream({List<String> tags = const <String>[]}) {
    log(I + 'usersStream - tags=$tags');
    return _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) => UserModel.fromMap(data, documentId),
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

  Stream<List<BidIn>> bidInsStream({required String uid}) {
    return _service.collectionStream(
      path: FirestorePath.bidIns(uid),
      builder: (data, documentId) => BidIn.fromMap(data, documentId),
      queryBuilder: (query) =>
          query.where('active', isEqualTo: true), //.orderBy('speed.num'),
    );
  }

  Stream<List<BidOut>> bidOutsStream({required String uid}) {
    return _service.collectionStream(
      path: FirestorePath.bidOuts(uid),
      builder: (data, documentId) => BidOut.fromMap(data, documentId),
      queryBuilder: (query) =>
          query.where('active', isEqualTo: true), //.orderBy('speed.num'),
    );
  }

  //<editor-fold desc="Meeting Module">\
  Stream<BidIn?> getBidIn({required String uid, required String bidId}) =>
      _service.documentStream(
        path: FirestorePath.bidIn(uid, bidId),
        builder: (data, documentId) => BidIn.fromMap(data, documentId),
      );
  Stream<BidInPrivate?> getBidInPrivate(
          {required String uid, required String bidId}) =>
      _service.documentStream(
        path: FirestorePath.bidPrivate(uid, bidId),
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

  Stream<List<Meeting?>> meetingHistoryA(String uid) =>
      _meetingHistoryX(uid, 'A');

  Stream<List<Meeting?>> meetingHistoryB(String uid) =>
      _meetingHistoryX(uid, 'B');

  Stream<List<Meeting?>> _meetingHistoryX(String uid, String field) {
    return _service
        .collectionStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) => Meeting.fromMap(data, documentId),
      queryBuilder: (query) => query.where(field, isEqualTo: uid),
    )
        .handleError((value) {
      log(value);
    });
  }
//</editor-fold>
}
