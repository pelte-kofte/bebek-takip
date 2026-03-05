import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../firebase_options.dart';

class AppleAuthService {
  AppleAuthService._();

  static final AppleAuthService instance = AppleAuthService._();
  static final Random _secureRandom = Random.secure();
  static const MethodChannel _iosRuntimeInfoChannel = MethodChannel(
    'com.nilico.baby/ios_runtime_info',
  );
  static const MethodChannel _nativeLogger = MethodChannel('native_logger');

  // Full alphanumeric + safe-symbol charset (matches Firebase docs example).
  static const String _charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';

  bool _inProgress = false;

  bool get inProgress => _inProgress;

  void _log(String message, {String? attemptId}) {
    _emitNativeLog(method: 'log', message: message, attemptId: attemptId);
  }

  void _logError(String message, {String? attemptId}) {
    _emitNativeLog(method: 'error', message: message, attemptId: attemptId);
  }

  void _emitNativeLog({
    required String method,
    required String message,
    String? attemptId,
  }) {
    final normalized = _normalizeLogPrefix(
      message: message,
      attemptId: attemptId,
    );
    unawaited(
      _nativeLogger.invokeMethod<void>(method, normalized).catchError((_) {}),
    );
  }

  String _normalizeLogPrefix({required String message, String? attemptId}) {
    final match = RegExp(r'^\[([A-Z0-9]{6})\]\s*(.*)$').firstMatch(message);
    final resolvedAttemptId = attemptId ?? match?.group(1) ?? 'GLOBAL';
    final resolvedMessage = match?.group(2) ?? message;
    return '[AppleAuthService][$resolvedAttemptId] $resolvedMessage';
  }

