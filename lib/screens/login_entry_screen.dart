import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/veri_yonetici.dart';
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

      await FirebaseAuth.instance.signInWithCredential(credential);
      _proceedToApp();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: ${e.toString()}'),
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
                                    onTap: _signInWithApple,
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
