import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';

class HealthOverviewCard extends StatelessWidget {
  const HealthOverviewCard({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _sleepSummary(
    AppLocalizations l10n,
    List<Map<String, dynamic>> sleeps,
  ) {
    final totalMinutes = sleeps.fold<int>(
      0,
      (sum, item) => sum + ((item['sure'] as Duration?)?.inMinutes ?? 0),
    );
    if (totalMinutes == 0) return '0${l10n.minAbbrev}';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '$minutes${l10n.minAbbrev}';
    if (minutes == 0) return '$hours${l10n.hourAbbrev}';
    return '$hours${l10n.hourAbbrev} $minutes${l10n.minAbbrev}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final todayFeedings = VeriYonetici.getMamaKayitlari()
        .where((item) => _isSameDay(item['tarih'] as DateTime, today))
        .length;
    final todayDiapers = VeriYonetici.getKakaKayitlari()
        .where((item) => _isSameDay(item['tarih'] as DateTime, today))
        .length;
    final todaySleeps = VeriYonetici.getUykuKayitlari()
        .where((item) => _isSameDay(item['bitis'] as DateTime, today))
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E0F7).withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.healthOverviewTitle,
                style: AppTypography.h3(context).copyWith(fontSize: 16),
              ),
              const Spacer(),
              Text(
                l10n.todayBadge,
                style: AppTypography.caption(
                  context,
                ).copyWith(fontSize: 10, letterSpacing: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.healthOverviewSubtitle,
            style: AppTypography.bodySmall(context).copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HealthMetricTile(
                  label: l10n.feeding,
                  value: '$todayFeedings',
                  detail: l10n.todayBadge,
                  icon: Icons.local_drink_outlined,
                  accent: const Color(0xFFFFC6D3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HealthMetricTile(
                  label: l10n.sleep,
                  value: _sleepSummary(l10n, todaySleeps),
                  detail: l10n.todayBadge,
                  icon: Icons.bedtime_outlined,
                  accent: const Color(0xFFBBD0FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HealthMetricTile(
                  label: l10n.diaper,
                  value: '$todayDiapers',
                  detail: l10n.todayBadge,
                  icon: Icons.baby_changing_station_outlined,
                  accent: const Color(0xFFD6C6FA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthMetricTile extends StatelessWidget {
  const _HealthMetricTile({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 15, color: const Color(0xFF5A4A45)),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTypography.h3(context).copyWith(fontSize: 17)),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.label(context).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: AppTypography.caption(context).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
