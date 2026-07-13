import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, kIsWeb, kProfileMode, setEquals;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/illustration_request.dart';
import '../models/veri_yonetici.dart';
import '../l10n/app_localizations.dart';
import '../services/illustration_request_service.dart';
import '../theme/app_theme.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/decorative_background.dart';
import '../widgets/illustration_upsell_sheet.dart';
import '../widgets/nilico_modal.dart';
import '../widgets/nilico_motion.dart';

/// Platform-aware image widget that works on both web and mobile
Widget buildPlatformImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  int? cacheWidth,
  int? cacheHeight,
  bool animateFirstFrame = false,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  final isNetwork = path.startsWith('http://') || path.startsWith('https://');
  final Widget image;
  if (kIsWeb || isNetwork) {
    // On web, ImagePicker returns blob URLs that work with Image.network
    image = Image.network(
      path,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      frameBuilder: animateFirstFrame ? _memoryImageFrameBuilder : null,
      errorBuilder: errorBuilder,
    );
  } else {
    // On mobile/desktop, use File
    image = Image.file(
      File(path),
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      frameBuilder: animateFirstFrame ? _memoryImageFrameBuilder : null,
      errorBuilder: errorBuilder,
    );
  }
  return image;
}

Widget _memoryImageFrameBuilder(
  BuildContext context,
  Widget child,
  int? frame,
  bool wasSynchronouslyLoaded,
) {
  if (wasSynchronouslyLoaded) return child;
  final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return Stack(
    fit: StackFit.expand,
    children: [
      const ColoredBox(color: Color(0xFFF3EEE9)),
      AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: child,
      ),
    ],
  );
}

String? resolveMilestonePhotoSource(Map<String, dynamic> milestone) {
  final localCandidates = [
    milestone['photoPath']?.toString().trim() ?? '',
    milestone['photoLocalPath']?.toString().trim() ?? '',
  ];
  for (final candidate in localCandidates) {
    if (candidate.isEmpty) continue;
    return candidate;
  }
  final remote = milestone['photoUrl']?.toString().trim() ?? '';
  if (remote.isNotEmpty) return remote;
  for (final candidate in localCandidates) {
    if (candidate.isNotEmpty) return candidate;
  }
  return null;
}

bool _shouldShowLocalOnlyMemoryPhotoNote() {
  final user = FirebaseAuth.instance.currentUser;
  return user == null || user.isAnonymous;
}

Future<String?> showMemoryIllustrationStyleSheet(BuildContext context) {
  return showNilicoModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _IllustrationStyleChooserSheet(),
  );
}

Future<bool> showMemoryDeleteConfirmation(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => NilicoDialog(
          title: Text(l10n.memoryDeleteTitle),
          content: Text(l10n.memoryDeleteMessage),
          actions: [
            NilicoDialogAction(
              onPressed: () => Navigator.pop(dialogContext, false),
              label: l10n.cancel,
            ),
            NilicoDialogAction(
              onPressed: () => Navigator.pop(dialogContext, true),
              label: l10n.delete,
              destructive: true,
            ),
          ],
        ),
      ) ??
      false;
}

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

enum _MemoryFilter { all, photos, illustrated }

class _MilestonesScreenState extends State<MilestonesScreen> {
  late List<Map<String, dynamic>> _milestones;
  _MemoryFilter _filter = _MemoryFilter.all;
  late final VoidCallback _dataListener;
  final IllustrationRequestService _illustrationRequestService =
      IllustrationRequestService();
  StreamSubscription<List<IllustrationRequest>>? _requestSubscription;
  Set<String> _generatingMemoryIds = const <String>{};

