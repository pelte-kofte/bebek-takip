import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/dil.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import 'growth_screen.dart';
import 'vaccines_screen.dart';

class BabyProfileScreen extends StatefulWidget {
  const BabyProfileScreen({super.key});

  @override
  State<BabyProfileScreen> createState() => _BabyProfileScreenState();
}

class _BabyProfileScreenState extends State<BabyProfileScreen> {
  late TextEditingController _nameController;
  final TextEditingController _notesController = TextEditingController();
  late DateTime _birthDate;
  String? _photoPath;
  final ImagePicker _imagePicker = ImagePicker();

  // Dirty tracking
  late String _initialName;
  late DateTime _initialBirthDate;
  String? _initialPhotoPath;

  bool get _isDirty =>
      _nameController.text.trim() != _initialName ||
      _birthDate != _initialBirthDate ||
      _photoPath != _initialPhotoPath;

  @override
  void initState() {
    super.initState();
    _initialName = VeriYonetici.getBabyName();
    _initialBirthDate = VeriYonetici.getBirthDate();
    _initialPhotoPath = VeriYonetici.getBabyPhotoPath();

    _nameController = TextEditingController(text: _initialName);
    _birthDate = _initialBirthDate;
    _photoPath = _initialPhotoPath;

    _nameController.addListener(() => setState(() {}));
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
    final totalMonths = (difference.inDays / 30.44).floor();
    final days = difference.inDays % 30;

    if (totalMonths >= 12) {
      final years = totalMonths ~/ 12;
      final remainingMonths = totalMonths % 12;
      if (remainingMonths > 0) {
        return '$years ${Dil.yil}  ·  $remainingMonths ${Dil.ay}';
      }
      return '$years ${Dil.yil}';
    } else if (totalMonths > 0) {
      return '$totalMonths ${Dil.ay}  ·  $days ${Dil.gun}';
    } else {
      return '$days ${Dil.gun}';
    }
  }

  bool get _hasPhoto =>
      _photoPath != null && File(_photoPath!).existsSync();

