import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final ReminderService _reminderService = ReminderService();

  bool _feedingReminderEnabled = false;
  int _feedingReminderInterval = 180;
  bool _diaperReminderEnabled = false;
  int _diaperReminderInterval = 120;

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  void _loadReminderSettings() {
    setState(() {
      _feedingReminderEnabled = VeriYonetici.isFeedingReminderEnabled();
      _feedingReminderInterval = VeriYonetici.getFeedingReminderInterval();
      _diaperReminderEnabled = VeriYonetici.isDiaperReminderEnabled();
      _diaperReminderInterval = VeriYonetici.getDiaperReminderInterval();
    });
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes dk';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours saat';
    return '$hours saat $mins dk';
  }

  Future<void> _toggleFeedingReminder(bool value) async {
    setState(() => _feedingReminderEnabled = value);
    await VeriYonetici.setFeedingReminderEnabled(value);
    if (!value) {
      await _reminderService.cancelFeedingReminder();
    }
  }

  Future<void> _toggleDiaperReminder(bool value) async {
    setState(() => _diaperReminderEnabled = value);
    await VeriYonetici.setDiaperReminderEnabled(value);
    if (!value) {
      await _reminderService.cancelDiaperReminder();
    }
  }

  void _showIntervalPicker({
    required String title,
    required int currentValue,
    required Function(int) onSelected,
  }) {
    final intervals = [60, 90, 120, 150, 180, 210, 240];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18),
                  ),
                ),
              ),
              ...intervals.map((interval) => ListTile(
                title: Text(
                  _formatInterval(interval),
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18),
                    fontWeight: interval == currentValue ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: interval == currentValue
                    ? const Icon(Icons.check, color: Color(0xFFFFB4A2))
                    : null,
                onTap: () {
                  onSelected(interval);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
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

                    // GÖRÜNÜM Section
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

                    // BİLDİRİMLER Section
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
                                ? 'Her ${_formatInterval(_feedingReminderInterval)}'
                                : 'Kapalı',
                            value: _feedingReminderEnabled,
                            onChanged: _toggleFeedingReminder,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          ),
                          if (_feedingReminderEnabled) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showIntervalPicker(
                                title: 'Beslenme Hatırlatıcı Aralığı',
                                currentValue: _feedingReminderInterval,
                                onSelected: (value) async {
                                  setState(() => _feedingReminderInterval = value);
                                  await VeriYonetici.setFeedingReminderInterval(value);
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
                                      _formatInterval(_feedingReminderInterval),
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
                                ? 'Her ${_formatInterval(_diaperReminderInterval)}'
                                : 'Kapalı',
                            value: _diaperReminderEnabled,
                            onChanged: _toggleDiaperReminder,
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          ),
                          if (_diaperReminderEnabled) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showIntervalPicker(
                                title: 'Bez Hatırlatıcı Aralığı',
                                currentValue: _diaperReminderInterval,
                                onSelected: (value) async {
                                  setState(() => _diaperReminderInterval = value);
                                  await VeriYonetici.setDiaperReminderInterval(value);
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
                                      _formatInterval(_diaperReminderInterval),
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

                    // VERİ YÖNETİMİ Section
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
                            '1.0.0',
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
                              : l10n.continueWithoutLogin,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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
