import 'package:flutter/material.dart';
import '../models/dil.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../widgets/decorative_background.dart';
import 'package:intl/intl.dart';

class AddVaccineScreen extends StatefulWidget {
  final Map<String, dynamic>? vaccine;
  final int? index;

  const AddVaccineScreen({
    super.key,
    this.vaccine,
    this.index,
  });

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedPeriod = 'Doğumda';
  String _selectedStatus = 'bekleniyor';
  DateTime? _selectedDate;

  final List<String> _periods = [
    'Doğumda',
    '2. Ay',
    '4. Ay',
    '6. Ay',
    '12. Ay',
    '18. Ay',
    '24. Ay',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vaccine != null) {
      _nameController.text = widget.vaccine!['ad'] ?? '';
      _notesController.text = widget.vaccine!['notlar'] ?? '';
      _selectedPeriod = widget.vaccine!['donem'] ?? 'Doğumda';
      _selectedStatus = widget.vaccine!['durum'] ?? 'bekleniyor';
      _selectedDate = widget.vaccine!['tarih'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveVaccine() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Dil.asiAdi} boş bırakılamaz')),
      );
      return;
    }

    final vaccines = VeriYonetici.getAsiKayitlari();
    final newVaccine = {
      'id': widget.vaccine?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'ad': _nameController.text.trim(),
      'donem': _selectedPeriod,
      'durum': _selectedStatus,
      'tarih': _selectedDate,
      'notlar': _notesController.text.trim(),
    };

    if (widget.index != null) {
      vaccines[widget.index!] = newVaccine;
    } else {
      vaccines.add(newVaccine);
    }

    await VeriYonetici.saveAsiKayitlari(vaccines);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFFFB4A2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isEdit = widget.vaccine != null;

  return DecorativeBackground(
    child: Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(isDark, isEdit),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameField(isDark),
                        const SizedBox(height: 24),
                        _buildPeriodSelector(isDark),
                        const SizedBox(height: 24),
                        _buildStatusSelector(isDark),

                        if (_selectedStatus == 'uygulandi') ...[
                          const SizedBox(height: 24),
                          _buildDateSelector(isDark),
                        ],

                        const SizedBox(height: 24),
                        _buildNotesField(isDark),
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
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildHeader(bool isDark, bool isEdit) {
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
                color: const Color(0xFFFFB4A2).withOpacity(0.1),
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
                color: const Color(0xFFFFB4A2),
                size: 24,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            isEdit ? Dil.asiDuzenle : Dil.asiEkle,
            style: AppTypography.h1(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            Dil.asiAdi,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB4A2).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _nameController,
            style: AppTypography.body(context),
            decoration: InputDecoration(
              hintText: 'örn: Hepatit B, BCG, Karma Aşı',
              hintStyle: AppTypography.bodySmall(context),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            Dil.donem,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFB4A2)
                      : (isDark
                          ? AppColors.bgDarkCard.withOpacity(0.9)
                          : Colors.white.withOpacity(0.9)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFB4A2)
                        : const Color(0xFFFFB4A2).withOpacity(0.1),
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFFFFB4A2).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  period,
                  style: AppTypography.label(context).copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Durum',
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = 'bekleniyor';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedStatus == 'bekleniyor'
                        ? const Color(0xFFE5E0F7)
                        : (isDark
                            ? AppColors.bgDarkCard.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedStatus == 'bekleniyor'
                          ? const Color(0xFFE5E0F7)
                          : const Color(0xFFFFB4A2).withOpacity(0.1),
                    ),
                    boxShadow: [
                      if (_selectedStatus == 'bekleniyor')
                        BoxShadow(
                          color: const Color(0xFFE5E0F7).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      Dil.bekleniyor,
                      style: AppTypography.body(context).copyWith(
                        color: _selectedStatus == 'bekleniyor'
                            ? const Color(0xFF5D3FD3)
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = 'uygulandi';
                    if (_selectedDate == null) {
                      _selectedDate = DateTime.now();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _selectedStatus == 'uygulandi'
                        ? const Color(0xFF81C784)
                        : (isDark
                            ? AppColors.bgDarkCard.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedStatus == 'uygulandi'
                          ? const Color(0xFF81C784)
                          : const Color(0xFFFFB4A2).withOpacity(0.1),
                    ),
                    boxShadow: [
                      if (_selectedStatus == 'uygulandi')
                        BoxShadow(
                          color: const Color(0xFF81C784).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      Dil.uygulandi,
                      style: AppTypography.body(context).copyWith(
                        color: _selectedStatus == 'uygulandi'
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            Dil.tarihSec,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.bgDarkCard.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFB4A2).withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB4A2).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: const Color(0xFFFFB4A2),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? DateFormat('dd.MM.yyyy').format(_selectedDate!)
                      : 'Tarih seçin',
                  style: AppTypography.body(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '${Dil.not} (${Dil.opsiyonel})',
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB4A2).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _notesController,
            style: AppTypography.body(context),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'örn: 1. Doz, DabT-IPA-Hib',
              hintStyle: AppTypography.bodySmall(context),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB4A2).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveVaccine,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB4A2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.vaccine != null ? Dil.guncelle : Dil.kaydet,
          style: AppTypography.button().copyWith(fontSize: 18),
        ),
      ),
    );
  }
}
