class AppConfig {
  static final AppConfig _singleton = AppConfig._internal();

  AppConfig._internal();

  factory AppConfig() {
    return _singleton;
  }

  int RINGPAGEDURATION = 30;
}
