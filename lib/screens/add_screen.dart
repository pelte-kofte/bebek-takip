import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../models/ikonlar.dart';

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

  // Growth form fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _headCircController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.initialActivity ?? 'breastfeeding';
    _sleepStartTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headCircController.dispose();
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
                const SizedBox(height: 12),
                // Activity type grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityCard(
                              type: 'breastfeeding',
                              icon: Ikonlar.breastfeeding(size: 54),
                              label: 'Breastfeeding',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityCard(
                              type: 'bottle',
                              icon: Ikonlar.bottle(size: 54),
                              label: 'Bottle',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityCard(
                              type: 'sleep',
                              icon: Ikonlar.sleep(size: 54),
                              label: 'Sleep',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActivityCard(
                              type: 'diaper',
                              icon: Ikonlar.diaperClean(size: 54),
                              label: 'Diaper',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Detail panel
                Flexible(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4EDF9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 32,
                          right: 32,
                          top: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedActivity == 'breastfeeding') ...[
                              // Side selector
                              const Text(
                                'Side',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => selectedSide = 'left'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedSide == 'left'
                                              ? const Color(0xFFFF998A)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: selectedSide == 'left'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF998A,
                                                    ).withValues(alpha: 0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          'Left',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: selectedSide == 'left'
                                                ? Colors.white
                                                : const Color(0xFF7A749E),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => selectedSide = 'right',
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selectedSide == 'right'
                                              ? const Color(0xFFFF998A)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: selectedSide == 'right'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF998A,
                                                    ).withValues(alpha: 0.3),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Text(
                                          'Right',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: selectedSide == 'right'
                                                ? Colors.white
                                                : const Color(0xFF7A749E),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Duration picker
                              const Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Minutes
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => minutes = (minutes + 1).clamp(
                                            0,
                                            59,
                                          ),
                                        ),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xFF7A749E),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 80,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              minutes.toString().padLeft(
                                                2,
                                                '0',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2D1A18),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Minutes',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF7A749E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => minutes = (minutes - 1).clamp(
                                            0,
                                            59,
                                          ),
                                        ),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Color(0xFF7A749E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  const Text(
                                    ':',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7A749E),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Seconds
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => seconds = (seconds + 1).clamp(
                                            0,
                                            59,
                                          ),
                                        ),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Color(0xFF7A749E),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 80,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              seconds.toString().padLeft(
                                                2,
                                                '0',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2D1A18),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Seconds',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF7A749E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => seconds = (seconds - 1).clamp(
                                            0,
                                            59,
                                          ),
                                        ),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.remove,
                                            color: Color(0xFF7A749E),
                                          ),
                                        ),
                                      ),
                                    ],
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
                                      if (bottleAmount >= 10) bottleAmount -= 10;
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
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
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
                                          color: const Color(0xFF4A3F3F).withValues(alpha: 0.4),
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
                                        onTap: () => setState(() => milkType = 'breast'),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                                          borderRadius: BorderRadius.circular(12),
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
                                    initialTime: _sleepEndTime ?? TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _sleepEndTime = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                                          borderRadius: BorderRadius.circular(12),
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
                                        _sleepEndTime?.format(context) ?? 'Tap to set',
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
                                    color: const Color(0xFFFF998A).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFF998A).withValues(alpha: 0.3),
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
                                      onTap: () => setState(() => _diaperType = 'wet'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _diaperType == 'wet'
                                              ? const Color(0xFFFF998A)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: _diaperType == 'wet'
                                                ? const Color(0xFFFF998A)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: _diaperType == 'wet'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFFF998A).withValues(alpha: 0.2),
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
                                                    ? Colors.white.withValues(alpha: 0.3)
                                                    : const Color(0xFFF4EDF9),
                                                borderRadius: BorderRadius.circular(8),
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
                                                    : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
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
                                      onTap: () => setState(() => _diaperType = 'dirty'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _diaperType == 'dirty'
                                              ? const Color(0xFFFF998A)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: _diaperType == 'dirty'
                                                ? const Color(0xFFFF998A)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: _diaperType == 'dirty'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFFF998A).withValues(alpha: 0.2),
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
                                                    ? Colors.white.withValues(alpha: 0.3)
                                                    : const Color(0xFFF4EDF9),
                                                borderRadius: BorderRadius.circular(8),
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
                                                    : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
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
                                      onTap: () => setState(() => _diaperType = 'both'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          color: _diaperType == 'both'
                                              ? const Color(0xFFFF998A)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(
                                            color: _diaperType == 'both'
                                                ? const Color(0xFFFF998A)
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: _diaperType == 'both'
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFFFF998A).withValues(alpha: 0.2),
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
                                                    ? Colors.white.withValues(alpha: 0.3)
                                                    : const Color(0xFFF4EDF9),
                                                borderRadius: BorderRadius.circular(8),
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
                                                    : const Color(0xFF4A3F3F).withValues(alpha: 0.6),
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
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDFCFB),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: TextField(
                                  controller: _diaperNotesController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText: 'Add a note about the diaper change...',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF4A3F3F).withValues(alpha: 0.3),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(20),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF4A3F3F).withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                            if (selectedActivity == 'growth') ...[
                              // Date selector
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null) {
                                    setState(() => _selectedDate = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF7A749E),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D1A18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Weight input
                              const Text(
                                'Weight (kg)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  hintText: 'e.g., 7.5',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7A749E),
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D1A18),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Height input
                              const Text(
                                'Height (cm)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _heightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  hintText: 'e.g., 68.5',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7A749E),
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D1A18),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Head circumference input
                              const Text(
                                'Head Circumference (cm) - Optional',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A749E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _headCircController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: InputDecoration(
                                  hintText: 'e.g., 42.0',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF7A749E),
                                    fontSize: 16,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D1A18),
                                ),
                              ),
                            ],
                            // Save button inside scrollable content
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _saveActivity,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF998A),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF998A,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Save Activity',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String type,
    required Widget icon,
    required String label,
  }) {
    final isSelected = selectedActivity == type;

    return GestureDetector(
      onTap: () => setState(() => selectedActivity = type),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF998A) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF998A).withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Icon and label
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFBF5)
                          : const Color(0xFFE5E0F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.4,
                      child: icon,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF2D1A18)
                          : const Color(0xFF7A749E).withValues(alpha: 0.4),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Check badge
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF998A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveActivity() async {
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

      kayitlar.insert(0, {
        'tarih': DateTime.now(),
        'tur': _diaperType,
        'notlar': _diaperNotesController.text,
      });

      await VeriYonetici.saveKakaKayitlari(kayitlar);
      widget.onSaved?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (selectedActivity == 'growth') {
      // Validate required fields
      if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
        return;
      }

      final kayitlar = VeriYonetici.getBoyKiloKayitlari();

      kayitlar.insert(0, {
        'tarih': _selectedDate,
        'boy':
            double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 0,
        'kilo':
            double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 0,
        'basCevresi':
            double.tryParse(_headCircController.text.replaceAll(',', '.')) ?? 0,
      });

      // Sort by date descending
      kayitlar.sort(
        (a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime),
      );

      await VeriYonetici.saveBoyKiloKayitlari(kayitlar);
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
