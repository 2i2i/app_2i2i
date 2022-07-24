import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../commons/keys.dart';
import '../../data_access_layer/repository/firestore_database.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';
import '../../models/app_version_model.dart';

class AppSettingModel extends ChangeNotifier {
  final SecureStorage storage;
  final FirestoreDatabase firebaseDatabase;

  AppSettingModel({
    required this.storage,
    required this.firebaseDatabase,
  });

  ThemeMode? currentThemeMode;
  Locale? locale;

  bool isAutoModeEnable = false;
  bool isAudioEnabled = true;
  bool isVideoEnabled = true;
  bool swapVideo = false;

  bool isInternetAvailable = true;

  void setInternetStatus(bool value) {
    isInternetAvailable = value;
    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    try {
      ConnectivityResult result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } on PlatformException {
      return false;
    }
  }

  void appInit() {
    isVideoEnabled = true;
    isAudioEnabled = true;
    notifyListeners();
  }

  void setAudioStatus(bool value) {
    isAudioEnabled = value;
    notifyListeners();
  }

  void setVideoStatus(bool value) {
    isVideoEnabled = value;
    notifyListeners();
  }

  void setSwapVideo(bool value) {
    swapVideo = value;
    notifyListeners();
  }

  bool updateRequired = false;
  String version = "1.0.22";

  Future<void> setThemeMode(String mode) async {
    await storage.write('theme_mode', mode);
    getTheme(mode);
    // notifyListeners();
  }

  Future<void> setLocal(String local) async {
    await storage.write('language', local);
    getLocal(local);
  }

  Future<void> checkIfUpdateAvailable() async {
    if(kIsWeb){
      return;
    }
    AppVersionModel? appVersion = await firebaseDatabase.getAppVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isAndroid) {
      version = appVersion?.androidVersion ?? "1";
    } else if (Platform.isIOS) {
      version = appVersion?.iosVersion ?? "1";
    }
    updateRequired = (packageInfo.version != version);
    notifyListeners();
  }

  void getLocal(String local) {
    locale = Locale(local);
    notifyListeners();
  }

  Future<String?> getThemeMode() async {
    String themeMode = await storage.read('theme_mode') ?? "";
    getTheme(themeMode);
    return themeMode;
  }

  ThemeMode getTheme(String mode, {bool notify = false}) {
    switch (mode) {
      case Keys.dark:
        isAutoModeEnable = false;
        currentThemeMode = ThemeMode.dark;
        break;
      case Keys.light:
        isAutoModeEnable = false;
        currentThemeMode = ThemeMode.light;
        break;
      case Keys.auto:
      default:
        isAutoModeEnable = true;
        currentThemeMode = ThemeMode.system;
    }
    notifyListeners();
    return currentThemeMode!;
  }
}