import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/illustration_request.dart';
import '../models/user_illustration_credits.dart';
import '../models/veri_yonetici.dart';
import '../screens/premium_screen.dart';
import '../services/illustration_request_service.dart';
import '../services/premium_service.dart'
    show
        IllustrationPackPurchaseException,
        PremiumService;

// ---------------------------------------------------------------------------
// Sheet state machine
// ---------------------------------------------------------------------------

enum _SheetState { upsell, loading, result, error, outOfCredits }

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

class IllustrationUpsellSheet extends StatefulWidget {
  final Map<String, dynamic> memory;
  /// When non-null the sheet opens directly on the result view (re-open flow).
  final String? initialIllustrationUrl;

  const IllustrationUpsellSheet({
    super.key,
    required this.memory,
    this.initialIllustrationUrl,
  });

  /// Standard entry point — shows upsell/generation flow.
  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> memory,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IllustrationUpsellSheet(memory: memory),
    );
  }

  /// Re-open an already-generated illustration directly in the result view.
  static Future<void> showResult(
    BuildContext context,
    Map<String, dynamic> memory,
    String illustrationUrl,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IllustrationUpsellSheet(
        memory: memory,
        initialIllustrationUrl: illustrationUrl,
      ),
    );
  }

  @override
  State<IllustrationUpsellSheet> createState() =>
      _IllustrationUpsellSheetState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _IllustrationUpsellSheetState extends State<IllustrationUpsellSheet>
    with SingleTickerProviderStateMixin {
  // ---- entrance animation --------------------------------------------------
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  // ---- premium check -------------------------------------------------------
  // Resolved synchronously from PremiumService — no async loading needed.
  bool get _loadingCredits => false;
  bool get _isPremium => PremiumService.instance.isPremium;

  // ---- shared baby check ---------------------------------------------------
  // Illustration generation is restricted to the baby owner only.
  // Co-parents may view shared baby data but cannot generate illustrations.
  bool get _isSharedBaby {
    final babyId = (widget.memory['babyId'] ?? '').toString().trim();
    return babyId.isNotEmpty && VeriYonetici.isSharedBaby(babyId);
  }

  // ---- state machine -------------------------------------------------------
  late _SheetState _sheetState;
  // Holds the URL for both the newly-generated result and the re-open flow.
  String? _resultImageUrl;
  String? _errorMessage;
  StreamSubscription<IllustrationRequest?>? _requestSub;

  // ---- pack purchase -------------------------------------------------------
  /// Non-null while a pack purchase is in progress. Holds the product ID of
  /// the pack being purchased so each row can show its own loading state.
  String? _purchasingPackId;

  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    // If re-opening an existing illustration, jump straight to result view.
    if (widget.initialIllustrationUrl != null) {
      _sheetState = _SheetState.result;
      _resultImageUrl = widget.initialIllustrationUrl;
    } else {
      _sheetState = _SheetState.upsell;
    }
    _animCtrl.forward();
  }

  // ---- CTA handlers --------------------------------------------------------

  Future<void> _onCreateIllustration() async {
    // Hard guards — should never be reachable via normal UI, but defend anyway.
    if (_isSharedBaby || !_isPremium) return;

    // Re-read the memory at tap-time so we get the latest photoStoragePath,
    // which may have been populated by the background photo-upload task that
    // runs after saveMilestones().
    final memoryId = (widget.memory['id'] ?? '').toString().trim();
    Map<String, dynamic> freshMemory = widget.memory;
    if (memoryId.isNotEmpty) {
      final match = VeriYonetici.getMilestones()
          .where((m) => m['id'] == memoryId);
      if (match.isNotEmpty) freshMemory = match.first;
    }

    final storagePath =
        (freshMemory['photoStoragePath'] ?? '').toString().trim();
    if (storagePath.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your photo is still uploading. Please try again in a moment.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _sheetState = _SheetState.loading);

    try {
      final service = IllustrationRequestService();
      final request = await service.createMemoryIllustrationRequest(
        memory: freshMemory,
      );

      _requestSub = service.watchRequest(request.id).listen(
        (updated) {
          if (!mounted || updated == null) return;
          if (updated.status == IllustrationRequestStatus.completed &&
              updated.resultImageUrl != null) {
            _requestSub?.cancel();
            // Persist the URL back into the milestone record so it survives
            // sheet dismissal and can be re-opened from the detail screen.
            final memoryId = (widget.memory['id'] ?? '').toString().trim();
            if (memoryId.isNotEmpty) {
              VeriYonetici.patchMilestoneIllustrationUrl(
                memoryId,
                updated.resultImageUrl!,
              );
            }
            setState(() {
              _resultImageUrl = updated.resultImageUrl;
              _sheetState = _SheetState.result;
            });
          } else if (updated.status == IllustrationRequestStatus.failed) {
            _requestSub?.cancel();
            final isTimeout =
                updated.errorCode == 'generation-timeout' ||
                updated.errorCode == 'worker-deadline-exceeded' ||
                (updated.errorMessage?.toLowerCase().contains('timeout') ??
                    false) ||
                (updated.errorMessage?.toLowerCase().contains('timed out') ??
                    false);
            setState(() {
              _errorMessage = isTimeout
                  ? 'This photo took too long to generate.\n'
                      'Your credit has been refunded — please try again.'
                  : (updated.errorMessage?.isNotEmpty == true
                      ? updated.errorMessage
                      : 'Something went wrong. Please try again.');
              _sheetState = _SheetState.error;
            });
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _errorMessage =
                  'Could not connect to the illustration service. '
                  'Please try again later.';
              _sheetState = _SheetState.error;
            });
          }
        },
      );
    } on IllustrationCreditException {
      if (mounted) {
        setState(() => _sheetState = _SheetState.outOfCredits);
      }
    } on StateError catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _sheetState = _SheetState.error;
        });
      }
    } catch (e, stack) {
      debugPrint('[IllustrationUpsellSheet] Unexpected error: $e\n$stack');
      if (mounted) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
          _sheetState = _SheetState.error;
        });
      }
    }
  }

  Future<void> _onBuyPack(String productId) async {
    if (_purchasingPackId != null) return; // already in-flight
    setState(() => _purchasingPackId = productId);
    try {
      final success =
          await PremiumService.instance.purchaseIllustrationPack(productId);
      if (!mounted) return;
      if (success) {
        // Credits arrive asynchronously via Adapty webhook → Firestore.
        // Pop the sheet so the user retries generation once credits land.
        Navigator.pop(context);
      } else {
        // User explicitly cancelled the system purchase sheet — no feedback needed.
        setState(() => _purchasingPackId = null);
      }
    } on IllustrationPackPurchaseException catch (e) {
      if (!mounted) return;
      setState(() => _purchasingPackId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _purchasingPackId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase could not be completed. Please try again.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _onExplorePremium() async {
    if (!mounted) return;
    await PremiumScreen.show(context);
    // After returning, premium state may have changed. If the user just
    // purchased, _isPremium (from PremiumService) is already true — trigger
    // a rebuild so the button label and CTA update immediately.
    if (mounted) setState(() {});
  }

  Future<void> _shareIllustration() async {
    final url = _resultImageUrl;
    if (url == null) return;
    try {
      // Download the image to a temp file so the system share sheet can attach it.
      final response = await HttpClient().getUrl(Uri.parse(url));
      final result = await response.close();
      final bytes = await result.expand((b) => b).toList();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/illustration_share.jpg');
      await file.writeAsBytes(bytes);
      final title = (widget.memory['title'] ?? '').toString();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: title.isNotEmpty ? title : 'A special moment, illustrated.',
        ),
      );
    } catch (_) {
      // Fallback: share the URL as plain text if download fails.
      await SharePlus.instance.share(
        ShareParams(text: url),
      );
    }
  }

  void _resetToUpsell() {
    _requestSub?.cancel();
    setState(() {
      _sheetState = _SheetState.upsell;
      _errorMessage = null;
      _resultImageUrl = null;
    });
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  // ---- build ---------------------------------------------------------------

  Widget _buildCurrentState() {
    // Shared-baby gate: illustration generation is owner-only regardless of
    // premium status. Show a locked state before any other branch.
    if (_isSharedBaby && _sheetState == _SheetState.upsell) {
      return _LockedSharedBabyContent(
        key: const ValueKey('locked-shared'),
        onDismiss: () => Navigator.pop(context),
      );
    }

    switch (_sheetState) {
      case _SheetState.upsell:
        return _UpsellContent(
          key: const ValueKey('upsell'),
          loadingCredits: _loadingCredits,
          isPremium: _isPremium,
          onPrimary: _isPremium ? _onCreateIllustration : _onExplorePremium,
          onDismiss: () => Navigator.pop(context),
        );
      case _SheetState.loading:
        return _LoadingContent(
          key: const ValueKey('loading'),
          onDismiss: () => Navigator.pop(context),
        );
      case _SheetState.result:
        return _ResultContent(
          key: const ValueKey('result'),
          imageUrl: _resultImageUrl!,
          onShare: _shareIllustration,
          onClose: () => Navigator.pop(context),
        );
      case _SheetState.error:
        return _ErrorContent(
          key: const ValueKey('error'),
          message: _errorMessage ?? 'Something went wrong.',
          onRetry: _resetToUpsell,
          onClose: () => Navigator.pop(context),
        );
      case _SheetState.outOfCredits:
        return _OutOfCreditsContent(
          key: const ValueKey('out-of-credits'),
          purchasingPackId: _purchasingPackId,
          onBuyPack: _onBuyPack,
          onDismiss: () => Navigator.pop(context),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFBF5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x18FFB4A2),
                  blurRadius: 32,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (currentChild, previousChildren) => Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
                  child: _buildCurrentState(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State sub-widgets
// ---------------------------------------------------------------------------

class _UpsellContent extends StatelessWidget {
  final bool loadingCredits;
  final bool isPremium;
  final VoidCallback onPrimary;
  final VoidCallback onDismiss;

  const _UpsellContent({
    super.key,
    required this.loadingCredits,
    required this.isPremium,
    required this.onPrimary,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 24),
        _SparkleIcon(),
        const SizedBox(height: 24),
        Text(
          isPremium ? 'This memory feels special.' : 'Turn memories into art',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isPremium
              ? 'Turn it into a soft illustration and keep it forever.\n'
                  'Some memories deserve to be felt again.'
              : 'Transform your baby\'s photos into beautiful soft illustrations.\n'
                  'Available with Premium.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF8A7C75),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        _PrimaryButton(
          loading: loadingCredits,
          label: isPremium ? 'Create Illustration' : 'Upgrade to Premium',
          onPressed: onPrimary,
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onDismiss,
          child: const Text(
            'Maybe Later',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A7C75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  final VoidCallback onDismiss;

  const _LoadingContent({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 40),
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: Color(0xFFFFB4A2),
            strokeWidth: 2.5,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Creating your illustration…',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This usually takes about a minute.\nWe\'ll show it right here when it\'s ready.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8A7C75),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        TextButton(
          onPressed: onDismiss,
          child: const Text(
            'Dismiss — I\'ll check back later',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A7C75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultContent extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const _ResultContent({
    super.key,
    required this.imageUrl,
    required this.onShare,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            imageUrl,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 260,
                color: const Color(0xFFE5E0F7),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFB4A2),
                    strokeWidth: 2,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your illustration is ready.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'A soft memory, kept forever.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8A7C75),
          ),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          loading: false,
          label: 'Share with family \u{1F49B}',
          onPressed: onShare,
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onClose,
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A7C75)),
          ),
        ),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _ErrorContent({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 36),
        const Icon(
          Icons.error_outline_rounded,
          size: 44,
          color: Color(0xFFFFB4A2),
        ),
        const SizedBox(height: 16),
        const Text(
          'Something went wrong.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8A7C75),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(loading: false, label: 'Try Again', onPressed: onRetry),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onClose,
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A7C75)),
          ),
        ),
      ],
    );
  }
}

class _LockedSharedBabyContent extends StatelessWidget {
  final VoidCallback onDismiss;

  const _LockedSharedBabyContent({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 32,
            color: Color(0xFFBDB5B0),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Illustrations are owner-only',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Illustration generation is only available to the\n'
          'baby owner. Ask the owner to create one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8A7C75),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        _PrimaryButton(
          loading: false,
          label: 'Got it',
          onPressed: onDismiss,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Out-of-credits — illustration pack purchase
// ---------------------------------------------------------------------------

class _PackOption {
  final String productId;
  final String label;
  final String sublabel;
  final String price;
  final String? badge;
  final bool emphasized;

  const _PackOption({
    required this.productId,
    required this.label,
    required this.sublabel,
    required this.price,
    this.badge,
    this.emphasized = false,
  });
}

class _OutOfCreditsContent extends StatelessWidget {
  final String? purchasingPackId;
  final void Function(String productId) onBuyPack;
  final VoidCallback onDismiss;

  const _OutOfCreditsContent({
    super.key,
    required this.purchasingPackId,
    required this.onBuyPack,
    required this.onDismiss,
  });

  static const _packs = [
    _PackOption(
      productId: 'illustration_credits_3',
      label: 'Quick pack',
      sublabel: '3 illustrations',
      price: r'$1.99',
    ),
    _PackOption(
      productId: 'illustration_credits_10',
      label: 'Best value',
      sublabel: '10 illustrations',
      price: r'$4.99',
      badge: 'Most popular',
      emphasized: true,
    ),
    _PackOption(
      productId: 'illustration_credits_25',
      label: 'For memory lovers',
      sublabel: '25 illustrations',
      price: r'$9.99',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(),
        const SizedBox(height: 24),
        _SparkleIcon(),
        const SizedBox(height: 20),
        const Text(
          "You're out of illustrations",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3E39),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Turn your memories into beautiful artwork.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF8A7C75),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        for (final pack in _packs) ...[
          _PackTile(
            pack: pack,
            loading: purchasingPackId == pack.productId,
            disabled: purchasingPackId != null &&
                purchasingPackId != pack.productId,
            onTap: () => onBuyPack(pack.productId),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        TextButton(
          onPressed: purchasingPackId != null ? null : onDismiss,
          child: const Text(
            'Maybe later',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8A7C75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PackTile extends StatelessWidget {
  final _PackOption pack;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _PackTile({
    required this.pack,
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = pack.emphasized
        ? const Color(0xFF9C88CC)
        : const Color(0xFFE5E0F7);
    final labelColor = pack.emphasized
        ? Colors.white
        : const Color(0xFF4A3E39);
    final sublabelColor = pack.emphasized
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF8A7C75);
    final priceColor = pack.emphasized
        ? Colors.white
        : const Color(0xFF9C88CC);

    return Opacity(
      opacity: disabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTap: disabled || loading ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: pack.emphasized ? 20 : 16,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: pack.emphasized
                ? [
                    BoxShadow(
                      color: const Color(0xFF9C88CC).withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pack.label,
                          style: TextStyle(
                            fontSize: pack.emphasized ? 16 : 15,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                          ),
                        ),
                        if (pack.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pack.badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pack.sublabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: sublabelColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: pack.emphasized
                        ? Colors.white
                        : const Color(0xFF9C88CC),
                  ),
                )
              else
                Text(
                  pack.price,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: priceColor,
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
// Shared micro-widgets
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB4A2).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SparkleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E0F7),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C88CC).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        size: 34,
        color: Color(0xFF9C88CC),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 52,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFFB4A2),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB4A2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// IllustrationCreditChip — reusable credit indicator
// ---------------------------------------------------------------------------
//
// Usage (both HomeScreen and MilestoneDetailScreen):
//
//   const IllustrationCreditChip()
//
// Only renders when the user is premium. Shows:
//   • monthly remaining < total  → "✨ 2 / 3 this month"
//   • purchased credits only     → "✨ 5 illustrations left"
//   • zero credits               → same formats but in warning amber
//
// Listens to Firestore via IllustrationRequestService.watchMyCredits()
// so it updates automatically after a purchase or usage.

class IllustrationCreditChip extends StatefulWidget {
  const IllustrationCreditChip({super.key});

  @override
  State<IllustrationCreditChip> createState() => _IllustrationCreditChipState();
}

class _IllustrationCreditChipState extends State<IllustrationCreditChip> {
  final _service = IllustrationRequestService();

  @override
  Widget build(BuildContext context) {
    if (!PremiumService.instance.isPremium) return const SizedBox.shrink();

    return StreamBuilder<UserIllustrationCredits>(
      stream: _service.watchMyCredits(),
      builder: (context, snapshot) {
        final credits = snapshot.data;
        if (credits == null) return const SizedBox.shrink();

        final monthly = credits.monthlyRemaining;
        final purchased = credits.purchasedCreditsRemaining;
        final total = credits.monthlyRemaining + credits.purchasedCreditsRemaining;
        final isEmpty = total == 0;

        final String label;
        if (purchased > 0 && monthly == 0) {
          label = '✨ $purchased illustrations left';
        } else {
          label = '✨ $monthly / ${UserIllustrationCredits.monthlyIncludedLimit} this month';
        }

        final color = isEmpty
            ? const Color(0xFFF59E0B)   // amber warning
            : const Color(0xFF9C88CC);  // lavender default

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
