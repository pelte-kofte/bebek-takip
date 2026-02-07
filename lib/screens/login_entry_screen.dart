import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/veri_yonetici.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class LoginEntryScreen extends StatefulWidget {
  const LoginEntryScreen({super.key});

  @override
  State<LoginEntryScreen> createState() => _LoginEntryScreenState();
}

class _LoginEntryScreenState extends State<LoginEntryScreen> {
  bool _isLoading = false;

  // Check if platform supports Apple Sign In (iOS only, not web/Android)
  bool get _supportsAppleSignIn {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  // Check if platform supports Google Sign In (not web)
  bool get _supportsGoogleSignIn {
    return !kIsWeb;
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _proceedToApp();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      _proceedToApp();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _skipLogin() {
    HapticFeedback.lightImpact();
    _proceedToApp();
  }

  void _proceedToApp() async {
    await VeriYonetici.setLoginEntryShown();
    if (mounted) {
      AppNavigator.goToRoot(const MainScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Welcome illustration
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/app_icon/app_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                l10n.welcomeToNilico,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF2D1A18),
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF2D1A18).withValues(alpha: 0.6),
                ),
              ),

              const Spacer(),

              // Sign in buttons
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    // Apple Sign In (iOS only)
                    if (_supportsAppleSignIn)
                      _buildSignInButton(
                        onTap: _signInWithApple,
                        icon: Icons.apple,
                        label: l10n.signInWithApple,
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        textColor: isDark ? Colors.black : Colors.white,
                      ),

                    if (_supportsAppleSignIn && _supportsGoogleSignIn)
                      const SizedBox(height: 12),

                    // Google Sign In (disabled on web)
                    if (_supportsGoogleSignIn)
                      _buildSignInButton(
                        onTap: _signInWithGoogle,
                        icon: null,
                        googleLogo: true,
                        label: l10n.signInWithGoogle,
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D3A)
                            : Colors.white,
                        textColor: isDark ? Colors.white : const Color(0xFF2D1A18),
                        borderColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFE0E0E0),
                      ),
                  ],
                ),

              const SizedBox(height: 24),

              // Skip button
              TextButton(
                onPressed: _isLoading ? null : _skipLogin,
                child: Text(
                  l10n.continueWithoutLogin,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : const Color(0xFF2D1A18).withValues(alpha: 0.5),
                  ),
                ),
              ),

              const Spacer(),

              // Privacy note
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  l10n.loginOptionalNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : const Color(0xFF2D1A18).withValues(alpha: 0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton({
    required VoidCallback onTap,
    IconData? icon,
    bool googleLogo = false,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
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
