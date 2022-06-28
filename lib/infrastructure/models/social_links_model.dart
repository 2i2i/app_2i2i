class SocialLinksModel {
  String? accountName;
  String? userEmail;
  String? userId;
  String? userName;

  SocialLinksModel({this.accountName, this.userEmail, this.userId, this.userName});

  SocialLinksModel.fromJson(Map<String, dynamic> json) {
    accountName = json['account_name'];
    userEmail = json['user_email'];
    userId = json['user_id'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_name'] = this.accountName;
    data['user_email'] = this.userEmail;
    data['user_id'] = this.userId;
    data['user_name'] = this.userName;
    return data;
  }
}
