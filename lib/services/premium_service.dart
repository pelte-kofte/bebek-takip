import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Thrown by [PremiumService.purchaseIllustrationPack] when the purchase
/// fails for a non-cancellation reason (placement not found, product missing,
/// store error). Callers should display [message] to the user.
class IllustrationPackPurchaseException implements Exception {
  final String message;
  const IllustrationPackPurchaseException(this.message);
  @override
  String toString() => 'IllustrationPackPurchaseException: $message';
}

// ---------------------------------------------------------------------------
// Adapty configuration
// ---------------------------------------------------------------------------

/// Adapty public SDK key — App Settings → API Keys in the Adapty dashboard.
const String _kAdaptyApiKey = 'public_live_wJs3JnyD.aIuC77qSt8lyyfPU9cdg';

/// Placement ID as configured in the Adapty dashboard.
const String _kPremiumPlacementId = 'premium';

/// Placement ID for illustration credit packs (non-subscription one-time purchases).
const String _kIllustrationPacksPlacementId = 'illustration_packs';

/// Access level name that grants premium features.
const String _kPremiumAccessLevel = 'premium';

// ---------------------------------------------------------------------------
// PremiumService
// ---------------------------------------------------------------------------

/// Singleton — single source of truth for premium state.
///
/// Usage:
///   Read:     PremiumService.instance.isPremium
///   React:    ValueListenableBuilder(valueListenable: PremiumService.instance.isPremiumNotifier)
///   Purchase: await PremiumService.instance.purchase()
///   Restore:  await PremiumService.instance.restorePurchases()
///
/// All future premium-only features (e.g. shared parenting / multiuser) must
/// gate on this service — do not add separate entitlement checks elsewhere.
class PremiumService {
  PremiumService._();

  static final PremiumService instance = PremiumService._();

  // ── Reactive state ─────────────────────────────────────────────────────

