import 'package:app_2i2i/infrastructure/data_access_layer/repository/firestore_database.dart';
import 'package:app_2i2i/infrastructure/data_access_layer/services/logging.dart';
import 'package:app_2i2i/infrastructure/models/meeting_model.dart';

final database = FirestoreDatabase();
void runTests(String myUID) async {
  final otherUID = 'asd';

  final a = await database.getUser(myUID);
  final b = await database.userPrivateStream(uid: myUID);

  try {
    final c = await database.userPrivateStream(uid: otherUID);
    log(E + 'final c = database.userPrivateStream(uid: otherUID);');
  } catch (e) {}

  // final b = database.userStream({required String uid})
  // final b = database.usersStream({List<String> tags = const <String>[]})

//   topSpeedsStream()
//   topDurationsStream()

//   bidInsPublicStream({required String uid})
//   bidInsPrivateStream({required String uid})
//   bidOutsStream({required String uid})
//   getBidInPublic(
//           {required String uid, required String bidId})
//   getBidInPrivate(
//           {required String uid, required String bidId})

//   updateUserHeartbeat(String uid, String status)
//   updateUserNameAndBio(String uid, Map<String, dynamic> data)
//   getUserRatings(String uid)

//   addBlocked(String uid, String targetUid)
//   addFriend(String uid, String targetUid)
//   removeBlocked(String uid, String targetUid)
//   removeFriend(String uid, String targetUid)

//   addBid(BidOut bidOut, BidIn bidIn)
//   cancelBid(BidOut bidOut, String myUid)
//   database.acceptBid(meeting);
//   meetingStream({required String id})
//   updateMeeting(String meetingId, Map<String, dynamic> data)

//   roomStream({required String meetingId})
// iceCandidatesStream({
//     required String meetingId,
//     required String subCollectionName,
//   })

//   meetingHistoryA(String uid)
//   meetingHistoryB(String uid, {int? limit})
}
