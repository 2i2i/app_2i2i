

import 'dart:math';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/services/logging.dart';

class UserModelChanger {
  UserModelChanger(this.database, this.uid);

  final FirestoreDatabase database;
  final String uid;

  Future updateHeartbeat() async {
    final heartbeat = epochSecsNow();
    final status = 'ONLINE';
    await database.updateUserHeartbeat(uid, heartbeat, status);
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
    this.locked = false,
    this.currentMeeting,
    this.name = '',
    this.bio = '',
    this.rating,
    this.numRatings = 0,
    this.heartbeat = 0,
  }) {
    _tags = tagsFromBio(bio);
  }

  final String id;
  final String status;
  final bool locked;
  final String? currentMeeting;
  final String bio;
  final String name;
  late final List<String> _tags;
  final double? rating;
  final int numRatings;
  final int heartbeat;

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
    final locked = data['locked'] as bool;
    final currentMeeting = data['currentMeeting'] as String?;
    final name = data['name'] as String;
    final bio = data['bio'] as String;
    final rating = double.parse(data['rating'].toString());
    final numRatings = data['numRatings'] as int;
    final heartbeat = data['heartbeat'] as int;

    return UserModel(
      id: documentId,
      status: status,
      locked: locked,
      currentMeeting: currentMeeting,
      name: name,
      bio: bio,
      rating: rating,
      numRatings: numRatings,
      heartbeat: heartbeat,
    );
  }
  static const words = [
    'string',
    'always',
    'ends',
    'with',
    'would',
    'also',
    'assume',
    'that',
    'not',
    'fastest',
    'solution',
    'need',
    'third',
    'party',
    'packages',
    'declare',
    'obscure',
    'constants',
    'house',
    'big'
  ];
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();
  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  factory UserModel.createRandomUser(String id) {
    String bio = getRandomString(5);
    int numHashWords = 2 + _rnd.nextInt(5);
    for (int i = 0; i < numHashWords; i++) {
      int ix = _rnd.nextInt(words.length);
      bio += ' #' + words[ix];
    }
    int numNonHashWords = 2 + _rnd.nextInt(5);
    for (int i = 0; i < numNonHashWords; i++) {
      int ix = _rnd.nextInt(words.length);
      bio += ' ' + words[ix];
    }

    return UserModel(id: id, bio: bio);
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'locked': locked,
      'currentMeeting': currentMeeting,
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
    return 'UserModel{id: $id, status: $status, locked: $locked, currentMeeting: $currentMeeting, bio: $bio, name: $name, _tags: $_tags, rating: $rating, numRatings: $numRatings, heartbeat: $heartbeat}';
  }
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
