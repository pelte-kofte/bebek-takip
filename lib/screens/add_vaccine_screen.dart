import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/decorative_background.dart';

class AddVaccineScreen extends StatefulWidget {
  final Map<String, dynamic>? vaccine;
  final int? index;

  const AddVaccineScreen({super.key, this.vaccine, this.index});

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
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.vaccineNameCannotBeEmpty)));
      return;
    }

    final vaccines = VeriYonetici.getAsiKayitlari();
    final newVaccine = {
      'id':
          widget.vaccine?['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
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

  /// Returns true if the selected period is a custom one (not in presets)
  bool get _isCustomPeriod {
    return !_periods.contains(_selectedPeriod) && _selectedPeriod != 'Doğumda';
  }

  String _monthLabel(AppLocalizations l10n, int month) {
    if (month == 0) return l10n.birth;
    return l10n.monthNumber(month);
  }

  void _showCustomMonthPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    int selectedMonth = 0;

    // Try to parse current custom period if any (e.g., "3. Ay" -> 3)
    if (_isCustomPeriod) {
      selectedMonth = parseVaccineMonth(_selectedPeriod) ?? 0;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
                        ),
                      ),
                    ),
                    Text(l10n.selectMonth, style: AppTypography.h3(context)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedPeriod = selectedMonth == 0
                              ? 'Doğumda'
                              : '$selectedMonth. Ay';
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.ok,
                        style: TextStyle(
                          color: const Color(0xFFFFB4A2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedMonth,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    selectedMonth = index;
                  },
                  children: List.generate(61, (index) {
                    final label = _monthLabel(l10n, index);
                    return Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    DateTime tempDate = _selectedDate ?? DateTime.now();
    final lastDate = _selectedStatus == 'bekleniyor'
        ? DateTime.now().add(const Duration(days: 365 * 5))
        : DateTime.now();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.bgDarkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF866F65),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = tempDate;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.ok,
                        style: TextStyle(
                          color: const Color(0xFFFFB4A2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate.isAfter(lastDate)
                      ? lastDate
                      : tempDate,
                  minimumDate: DateTime(2020),
                  maximumDate: lastDate,
                  onDateTimeChanged: (date) {
                    tempDate = date;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.vaccine != null;

    return DecorativeBackground(
      preset: BackgroundPreset.vaccines,
      child: Scaffold(
        backgroundColor: Colors.transparent,
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

                          const SizedBox(height: 24),
                          _buildDateSelector(isDark),

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
    final l10n = AppLocalizations.of(context)!;
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
            isEdit ? l10n.editVaccine : l10n.addVaccine,
            style: AppTypography.h1(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.vaccineName,
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
            border: Border.all(color: const Color(0xFFFFB4A2).withOpacity(0.1)),
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
              hintText: AppLocalizations.of(context)!.vaccineNameHint,
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
    final l10n = AppLocalizations.of(context)!;
    // Build the list of chips to display
    final List<Widget> chips = [];

    // Add preset period chips
    for (final period in _periods) {
      final isSelected = _selectedPeriod == period;
      chips.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              localizedPeriodLabel(l10n, period),
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
        ),
      );
    }

    // Add custom period chip if a non-preset month is selected
    if (_isCustomPeriod) {
      chips.add(
        GestureDetector(
          onTap: _showCustomMonthPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB4A2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB4A2)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              localizedPeriodLabel(l10n, _selectedPeriod),
              style: AppTypography.label(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    // Add custom month button
    chips.add(
      GestureDetector(
        onTap: _showCustomMonthPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: const Color(0xFFFFB4A2)),
              const SizedBox(width: 4),
              Text(
                l10n.otherMonth,
                style: AppTypography.label(context).copyWith(
                  color: const Color(0xFFFFB4A2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.period,
            style: AppTypography.label(context).copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _buildStatusSelector(bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.status,
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
                      l10n.pending,
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
                    _selectedDate ??= DateTime.now();
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
                      l10n.applied,
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
    final l10n = AppLocalizations.of(context)!;
    final dateLabel = _selectedStatus == 'bekleniyor'
        ? l10n.scheduledDate
        : l10n.selectDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            dateLabel,
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
                      ? formatLocalizedDate(context, _selectedDate!)
                      : l10n.selectDate,
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            l10n.optionalNotes,
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
            border: Border.all(color: const Color(0xFFFFB4A2).withOpacity(0.1)),
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
              hintText: AppLocalizations.of(context)!.vaccineDoseHint,
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
    final l10n = AppLocalizations.of(context)!;
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
          widget.vaccine != null ? l10n.update : l10n.save,
          style: AppTypography.button().copyWith(fontSize: 18),
        ),
      ),
    );
  }
}
