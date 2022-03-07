class AppVersionModel {
  String? androidVersion;
  String? iosVersion;
  String? webVersion;

  AppVersionModel({this.androidVersion, this.iosVersion, this.webVersion});

  AppVersionModel.fromJson(Map<String, dynamic> json) {
    androidVersion = json['android_version'];
    iosVersion = json['ios_version'];
    webVersion = json['web_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['android_version'] = this.androidVersion;
    data['ios_version'] = this.iosVersion;
    data['web_version'] = this.webVersion;
    return data;
  }
}
