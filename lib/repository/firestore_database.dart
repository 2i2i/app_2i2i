import 'dart:async';

import 'package:app_2i2i/models/bid.dart';
import 'package:app_2i2i/models/meeting.dart';
import 'package:app_2i2i/models/room.dart';
import 'package:app_2i2i/models/user.dart';
import 'package:app_2i2i/repository/firestore_path.dart';
import 'package:app_2i2i/repository/firestore_service.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FirestoreDatabase {
  FirestoreDatabase();

  final _service = FirestoreService.instance;

  Future<void> setTestA() => _service.setData(
        path: FirestorePath.testA(),
        data: {},
        merge: true,
      );

  Future<void> updateUserHearbeat(String uid, int heartbeat, String status) =>
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
    print('setUser - user=$user - map=${user.toMap()}');
    _service.setData(
      path: FirestorePath.user(user.id),
      data: user.toMap(),
      merge: true,
    );
    print('setUser - done');
  }

  Future<void> setUserPrivate(String uid, UserModelPrivate userPrivate) =>
      _service.setData(
          path: FirestorePath.userPrivate(uid),
          data: userPrivate.toMap(),
          merge: true);

  Stream<UserModel> userStream({required String uid}) =>
      _service.documentStream(
        path: FirestorePath.user(uid),
        builder: (data, documentId) => UserModel.fromMap(data, documentId),
      );
  Stream<UserModelPrivate> userPrivateStream({required String uid}) =>
      _service.documentStream(
        path: FirestorePath.userPrivate(uid),
        builder: (data, documentId) =>
            UserModelPrivate.fromMap(data, documentId),
      );

  Stream<List<UserModel?>> usersStream({List<String> tags = const <String>[]}) {
    log('FirestoreDatabase - usersStream');
    return _service.collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) {
        if (data == null) return null;
        return UserModel.fromMap(data, documentId);
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

  Stream<Bid> bidStream({required String id}) => _service.documentStream(
        path: FirestorePath.bid(id),
        builder: (data, documentId) => Bid.fromMap(data, documentId),
      );

  Future<void> setBid(Bid bid) => _service.setData(
        path: FirestorePath.bid(bid.id),
        data: bid.toMap(),
        merge: true,
      );
  Future<void> setBidPrivate(String bidId, BidPrivate bid) => _service.setData(
        path: FirestorePath.bidPrivate(bidId),
        data: bid.toMap(),
        merge: true,
      );

  Stream<Meeting> meetingStream({required String id}) =>
      _service.documentStream(
        path: FirestorePath.meeting(id),
        builder: (data, documentId) => Meeting.fromMap(data, documentId),
      );
  Future<void> setMeeting(Meeting meeting) => _service.setData(
        path: FirestorePath.meeting(meeting.id),
        data: meeting.toMap(),
        merge: true,
      );
}