  @override
  void initState() {
    super.initState();
    final hydrationWatch = Stopwatch()..start();
    _milestones = VeriYonetici.getMilestones();
    if (kDebugMode) {
      debugPrint(
        '[MemoriesTiming] cached-list-available '
        '${hydrationWatch.elapsedMicroseconds / 1000}ms '
        'count=${_milestones.length}',
      );
    }
    _dataListener = () {
      if (mounted) _loadMilestones();
    };
    VeriYonetici.dataNotifier.addListener(_dataListener);
    _requestSubscription = _illustrationRequestService.watchMyRequests().listen(
      (requests) {
        if (!mounted) return;
        final generatingIds = requests
            .where(
              (request) =>
                  request.memoryId.isNotEmpty &&
                  request.resultImageUrl == null &&
                  (request.status == IllustrationRequestStatus.pending ||
                      request.status == IllustrationRequestStatus.processing),
            )
            .map((request) => request.memoryId)
            .toSet();
        if (setEquals(generatingIds, _generatingMemoryIds)) return;
        setState(() => _generatingMemoryIds = generatingIds);
      },
    );
  }

  @override
  void dispose() {
    VeriYonetici.dataNotifier.removeListener(_dataListener);
    _requestSubscription?.cancel();
    super.dispose();
  }

  void _loadMilestones() {
    final fresh = VeriYonetici.getMilestones();
    if (_sameMilestoneSnapshot(_milestones, fresh)) return;
    setState(() => _milestones = fresh);
  }

  bool _sameMilestoneSnapshot(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> fresh,
  ) {
    if (current.length != fresh.length) return false;
    for (var i = 0; i < current.length; i++) {
      final a = current[i];
      final b = fresh[i];
      if (a['id'] != b['id'] ||
          a['updatedAt'] != b['updatedAt'] ||
          a['title'] != b['title'] ||
          a['date'] != b['date'] ||
          a['note'] != b['note'] ||
          a['photoPath'] != b['photoPath'] ||
          a['photoUrl'] != b['photoUrl'] ||
          a['illustrationUrl'] != b['illustrationUrl']) {
        return false;
      }
    }
    return true;
  }

