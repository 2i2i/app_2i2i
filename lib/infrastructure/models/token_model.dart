class TokenModel {
  String? token;
  bool? isIos;

  TokenModel({this.token, this.isIos});

  TokenModel.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    isIos = json['isIos'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['isIos'] = this.isIos;
    return data;
  }
}
