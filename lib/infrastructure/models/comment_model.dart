class CommentModel {
  int? messageId;
  String? message;
  String? userId;
  String? hostUid;

  CommentModel({this.messageId, this.message, this.userId, this.hostUid});

  CommentModel.fromJson(Map<String, dynamic> json) {
    messageId = json['messageId'];
    message = json['message'];
    userId = json['userId'];
    hostUid = json['hostUid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageId'] = this.messageId;
    data['message'] = this.message;
    data['userId'] = this.userId;
    data['hostUid'] = this.hostUid;
    return data;
  }
}
