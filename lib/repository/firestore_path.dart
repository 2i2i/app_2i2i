class FirestorePath {
  static String testA() => 'test/a';

  static String user(String uid) => 'users/$uid';
  static String userPrivate(String uid) => 'users/$uid/private/main';
  static String users() => 'users';

  static String meetings() => 'meetings';
  static String meeting(String id) => 'meetings/$id';

  static String bidIns(String uid) => 'users/$uid/bidIns';
  static String bidOuts(String uid) => 'users/$uid/bidOuts';
  static String bidPrivate(String uid, String bidId) => 'users/$uid/bidIns/$bidId/private/main';

  static String rating(String uid) => 'users/$uid/ratings/';

  // static String meetingMessages(String meetingId, String sourceUid, String targetUid) => 'meetings/$meetingId/$sourceUid->$targetUid';
  static String room(String meetingId) => 'meetings/$meetingId/rooms/main';

  static String iceCandidates(String meetingId, String subCollectionName) =>
      'meetings/$meetingId/rooms/main/$subCollectionName';
}
