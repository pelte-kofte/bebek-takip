import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';

class IlaclarScreen extends StatefulWidget {
  const IlaclarScreen({super.key});

  @override
  State<IlaclarScreen> createState() => _IlaclarScreenState();
}

class _IlaclarScreenState extends State<IlaclarScreen> {
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  void _loadMedications() {
    setState(() {
      _medications = VeriYonetici.getIlacKayitlari();
      // Sort: active first, then by createdAt descending
      _medications.sort((a, b) {
        final aActive = a['isActive'] == true;
        final bActive = b['isActive'] == true;
        if (aActive != bActive) return aActive ? -1 : 1;
        final aDate = a['createdAt'] as DateTime;
        final bDate = b['createdAt'] as DateTime;
        return bDate.compareTo(aDate);
      });
    });
  }

  void _addMedication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _MedicationFormScreen(),
      ),
    );
    if (result == true) _loadMedications();
  }

  void _editMedication(Map<String, dynamic> medication) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _MedicationFormScreen(medication: medication),
      ),
    );
    if (result == true) _loadMedications();
  }

  void _deleteMedication(Map<String, dynamic> medication) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.attention),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _medications.removeWhere((m) => m['id'] == medication['id']);
      await VeriYonetici.saveIlacKayitlari(_medications);
      _loadMedications();
    }
  }

  void _toggleActive(Map<String, dynamic> medication) async {
    final index = _medications.indexWhere((m) => m['id'] == medication['id']);
    if (index == -1) return;
    _medications[index]['isActive'] = !(medication['isActive'] == true);
    await VeriYonetici.saveIlacKayitlari(_medications);
    _loadMedications();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_medications.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noMedications,
                    style: AppTypography.h3(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: _buildAddButton(l10n),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          itemCount: _medications.length,
          itemBuilder: (context, index) {
            final med = _medications[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMedicationCard(med, isDark, l10n),
            );
          },
        ),
        Positioned(
          bottom: 32,
          left: 24,
          right: 24,
          child: _buildAddButton(l10n),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
    Map<String, dynamic> med,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isActive = med['isActive'] == true;
    final isMedication = med['type'] == 'medication';
    final typeBadge = isMedication ? l10n.medication : l10n.supplement;
    final badgeColor = isMedication
        ? AppColors.primary.withOpacity(0.15)
        : const Color(0xFFE5E0F7);
    final badgeTextColor = isMedication
        ? AppColors.primary
        : const Color(0xFF6B5B95);

    return GestureDetector(
      onTap: () => _editMedication(med),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withOpacity(isActive ? 0.9 : 0.5)
              : Colors.white.withOpacity(isActive ? 0.9 : 0.6),
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
                color: isActive
                    ? const Color(0xFFFFDAB9)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isMedication
                    ? Icons.medication_outlined
                    : Icons.eco_outlined,
                color: isActive
                    ? const Color(0xFFFFB4A2)
                    : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          med['name'] ?? '',
                          style: AppTypography.h3(context).copyWith(
                            fontSize: 16,
                            color: isActive
                                ? null
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF866F65)),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? badgeColor : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? badgeTextColor : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((med['dosage'] as String?)?.isNotEmpty == true ||
                      (med['scheduleText'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if ((med['dosage'] as String?)?.isNotEmpty == true)
                          med['dosage'],
                        if ((med['scheduleText'] as String?)?.isNotEmpty == true)
                          med['scheduleText'],
                      ].join(' • '),
                      style: AppTypography.caption(context).copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF866F65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.5)
                    : const Color(0xFF866F65).withOpacity(0.5),
                size: 20,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editMedication(med);
                    break;
                  case 'toggle':
                    _toggleActive(med);
                    break;
                  case 'delete':
                    _deleteMedication(med);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(isActive ? 'Pasif' : 'Aktif'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(AppLocalizations l10n) {
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
        onPressed: _addMedication,
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
              l10n.addMedication,
              style: AppTypography.button().copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ ADD / EDIT FORM ============

class _MedicationFormScreen extends StatefulWidget {
  final Map<String, dynamic>? medication;

  const _MedicationFormScreen({this.medication});

  @override
  State<_MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<_MedicationFormScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'medication';
  bool _isActive = true;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final med = widget.medication!;
      _nameController.text = med['name'] ?? '';
      _dosageController.text = med['dosage'] ?? '';
      _scheduleController.text = med['scheduleText'] ?? '';
      _notesController.text = med['notes'] ?? '';
      _type = med['type'] ?? 'medication';
      _isActive = med['isActive'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.medicationNameRequired)),
      );
      return;
    }

    final medications = VeriYonetici.getIlacKayitlari();

    if (_isEditing) {
      final index = medications.indexWhere(
        (m) => m['id'] == widget.medication!['id'],
      );
      if (index != -1) {
        medications[index] = {
          ...medications[index],
          'name': name,
          'type': _type,
          'dosage': _dosageController.text.trim().isEmpty
              ? null
              : _dosageController.text.trim(),
          'scheduleText': _scheduleController.text.trim().isEmpty
              ? null
              : _scheduleController.text.trim(),
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          'isActive': _isActive,
        };
      }
    } else {
      medications.add({
        'id': 'ilac_${DateTime.now().millisecondsSinceEpoch}',
        'babyId': VeriYonetici.getActiveBabyId(),
        'name': name,
        'type': _type,
        'dosage': _dosageController.text.trim().isEmpty
            ? null
            : _dosageController.text.trim(),
        'scheduleText': _scheduleController.text.trim().isEmpty
            ? null
            : _scheduleController.text.trim(),
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'isActive': _isActive,
        'createdAt': DateTime.now(),
      });
    }

    await VeriYonetici.saveIlacKayitlari(medications);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editMedication : l10n.addMedication,
          style: AppTypography.h2(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            Text(
              l10n.medicationName,
              style: AppTypography.label(context).copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF866F65),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration(isDark),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Type selector
            Text(
              l10n.type,
              style: AppTypography.label(context).copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF866F65),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption(
                    l10n.medication,
                    'medication',
                    Icons.medication_outlined,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeOption(
                    l10n.supplement,
                    'supplement',
                    Icons.eco_outlined,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dosage field
            Text(
              l10n.dosage,
              style: AppTypography.label(context).copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF866F65),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dosageController,
              decoration: _inputDecoration(isDark, hint: 'ör: 5ml, 1 tablet'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Schedule field
            Text(
              l10n.schedule,
              style: AppTypography.label(context).copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF866F65),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _scheduleController,
              decoration: _inputDecoration(
                isDark,
                hint: 'ör: Günde 2 kez, sabah-akşam',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Notes field
            Text(
              l10n.notes,
              style: AppTypography.label(context).copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF866F65),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: _inputDecoration(isDark),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.save,
                  style: AppTypography.button().copyWith(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : (isDark ? AppColors.bgDarkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : const Color(0xFF866F65)),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : const Color(0xFF866F65)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, {String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? AppColors.bgDarkCard : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }
}
