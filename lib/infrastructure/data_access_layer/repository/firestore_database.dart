import 'dart:async';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/app_version_model.dart';
import 'package:app_2i2i/infrastructure/models/bid_model.dart';
import 'package:app_2i2i/infrastructure/models/chat_model.dart';
import 'package:app_2i2i/infrastructure/models/fx_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_history_model.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';
import 'package:app_2i2i/infrastructure/models/redeem_coin_model.dart';
import 'package:app_2i2i/infrastructure/models/room_model.dart';
import 'package:app_2i2i/infrastructure/models/social_links_model.dart';
import 'package:app_2i2i/infrastructure/models/token_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'firestore_path.dart';
import 'firestore_service.dart';

class FirestoreDatabase {
  FirestoreDatabase._internal();

  static final FirestoreDatabase _singleton = FirestoreDatabase._internal();

  factory FirestoreDatabase() {
    return _singleton;
  }

  final _service = FirestoreService.instance;

  //create user function
  Future createUser(String uid) async {
    final createdUserModel = UserModel(
        id: uid,
        status: Status.ONLINE,
        meeting: null,
        bio: "",
        name: "",
        rating: 1,
        numRatings: 0,
        tags: [],
        rule: Rule(
          maxMeetingDuration: 300,
          minSpeedMicroALGO: 0,
          importance: {
            Lounge.chrony: 1,
            Lounge.highroller: 4,
            Lounge.eccentric: 0,
            Lounge.lurker: 0,
          },
        ),
        loungeHistory: [],
        loungeHistoryIndex: -1,
        blocked: [],
        friends: [],
        imageUrl: '',
        heartbeatBackground: DateTime.now(),
        heartbeatForeground: DateTime.now(),
        socialLinks: []);
    final userInfoMap = createdUserModel.toMap();
    userInfoMap['heartbeatBackground'] = FieldValue.serverTimestamp();
    userInfoMap['heartbeatForeground'] = FieldValue.serverTimestamp();
    await _service.firestore.collection(FirestorePath.users()).doc(createdUserModel.id).set(userInfoMap).catchError(
      (onError) {
        log("$E createUser : $onError");
      },
    );
  }

  String newDocId({required String path}) => _service.newDocId(path: path);

  Future addAlgorandAccount(String uid, String algorandAccount, String type) => _service.setData(
        path: FirestorePath.algorandAccount(uid, algorandAccount),
        data: {
          'type': type,
          'ts': FieldValue.serverTimestamp(),
          'id': algorandAccount,
        },
        merge: false,
      );

  Future acceptBid(Meeting meeting) async {
    return _service.runTransaction((transaction) {
      // create meeting

      final meetingDocRef = _service.firestore.collection(FirestorePath.meetings()).doc(meeting.id);
      transaction.set(meetingDocRef, meeting.toMap());

      // lock users
      final lockObj = {'meeting': meeting.id};
      final userADocRef = _service.firestore.doc(FirestorePath.user(meeting.A));
      transaction.update(userADocRef, lockObj);
      final userBDocRef = _service.firestore.doc(FirestorePath.user(meeting.B));
      transaction.update(userBDocRef, lockObj);

      // deactivate bids
      final bidOutRef = _service.firestore.doc(FirestorePath.bidOut(meeting.A, meeting.id));
      final bidInPublicRef = _service.firestore.doc(FirestorePath.bidInPublic(meeting.B, meeting.id));
      final bidInPrivateRef = _service.firestore.doc(FirestorePath.bidInPrivate(meeting.B, meeting.id));
      final bidObj = {'active': false};
      transaction.update(bidOutRef, bidObj);
      transaction.update(bidInPublicRef, bidObj);
      transaction.update(bidInPrivateRef, bidObj);

      return Future.value();
    }).catchError((onError) {
      log("$E acceptBid : $onError");
    });
  }

  Future addBid(BidOut bidOut, BidIn bidIn) async {
    return _service.runTransaction((transaction) {
      final bidOutRef = _service.firestore.doc(FirestorePath.bidOut(bidIn.private!.A, bidOut.id));
      final bidInPublicRef = _service.firestore.doc(FirestorePath.bidInPublic(bidOut.B, bidOut.id));
      final bidInPrivateRef = _service.firestore.doc(FirestorePath.bidInPrivate(bidOut.B, bidOut.id));

      transaction.set(bidOutRef, bidOut.toMap(), SetOptions(merge: false));
      transaction.set(bidInPublicRef, bidIn.public.toMap(), SetOptions(merge: false));
      transaction.set(bidInPrivateRef, bidIn.private!.toMap(), SetOptions(merge: false));

      return Future.value();
    }).catchError((onError) {
      log("$E addBid : $onError");
    });
  }

