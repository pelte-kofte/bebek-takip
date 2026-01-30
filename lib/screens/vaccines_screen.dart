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
    final birthDate = VeriYonetici.getBirthDate();
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final months = (difference.inDays / 30).floor();
    final days = difference.inDays % 30;

    if (months >= 12) {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths > 0) {
        return '$years Yıl $remainingMonths Aylık';
      }
      return '$years Yıllık';
    } else if (months > 0) {
      return '$months Ay $days Günlük';
    } else {
      return '$days Günlük';
    }
  }

  String _getBabyName() {
    return VeriYonetici.getBabyName();
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

  void _showVaccineOptions(Map<String, dynamic> vaccine, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                ),
                title: Text(Dil.duzenle),
                onTap: () {
                  Navigator.pop(context);
                  _editVaccine(vaccine, index);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                title: Text(
                  Dil.sil,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteVaccine(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAsCompleted(int index) async {
    setState(() {
      _vaccines[index]['durum'] = 'uygulandi';
      _vaccines[index]['tarih'] = DateTime.now();
    });
    await VeriYonetici.saveAsiKayitlari(_vaccines);
  }

  void _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      // Adjust indices to account for baby info card at index 0
      oldIndex -= 1;
      newIndex -= 1;

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _vaccines.removeAt(oldIndex);
      _vaccines.insert(newIndex, item);
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

  /// Checks if a vaccine already exists in user's list (same name + same period)
  bool _isDuplicateVaccine(Map<String, dynamic> vaccine) {
    return _vaccines.any((v) =>
        v['ad'] == vaccine['ad'] && v['donem'] == vaccine['donem']);
  }

  void _showNationalVaccineSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nationalVaccines = AsiVeri.getTurkiyeAsiTakvimi();

    // Track which vaccines are selected (initially none)
    final selectedVaccines = <String, bool>{};
    for (final vaccine in nationalVaccines) {
      selectedVaccines[vaccine['id']] = false;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Count selected and available (non-duplicate) vaccines
          int availableCount = 0;
          int selectedCount = 0;
          for (final vaccine in nationalVaccines) {
            if (!_isDuplicateVaccine(vaccine)) {
              availableCount++;
              if (selectedVaccines[vaccine['id']] == true) {
                selectedCount++;
              }
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : const Color(0xFFFFFBF5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAB9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('🇹🇷', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Türk Aşı Takvimi',
                              style: AppTypography.h2(context),
                            ),
                            Text(
                              '$availableCount aşı mevcut',
                              style: AppTypography.caption(context).copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF866F65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
                        ),
                      ),
                    ],
                  ),
                ),
                // Select All / Deselect All buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: availableCount > 0
                              ? () {
                                  setModalState(() {
                                    for (final vaccine in nationalVaccines) {
                                      if (!_isDuplicateVaccine(vaccine)) {
                                        selectedVaccines[vaccine['id']] = true;
                                      }
                                    }
                                  });
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Tümünü Seç'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: selectedCount > 0
                              ? () {
                                  setModalState(() {
                                    for (final id in selectedVaccines.keys) {
                                      selectedVaccines[id] = false;
                                    }
                                  });
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF866F65),
                            side: BorderSide(
                              color: const Color(0xFF866F65).withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Temizle'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Vaccine list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: nationalVaccines.length,
                    itemBuilder: (context, index) {
                      final vaccine = nationalVaccines[index];
                      final isDuplicate = _isDuplicateVaccine(vaccine);
                      final isSelected = selectedVaccines[vaccine['id']] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDuplicate
                                  ? Colors.grey.withOpacity(0.2)
                                  : isSelected
                                      ? AppColors.primary.withOpacity(0.3)
                                      : Colors.transparent,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: isDuplicate
                                ? null
                                : (value) {
                                    setModalState(() {
                                      selectedVaccines[vaccine['id']] = value ?? false;
                                    });
                                  },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.primary,
                            title: Text(
                              vaccine['ad'],
                              style: AppTypography.body(context).copyWith(
                                color: isDuplicate
                                    ? (isDark
                                        ? AppColors.textSecondaryDark.withOpacity(0.5)
                                        : const Color(0xFF866F65).withOpacity(0.5))
                                    : null,
                                decoration: isDuplicate
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Text(
                              isDuplicate
                                  ? '${vaccine['donem']} • Zaten ekli'
                                  : '${vaccine['donem']}${vaccine['notlar']?.isNotEmpty == true ? ' • ${vaccine['notlar']}' : ''}',
                              style: AppTypography.caption(context).copyWith(
                                color: isDuplicate
                                    ? (isDark
                                        ? AppColors.textSecondaryDark.withOpacity(0.4)
                                        : const Color(0xFF866F65).withOpacity(0.4))
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : const Color(0xFF866F65)),
                              ),
                            ),
                            secondary: isDuplicate
                                ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.accentGreen.withOpacity(0.5),
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Add button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedCount > 0
                            ? () async {
                                // Gather selected vaccines
                                final toAdd = nationalVaccines
                                    .where((v) =>
                                        selectedVaccines[v['id']] == true &&
                                        !_isDuplicateVaccine(v))
                                    .toList();

                                if (toAdd.isEmpty) {
                                  Navigator.pop(context);
                                  return;
                                }

                                // Add vaccines with new unique IDs to avoid conflicts
                                final existingVaccines = VeriYonetici.getAsiKayitlari();
                                for (final vaccine in toAdd) {
                                  final newVaccine = Map<String, dynamic>.from(vaccine);
                                  // Generate a unique ID to prevent ID conflicts
                                  newVaccine['id'] = '${vaccine['id']}_${DateTime.now().millisecondsSinceEpoch}_${existingVaccines.length}';
                                  existingVaccines.add(newVaccine);
                                }

                                await VeriYonetici.saveAsiKayitlari(existingVaccines);
                                _loadVaccines();

                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${toAdd.length} aşı eklendi'),
                                      backgroundColor: AppColors.accentGreen,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          selectedCount > 0
                              ? '$selectedCount Aşı Ekle'
                              : 'Aşı Seçin',
                          style: AppTypography.button(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return DecorativeBackground(
    preset: BackgroundPreset.vaccines,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: _vaccines.isEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBabyInfoCard(isDark),
                              const SizedBox(height: 32),
                              _buildEmptyState(isDark),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          buildDefaultDragHandles: false,
                          onReorder: _onReorder,
                          itemCount: _vaccines.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                key: const ValueKey('baby_info'),
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _buildBabyInfoCard(isDark),
                              );
                            }
                            final vaccineIndex = index - 1;
                            final vaccine = _vaccines[vaccineIndex];
                            final isCompleted = vaccine['durum'] == 'uygulandi';
                            return Padding(
                              key: ValueKey(vaccine['id'] ?? vaccineIndex),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReorderableVaccineCard(
                                vaccine,
                                vaccineIndex,
                                isDark,
                                isCompleted,
                              ),
                            );
                          },
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
          Expanded(
            child: Text(
              Dil.asilarim,
              style: AppTypography.h1(context),
            ),
          ),
          // National vaccine selector button
          GestureDetector(
            onTap: _showNationalVaccineSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.bgDarkCard
                    : const Color(0xFFFFDAB9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇹🇷', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    'Takvim',
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
                _getBabyName(),
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
          final index = _vaccines.indexOf(vaccine);
          final isCompleted = vaccine['durum'] == 'uygulandi';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVaccineCard(vaccine, index, isDark, isCompleted),
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

  Widget _buildReorderableVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
    bool isCompleted,
  ) {
    final dateStr = vaccine['tarih'] != null
        ? DateFormat('dd.MM.yyyy').format(vaccine['tarih'] as DateTime)
        : '';

    return GestureDetector(
      onTap: () => _editVaccine(vaccine, index),
      onLongPress: () => _showVaccineOptions(vaccine, index),
      child: Container(
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
            ReorderableDragStartListener(
              index: index + 1,
              child: Icon(
                Icons.drag_indicator,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.4)
                    : const Color(0xFF866F65).withOpacity(0.4),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFFFDAB9)
                    : AppColors.accentPeach.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.vaccines,
                color: isCompleted
                    ? const Color(0xFFFFB4A2)
                    : AppColors.primary,
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
                        : dateStr.isNotEmpty
                            ? '${vaccine['donem']} • $dateStr'
                            : '${vaccine['donem']} • Tarih seç',
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
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark.withOpacity(0.5)
                  : const Color(0xFF866F65).withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
    bool isCompleted,
  ) {
    final dateStr = vaccine['tarih'] != null
        ? DateFormat('dd.MM.yyyy').format(vaccine['tarih'] as DateTime)
        : '';

    return GestureDetector(
      onTap: () => _editVaccine(vaccine, index),
      onLongPress: () => _showVaccineOptions(vaccine, index),
      child: Container(
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
                        : dateStr.isNotEmpty
                            ? '${vaccine['donem']} • $dateStr'
                            : '${vaccine['donem']} • Tarih seç',
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
            const SizedBox(width: 8),
            Icon(
              Icons.edit_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark.withOpacity(0.5)
                  : const Color(0xFF866F65).withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingVaccineCard(
    Map<String, dynamic> vaccine,
    int index,
    bool isDark,
  ) {
    final dateStr = vaccine['tarih'] != null
        ? DateFormat('dd.MM.yyyy').format(vaccine['tarih'] as DateTime)
        : '';

    return GestureDetector(
      onTap: () => _editVaccine(vaccine, index),
      onLongPress: () => _showVaccineOptions(vaccine, index),
      child: Container(
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
                    dateStr.isNotEmpty
                        ? '${vaccine['donem']} • $dateStr'
                        : '${vaccine['donem']} • Tarih seç',
                    style: AppTypography.caption(context).copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : const Color(0xFF866F65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: isDark
                  ? AppColors.textSecondaryDark.withOpacity(0.5)
                  : const Color(0xFF866F65).withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
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
