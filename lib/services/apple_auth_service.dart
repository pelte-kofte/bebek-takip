import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  AppleAuthService._();

  static final AppleAuthService instance = AppleAuthService._();
  static final Random _secureRandom = Random.secure();
  static const String _charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

  bool _inProgress = false;
  String? _currentNonce;

  bool get inProgress => _inProgress;

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get _useWebAuthenticationOptions =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

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
    switch (e.code) {
      case 'invalid-credential':
      case 'credential-already-in-use':
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
      case 'network-request-failed':
      case 'too-many-requests':
      case 'user-disabled':
      case 'operation-not-allowed':
      case 'missing-or-invalid-nonce':
      case 'missing-identity-token':
      case 'missing-web-auth-options':
        _log('[$attemptId] FirebaseAuthException@$stage ${e.code}: ${e.message}');
        return;
      default:
        _log('[$attemptId] FirebaseAuthException@$stage ${e.code}: ${e.message}');
    }
  }

  // Checklist:
  // 1) Firebase Console -> Apple provider is enabled.
  // 2) Apple Service ID / bundle identifier matches this iOS app target.
  // 3) Xcode Runner target has "Sign in with Apple" capability enabled.
  Future<UserCredential?> signIn() async {
    if (_inProgress) {
      _log('Ignoring duplicate Apple sign-in attempt while one is active.');
      return null;
    }

    _inProgress = true;
    final attemptId = _generateAttemptId();
    _log('[$attemptId] START Apple sign-in');
    try {
      final rawNonce = generateNonce();
      _currentNonce = rawNonce;
      final hashedNonce = sha256OfString(rawNonce);
      _log(
        '[$attemptId] Nonce generated (rawLength=${rawNonce.length}, sha256Length=${hashedNonce.length})',
      );

      final AuthorizationCredentialAppleID appleCredential;
      try {
        if (_isIOS) {
          // iOS native flow: never pass webAuthenticationOptions here.
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );
        } else if (_useWebAuthenticationOptions) {
          final webOptions = _webAuthOptions(attemptId);
          if (webOptions == null) {
            throw FirebaseAuthException(
              code: 'missing-web-auth-options',
              message:
                  'APPLE_SERVICE_ID and APPLE_REDIRECT_URI are required on Android/Web.',
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

      _log(
        '[$attemptId] GOT Apple credential '
        '(hasToken=${appleCredential.identityToken != null}, '
        'hasCode=${appleCredential.authorizationCode.isNotEmpty})',
      );

      final identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        _log('[$attemptId] Apple credential missing identityToken.');
        throw FirebaseAuthException(
          code: 'missing-identity-token',
          message: 'Apple identity token is missing.',
        );
      }

      if (appleCredential.authorizationCode.isEmpty) {
        _log(
          '[$attemptId] Apple credential missing authorizationCode. '
          'Continuing because Firebase sign-in uses identityToken + nonce.',
        );
      }

      final currentNonce = _currentNonce;
      if (currentNonce == null || currentNonce.isEmpty) {
        _log('[$attemptId] Missing raw nonce before Firebase credential creation.');
        throw FirebaseAuthException(
          code: 'missing-or-invalid-nonce',
          message: 'Missing nonce. Please try again.',
        );
      }

      final oauthCredential =
          OAuthProvider('apple.com').credential(
            idToken: identityToken,
            rawNonce: currentNonce,
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
          _log('[$attemptId] Link conflict (${e.code}); signing out anon, retrying signIn');
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
          _logFirebaseAuthException(attemptId, e, stage: 'signInWithCredential');
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
      _currentNonce = null;
      _inProgress = false;
      _log('[$attemptId] END - nonce/inProgress cleared');
    }
  }

  String generateNonce({int length = 32}) {
    final codeUnits = List<int>.generate(
      length,
      (_) => _charset.codeUnitAt(_secureRandom.nextInt(_charset.length)),
    );
    return String.fromCharCodes(codeUnits);
  }

  String sha256OfString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