  Future cancelBid({required String A, required String B, required String bidId}) async {
    return _service.runTransaction((transaction) {
      final bidOutRef = _service.firestore.doc(FirestorePath.bidOut(A, bidId));
      final bidInPublicRef = _service.firestore.doc(FirestorePath.bidInPublic(B, bidId));
      final bidInPrivateRef = _service.firestore.doc(FirestorePath.bidInPrivate(B, bidId));

      final obj = {'active': false};

      transaction.update(bidOutRef, obj);
      transaction.update(bidInPublicRef, obj);
      transaction.update(bidInPrivateRef, obj);

      return Future.value();
    }).catchError((onError) {
      log("$E cancelBid : $onError");
    });
  }

  Future<void> updateDeviceInfo(String uid, Map<String, String?> data) => _service
          .setData(
        path: FirestorePath.device(uid),
        data: data,
        merge: true,
      )
          .catchError((onError) {
        log("$E updateDeviceInfo : $onError");
      });

  Future<void> updateToken(String uid, String token) {
    final tokenModel = TokenModel(value: token);
    return _service.setData(
      path: FirestorePath.token(uid, token),
      data: tokenModel.toJson(),
      merge: true,
    );
  }

  Future<void> removeToken(String uid, [String? token]) async {
    token ??= await FirebaseMessaging.instance.getToken();
    if (token?.isNotEmpty ?? false) {
      return _service.deleteData(path: FirestorePath.token(uid, token!));
    }
  }

  Future<void>? updateUserHeartbeatFromForeground(String uid, {bool setStatus = false}) =>
      setStatus ? _updateUserHeartbeat(uid, 'heartbeatForeground', newStatus: 'ONLINE') : _updateUserHeartbeat(uid, 'heartbeatForeground');

  Future<void>? updateUserHeartbeatFromBackground(String uid, {bool setStatus = false}) =>
      setStatus ? _updateUserHeartbeat(uid, 'heartbeatBackground', newStatus: 'IDLE') : _updateUserHeartbeat(uid, 'heartbeatBackground');

