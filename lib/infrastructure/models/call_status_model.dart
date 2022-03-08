class CallStatusModel {
  bool? isMuteVideoA;
  bool? isMuteVideoB;
  bool? isMuteAudioA;
  bool? isMuteAudioB;

  CallStatusModel(
      {this.isMuteVideoA,
        this.isMuteVideoB,
        this.isMuteAudioA,
        this.isMuteAudioB});

  CallStatusModel.fromJson(Map<String, dynamic> json,documentId) {
    if (documentId == null) {
      throw StateError('missing data for id: $documentId');
    }
    isMuteVideoA = json['isVideoMuteA'];
    isMuteVideoB = json['isVideoMuteB'];
    isMuteAudioA = json['isAudioMuteA'];
    isMuteAudioB = json['isAudioMuteB'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isVideoMuteA'] = this.isMuteVideoA;
    data['isVideoMuteB'] = this.isMuteVideoB;
    data['isAudioMuteA'] = this.isMuteAudioA;
    data['isAudioMuteB'] = this.isMuteAudioB;
    return data;
  }
}
