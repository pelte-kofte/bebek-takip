import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../constants/legal_urls.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import '../services/reminder_service.dart';
import '../services/sleep_notification_service.dart';
import '../services/locale_service.dart';
import '../services/premium_service.dart';
import '../l10n/app_localizations.dart';
import 'rapor_screen.dart';
import 'login_entry_screen.dart';
import 'premium_screen.dart';
import '../services/shared_parenting_service.dart';
import 'invitation_inbox_screen.dart';
import 'shared_parenting_screen.dart';
import '../widgets/illustration_upsell_sheet.dart';
import '../widgets/nilico_badge.dart';
import '../widgets/nilico_section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ReminderService _reminderService = ReminderService();

  bool _feedingReminderEnabled = false;
  bool _diaperReminderEnabled = false;
  bool _dailyTipReminderEnabled = false;
  TimeOfDay _feedingReminderTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _diaperReminderTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _dailyTipReminderTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    assert(() {
      debugAssertLegalUrls();
      return true;
    }());
    _loadReminderSettings();
  }

  void _loadReminderSettings() {
    setState(() {
      _feedingReminderEnabled = VeriYonetici.isFeedingReminderEnabled();
      _diaperReminderEnabled = VeriYonetici.isDiaperReminderEnabled();
      _dailyTipReminderEnabled = VeriYonetici.isDailyTipReminderEnabled();
      _feedingReminderTime = TimeOfDay(
        hour: VeriYonetici.getFeedingReminderHour(),
        minute: VeriYonetici.getFeedingReminderMinute(),
      );
      _diaperReminderTime = TimeOfDay(
        hour: VeriYonetici.getDiaperReminderHour(),
        minute: VeriYonetici.getDiaperReminderMinute(),
      );
      _dailyTipReminderTime = TimeOfDay(
        hour: VeriYonetici.getDailyTipReminderHour(),
        minute: VeriYonetici.getDailyTipReminderMinute(),
      );
    });
  }

  int? _babyAgeInMonths() {
    final baby = VeriYonetici.getActiveBabyOrNull();
    if (baby == null) return null;
    final birthDate = baby.birthDate;
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months -= 1;
    }
    return months < 0 ? 0 : months;
  }

  DateTime _nextReminderDateTime(TimeOfDay time) {
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      return scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _openInAppUrl(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);
    final inAppLaunched = await launchUrl(
      uri,
      mode: kIsWeb
          ? LaunchMode.externalApplication
          : LaunchMode.inAppBrowserView,
    );
    if (inAppLaunched) return;

    final externalLaunched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!externalLaunched && mounted) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pageCouldNotOpen)));
    }
  }

  Future<void> _toggleFeedingReminder(bool value) async {
    setState(() => _feedingReminderEnabled = value);
    await VeriYonetici.setFeedingReminderEnabled(value);
    if (value) {
      await _reminderService.initialize();
      final scheduledAt = _nextReminderDateTime(_feedingReminderTime);
      await _reminderService.scheduleFeedingReminderAt(scheduledAt);
    } else {
      await _reminderService.cancelFeedingReminder();
    }
  }

  Future<void> _toggleDiaperReminder(bool value) async {
    setState(() => _diaperReminderEnabled = value);
    await VeriYonetici.setDiaperReminderEnabled(value);
    if (value) {
      await _reminderService.initialize();
      final scheduledAt = _nextReminderDateTime(_diaperReminderTime);
      await _reminderService.scheduleDiaperReminderAt(scheduledAt);
    } else {
      await _reminderService.cancelDiaperReminder();
    }
  }

  Future<void> _toggleDailyTipReminder(bool value) async {
    setState(() => _dailyTipReminderEnabled = value);
    await VeriYonetici.setDailyTipReminderEnabled(value);
    if (value) {
      await _reminderService.initialize();
      final scheduledAt = _nextReminderDateTime(_dailyTipReminderTime);
      await _reminderService.scheduleDailyTipReminderAt(
        scheduledAt: scheduledAt,
        babyAgeInMonths: _babyAgeInMonths(),
      );
    } else {
      await _reminderService.cancelDailyTipReminder();
    }
  }

  void _showTimePicker({
    required String title,
    required TimeOfDay currentValue,
    required Function(TimeOfDay) onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var tempTime = currentValue;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF866F65),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF2D1A18),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onSelected(tempTime);
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: TextStyle(
                        color: Color(0xFFFF998A),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(
                  0,
                  1,
                  1,
                  currentValue.hour,
                  currentValue.minute,
                ),
                onDateTimeChanged: (dateTime) {
                  tempTime = TimeOfDay(
                    hour: dateTime.hour,
                    minute: dateTime.minute,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : const Color(0xFF2D1A18);
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF7A749E);
    final l10n = AppLocalizations.of(context)!;

    return DecorativeBackground(
      preset: BackgroundPreset.settings,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: subtitleColor.withValues(alpha: 0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.035),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.appPreferences,
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PREMIUM Section
                      _buildPremiumSection(cardColor, textColor, subtitleColor),
                      const SizedBox(height: 12),
                      _buildBuyIllustrationsSection(
                        cardColor,
                        textColor,
                        subtitleColor,
                      ),
                      const SizedBox(height: 12),

                      // SHARED PARENTING Section
                      _buildSharedParentingSection(
                        cardColor,
                        textColor,
                        subtitleColor,
                      ),
                      const SizedBox(height: 12),

                      // PENDING INVITATIONS Section (conditional)
                      _buildPendingInvitationsSection(
                        cardColor,
                        textColor,
                        subtitleColor,
                      ),
                      const SizedBox(height: 20),

                      // HESAP Section
                      _buildAccountSection(cardColor, textColor, subtitleColor),
                      const SizedBox(height: 20),

                      // GÖRÜNÜM Section
                      _buildSectionHeader(l10n.appearance, subtitleColor),
                      const SizedBox(height: 12),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: isDark ? Icons.dark_mode : Icons.light_mode,
                              iconBgColor: const Color(0xFFE5E0F7),
                              iconColor: subtitleColor,
                              title: l10n.darkMode,
                              subtitle: l10n.darkModeSubtitle,
                              value:
                                  BabyTrackerApp.of(context)?.isDarkMode ??
                                  false,
                              onChanged: (value) {
                                BabyTrackerApp.of(context)?.toggleTheme();
                              },
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.1),
                              height: 24,
                            ),
                            _buildActionTile(
                              icon: Icons.language,
                              iconBgColor: const Color(0xFFE5E0F7),
                              iconColor: subtitleColor,
                              title: l10n.language,
                              subtitle: LocaleService.labelForCode(
                                l10n,
                                BabyTrackerApp.of(context)?.localeCode ?? 'en',
                              ),
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              onTap: () => _showLanguagePicker(
                                isDark,
                                cardColor,
                                textColor,
                                subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // BİLDİRİMLER Section
                      _buildSectionHeader(l10n.notifications, subtitleColor),
                      const SizedBox(height: 12),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.restaurant,
                              iconBgColor: const Color(0xFFFFE5E0),
                              iconColor: const Color(0xFFFFB4A2),
                              title: l10n.feedingReminder,
                              subtitle: _feedingReminderEnabled ? '' : l10n.off,
                              value: _feedingReminderEnabled,
                              onChanged: _toggleFeedingReminder,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              trailing: _feedingReminderEnabled
                                  ? _buildReminderTimePill(
                                      label: _formatTime(_feedingReminderTime),
                                      onTap: () => _showTimePicker(
                                        title: l10n.reminderTime,
                                        currentValue: _feedingReminderTime,
                                        onSelected: (value) async {
                                          setState(
                                            () => _feedingReminderTime = value,
                                          );
                                          await VeriYonetici.setFeedingReminderTime(
                                            value.hour,
                                            value.minute,
                                          );
                                          if (_feedingReminderEnabled) {
                                            await _reminderService.initialize();
                                            final scheduledAt =
                                                _nextReminderDateTime(value);
                                            await _reminderService
                                                .scheduleFeedingReminderAt(
                                                  scheduledAt,
                                                );
                                          }
                                        },
                                      ),
                                      bgColor: const Color(
                                        0xFFFFB4A2,
                                      ).withValues(alpha: 0.14),
                                      fgColor: const Color(0xFFE08F78),
                                      borderColor: const Color(
                                        0xFFFFB4A2,
                                      ).withValues(alpha: 0.18),
                                    )
                                  : null,
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.1),
                              height: 24,
                            ),
                            _buildSwitchTile(
                              icon: Icons.lightbulb_outline_rounded,
                              iconBgColor: const Color(0xFFFFF0D9),
                              iconColor: const Color(0xFFDAA520),
                              title: l10n.dailyTip,
                              subtitle: _dailyTipReminderEnabled
                                  ? ''
                                  : l10n.off,
                              value: _dailyTipReminderEnabled,
                              onChanged: _toggleDailyTipReminder,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              trailing: _dailyTipReminderEnabled
                                  ? _buildReminderTimePill(
                                      label: _formatTime(_dailyTipReminderTime),
                                      onTap: () => _showTimePicker(
                                        title: l10n.dailyTip,
                                        currentValue: _dailyTipReminderTime,
                                        onSelected: (value) async {
                                          setState(
                                            () => _dailyTipReminderTime = value,
                                          );
                                          await VeriYonetici.setDailyTipReminderTime(
                                            value.hour,
                                            value.minute,
                                          );
                                          if (_dailyTipReminderEnabled) {
                                            await _reminderService.initialize();
                                            final scheduledAt =
                                                _nextReminderDateTime(value);
                                            await _reminderService
                                                .scheduleDailyTipReminderAt(
                                                  scheduledAt: scheduledAt,
                                                  babyAgeInMonths:
                                                      _babyAgeInMonths(),
                                                );
                                          }
                                        },
                                      ),
                                      bgColor: const Color(
                                        0xFFFFF0D9,
                                      ).withValues(alpha: 0.95),
                                      fgColor: const Color(0xFFDAA520),
                                      borderColor: const Color(
                                        0xFFDAA520,
                                      ).withValues(alpha: 0.16),
                                    )
                                  : null,
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.1),
                              height: 24,
                            ),
                            _buildSwitchTile(
                              icon: Icons.baby_changing_station,
                              iconBgColor: const Color(0xFFE5E0F7),
                              iconColor: subtitleColor,
                              title: l10n.diaperReminder,
                              subtitle: _diaperReminderEnabled ? '' : l10n.off,
                              value: _diaperReminderEnabled,
                              onChanged: _toggleDiaperReminder,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              trailing: _diaperReminderEnabled
                                  ? _buildReminderTimePill(
                                      label: _formatTime(_diaperReminderTime),
                                      onTap: () => _showTimePicker(
                                        title: l10n.reminderTime,
                                        currentValue: _diaperReminderTime,
                                        onSelected: (value) async {
                                          setState(
                                            () => _diaperReminderTime = value,
                                          );
                                          await VeriYonetici.setDiaperReminderTime(
                                            value.hour,
                                            value.minute,
                                          );
                                          if (_diaperReminderEnabled) {
                                            await _reminderService.initialize();
                                            final scheduledAt =
                                                _nextReminderDateTime(value);
                                            await _reminderService
                                                .scheduleDiaperReminderAt(
                                                  scheduledAt,
                                                );
                                          }
                                        },
                                      ),
                                      bgColor: const Color(
                                        0xFFE5E0F7,
                                      ).withValues(alpha: 0.38),
                                      fgColor: subtitleColor,
                                      borderColor: subtitleColor.withValues(
                                        alpha: 0.12,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // VERİ YÖNETİMİ Section
                      _buildSectionHeader(l10n.dataManagement, subtitleColor),
                      const SizedBox(height: 12),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildActionTile(
                              icon: Icons.analytics_outlined,
                              iconBgColor: const Color(0xFFE5E0F7),
                              iconColor: subtitleColor,
                              title: l10n.createReport,
                              subtitle: l10n.weeklyMonthlyStats,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RaporScreen(),
                                  ),
                                );
                              },
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.1),
                              height: 24,
                            ),
                            _buildActionTile(
                              icon: Icons.delete_outline,
                              iconBgColor: const Color(0xFFFFE5E0),
                              iconColor: Colors.red.shade400,
                              title: l10n.deleteAllDataTitle,
                              subtitle: l10n.deleteAllDataSubtitle,
                              textColor: Colors.red.shade400,
                              subtitleColor: subtitleColor,
                              onTap: () => _showDeleteDialog(
                                isDark,
                                textColor,
                                subtitleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // HAKKINDA Section
                      _buildSectionHeader(l10n.about, subtitleColor),
                      const SizedBox(height: 12),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildInfoTile(
                              l10n.version,
                              '1.0.0',
                              textColor,
                              subtitleColor,
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.1),
                              height: 24,
                            ),
                            _buildInfoTile(
                              l10n.developer,
                              'Nilico',
                              textColor,
                              subtitleColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionHeader(l10n.legalSection, subtitleColor),
                      const SizedBox(height: 12),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildLegalTile(
                              icon: Icons.description_outlined,
                              title: l10n.termsOfUse,
                              subtitle: l10n.termsOfUseSubtitle,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              onTap: () => _openInAppUrl(TERMS_URL),
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.1),
                              height: 16,
                            ),
                            _buildLegalTile(
                              icon: Icons.privacy_tip_outlined,
                              title: l10n.privacyPolicy,
                              subtitle: l10n.privacyPolicySubtitle,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              onTap: () => _openInAppUrl(PRIVACY_URL),
                            ),
                          ],
                        ),
                      ),
                      // DEBUG section (only in debug builds)
                      if (kDebugMode) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader(l10n.debug, subtitleColor),
                        const SizedBox(height: 12),
                        _buildCard(
                          cardColor: cardColor,
                          child: Column(
                            children: [
                              _buildActionTile(
                                icon: Icons.notifications_active,
                                iconBgColor: const Color(0xFFFFE5E0),
                                iconColor: Colors.orange,
                                title: l10n.testSleepNotification,
                                subtitle: l10n.fireSleepNotificationNow,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final message = AppLocalizations.of(
                                    context,
                                  )!.notificationSleepFired;
                                  final svc = SleepNotificationService();
                                  await svc.initialize();
                                  await svc.requestPermissions();
                                  await svc.showSleepNotification(
                                    DateTime.now(),
                                  );
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: const Color(
                                          0xFFFFB4A2,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Divider(
                                color: subtitleColor.withValues(alpha: 0.1),
                                height: 24,
                              ),
                              _buildActionTile(
                                icon: Icons.notifications_active,
                                iconBgColor: const Color(0xFFE5E0F7),
                                iconColor: Colors.purple,
                                title: l10n.testNursingNotification,
                                subtitle: l10n.fireNursingNotificationNow,
                                textColor: textColor,
                                subtitleColor: subtitleColor,
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final message = AppLocalizations.of(
                                    context,
                                  )!.notificationNursingFired;
                                  final svc = SleepNotificationService();
                                  await svc.initialize();
                                  await svc.requestPermissions();
                                  await svc.showNursingNotification(
                                    DateTime.now(),
                                    l10n.left.toLowerCase(),
                                  );
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: const Color(
                                          0xFFE5E0F7,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color subtitleColor) {
    return NilicoSectionHeader(
      title: title,
      mode: NilicoSectionHeaderMode.eyebrow,
      titleColor: subtitleColor,
    );
  }

  Widget _buildPremiumSection(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<bool>(
      valueListenable: PremiumService.instance.isPremiumNotifier,
      builder: (context, isPremium, _) {
        return _buildCard(
          cardColor: cardColor,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => PremiumScreen.show(context),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E0F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF9C88CC),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPremium
                            ? l10n.premiumIsActive
                            : l10n.premiumFeatureTeaser,
                        style: TextStyle(
                          fontSize: 13,
                          color: isPremium
                              ? const Color(0xFF9C88CC)
                              : subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPremium)
                  NilicoBadge(
                    label: l10n.active,
                    variant: NilicoBadgeVariant.premium,
                  )
                else
                  Icon(Icons.chevron_right, color: subtitleColor, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSharedParentingSection(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      cardColor: cardColor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null || user.isAnonymous) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.signInToUseSharedParenting,
                ),
              ),
            );
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginEntryScreen()),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SharedParentingScreen()),
          );
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEFF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: Color(0xFF6AADCF),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.spTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (!PremiumService.instance.isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB4A2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PremiumService.instance.isPremium
                        ? l10n.spGateTitle
                        : l10n.availableWithPremium,
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subtitleColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyIllustrationsSection(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      cardColor: cardColor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => IllustrationUpsellSheet.showPurchase(context),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1EC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFFFFB4A2),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.buyIllustrations,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.buyIllustrationsSubtitle,
                    style: TextStyle(fontSize: 13, color: subtitleColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subtitleColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingInvitationsSection(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<InvitationItem>>(
      stream: SharedParentingService.instance.watchPendingInvitations(),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        if (count == 0) return const SizedBox.shrink();

        return Column(
          children: [
            _buildCard(
              cardColor: cardColor,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InvitationInboxScreen(),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.mail_rounded,
                            color: Color(0xFFFFB4A2),
                            size: 22,
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFB4A2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.pendingInvitationsTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.pendingInvitationsSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: subtitleColor, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildAccountSection(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        return _buildAccountSectionContent(
          cardColor: cardColor,
          textColor: textColor,
          subtitleColor: subtitleColor,
          user: user,
        );
      },
    );
  }

  Widget _buildAccountSectionContent({
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required User? user,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isAnonymous = user?.isAnonymous ?? false;
    final isSignedInProviderUser = user != null && !isAnonymous;
    final hasSession = user != null;

    String titleText;
    String detailText;
    IconData actionIcon;
    String actionLabel;
    Color actionBgColor;
    Color actionTextColor;

    if (!hasSession) {
      titleText = l10n.notSignedIn;
      detailText = l10n.signInToProtectData;
      actionIcon = Icons.login;
      actionLabel = l10n.signIn;
      actionBgColor = const Color(0xFFFFB4A2);
      actionTextColor = Colors.white;
    } else if (isAnonymous) {
      titleText = l10n.guestMode;
      detailText = l10n.signInToProtectData;
      actionIcon = Icons.login;
      actionLabel = l10n.signIn;
      actionBgColor = const Color(0xFFFFB4A2);
      actionTextColor = Colors.white;
    } else {
      final identity = user.email ?? user.displayName ?? l10n.user;
      titleText = l10n.signedInAs(identity);
      detailText = identity;
      actionIcon = Icons.logout;
      actionLabel = l10n.signOut;
      actionBgColor = const Color(0xFFFFE5E0);
      actionTextColor = Colors.red.shade400;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.account, subtitleColor),
        const SizedBox(height: 12),
        _buildCard(
          cardColor: cardColor,
          child: Column(
            children: [
              // User status row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSignedInProviderUser
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFE5E0F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSignedInProviderUser
                          ? Icons.verified_user
                          : Icons.person_outline,
                      color: isSignedInProviderUser
                          ? const Color(0xFF4CAF50)
                          : subtitleColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: TextStyle(fontSize: 13, color: subtitleColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detailText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isSignedInProviderUser) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.backupSyncComingSoon,
                            style: TextStyle(
                              fontSize: 11,
                              color: subtitleColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Sign In / Sign Out button
              GestureDetector(
                onTap: () async {
                  if (isSignedInProviderUser) {
                    await _signOut();
                  } else {
                    _navigateToLogin();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: actionBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(actionIcon, color: actionTextColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: actionTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (!kIsWeb) {
        try {
          await GoogleSignIn().disconnect();
        } catch (_) {}
        try {
          await GoogleSignIn().signOut();
        } catch (_) {}
      }
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      AppNavigator.goToRoot(const LoginEntryScreen());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.signedOutSuccessfully),
          backgroundColor: Color(0xFFFFB4A2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginEntryScreen()),
    ).then((_) {
      // Refresh the UI when returning from login screen
      setState(() {});
    });
  }

  Widget _buildCard({required Color cardColor, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppShadows.card(false),
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color subtitleColor,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: subtitleColor),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing],
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: iconBgColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: subtitleColor.withValues(alpha: 0.08)),
          ),
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFFB4A2),
            activeTrackColor: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimePill({
    required String label,
    required VoidCallback onTap,
    required Color bgColor,
    required Color fgColor,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_rounded, size: 15, color: fgColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 16, color: fgColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: subtitleColor),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: subtitleColor)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: subtitleColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: subtitleColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.5, color: subtitleColor),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: subtitleColor,
        size: 20,
      ),
      onTap: onTap,
      visualDensity: const VisualDensity(vertical: -3),
    );
  }

  void _showLanguagePicker(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = BabyTrackerApp.of(context)?.localeCode ?? 'en';
    if (kDebugMode) {
      const sampleTr = 'Türkçe';
      const sampleEs = 'Español';
      debugPrint('[Locale] sample="$sampleTr" codeUnits=${sampleTr.codeUnits}');
      debugPrint('[Locale] sample="$sampleEs" codeUnits=${sampleEs.codeUnits}');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.language,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            ...LocaleService.supportedCodes.map((code) {
              final isSelected = code == currentCode;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? const Color(0xFFFFB4A2) : subtitleColor,
                ),
                title: Text(
                  LocaleService.labelForCode(l10n, code),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await BabyTrackerApp.of(context)?.setLocale(code);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.languageUpdated,
                        ),
                        backgroundColor: const Color(0xFFFFB4A2),
                      ),
                    );
                  }
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(bool isDark, Color textColor, Color subtitleColor) {
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.attention,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)!.deleteAllDataWarning,
          style: TextStyle(fontSize: 15, color: subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await VeriYonetici.verileriTemizle();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.allDataDeleted),
                  backgroundColor: Color(0xFFFFB4A2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
