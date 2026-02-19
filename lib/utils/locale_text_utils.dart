import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class AgeParts {
  final int years;
  final int months;
  final int days;
  final int totalMonths;
  final int totalDays;

  const AgeParts({
    required this.years,
    required this.months,
    required this.days,
    required this.totalMonths,
    required this.totalDays,
  });
}

DateTime dateOnly(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}

AgeParts calcAge(DateTime birthDate, {DateTime? referenceDate}) {
  final reference = dateOnly(referenceDate ?? DateTime.now());
  final birth = dateOnly(birthDate);

  if (birth.isAfter(reference)) {
    return const AgeParts(
      years: 0,
      months: 0,
      days: 0,
      totalMonths: 0,
      totalDays: 0,
    );
  }

  int years = reference.year - birth.year;
  int months = reference.month - birth.month;
  int days = reference.day - birth.day;

  if (days < 0) {
    months -= 1;
    final previousMonth = DateTime(reference.year, reference.month, 0);
    days += previousMonth.day;
  }

  if (months < 0) {
    years -= 1;
    months += 12;
  }

  final totalMonths = years * 12 + months;
  final totalDays = reference.difference(birth).inDays;

  return AgeParts(
    years: years,
    months: months,
    days: days,
    totalMonths: totalMonths,
    totalDays: totalDays,
  );
}

String ageString(
  BuildContext context,
  DateTime birthDate, {
  DateTime? referenceDate,
}) {
  final l10n = AppLocalizations.of(context)!;
  final age = calcAge(birthDate, referenceDate: referenceDate);

  if (age.years >= 2) {
    if (age.months > 0) {
      return l10n.ageYearsMonths(age.years, age.months);
    }
    return l10n.ageYears(age.years);
  }

  if (age.totalMonths > 0) {
    if (age.days > 0) {
      return l10n.ageMonthsDays(age.totalMonths, age.days);
    }
    return l10n.ageMonths(age.totalMonths);
  }

  return l10n.ageDays(age.totalDays);
}

String formatLocalizedAge(BuildContext context, DateTime birthDate) {
  return ageString(context, birthDate);
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
