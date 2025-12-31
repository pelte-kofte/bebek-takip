import 'package:flutter/material.dart';
import '../main.dart';
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import 'rapor_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _isimController = TextEditingController(
    text: 'Bebeğim',
  );
  DateTime _dogumTarihi = DateTime(2024, 6, 15);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF121212)]
                : [const Color(0xFFFCE4EC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚙️ ${Dil.ayarlar}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),

                // GÖRÜNÜM
                _buildSection(
                  title: '🎨 ${Dil.gorunum}',
                  cardColor: cardColor,
                  children: [
                    _buildSwitchTile(
                      title: Dil.karanlikMod,
                      subtitle: Dil.karanlikModAciklama,
                      value: BabyTrackerApp.of(context)?.isDarkMode ?? false,
                      onChanged: (value) {
                        BabyTrackerApp.of(context)?.toggleTheme();
                      },
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      iconColor: isDark ? Colors.amber : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // BEBEK BİLGİLERİ
                _buildSection(
                  title: '👶 ${Dil.bebekBilgileri}',
                  cardColor: cardColor,
                  children: [
                    _buildTextField(
                      controller: _isimController,
                      label: Dil.bebekAdi,
                      icon: Icons.person,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      label: Dil.dogumTarihi,
                      value: _dogumTarihi,
                      isDark: isDark,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dogumTarihi,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _dogumTarihi = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // BİLDİRİMLER
                _buildSection(
                  title: '🔔 ${Dil.bildirimler}',
                  cardColor: cardColor,
                  children: [
                    _buildSwitchTile(
                      title: Dil.mamaHatirlatici,
                      subtitle: 'Her 3 saatte bir hatırlat',
                      value: true,
                      onChanged: (value) {},
                      icon: Icons.restaurant,
                      iconColor: const Color(0xFFE91E63),
                    ),
                    _buildSwitchTile(
                      title: Dil.bezHatirlatici,
                      subtitle: 'Her 2 saatte bir kontrol et',
                      value: false,
                      onChanged: (value) {},
                      icon: Icons.baby_changing_station,
                      iconColor: const Color(0xFF9C27B0),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // VERİ YÖNETİMİ
                _buildSection(
                  title: '💾 ${Dil.veriYonetimi}',
                  cardColor: cardColor,
                  children: [
                    _buildActionTile(
                      icon: Icons.analytics,
                      title: 'Rapor Oluştur',
                      subtitle: 'Haftalık/Aylık istatistikler',
                      color: const Color(0xFFFF8AC1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RaporScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.download,
                      title: Dil.verileriDisaAktar,
                      subtitle: 'JSON formatında indir',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Yakında eklenecek!')),
                        );
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.delete_forever,
                      title: Dil.tumVerileriSil,
                      subtitle: Dil.silmeUyarisi,
                      color: Colors.red,
                      onTap: () => _showDeleteDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // HAKKINDA
                _buildSection(
                  title: 'ℹ️ ${Dil.hakkinda}',
                  cardColor: cardColor,
                  children: [
                    _buildInfoTile(Dil.versiyon, '1.0.0', isDark),
                    _buildInfoTile(Dil.gelistirici, 'Bebek Takip', isDark),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color cardColor,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFE91E63)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
                Text(
                  '${value.day} ${Dil.aylar[value.month - 1]} ${value.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Text(
              Dil.dikkat,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
        content: Text(
          Dil.silmeUyarisi,
          style: TextStyle(
            color: isDark ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Dil.iptal),
          ),
          ElevatedButton(
            onPressed: () {
              VeriYonetici.verileriTemizle();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm veriler silindi!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(Dil.sil, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
