import 'dart:async';

import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/room.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_path.dart';
import 'package:app_2i2i/repository/firestore_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FirestoreDatabase {
  FirestoreDatabase();

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

  Future<void> addRating(String uid, RatingModel rating) => _service
          .createData(
        path: FirestorePath.rating(uid),
        data: rating.toMap(),
      )
          .onError((error, stackTrace) {
        print(error);
      });

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

  Stream<List<UserModel?>> usersStream({List<String> tags = const <String>[]}) {
    // log(H + 'FirestoreDatabase - usersStream - tags=$tags');
    return _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) {
        try {
          final user = UserModel.fromMap(data, documentId);
          // log(H + 'FirestoreDatabase - usersStream - user=$user');
          return user;
        } catch (e) {
          return null;
        }
      },
      queryBuilder: (query) {
        if (tags.isEmpty) return query.orderBy('status', descending: true);
        return query.where('tags', arrayContainsAny: tags).orderBy('status');
      },
      // sort: (UserModel? u1, UserModel? u2) {
      //   if (u1 == null && u2 == null) return 1;
      //   if (u1 == null && u2 != null) return 1;
      //   if (u1 != null && u2 == null) return -1;
      //   if (u1!.status == 'ONLINE' && u2!.status != 'ONLINE') return 1;
      //   if (u1.status != 'ONLINE' && u2!.status == 'ONLINE') return -1;
      //   if (u1.status != 'ONLINE' && u2!.status != 'ONLINE') {
      //     if (u1.locked && !u2.locked) return 1;
      //     if (!u1.locked && u2.locked) return -1;
      //   }

      //   return 1;
      // },
    );
    //   .handleError((value) {
    // log(value);
    // });
  }

  Stream<List<Meeting?>> meetingHistoryA(String uid) {
    return _service
        .collectionStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) {
        try {
          final user = Meeting.fromMap(data, documentId);
          return user;
        } catch (e) {
          return null;
        }
      },
      queryBuilder: (query) {
        return query.where('A', isEqualTo: uid);
      },
    )
        .handleError((value) {
      log(value);
    });
  }

  Stream<List<Meeting?>> meetingHistoryB(String uid) {
    return _service
        .collectionStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) {
        try {
          final user = Meeting.fromMap(data, documentId);
          return user;
        } catch (e) {
          return null;
        }
      },
      queryBuilder: (query) {
        return query.where('B', isEqualTo: uid);
      },
    )
        .handleError((value) {
      log(value);
    });
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
      queryBuilder: (query) => query.where('active', isEqualTo: true), //.orderBy('speed.num'),
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

  Stream<BidInPrivate?> getBidInPrivate({required String uid, required String bidId}) =>
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
  Future<void> setMeeting(Meeting meeting) => _service.setData(
        path: FirestorePath.meeting(meeting.id),
        data: meeting.toMap(),
        merge: true,
      );
}
