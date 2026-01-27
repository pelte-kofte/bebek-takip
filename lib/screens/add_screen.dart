import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/ikonlar.dart';
import '../models/dil.dart';

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

  // Sleep fields
  late TimeOfDay _sleepStartTime;
  TimeOfDay? _sleepEndTime;

  // Diaper fields
  String _diaperType = 'both'; // 'wet', 'dirty', or 'both'
  final TextEditingController _diaperNotesController = TextEditingController();

  // Validation error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.initialActivity ?? 'breastfeeding';
    _sleepStartTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _diaperNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.95),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F0),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF4A3F3F),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Activity',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1A18),
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'What happened?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7A749E),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Compact activity type row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildCompactActivityChip(
                        'breastfeeding',
                        Ikonlar.breastfeeding(size: 24),
                        'Nursing',
                      ),
                      const SizedBox(width: 6),
                      _buildCompactActivityChip(
                        'bottle',
                        Ikonlar.bottle(size: 24),
                        'Bottle',
                      ),
                      const SizedBox(width: 6),
                      _buildCompactActivityChip(
                        'sleep',
                        Ikonlar.sleep(size: 24),
                        'Sleep',
                      ),
                      const SizedBox(width: 6),
                      _buildCompactActivityChip(
                        'diaper',
                        Ikonlar.diaperClean(size: 24),
                        'Diaper',
                      ),
                    ],
                  ),
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
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(
                              0xFFE5E0F7,
                            ).withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFE5E0F7,
                              ).withValues(alpha: 0.3),
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
                              Row(
                                children: [
                                  const Text(
                                    'Side',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A749E),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                              'Left',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: selectedSide == 'left'
                                                    ? Colors.white
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
                                              'Right',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: selectedSide == 'right'
                                                    ? Colors.white
                                                    : const Color(0xFF7A749E),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Compact duration picker (minutes only)
                              Row(
                                children: [
                                  const Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A749E),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => minutes = (minutes - 1).clamp(
                                              0,
                                              60,
                                            ),
                                          ),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF4EDF9),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              color: Color(0xFF7A749E),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '$minutes min',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D1A18),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => minutes = (minutes + 1).clamp(
                                              0,
                                              60,
                                            ),
                                          ),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFF998A,
                                              ).withValues(alpha: 0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Color(0xFFFF998A),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (selectedActivity == 'bottle') ...[
                              // Amount section
                              const Center(
                                child: Text(
                                  'AMOUNT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A3F3F),
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
                                        color: Colors.white,
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
                                          Icons.remove,
                                          color: Color(0xFF7A749E),
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
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Ikonlar.bottle(size: 28),
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
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A3F3F),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ml',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(
                                            0xFF4A3F3F,
                                          ).withValues(alpha: 0.4),
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
                                        color: Colors.white,
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
                              const Text(
                                'MILK TYPE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
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
                                                ? Colors.white
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
                                                  : const Color(
                                                      0xFF4A3F3F,
                                                    ).withValues(alpha: 0.6),
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
                                                ? Colors.white
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
                                                  : const Color(
                                                      0xFF4A3F3F,
                                                    ).withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (selectedActivity == 'sleep') ...[
                              // Sleep started at
                              const Text(
                                'SLEEP STARTED AT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _sleepStartTime,
                                  );
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Ikonlar.sleep(size: 24),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _sleepStartTime.format(context),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A3F3F),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.access_time,
                                        color: Color(0xFF7A749E),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Woke up at
                              const Text(
                                'WOKE UP AT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime:
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
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
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
                                        _sleepEndTime?.format(context) ??
                                            'Tap to set',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: _sleepEndTime != null
                                              ? const Color(0xFF4A3F3F)
                                              : const Color(0xFF7A749E),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.access_time,
                                        color: Color(0xFF7A749E),
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
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A3F3F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                            if (selectedActivity == 'diaper') ...[
                              // Diaper type selector
                              const Text(
                                'TYPE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3F3F),
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
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: _diaperType == 'wet'
                                                ? const Color(0xFFFF998A)
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
                                                    : const Color(0xFFF4EDF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/icons/illustration/diaper_wet.png',
                                                  width: 24,
                                                  height: 24,
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
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: _diaperType == 'dirty'
                                                ? const Color(0xFFFF998A)
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
                                                    : const Color(0xFFF4EDF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/icons/illustration/diaper_dirty.png',
                                                  width: 24,
                                                  height: 24,
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
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: _diaperType == 'both'
                                                ? const Color(0xFFFF998A)
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
                                                    : const Color(0xFFF4EDF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/icons/illustration/diaper_clean.png',
                                                  width: 24,
                                                  height: 24,
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
                              // Optional notes
                              const Text(
                                'OPTIONAL NOTES',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A3F3F),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Material(
                                color: const Color(0xFFFDFCFB),
                                borderRadius: BorderRadius.circular(24),
                                child: TextField(
                                  controller: _diaperNotesController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Add a note about the diaper change...',
                                    hintStyle: TextStyle(
                                      color: const Color(
                                        0xFF4A3F3F,
                                      ).withValues(alpha: 0.3),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(20),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(
                                      0xFF4A3F3F,
                                    ).withValues(alpha: 0.8),
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
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFF998A)
                  : const Color(0xFFE5E0F7),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(opacity: isSelected ? 1.0 : 0.5, child: icon),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFFF998A)
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
    if (selectedActivity == 'bottle' && bottleAmount == 0) {
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
      });

      await VeriYonetici.saveMamaKayitlari(kayitlar);
      widget.onSaved?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (selectedActivity == 'bottle') {
      final kayitlar = VeriYonetici.getMamaKayitlari();

      kayitlar.insert(0, {
        'tarih': DateTime.now(),
        'tur': milkType == 'breast' ? 'Anne Sütü (Biberon)' : 'Formül',
        'solDakika': 0,
        'sagDakika': 0,
        'miktar': bottleAmount,
      });

      await VeriYonetici.saveMamaKayitlari(kayitlar);
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

      kayitlar.insert(0, {
        'tarih': DateTime.now(),
        'tur': turkceTur,
        'notlar': _diaperNotesController.text,
      });

      await VeriYonetici.saveKakaKayitlari(kayitlar);
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
