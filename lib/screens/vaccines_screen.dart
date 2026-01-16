import 'package:flutter/material.dart';
import '../models/dil.dart';
import '../models/veri_yonetici.dart';
import '../models/asi_veri.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import 'add_vaccine_screen.dart';
import 'package:intl/intl.dart';

class VaccinesScreen extends StatefulWidget {
  const VaccinesScreen({super.key});

  @override
  State<VaccinesScreen> createState() => _VaccinesScreenState();
}

class _VaccinesScreenState extends State<VaccinesScreen> {
  List<Map<String, dynamic>> _vaccines = [];

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  void _loadVaccines() {
    setState(() {
      _vaccines = VeriYonetici.getAsiKayitlari();
    });
  }

  List<Map<String, dynamic>> _getVaccinesByPeriod(String period) {
    return _vaccines.where((v) => v['donem'] == period).toList();
  }

  List<Map<String, dynamic>> _getCompletedVaccines() {
    return _vaccines.where((v) => v['durum'] == 'uygulandi').toList();
  }

  List<Map<String, dynamic>> _getUpcomingVaccines() {
    return _vaccines.where((v) => v['durum'] == 'bekleniyor').toList();
  }

  String _getChildAge() {
    return '10 Ay 12 Günlük';
  }

  void _deleteVaccine(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Dil.dikkat),
        content: Text(Dil.silmekIstiyor),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Dil.hayir),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              Dil.evet,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _vaccines.removeAt(index);
      });
      await VeriYonetici.saveAsiKayitlari(_vaccines);
    }
  }

  void _editVaccine(Map<String, dynamic> vaccine, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVaccineScreen(
          vaccine: vaccine,
          index: index,
        ),
      ),
    );

    if (result == true) {
      _loadVaccines();
    }
  }

  void _markAsCompleted(int index) async {
    setState(() {
      _vaccines[index]['durum'] = 'uygulandi';
      _vaccines[index]['tarih'] = DateTime.now();
    });
    await VeriYonetici.saveAsiKayitlari(_vaccines);
  }

  void _initializeDefaultVaccines() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Türkiye Aşı Takvimini Yükle'),
        content: const Text(
          'Türkiye\'nin standart aşı takvimi yüklenecek. Mevcut aşılar silinmeyecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Dil.iptal),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Dil.tamam),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final defaultVaccines = AsiVeri.getTurkiyeAsiTakvimi();
      final existingVaccines = VeriYonetici.getAsiKayitlari();

      final existingIds = existingVaccines.map((v) => v['id']).toSet();
      final newVaccines = defaultVaccines.where((v) => !existingIds.contains(v['id'])).toList();

      existingVaccines.addAll(newVaccines);
      await VeriYonetici.saveAsiKayitlari(existingVaccines);
      _loadVaccines();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newVaccines.length} aşı eklendi'),
          ),
        );
      }
    }
  }

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return DecorativeBackground(
    child: Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBabyInfoCard(isDark),

                        if (_vaccines.isEmpty) ...[
                          const SizedBox(height: 32),
                          _buildEmptyState(isDark),
                        ],

                        const SizedBox(height: 32),
                        _buildVaccinesByPeriod('Doğumda', Dil.dogumda, isDark),
                        const SizedBox(height: 32),
                        _buildVaccinesByPeriod('2. Ay', Dil.ikinci, isDark),
                        const SizedBox(height: 32),
                        _buildUpcomingVaccines(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: _buildAddButton(),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            Dil.asilarim,
            style: AppTypography.h1(context),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFB4A2).withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAB9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.child_care,
              color: const Color(0xFFFFB4A2),
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mavi',
                style: AppTypography.h2(context),
              ),
              const SizedBox(height: 4),
              Text(
                _getChildAge(),
                style: AppTypography.bodySmall(context).copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF866F65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesByPeriod(String period, String title, bool isDark) {
    final vaccines = _getVaccinesByPeriod(period);
    if (vaccines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title.toUpperCase(),
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...vaccines.asMap().entries.map((entry) {
          final vaccine = entry.value;
          final isCompleted = vaccine['durum'] == 'uygulandi';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVaccineCard(vaccine, isDark, isCompleted),
          );
        }),
      ],
    );
  }

  Widget _buildUpcomingVaccines(bool isDark) {
    final upcomingVaccines = _getUpcomingVaccines();
    if (upcomingVaccines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            Dil.gelecekAsilar.toUpperCase(),
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...upcomingVaccines.asMap().entries.map((entry) {
          final index = _vaccines.indexOf(entry.value);
          final vaccine = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildUpcomingVaccineCard(vaccine, index, isDark),
          );
        }),
      ],
    );
  }

  Widget _buildVaccineCard(
    Map<String, dynamic> vaccine,
    bool isDark,
    bool isCompleted,
  ) {
    final dateStr = vaccine['tarih'] != null
        ? DateFormat('dd.MM.yyyy').format(vaccine['tarih'] as DateTime)
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB4A2).withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAB9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.vaccines,
              color: const Color(0xFFFFB4A2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine['ad'],
                  style: AppTypography.h3(context).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted
                      ? '${Dil.uygulandi} - $dateStr'
                      : vaccine['notlar'] ?? Dil.bekleniyor,
                  style: AppTypography.caption(context).copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF866F65),
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.check,
                color: AppColors.accentGreen,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accentPeach.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.vaccines,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine['ad'],
                  style: AppTypography.h3(context).copyWith(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF866F65),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vaccine['notlar'] ?? Dil.bekleniyor,
                  style: AppTypography.caption(context).copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF866F65),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _editVaccine(vaccine, index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                Dil.duzenle,
                style: AppTypography.label(context).copyWith(
                  color: const Color(0xFF5D3FD3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.bgDarkCard.withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.vaccines_outlined,
            size: 64,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz aşı kaydı yok',
            style: AppTypography.h3(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Türkiye aşı takvimini yükleyin veya manuel olarak ekleyin',
            style: AppTypography.bodySmall(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _initializeDefaultVaccines,
            icon: const Icon(Icons.calendar_month),
            label: const Text('Türkiye Aşı Takvimini Yükle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddVaccineScreen(),
            ),
          );

          if (result == true) {
            _loadVaccines();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 24),
            const SizedBox(width: 8),
            Text(
              Dil.asiEkle,
              style: AppTypography.button().copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
