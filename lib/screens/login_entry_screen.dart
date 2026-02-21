import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/veri_yonetici.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/apple_auth_service.dart';
import '../services/sync_manager.dart';

class LoginEntryScreen extends StatefulWidget {
  const LoginEntryScreen({super.key});

  @override
  State<LoginEntryScreen> createState() => _LoginEntryScreenState();
}

class _LoginEntryScreenState extends State<LoginEntryScreen> {
  bool _isLoading = false;
  bool _isAppleSigningIn = false;

  // Check if platform supports Apple Sign In (iOS only, not web/Android)
  bool get _supportsAppleSignIn {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Check if platform supports Google Sign In (not web)
  bool get _supportsGoogleSignIn {
    return !kIsWeb;
  }

  Future<void> _authenticateWithCredential(AuthCredential credential) async {
    await SyncManager.onLogin(credential);
    _proceedToApp();
  }

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _authenticateWithCredential(credential);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.googleSignInFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (_isAppleSigningIn || AppleAuthService.instance.inProgress) {
      return;
    }
    setState(() {
      _isLoading = true;
      _isAppleSigningIn = true;
    });
    try {
      final credential = await AppleAuthService.instance.signIn();
      if (credential == null) return;
      await _proceedToApp();
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final message = _isMissingOrInvalidNonce(e)
            ? 'Please try again'
            : l10n.signInFailed(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAppleSigningIn = false;
          _isLoading = false;
        });
      } else {
        _isAppleSigningIn = false;
      }
    }
  }

  bool _isMissingOrInvalidNonce(Object error) {
    if (error is FirebaseAuthException) {
      return error.code == 'missing-or-invalid-nonce' ||
          error.message?.contains('missing-or-invalid-nonce') == true ||
          error.message?.contains('Duplicate credential received') == true;
    }
    final text = error.toString();
    return text.contains('missing-or-invalid-nonce') ||
        text.contains('Duplicate credential received');
  }

  Future<void> _skipLogin() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      if (kDebugMode) {
        final before = FirebaseAuth.instance.currentUser;
        final providers =
            before?.providerData
                .map((p) => '${p.providerId}:${p.uid}')
                .toList() ??
            const <String>[];
        debugPrint(
          '[LoginEntryScreen] guest tap before uid=${before?.uid} anonymous=${before?.isAnonymous} providers=$providers',
        );
      }
      await SyncManager.forceGuestSession();
      if (kDebugMode) {
        final after = FirebaseAuth.instance.currentUser;
        final providers =
            after?.providerData
                .map((p) => '${p.providerId}:${p.uid}')
                .toList() ??
            const <String>[];
        debugPrint(
          '[LoginEntryScreen] guest tap after uid=${after?.uid} anonymous=${after?.isAnonymous} providers=$providers',
        );
      }
      await _proceedToApp(forcePromptAddBabyForGuest: true);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.signInFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _proceedToApp({bool forcePromptAddBabyForGuest = false}) async {
    await VeriYonetici.setLoginEntryShown();
    await SyncManager.syncCurrentUserData();
    final user = FirebaseAuth.instance.currentUser;
    final shouldPromptAddBaby =
        forcePromptAddBabyForGuest &&
        user != null &&
        user.isAnonymous &&
        VeriYonetici.getBabies().isEmpty;
    if (mounted) {
      AppNavigator.goToRoot(
        MainScreen(promptAddBabyOnStart: shouldPromptAddBaby),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/login_entry.png',
              fit: BoxFit.cover,
            ),
          ),

          // Layer 2: Gradient overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // Layer 3: Content — bottom aligned, scrollable
          Positioned.fill(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),

                          // Title
                          Text(
                            l10n.createYourAccount,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle
                          Text(
                            l10n.loginBenefitText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can keep using as guest. If you sign in later, your data will sync across devices. Photos are stored locally for now.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Sign in buttons
                          if (_isLoading)
                            const CircularProgressIndicator(color: Colors.white)
                          else
                            Column(
                              children: [
                                // Apple Sign In (iOS only)
                                if (_supportsAppleSignIn)
                                  _buildSignInButton(
                                    onTap: _isAppleSigningIn
                                        ? null
                                        : _signInWithApple,
                                    icon: Icons.apple,
                                    label: l10n.signInWithApple,
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                  ),

                                if (_supportsAppleSignIn &&
                                    _supportsGoogleSignIn)
                                  const SizedBox(height: 12),

                                // Google Sign In
                                if (_supportsGoogleSignIn)
                                  _buildSignInButton(
                                    onTap: _signInWithGoogle,
                                    icon: null,
                                    googleLogo: true,
                                    label: l10n.signInWithGoogle,
                                    backgroundColor: Colors.white,
                                    textColor: const Color(0xFF2D1A18),
                                  ),
                              ],
                            ),

                          const SizedBox(height: 20),

                          // Skip button
                          TextButton(
                            onPressed: _isLoading ? null : _skipLogin,
                            child: Text(
                              l10n.continueWithoutLogin,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Privacy note
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              l10n.loginOptionalNote,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildSignInButton({
    required VoidCallback? onTap,
    IconData? icon,
    bool googleLogo = false,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled
              ? backgroundColor.withValues(alpha: 0.65)
              : backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, color: textColor, size: 22)
            else if (googleLogo)
              _buildGoogleLogo(),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade600,
          ),
        ),
      ),
    );
  }
}
