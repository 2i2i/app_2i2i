class InstagramConfig {
  static InstagramConfig? _instance;

  static InstagramConfig get instance {
    _instance ??= InstagramConfig._init();
    return _instance!;
  }

  InstagramConfig._init();

  static const String clientID = '1368767086955518';
  static const String appSecret = '87dc91706c3af8bd102228c24a56fd05';
  static const String redirectUri = 'https://about.2i2i.app/';
  static const String redirectUriHost = 'about.2i2i.app';
  static const String scope = 'user_profile';
  static const String responseType = 'code';
  static String url =
      'https://api.instagram.com/oauth/authorize?client_id=$clientID&redirect_uri=$redirectUri&scope=user_profile,user_media&response_type=$responseType';
}
