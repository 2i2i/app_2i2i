import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/services/logging.dart';

enum Lounge { chrony, highroller, eccentric, lurker }

extension ParseToStringLounge on Lounge {
  String toStringEnum() {
    return this.toString().split('.').last;
  }

  String name() {
    final s = toStringEnum();
    return "${s[0].toUpperCase()}${s.substring(1).toLowerCase()}";
  }
}

enum Status { ONLINE, IDLE, OFFLINE }

extension ParseToStringStatus on Status {
  String toStringEnum() {
    return this.toString().split('.').last;
  }
}

class UserModelChanger {
  UserModelChanger(this.database, this.uid);

  final FirestoreDatabase database;
  final String uid;

  Future updateHeartbeatBackground({bool setStatus = false}) =>
      database.updateUserHeartbeatFromBackground(uid, setStatus: setStatus);
  Future updateHeartbeatForeground({bool setStatus = false}) =>
      database.updateUserHeartbeatFromForeground(uid, setStatus: setStatus);
  Future updateSettings(UserModel user) => database.updateUser(user);
  Future addComment(String targetUid, ChatModel chat) =>
      database.addChat(targetUid, chat);

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
class Rule extends Equatable {
  static const defaultImportance = {
    // set also in cloud function userCreated
    Lounge.chrony: 1,
    Lounge.highroller: 4,
    Lounge.eccentric: 0,
    Lounge.lurker: 0,
  };

  const Rule({
    // set also in cloud function userCreated
    this.maxMeetingDuration = 300,
    this.minSpeed = 0,
    this.importance = defaultImportance,
  });

  final int maxMeetingDuration;
  final int minSpeed;
  final Map<Lounge, int> importance;

  factory Rule.fromMap(Map<String, dynamic> data) {
    final int maxMeetingDuration = data['maxMeetingDuration'];
    final int minSpeed = data['minSpeed'];

    final Map<Lounge, int> importance = {};
    final Map<String, dynamic> x = data['importance'];
    for (final k in x.keys) {
      final lounge = Lounge.values.firstWhere((l) => l.toStringEnum() == k);
      importance[lounge] = x[k]! as int;
    }

    return Rule(
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
class UserModel extends Equatable {
  static const int MAX_SHOWN_NAME_LENGTH = 10;

  UserModel({
    // set also in cloud function userCreated
    required this.id,
    this.status = Status.ONLINE,
    this.meeting,
    this.name = '',
    this.bio = '',
    this.rating = 1,
    this.numRatings = 0,
    this.heartbeatBackground,
    this.imageUrl,
    this.heartbeatForeground,
    this.rule = const Rule(),
    this.loungeHistory = const <Lounge>[],
    this.loungeHistoryIndex = -1,
    this.blocked = const <String>[],
    this.friends = const <String>[],
  }) {
    setTags();
  }

  final String id;
  final DateTime? heartbeatBackground;
  final DateTime? heartbeatForeground;
  final Status status;

  final String? meeting;
  Rule rule;

  String name;
  String? imageUrl;
  String bio;
  late List<String> _tags;
  void setTags() {
    _tags = [name.toLowerCase(), ...tagsFromBio(bio)];
  }

  // https://stackoverflow.com/questions/51568821/works-in-chrome-but-breaks-in-safari-invalid-regular-expression-invalid-group
  // (?<=#)[a-zA-Z0-9]+ -> (?:#)[a-zA-Z0-9]+
  static List<String> tagsFromBio(String bio) {
    RegExp r = RegExp(r"(?:#)[a-zA-Z0-9]+");
    final matches = r.allMatches(bio).toList();
    final List<String> tags = [];
    for (final m in matches) {
      final t = bio.substring(m.start + 1, m.end).toLowerCase();
      tags.add(t);
    }
    return tags;
  }

  void setNameOrBio({String? name, String? bio}) {
    if (name is String) this.name = name.trim();
    if (bio is String) this.bio = bio.trim();
    if (name is String || bio is String) setTags();
  }

  final double rating;
  final int numRatings;

  final List<Lounge>
      loungeHistory; // actually circular array containing recent 100 lounges
  final int loungeHistoryIndex; // index where 0 is; goes anti-clockwise

  final List<String> blocked;
  final List<String> friends;

  @override
  List<Object> get props => [id];

  @override
  bool get stringify => true;

  factory UserModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      log('user.fromMap - data == null');
      throw StateError('missing data for uid: $documentId');
    }

    // log('user.fromMap - data=$data');
    // log('user.fromMap - data=${data['bidsIn']}');
    // log('user.fromMap - data=${data['bidsIn'].runtimeType}');

    final Status status =
        Status.values.firstWhere((e) => e.toStringEnum() == data['status']);
    final String? meeting = data['meeting'];
    final String name = data['name'] ?? '';
    final String bio = data['bio'] ?? '';
    final String imageUrl = data['imageUrl'] ?? '';
    final double rating = double.tryParse(data['rating'].toString()) ?? 1;
    final int numRatings = int.tryParse(data['numRatings'].toString()) ?? 0;
    final DateTime? heartbeatBackground = data['heartbeatBackground']?.toDate();
    final DateTime? heartbeatForeground = data['heartbeatForeground']?.toDate();
    final Rule rule =
        data['rule'] == null ? Rule() : Rule.fromMap(data['rule']);

    final List<Lounge> loungeHistory = data.containsKey('loungeHistory') &&
            data['loungeHistory'] != null
        ? List<Lounge>.from(data['loungeHistory']
            .map((item) => Lounge.values.firstWhere((e) => e.index == item)))
        : [];

    final int loungeHistoryIndex = data['loungeHistoryIndex'] ?? 0;

    final List<String> blocked = List.castFrom(
        data.containsKey('blocked') && data['blocked'] != null
            ? data['blocked']
            : []);
    final List<String> friends = List.castFrom(
        data.containsKey('friends') && data['friends'] != null
            ? data['friends']
            : []);

    return UserModel(
      id: documentId,
      status: status,
      meeting: meeting,
      name: name,
      bio: bio,
      imageUrl: imageUrl,
      rating: rating,
      numRatings: numRatings,
      heartbeatBackground: heartbeatBackground,
      heartbeatForeground: heartbeatForeground,
      rule: rule,
      loungeHistory: loungeHistory,
      loungeHistoryIndex: loungeHistoryIndex,
      blocked: blocked,
      friends: friends,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.toStringEnum(),
      'meeting': meeting,
      'bio': bio,
      'name': name,
      'tags': _tags,
      'imageUrl': imageUrl,
      'rating': rating,
      'numRatings': numRatings,
      'heartbeatBackground': heartbeatBackground,
      'heartbeatForeground': heartbeatForeground,
      'rule': rule.toMap(),
      'loungeHistory': loungeHistory.map((e) => e.index).toList(),
      'loungeHistoryIndex': loungeHistoryIndex,
      'blocked': blocked,
      'friends': friends,
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, status: $status, meeting: $meeting, bio: $bio, name: $name, _tags: $_tags, rating: $rating, numRatings: $numRatings, heartbeatBackground: $heartbeatBackground, heartbeatForeground: $heartbeatForeground}';
  }

  bool isInMeeting() => meeting != null;
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
