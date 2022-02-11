import 'dart:async';

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
      case 'ar':
        map = ar().data();
        break;
      case 'de':
        map = de().data();
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
