class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';

  static String token(String uid) => 'tokens/$uid';
  static String device(String uid) => 'devices/$uid';
  static String chat(String uid) => 'users/$uid/chat';

  static String meetings() => 'meetings';
  static String topSpeeds() => 'topSpeeds';
  static String topDurations() => 'topDurations';
  static String appVersion() => 'test/app_version';
  static String meeting(String meetingId) => 'meetings/$meetingId';
  static String updateCallStatus(String meetingId) => 'calls/$meetingId';

  static String bidInsPublic(String uid) => 'users/$uid/bidInsPublic';
  static String bidInsPrivate(String uid) => 'users/$uid/bidInsPrivate';
  static String bidOuts(String uid) => 'users/$uid/bidOuts';
  static String bidInPublic(String uid, String bidId) => 'users/$uid/bidInsPublic/$bidId';
  static String bidOut(String uid, String bidId) => 'users/$uid/bidOuts/$bidId';
  static String bidInPrivate(String uid, String bidId) => 'users/$uid/bidInsPrivate/$bidId';

  static String ratings(String uid) => 'users/$uid/ratings/';
  static String newRating(String uid, String meetingId) => 'users/$uid/ratings/$meetingId';

  // static String meetingMessages(String meetingId, String sourceUid, String targetUid) => 'meetings/$meetingId/$sourceUid->$targetUid';
  static String room(String meetingId) => 'meetings/$meetingId/rooms/main';

  static String iceCandidates(String meetingId, String subCollectionName) =>
      'meetings/$meetingId/rooms/main/$subCollectionName';
}