  Future<void>? _updateUserHeartbeat(String uid, String field, {String? newStatus}) {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    final data = <String, dynamic>{
      field: FieldValue.serverTimestamp(),
    };
    if (newStatus != null) data['status'] = newStatus;

    return _service
        .setData(
      path: FirestorePath.user(uid),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      log("$E _updateUserHeartbeat : $onError");
    });
  }

  Future<void> updateMeeting(String meetingId, Map<String, dynamic> data) {
    return _service
        .setData(
      path: FirestorePath.meeting(meetingId),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      log("$E updateMeeting : $onError");
    });
  }

  Future<void> updateMeetingStatus(String meetingId, Map<String, dynamic> data) {
    return _service
        .setData(
      path: FirestorePath.meeting(meetingId),
      data: data,
      merge: true,
    )
        .catchError((onError) {
      log("$E updateMeetingStatus : $onError");
    });
  }

  Future meetingEndUnlockUser(Map<String, dynamic> meeting, Map<String, dynamic> data) async {
    return _service.runTransaction((transaction) {
      final userARef = _service.firestore.doc(FirestorePath.user(meeting['meetingUserA']));
      final userBRef = _service.firestore.doc(FirestorePath.user(meeting['meetingUserB']));
      final meetingRef = _service.firestore.doc(FirestorePath.meeting(meeting['meetingId']));

      final obj = {'meeting': null};

      transaction.update(meetingRef, data);
      transaction.update(userARef, obj);
      transaction.update(userBRef, obj);

      return Future.value();
    }).catchError((onError) {
      log("$E meetingEndUnlockUser : $onError");
    });
  }

  Future<void> updateUserNameAndBio(String uid, Map<String, dynamic> data) => _service
          .setData(
        path: FirestorePath.user(uid),
        data: data,
        merge: true,
      )
          .catchError((onError) {
        log("$E updateUserNameAndBio : $onError");
      });

  Future<void> addRating(String uid, String meetingId, RatingModel rating) => _service
          .setData(
        path: FirestorePath.newRating(uid, meetingId),
        data: rating.toMap(),
      )
          .catchError((onError) {
        log("$E addRating : $onError");
      });

  Stream<List<RatingModel>> getUserRatings(String uid) {
    return _service
        .collectionStream(
      path: FirestorePath.ratings(uid),
      queryBuilder: (query) => query.orderBy('rating', descending: true),
      builder: (data, documentId) {
        return RatingModel.fromMap(data, documentId);
      },
    )
        .handleError(
      (value) {
        log("$E addRating : $value");
      },
    );
  }

  Future<void> addBlocked(String uid, String targetUid) => _service
          .setData(
        path: FirestorePath.user(uid),
        data: {
          'blocked': FieldValue.arrayUnion([targetUid])
        },
        merge: true,
      )
          .catchError((onError) {
        log("$E addBlocked : $onError");
      });

  Future<void> addFriend(String uid, String targetUid) => _service
          .setData(
        path: FirestorePath.user(uid),
        data: {
          'friends': FieldValue.arrayUnion([targetUid])
        },
        merge: true,
      )
          .catchError((onError) {
        log("$E addFriend : $onError");
      });

  Future<void> removeBlocked(String uid, String targetUid) => _service
          .setData(
        path: FirestorePath.user(uid),
        data: {
          'blocked': FieldValue.arrayRemove([targetUid])
        },
        merge: true,
      )
          .catchError((onError) {
        log("$E removeBlocked : $onError");
      });

  Future<void> removeFriend(String uid, String targetUid) => _service.setData(
        path: FirestorePath.user(uid),
        data: {
          'friends': FieldValue.arrayRemove([targetUid])
        },
        merge: true,
      );

  Stream<UserModel> userStream({required String uid}) {
    return _service
        .documentStream(
      path: FirestorePath.user(uid),
      builder: (data, documentId) {
        if (data == null) {
          return UserModel(id: documentId);
        }
        return UserModel.fromMap(data, documentId);
      },
    )
        .handleError((onError) {
      log("$E userStream : $onError");
    });
  }

  Stream<FXModel> FXStream({required int assetId}) {
    return _service
        .documentStream(
      path: FirestorePath.FX(assetId),
      builder: (data, documentId) {
        if (data == null) return FXModel.subjective(id: assetId);
        return FXModel.objective(data, assetId);
      },
    )
        .handleError((onError) {
      log("$E FXStream : $onError");
    });
  }

  Future<FXModel?> getFX(int assetId) async {
    final snapshot = await _service.getData(path: FirestorePath.FX(assetId)).catchError((onError) {
      log("$E getFX : $onError");
    });
    if (snapshot?.data() is Map) {
      final data = snapshot!.data() as Map<String, dynamic>?;
      return FXModel.objective(data!, assetId);
    }
    return FXModel.subjective(id: assetId);
  }

  Future<List<TokenModel>> getTokenFromId(String uid) async {
    final snapshot = await _service
        .getCollectionData(
      path: FirestorePath.tokens(uid),
      builder: (Map<String, dynamic>? data, DocumentReference<Object?> documentID) {
        return TokenModel.fromJson(data ?? {});
      },
    )
        .catchError((onError) {
      log("$E getTokenFromId : $onError");
    });
    return snapshot.toList();
  }

  Future<void> updateUser(UserModel user) {
    return _service
        .setData(
      path: FirestorePath.user(user.id),
      data: user.toMap(),
      merge: true,
    )
        .catchError((onError) {
      log("$E updateUser : $onError");
    });
  }

  Future<AppVersionModel?> getAppVersion() async {
    final snapshot = await _service.getData(path: FirestorePath.appVersion()).catchError((onError) {
      log("$E getAppVersion : $onError");
    });
    if (snapshot?.data() is Map) {
      final data = snapshot?.data() as Map<String, dynamic>?;
      return AppVersionModel.fromJson(data!);
    }
    return null;
  }

  Future<UserModel?> getUser(String uid) async {
    final documentSnapshot = await _service.getData(path: FirestorePath.user(uid)).catchError((onError) {
      log("$E getUser : $onError");
    });
    if (documentSnapshot?.exists ?? false) {
      final id = documentSnapshot!.id;
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

  Stream<int?> numMeetingsStream() {
    return _service
        .documentStream(
      path: FirestorePath.numMeetings(),
      builder: (data, documentId) {
        if (data == null) return null;
        return data['numMeetings'] as int;
      },
    )
        .handleError((onError) {
      log("$E numMeetingsStream : $onError");
    });
  }

  Future<List> checkAddressAvailable(String address) async {
    final documentSnapshot = await _service
        .getCollectionGroupData(
      path: FirestorePath.alograndAccountPath(),
      queryBuilder: (query) => query.where('id', isEqualTo: address).orderBy('ts', descending: true),
      builder: (Map<String, dynamic>? data, DocumentReference documentID) {
        if (data is Map) {
          List paths = documentID.path.split('/');
          if (paths.length > 1) {
            String userId = paths[1];
            return userId;
          }
        }
      },
    )
        .catchError((onError) {
      log("$E checkAddressAvailable : $onError");
    });
    if (documentSnapshot.isNotEmpty) {
      return documentSnapshot.toList();
    }
    return [];
  }

  Future<List> checkInstaUserAvailable(SocialLinksModel socialLinksModel) async {
    final documentSnapshot = await _service
        .getCollectionData(
      path: FirestorePath.users(),
      queryBuilder: (query) => query.where('socialLinks', arrayContains: socialLinksModel.toJson()),
      builder: (Map<String, dynamic>? data, DocumentReference documentID) {
        return documentID.id;
      },
    )
        .catchError((onError) {
      log("$E checkInstaUserAvailable : $onError");
    });
    if (documentSnapshot.isNotEmpty) {
      return documentSnapshot.toList();
    }
    return [];
  }

  Stream<List<UserModel>> usersStream({List<String> tags = const <String>[]}) {
    log(I + 'usersStream - tags=$tags');
    return _service
        .collectionStream(
      path: FirestorePath.users(),
      builder: (data, documentId) {
        return UserModel.fromMap(data, documentId);
      },
      queryBuilder: tags.isEmpty ? null : (query) => query.where('tags', arrayContainsAny: tags),
    )
        .handleError((onError) {
      log("$E usersStream : $onError");
    });
  }

  Stream<List<RedeemCoinModel>> redeemCoinStream({required String uid}) {
    return _service
        .documentStream(
      path: FirestorePath.redeem(uid),
      builder: (data, documentId) {
        // log(B + 'redeemCoinStream uid=$uid data=$data');
        if (data != null) {
          final list = data.entries.toList();
          return list.map((e) => RedeemCoinModel(assetId: int.parse(e.key), uid: uid, value: e.value)).toList();
        }
        return <RedeemCoinModel>[];
      },
    )
        .handleError(
      (onError) {
        log("$E redeemCoinStream : $onError");
      },
    );
  }

  Stream<Room> roomStream({required String meetingId}) => _service
          .documentStream(
        path: FirestorePath.room(meetingId),
        builder: (data, documentId) => Room.fromMap(data, meetingId),
      )
          .handleError((onError) {
        log("$E roomStream : $onError");
      });

  Stream<List<RTCIceCandidate>> iceCandidatesStream({
    required String meetingId,
    required String subCollectionName,
  }) {
    return _service
        .collectionAddedStream(
      path: FirestorePath.iceCandidates(meetingId, subCollectionName),
      builder: (data, documentId) {
        return RTCIceCandidate(data!['candidate'], data['sdpMid'], data['sdpMlineIndex']);
      },
    )
        .handleError((onError) {
      log("$E iceCandidatesStream : $onError");
    });
  }

  Stream<List<BidInPublic>> bidInsPublicStream({required String uid}) {
    return _service
        .collectionStream(
      path: FirestorePath.bidInsPublic(uid),
      builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true).orderBy('ts'),
    )
        .handleError((onError) {
      log("$E bidInsPublicStream : $onError");
    });
  }

  Stream<List<BidInPrivate>> bidInsPrivateStream({required String uid}) {
    return _service
        .collectionStream(
      path: FirestorePath.bidInsPrivate(uid),
      builder: (data, documentId) => BidInPrivate.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true),
    )
        .handleError((onError) {
      log("$E bidInsPrivateStream : $onError");
    });
  }

  Stream<List<BidOut>> bidOutsStream({required String uid}) {
    return _service
        .collectionStream(
      path: FirestorePath.bidOuts(uid),
      builder: (data, documentId) => BidOut.fromMap(data, documentId),
      queryBuilder: (query) => query.where('active', isEqualTo: true),
    )
        .handleError((onError) {
      log("$E bidOutsStream : $onError");
    });
  }

  Stream<BidOut> getBidOut({required String uid, required String bidId}) => _service
          .documentStream(
        path: FirestorePath.bidOut(uid, bidId),
        builder: (data, documentId) => BidOut.fromMap(data, documentId),
      )
          .handleError((onError) {
        log("$E getBidOut : $onError");
      });

  Stream<BidInPublic> getBidInPublic({required String uid, required String bidId}) => _service
          .documentStream(
        path: FirestorePath.bidInPublic(uid, bidId),
        builder: (data, documentId) => BidInPublic.fromMap(data, documentId),
      )
          .handleError((onError) {
        log("$E getBidInPublic : $onError");
      });

  Stream<BidInPrivate> getBidInPrivate({required String uid, required String bidId}) => _service
          .documentStream(
        path: FirestorePath.bidInPrivate(uid, bidId),
        builder: (data, documentId) => BidInPrivate.fromMap(data, documentId),
      )
          .handleError((onError) {
        log("$E getBidInPrivate : $onError");
      });

  Stream<Meeting> meetingStream({required String id}) {
    return _service
        .documentStream(
            path: FirestorePath.meeting(id),
            builder: (data, documentId) {
              return Meeting.fromMap(data, documentId);
            })
        .handleError((onError) {
      log("$E meetingStream : $onError");
    });
  }

  Stream<List<TopMeeting>> topStream(path) => _service
          .collectionStream(
        path: path,
        builder: (data, documentId) => TopMeeting.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('value', descending: true),
      )
          .handleError((onError) {
    log("$E topStream : $onError");
        return [];
      });

  Stream<List<TopMeeting>> topValuesStream() => topStream(FirestorePath.topValues());

  Stream<List<TopMeeting>> topSpeedsStream() => topStream(FirestorePath.topSpeeds());

  Stream<List<TopMeeting>> topDurationsStream() => topStream(FirestorePath.topDurations());

  // Future<void> setMeeting(Meeting meeting) => _service.setData(
  //       path: FirestorePath.meeting(meeting.id),
  //       data: meeting.toMap(),
  //       merge: true,
  //     );

  // Stream<Map> meetingHistory({required MeetingDataModel meetingDataModel}) =>
  //     _meetingHistoryX(meetingDataModel.uId!, meetingDataModel.userAorB!,lastDocument: meetingDataModel.lastDocument,limit: meetingDataModel.page!);

  Stream<Map> meetingHistory({required MeetingDataModel meetingDataModel}) {
    return _service
        .getDocumentStream(
      path: FirestorePath.meetings(),
      builder: (data, documentId) => Meeting.fromMap(data, documentId),
      queryBuilder: (query) {
        log('meetingHistory meetingDataModel.userAorB=${meetingDataModel.userAorB} meetingDataModel.uid=${meetingDataModel.uid} meetingDataModel.lastDocument=${meetingDataModel.lastDocument} meetingDataModel.page=${meetingDataModel.page}');
        query = query.where(meetingDataModel.userAorB, isEqualTo: meetingDataModel.uid);
        if (meetingDataModel.lastDocument != null) {
          query = query.startAfterDocument(meetingDataModel.lastDocument!).limit(meetingDataModel.page);
        } else {
          query = query.limit(meetingDataModel.page);
        }
        return query;
      },
    )
        .handleError((onError) {
      log("$E meetingHistory : $onError");
    });
  }

  //chat
  Stream<List<ChatModel>> getChat(String uid) {
    return _service
        .collectionStream(
      path: FirestorePath.chat(uid),
      builder: (data, documentId) => ChatModel.fromMap(data!),
      queryBuilder: (query) => query.orderBy('ts', descending: true).limit(100),
    )
        .handleError((onError) {
      log("$E getChat : $onError");
    });
  }

  Future<void> addChat(String uid, ChatModel chat) => _service
          .setData(
        path: FirestorePath.chat(uid) + '/' + _service.newDocId(path: FirestorePath.chat(uid)),
        data: chat.toMap(),
      )
          .catchError((onError) {
        log("$E addChat : $onError");
      });
}
