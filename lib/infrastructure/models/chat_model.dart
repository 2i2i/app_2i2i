class ChatMessageModel {
  String? chatMessage;
  String? chatMessageId;
  List<String>? chatMessageSeenBy;
  String? chatMessageUserId;
  String? chatMessageUserName;
  int? timeStamp;

  ChatMessageModel(
      {this.chatMessage,
      this.chatMessageId,
      this.chatMessageSeenBy,
      this.chatMessageUserId,
      this.chatMessageUserName,
      this.timeStamp});

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    chatMessage = json['chatMessage'];
    chatMessageId = json['chatMessageId'];
    chatMessageSeenBy = json['chatMessageSeenBy'].cast<String>();
    chatMessageUserId = json['chatMessageUserId'];
    chatMessageUserName = json['chatMessageUserName'];
    timeStamp = json['timeStamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatMessage'] = this.chatMessage;
    data['chatMessageId'] = this.chatMessageId;
    data['chatMessageSeenBy'] = this.chatMessageSeenBy;
    data['chatMessageUserId'] = this.chatMessageUserId;
    data['chatMessageUserName'] = this.chatMessageUserName;
    data['timeStamp'] = this.timeStamp;
    return data;
  }
}
