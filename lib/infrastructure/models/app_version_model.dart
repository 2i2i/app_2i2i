class AppVersionModel {
  String? androidVersion;
  String? iosVersion;
  String? webVersion;

  AppVersionModel({this.androidVersion, this.iosVersion, this.webVersion});

  AppVersionModel.fromJson(Map<String, dynamic> json) {
    androidVersion = json['android'];
    iosVersion = json['ios'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['android'] = this.androidVersion;
    data['ios'] = this.iosVersion;
    return data;
  }
}
