import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_2i2i/ui/screens/localization/en.dart';
import 'package:app_2i2i/ui/screens/localization/zh.dart';
import 'package:app_2i2i/ui/screens/localization/es.dart';
import 'package:app_2i2i/ui/screens/localization/ar.dart';
import 'package:app_2i2i/ui/screens/localization/de.dart';
import 'package:app_2i2i/ui/screens/localization/ko.dart';

class ApplicationLocalizations {
  final Locale appLocale;

  ApplicationLocalizations(this.appLocale);

  static ApplicationLocalizations? of(BuildContext context) {
    return Localizations.of<ApplicationLocalizations>(
        context, ApplicationLocalizations);
  }

  Map<String, String>? _localizedStrings;

  Future<ApplicationLocalizations> load() async {
    Map map = {};
    switch (appLocale.languageCode) {
      case 'en':
        map = en().data();
        break;
      case 'zh':
        map = zh().data();
        break;
      case 'es':
        map = es().data();
        break;
      case 'ar':
        map = ar().data();
        break;
      case 'de':
        map = de().data();
        break;
      case 'ko':
        map = ko().data();
        break;
    }
    _localizedStrings = map.cast();
    return this;
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }
}

class ApplicationLocalizationsDelegate
    extends LocalizationsDelegate<ApplicationLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh', 'es', 'ar', 'de', 'ko'].contains(locale.languageCode);
  }

  @override
  Future<ApplicationLocalizations> load(Locale locale) {
    return ApplicationLocalizations(locale).load();
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<ApplicationLocalizations> old) {
    return false;
  }
}
