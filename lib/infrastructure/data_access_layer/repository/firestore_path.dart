class FirestorePath {
  static String testA() => 'test/a';

  static String user(String uid) => 'users/$uid';
  static String userPrivate(String uid) => 'users/$uid/private/main';
  static String users() => 'users';

  static String meetings() => 'meetings';
  static String topMeetings() => 'topMeetings';
  static String meeting(String meetingId) => 'meetings/$meetingId';

  static String bidInsPublic(String uid) => 'users/$uid/bidInsPublic';
  static String bidInsPrivate(String uid) => 'users/$uid/bidInsPrivate';
  static String bidOuts(String uid) => 'users/$uid/bidOuts';
  static String bidIn(String uid, String bidId) => 'users/$uid/bidIns/$bidId';
  static String bidOut(String uid, String bidId) => 'users/$uid/bidOuts/$bidId';
  static String bidPrivate(String uid, String bidId) => 'users/$uid/bidIns/$bidId/private/main';

  static String ratings(String uid) => 'users/$uid/ratings/';
  static String newRating(String uid, String meetingId) => 'users/$uid/ratings/$meetingId';

  // static String meetingMessages(String meetingId, String sourceUid, String targetUid) => 'meetings/$meetingId/$sourceUid->$targetUid';
  static String room(String meetingId) => 'meetings/$meetingId/rooms/main';

  static String iceCandidates(String meetingId, String subCollectionName) =>
      'meetings/$meetingId/rooms/main/$subCollectionName';
}
