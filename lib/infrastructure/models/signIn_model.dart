class SignInModel {
  String? label;
  String? icon;

  SignInModel({this.label, this.icon});

  SignInModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['icon'] = this.icon;
    return data;
  }
}
