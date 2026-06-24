import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_tip.dart';

class DailyTipHistoryService {
  DailyTipHistoryService._();

  static final DailyTipHistoryService instance = DailyTipHistoryService._();

  static const String _seenTipIdsKey = 'daily_tip_seen_ids';
  static const String _lastSeenDateKey = 'daily_tip_last_seen_date';
  static const String _lastSeenTipIdKey = 'daily_tip_last_seen_tip_id';
  static const int _maxSeenTips = 30;

  Future<void> recordSeenTip(DailyTip tip) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final lastSeenDate = prefs.getString(_lastSeenDateKey);
    final lastSeenTipId = prefs.getString(_lastSeenTipIdKey);
    if (lastSeenDate == todayKey && lastSeenTipId == tip.id) {
      return;
    }

    final seenIds = prefs.getStringList(_seenTipIdsKey) ?? const <String>[];
    final nextIds = <String>[
      tip.id,
      ...seenIds.where((id) => id != tip.id),
    ].take(_maxSeenTips).toList(growable: false);

    await prefs.setStringList(_seenTipIdsKey, nextIds);
    await prefs.setString(_lastSeenDateKey, todayKey);
    await prefs.setString(_lastSeenTipIdKey, tip.id);
  }

  Future<List<DailyTip>> loadSeenTips({
    required int? fallbackBabyAgeInMonths,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList(_seenTipIdsKey) ?? const <String>[];
    final tipById = <String, DailyTip>{
      for (final tip in DailyTip.tips) tip.id: tip,
    };
    final seenTips = seenIds
        .map((id) => tipById[id])
        .whereType<DailyTip>()
        .toList(growable: false);

    if (seenTips.isNotEmpty) {
      return seenTips;
    }

    return <DailyTip>[DailyTip.todayForBaby(fallbackBabyAgeInMonths)];
  }

  String _dateKey(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
