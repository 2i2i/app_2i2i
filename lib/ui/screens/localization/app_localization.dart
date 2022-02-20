import 'dart:async';

import 'package:app_2i2i/ui/screens/localization/cn.dart';
import 'package:app_2i2i/ui/screens/localization/es.dart';
import 'package:app_2i2i/ui/screens/localization/kr.dart';
import 'package:flutter/material.dart';

import 'ar.dart';
import 'de.dart';
import 'en.dart';

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
      case 'cn':
        map = cn().data();
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
      case 'kr':
        map = kr().data();
        break;
    }
    _localizedStrings = map.cast();
    return this;
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }
}

class ApplicationLocalizationsDelegate extends LocalizationsDelegate<ApplicationLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en', 'de'].contains(locale.languageCode);
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
