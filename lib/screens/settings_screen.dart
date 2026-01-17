import 'package:flutter/material.dart';
import '../main.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../theme/app_theme.dart';
import 'rapor_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : const Color(0xFFFFFBF5);
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18);
    final subtitleColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF7A749E);

    return Scaffold(
      backgroundColor: bgColor,
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
                            subtitle: 'Her 3 saatte bir hatırlat',
                            value: true,
                            onChanged: (value) {},
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          ),
                          Divider(
                            color: subtitleColor.withValues(alpha: 0.1),
                            height: 24,
                          ),
                          _buildSwitchTile(
                            icon: Icons.baby_changing_station,
                            iconBgColor: const Color(0xFFE5E0F7),
                            iconColor: subtitleColor,
                            title: Dil.bezHatirlatici,
                            subtitle: 'Her 2 saatte bir kontrol et',
                            value: false,
                            onChanged: (value) {},
                            textColor: textColor,
                            subtitleColor: subtitleColor,
                          ),
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
                            'Bebek Takip',
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
