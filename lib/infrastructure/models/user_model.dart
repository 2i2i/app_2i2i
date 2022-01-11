import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/services/logging.dart';

class UserModelChanger {
  UserModelChanger(this.database, this.uid);

  final FirestoreDatabase database;
  final String uid;

  Future updateHeartbeat() async {
    final status = 'ONLINE';
    await database.updateUserHeartbeat(uid, status);
  }

  Future updateNameAndBio(String name, String bio) async {
    final tags = UserModel.tagsFromBio(bio);
    await database.updateUserNameAndBio(uid, name, bio, [name, ...tags]);
  }

  // TODO before calling addBlocked or addFriend, need to check whether targetUid already in array
  // do this by getting UserModelPrivate
  // blocked users: we cannot see their bids for us
  // friend users: we see their bids on top
  Future addBlocked(String targetUid) => database.addBlocked(uid, targetUid);
  Future addFriend(String targetUid) => database.addFriend(uid, targetUid);
  Future removeBlocked(String targetUid) =>
      database.removeBlocked(uid, targetUid);
  Future removeFriend(String targetUid) =>
      database.removeFriend(uid, targetUid);
}

@immutable
class UserModel extends Equatable {
  static const int MAX_SHOWN_NAME_LENGTH = 10;

  UserModel({
    required this.id,
    this.status = 'ONLINE',
    this.meeting,
    this.name = '',
    this.bio = '',
    this.rating,
    this.numRatings = 0,
    this.heartbeat,
  }) {
    _tags = tagsFromBio(bio);
  }

  final String id;
  final String status;
  final String? meeting;
  final String bio;
  final String name;
  late final List<String> _tags;
  final double? rating;
  final int numRatings;
  final DateTime? heartbeat;

  static List<String> tagsFromBio(String bio) {
    RegExp r = RegExp(r"(?<=#)[a-zA-Z0-9]+");
    final matches = r.allMatches(bio).toList();
    final List<String> tags = [];
    for (final m in matches) {
      final t = bio.substring(m.start, m.end);
      tags.add(t);
    }
    return tags;
  }

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory UserModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('UserModel.fromMap - data == null');
      throw StateError('missing data for uid: $documentId');
    }

    // log('UserModel.fromMap - data=$data');
    // log('UserModel.fromMap - data=${data['bidsIn']}');
    // log('UserModel.fromMap - data=${data['bidsIn'].runtimeType}');

    final status = data['status'] as String;
    final meeting = data['meeting'] as String?;
    final name = data['name'] as String;
    final bio = data['bio'] as String;
    final rating = double.parse(data['rating'].toString());
    final numRatings = data['numRatings'] as int;
    log(F + 'data=${data}');
    log(F + 'data[heartbeat]=${data['heartbeat']}');
    final DateTime? heartbeat = data['heartbeat']?.toDate();

    return UserModel(
      id: documentId,
      status: status,
      meeting: meeting,
      name: name,
      bio: bio,
      rating: rating,
      numRatings: numRatings,
      heartbeat: heartbeat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'meeting': meeting,
      'bio': bio,
      'name': name,
      'tags': _tags,
      'rating': rating,
      'numRatings': numRatings,
      'heartbeat': heartbeat,
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, status: $status, meeting: $meeting, bio: $bio, name: $name, _tags: $_tags, rating: $rating, numRatings: $numRatings, heartbeat: $heartbeat}';
  }

  bool isInMeeting() => meeting != null;
}

class UserModelPrivate {
  UserModelPrivate({
    this.blocked = const <String>[],
    this.friends = const <String>[],
  });

  final List<String> blocked;
  final List<String> friends;

  factory UserModelPrivate.fromMap(
      Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('UserModelPrivate.fromMap - data == null');
      throw StateError('missing data for uid: $documentId');
    }

    final List<String> blocked = List.castFrom(data['blocked'] as List);
    final List<String> friends = List.castFrom(data['friends'] as List);

    return UserModelPrivate(
      blocked: blocked,
      friends: friends,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blocked': blocked,
      'friends': friends,
    };
  }
}
