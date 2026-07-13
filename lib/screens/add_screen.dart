import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoDatePicker,
        CupertinoDatePickerMode,
        CupertinoIcons,
        CupertinoTimerPicker,
        CupertinoTimerPickerMode;
import 'package:flutter/services.dart';
import '../models/veri_yonetici.dart';
import '../l10n/app_localizations.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';
import '../utils/event_datetime_utils.dart';
import '../widgets/nilico_modal.dart';

class _AddScreenSnapshot {
  const _AddScreenSnapshot({
    required this.selectedActivity,
    required this.selectedSide,
    required this.minutes,
    required this.seconds,
    required this.bottleAmount,
    required this.milkType,
    required this.feedingCategory,
    required this.solidFood,
    required this.sleepStartDateTime,
    required this.sleepEndDateTime,
    required this.diaperType,
    required this.diaperDateTime,
    required this.diaperNotes,
    required this.feedingDateTime,
  });

  final String selectedActivity;
  final String selectedSide;
  final int minutes;
  final int seconds;
  final int bottleAmount;
  final String milkType;
  final String feedingCategory;
  final String solidFood;
  final DateTime sleepStartDateTime;
  final DateTime? sleepEndDateTime;
  final String diaperType;
  final DateTime diaperDateTime;
  final String diaperNotes;
  final DateTime feedingDateTime;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AddScreenSnapshot &&
        other.selectedActivity == selectedActivity &&
        other.selectedSide == selectedSide &&
        other.minutes == minutes &&
        other.seconds == seconds &&
        other.bottleAmount == bottleAmount &&
        other.milkType == milkType &&
        other.feedingCategory == feedingCategory &&
        other.solidFood == solidFood &&
        other.sleepStartDateTime == sleepStartDateTime &&
        other.sleepEndDateTime == sleepEndDateTime &&
        other.diaperType == diaperType &&
        other.diaperDateTime == diaperDateTime &&
        other.diaperNotes == diaperNotes &&
        other.feedingDateTime == feedingDateTime;
  }

  @override
  int get hashCode => Object.hash(
    selectedActivity,
    selectedSide,
    minutes,
    seconds,
    bottleAmount,
    milkType,
    feedingCategory,
    solidFood,
    sleepStartDateTime,
    sleepEndDateTime,
    diaperType,
    diaperDateTime,
    diaperNotes,
    feedingDateTime,
  );
}

class AddScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  final String? initialActivity;

  const AddScreen({super.key, this.onSaved, this.initialActivity});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late String selectedActivity;
  String selectedSide = 'left';
  int minutes = 0;
  int seconds = 0;

  // Bottle feeding fields
  int bottleAmount = 120;
  String milkType = 'breast'; // 'breast' or 'formula'
  String feedingCategory = 'Milk'; // 'Milk' or 'Solid'
  final TextEditingController _solidFoodController = TextEditingController();

  // Sleep fields
  late DateTime _sleepStartDateTime;
  DateTime? _sleepEndDateTime;

  // Diaper fields
  String _diaperType = 'both'; // 'wet', 'dirty', or 'both'
  late DateTime _diaperDateTime;
  final TextEditingController _diaperNotesController = TextEditingController();
  late DateTime _feedingDateTime;

  // Validation error message
  String? _errorMessage;
  bool _isSaving = false;
  late _AddScreenSnapshot _initialSnapshot;

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.initialActivity ?? 'breastfeeding';
    final now = DateTime.now();
    _sleepStartDateTime = now;
    _diaperDateTime = now;
    _feedingDateTime = now;
    _initialSnapshot = _captureSnapshot();
  }

  @override
  void dispose() {
    _diaperNotesController.dispose();
    _solidFoodController.dispose();
    super.dispose();
  }

  Future<void> _scheduleFeedingReminderIfEnabled() async {
    if (!VeriYonetici.isFeedingReminderEnabled()) return;
    final scheduledAt = _nextReminderDateTime(
      TimeOfDay(
        hour: VeriYonetici.getFeedingReminderHour(),
        minute: VeriYonetici.getFeedingReminderMinute(),
      ),
    );
    final reminderService = ReminderService();
    await reminderService.initialize();
    await reminderService.scheduleFeedingReminderAt(scheduledAt);
  }

  Future<void> _scheduleDiaperReminderIfEnabled() async {
    if (!VeriYonetici.isDiaperReminderEnabled()) return;
    final scheduledAt = _nextReminderDateTime(
      TimeOfDay(
        hour: VeriYonetici.getDiaperReminderHour(),
        minute: VeriYonetici.getDiaperReminderMinute(),
      ),
    );
    final reminderService = ReminderService();
    await reminderService.initialize();
    await reminderService.scheduleDiaperReminderAt(scheduledAt);
  }

  DateTime _nextReminderDateTime(TimeOfDay time) {
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      return scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  _AddScreenSnapshot _captureSnapshot() {
    return _AddScreenSnapshot(
      selectedActivity: selectedActivity,
      selectedSide: selectedSide,
      minutes: minutes,
      seconds: seconds,
      bottleAmount: bottleAmount,
      milkType: milkType,
      feedingCategory: feedingCategory,
      solidFood: _solidFoodController.text,
      sleepStartDateTime: _sleepStartDateTime,
      sleepEndDateTime: _sleepEndDateTime,
      diaperType: _diaperType,
      diaperDateTime: _diaperDateTime,
      diaperNotes: _diaperNotesController.text,
      feedingDateTime: _feedingDateTime,
    );
  }

  bool get _isDirty => _captureSnapshot() != _initialSnapshot;

  Future<bool> _confirmDiscardChanges() async {
    if (!_isDirty) return true;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => NilicoDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Discard them and close?',
        ),
        actions: [
          NilicoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            label: 'Continue editing',
          ),
          NilicoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, true),
            label: 'Discard',
            destructive: true,
          ),
        ],
      ),
    );
    return shouldDiscard ?? false;
  }

  Future<void> _handleCloseRequested() async {
    if (_isSaving) return;
    final shouldClose = await _confirmDiscardChanges();
    if (!mounted || !shouldClose) return;
    Navigator.pop(context, false);
  }

  /// Shows a Cupertino-style time picker in a bottom sheet
  Future<TimeOfDay?> _showCupertinoTimePicker(TimeOfDay initialTime) async {
    TimeOfDay selectedTime = initialTime;
    final l10n = AppLocalizations.of(context)!;

    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NilicoPickerSheet(
        cancelLabel: l10n.cancel,
        confirmLabel: l10n.ok,
        onCancel: () => Navigator.pop(context),
        onConfirm: () => Navigator.pop(context, selectedTime),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            initialTime.hour,
            initialTime.minute,
          ),
          onDateTimeChanged: (DateTime dateTime) {
            selectedTime = TimeOfDay(
              hour: dateTime.hour,
              minute: dateTime.minute,
            );
          },
        ),
      ),
    );

    return result;
  }

  Future<DateTime?> _pickEventTime(DateTime initialDateTime) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final pickedTime = await _showCupertinoTimePicker(
      TimeOfDay(hour: initialDateTime.hour, minute: initialDateTime.minute),
    );
    if (pickedTime == null) return null;

    final candidate = normalizePickedDateTime(
      now: now,
      pickedDate: DateTime(
        initialDateTime.year,
        initialDateTime.month,
        initialDateTime.day,
      ),
      pickedTime: pickedTime,
    );

    if (!isWithinRollingWindow(now: now, candidate: candidate)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.eventTimeTooOld)));
      }
      return null;
    }

    return candidate;
  }

  Future<DateTime?> _pickEventDate(DateTime initialDateTime) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(hours: 48));
    final initialDate = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now)
          ? DateTime(now.year, now.month, now.day)
          : initialDate,
      firstDate: DateTime(
        earliest.year,
        earliest.month,
        earliest.day,
      ).subtract(const Duration(days: 2)),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: l10n.selectDate,
    );
    if (pickedDate == null) return null;

    final candidate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      initialDateTime.hour,
      initialDateTime.minute,
    );

    if (!isWithinRollingWindow(now: now, candidate: candidate)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.eventTimeTooOld)));
      }
      return null;
    }

    return candidate;
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateLabel(DateTime value) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if (_isSameDate(value, now)) return l10n.today;
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }

  Widget _buildSectionEyebrow(String text, bool isDark) {
    return Text(
      text,
      style: AppTypography.eyebrow(context).copyWith(
        fontSize: 10,
        color: isDark
            ? Colors.white.withValues(alpha: 0.6)
            : const Color(0xFF4A3F3F),
      ),
    );
  }

  Widget _buildPastelTimeCard({
    required bool isDark,
    required DateTime? value,
    required String placeholder,
    required VoidCallback onTap,
    String? secondaryLabel,
    VoidCallback? onDateTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: _buildFeedingCard(
          isDark: isDark,
          surfaceColor: isDark ? AppColors.bgDarkSurface : Colors.white,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFFFF4EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CupertinoIcons.time,
                  size: 20,
                  color: isDark ? Colors.white70 : const Color(0xFFCF866F),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value != null ? _formatTime(value) : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.dataValue(context).copyWith(
                        fontSize: 22,
                        color: value != null
                            ? (isDark
                                  ? AppColors.textPrimaryDark
                                  : const Color(0xFF4A3F3F))
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : const Color(0xFF7A749E)),
                      ),
                    ),
                    if (secondaryLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        secondaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.58)
                              : const Color(0xFF8F8796),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null && onDateTap != null) ...[
                const SizedBox(width: 10),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onDateTap,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFFFF4EE),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF0E4E1),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.calendar,
                        size: 16,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFFCF866F),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 12),
              Icon(
                CupertinoIcons.chevron_right,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : const Color(0xFFB2A7AE),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarmSummaryCard({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF998A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  /// Shows a Cupertino-style duration picker (hours + minutes) in a bottom sheet
  Future<Duration?> _showCupertinoDurationPicker(
    Duration initialDuration,
  ) async {
    Duration selectedDuration = initialDuration;
    final l10n = AppLocalizations.of(context)!;

    final result = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => NilicoPickerSheet(
        cancelLabel: l10n.cancel,
        confirmLabel: l10n.ok,
        onCancel: () => Navigator.pop(context),
        onConfirm: () => Navigator.pop(context, selectedDuration),
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: initialDuration,
          onTimerDurationChanged: (Duration duration) {
            selectedDuration = duration;
          },
        ),
      ),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.bgDarkCard : AppColors.bgLightCard;
    final surfaceColor = isDark ? AppColors.bgDarkSurface : Colors.white;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleCloseRequested();
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.95),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  children: [
                    Material(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isSaving ? null : _handleCloseRequested,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : const Color(0xFF4A3F3F),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildCompactActivityChip('breastfeeding', l10n.nursing),
                    const SizedBox(width: 6),
                    _buildCompactActivityChip('bottle', l10n.bottle),
                    const SizedBox(width: 6),
                    _buildCompactActivityChip('sleep', l10n.sleep),
                    const SizedBox(width: 6),
                    _buildCompactActivityChip('diaper', l10n.diaper),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.bgDarkSurface
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: isDark
                            ? null
                            : const [
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 18,
                                  offset: Offset(0, 6),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedActivity == 'breastfeeding' ||
                              selectedActivity == 'bottle') ...[
                            _buildSectionEyebrow(l10n.selectTime, isDark),
                            const SizedBox(height: 12),
                            _buildPastelTimeCard(
                              isDark: isDark,
                              value: _feedingDateTime,
                              placeholder: l10n.tapToSetTime,
                              secondaryLabel: _formatDateLabel(
                                _feedingDateTime,
                              ),
                              onDateTap: () async {
                                final picked = await _pickEventDate(
                                  _feedingDateTime,
                                );
                                if (picked != null) {
                                  setState(() => _feedingDateTime = picked);
                                }
                              },
                              onTap: () async {
                                final picked = await _pickEventTime(
                                  _feedingDateTime,
                                );
                                if (picked != null) {
                                  setState(() => _feedingDateTime = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (selectedActivity == 'breastfeeding') ...[
                            _buildSectionEyebrow(l10n.side, isDark),
                            const SizedBox(height: 12),
                            _buildFeedingSegmentControl(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              groupValue: selectedSide,
                              options: [
                                _SegmentOption(value: 'left', label: l10n.left),
                                _SegmentOption(
                                  value: 'right',
                                  label: l10n.right,
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => selectedSide = value),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionEyebrow(l10n.duration, isDark),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                final picked =
                                    await _showCupertinoDurationPicker(
                                      Duration(minutes: minutes),
                                    );
                                if (picked != null) {
                                  setState(() => minutes = picked.inMinutes);
                                }
                              },
                              child: _buildFeedingMetricCard(
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                label: l10n.duration,
                                value: minutes > 0 ? minutes.toString() : '0',
                                unit: l10n.minAbbrev,
                                icon: CupertinoIcons.timer,
                                onDecrease: () => setState(() {
                                  if (minutes > 0) minutes--;
                                }),
                                onIncrease: () => setState(() {
                                  minutes++;
                                }),
                              ),
                            ),
                          ],
                          if (selectedActivity == 'bottle') ...[
                            _buildSectionEyebrow(l10n.category, isDark),
                            const SizedBox(height: 12),
                            _buildFeedingSegmentControl(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              groupValue: feedingCategory,
                              options: [
                                _SegmentOption(value: 'Milk', label: l10n.milk),
                                _SegmentOption(
                                  value: 'Solid',
                                  label: l10n.solid,
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => feedingCategory = value),
                            ),
                            const SizedBox(height: 24),
                            if (feedingCategory == 'Solid') ...[
                              _buildSectionEyebrow(l10n.whatWasGiven, isDark),
                              const SizedBox(height: 12),
                              _buildFeedingCard(
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                child: TextField(
                                  controller: _solidFoodController,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: l10n.solidFoodHint,
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.34)
                                          : const Color(
                                              0xFF6B6475,
                                            ).withValues(alpha: 0.55),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.86)
                                        : const Color(0xFF4A3F3F),
                                  ),
                                ),
                              ),
                            ] else ...[
                              _buildFeedingMetricCard(
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                label: l10n.amount,
                                value: bottleAmount.toString(),
                                unit: l10n.mlAbbrev,
                                icon: CupertinoIcons.drop,
                                onDecrease: () => setState(() {
                                  if (bottleAmount >= 10) bottleAmount -= 10;
                                }),
                                onIncrease: () => setState(() {
                                  bottleAmount += 10;
                                }),
                              ),
                              const SizedBox(height: 24),
                              _buildSectionEyebrow(l10n.milkType, isDark),
                              const SizedBox(height: 12),
                              _buildFeedingSegmentControl(
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                groupValue: milkType,
                                options: [
                                  _SegmentOption(
                                    value: 'breast',
                                    label: l10n.breastMilk,
                                  ),
                                  _SegmentOption(
                                    value: 'formula',
                                    label: l10n.formula,
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => milkType = value),
                              ),
                            ],
                          ],
                          if (selectedActivity == 'sleep') ...[
                            _buildSectionEyebrow(l10n.sleepStartedAt, isDark),
                            const SizedBox(height: 12),
                            _buildPastelTimeCard(
                              isDark: isDark,
                              value: _sleepStartDateTime,
                              placeholder: l10n.tapToSetTime,
                              secondaryLabel: _formatDateLabel(
                                _sleepStartDateTime,
                              ),
                              onDateTap: () async {
                                final picked = await _pickEventDate(
                                  _sleepStartDateTime,
                                );
                                if (picked != null) {
                                  setState(() => _sleepStartDateTime = picked);
                                }
                              },
                              onTap: () async {
                                final picked = await _pickEventTime(
                                  _sleepStartDateTime,
                                );
                                if (picked != null) {
                                  setState(() => _sleepStartDateTime = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionEyebrow(l10n.wokeUpAt, isDark),
                            const SizedBox(height: 12),
                            _buildPastelTimeCard(
                              isDark: isDark,
                              value: _sleepEndDateTime,
                              placeholder: l10n.tapToSetTime,
                              secondaryLabel: _sleepEndDateTime != null
                                  ? _formatDateLabel(_sleepEndDateTime!)
                                  : null,
                              onDateTap: _sleepEndDateTime == null
                                  ? null
                                  : () async {
                                      final picked = await _pickEventDate(
                                        _sleepEndDateTime!,
                                      );
                                      if (picked != null) {
                                        setState(
                                          () => _sleepEndDateTime = picked,
                                        );
                                      }
                                    },
                              onTap: () async {
                                final picked = await _pickEventTime(
                                  _sleepEndDateTime ?? DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _sleepEndDateTime = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            if (_sleepEndDateTime != null)
                              _buildWarmSummaryCard(
                                isDark: isDark,
                                child: Center(
                                  child: Text(
                                    l10n.totalSleep(_calculateSleepDuration()),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : const Color(0xFF4A3F3F),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if (selectedActivity == 'diaper') ...[
                            _buildSectionEyebrow(l10n.healthType, isDark),
                            const SizedBox(height: 12),
                            _buildFeedingSegmentControl(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              groupValue: _diaperType,
                              options: [
                                _SegmentOption(value: 'wet', label: l10n.wet),
                                _SegmentOption(
                                  value: 'dirty',
                                  label: l10n.dirty,
                                ),
                                _SegmentOption(value: 'both', label: l10n.both),
                              ],
                              onChanged: (value) =>
                                  setState(() => _diaperType = value),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionEyebrow(l10n.healthTime, isDark),
                            const SizedBox(height: 12),
                            _buildPastelTimeCard(
                              isDark: isDark,
                              value: _diaperDateTime,
                              placeholder: l10n.tapToSetTime,
                              secondaryLabel: _formatDateLabel(_diaperDateTime),
                              onDateTap: () async {
                                final picked = await _pickEventDate(
                                  _diaperDateTime,
                                );
                                if (picked != null) {
                                  setState(() => _diaperDateTime = picked);
                                }
                              },
                              onTap: () async {
                                final picked = await _pickEventTime(
                                  _diaperDateTime,
                                );
                                if (picked != null) {
                                  setState(() => _diaperDateTime = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionEyebrow(l10n.optionalNotes, isDark),
                            const SizedBox(height: 12),
                            _buildFeedingCard(
                              isDark: isDark,
                              surfaceColor: surfaceColor,
                              child: TextField(
                                controller: _diaperNotesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: l10n.diaperNoteHint,
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : const Color(
                                            0xFF4A3F3F,
                                          ).withValues(alpha: 0.3),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : const Color(
                                          0xFF4A3F3F,
                                        ).withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFF6B6B,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFF6B6B,
                                  ).withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFFF6B6B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFF6B6B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Material(
                            color: selectedActivity == 'bottle'
                                ? const Color(0xFFE39A86)
                                : const Color(0xFFFF998A),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _isSaving ? null : _saveActivity,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        l10n.save,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.button().copyWith(
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActivityChip(String type, String label) {
    final isSelected = selectedActivity == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _clearError();
            setState(() => selectedActivity = type);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFF998A).withValues(alpha: 0.12)
                  : (isDark ? AppColors.bgDarkCard : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF998A)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE9E2DE),
                width: 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFFF998A)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.72)
                    : const Color(0xFF7A749E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedingSegmentControl({
    required bool isDark,
    required Color surfaceColor,
    required String groupValue,
    required List<_SegmentOption> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A33) : const Color(0xFFF7F1EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: options
            .map(
              (option) => Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onChanged(option.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: groupValue == option.value
                            ? (isDark ? surfaceColor : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: groupValue == option.value && !isDark
                            ? const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        option.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: groupValue == option.value
                              ? const Color(0xFFB86E5A)
                              : isDark
                              ? Colors.white.withValues(alpha: 0.74)
                              : const Color(0xFF6F6878),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFeedingCard({
    required bool isDark,
    required Color surfaceColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkCard : const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _buildFeedingMetricCard({
    required bool isDark,
    required Color surfaceColor,
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return _buildFeedingCard(
      isDark: isDark,
      surfaceColor: surfaceColor,
      child: Row(
        children: [
          _buildFeedingAdjustButton(
            isDark: isDark,
            icon: Icons.remove_rounded,
            onTap: onDecrease,
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFFFF4EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFFCF866F),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.62)
                        : const Color(0xFF8F8796),
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: AppTypography.dataValue(context).copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : const Color(0xFF4A3F3F),
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: AppTypography.compactTitle(context).copyWith(
                          fontSize: 15,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.46)
                              : const Color(0xFF8F8796),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildFeedingAdjustButton(
            isDark: isDark,
            icon: Icons.add_rounded,
            onTap: onIncrease,
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingAdjustButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : const Color(0xFFFFFCF9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF0E4E1),
            ),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Icon(
            icon,
            size: 22,
            color: accent
                ? const Color(0xFFE08F78)
                : isDark
                ? Colors.white.withValues(alpha: 0.76)
                : const Color(0xFF8A8393),
          ),
        ),
      ),
    );
  }

  void _showValidationError(String message) {
    setState(() => _errorMessage = message);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _runBestEffortAfterClose(
    Future<void> Function() action,
    String label,
  ) async {
    try {
      await action().timeout(const Duration(seconds: 3));
    } catch (e, st) {
      debugPrint('AddScreen $label failed: $e\n$st');
    }
  }

  void _schedulePostCloseTask(Future<void> Function() action, String label) {
    unawaited(_runBestEffortAfterClose(action, label));
  }

  String _saveErrorMessage(AppLocalizations l10n, Object error) {
    final message = error.toString().trim();
    if (message.isEmpty) return l10n.saveFailedTryAgain;
    return l10n.errorWithMessage(message);
  }

  Future<void> _runSaveAction(
    Future<void> Function() action, {
    Future<void> Function()? afterClose,
  }) async {
    if (_isSaving) return;

    final l10n = AppLocalizations.of(context)!;
    _clearError();
    setState(() => _isSaving = true);
    var didClose = false;
    try {
      await action();
      _initialSnapshot = _captureSnapshot();
      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.of(context).pop(true);
      didClose = true;

      try {
        HapticFeedback.lightImpact();
      } catch (e, st) {
        debugPrint('AddScreen haptic feedback failed: $e\n$st');
      }
      try {
        widget.onSaved?.call();
      } catch (e, st) {
        debugPrint('AddScreen onSaved callback failed: $e\n$st');
      }
      if (afterClose != null) {
        _schedulePostCloseTask(afterClose, 'post-close action');
      }
    } catch (e, st) {
      debugPrint('AddScreen save failed: $e\n$st');
      if (!mounted) return;
      _showValidationError(_saveErrorMessage(l10n, e));
    } finally {
      if (mounted && _isSaving) {
        debugPrint('AddScreen save guard reset (didClose=$didClose)');
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveActivity() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // Validation: prevent saving activities with zero values
    if (selectedActivity == 'breastfeeding' && minutes == 0) {
      _showValidationError(l10n.pleaseSetDuration);
      return;
    }
    if (selectedActivity == 'bottle' &&
        feedingCategory == 'Milk' &&
        bottleAmount == 0) {
      _showValidationError(l10n.pleaseSetAmount);
      return;
    }
    if (selectedActivity == 'sleep') {
      if (_sleepEndDateTime == null) {
        _showValidationError(l10n.pleaseSetWakeUpTime);
        return;
      }
      final startDT = _sleepStartDateTime;
      var endDT = _sleepEndDateTime!;
      if (_isSameDate(startDT, endDT) && endDT.isBefore(startDT)) {
        endDT = endDT.add(const Duration(days: 1));
      }
      if (endDT.isAfter(now)) {
        _showValidationError(l10n.eventTimeTooOld);
        return;
      }
      if (endDT.difference(startDT).inMinutes == 0) {
        _showValidationError(l10n.sleepDurationMustBeGreater);
        return;
      }
    }

    if (selectedActivity == 'breastfeeding') {
      await _runSaveAction(() async {
        final kayitlar = VeriYonetici.getMamaKayitlari();
        final totalMinutes = minutes + (seconds / 60);

        kayitlar.insert(0, {
          'tarih': _feedingDateTime,
          'tur': 'Anne Sütü',
          'solDakika': selectedSide == 'left' ? totalMinutes.round() : 0,
          'sagDakika': selectedSide == 'right' ? totalMinutes.round() : 0,
          'miktar': 0,
          'kategori': 'Milk',
        });
        VeriYonetici.attachCreatorMetadataIfAbsent(kayitlar.first);

        await VeriYonetici.saveMamaKayitlari(kayitlar);
      }, afterClose: _scheduleFeedingReminderIfEnabled);
      return;
    }

    if (selectedActivity == 'bottle') {
      await _runSaveAction(() async {
        final kayitlar = VeriYonetici.getMamaKayitlari();

        if (feedingCategory == 'Solid') {
          kayitlar.insert(0, {
            'tarih': _feedingDateTime,
            'tur': 'Katı Gıda',
            'solDakika': 0,
            'sagDakika': 0,
            'miktar': 0,
            'kategori': 'Solid',
            'solidAciklama': _solidFoodController.text.isNotEmpty
                ? _solidFoodController.text
                : null,
            'solidDakika': 0,
          });
          VeriYonetici.attachCreatorMetadataIfAbsent(kayitlar.first);
        } else {
          kayitlar.insert(0, {
            'tarih': _feedingDateTime,
            'tur': milkType == 'breast' ? 'Anne Sütü (Biberon)' : 'Formül',
            'solDakika': 0,
            'sagDakika': 0,
            'miktar': bottleAmount,
            'kategori': 'Milk',
          });
          VeriYonetici.attachCreatorMetadataIfAbsent(kayitlar.first);
        }

        await VeriYonetici.saveMamaKayitlari(kayitlar);
      }, afterClose: _scheduleFeedingReminderIfEnabled);
      return;
    }

    if (selectedActivity == 'sleep') {
      await _runSaveAction(() async {
        final startDateTime = _sleepStartDateTime;
        var endDateTime = _sleepEndDateTime!;

        if (_isSameDate(startDateTime, endDateTime) &&
            endDateTime.isBefore(startDateTime)) {
          endDateTime = endDateTime.add(const Duration(days: 1));
        }

        final duration = endDateTime.difference(startDateTime);

        final kayitlar = VeriYonetici.getUykuKayitlari();
        kayitlar.insert(0, {
          'baslangic': startDateTime,
          'bitis': endDateTime,
          'sure': duration,
        });
        VeriYonetici.attachCreatorMetadataIfAbsent(kayitlar.first);

        await VeriYonetici.saveUykuKayitlari(kayitlar);
      });
      return;
    }

    if (selectedActivity == 'diaper') {
      await _runSaveAction(() async {
        final kayitlar = VeriYonetici.getKakaKayitlari();
        final diaperType = VeriYonetici.normalizeDiaperType(_diaperType);

        kayitlar.insert(0, {
          'tarih': _diaperDateTime,
          'tur': diaperType,
          'diaperType': diaperType,
          'eventType': VeriYonetici.diaperEventType,
          'notlar': _diaperNotesController.text,
        });
        VeriYonetici.attachCreatorMetadataIfAbsent(kayitlar.first);

        await VeriYonetici.saveKakaKayitlari(kayitlar);
      }, afterClose: _scheduleDiaperReminderIfEnabled);
    }
  }

  String _calculateSleepDuration() {
    if (_sleepEndDateTime == null) return '';
    final l10n = AppLocalizations.of(context)!;

    final startDateTime = _sleepStartDateTime;
    var endDateTime = _sleepEndDateTime!;

    if (_isSameDate(startDateTime, endDateTime) &&
        endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final duration = endDateTime.difference(startDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours ${l10n.hourAbbrev} $minutes ${l10n.minAbbrev}';
    } else {
      return '$minutes ${l10n.minAbbrev}';
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _SegmentOption {
  const _SegmentOption({required this.value, required this.label});

  final String value;
  final String label;
}
