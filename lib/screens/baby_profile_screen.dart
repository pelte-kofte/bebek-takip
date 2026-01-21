import 'package:flutter/material.dart';
import '../models/dil.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  late TextEditingController _nameController;
  final TextEditingController _notesController = TextEditingController();
  late DateTime _birthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: VeriYonetici.getBabyName());
    _birthDate = VeriYonetici.getBirthDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _calculateAge() {
    final now = DateTime.now();
    final difference = now.difference(_birthDate);
    final months = (difference.inDays / 30).floor();
    final days = difference.inDays % 30;

    if (months >= 12) {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths > 0) {
        return '$years ${Dil.yil} $remainingMonths ${Dil.ay}';
      }
      return '$years ${Dil.yil}';
    } else if (months > 0) {
      return '$months ${Dil.ay} $days ${Dil.gun}';
    } else {
      return '$days ${Dil.gun}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : const Color(0xFFFFFBF5);
    final cardColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final textColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18);
    final subtitleColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF7A749E);

    return DecorativeBackground(
      preset: BackgroundPreset.profile,
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
                        Dil.bebekProfili,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Dil.bebekBilgileri,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Baby Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEBE8FF),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB4A2).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/illustration/baby_face.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFEBE8FF),
                            child: const Icon(
                              Icons.child_care,
                              color: Color(0xFFFF998A),
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Age display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E0F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _calculateAge(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Baby Name Card
                    _buildCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Dil.bebekAdi.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: Dil.bebekAdi,
                              hintStyle: TextStyle(
                                color: subtitleColor.withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E0F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: subtitleColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 52,
                                minHeight: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Birth Date Card
                    _buildCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Dil.dogumTarihi.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _birthDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _birthDate = picked);
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E0F7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: subtitleColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_birthDate.day} ${Dil.aylar[_birthDate.month - 1]} ${_birthDate.year}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  color: subtitleColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes Card
                    _buildCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Dil.notlar} (${Dil.istegeBagli})'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Alerjiler, tercihler, notlar...',
                              hintStyle: TextStyle(
                                color: subtitleColor.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // View Growth Records Button
                    GestureDetector(
                      onTap: () {
                        // Navigate to growth records (view-only)
                        // This will be handled in the future
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(Dil.yapilandiriliyor),
                            backgroundColor: const Color(0xFFFFB4A2),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E0F7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.show_chart,
                              color: subtitleColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Dil.buyumeKayitlari,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: subtitleColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    GestureDetector(
                      onTap: _saveProfile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB4A2),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          Dil.kaydet,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildCard({
    required bool isDark,
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

  void _saveProfile() async {
    await VeriYonetici.setBabyName(_nameController.text.trim());
    await VeriYonetici.setBirthDate(_birthDate);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Dil.kaydedildi),
        backgroundColor: const Color(0xFFFFB4A2),
      ),
    );
    Navigator.pop(context, true); // Return true to indicate changes were made
  }
}
