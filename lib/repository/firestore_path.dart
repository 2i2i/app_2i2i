class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String userPrivate(String uid) => 'users/$uid/private/main';
  static String users() => 'users';
  static String bid(String id) => 'bids/$id';
  static String bidPrivate(String id) => 'bids/$id/private/main';
  static String meeting(String id) => 'meetings/$id';
  // static String meetingMessages(String meetingId, String sourceUid, String targetUid) => 'meetings/$meetingId/$sourceUid->$targetUid';
  static String room(String meetingId) => 'meetings/$meetingId/rooms/main';
  static String iceCandidates(String meetingId, String subCollectionName) =>
      'meetings/$meetingId/rooms/main/$subCollectionName';
}