  Future<void> _pickPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _photoPath = image.path);
    }
  }

  void _showPhotoOptions(bool isDark) {
    final cardColor = isDark ? AppColors.bgDarkCard : const Color(0xFFFFFBF5);
    final textColor = isDark ? AppColors.textPrimaryDark : const Color(0xFF2D1A18);
    final subtitleColor = isDark ? AppColors.textSecondaryDark : const Color(0xFF7A749E);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: subtitleColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFE5E0F7).withValues(alpha: 0.12)
                      : const Color(0xFFE5E0F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_outlined, color: subtitleColor, size: 20),
              ),
              title: Text(
                'Fotoğrafı Değiştir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto();
              },
            ),
            if (_hasPhoto)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                ),
                title: Text(
                  'Fotoğrafı Kaldır',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade300,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _photoPath = null);
                },
              ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                        boxShadow: isDark
                            ? null
                            : [
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
                    GestureDetector(
                      onTap: () {
                        if (_hasPhoto) {
                          _showPhotoOptions(isDark);
                        } else {
                          _pickPhoto();
                        }
                      },
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.bgDarkCard
                                      : const Color(0xFFEBE8FF),
                                  border: Border.all(
                                    color: _hasPhoto
                                        ? const Color(0xFFFFB4A2).withValues(alpha: 0.4)
                                        : (isDark ? Colors.white24 : Colors.white),
                                    width: _hasPhoto ? 3 : 4,
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: _hasPhoto
                                                ? const Color(0xFFFFB4A2).withValues(alpha: 0.25)
                                                : Colors.black.withValues(alpha: 0.06),
                                            blurRadius: _hasPhoto ? 24 : 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                ),
                                child: ClipOval(
                                  child: _hasPhoto
                                      ? Image.file(
                                          File(_photoPath!),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/icons/illustration/baby_face.png',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Container(
                                                color: isDark
                                                    ? AppColors.bgDarkCard
                                                    : const Color(0xFFEBE8FF),
                                                child: Icon(
                                                  Icons.child_care,
                                                  color: isDark
                                                      ? const Color(0xFFFFB4A2)
                                                      : const Color(0xFFFF998A),
                                                  size: 48,
                                                ),
                                              ),
                                        ),
                                ),
                              ),
                              // Camera badge
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB4A2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.bgDark
                                          : Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!_hasPhoto) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Fotoğraf ekle',
                              style: TextStyle(
                                fontSize: 13,
                                color: subtitleColor.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
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
                        color: isDark
                            ? const Color(0xFFE5E0F7).withValues(alpha: 0.15)
                            : const Color(0xFFE5E0F7),
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
                                    color: isDark
                                        ? const Color(0xFFE5E0F7).withValues(alpha: 0.12)
                                        : const Color(0xFFE5E0F7),
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
                                    color: isDark
                                        ? const Color(0xFFE5E0F7).withValues(alpha: 0.12)
                                        : const Color(0xFFE5E0F7),
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

                    // Action Cards
                    _buildActionCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      icon: Icons.show_chart,
                      label: Dil.buyumeKayitlari,
                      subtitleColor: subtitleColor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GrowthScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      icon: Icons.vaccines_outlined,
                      label: Dil.asilar,
                      subtitleColor: subtitleColor,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VaccinesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isDirty ? 1.0 : 0.45,
                      child: GestureDetector(
                        onTap: _isDirty ? _saveProfile : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB4A2),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _isDirty && !isDark
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
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
                    ),
                    const SizedBox(height: 32),

                    // Danger Zone separator
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: subtitleColor.withValues(alpha: 0.12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'VERİ YÖNETİMİ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: subtitleColor.withValues(alpha: 0.5),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: subtitleColor.withValues(alpha: 0.12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      isDark: isDark,
                      cardColor: cardColor,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showResetDialog(isDark, cardColor, textColor, subtitleColor),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.red.shade400.withValues(alpha: 0.15)
                                    : const Color(0xFFFFE5E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: isDark
                                    ? Colors.red.shade300
                                    : Colors.red.shade400,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bu bebeğin verilerini sil',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.red.shade300
                                          : Colors.red.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Diğer bebekler etkilenmez',
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

  Widget _buildActionCard({
    required bool isDark,
    required Color cardColor,
    required IconData icon,
    required String label,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isDark
          ? const Color(0xFFE5E0F7).withValues(alpha: 0.12)
          : const Color(0xFFE5E0F7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
        highlightColor: const Color(0xFFFFB4A2).withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: subtitleColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: subtitleColor,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(bool isDark, Color cardColor, Color textColor, Color subtitleColor) {
    final babyName = _nameController.text.trim();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.red.shade400.withValues(alpha: 0.15)
                    : const Color(0xFFFFE5E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: isDark ? Colors.red.shade300 : Colors.red.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              Dil.dikkat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 14, color: subtitleColor, height: 1.5),
            children: [
              const TextSpan(text: 'Sadece '),
              TextSpan(
                text: babyName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const TextSpan(text: ' bebeğinin tüm kayıtları silinecek.\n\n'),
              const TextSpan(text: 'Diğer bebekler etkilenmez. Bu işlem geri alınamaz.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Dil.iptal,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 15,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await VeriYonetici.verileriTemizle();
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$babyName verileri silindi'),
                  backgroundColor: const Color(0xFFFFB4A2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.red.shade300 : Colors.red.shade400,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                Dil.sil,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
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
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.06))
            : null,
        boxShadow: isDark
            ? null
            : [
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
    await VeriYonetici.setBabyPhotoPath(_photoPath);

    if (!mounted) return;

    // Update initial values so dirty state resets
    _initialName = _nameController.text.trim();
    _initialBirthDate = _birthDate;
    _initialPhotoPath = _photoPath;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Dil.kaydedildi),
        backgroundColor: const Color(0xFFFFB4A2),
      ),
    );
    Navigator.pop(context, true);
  }
}
