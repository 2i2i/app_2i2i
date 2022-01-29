import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/services/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum Lounge { chrony, highroller, eccentric, lurker }

extension ParseToString on Lounge {
  String toStringEnum() {
    return this.toString().split('.').last;
  }

  String name() {
    final s = toStringEnum();
    return "${s[0].toUpperCase()}${s.substring(1).toLowerCase()}";
  }
}

class HangoutChanger {
  HangoutChanger(this.database, this.uid);

  final FirestoreDatabase database;
  final String uid;

  Future unlock(String uid) => database.unlockUser(uid);

  Future updateHeartbeat() async {
    final status = 'ONLINE';
    return database.updateUserHeartbeat(uid, status);
  }

  Future updateHangout(Hangout hangout) {
    final tags = Hangout.tagsFromBio(hangout.bio);
    Map map = hangout.toMap();
    map['tags'] = [hangout.name.toLowerCase(), ...tags];
    return database.updateUserNameAndBio(uid, map.cast());
  }

  Future updateNameAndBio(String name, String bio) async {
    final tags = Hangout.tagsFromBio(bio);
    Map<String, dynamic> data = {
      'name': name,
      'bio': bio,
      'tags': [name.toLowerCase(), ...tags]
    };
    final user = await database.getUser(uid);
    if (user == null) {
      final newUser = Hangout(id: uid, name: name, bio: bio);
      data = newUser.toMap();
    }
    return database.updateUserNameAndBio(uid, data);
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
class HangOutRule extends Equatable {
  static const defaultImportance = {
    // set also in cloud function userCreated
    Lounge.lurker: 0,
    Lounge.chrony: 1,
    Lounge.highroller: 5,
    Lounge.eccentric: 0
  };

  const HangOutRule({
    // set also in cloud function userCreated
    this.maxMeetingDuration = 300,
    this.minSpeed = 0,
    this.importance = defaultImportance,
  });

  final int maxMeetingDuration;
  final int minSpeed;
  final Map<Lounge, int> importance;

  factory HangOutRule.fromMap(Map<String, dynamic> data) {
    final int maxMeetingDuration = data['maxMeetingDuration'];
    final int minSpeed = data['minSpeed'];

    final Map<Lounge, int> importance = {};
    final Map<String, dynamic> x = data['importance'];
    for (final k in x.keys) {
      final lounge = Lounge.values.firstWhere((l) => l.toStringEnum() == k);
      importance[lounge] = x[k]! as int;
    }

    return HangOutRule(
      maxMeetingDuration: maxMeetingDuration,
      minSpeed: minSpeed,
      importance: importance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxMeetingDuration': maxMeetingDuration,
      'minSpeed': minSpeed,
      'importance':
          importance.map((key, value) => MapEntry(key.toStringEnum(), value)),
    };
  }

  int importanceSize() =>
      importance.values.reduce((value, element) => value + element);

  @override
  List<Object> get props => [maxMeetingDuration, minSpeed, importance];
}

@immutable
class Hangout extends Equatable {
  static const int MAX_SHOWN_NAME_LENGTH = 10;

  Hangout({
    // set also in cloud function userCreated
    required this.id,
    this.status = 'ONLINE',
    this.meeting,
    this.name = '',
    this.bio = '',
    this.rating = 1,
    this.numRatings = 0,
    this.heartbeat,
    this.rule = const HangOutRule(),
    this.loungeHistory = const <Lounge>[],
    this.loungeHistoryIndex = -1,
  }) {
    _tags = [name.toLowerCase(), ...tagsFromBio(bio)];
  }

  final String id;
  final DateTime? heartbeat;
  final String status;

  final String? meeting;
  HangOutRule rule;
  String name;
  String bio;
  late final List<String> _tags;

  final double rating;
  final int numRatings;

  final List<Lounge>
      loungeHistory; // actually circular array containing recent 100 lounges
  final int loungeHistoryIndex; // index where 0 is; goes anti-clockwise

  static List<String> tagsFromBio(String bio) {
    RegExp r = RegExp(r"(?<=#)[a-zA-Z0-9]+");
    final matches = r.allMatches(bio).toList();
    final List<String> tags = [];
    for (final m in matches) {
      final t = bio.substring(m.start, m.end).toLowerCase();
      tags.add(t);
    }
    return tags;
  }

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory Hangout.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('Hangout.fromMap - data == null');
      throw StateError('missing data for uid: $documentId');
    }

    // log('Hangout.fromMap - data=$data');
    // log('Hangout.fromMap - data=${data['bidsIn']}');
    // log('Hangout.fromMap - data=${data['bidsIn'].runtimeType}');

    final String status = data['status'];
    final String? meeting = data['meeting'];
    final String name = data['name'] ?? '';
    final String bio = data['bio'] ?? '';
    final double rating = double.tryParse(data['rating'].toString()) ?? 1;
    final int numRatings = int.tryParse(data['numRatings'].toString()) ?? 0;
    final DateTime? heartbeat = data['heartbeat']?.toDate();
    final HangOutRule rule = data['rule'] == null
        ? HangOutRule()
        : HangOutRule.fromMap(data['rule']);
    List list = [];
    if(data['loungeHistory']?.isNotEmpty??false){
      list = data['loungeHistory'].map((item) => Lounge.values.firstWhere((e) => e.toStringEnum() == item));
    }
    final List<Lounge> loungeHistory = List<Lounge>.from(list);
    final int loungeHistoryIndex = data['loungeHistoryIndex']??0;

    return Hangout(
      id: documentId,
      status: status,
      meeting: meeting,
      name: name,
      bio: bio,
      rating: rating,
      numRatings: numRatings,
      heartbeat: heartbeat,
      rule: rule,
      loungeHistory: loungeHistory,
      loungeHistoryIndex: loungeHistoryIndex,
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
      'rule': rule.toMap(),
      'loungeHistory': loungeHistory,
      'loungeHistoryIndex': loungeHistoryIndex,
    };
  }

  @override
  String toString() {
    return 'Hangout{id: $id, status: $status, meeting: $meeting, bio: $bio, name: $name, _tags: $_tags, rating: $rating, numRatings: $numRatings, heartbeat: $heartbeat}';
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

extension ParseToDate on String {
  DateTime? toDate() {
    return DateTime.tryParse(this)?.toLocal();
  }
}

extension ParseToTimeStamp on Timestamp {
  DateTime? toDate() {
    return this.toDate().toLocal();
  }
}
