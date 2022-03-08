import 'package:flutter/material.dart';

import '../../commons/keys.dart';
import '../../data_access_layer/repository/secure_storage_service.dart';

class AppSettingModel extends ChangeNotifier {
  final SecureStorage storage;

  AppSettingModel({
    required this.storage,
  });

  ThemeMode? currentThemeMode;
  Locale? locale;

  bool isAutoModeEnable = false;
  bool isAudioEnabled = true;
  bool isVideoEnabled = true;
  bool swapVideo = false;

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

  Future<void> setThemeMode(String mode) async {
    await storage.write('theme_mode', mode);
    getTheme(mode);
    // notifyListeners();
  }

  Future<void> setLocal(String local) async {
    await storage.write('language', local);
    getLocal(local);
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