  String _currentBuildMode() {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  Map<String, dynamic>? _decodeJwtPayload(String jwt) {
    final segments = jwt.split('.');
    if (segments.length < 2) return null;

    try {
      final normalized = base64Url.normalize(segments[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded);
      if (payload is Map<String, dynamic>) return payload;
      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
    } catch (e) {
      _log('Failed to decode Apple identity token payload: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _fetchIosRuntimeDiagnostics(
    String attemptId,
  ) async {
    if (kIsWeb || !Platform.isIOS) return null;

    try {
      final result = await _iosRuntimeInfoChannel
          .invokeMapMethod<String, dynamic>('getAppleSignInDiagnostics');
      if (result == null) return null;
      _log(
        '[$attemptId] iOS runtime diagnostics '
        'bundleId=${result['bundleId']} '
        'buildMode=${result['buildMode']} '
        'appleSignInEntitlement=${result['appleSignInEntitlement']} '
        'appGroups=${result['appGroups']}',
        attemptId: attemptId,
      );
      return result;
    } catch (e) {
      _logError(
        'Failed to fetch iOS runtime diagnostics: $e',
        attemptId: attemptId,
      );
      return null;
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
        attemptId: attemptId,
      );
      return null;
    }

    final redirectUri = Uri.tryParse(redirectUriRaw);
    if (redirectUri == null) {
      _log(
        'Invalid APPLE_REDIRECT_URI: "$redirectUriRaw".',
        attemptId: attemptId,
      );
      return null;
    }

    return WebAuthenticationOptions(
      clientId: serviceId,
      redirectUri: redirectUri,
    );
  }

  Future<FirebaseApp> _ensureFirebaseReady(String attemptId) async {
    if (Firebase.apps.isEmpty) {
      _log('[$attemptId] Firebase not initialized. Initializing now.');
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _log('[$attemptId] Firebase initialized lazily. app=${app.name}');
      return app;
    }

    final app = Firebase.app();
    _log('[$attemptId] Firebase already initialized. app=${app.name}');
    return app;
  }

  void _logFirebaseState(String attemptId, FirebaseApp app) {
    final options = app.options;
    _log(
      '[$attemptId] Firebase state '
      'apps=${Firebase.apps.length} '
      'defaultApp=${app.name} '
      'apiKey=${options.apiKey} '
      'appId=${options.appId} '
      'projectId=${options.projectId} '
      'messagingSenderId=${options.messagingSenderId} '
      'storageBucket=${options.storageBucket}',
    );
  }

  // Prerequisites checklist:
  // 1) Firebase Console → Apple provider is enabled.
  // 2) Apple Service ID / bundle identifier matches this iOS app target.
  // 3) Xcode Runner target has "Sign in with Apple" capability enabled.
  //
  // Nonce contract:
  //   hashedNonce (SHA-256 of rawNonce) -> passed to Apple as `nonce`
  //   rawNonce -> passed to Firebase as `rawNonce`
  //   Firebase verifies SHA-256(rawNonce) equals JWT nonce claim
  Future<OAuthCredential?> signIn() async {
    if (_inProgress) {
      _log('Ignoring duplicate Apple sign-in attempt while one is active.');
      return null;
    }

    _inProgress = true;
    final attemptId = _generateAttemptId();
    _log('[$attemptId] START Apple sign-in');
    try {
      _log(
        '[$attemptId] Build branch '
        'mode=${_currentBuildMode()} '
        'kIsWeb=$kIsWeb '
        'platform=${kIsWeb ? 'web' : Platform.operatingSystem}',
      );
      final firebaseApp = await _ensureFirebaseReady(attemptId);
      _logFirebaseState(attemptId, firebaseApp);
      final runtimeDiagnostics = await _fetchIosRuntimeDiagnostics(attemptId);
      if (Platform.isIOS && runtimeDiagnostics != null) {
        final appleSignInEntitlement =
            runtimeDiagnostics['appleSignInEntitlement'];
        if (appleSignInEntitlement == null) {
          throw FirebaseAuthException(
            code: 'missing-apple-sign-in-entitlement',
            message:
                'Signed iOS app is missing the Sign In with Apple entitlement.',
          );
        }
      }

      // Generate a cryptographically secure random nonce.
      // We pass SHA-256(rawNonce) to Apple so Apple includes it in the JWT.
      // We pass rawNonce to Firebase so Firebase can verify SHA-256(rawNonce) == JWT nonce.
      final rawNonce = generateNonce();
      final hashedNonce = sha256OfString(rawNonce);
      _log(
        '[$attemptId] Nonce generated '
        'rawNonce=$rawNonce '
        'hashedNonce=$hashedNonce '
        'rawLength=${rawNonce.length} '
        'sha256Length=${hashedNonce.length}',
      );
      _log(
        'Calling SignInWithApple.getAppleIDCredential '
        'scopes=[email,fullName] '
        'platform=${kIsWeb ? 'web' : Platform.operatingSystem} '
        'hashedNonceLength=${hashedNonce.length}',
        attemptId: attemptId,
      );

      final AuthorizationCredentialAppleID appleCredential;
      try {
        if (kIsWeb) {
          _log('[$attemptId] Using Apple flow branch=web');
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
          _log('[$attemptId] Using Apple flow branch=ios-native');
          // iOS native flow: never pass webAuthenticationOptions.
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );
        } else if (Platform.isAndroid) {
          _log('[$attemptId] Using Apple flow branch=android-web');
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
          _log('[$attemptId] Using Apple flow branch=fallback-native');
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
        _logError(
          'ERROR (Apple authorization): ${e.code} - $e',
          attemptId: attemptId,
        );
        rethrow;
      }

      final identityToken = appleCredential.identityToken;
      _log(
        'Received appleCredential '
        'hasIdentityToken=${(identityToken ?? '').isNotEmpty} '
        'hasAuthorizationCode=${appleCredential.authorizationCode.isNotEmpty} '
        'userIdentifierPresent=${(appleCredential.userIdentifier ?? '').isNotEmpty} '
        'hasEmail=${(appleCredential.email ?? '').isNotEmpty} '
        'hasFullName=${(appleCredential.givenName ?? '').isNotEmpty || (appleCredential.familyName ?? '').isNotEmpty}',
        attemptId: attemptId,
      );

      // sign_in_with_apple 6.x returns identityToken as String?.
      // authorizationCode is NOT required for Firebase authentication.
      if (identityToken == null || identityToken.isEmpty) {
        _logError(
          'Apple credential missing identityToken.',
          attemptId: attemptId,
        );
        throw FirebaseAuthException(
          code: 'missing-identity-token',
          message: 'Apple identity token is missing.',
        );
      }

      _log(
        '[$attemptId] GOT Apple credential '
        'hasToken=true '
        'hasAuthorizationCode=${appleCredential.authorizationCode.isNotEmpty} '
        'hasEmail=${(appleCredential.email ?? '').isNotEmpty} '
        'hasGivenName=${(appleCredential.givenName ?? '').isNotEmpty} '
        'hasFamilyName=${(appleCredential.familyName ?? '').isNotEmpty} '
        'userIdentifierPresent=${(appleCredential.userIdentifier ?? '').isNotEmpty}',
      );

      final jwtPayload = _decodeJwtPayload(identityToken);
      final aud = jwtPayload?['aud'];
      final iss = jwtPayload?['iss'];
      final exp = jwtPayload?['exp'];
      final iat = jwtPayload?['iat'];
      final jwtNonce = jwtPayload?['nonce'];
      _log(
        '[$attemptId] Apple identityToken payload '
        'aud=$aud iss=$iss exp=$exp iat=$iat nonce=$jwtNonce',
      );
      if (jwtNonce != null) {
        _log(
          '[$attemptId] Apple nonce comparison '
          'jwtMatchesHashedNonce=${jwtNonce == hashedNonce}',
        );
      }

      final runtimeBundleId = runtimeDiagnostics?['bundleId']?.toString();
      if (Platform.isIOS &&
          runtimeBundleId != null &&
          runtimeBundleId.isNotEmpty) {
        if (aud != runtimeBundleId) {
          _log(
            '[$attemptId] Apple audience mismatch '
            'tokenAud=$aud runtimeBundleId=$runtimeBundleId',
          );
          throw FirebaseAuthException(
            code: 'invalid-apple-audience',
            message:
                'Apple identity token audience mismatch. Expected $runtimeBundleId, got $aud.',
          );
        }
      }

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: identityToken, rawNonce: rawNonce);
      _log(
        'Returning Apple OAuthCredential provider=${oauthCredential.providerId} '
        'rawNonceLength=${rawNonce.length} idTokenPresent=${identityToken.isNotEmpty}',
        attemptId: attemptId,
      );
      return oauthCredential;
    } on FirebaseAuthException catch (e, st) {
      _logError(
        'FirebaseAuthException@top-level '
        'code=${e.code} message=${e.message} plugin=${e.plugin}',
        attemptId: attemptId,
      );
      _logError(
        'FirebaseAuthException@top-level stack=$st',
        attemptId: attemptId,
      );
      rethrow;
    } catch (e, st) {
      _logError('ERROR: $e', attemptId: attemptId);
      _logError('ERROR stack=$st', attemptId: attemptId);
      rethrow;
    } finally {
      _inProgress = false;
      _log('END - inProgress cleared', attemptId: attemptId);
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

  // Backward-compatible alias for callers expecting this exact casing.
  String sha256ofString(String input) => sha256OfString(input);
}
