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
import '../widgets/nilico_modal.dart';

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
    var tempTime = currentValue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NilicoPickerSheet(
        title: title,
        cancelLabel: AppLocalizations.of(context)!.cancel,
        confirmLabel: AppLocalizations.of(context)!.ok,
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          onSelected(tempTime);
          Navigator.pop(context);
        },
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
            tempTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.bgDarkCard : AppColors.paper;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
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
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: subtitleColor.withValues(alpha: 0.05),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.018),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: textColor.withValues(alpha: 0.82),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.settings,
                          style: AppTypography.h2(
                            context,
                          ).copyWith(color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.appPreferences,
                          style: AppTypography.bodySmall(context).copyWith(
                            fontSize: 13,
                            color: subtitleColor,
                            letterSpacing: 0.1,
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
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PREMIUM Section
                      _buildSectionHeader('Premium', subtitleColor),
                      const SizedBox(height: 10),
                      _buildPremiumSection(cardColor, textColor, subtitleColor),
                      const SizedBox(height: 14),

                      // PENDING INVITATIONS Section (conditional)
                      _buildPendingInvitationsSection(
                        cardColor,
                        textColor,
                        subtitleColor,
                      ),
                      const SizedBox(height: 26),

                      // HESAP Section
                      _buildAccountSection(cardColor, textColor, subtitleColor),
                      const SizedBox(height: 26),

                      // GÖRÜNÜM Section
                      _buildSectionHeader(l10n.appearance, subtitleColor),
                      const SizedBox(height: 10),
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
                              color: subtitleColor.withValues(alpha: 0.075),
                              height: 20,
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
                      const SizedBox(height: 26),

                      // BİLDİRİMLER Section
                      _buildSectionHeader(l10n.notifications, subtitleColor),
                      const SizedBox(height: 10),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildSwitchTile(
                              icon: Icons.restaurant,
                              iconBgColor: const Color(0xFFE9E6E3),
                              iconColor: subtitleColor,
                              title: l10n.feedingReminder,
                              subtitle: '',
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
                                      bgColor: subtitleColor.withValues(
                                        alpha: 0.05,
                                      ),
                                      fgColor: subtitleColor.withValues(
                                        alpha: 0.82,
                                      ),
                                      borderColor: subtitleColor.withValues(
                                        alpha: 0.09,
                                      ),
                                    )
                                  : null,
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.075),
                              height: 18,
                            ),
                            _buildSwitchTile(
                              icon: Icons.lightbulb_outline_rounded,
                              iconBgColor: const Color(0xFFE9E6E3),
                              iconColor: subtitleColor,
                              title: l10n.dailyTip,
                              subtitle: '',
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
                                      bgColor: subtitleColor.withValues(
                                        alpha: 0.05,
                                      ),
                                      fgColor: subtitleColor.withValues(
                                        alpha: 0.82,
                                      ),
                                      borderColor: subtitleColor.withValues(
                                        alpha: 0.09,
                                      ),
                                    )
                                  : null,
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.075),
                              height: 18,
                            ),
                            _buildSwitchTile(
                              icon: Icons.baby_changing_station,
                              iconBgColor: const Color(0xFFE9E6E3),
                              iconColor: subtitleColor,
                              title: l10n.diaperReminder,
                              subtitle: '',
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
                                      bgColor: subtitleColor.withValues(
                                        alpha: 0.05,
                                      ),
                                      fgColor: subtitleColor.withValues(
                                        alpha: 0.82,
                                      ),
                                      borderColor: subtitleColor.withValues(
                                        alpha: 0.09,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      // VERİ YÖNETİMİ Section
                      _buildSectionHeader(l10n.dataManagement, subtitleColor),
                      const SizedBox(height: 10),
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
                              color: subtitleColor.withValues(alpha: 0.075),
                              height: 20,
                            ),
                            _buildActionTile(
                              icon: Icons.delete_outline,
                              iconBgColor: const Color(0xFFEDE5E3),
                              iconColor: const Color(0xFF9A665F),
                              title: l10n.deleteAllDataTitle,
                              subtitle: l10n.deleteAllDataSubtitle,
                              textColor: textColor,
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
                      const SizedBox(height: 26),

                      // HAKKINDA Section
                      _buildSectionHeader(l10n.about, subtitleColor),
                      const SizedBox(height: 10),
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
                              color: subtitleColor.withValues(alpha: 0.065),
                              height: 22,
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
                      const SizedBox(height: 26),

                      _buildSectionHeader(l10n.legalSection, subtitleColor),
                      const SizedBox(height: 10),
                      _buildCard(
                        cardColor: cardColor,
                        child: Column(
                          children: [
                            _buildLegalTile(
                              title: l10n.termsOfUse,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              onTap: () => _openInAppUrl(TERMS_URL),
                            ),
                            Divider(
                              color: subtitleColor.withValues(alpha: 0.055),
                              height: 12,
                            ),
                            _buildLegalTile(
                              title: l10n.privacyPolicy,
                              textColor: textColor,
                              subtitleColor: subtitleColor,
                              onTap: () => _openInAppUrl(PRIVACY_URL),
                            ),
                          ],
                        ),
                      ),
                      // DEBUG section (only in debug builds)
                      if (kDebugMode) ...[
                        const SizedBox(height: 26),
                        _buildSectionHeader(l10n.debug, subtitleColor),
                        const SizedBox(height: 10),
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
                                color: subtitleColor.withValues(alpha: 0.075),
                                height: 20,
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
    return Text(
      title.toUpperCase(),
      style: AppTypography.eyebrow(context).copyWith(
        color: subtitleColor.withValues(alpha: 0.86),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
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
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => PremiumScreen.show(context),
                child: _buildSettingsRow(
                  icon: Icons.auto_awesome_rounded,
                  iconBgColor: const Color(0xFFE9E5EB),
                  iconColor: const Color(0xFF817887),
                  title: 'Premium',
                  subtitle: isPremium ? l10n.premiumIsActive : '',
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  trailing: isPremium
                      ? NilicoBadge(
                          label: l10n.active,
                          variant: NilicoBadgeVariant.premium,
                        )
                      : null,
                ),
              ),
              _buildGroupDivider(subtitleColor),
              _buildBuyIllustrationsSection(textColor, subtitleColor),
              _buildGroupDivider(subtitleColor),
              _buildSharedParentingSection(textColor, subtitleColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSharedParentingSection(Color textColor, Color subtitleColor) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null || user.isAnonymous) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.signInToUseSharedParenting)),
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
      child: _buildSettingsRow(
        icon: Icons.people_outline_rounded,
        iconBgColor: const Color(0xFFE4E9EB),
        iconColor: const Color(0xFF718087),
        title: l10n.spTitle,
        subtitle: '',
        textColor: textColor,
        subtitleColor: subtitleColor,
        isSecondary: true,
      ),
    );
  }

  Widget _buildBuyIllustrationsSection(Color textColor, Color subtitleColor) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => IllustrationUpsellSheet.showPurchase(context),
      child: _buildSettingsRow(
        icon: Icons.image_outlined,
        iconBgColor: const Color(0xFFEDE8E4),
        iconColor: const Color(0xFF8A7B72),
        title: l10n.buyIllustrations,
        subtitle: '',
        textColor: textColor,
        subtitleColor: subtitleColor,
        isSecondary: true,
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
                child: _buildSettingsRow(
                  icon: Icons.mail_outline_rounded,
                  iconBgColor: const Color(0xFFEDE5E3),
                  iconColor: const Color(0xFF926F69),
                  title: l10n.pendingInvitationsTitle,
                  subtitle: l10n.pendingInvitationsSubtitle,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
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
      titleText = user.displayName ?? l10n.account;
      detailText = identity;
      actionIcon = Icons.logout;
      actionLabel = l10n.signOut;
      actionBgColor = subtitleColor.withValues(alpha: 0.07);
      actionTextColor = textColor.withValues(alpha: 0.78);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.account, subtitleColor),
        const SizedBox(height: 10),
        _buildCard(
          cardColor: cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User status row
              Row(
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: isSignedInProviderUser
                          ? const Color(0xFFE4E9E5).withValues(alpha: 0.65)
                          : const Color(0xFFE9E5EB).withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSignedInProviderUser
                          ? Icons.verified_user
                          : Icons.person_outline,
                      color: isSignedInProviderUser
                          ? const Color(0xFF6F7F73)
                          : subtitleColor,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleText,
                          style: AppTypography.compactTitle(
                            context,
                          ).copyWith(fontSize: 15, color: textColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detailText,
                          style: AppTypography.bodySmall(context).copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor.withValues(alpha: 0.82),
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isSignedInProviderUser) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.backupSyncComingSoon,
                            style: AppTypography.caption(context).copyWith(
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
              const SizedBox(height: 10),
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
                  width: isSignedInProviderUser ? null : double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSignedInProviderUser ? 10 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: actionBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: subtitleColor.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: isSignedInProviderUser
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    mainAxisAlignment: isSignedInProviderUser
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(actionIcon, color: actionTextColor, size: 15),
                      const SizedBox(width: 7),
                      Text(
                        actionLabel,
                        style: AppTypography.compactTitle(
                          context,
                        ).copyWith(fontSize: 14, color: actionTextColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.07)
              : AppColors.borderSoft.withValues(alpha: 0.52),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.055 : 0.016),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGroupDivider(Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 46),
      child: Divider(
        color: subtitleColor.withValues(alpha: 0.075),
        height: 18,
        thickness: 0.6,
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    Widget? trailing,
    bool isSecondary = false,
  }) {
    return Row(
      children: [
        if (isSecondary) const SizedBox(width: 4),
        Container(
          width: isSecondary ? 24 : 29,
          height: isSecondary ? 24 : 29,
          decoration: BoxDecoration(
            color: iconBgColor.withValues(alpha: isSecondary ? 0.26 : 0.36),
            borderRadius: BorderRadius.circular(isSecondary ? 7 : 8),
          ),
          child: Icon(
            icon,
            color: iconColor.withValues(alpha: isSecondary ? 0.56 : 0.66),
            size: isSecondary ? 13 : 15,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.compactTitle(context).copyWith(
                  fontSize: isSecondary ? 14 : 15,
                  color: isSecondary
                      ? textColor.withValues(alpha: 0.76)
                      : textColor,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(fontSize: 12.5, color: subtitleColor, height: 1.3),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
        if (trailing == null) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: subtitleColor.withValues(alpha: isSecondary ? 0.38 : 0.48),
            size: 19,
          ),
        ],
      ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: iconBgColor.withValues(alpha: 0.32),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor.withValues(alpha: 0.62), size: 15),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.compactTitle(
                  context,
                ).copyWith(fontSize: 15, color: textColor),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(fontSize: 12.5, color: subtitleColor, height: 1.3),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 7), trailing],
        const SizedBox(width: 6),
        Transform.scale(
          scale: 0.76,
          alignment: Alignment.centerRight,
          child: CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFFB78F87),
            inactiveTrackColor: subtitleColor.withValues(alpha: 0.16),
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
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.expand_more_rounded, size: 14, color: fgColor),
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
      child: _buildSettingsRow(
        icon: icon,
        iconBgColor: iconBgColor,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
        textColor: textColor,
        subtitleColor: subtitleColor,
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    Color textColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall(
              context,
            ).copyWith(fontSize: 14, color: subtitleColor),
          ),
          Text(
            value,
            style: AppTypography.compactTitle(
              context,
            ).copyWith(fontSize: 14, color: textColor.withValues(alpha: 0.88)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile({
    required String title,
    required Color textColor,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: AppTypography.compactTitle(
          context,
        ).copyWith(fontSize: 14, color: textColor.withValues(alpha: 0.72)),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: subtitleColor.withValues(alpha: 0.34),
        size: 18,
      ),
      onTap: onTap,
      visualDensity: const VisualDensity(vertical: -4),
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
    const selectableCodes = <String>['tr', 'en'];
    if (kDebugMode) {
      const sampleTr = 'Türkçe';
      const sampleEs = 'Español';
      debugPrint('[Locale] sample="$sampleTr" codeUnits=${sampleTr.codeUnits}');
      debugPrint('[Locale] sample="$sampleEs" codeUnits=${sampleEs.codeUnits}');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NilicoSheetFrame(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.language, style: AppTypography.sheetTitle(ctx)),
            ),
            const SizedBox(height: 12),
            ...selectableCodes.map((code) {
              final isSelected = code == currentCode;
              return ListTile(
                minTileHeight: 48,
                contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                title: Text(
                  LocaleService.labelForCode(l10n, code),
                  style: AppTypography.body(ctx).copyWith(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.primaryDark,
                        size: 21,
                      )
                    : const SizedBox(width: 21),
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
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(bool isDark, Color textColor, Color subtitleColor) {
    showDialog(
      context: context,
      builder: (context) => NilicoDialog(
        title: Text(AppLocalizations.of(context)!.attention),
        content: Text(AppLocalizations.of(context)!.deleteAllDataWarning),
        actions: [
          NilicoDialogAction(
            onPressed: () => Navigator.pop(context),
            label: AppLocalizations.of(context)!.cancel,
          ),
          NilicoDialogAction(
            onPressed: () async {
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
            label: AppLocalizations.of(context)!.delete,
            destructive: true,
          ),
        ],
      ),
    );
  }
}
