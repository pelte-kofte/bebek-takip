import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/veri_yonetici.dart';
import '../l10n/app_localizations.dart';
import '../widgets/decorative_background.dart';

// Photo style enum for privacy-friendly sharing
enum PhotoStyle { original, softIllustration, pastelBlur }

/// Platform-aware image widget that works on both web and mobile
Widget buildPlatformImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  if (kIsWeb) {
    // On web, ImagePicker returns blob URLs that work with Image.network
    return Image.network(
      path,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  } else {
    // On mobile/desktop, use File
    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}

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

  String _formatDate(DateTime date, {bool includeYear = false}) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    if (includeYear || date.year != DateTime.now().year) {
      return '$day $month ${date.year}';
    }
    return '$day $month';
  }

  void _showMilestoneDetail(Map<String, dynamic> milestone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(
          milestone: milestone,
          onSaved: _loadMilestones,
          formatDate: _formatDate,
        ),
      ),
    );
  }

  void _showEditMilestoneSheet(Map<String, dynamic> milestone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EditMilestoneSheet(milestone: milestone, onSaved: _loadMilestones),
    );
  }

  void _shareMilestone(Map<String, dynamic> milestone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SharePreviewSheet(milestone: milestone, formatDate: _formatDate),
    );
  }

  Future<void> _deleteMilestone(Map<String, dynamic> milestone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete memory?',
          style: TextStyle(color: Color(0xFF4A3E39)),
        ),
        content: const Text(
          'This memory will be permanently deleted.',
          style: TextStyle(color: Color(0xFF4A3E39)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final milestones = VeriYonetici.getMilestones();
      milestones.removeWhere((m) => m['id'] == milestone['id']);
      await VeriYonetici.saveMilestones(milestones);
      _loadMilestones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecorativeBackground(
      preset: BackgroundPreset.home,
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
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.memories,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB4A2),
                      letterSpacing: -0.5,
                    ),
                  ),
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
        floatingActionButton: _milestones.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton.extended(
                  onPressed: _showAddMilestoneSheet,
                  backgroundColor: const Color(0xFFFFB4A2),
                  elevation: 8,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add Memory',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF4A3E39).withValues(alpha: 0.85);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF4A3E39).withValues(alpha: 0.5);

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
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(48),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 44,
                  color: Color(0xFFFFB4A2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Every moment is precious',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: titleColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'First smile, first steps...\nSave them before they fade',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: _showAddMilestoneSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB4A2),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB4A2).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Add Memory',
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline icon or photo thumbnail
          GestureDetector(
            onTap: () => _showMilestoneDetail(milestone),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0F7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB4A2).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: buildPlatformImage(
                        milestone['photoPath'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.star,
                                color: Color(0xFFFFB4A2),
                                size: 28,
                              ),
                            ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.star,
                        color: Color(0xFFFFB4A2),
                        size: 28,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          // Card content
          Expanded(
            child: GestureDetector(
              onTap: () => _showMilestoneDetail(milestone),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
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
                                  color: const Color(
                                    0xFF4A3E39,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Overflow menu
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              size: 18,
                              color: const Color(0xFF4A3E39).withValues(alpha: 0.4),
                            ),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: const Color(0xFFFFFBF5),
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _showEditMilestoneSheet(milestone);
                                case 'share':
                                  _shareMilestone(milestone);
                                case 'delete':
                                  _deleteMilestone(milestone);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4A3E39)),
                                    SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.edit, style: TextStyle(color: Color(0xFF4A3E39))),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'share',
                                child: Row(
                                  children: [
                                    Icon(Icons.share_outlined, size: 18, color: Color(0xFF4A3E39)),
                                    SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.share, style: TextStyle(color: Color(0xFF4A3E39))),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF6B6B)),
                                    SizedBox(width: 10),
                                    Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Color(0xFFFF6B6B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (milestone['note'] != null &&
                        (milestone['note'] as String).isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        milestone['note'],
                        maxLines: 1,
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
  final ImagePicker _imagePicker = ImagePicker();
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

  Future<void> _pickPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      // Offer optional cropping (skip on web as image_cropper doesn't support it)
      if (!kIsWeb) {
        final croppedFile = await _cropImage(image.path);
        setState(() => _photoPath = croppedFile ?? image.path);
      } else {
        setState(() => _photoPath = image.path);
      }
    }
  }

  Future<String?> _cropImage(String sourcePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Kırp',
          toolbarColor: const Color(0xFFFFB4A2),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFFFB4A2),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Kırp',
          doneButtonTitle: 'Tamam',
          cancelButtonTitle: 'İptal',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    return croppedFile?.path;
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
                        'Add Memory',
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
                              onTap: _pickPhoto,
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
                                          child: buildPlatformImage(
                                            _photoPath!,
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
                                  onTap: _pickPhoto,
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
                        // Memory title
                        Text(
                          'Title',
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
                            hintText: AppLocalizations.of(context)!.memoryTitleHint,
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
                            hintText: AppLocalizations.of(context)!.memoryNoteHint,
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
                      'Save Memory',
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

// Edit Milestone Bottom Sheet
class EditMilestoneSheet extends StatefulWidget {
  final Map<String, dynamic> milestone;
  final VoidCallback onSaved;

  const EditMilestoneSheet({
    super.key,
    required this.milestone,
    required this.onSaved,
  });

  @override
  State<EditMilestoneSheet> createState() => _EditMilestoneSheetState();
}

class _EditMilestoneSheetState extends State<EditMilestoneSheet> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  String? _photoPath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.milestone['title'] ?? '',
    );
    _noteController = TextEditingController(
      text: widget.milestone['note'] ?? '',
    );
    _selectedDate = widget.milestone['date'] as DateTime;
    _photoPath = widget.milestone['photoPath'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      // Offer optional cropping (skip on web)
      if (!kIsWeb) {
        final croppedFile = await _cropImage(image.path);
        setState(() => _photoPath = croppedFile ?? image.path);
      } else {
        setState(() => _photoPath = image.path);
      }
    }
  }

  Future<String?> _cropImage(String sourcePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Kırp',
          toolbarColor: const Color(0xFFFFB4A2),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFFFB4A2),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Kırp',
          doneButtonTitle: 'Tamam',
          cancelButtonTitle: 'İptal',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    return croppedFile?.path;
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
    final index = milestones.indexWhere(
      (m) => m['id'] == widget.milestone['id'],
    );

    if (index != -1) {
      milestones[index] = {
        ...widget.milestone,
        'title': _titleController.text,
        'date': _selectedDate,
        'note': _noteController.text,
        'photoPath': _photoPath,
      };
      await VeriYonetici.saveMilestones(milestones);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteMilestone() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete memory?',
          style: TextStyle(color: Color(0xFF4A3E39)),
        ),
        content: const Text(
          'This memory will be permanently deleted.',
          style: TextStyle(color: Color(0xFF4A3E39)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final milestones = VeriYonetici.getMilestones();
      milestones.removeWhere((m) => m['id'] == widget.milestone['id']);
      await VeriYonetici.saveMilestones(milestones);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatDateDisplay(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final hasPhoto = _photoPath != null && _photoPath!.isNotEmpty;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E0F7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ),
                ),
                const Text(
                  'Edit Memory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3E39),
                  ),
                ),
                GestureDetector(
                  onTap: _deleteMilestone,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFFF6B6B),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo section
                  if (hasPhoto)
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFE5E0F7,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: buildPlatformImage(
                                _photoPath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: const Color(0xFFE5E0F7),
                                      child: const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Color(0xFF4A3E39),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                        ),
                        // Replace photo button
                        Positioned(
                          bottom: 28,
                          right: 8,
                          child: GestureDetector(
                            onTap: _pickPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB4A2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        // Remove photo button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _photoPath = null);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Add photo button (when no photo)
                    GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE5E0F7),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fotoğraf Ekle',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Title field
                  Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.memoryTitleHint,
                      hintStyle: TextStyle(
                        color: const Color(0xFF4A3E39).withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A3E39),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Date picker
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDateDisplay(_selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4A3E39),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: const Color(
                              0xFF4A3E39,
                            ).withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Notes
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.memoryNoteHint,
                      hintStyle: TextStyle(
                        color: const Color(0xFF4A3E39).withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A3E39),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  GestureDetector(
                    onTap: _saveMilestone,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB4A2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Save Changes',
                        textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }
}

// Share Preview Bottom Sheet
class _SharePreviewSheet extends StatelessWidget {
  final Map<String, dynamic> milestone;
  final String Function(DateTime, {bool includeYear}) formatDate;

  const _SharePreviewSheet({required this.milestone, required this.formatDate});

  Future<void> _doShare() async {
    final title = milestone['title'] ?? '';
    final date = formatDate(milestone['date'] as DateTime, includeYear: true);
    final note = milestone['note'] ?? '';
    final photoPath = milestone['photoPath'];

    final text = '$title\n$date${note.isNotEmpty ? '\n\n$note' : ''}';

    if (photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync()) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(photoPath)], text: text),
      );
    } else {
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = milestone['title'] ?? '';
    final date = formatDate(milestone['date'] as DateTime);
    final photoPath = milestone['photoPath'];
    final hasPhoto =
        photoPath != null &&
        photoPath.isNotEmpty &&
        File(photoPath).existsSync();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E0F7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Preview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Photo or icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: hasPhoto
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: buildPlatformImage(
                            photoPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.star,
                              color: Color(0xFFFFB4A2),
                              size: 28,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.star,
                          color: Color(0xFFFFB4A2),
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                // Title and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3E39),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // AI Illustration placeholder (coming soon)
          Opacity(
            opacity: 0.5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE5E0F7),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '✨',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Turn this moment into an illustration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A3E39).withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coming soon',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFB4A2).withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4A3E39).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _doShare();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB4A2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Milestone Detail Screen
class MilestoneDetailScreen extends StatelessWidget {
  final Map<String, dynamic> milestone;
  final VoidCallback onSaved;
  final String Function(DateTime, {bool includeYear}) formatDate;

  const MilestoneDetailScreen({
    super.key,
    required this.milestone,
    required this.onSaved,
    required this.formatDate,
  });

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditMilestoneSheet(
        milestone: milestone,
        onSaved: () {
          onSaved();
          // Refresh the detail screen by popping and re-pushing
          Navigator.pop(context);
        },
      ),
    );
  }

  void _shareMilestone(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SharePreviewSheet(
        milestone: milestone,
        formatDate: formatDate,
      ),
    );
  }

  Future<void> _deleteMemory(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete memory?',
          style: TextStyle(color: Color(0xFF4A3E39)),
        ),
        content: const Text(
          'This memory will be permanently deleted.',
          style: TextStyle(color: Color(0xFF4A3E39)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final milestones = VeriYonetici.getMilestones();
      milestones.removeWhere((m) => m['id'] == milestone['id']);
      await VeriYonetici.saveMilestones(milestones);
      onSaved();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = milestone['photoPath'] != null &&
        (milestone['photoPath'] as String).isNotEmpty;
    final title = milestone['title'] ?? '';
    final date = milestone['date'] as DateTime;
    final note = milestone['note'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB4A2).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: IgnorePointer(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E0F7).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
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
                          child: Icon(
                            Icons.arrow_back,
                            color: const Color(0xFF4A3E39).withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Actions menu
                      PopupMenuButton<String>(
                        icon: Container(
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
                          child: Icon(
                            Icons.more_horiz,
                            color: const Color(0xFF4A3E39).withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: const Color(0xFFFFFBF5),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditSheet(context);
                            case 'share':
                              _shareMilestone(context);
                            case 'delete':
                              _deleteMemory(context);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: Color(0xFF4A3E39)),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.edit, style: TextStyle(color: Color(0xFF4A3E39))),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share_outlined, size: 18, color: Color(0xFF4A3E39)),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.share, style: TextStyle(color: Color(0xFF4A3E39))),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF6B6B)),
                                SizedBox(width: 10),
                                Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Color(0xFFFF6B6B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo (full-width, not cropped)
                        if (hasPhoto) ...[
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: buildPlatformImage(
                                milestone['photoPath'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 200,
                                      color: const Color(0xFFE5E0F7).withValues(alpha: 0.3),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Color(0xFF4A3E39),
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A3E39),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatDate(date, includeYear: true),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        // Notes
                        if (note.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE5E0F7).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: const Color(0xFF4A3E39).withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ],
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
}
