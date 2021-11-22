import 'dart:async';
import 'package:app_2i2i/app/home/models/meeting.dart';
import 'package:app_2i2i/services/firestore_service.dart';
import 'package:app_2i2i/app/home/models/user.dart';
import 'package:app_2i2i/app/home/models/bid.dart';
import 'package:app_2i2i/app/home/models/room.dart';
import 'package:app_2i2i/services/firestore_path.dart';
import 'package:app_2i2i/app/logging.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FirestoreDatabase {
  FirestoreDatabase();

  final _service = FirestoreService.instance;

  Future<void> updateUserHearbeat(uid, heartbeat, status) => _service.setData(
        path: FirestorePath.user(uid),
        data: {'heartbeat': heartbeat, 'status': status},
        merge: true,
      );
  Future<void> updateUserBio(uid, bio, tags) => _service.setData(
        path: FirestorePath.user(uid),
        data: {'bio': bio, 'tags': tags},
        merge: true,
      );
  Future<void> setUser(UserModel user) => _service.setData(
        path: FirestorePath.user(user.id),
        data: user.toMap(),
        merge: true,
      );
  Future<void> setUserPrivate(String uid, UserModelPrivate userPrivate) =>
      _service.setData(
        path: FirestorePath.userPrivate(uid),
        data: userPrivate.toMap(),
        merge: true,
      );

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
        // log('FirestoreDatabase - usersStream - builder - documentId=$documentId');
        try {
          return UserModel.fromMap(data, documentId);
        } catch (e) {
          return null;
        }
      },
      queryBuilder: (query) {
        if (tags.isEmpty) return query;
        return query.where('tags', arrayContainsAny: tags);
      },
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
