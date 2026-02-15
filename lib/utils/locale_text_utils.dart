import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

String formatLocalizedAge(BuildContext context, DateTime birthDate) {
  final l10n = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final difference = now.difference(birthDate);
  final totalMonths = (difference.inDays / 30.44).floor();
  final days = difference.inDays % 30;

  if (totalMonths >= 12) {
    final years = totalMonths ~/ 12;
    final remainingMonths = totalMonths % 12;
    if (remainingMonths > 0) {
      return '${l10n.ageYears(years)} ${l10n.ageMonths(remainingMonths)}';
    }
    return l10n.ageYears(years);
  }

  if (totalMonths > 0) {
    return l10n.ageMonths(totalMonths);
  }

  return l10n.ageDays(days);
}

String formatLocalizedDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMediumDate(date);
}

int? parseVaccineMonth(String period) {
  if (period == 'Doğumda') return 0;
  final monthMatch = RegExp(r'^(\d+)\.\s*Ay$').firstMatch(period);
  if (monthMatch != null) {
    return int.tryParse(monthMatch.group(1)!);
  }
  final yearMatch = RegExp(r'^(\d+)(-\d+)?\s*Yaş$').firstMatch(period);
  if (yearMatch != null) {
    final years = int.tryParse(yearMatch.group(1)!);
    if (years != null) return years * 12;
  }
  return null;
}

String localizedPeriodLabel(AppLocalizations l10n, String period) {
  final month = parseVaccineMonth(period);
  if (month == null) return period;
  if (month == 0) return l10n.birth;
  return l10n.monthNumber(month);
}
