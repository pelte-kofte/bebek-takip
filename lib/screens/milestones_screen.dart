import 'dart:io';
import 'package:flutter/material.dart';
import '../models/veri_yonetici.dart';
import '../widgets/decorative_background.dart';

// Photo style enum for privacy-friendly sharing
enum PhotoStyle { original, softIllustration, pastelBlur }

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  List<Map<String, dynamic>> _milestones = [];

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  void _loadMilestones() {
    setState(() {
      _milestones = VeriYonetici.getMilestones();
      // Sort by date descending (most recent first)
      _milestones.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
      );
    });
  }

  void _showAddMilestoneSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddMilestoneScreen(onSaved: _loadMilestones),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      preset: BackgroundPreset.milestones,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Milestones',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB4A2),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E0F7).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF4A3E39),
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _milestones.isEmpty
                    ? _buildEmptyState()
                    : _buildMilestonesList(),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
            onPressed: _showAddMilestoneSheet,
            backgroundColor: const Color(0xFFFFB4A2),
            elevation: 8,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Milestone',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0F7),
                borderRadius: BorderRadius.circular(48),
              ),
              child: const Center(
                child: Icon(
                  Icons.star_outline,
                  size: 48,
                  color: Color(0xFF4A3E39),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No milestones yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A3E39),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture your baby\'s special moments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _showAddMilestoneSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB4A2),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'Add first milestone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesList() {
    return Stack(
      children: [
        // Timeline line
        Positioned(
          left: 24 + 24 - 1, // padding + half icon width - half line width
          top: 0,
          bottom: 120, // Space for FAB
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE5E0F7),
                  const Color(0xFFE5E0F7).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        // Milestone cards
        ListView.builder(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: 120,
          ),
          itemCount: _milestones.length,
          itemBuilder: (context, index) {
            final milestone = _milestones[index];
            return _buildMilestoneCard(milestone);
          },
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(Map<String, dynamic> milestone) {
    final hasPhoto =
        milestone['photoPath'] != null &&
        (milestone['photoPath'] as String).isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline icon or photo thumbnail
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E0F7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: hasPhoto
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(milestone['photoPath']),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.star,
                              color: Color(0xFF4A3E39),
                              size: 28,
                            ),
                          ),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.star, color: Color(0xFF4A3E39), size: 28),
                  ),
          ),
          const SizedBox(width: 16),
          // Card content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3E39),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(milestone['date'] as DateTime),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
                    ),
                  ),
                  if (milestone['note'] != null &&
                      (milestone['note'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      milestone['note'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF4A3E39).withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add Milestone Screen (Full Screen Modal)
class AddMilestoneScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const AddMilestoneScreen({super.key, required this.onSaved});

  @override
  State<AddMilestoneScreen> createState() => _AddMilestoneScreenState();
}

class _AddMilestoneScreenState extends State<AddMilestoneScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _photoPath;
  PhotoStyle _photoStyle =
      PhotoStyle.softIllustration; // Default: soft illustrated

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFB4A2),
              onPrimary: Colors.white,
              surface: Color(0xFFFFFBF5),
              onSurface: Color(0xFF4A3E39),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveMilestone() async {
    if (_titleController.text.isEmpty) return;

    final milestones = VeriYonetici.getMilestones();
    milestones.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _titleController.text,
      'date': _selectedDate,
      'note': _noteController.text,
      'photoPath': _photoPath,
      'photoStyle': _photoStyle.name,
    });

    await VeriYonetici.saveMilestones(milestones);
    widget.onSaved();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: Stack(
        children: [
          // Decorative blurred circles
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: IgnorePointer(
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: -MediaQuery.of(context).size.width * 0.15,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header - sticky
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  color: const Color(0xFFFFFBF5).withValues(alpha: 0.95),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color: const Color(
                              0xFF4A3E39,
                            ).withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      ),
                      // Title
                      const Text(
                        'Add Milestone',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3E39),
                          letterSpacing: -0.5,
                        ),
                      ),
                      // Spacer for alignment
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 140,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Photo upload area
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Photo picker would go here
                              },
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E0F7),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _photoPath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          child: Image.file(
                                            File(_photoPath!),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _buildPhotoPlaceholder(),
                                          ),
                                        )
                                      : _buildPhotoPlaceholder(),
                                ),
                              ),
                            ),
                            // Edit button (shown when photo exists)
                            if (_photoPath != null)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    // Edit photo action
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: const Color(
                                        0xFF4A3E39,
                                      ).withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Photo style selector (privacy-friendly)
                        Text(
                          'Photo style',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF4A3E39,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStyleOption(
                              PhotoStyle.original,
                              'Original',
                              Icons.photo,
                            ),
                            const SizedBox(width: 8),
                            _buildStyleOption(
                              PhotoStyle.softIllustration,
                              'Soft',
                              Icons.brush,
                            ),
                            const SizedBox(width: 8),
                            _buildStyleOption(
                              PhotoStyle.pastelBlur,
                              'Blur',
                              Icons.blur_on,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Milestone title
                        Text(
                          'Milestone title',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF4A3E39,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g. First Steps',
                            hintStyle: TextStyle(
                              color: const Color(
                                0xFF4A3E39,
                              ).withValues(alpha: 0.4),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A3E39),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Date picker
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF4A3E39,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _formatDateForInput(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4A3E39),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: const Color(
                                    0xFF4A3E39,
                                  ).withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Notes
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                              0xFF4A3E39,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Write down the memory...',
                            hintStyle: TextStyle(
                              color: const Color(
                                0xFF4A3E39,
                              ).withValues(alpha: 0.4),
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A3E39),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed bottom save button with gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFFBF5).withValues(alpha: 0),
                    const Color(0xFFFFFBF5),
                    const Color(0xFFFFFBF5),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  onTap: _saveMilestone,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB4A2),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Save Milestone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 48,
          color: const Color(0xFF4A3E39).withValues(alpha: 0.4),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a photo of the moment',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleOption(PhotoStyle style, String label, IconData icon) {
    final isSelected = _photoStyle == style;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _photoStyle = style),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFB4A2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB4A2).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF4A3E39).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF4A3E39).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
