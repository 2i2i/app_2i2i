class AppVersionModel {
  String? androidVersion;
  String? iosVersion;
  String? webVersion;
  String? minAppVersion;
  String? releaseNote;

  AppVersionModel(this.minAppVersion, this.releaseNote, {this.androidVersion, this.iosVersion, this.webVersion});

  AppVersionModel.fromJson(Map<String, dynamic> json) {
    androidVersion = json['android'];
    iosVersion = json['ios'];
    webVersion = json['webVersion'];
    minAppVersion = json['minAppVersion'];
    releaseNote = json['releaseNote'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['android'] = this.androidVersion;
    data['ios'] = this.iosVersion;
    data['webVersion'] = this.webVersion;
    data['minAppVersion'] = this.minAppVersion;
    data['releaseNote'] = this.releaseNote;
    return data;
  }
}
