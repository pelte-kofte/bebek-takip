import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  AppleAuthService._();

  static final AppleAuthService instance = AppleAuthService._();
  static final Random _secureRandom = Random.secure();

  // Full alphanumeric + safe-symbol charset (matches Firebase docs example).
  static const String _charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';

  bool _inProgress = false;

  bool get inProgress => _inProgress;

  bool _isLinkConflict(FirebaseAuthException e) {
    return e.code == 'credential-already-in-use' ||
        e.code == 'email-already-in-use' ||
        e.code == 'account-exists-with-different-credential';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AppleAuthService] $message');
    }
  }

  String _generateAttemptId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      6,
      (_) => chars[_secureRandom.nextInt(chars.length)],
    ).join();
  }

  WebAuthenticationOptions? _webAuthOptions(String attemptId) {
    const serviceId = String.fromEnvironment('APPLE_SERVICE_ID');
    const redirectUriRaw = String.fromEnvironment('APPLE_REDIRECT_URI');

    if (serviceId.isEmpty || redirectUriRaw.isEmpty) {
      _log(
        '[$attemptId] Missing APPLE_SERVICE_ID / APPLE_REDIRECT_URI for web/Android Apple flow.',
      );
      return null;
    }

    final redirectUri = Uri.tryParse(redirectUriRaw);
    if (redirectUri == null) {
      _log('[$attemptId] Invalid APPLE_REDIRECT_URI: "$redirectUriRaw".');
      return null;
    }

    return WebAuthenticationOptions(
      clientId: serviceId,
      redirectUri: redirectUri,
    );
  }

  void _logFirebaseAuthException(
    String attemptId,
    FirebaseAuthException e, {
    required String stage,
  }) {
    _log('[$attemptId] FirebaseAuthException@$stage ${e.code}: ${e.message}');
  }

  // Prerequisites checklist:
  // 1) Firebase Console → Apple provider is enabled.
  // 2) Apple Service ID / bundle identifier matches this iOS app target.
  // 3) Xcode Runner target has "Sign in with Apple" capability enabled.
  //
  // Nonce contract:
  //   rawNonce  → passed to Apple as `nonce` (SHA-256 of rawNonce goes into the JWT)
  //   rawNonce  → passed to Firebase as `rawNonce` (Firebase verifies SHA-256 matches JWT)
  Future<UserCredential?> signIn() async {
    if (_inProgress) {
      _log('Ignoring duplicate Apple sign-in attempt while one is active.');
      return null;
    }

    _inProgress = true;
    final attemptId = _generateAttemptId();
    _log('[$attemptId] START Apple sign-in');
    try {
      // Generate a cryptographically secure random nonce.
      // We pass SHA-256(rawNonce) to Apple so Apple includes it in the JWT.
      // We pass rawNonce to Firebase so Firebase can verify SHA-256(rawNonce) == JWT nonce.
      final rawNonce = generateNonce();
      final hashedNonce = sha256OfString(rawNonce);
      _log(
        '[$attemptId] Nonce generated (rawLength=${rawNonce.length}, sha256Length=${hashedNonce.length})',
      );

      final AuthorizationCredentialAppleID appleCredential;
      try {
        if (kIsWeb) {
          final webOptions = _webAuthOptions(attemptId);
          if (webOptions == null) {
            throw FirebaseAuthException(
              code: 'missing-web-auth-options',
              message:
                  'APPLE_SERVICE_ID and APPLE_REDIRECT_URI are required on web.',
            );
          }
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
            webAuthenticationOptions: webOptions,
          );
        } else if (Platform.isIOS) {
          // iOS native flow: never pass webAuthenticationOptions.
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );
        } else if (Platform.isAndroid) {
          final webOptions = _webAuthOptions(attemptId);
          if (webOptions == null) {
            throw FirebaseAuthException(
              code: 'missing-web-auth-options',
              message:
                  'APPLE_SERVICE_ID and APPLE_REDIRECT_URI are required on Android.',
            );
          }
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
            webAuthenticationOptions: webOptions,
          );
        } else {
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );
        }
      } on SignInWithAppleAuthorizationException catch (e) {
        if (e.code == AuthorizationErrorCode.canceled) {
          _log('[$attemptId] CANCEL - user dismissed Apple sheet');
          return null;
        }
        _log('[$attemptId] ERROR (Apple authorization): ${e.code} - $e');
        rethrow;
      }

      // sign_in_with_apple 6.x returns identityToken as String?.
      // authorizationCode is NOT required for Firebase authentication.
      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        _log('[$attemptId] Apple credential missing identityToken.');
        throw FirebaseAuthException(
          code: 'missing-identity-token',
          message: 'Apple identity token is missing.',
        );
      }

      _log('[$attemptId] GOT Apple credential (hasToken=true)');

      // Build the OAuthCredential with rawNonce so Firebase can verify
      // SHA-256(rawNonce) == nonce claim in the identityToken JWT.
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
      );

      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      _log(
        '[$attemptId] BEFORE Firebase call (anonymous=${currentUser?.isAnonymous})',
      );

      UserCredential result;
      if (currentUser != null && currentUser.isAnonymous) {
        try {
          result = await currentUser.linkWithCredential(oauthCredential);
        } on FirebaseAuthException catch (e) {
          _logFirebaseAuthException(attemptId, e, stage: 'linkWithCredential');
          if (!_isLinkConflict(e)) {
            rethrow;
          }
          _log(
            '[$attemptId] Link conflict (${e.code}); signing out anon, retrying signIn',
          );
          await auth.signOut();
          try {
            result = await auth.signInWithCredential(oauthCredential);
          } on FirebaseAuthException catch (e) {
            _logFirebaseAuthException(
              attemptId,
              e,
              stage: 'signInWithCredential-after-link-conflict',
            );
            rethrow;
          }
        }
      } else {
        try {
          result = await auth.signInWithCredential(oauthCredential);
        } on FirebaseAuthException catch (e) {
          _logFirebaseAuthException(
            attemptId,
            e,
            stage: 'signInWithCredential',
          );
          rethrow;
        }
      }

      _log('[$attemptId] SUCCESS uid=${result.user?.uid}');
      return result;
    } on FirebaseAuthException catch (e) {
      _logFirebaseAuthException(attemptId, e, stage: 'top-level');
      rethrow;
    } catch (e) {
      _log('[$attemptId] ERROR: $e');
      rethrow;
    } finally {
      _inProgress = false;
      _log('[$attemptId] END - inProgress cleared');
    }
  }

  /// Generates a cryptographically secure random nonce string.
  /// The SHA-256 of this value is sent to Apple and included in the JWT.
  String generateNonce({int length = 32}) {
    final codeUnits = List<int>.generate(
      length,
      (_) => _charset.codeUnitAt(_secureRandom.nextInt(_charset.length)),
    );
    return String.fromCharCodes(codeUnits);
  }

  /// Returns the lowercase hex SHA-256 digest of [input].
  String sha256OfString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
