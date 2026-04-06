import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import 'login_entry_screen.dart';
import '../services/premium_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  /// Entry point for all premium CTAs in the app.
  ///
  /// - Free users: shows the Adapty-designed paywall (native UI).
  ///   [isPremiumNotifier] updates automatically on purchase/restore.
  /// - Premium users: pushes the lightweight management screen.
  static Future<void> show(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final requiresSignIn = user == null || user.isAnonymous;
    if (requiresSignIn) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.premiumSignInRequired),
          ),
        );
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => const LoginEntryScreen(
              showPremiumDiscoveryAfterLogin: true,
            ),
          ),
        );
      }
      return;
    }

    if (PremiumService.instance.isPremium) {
      // Already premium — show management screen.
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const PremiumScreen(),
        ),
      );
    } else {
      // Free user — present the Adapty paywall (handles purchase + restore).
      await PremiumService.instance.presentPaywall();
    }
  }

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

// PremiumScreen is only shown to premium-active users (management screen).
// Free users see the native Adapty paywall via PremiumService.presentPaywall().
class _PremiumScreenState extends State<PremiumScreen> {
  bool _restoreLoading = false;

  Future<void> _onManageSubscription() async {
    // Opens the iOS/Android native subscription management page.
    // TODO(adapty-config): Replace with Adapty().presentCodeRedemptionSheet()
    // or the Adapty subscription management deep link when available.
    const url = 'https://apps.apple.com/account/subscriptions';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onRestorePurchases() async {
    if (_restoreLoading) return;
    setState(() => _restoreLoading = true);
    try {
      final restored = await PremiumService.instance.restorePurchases();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (!restored) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.premiumNoPurchasesFound),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.premiumRestoreFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _restoreLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF8A7C75),
                  onPressed: _restoreLoading
                      ? null
                      : () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E0F7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9C88CC).withValues(alpha: 0.2),
                            blurRadius: 28,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 40,
                        color: Color(0xFF9C88CC),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.premiumIsActive,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A3E39),
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.premiumActiveDesc,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A7C75),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _restoreLoading ? null : _onManageSubscription,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5E0F7),
                        foregroundColor: const Color(0xFF4A3E39),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        l10n.premiumManageSubscription,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _restoreLoading
                      ? const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Color(0xFF8A7C75),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: _onRestorePurchases,
                          child: Text(
                            l10n.premiumRestorePurchases,
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF8A7C75).withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