  void _showAddMilestoneSheet() {
    Navigator.push(
      context,
      buildNilicoPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddMilestoneScreen(onSaved: _loadMilestones),
      ),
    );
  }

  String _formatDate(DateTime date, {bool includeYear = false}) {
    if (includeYear || date.year != DateTime.now().year) {
      return formatLocalizedDate(context, date);
    }
    return MaterialLocalizations.of(context).formatShortMonthDay(date);
  }

  void _showMilestoneDetail(Map<String, dynamic> milestone) {
    Navigator.push(
      context,
      buildNilicoPageRoute(
        builder: (context) => MilestoneDetailScreen(
          milestone: milestone,
          onSaved: _loadMilestones,
          formatDate: _formatDate,
        ),
      ),
    );
  }

  void _showEditMilestoneSheet(Map<String, dynamic> milestone) {
    showNilicoModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EditMilestoneSheet(milestone: milestone, onSaved: _loadMilestones),
    );
  }

  void _shareMilestone(Map<String, dynamic> milestone) {
    showNilicoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SharePreviewSheet(milestone: milestone, formatDate: _formatDate),
    );
  }

  Future<void> _deleteMilestone(Map<String, dynamic> milestone) async {
    final confirm = await showMemoryDeleteConfirmation(context);

    if (confirm == true) {
      NilicoHaptics.trigger(NilicoHapticType.medium);
      final milestones = VeriYonetici.getMilestones();
      milestones.removeWhere((m) => m['id'] == milestone['id']);
      await VeriYonetici.saveMilestones(milestones);
      _loadMilestones();
    }
  }

  List<Map<String, dynamic>> get _filteredMilestones {
    switch (_filter) {
      case _MemoryFilter.all:
        return _milestones;
      case _MemoryFilter.photos:
        return _milestones.where((m) {
          final p = resolveMilestonePhotoSource(m);
          return p != null && p.isNotEmpty;
        }).toList();
      case _MemoryFilter.illustrated:
        return _milestones.where((m) {
          return (m['illustrationUrl'] ?? '').toString().trim().isNotEmpty;
        }).toList();
    }
  }

  Widget _buildFilterBar() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.controlFill.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderSoft.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildFilterSegment(
                l10n.memoriesFilterAll,
                _MemoryFilter.all,
              ),
            ),
            Expanded(
              child: _buildFilterSegment(
                l10n.memoriesFilterPhotos,
                _MemoryFilter.photos,
              ),
            ),
            Expanded(
              child: _buildFilterSegment(
                l10n.memoriesFilterIllustrated,
                _MemoryFilter.illustrated,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSegment(String label, _MemoryFilter filter) {
    final isSelected = _filter == filter;
    return NilicoPressable(
      onTap: () {
        if (!isSelected) {
          NilicoHaptics.trigger(NilicoHapticType.selection);
        }
        setState(() => _filter = filter);
      },
      child: AnimatedContainer(
        duration: NilicoMotion.chipDuration,
        curve: NilicoMotion.ease,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.controlActive.withValues(alpha: 0.98)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0D2F221C),
                    blurRadius: 5,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: NilicoMotion.chipDuration,
          curve: NilicoMotion.ease,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.78),
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _buildIllustrationBadge({
    required bool isReady,
    required bool isGenerating,
    bool onPhoto = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    if (!isReady && !isGenerating) return const SizedBox.shrink();

    final bgColor = isReady
        ? const Color(0xFFF5F0F8).withValues(alpha: onPhoto ? 0.92 : 1)
        : const Color(0xFFFFF3ED).withValues(alpha: onPhoto ? 0.92 : 1);
    final borderColor = isReady
        ? const Color(0xFF9C88CC).withValues(alpha: onPhoto ? 0.0 : 0.3)
        : const Color(0xFFFFB4A2).withValues(alpha: onPhoto ? 0.0 : 0.3);
    final textColor = isReady
        ? const Color(0xFF75688F)
        : const Color(0xFF9A675A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGenerating)
            SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: textColor,
              ),
            )
          else
            Icon(Icons.auto_awesome_rounded, size: 9, color: textColor),
          const SizedBox(width: 3),
          Text(
            isReady ? l10n.illustrationReady : l10n.illustrationGenerating,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(right: 24, bottom: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: const IllustrationCreditChip(),
                ),
              ),
              if (_milestones.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildFilterBar(),
                const SizedBox(height: 8),
              ],
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
            ? Semantics(
                button: true,
                label: AppLocalizations.of(context)!.addMemory,
                child: NilicoPressable(
                  onTap: _showAddMilestoneSheet,
                  haptic: NilicoHapticType.selection,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x122F221C),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 18),
                        const SizedBox(width: 7),
                        Text(
                          AppLocalizations.of(context)!.addMemory,
                          style: AppTypography.button().copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E0F7).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 30,
                  color: Color(0xFFFFB4A2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              AppLocalizations.of(context)!.memoriesEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTypography.h2(
                context,
              ).copyWith(fontSize: 20, color: titleColor, height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.memoriesEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.body(
                context,
              ).copyWith(fontSize: 14, color: subtitleColor, height: 1.5),
            ),
            const SizedBox(height: 28),
            NilicoPressable(
              onTap: _showAddMilestoneSheet,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB4A2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppLocalizations.of(context)!.addFirstMemory,
                  style: AppTypography.button().copyWith(
                    fontSize: 14,
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
    final filtered = _filteredMilestones;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Text(
            AppLocalizations.of(context)!.memoriesEmptyFilter,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF4A3E39).withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _gridColumnCount(constraints.maxWidth);
        final tileWidth =
            (constraints.maxWidth - 48 - (crossAxisCount - 1) * 12) /
            crossAxisCount;
        final thumbnailPixels =
            (tileWidth * MediaQuery.devicePixelRatioOf(context)).ceil().clamp(
              240,
              900,
            );
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 104),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: _gridChildAspectRatio(crossAxisCount),
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildMilestoneCard(
            filtered[index],
            thumbnailPixels: thumbnailPixels,
          ),
        );
      },
    );
  }

  int _gridColumnCount(double width) {
    return width < 300 ? 1 : 2;
  }

  double _gridChildAspectRatio(int crossAxisCount) {
    if (crossAxisCount == 1) return 1.35;
    return _filter == _MemoryFilter.photos ? 0.82 : 0.76;
  }

  Widget _buildMilestoneCard(
    Map<String, dynamic> milestone, {
    required int thumbnailPixels,
  }) {
    final photoSource = resolveMilestonePhotoSource(milestone);
    final hasPhoto = photoSource != null && photoSource.isNotEmpty;
    final illustrationUrl = (milestone['illustrationUrl'] ?? '')
        .toString()
        .trim();
    final hasIllustration = illustrationUrl.isNotEmpty;
    final memoryId = (milestone['id'] ?? '').toString();
    final isGenerating =
        !hasIllustration &&
        memoryId.isNotEmpty &&
        _generatingMemoryIds.contains(memoryId);
    final title = (milestone['title'] ?? '').toString();
    final date = _formatDate(milestone['date'] as DateTime);

    return NilicoPressable(
      onTap: () => _showMilestoneDetail(milestone),
      haptic: NilicoHapticType.selection,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderSoft.withValues(alpha: 0.62),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A2F221C),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasPhoto)
                      Hero(
                        tag: 'memory-image-${milestone['id']}',
                        child: buildPlatformImage(
                          photoSource,
                          fit: BoxFit.cover,
                          cacheWidth: thumbnailPixels,
                          cacheHeight: thumbnailPixels,
                          animateFirstFrame: true,
                          errorBuilder: (context, error, stackTrace) {
                            final remote = (milestone['photoUrl'] ?? '')
                                .toString()
                                .trim();
                            if (remote.isNotEmpty && remote != photoSource) {
                              return buildPlatformImage(
                                remote,
                                fit: BoxFit.cover,
                                cacheWidth: thumbnailPixels,
                                cacheHeight: thumbnailPixels,
                                animateFirstFrame: true,
                              );
                            }
                            return const ColoredBox(
                              color: Color(0xFFF3EEE9),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Color(0xFF9A8F88),
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      ColoredBox(
                        color: const Color(0xFFFFF7F1),
                        child: Center(
                          child: Icon(
                            Icons.photo_library_outlined,
                            size: 26,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    if (hasIllustration || isGenerating)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _buildIllustrationBadge(
                          isReady: hasIllustration,
                          isGenerating: isGenerating,
                          onPhoto: hasPhoto,
                        ),
                      ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildMemoryMenu(milestone, hasPhoto: hasPhoto),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.paper,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.compactTitle(context).copyWith(
                        fontSize: 13,
                        height: 1.22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(context).copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryMenu(
    Map<String, dynamic> milestone, {
    required bool hasPhoto,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 44,
      height: 44,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: hasPhoto
                ? AppColors.paper.withValues(alpha: 0.82)
                : AppColors.paper.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            Icons.more_horiz,
            size: 16,
            color: AppColors.textPrimary.withValues(alpha: 0.58),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: AppColors.paper,
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
          _memoryMenuItem('edit', Icons.edit_outlined, l10n.edit),
          _memoryMenuItem('share', Icons.share_outlined, l10n.share),
          _memoryMenuItem(
            'delete',
            Icons.delete_outline,
            l10n.delete,
            destructive: true,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _memoryMenuItem(
    String value,
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    final color = destructive ? const Color(0xFFD45D5D) : AppColors.textPrimary;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTypography.body(
              context,
            ).copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: color),
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
  bool _isSaving = false;

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
    final l10n = AppLocalizations.of(context)!;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: l10n.cropPhoto,
          toolbarColor: const Color(0xFFFFB4A2),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFFFB4A2),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: l10n.cropPhoto,
          doneButtonTitle: l10n.ok,
          cancelButtonTitle: l10n.cancel,
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
    if (_isSaving) return;
    if (_titleController.text.isEmpty) return;

    final timing = Stopwatch()..start();
    final traceId = 'memory-add-${DateTime.now().microsecondsSinceEpoch}';
    if (kDebugMode || kProfileMode) {
      debugPrint(
        '[MemorySaveTrace] ts=${DateTime.now().toIso8601String()} '
        'id=$traceId event=save-button-tap total_us=0 mode=add',
      );
    }
    setState(() => _isSaving = true);
    try {
      final milestones = VeriYonetici.getMilestones();
      milestones.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'date': _selectedDate,
        'note': _noteController.text,
        'photoPath': _photoPath,
      });

      final modelSaveStep = Stopwatch()..start();
      await VeriYonetici.saveMilestones(milestones, traceId: traceId);
      if (kDebugMode || kProfileMode) {
        debugPrint(
          '[MemorySaveTrace] ts=${DateTime.now().toIso8601String()} '
          'id=$traceId event=await-model-save-end '
          'step_us=${modelSaveStep.elapsedMicroseconds} '
          'total_us=${timing.elapsedMicroseconds}',
        );
      }
      if (!mounted) return;
      widget.onSaved();
      if (kDebugMode) {
        debugPrint(
          '[MemoriesTiming] save-to-list-update '
          '${timing.elapsedMilliseconds}ms',
        );
      }
      NilicoHaptics.trigger(NilicoHapticType.success);

      if (mounted) {
        if (kDebugMode || kProfileMode) {
          debugPrint(
            '[MemorySaveTrace] ts=${DateTime.now().toIso8601String()} '
            'id=$traceId event=navigator-pop '
            'total_us=${timing.elapsedMicroseconds}',
          );
        }
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (kDebugMode) {
            debugPrint(
              '[MemoriesTiming] save-to-navigation-frame '
              '${timing.elapsedMilliseconds}ms',
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveFailedTryAgain),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: Stack(
        children: [
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
                      Semantics(
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.paperMuted,
                              borderRadius: BorderRadius.circular(14),
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
                      ),
                      // Title
                      Text(
                        l10n.addMemory,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A3E39),
                          letterSpacing: -0.5,
                        ),
                      ),
                      // Spacer for alignment
                      const SizedBox(width: 44),
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
                                aspectRatio: 4 / 3,
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.paperMuted,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.borderSoft,
                                    ),
                                  ),
                                  child: _photoPath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            19,
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
                                      borderRadius: BorderRadius.circular(14),
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
                        if (_shouldShowLocalOnlyMemoryPhotoNote()) ...[
                          Text(
                            l10n.memoryPhotosLocalOnly,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(
                                0xFF4A3E39,
                              ).withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ] else
                          const SizedBox(height: 20),
                        // Memory title
                        Text(
                          l10n.titleLabel,
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
                            hintText: AppLocalizations.of(
                              context,
                            )!.memoryTitleHint,
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
                          l10n.dateLabel,
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
                              border: Border.all(color: AppColors.borderSoft),
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
                          l10n.notes,
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
                            hintText: AppLocalizations.of(
                              context,
                            )!.memoryNoteHint,
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
          // Fixed bottom save button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                border: Border(top: BorderSide(color: AppColors.borderSoft)),
              ),
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  onTap: _isSaving ? null : _saveMilestone,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB4A2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Text(
                            l10n.saveMemory,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
          AppLocalizations.of(context)!.memoryPhotoPlaceholder,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
          ),
        ),
      ],
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
  bool _isSaving = false;

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
    final l10n = AppLocalizations.of(context)!;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: l10n.cropPhoto,
          toolbarColor: const Color(0xFFFFB4A2),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFFFFB4A2),
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: l10n.cropPhoto,
          doneButtonTitle: l10n.ok,
          cancelButtonTitle: l10n.cancel,
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
    if (_isSaving) return;
    if (_titleController.text.isEmpty) return;

    final timing = Stopwatch()..start();
    final traceId = 'memory-edit-${DateTime.now().microsecondsSinceEpoch}';
    if (kDebugMode || kProfileMode) {
      debugPrint(
        '[MemorySaveTrace] ts=${DateTime.now().toIso8601String()} '
        'id=$traceId event=save-button-tap total_us=0 mode=edit',
      );
    }
    setState(() => _isSaving = true);
    try {
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
        final modelSaveStep = Stopwatch()..start();
        await VeriYonetici.saveMilestones(milestones, traceId: traceId);
        if (kDebugMode || kProfileMode) {
          debugPrint(
            '[MemorySaveTrace] ts=${DateTime.now().toIso8601String()} '
            'id=$traceId event=await-model-save-end '
            'step_us=${modelSaveStep.elapsedMicroseconds} '
            'total_us=${timing.elapsedMicroseconds}',
          );
        }
      }

      if (!mounted) return;
      widget.onSaved();
      if (kDebugMode || kProfileMode) {
        debugPrint(
          '[MemorySaveTrace] ts=${DateTime.now().toIso8601String()} '
          'id=$traceId event=navigator-pop '
          'total_us=${timing.elapsedMicroseconds}',
        );
      }
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.saveFailedTryAgain),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteMilestone() async {
    final confirm = await showMemoryDeleteConfirmation(context);

    if (confirm == true) {
      final milestones = VeriYonetici.getMilestones();
      milestones.removeWhere((m) => m['id'] == widget.milestone['id']);
      await VeriYonetici.saveMilestones(milestones);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    }
  }

  String _formatDateDisplay(DateTime date) {
    return formatLocalizedDate(context, date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.paperMuted,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.close,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.6),
                      size: 18,
                    ),
                  ),
                ),
                Text(
                  l10n.editMemory,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3E39),
                  ),
                ),
                GestureDetector(
                  onTap: _deleteMilestone,
                  child: Container(
                    width: 44,
                    height: 44,
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
                            height: 180,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
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
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: const Color(
                                0xFF4A3E39,
                              ).withValues(alpha: 0.5),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.addPhoto,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(
                                  0xFF4A3E39,
                                ).withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_shouldShowLocalOnlyMemoryPhotoNote()) ...[
                    Text(
                      l10n.memoryPhotosLocalOnly,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4A3E39).withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Title field
                  Text(
                    l10n.titleLabel,
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
                    l10n.dateLabel,
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
                    l10n.notes,
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
                    onTap: _isSaving ? null : _saveMilestone,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB4A2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              l10n.update,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
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

  Future<void> _onIllustrationTap(BuildContext context) async {
    Navigator.pop(context); // close share sheet
    final style = await showMemoryIllustrationStyleSheet(context);
    if (style != null && context.mounted) {
      await IllustrationUpsellSheet.show(context, milestone, style: style);
    }
  }

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
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
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
                          fontWeight: FontWeight.w600,
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
          GestureDetector(
            onTap: () => _onIllustrationTap(context),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: Color(0xFF9C88CC),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.illTurnIntoIllustration,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.7),
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
                      AppLocalizations.of(context)!.cancel,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.share_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.share,
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
    showNilicoModalBottomSheet(
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
    showNilicoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SharePreviewSheet(milestone: milestone, formatDate: formatDate),
    );
  }

  Future<void> _deleteMemory(BuildContext context) async {
    final confirm = await showMemoryDeleteConfirmation(context);

    if (confirm == true) {
      NilicoHaptics.trigger(NilicoHapticType.medium);
      final milestones = VeriYonetici.getMilestones();
      milestones.removeWhere((m) => m['id'] == milestone['id']);
      await VeriYonetici.saveMilestones(milestones);
      onSaved();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : AppColors.paper;
    final surfaceColor = isDark ? AppColors.bgDarkCard : AppColors.paper;
    final mutedSurfaceColor = isDark
        ? AppColors.bgDarkSurface
        : AppColors.paperMuted;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimary;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.borderSoft;
    final photoSource = resolveMilestonePhotoSource(milestone);
    final hasPhoto = photoSource != null && photoSource.isNotEmpty;
    final title = milestone['title'] ?? '';
    final date = milestone['date'] as DateTime;
    final note = milestone['note'] ?? '';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: mutedSurfaceColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const IllustrationCreditChip(),
                      const SizedBox(width: 10),
                      // Actions menu
                      PopupMenuButton<String>(
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: mutedSurfaceColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            color: textSecondary,
                            size: 20,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: surfaceColor,
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
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: textPrimary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.edit,
                                  style: TextStyle(color: textPrimary),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.share_outlined,
                                  size: 18,
                                  color: textPrimary,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.share,
                                  style: TextStyle(color: textPrimary),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Color(0xFFFF6B6B),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: TextStyle(color: Color(0xFFFF6B6B)),
                                ),
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
                            constraints: const BoxConstraints(maxHeight: 400),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Hero(
                                tag: 'memory-image-${milestone['id']}',
                                child: buildPlatformImage(
                                  photoSource,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    final remote = (milestone['photoUrl'] ?? '')
                                        .toString()
                                        .trim();
                                    if (remote.isNotEmpty &&
                                        remote != photoSource) {
                                      return buildPlatformImage(
                                        remote,
                                        fit: BoxFit.cover,
                                        animateFirstFrame: true,
                                      );
                                    }
                                    return Container(
                                      height: 200,
                                      color: mutedSurfaceColor,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: textSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Title
                        Text(
                          title,
                          style: AppTypography.h1(
                            context,
                          ).copyWith(fontSize: 24, color: textPrimary),
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatDate(date, includeYear: true),
                              style: AppTypography.body(
                                context,
                              ).copyWith(fontSize: 15, color: textSecondary),
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
                              color: mutedSurfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              note,
                              style: AppTypography.body(context).copyWith(
                                fontSize: 16,
                                height: 1.6,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                        // Illustration section
                        _IllustrationSection(milestone: milestone),
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

/// Shows a generated illustration thumbnail + re-open button if one exists,
/// or the "Turn into illustration" prompt if not.
///
/// Stateful so it can react to [VeriYonetici.dataNotifier] firing after
/// [patchMilestoneIllustrationUrl] completes — the shallow-copied map
/// passed as [milestone] is NOT mutated in place, so a listener-driven
/// re-read from VeriYonetici is required.
class _IllustrationSection extends StatefulWidget {
  final Map<String, dynamic> milestone;

  const _IllustrationSection({required this.milestone});

  @override
  State<_IllustrationSection> createState() => _IllustrationSectionState();
}

class _IllustrationSectionState extends State<_IllustrationSection> {
  late Map<String, dynamic> _milestone;
  late final VoidCallback _dataListener;

  @override
  void initState() {
    super.initState();
    _milestone = widget.milestone;
    _dataListener = () {
      if (!mounted) return;
      final id = (_milestone['id'] ?? '').toString();
      if (id.isEmpty) return;
      final fresh = VeriYonetici.getMilestones()
          .where((m) => (m['id'] ?? '').toString() == id)
          .firstOrNull;
      if (fresh != null) setState(() => _milestone = fresh);
    };
    VeriYonetici.dataNotifier.addListener(_dataListener);
  }

  @override
  void dispose() {
    VeriYonetici.dataNotifier.removeListener(_dataListener);
    super.dispose();
  }

  Future<void> _showStyleChooser(BuildContext context) async {
    final style = await showMemoryIllustrationStyleSheet(context);
    if (style != null && context.mounted) {
      await IllustrationUpsellSheet.show(context, _milestone, style: style);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.bgDarkSurface
        : Colors.white.withValues(alpha: 0.8);
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE5E0F7);
    final illustrationUrl = (_milestone['illustrationUrl'] ?? '')
        .toString()
        .trim();
    final hasIllustration = illustrationUrl.isNotEmpty;

    if (hasIllustration) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: GestureDetector(
          onTap: () => IllustrationUpsellSheet.showResult(
            context,
            _milestone,
            illustrationUrl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.illustrationSectionTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  illustrationUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      color: surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFB4A2),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF9C88CC),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.illustrationTapToView,
                style: TextStyle(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // No illustration yet — show the generate prompt.
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GestureDetector(
        onTap: () => _showStyleChooser(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Color(0xFF9C88CC),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.illTurnIntoIllustration,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Style chooser bottom sheet
// ---------------------------------------------------------------------------

class _IllustrationStyleChooserSheet extends StatelessWidget {
  const _IllustrationStyleChooserSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
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
            const SizedBox(height: 20),
            // Nilico Style option
            _StyleOption(
              icon: Icons.auto_fix_high_rounded,
              iconColor: const Color(0xFFFFB4A2),
              label: l10n.illNilicoStyle,
              description: l10n.illStyleDefaultDescription,
              onTap: () => Navigator.pop(context, 'default'),
            ),
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: Color(0xFFE5E0F7),
            ),
            // Lo-Fi option
            _StyleOption(
              icon: Icons.brush_rounded,
              iconColor: const Color(0xFF9C88CC),
              label: l10n.illLofiIllustration,
              description: l10n.illStyleLofiDescription,
              onTap: () => Navigator.pop(context, 'lofi'),
            ),
            const SizedBox(height: 8),
            // Cancel
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E0F7).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    l10n.cancel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A3E39).withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyleOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _StyleOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A3E39),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF4A3E39).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: const Color(0xFF4A3E39).withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
