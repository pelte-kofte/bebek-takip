import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoDatePicker, CupertinoDatePickerMode, CupertinoTimerPicker, CupertinoTimerPickerMode;
import '../models/veri_yonetici.dart';
import '../models/dil.dart';
import '../l10n/app_localizations.dart';
import '../services/reminder_service.dart';
import '../theme/app_theme.dart';

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
  late TimeOfDay _sleepStartTime;
  TimeOfDay? _sleepEndTime;

  // Diaper fields
  String _diaperType = 'both'; // 'wet', 'dirty', or 'both'
  late TimeOfDay _diaperTime;
  final TextEditingController _diaperNotesController = TextEditingController();

  // Validation error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.initialActivity ?? 'breastfeeding';
    _sleepStartTime = TimeOfDay.now();
    _diaperTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _diaperNotesController.dispose();
    _solidFoodController.dispose();
    super.dispose();
  }

  Future<void> _scheduleFeedingReminderIfEnabled() async {
    if (!VeriYonetici.isFeedingReminderEnabled()) return;
    final reminderService = ReminderService();
    await reminderService.initialize();
    await reminderService.scheduleFeedingReminder(
      lastFeedingTime: DateTime.now(),
      intervalMinutes: VeriYonetici.getFeedingReminderInterval(),
    );
  }

  Future<void> _scheduleDiaperReminderIfEnabled() async {
    if (!VeriYonetici.isDiaperReminderEnabled()) return;
    final reminderService = ReminderService();
    await reminderService.initialize();
    await reminderService.scheduleDiaperReminder(
      lastDiaperTime: DateTime.now(),
      intervalMinutes: VeriYonetici.getDiaperReminderInterval(),
    );
  }

  /// Shows a Cupertino-style time picker in a bottom sheet
  Future<TimeOfDay?> _showCupertinoTimePicker(TimeOfDay initialTime) async {
    TimeOfDay selectedTime = initialTime;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkCard : AppColors.bgLightCard,
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
            // Header with Done button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      Dil.iptal,
                      style: TextStyle(
                        color: const Color(0xFF866F65),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedTime),
                    child: Text(
                      Dil.tamam,
                      style: TextStyle(
                        color: const Color(0xFFFF998A),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cupertino Time Picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                maximumDate: DateTime.now(),
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
          ],
        ),
      ),
    );

    return result;
  }

  /// Shows a Cupertino-style duration picker (hours + minutes) in a bottom sheet
  Future<Duration?> _showCupertinoDurationPicker(Duration initialDuration) async {
    Duration selectedDuration = initialDuration;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showModalBottomSheet<Duration>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkCard : AppColors.bgLightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      Dil.iptal,
                      style: TextStyle(
                        color: const Color(0xFF866F65),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedDuration),
                    child: Text(
                      Dil.tamam,
                      style: TextStyle(
                        color: const Color(0xFFFF998A),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: initialDuration,
                onTimerDurationChanged: (Duration duration) {
                  selectedDuration = duration;
                },
              ),
            ),
          ],
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

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.95),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Decorative background blobs - top-right corner
          Positioned(
            top: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF998A).withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Decorative background blobs - bottom-left corner
          Positioned(
            bottom: -150,
            left: -150,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E0F7).withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surfaceColor,
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
                            Icons.close,
                            color: isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.addActivity,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D1A18),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.whatHappened,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Compact activity type row
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildCompactActivityChip(
                            'breastfeeding',
                            const Icon(Icons.child_care_outlined, size: 24, color: Color(0xFFFF998A)),
                            l10n.nursing,
                          ),
                          const SizedBox(width: 6),
                          _buildCompactActivityChip(
                            'bottle',
                            const Icon(Icons.local_drink_outlined, size: 24, color: Color(0xFFFF998A)),
                            l10n.bottle,
                          ),
                          const SizedBox(width: 6),
                          _buildCompactActivityChip(
                            'sleep',
                            const Icon(Icons.bedtime_outlined, size: 24, color: Color(0xFFFF998A)),
                            l10n.sleep,
                          ),
                          const SizedBox(width: 6),
                          _buildCompactActivityChip(
                            'diaper',
                            const Icon(Icons.baby_changing_station_outlined, size: 24, color: Color(0xFFFF998A)),
                            l10n.diaper,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Detail panel - warmer card design
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 0,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.bgDarkSurface : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E0F7).withValues(alpha: 0.5),
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedActivity == 'breastfeeding') ...[
                              // Compact side selector
                              Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Row(
                                    children: [
                                      Text(
                                        l10n.side,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF7A749E),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: surfaceColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () => setState(
                                                () => selectedSide = 'left',
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: selectedSide == 'left'
                                                      ? const Color(0xFFFF998A)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  l10n.left,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: selectedSide == 'left'
                                                        ? Colors.white
                                                        : isDark
                                                            ? Colors.white.withValues(alpha: 0.7)
                                                            : const Color(0xFF7A749E),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => setState(
                                                () => selectedSide = 'right',
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: selectedSide == 'right'
                                                      ? const Color(0xFFFF998A)
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  l10n.right,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: selectedSide == 'right'
                                                        ? Colors.white
                                                        : isDark
                                                            ? Colors.white.withValues(alpha: 0.7)
                                                            : const Color(0xFF7A749E),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Duration picker (Cupertino style)
                              Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.duration.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () async {
                                          final picked = await _showCupertinoDurationPicker(
                                            Duration(minutes: minutes),
                                          );
                                          if (picked != null) {
                                            setState(() => minutes = picked.inMinutes);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 14,
                                          ),
                                          decoration: BoxDecoration(
                                            color: surfaceColor,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: isDark ? null : const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF4EDF9),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.timer_outlined, size: 24, color: Color(0xFFFF998A)),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                minutes > 0 ? '$minutes ${l10n.minAbbrev}' : l10n.tapToSet,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: minutes > 0
                                                      ? (isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F))
                                                      : (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF7A749E)),
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.access_time,
                                                color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF7A749E),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                            if (selectedActivity == 'bottle') ...[
                              // Category selector (Milk/Solid)
                              Text(
                                'CATEGORY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: surfaceColor.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => feedingCategory = 'Milk'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: feedingCategory == 'Milk' ? surfaceColor : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: feedingCategory == 'Milk'
                                                ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                                                : [],
                                          ),
                                          child: Text(
                                            'Milk',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: feedingCategory == 'Milk'
                                                  ? const Color(0xFFFF998A)
                                                  : isDark
                                                      ? Colors.white.withValues(alpha: 0.7)
                                                      : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => feedingCategory = 'Solid'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: feedingCategory == 'Solid' ? surfaceColor : Colors.transparent,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: feedingCategory == 'Solid'
                                                ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                                                : [],
                                          ),
                                          child: Text(
                                            'Solid',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: feedingCategory == 'Solid'
                                                  ? const Color(0xFFFF998A)
                                                  : isDark
                                                      ? Colors.white.withValues(alpha: 0.7)
                                                      : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Show different content based on category
                              if (feedingCategory == 'Solid') ...[
                                // Solid food description
                                Text(
                                  'NE VERİLDİ?',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Material(
                                  color: isDark ? AppColors.bgDarkCard : const Color(0xFFFDFCFB),
                                  borderRadius: BorderRadius.circular(24),
                                  child: TextField(
                                    controller: _solidFoodController,
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: 'Ör: Muz püresi, havuç...',
                                      hintStyle: TextStyle(
                                        color: isDark ? Colors.white.withValues(alpha: 0.3) : const Color(0xFF4A3F3F).withValues(alpha: 0.3),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(20),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF4A3F3F).withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ] else ...[
                              // Amount section (for Milk)
                              Center(
                                child: Text(
                                  'AMOUNT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Amount display with icon and +/- buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Minus button
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      if (bottleAmount >= 10) {
                                        bottleAmount -= 10;
                                      }
                                    }),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.remove,
                                          color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF7A749E),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Bottle icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: surfaceColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.local_drink_outlined, size: 28, color: Color(0xFFFF998A)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Amount value
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        bottleAmount.toString(),
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ml',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white.withValues(alpha: 0.4)
                                              : const Color(0xFF4A3F3F).withValues(alpha: 0.4),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Plus button
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      bottleAmount += 10;
                                    }),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Color(0xFFFF998A),
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Milk type selector
                              Text(
                                'MILK TYPE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: surfaceColor.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () =>
                                            setState(() => milkType = 'breast'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: milkType == 'breast'
                                                ? surfaceColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: milkType == 'breast'
                                                ? const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Text(
                                            'Breast milk',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: milkType == 'breast'
                                                  ? const Color(0xFFFF998A)
                                                  : isDark
                                                      ? Colors.white.withValues(alpha: 0.7)
                                                      : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(
                                          () => milkType = 'formula',
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: milkType == 'formula'
                                                ? surfaceColor
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: milkType == 'formula'
                                                ? const [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Text(
                                            'Formula',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: milkType == 'formula'
                                                  ? const Color(0xFFFF998A)
                                                  : isDark
                                                      ? Colors.white.withValues(alpha: 0.7)
                                                      : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ], // end of else (Milk category)
                            ],
                            if (selectedActivity == 'sleep') ...[
                              // Sleep started at
                              Text(
                                'SLEEP STARTED AT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await _showCupertinoTimePicker(_sleepStartTime);
                                  if (picked != null) {
                                    setState(() => _sleepStartTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isDark ? null : const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF4EDF9),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.bedtime_outlined, size: 24, color: Color(0xFFFF998A)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '${_sleepStartTime.hour.toString().padLeft(2, '0')}:${_sleepStartTime.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.access_time,
                                        color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF7A749E),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Woke up at
                              Text(
                                'WOKE UP AT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await _showCupertinoTimePicker(
                                    _sleepEndTime ?? TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _sleepEndTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isDark ? null : const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF4EDF9),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.wb_sunny_outlined,
                                            color: Color(0xFFFF998A),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _sleepEndTime != null
                                            ? '${_sleepEndTime!.hour.toString().padLeft(2, '0')}:${_sleepEndTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Tap to set',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: _sleepEndTime != null
                                              ? (isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F))
                                              : (isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF7A749E)),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.access_time,
                                        color: isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF7A749E),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Duration display (calculated)
                              if (_sleepEndTime != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFF998A,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFF998A,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        color: Color(0xFFFF998A),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Total sleep: ${_calculateSleepDuration()}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                            if (selectedActivity == 'diaper') ...[
                              // Diaper type selector
                              Text(
                                'TYPE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Wet button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _diaperType = 'wet'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _diaperType == 'wet'
                                              ? const Color(0xFFFF998A)
                                              : surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: _diaperType == 'wet'
                                                ? const Color(0xFFFF998A)
                                                : isDark
                                                    ? Colors.white.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: _diaperType == 'wet'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF998A,
                                                    ).withValues(alpha: 0.2),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _diaperType == 'wet'
                                                    ? Colors.white.withValues(
                                                        alpha: 0.3,
                                                      )
                                                    : isDark
                                                        ? Colors.white.withValues(alpha: 0.08)
                                                        : const Color(0xFFF4EDF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.water_drop_outlined,
                                                  size: 24,
                                                  color: _diaperType == 'wet'
                                                      ? Colors.white
                                                      : isDark
                                                          ? Colors.white.withValues(alpha: 0.7)
                                                          : const Color(0xFF7A749E),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Wet',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _diaperType == 'wet'
                                                    ? Colors.white
                                                    : isDark
                                                        ? Colors.white.withValues(alpha: 0.7)
                                                        : const Color(
                                                            0xFF4A3F3F,
                                                          ).withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Dirty button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _diaperType = 'dirty'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _diaperType == 'dirty'
                                              ? const Color(0xFFFF998A)
                                              : surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: _diaperType == 'dirty'
                                                ? const Color(0xFFFF998A)
                                                : isDark
                                                    ? Colors.white.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: _diaperType == 'dirty'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF998A,
                                                    ).withValues(alpha: 0.2),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _diaperType == 'dirty'
                                                    ? Colors.white.withValues(
                                                        alpha: 0.3,
                                                      )
                                                    : isDark
                                                        ? Colors.white.withValues(alpha: 0.08)
                                                        : const Color(0xFFF4EDF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.cloud_outlined,
                                                  size: 24,
                                                  color: _diaperType == 'dirty'
                                                      ? Colors.white
                                                      : isDark
                                                          ? Colors.white.withValues(alpha: 0.7)
                                                          : const Color(0xFF7A749E),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Dirty',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _diaperType == 'dirty'
                                                    ? Colors.white
                                                    : isDark
                                                        ? Colors.white.withValues(alpha: 0.7)
                                                        : const Color(
                                                            0xFF4A3F3F,
                                                          ).withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Both button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => _diaperType = 'both'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _diaperType == 'both'
                                              ? const Color(0xFFFF998A)
                                              : surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: _diaperType == 'both'
                                                ? const Color(0xFFFF998A)
                                                : isDark
                                                    ? Colors.white.withValues(alpha: 0.15)
                                                    : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: _diaperType == 'both'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF998A,
                                                    ).withValues(alpha: 0.2),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: _diaperType == 'both'
                                                    ? Colors.white.withValues(
                                                        alpha: 0.3,
                                                      )
                                                    : isDark
                                                        ? Colors.white.withValues(alpha: 0.08)
                                                        : const Color(0xFFF4EDF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.baby_changing_station_outlined,
                                                  size: 24,
                                                  color: _diaperType == 'both'
                                                      ? Colors.white
                                                      : isDark
                                                          ? Colors.white.withValues(alpha: 0.7)
                                                          : const Color(0xFF7A749E),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Both',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: _diaperType == 'both'
                                                    ? Colors.white
                                                    : isDark
                                                        ? Colors.white.withValues(alpha: 0.7)
                                                        : const Color(
                                                            0xFF4A3F3F,
                                                          ).withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Time picker
                              Text(
                                'TIME',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await _showCupertinoTimePicker(_diaperTime);
                                  if (picked != null) {
                                    setState(() => _diaperTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isDark
                                        ? Border.all(color: Colors.white.withValues(alpha: 0.1))
                                        : null,
                                    boxShadow: isDark
                                        ? []
                                        : const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF4EDF9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.access_time, size: 24, color: Color(0xFFFF998A)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '${_diaperTime.hour.toString().padLeft(2, '0')}:${_diaperTime.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textPrimaryDark : const Color(0xFF4A3F3F),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.access_time,
                                        color: isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF7A749E),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Optional notes
                              Text(
                                'OPTIONAL NOTES',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Material(
                                color: isDark ? AppColors.bgDarkCard : const Color(0xFFFDFCFB),
                                borderRadius: BorderRadius.circular(24),
                                child: TextField(
                                  controller: _diaperNotesController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Add a note about the diaper change...',
                                    hintStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.3)
                                          : const Color(0xFF4A3F3F).withValues(alpha: 0.3),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(20),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF4A3F3F).withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                            // Inline validation error
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
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
                            // Save button - calm style
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _saveActivity,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF998A),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  'Save',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
        ],
      ),
    );
  }

  Widget _buildCompactActivityChip(String type, Widget icon, String label) {
    final isSelected = selectedActivity == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _clearError();
          setState(() => selectedActivity = type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF998A).withValues(alpha: 0.15)
                : (isDark ? AppColors.bgDarkCard : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF998A)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFFE5E0F7),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(opacity: isSelected ? 1.0 : (isDark ? 0.7 : 0.5), child: icon),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFFF998A)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF7A749E),
                ),
              ),
            ],
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

  void _saveActivity() async {
    // Validation: prevent saving activities with zero values
    if (selectedActivity == 'breastfeeding' && minutes == 0) {
      _showValidationError('Please set a duration');
      return;
    }
    if (selectedActivity == 'bottle' && feedingCategory == 'Milk' && bottleAmount == 0) {
      _showValidationError('Please set an amount');
      return;
    }
    if (selectedActivity == 'sleep') {
      if (_sleepEndTime == null) {
        _showValidationError('Please set wake up time');
        return;
      }
      // Check if duration would be 0
      final now = DateTime.now();
      final startDT = DateTime(now.year, now.month, now.day, _sleepStartTime.hour, _sleepStartTime.minute);
      var endDT = DateTime(now.year, now.month, now.day, _sleepEndTime!.hour, _sleepEndTime!.minute);
      if (endDT.isBefore(startDT)) endDT = endDT.add(const Duration(days: 1));
      if (endDT.difference(startDT).inMinutes == 0) {
        _showValidationError('Sleep duration must be greater than 0');
        return;
      }
    }

    if (selectedActivity == 'breastfeeding') {
      final kayitlar = VeriYonetici.getMamaKayitlari();
      final totalMinutes = minutes + (seconds / 60);

      kayitlar.insert(0, {
        'tarih': DateTime.now(),
        'tur': 'Anne Sütü',
        'solDakika': selectedSide == 'left' ? totalMinutes.round() : 0,
        'sagDakika': selectedSide == 'right' ? totalMinutes.round() : 0,
        'miktar': 0,
        'kategori': 'Milk',
      });

      await VeriYonetici.saveMamaKayitlari(kayitlar);
      await _scheduleFeedingReminderIfEnabled();
      widget.onSaved?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (selectedActivity == 'bottle') {
      final kayitlar = VeriYonetici.getMamaKayitlari();

      if (feedingCategory == 'Solid') {
        kayitlar.insert(0, {
          'tarih': DateTime.now(),
          'tur': 'Katı Gıda',
          'solDakika': 0,
          'sagDakika': 0,
          'miktar': 0,
          'kategori': 'Solid',
          'solidAciklama': _solidFoodController.text.isNotEmpty ? _solidFoodController.text : null,
        });
      } else {
        kayitlar.insert(0, {
          'tarih': DateTime.now(),
          'tur': milkType == 'breast' ? 'Anne Sütü (Biberon)' : 'Formül',
          'solDakika': 0,
          'sagDakika': 0,
          'miktar': bottleAmount,
          'kategori': 'Milk',
        });
      }

      await VeriYonetici.saveMamaKayitlari(kayitlar);
      await _scheduleFeedingReminderIfEnabled();
      widget.onSaved?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (selectedActivity == 'sleep') {
      if (_sleepEndTime == null) return;

      final now = DateTime.now();
      final startDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _sleepStartTime.hour,
        _sleepStartTime.minute,
      );
      var endDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _sleepEndTime!.hour,
        _sleepEndTime!.minute,
      );

      // If end time is before start time, assume it's the next day
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }

      final duration = endDateTime.difference(startDateTime);

      final kayitlar = VeriYonetici.getUykuKayitlari();
      kayitlar.insert(0, {
        'baslangic': startDateTime,
        'bitis': endDateTime,
        'sure': duration,
      });

      await VeriYonetici.saveUykuKayitlari(kayitlar);
      widget.onSaved?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (selectedActivity == 'diaper') {
      final kayitlar = VeriYonetici.getKakaKayitlari();

      // Convert English type to Turkish for consistency
      String turkceTur;
      switch (_diaperType) {
        case 'wet':
          turkceTur = Dil.islak;
          break;
        case 'dirty':
          turkceTur = Dil.kirli;
          break;
        default:
          turkceTur = Dil.ikisiBirden;
      }

      final now = DateTime.now();
      final diaperDateTime = DateTime(
        now.year, now.month, now.day,
        _diaperTime.hour, _diaperTime.minute,
      );

      kayitlar.insert(0, {
        'tarih': diaperDateTime,
        'tur': turkceTur,
        'notlar': _diaperNotesController.text,
      });

      await VeriYonetici.saveKakaKayitlari(kayitlar);
      await _scheduleDiaperReminderIfEnabled();
      widget.onSaved?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _calculateSleepDuration() {
    if (_sleepEndTime == null) return '';

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _sleepStartTime.hour,
      _sleepStartTime.minute,
    );
    var endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _sleepEndTime!.hour,
      _sleepEndTime!.minute,
    );

    // If end time is before start time, assume it's the next day
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final duration = endDateTime.difference(startDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
