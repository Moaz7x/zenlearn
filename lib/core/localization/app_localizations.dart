import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'translations/ar.dart';
import 'translations/en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON files based on locale
    switch (locale.languageCode) {
      case 'ar':
        _localizedStrings = arTranslations;
        break;
      case 'en':
      default:
        _localizedStrings = enTranslations;
        break;
    }
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static bool isRtl(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  static String formatDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).format(date);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension to make it easier to access translations
extension TranslateX on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context).translate(this);
  }
}
