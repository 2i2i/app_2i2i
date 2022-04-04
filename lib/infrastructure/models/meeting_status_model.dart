class MeetingStatusModel {
  final String id;
  final String A;
  final String B;
  bool mutedVideoA = false;
  bool mutedVideoB = false;
  bool mutedAudioA = false;
  bool mutedAudioB = false;

  MeetingStatusModel({
    required this.id,
    required this.A,
    required this.B,
    this.mutedVideoA = false,
    this.mutedVideoB = false,
    this.mutedAudioA = false,
    this.mutedAudioB = false,
  });

  factory MeetingStatusModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    final A = data['A'] ?? "";
    final B = data['B'] ?? "";
    final mutedVideoA = data['mutedVideoA'] ?? false;
    final mutedVideoB = data['mutedVideoB'] ?? false;
    final mutedAudioA = data['mutedAudioA'] ?? false;
    final mutedAudioB = data['mutedAudioB'] ?? false;

    return MeetingStatusModel(
      id: documentId,
      A: A,
      B: B,
      mutedVideoA: mutedVideoA,
      mutedVideoB: mutedVideoB,
      mutedAudioA: mutedAudioA,
      mutedAudioB: mutedAudioB,
    );
  }

  Map<String, dynamic> toMap() {
    final data = new Map<String, dynamic>();
    data['A'] = A;
    data['B'] = B;
    data['mutedVideoA'] = mutedVideoA;
    data['mutedVideoB'] = mutedVideoB;
    data['mutedAudioA'] = mutedAudioA;
    data['mutedAudioB'] = mutedAudioB;
    return data;
  }
}
