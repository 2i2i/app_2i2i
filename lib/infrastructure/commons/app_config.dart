import 'package:app_2i2i/infrastructure/data_access_layer/repository/algorand_service.dart';
import 'package:firebase_core/firebase_core.dart';

class AppConfig {
  static final AppConfig _singleton = AppConfig._internal();

  AppConfig._internal();

  factory AppConfig() {
    return _singleton;
  }

  int RINGPAGEDURATION = 30;

  AlgorandNet ALGORAND_NET = Firebase.app().options.projectId == 'app-2i2i' ? AlgorandNet.mainnet : AlgorandNet.testnet;

  static final String hostUrltest = "https://about.2i2i.app";
  static final String hostUrl = "https://web.2i2i.app";
  static final String androidAppId = "app.i2i2";
  static final String iosAppId = "app.2i2i";
  static final String appStoreId = "1609689141";
}