  /// `true` while the user holds an active premium entitlement.
  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);

  bool get isPremium => isPremiumNotifier.value;
  bool get requiresAuthenticatedUser {
    final user = FirebaseAuth.instance.currentUser;
    return user == null || user.isAnonymous;
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────

  /// Tracks the in-progress init Future so concurrent callers share the same
  /// work instead of calling Adapty().activate() multiple times.
  Future<void>? _initFuture;
  StreamSubscription<User?>? _authSubscription;
  String? _lastSyncedAdaptyUid;

  /// Activate the Adapty SDK and fetch the initial premium state.
  /// Safe to call multiple times — the activation runs exactly once.
  Future<void> init() {
    _initFuture ??= _doInit();
    return _initFuture!;
  }

  Future<void> _doInit() async {
    try {
      await Adapty().activate(
        configuration: AdaptyConfiguration(apiKey: _kAdaptyApiKey),
      );
      _log('Adapty activated');
      _startAuthSync();
      await _syncAdaptyIdentity(FirebaseAuth.instance.currentUser);
      await _refreshPremiumState();
    } catch (e) {
      _log('init error: $e');
      // Non-fatal: app works in free mode if Adapty fails to initialise.
    }
  }

  void _startAuthSync() {
    _authSubscription ??= FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      _syncAdaptyIdentity(user).ignore();
    });
  }

  Future<void> _syncAdaptyIdentity(User? user) async {
    final uid = user?.uid;
    final isAuthenticatedUser =
        user != null && !user.isAnonymous && uid != null && uid.isNotEmpty;

    if (!isAuthenticatedUser) {
      // Eagerly clear premium before any async work.  If Adapty().logout()
      // throws the state is still safe — no previous user's premium leaks.
      isPremiumNotifier.value = false;
      if (_lastSyncedAdaptyUid == null) return;
      try {
        await Adapty().logout();
        _log('Adapty identity cleared');
      } catch (e) {
        _log('logout error: $e');
      } finally {
        // Always clear the tracked uid so the next sign-in re-identifies.
        _lastSyncedAdaptyUid = null;
      }
      return;
    }

    if (_lastSyncedAdaptyUid == uid) return;

    // Eagerly clear premium for the incoming user before async identify +
    // refresh.  Prevents User A's isPremium=true from leaking into User B's
    // session if identify or getProfile throws.
    isPremiumNotifier.value = false;

    try {
      await Adapty().identify(uid);
      _lastSyncedAdaptyUid = uid;
      _log('Adapty identified uid=$uid');
      // Identity changed — re-sync premium state so Firestore reflects the
      // correct value for the newly-authenticated UID without waiting for a
      // purchase/restore event.
      await _refreshPremiumState();
    } catch (e) {
      _log('identify error: $e');
    }
  }

  /// Re-fetch the user's Adapty profile and update [isPremiumNotifier].
  Future<void> _refreshPremiumState() async {
    if (requiresAuthenticatedUser) {
      isPremiumNotifier.value = false;
      _log('refresh skipped: authenticated user required');
      return;
    }
    try {
      final profile = await Adapty().getProfile();
      final active =
          profile.accessLevels[_kPremiumAccessLevel]?.isActive ?? false;
      isPremiumNotifier.value = active;
      _log('isPremium=$active');
      await _syncPremiumTruthToBackendIfNeeded(active);
    } catch (e) {
      _log('refresh error: $e');
    }
  }

  Future<void> _syncPremiumTruthToBackendIfNeeded(bool isPremium) async {
    if (!isPremium || requiresAuthenticatedUser) return;
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'syncPremiumStatus',
      );
      await callable.call<Map<String, dynamic>>();
      _log('Backend premium truth synced');
    } catch (e) {
      _log('backend premium sync error: $e');
    }
  }

  // ── Adapty Paywall UI ──────────────────────────────────────────────────

  /// Present the Adapty-designed paywall for placement [_kPremiumPlacementId].
  ///
  /// The paywall handles purchase, restore, and close internally via
  /// [_PremiumPaywallObserver]. [isPremiumNotifier] is updated immediately
  /// on success — no app restart needed.
  Future<void> presentPaywall() async {
    await init();
    if (requiresAuthenticatedUser) {
      _log('presentPaywall skipped: authenticated user required');
      return;
    }
    try {
      final paywall = await Adapty().getPaywall(
        placementId: _kPremiumPlacementId,
      );
      final view = await AdaptyUI().createPaywallView(paywall: paywall);
      AdaptyUI().setPaywallsEventsObserver(_PremiumPaywallObserver(this));
      await view.present();
    } on AdaptyError catch (e) {
      _log('AdaptyError presenting paywall: ${e.message}');
    } catch (e) {
      _log('Unexpected error presenting paywall: $e');
    }
  }

  // ── Purchase ───────────────────────────────────────────────────────────

  /// Open the Adapty paywall for the "premium" placement and complete the
  /// purchase flow.
  ///
  /// Returns `true` when the user is now premium, `false` when cancelled or
  /// on error. Errors are caught internally — callers do not need try/catch.
  Future<bool> purchase() async {
    await init(); // ensures SDK is ready; no-op if already initialised
    if (requiresAuthenticatedUser) {
      _log('purchase skipped: authenticated user required');
      return false;
    }
    try {
      // 1. Fetch the paywall for the premium placement.
      final paywall = await Adapty().getPaywall(
        placementId: _kPremiumPlacementId,
      );

      // 2. Fetch the products attached to this paywall.
      final products = await Adapty().getPaywallProducts(paywall: paywall);
      if (products.isEmpty) {
        _log('No products found for placement $_kPremiumPlacementId');
        return false;
      }

      // 3. Trigger the native StoreKit / Play Billing purchase sheet.
      await Adapty().makePurchase(product: products.first);

      // 4. Re-fetch entitlements and update state.
      await _refreshPremiumState();
      return isPremium;
    } on AdaptyError catch (e) {
      // Code 2 = user cancelled — not an error worth surfacing.
      _log('AdaptyError during purchase: ${e.message}');
      return false;
    } catch (e) {
      _log('Unexpected purchase error: $e');
      return false;
    }
  }

  // ── Illustration pack purchase ─────────────────────────────────────────

  /// Purchase a one-time illustration credit pack by its store product ID.
  ///
  /// Product IDs: `illustration_credits_3`, `illustration_credits_10`,
  /// `illustration_credits_25`. These must match the Adapty placement
  /// [_kIllustrationPacksPlacementId] and App Store Connect exactly.
  ///
  /// Returns `true` when the purchase completed successfully.
  /// Returns `false` when the user explicitly cancelled the purchase sheet.
  /// Throws [IllustrationPackPurchaseException] on configuration or store
  /// errors so the caller can show meaningful feedback.
  Future<bool> purchaseIllustrationPack(String productId) async {
    await init();
    if (requiresAuthenticatedUser) {
      _log('purchaseIllustrationPack skipped: authenticated user required');
      return false;
    }
    try {
      _log('Fetching illustration_packs paywall for productId=$productId');
      final paywall = await Adapty().getPaywall(
        placementId: _kIllustrationPacksPlacementId,
      );

      final products = await Adapty().getPaywallProducts(paywall: paywall);
      _log(
        'Paywall products fetched count=${products.length} '
        'ids=${products.map((p) => p.vendorProductId).toList()}',
      );

      if (products.isEmpty) {
        _log('No products found in placement $_kIllustrationPacksPlacementId');
        throw IllustrationPackPurchaseException(
          'No products are configured for illustration packs. '
          'Please try again later.',
        );
      }

      final AdaptyPaywallProduct? product =
          products.cast<AdaptyPaywallProduct?>().firstWhere(
            (p) => p?.vendorProductId == productId,
            orElse: () => null,
          );

      if (product == null) {
        _log(
          'Product $productId not found. '
          'Available: ${products.map((p) => p.vendorProductId).toList()}',
        );
        throw IllustrationPackPurchaseException(
          'This illustration pack is currently unavailable. '
          'Please try again later.',
        );
      }

      _log('Calling makePurchase for vendorProductId=${product.vendorProductId}');
      await Adapty().makePurchase(product: product);
      _log('Illustration pack purchase succeeded: $productId');
      return true;
    } on AdaptyError catch (e) {
      // User-cancelled purchase — treat as silent cancel, not an error.
      if (_isAdaptyUserCancellation(e)) {
        _log('Pack purchase cancelled by user: $productId');
        return false;
      }
      _log('AdaptyError during pack purchase ($productId): ${e.message}');
      throw IllustrationPackPurchaseException(
        'Purchase could not be completed. Please try again.',
      );
    } on IllustrationPackPurchaseException {
      rethrow;
    } catch (e) {
      _log('Unexpected error during pack purchase ($productId): $e');
      throw IllustrationPackPurchaseException(
        'Purchase could not be completed. Please try again.',
      );
    }
  }

  /// Returns true when an [AdaptyError] represents a user-initiated cancel.
  /// Adapty maps StoreKit's SKErrorPaymentCancelled (code 2) to this.
  bool _isAdaptyUserCancellation(AdaptyError e) {
    final msg = e.message.toLowerCase();
    return msg.contains('cancel') || msg.contains('user cancel');
  }

  // ── Restore ────────────────────────────────────────────────────────────

  /// Restore previous purchases.
  ///
  /// Returns `true` if the user now has an active premium entitlement.
  Future<bool> restorePurchases() async {
    await init();
    if (requiresAuthenticatedUser) {
      _log('restore skipped: authenticated user required');
      return false;
    }
    try {
      final profile = await Adapty().restorePurchases();
      final active =
          profile.accessLevels[_kPremiumAccessLevel]?.isActive ?? false;
      isPremiumNotifier.value = active;
      _log('restore isPremium=$active');
      await _syncPremiumTruthToBackendIfNeeded(active);
      return active;
    } on AdaptyError catch (e) {
      _log('AdaptyError during restore: ${e.message}');
      return false;
    } catch (e) {
      _log('Unexpected restore error: $e');
      return false;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _log(String message) {
    if (kDebugMode) debugPrint('[PremiumService] $message');
  }
}

// ---------------------------------------------------------------------------
// Adapty paywall event observer
// ---------------------------------------------------------------------------

/// Handles all events from the Adapty-presented paywall and keeps
/// [PremiumService.isPremiumNotifier] up to date.
class _PremiumPaywallObserver implements AdaptyUIPaywallsEventsObserver {
  final PremiumService _service;

  _PremiumPaywallObserver(this._service);

  @override
  void paywallViewDidAppear(AdaptyUIPaywallView view) {}

  @override
  void paywallViewDidDisappear(AdaptyUIPaywallView view) {}

  @override
  void paywallViewDidPerformAction(
    AdaptyUIPaywallView view,
    AdaptyUIAction action,
  ) {
    switch (action) {
      case const CloseAction():
      case const AndroidSystemBackAction():
        view.dismiss();
        break;
      default:
        break;
    }
  }

  @override
  void paywallViewDidSelectProduct(AdaptyUIPaywallView view, String productId) {}

  @override
  void paywallViewDidStartPurchase(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct product,
  ) {}

  @override
  void paywallViewDidFinishPurchase(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct product,
    AdaptyPurchaseResult purchaseResult,
  ) {
    if (purchaseResult is AdaptyPurchaseResultSuccess) {
      final active =
          purchaseResult.profile.accessLevels[_kPremiumAccessLevel]?.isActive ??
          false;
      _service.isPremiumNotifier.value = active;
      _service._log('paywall purchase isPremium=$active');
      _service._syncPremiumTruthToBackendIfNeeded(active).ignore();
    }
    view.dismiss();
  }

  @override
  void paywallViewDidFailPurchase(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct product,
    AdaptyError error,
  ) {
    _service._log('paywall purchase error: ${error.message}');
  }

  @override
  void paywallViewDidStartRestore(AdaptyUIPaywallView view) {}

  @override
  void paywallViewDidFinishRestore(
    AdaptyUIPaywallView view,
    AdaptyProfile profile,
  ) {
    final active =
        profile.accessLevels[_kPremiumAccessLevel]?.isActive ?? false;
    _service.isPremiumNotifier.value = active;
    _service._log('paywall restore isPremium=$active');
    _service._syncPremiumTruthToBackendIfNeeded(active).ignore();
    if (active) view.dismiss();
  }

  @override
  void paywallViewDidFailRestore(AdaptyUIPaywallView view, AdaptyError error) {
    _service._log('paywall restore error: ${error.message}');
  }

  @override
  void paywallViewDidFailRendering(
    AdaptyUIPaywallView view,
    AdaptyError error,
  ) {
    _service._log('paywall render error: ${error.message}');
    view.dismiss();
  }

  @override
  void paywallViewDidFailLoadingProducts(
    AdaptyUIPaywallView view,
    AdaptyError error,
  ) {
    _service._log('paywall load products error: ${error.message}');
  }

  @override
  void paywallViewDidFinishWebPaymentNavigation(
    AdaptyUIPaywallView view,
    AdaptyPaywallProduct? product,
    AdaptyError? error,
  ) {}
}
