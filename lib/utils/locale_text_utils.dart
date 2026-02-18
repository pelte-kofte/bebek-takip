import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

String formatLocalizedAge(BuildContext context, DateTime birthDate) {
  final l10n = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);

  if (birth.isAfter(today)) {
    return l10n.ageDays(0);
  }

  int years = today.year - birth.year;
  int months = today.month - birth.month;
  int days = today.day - birth.day;

  if (days < 0) {
    months -= 1;
    final previousMonth = DateTime(today.year, today.month, 0);
    days += previousMonth.day;
  }

  if (months < 0) {
    years -= 1;
    months += 12;
  }

  final totalMonths = years * 12 + months;

  if (years >= 2) {
    if (months > 0) {
      return l10n.ageYearsMonths(years, months);
    }
    return l10n.ageYears(years);
  }

  if (totalMonths > 0) {
    if (days > 0) {
      return l10n.ageMonthsDays(totalMonths, days);
    }
    return l10n.ageMonths(totalMonths);
  }

  final totalDays = today.difference(birth).inDays;
  return l10n.ageDays(totalDays);
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
