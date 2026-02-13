import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class LocaleService {
  static const _key = 'app_locale';

  static const supportedCodes = ['system', 'tr', 'en', 'ru', 'uk', 'es'];

  static Future<String> getSavedLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'system';
  }

  static Future<void> setSavedLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  static Locale? toLocale(String code) {
    if (code == 'system') return null;
    return Locale(code);
  }

  static String labelForCode(AppLocalizations l10n, String code) {
    switch (code) {
      case 'system':
        return l10n.systemDefault;
      case 'tr':
        return l10n.turkish;
      case 'en':
        return l10n.english;
      case 'ru':
        return l10n.russian;
      case 'uk':
        return l10n.ukrainian;
      case 'es':
        return l10n.spanish;
      default:
        return code;
    }
  }
}
