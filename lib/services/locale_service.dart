import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class LocaleService {
  static const _key = 'app_locale';

  static const supportedCodes = ['tr', 'en', 'ru', 'uk', 'es'];

  static Future<String> getSavedLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && supportedCodes.contains(saved)) {
      return saved;
    }

    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final resolved = supportedCodes.contains(deviceCode) ? deviceCode : 'en';
    await prefs.setString(_key, resolved);
    return resolved;
  }

  static Future<void> setSavedLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  static Locale toLocale(String code) {
    return Locale(code);
  }

  static String labelForCode(AppLocalizations l10n, String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      case 'es':
        return 'Español';
      default:
        return code;
    }
  }
}
