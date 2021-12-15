import 'package:app_2i2i/repository/secure_storage_service.dart';
import 'package:flutter/material.dart';

class AppSettingModel extends ChangeNotifier {
  final SecureStorage storage;

  AppSettingModel({
    required this.storage,
  });

  ThemeMode? currentThemeMode;

  bool isAutoModeEnable = false;

  Future<void> setThemeMode(String mode) async {
    await storage.write('theme_mode', mode);
    getTheme(mode);
    notifyListeners();
  }

  Future<String?> getThemeMode() async {
    String themeMode = await storage.read('theme_mode') ?? "";
    getTheme(themeMode);
    return themeMode;
  }

  ThemeMode getTheme(String mode, {bool notify = false}) {
    switch (mode) {
      case "DARK":
        isAutoModeEnable = false;
        currentThemeMode = ThemeMode.dark;
        break;
      case "LIGHT":
        isAutoModeEnable = false;
        currentThemeMode = ThemeMode.light;
        break;
      case "AUTO":
      default:
        isAutoModeEnable = true;
        currentThemeMode = ThemeMode.system;
    }
     notifyListeners();
    return currentThemeMode!;
  }
}