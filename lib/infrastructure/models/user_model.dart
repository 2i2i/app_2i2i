import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data_access_layer/repository/firestore_database.dart';
import '../data_access_layer/services/logging.dart';
import 'social_links_model.dart';

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
  UserModelChanger(this.database, this.uid, this.userModel);

  final FirestoreDatabase database;
  final String uid;
  final UserModel? userModel;

  Future? updateHeartbeatBackground({bool setStatus = false}) {
    if (userModel?.name.isNotEmpty ?? false) return database.updateUserHeartbeatFromBackground(uid, setStatus: setStatus);
    return null;
  }

  Future? updateHeartbeatForeground({bool setStatus = false}) {
    if (userModel?.name.isNotEmpty ?? false) database.updateUserHeartbeatFromForeground(uid, setStatus: setStatus);
    return null;
  }

  Future updateSettings(UserModel user) => database.updateUser(user);

  Future addComment(String targetUid, ChatModel chat) => database.addChat(targetUid, chat);

  // TODO before calling addBlocked or addFriend, need to check whether targetUid already in array
  // do this by getting UserModelPrivate
  // blocked users: we cannot see their bids for us
  // friend users: we see their bids on top
  Future addBlocked(String targetUid) => database.addBlocked(uid, targetUid);

  Future addFriend(String targetUid) => database.addFriend(uid, targetUid);

  Future removeBlocked(String targetUid) => database.removeBlocked(uid, targetUid);

  Future removeFriend(String targetUid) => database.removeFriend(uid, targetUid);
}

@immutable
class Rule extends Equatable {
  static const defaultImportance = {
    Lounge.chrony: 1,
    Lounge.highroller: 4,
    Lounge.eccentric: 0,
    Lounge.lurker: 0,
  };

  const Rule({
    // set also in cloud function userCreated
    this.maxMeetingDuration = 300,
    this.minSpeedMicroALGO = 0,
    this.importance = defaultImportance,
  });

  final int maxMeetingDuration;
  final int minSpeedMicroALGO;
  final Map<Lounge, int> importance;

  factory Rule.fromMap(Map<String, dynamic> data) {
    final int maxMeetingDuration = data['maxMeetingDuration'];
    final int minSpeedALGO = data['minSpeed'];
    final Map<Lounge, int> importance = {};

    final Map<String, dynamic> x = data['importance'];
    for (final k in x.keys) {
      final lounge = Lounge.values.firstWhere((l) => l.toStringEnum() == k);
      importance[lounge] = x[k]! as int;
    }

    return Rule(
      maxMeetingDuration: maxMeetingDuration,
      minSpeedMicroALGO: minSpeedALGO,
      importance: importance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maxMeetingDuration': maxMeetingDuration,
      'minSpeed': minSpeedMicroALGO,
      'importance': importance.map((key, value) => MapEntry(key.toStringEnum(), value)),
    };
  }

  int importanceSize() => importance.values.reduce((value, element) => value + element);

  @override
  List<Object> get props => [maxMeetingDuration, minSpeedMicroALGO, importance];
}

@immutable
class UserModel extends Equatable {
  static const int MAX_SHOWN_NAME_LENGTH = 10;

  UserModel({
    required this.id,
    this.url,
    this.status = Status.ONLINE,
    this.socialLinks = const <SocialLinksModel>[],
    this.meeting,
    this.name = '',
    this.bio = '',
    this.rating = 1,
    this.numRatings = 0,
    this.heartbeatBackground,
    this.tags = const <String>[],
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
  List<SocialLinksModel> socialLinks;
  final String? meeting;

  Rule rule;
  String? url;

  String name;
  String? imageUrl;
  String bio;
  List<String> tags;

  void setTags() {
    tags = [...keysFromName(name), ...tagsFromBio(bio)];
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

  static List<String> keysFromName(String name) {
    List<String> keysList = [];
    String keyWord = "";
    for (var i = 0; i < name.length; i++) {
      if (name[i] == " ") {
        keyWord = "";
      } else {
        keyWord = keyWord + name[i];
        keysList.add(keyWord.toLowerCase());
      }
    }
    return keysList;
  }

  void setNameOrBio({String? name, String? bio}) {
    if (name is String) this.name = name.trim();
    if (bio is String) this.bio = bio.trim();
    if (name is String || bio is String) setTags();
  }

  final double rating;
  final int numRatings;

  final List<Lounge> loungeHistory; // actually circular array containing recent 100 lounges
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

    final Status status = data.containsKey('status') && data['status'] != null
        ? Status.values.firstWhere((e) => e.toStringEnum() == data['status'], orElse: () => Status.ONLINE)
        : Status.ONLINE;
    final List<SocialLinksModel> socialLinksList = data.containsKey('socialLinks') && data['socialLinks'] != null
        ? List<SocialLinksModel>.from(data['socialLinks'].map((item) => SocialLinksModel.fromJson(item)))
        : [];

    final List<Lounge> loungeHistory = data.containsKey('loungeHistory') && data['loungeHistory'] != null
        ? List<Lounge>.from(data['loungeHistory'].map((item) => Lounge.values.firstWhere((e) => e.index == item)))
        : [];
    final List<String> blocked = data.containsKey('blocked') && data['blocked'] != null ? List.castFrom(data['blocked']) : [];
    final List<String> friends = data.containsKey('friends') && data['friends'] != null ? List.castFrom(data['friends']) : [];

    final String? meeting = data['meeting'];
    final String name = data['name'] ?? '';
    final String bio = data['bio'] ?? '';
    final String? imageUrl = data['imageUrl'];
    final double rating = double.tryParse(data['rating'].toString()) ?? 1;
    final int numRatings = int.tryParse(data['numRatings'].toString()) ?? 0;
    final DateTime? heartbeatBackground = data['heartbeatBackground']?.toDate();
    final DateTime? heartbeatForeground = data['heartbeatForeground']?.toDate();
    final Rule rule = data.containsKey('rule') && data['rule'] != null ? Rule.fromMap(data['rule']) : Rule();
    final int loungeHistoryIndex = data['loungeHistoryIndex'] ?? 0;

    return UserModel(
        id: documentId,
        url: data['url']?.toString(),
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
        socialLinks: socialLinksList);
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'status': status.toStringEnum(),
      'meeting': meeting,
      'bio': bio,
      'name': name,
      'tags': tags,
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
      'socialLinks': FieldValue.arrayUnion(socialLinks.map((e) => e.toJson()).toList()),
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, status: $status, meeting: $meeting, bio: $bio, name: $name, _tags: $tags, rating: $rating, numRatings: $numRatings, heartbeatBackground: $heartbeatBackground, heartbeatForeground: $heartbeatForeground}';
  }

  bool isInMeeting() => meeting != null;

  bool isVerified() => socialLinks.isNotEmpty;
}

