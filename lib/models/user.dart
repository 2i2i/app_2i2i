import 'dart:math';
import 'package:app_2i2i/common/utils.dart';
import 'package:app_2i2i/repository/firestore_database.dart';
import 'package:equatable/equatable.dart';
import 'package:app_2i2i/services/logging.dart';
import 'package:flutter/material.dart';

class UserModelChanger {
  UserModelChanger(this.database, this.uid);
  final FirestoreDatabase database;
  final String uid;

  Future updateHeartbeat() async {
    final heartbeat = epochSecsNow();
    final status = 'ONLINE';
    await database.updateUserHearbeat(uid, heartbeat, status);
  }

  Future updateBio(String newBio) async {
    final name = UserModel.nameFromBio(newBio);
    final tags = UserModel.tagsFromBio(newBio);
    await database.updateUserBio(uid, newBio, [name, ...tags]);
  }
}

@immutable
class UserModel extends Equatable {
  static const int MAX_SHOWN_NAME_LENGTH = 10;

  UserModel({
    required this.id,
    this.status = 'ONLINE',
    this.locked = false,
    this.currentMeeting,
    this.bidsIn = const [],
    this.bio = '',
    this.upVotes = 0,
    this.downVotes = 0,
    this.heartbeat = 0,
  }) {
    _name = nameFromBio(bio);
    _tags = tagsFromBio(bio);
  }

  final String id;
  final String status;
  final bool locked;
  final String? currentMeeting;
  final List<String> bidsIn;
  final String bio;
  late final String _name;
  late final List<String> _tags;
  final int upVotes;
  final int downVotes;
  final int heartbeat;

  String get name => _name;

  static String nameFromBio(String bio) {
    if (bio.isEmpty) return '';
    int ix = bio.indexOf(RegExp(r'\s'));
    if (ix == -1) ix = bio.length;
    if (MAX_SHOWN_NAME_LENGTH < ix)
      return bio.substring(0, MAX_SHOWN_NAME_LENGTH) + '...';
    return bio.substring(0, ix);
  }

  static List<String> tagsFromBio(String bio) => bio
      .split(RegExp(r'\s'))
      .where((element) => element.startsWith('#'))
      .map((e) => e.substring(1))
      .toList();

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
    final List<String> bidsIn = List.castFrom(data['bidsIn'] as List);
    final bio = data['bio'] as String;
    final upVotes = data['upVotes'] as int;
    final downVotes = data['downVotes'] as int;
    final heartbeat = data['heartbeat'] as int;

    return UserModel(
      id: documentId,
      status: status,
      locked: locked,
      currentMeeting: currentMeeting,
      bidsIn: bidsIn,
      bio: bio,
      upVotes: upVotes,
      downVotes: downVotes,
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
      'bidsIn': bidsIn,
      'bio': bio,
      'name': _name,
      'tags': _tags,
      'upVotes': upVotes,
      'downVotes': downVotes,
      'heartbeat': heartbeat,
    };
  }
}

class BidOut {
  const BidOut({required this.bid, required this.user});
  final String bid;
  final String user;
}

class UserModelPrivate {
  UserModelPrivate({
    this.bidsOut = const <BidOut>[],
    this.blocked = const <String>[],
    this.friends = const <String>[],
  });

  final List<BidOut> bidsOut;
  final List<String> blocked;
  final List<String> friends;

  factory UserModelPrivate.fromMap(
      Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('UserModelPrivate.fromMap - data == null');
      throw StateError('missing data for uid: $documentId');
    }

    final List<BidOut> bidsOut = List<BidOut>.from(data['bidsOut'].map((item) {
      return BidOut(bid: item['bid'], user: item['user']);
    }));
    final List<String> blocked = List.castFrom(data['blocked'] as List);
    final List<String> friends = List.castFrom(data['friends'] as List);

    return UserModelPrivate(
      bidsOut: bidsOut,
      blocked: blocked,
      friends: friends,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bidsOut': bidsOut,
      'blocked': blocked,
      'friends': friends,
    };
  }
}
