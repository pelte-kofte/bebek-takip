import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../main.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import '../services/reminder_service.dart';
import '../l10n/app_localizations.dart';
import 'rapor_screen.dart';
import 'login_entry_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _privacyPolicyUrl = 'https://example.com/privacy-policy';
  static const String _termsOfUseUrl = 'https://example.com/terms-of-use';

  final ReminderService _reminderService = ReminderService();

  bool _feedingReminderEnabled = false;
  bool _diaperReminderEnabled = false;
  TimeOfDay _feedingReminderTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _diaperReminderTime = const TimeOfDay(hour: 14, minute: 0);
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
    _loadAppInfo();
  }

  void _loadReminderSettings() {
    setState(() {
      _feedingReminderEnabled = VeriYonetici.isFeedingReminderEnabled();
      _diaperReminderEnabled = VeriYonetici.isDiaperReminderEnabled();
      _feedingReminderTime = TimeOfDay(
        hour: VeriYonetici.getFeedingReminderHour(),
        minute: VeriYonetici.getFeedingReminderMinute(),
      );
      _diaperReminderTime = TimeOfDay(
        hour: VeriYonetici.getDiaperReminderHour(),
        minute: VeriYonetici.getDiaperReminderMinute(),
      );
    });
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  DateTime _nextReminderDateTime(TimeOfDay time) {
    final now = DateTime.now();
    final scheduled = DateTime(now.year, now.month, now.day, time.hour, time.minute);
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

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link açılamadı'),
          backgroundColor: Color(0xFFFFB4A2),
        ),
      );
    }
  }

  Future<void> _sendFeedbackEmail() async {
    final subject = 'Nilico Feedback (iOS build $_appVersion+$_buildNumber)';
    final body = StringBuffer()
      ..writeln('Device model: Unknown')
      ..writeln('iOS version: ${Platform.operatingSystemVersion}')
      ..writeln('App version/build: $_appVersion+$_buildNumber')
      ..writeln()
      ..writeln('Feedback:');

    final emailUri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': subject,
        'body': body.toString(),
      },
    );

    final launched = await launchUrl(emailUri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta uygulaması açılamadı'),
          backgroundColor: Color(0xFFFFB4A2),
        ),
      );
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
                      Dil.iptal,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : const Color(0xFF866F65),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onSelected(tempTime);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Tamam',
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
    final bgColor = isDark ? AppColors.bgDark : const Color(0xFFFFFBF5);
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18);
    final subtitleColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF7A749E);

    return DecorativeBackground(
      preset: BackgroundPreset.settings,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                        Dil.ayarlar,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Uygulama tercihleri',
                        style: TextStyle(
                          fontSize: 14,
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HESAP Section
                    _buildAccountSection(cardColor, textColor, subtitleColor),
                    const SizedBox(height: 24),

                    // GÃ–RÃœNÃœM Section
                    _buildSectionHeader(Dil.gorunum, subtitleColor),
                    const SizedBox(height: 12),
                    _buildCard(
                      cardColor: cardColor,
                      child: _buildSwitchTile(
                        icon: isDark ? Icons.dark_mode : Icons.light_mode,
                        iconBgColor: const Color(0xFFE5E0F7),
                        iconColor: subtitleColor,
                        title: Dil.karanlikMod,
                        subtitle: Dil.karanlikModAciklama,
                        value: BabyTrackerApp.of(context)?.isDarkMode ?? false,
                        onChanged: (value) {
                          BabyTrackerApp.of(context)?.toggleTheme();
                        },
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BÄ°LDÄ°RÄ°MLER Section
                    _buildSectionHeader(Dil.bildirimler, subtitleColor),
                    const SizedBox(height: 12),
                    _buildCard(
                      cardColor: cardColor,
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.restaurant,
                            iconBgColor: const Color(0xFFFFE5E0),
                            iconColor: const Color(0xFFFFB4A2),
                            title: Dil.mamaHatirlatici,
                            subtitle: _feedingReminderEnabled
                                ? 'Saat ${_formatTime(_feedingReminderTime)}'
                                : 'Kapalı',
                            value: _feedingReminderEnabled,
                            onChanged: _toggleFeedingReminder,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          ),
                          if (_feedingReminderEnabled) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showTimePicker(
                                title: 'Hatırlatma Saati',
                                currentValue: _feedingReminderTime,
                                onSelected: (value) async {
                                  setState(() => _feedingReminderTime = value);
                                  await VeriYonetici.setFeedingReminderTime(
                                    value.hour,
                                    value.minute,
                                  );
                                  if (_feedingReminderEnabled) {
                                    await _reminderService.initialize();
                                    final scheduledAt = _nextReminderDateTime(value);
                                    await _reminderService.scheduleFeedingReminderAt(scheduledAt);
                                  }
                                },
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(left: 60),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule, size: 16, color: const Color(0xFFFFB4A2)),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(_feedingReminderTime),
                                      style: const TextStyle(
                                        color: Color(0xFFFFB4A2),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.expand_more, size: 16, color: const Color(0xFFFFB4A2)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          Divider(
                            color: subtitleColor.withValues(alpha: 0.1),
                            height: 24,
                          ),
                          _buildSwitchTile(
                            icon: Icons.baby_changing_station,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: Dil.bezHatirlatici,
                            subtitle: _diaperReminderEnabled
                                ? 'Saat ${_formatTime(_diaperReminderTime)}'
                                : 'Kapalı',
                            value: _diaperReminderEnabled,
                            onChanged: _toggleDiaperReminder,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          ),
                          if (_diaperReminderEnabled) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showTimePicker(
                                title: 'Hatırlatma Saati',
                                currentValue: _diaperReminderTime,
                                onSelected: (value) async {
                                  setState(() => _diaperReminderTime = value);
                                  await VeriYonetici.setDiaperReminderTime(
                                    value.hour,
                                    value.minute,
                                  );
                                  if (_diaperReminderEnabled) {
                                    await _reminderService.initialize();
                                    final scheduledAt = _nextReminderDateTime(value);
                                    await _reminderService.scheduleDiaperReminderAt(scheduledAt);
                                  }
                                },
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(left: 60),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule, size: 16, color: subtitleColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(_diaperReminderTime),
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.expand_more, size: 16, color: subtitleColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // VERÄ° YÃ–NETÄ°MÄ° Section
                    _buildSectionHeader(Dil.veriYonetimi, subtitleColor),
                    const SizedBox(height: 12),
                    _buildCard(
                      cardColor: cardColor,
                      child: Column(
                        children: [
                          _buildActionTile(
                            icon: Icons.analytics_outlined,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: 'Rapor Oluştur',
                            subtitle: 'Haftalık/Aylık istatistikler',
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
                            icon: Icons.download_outlined,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: Dil.verileriDisaAktar,
                            subtitle: 'JSON formatında indir',
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(Dil.yapilandiriliyor),
                                  backgroundColor: const Color(0xFFFFB4A2),
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
                            title: Dil.tumVerileriSil,
                            subtitle: 'Tüm kayıtları kalıcı olarak sil',
                            textColor: Colors.red.shade400,
                            subtitleColor: subtitleColor,
                            onTap: () => _showDeleteDialog(isDark, textColor, subtitleColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // HAKKINDA Section
                    _buildSectionHeader(Dil.hakkinda, subtitleColor),
                    const SizedBox(height: 12),
                    _buildCard(
                      cardColor: cardColor,
                      child: Column(
                        children: [
                          _buildInfoTile(
                            Dil.versiyon,
                            '$_appVersion+$_buildNumber',
                            textColor,
                            subtitleColor,
                          ),
                          Divider(
                            color: subtitleColor.withValues(alpha: 0.1),
                            height: 24,
                          ),
                          _buildInfoTile(
                            Dil.gelistirici,
                            'Nilico',
                            textColor,
                            subtitleColor,
                          ),
                          Divider(
                            color: subtitleColor.withValues(alpha: 0.1),
                            height: 24,
                          ),
                          _buildActionTile(
                            icon: Icons.feedback_outlined,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: 'Send Feedback',
                            subtitle: 'Mail ile geri bildirim gönder',
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: _sendFeedbackEmail,
                          ),
                          Divider(
                            color: subtitleColor.withValues(alpha: 0.1),
                            height: 24,
                          ),
                          _buildActionTile(
                            icon: Icons.privacy_tip_outlined,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: 'Privacy Policy',
                            subtitle: 'Gizlilik politikasını görüntüle',
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: () => _openExternalUrl(_privacyPolicyUrl),
                          ),
                          Divider(
                            color: subtitleColor.withValues(alpha: 0.1),
                            height: 24,
                          ),
                          _buildActionTile(
                            icon: Icons.description_outlined,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: 'Terms of Use',
                            subtitle: 'Kullanım koşullarını görüntüle',
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                            onTap: () => _openExternalUrl(_termsOfUseUrl),
                          ),
                        ],
                      ),
                    ),
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
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: subtitleColor,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAccountSection(Color cardColor, Color textColor, Color subtitleColor) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

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
                      color: isLoggedIn
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFE5E0F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isLoggedIn ? Icons.person : Icons.person_outline,
                      color: isLoggedIn
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
                          isLoggedIn
                              ? l10n.signedInAs(user.email ?? user.displayName ?? 'User')
                              : l10n.guestMode,
                          style: TextStyle(
                            fontSize: 13,
                            color: subtitleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoggedIn
                              ? (user.email ?? user.displayName ?? 'User')
                              : l10n.signInToProtectData,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isLoggedIn) ...[
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
                  if (isLoggedIn) {
                    await _signOut();
                  } else {
                    _navigateToLogin();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isLoggedIn
                        ? const Color(0xFFFFE5E0)
                        : const Color(0xFFFFB4A2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLoggedIn ? Icons.logout : Icons.login,
                        color: isLoggedIn
                            ? Colors.red.shade400
                            : Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLoggedIn ? l10n.signOut : l10n.signIn,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isLoggedIn
                              ? Colors.red.shade400
                              : Colors.white,
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
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Color(0xFFFFB4A2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  Widget _buildCard({
    required Color cardColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
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
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFFFB4A2),
          activeTrackColor: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
        ),
      ],
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: subtitleColor,
            size: 24,
          ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: subtitleColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
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
              Dil.dikkat,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        content: Text(
          Dil.silmeUyarisi,
          style: TextStyle(
            fontSize: 15,
            color: subtitleColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Dil.iptal,
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
                const SnackBar(
                  content: Text('Tüm veriler silindi!'),
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
                Dil.sil,
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
