import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/veri_yonetici.dart';

class SyncManager {
  static const bool _debugLogs = true;

  static void _log(String message) {
    if (kDebugMode && _debugLogs) {
      debugPrint('[SyncManager] $message');
    }
  }

  static Future<void> initializeAnonymousSession() async {
    final existing = FirebaseAuth.instance.currentUser;
    if (existing != null) {
      _log('Auth ready uid=${existing.uid} anonymous=${existing.isAnonymous}');
      return;
    }
    _log('No current user, signing in anonymously.');
    await FirebaseAuth.instance.signInAnonymously();
    _log('Anonymous sign-in completed.');
  }

  static Future<void> forceGuestSession() async {
    final auth = FirebaseAuth.instance;
    final before = auth.currentUser;
    final beforeProviders =
        before?.providerData.map((p) => '${p.providerId}:${p.uid}').toList() ??
        const <String>[];
    _log(
      'Guest flow start uid=${before?.uid} anonymous=${before?.isAnonymous} providers=$beforeProviders',
    );

    final shouldSignOutProviderUser = before != null && !before.isAnonymous;

    if (!kIsWeb && shouldSignOutProviderUser) {
      final googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.disconnect();
        _log('Google disconnect completed.');
      } catch (e) {
        _log('Google disconnect skipped: $e');
      }
      try {
        await googleSignIn.signOut();
        _log('Google sign-out completed.');
      } catch (e) {
        _log('Google sign-out skipped: $e');
      }
    }

    if (shouldSignOutProviderUser) {
      _log(
        'Guest flow detected signed-in non-anonymous user. Signing out first.',
      );
      await auth.signOut();
    } else {
      _log(
        'Guest flow already anonymous-or-empty auth state. Keeping local app data intact.',
      );
    }

    if (auth.currentUser == null || !auth.currentUser!.isAnonymous) {
      _log('Guest flow ensuring anonymous sign-in.');
      await auth.signInAnonymously();
    }
    final anonymous = auth.currentUser;
    final afterProviders =
        anonymous?.providerData
            .map((p) => '${p.providerId}:${p.uid}')
            .toList() ??
        const <String>[];
    _log(
      'Guest flow end uid=${anonymous?.uid} anonymous=${anonymous?.isAnonymous} providers=$afterProviders',
    );

    await VeriYonetici.refreshForCurrentUser();
  }

  static bool _isLinkConflict(FirebaseAuthException e) {
    return e.code == 'credential-already-in-use' ||
        e.code == 'email-already-in-use' ||
        e.code == 'account-exists-with-different-credential';
  }

  static Future<UserCredential> onLogin(AuthCredential credential) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    final anonUser = currentUser;
    final shouldLinkAnonymous = anonUser != null && anonUser.isAnonymous;
    _log(
      'onLogin start uid=${currentUser?.uid} anonymous=${currentUser?.isAnonymous} '
      'mode=${shouldLinkAnonymous ? 'link-anonymous' : 'sign-in'} provider=${credential.providerId}',
    );
    try {
      if (shouldLinkAnonymous) {
        try {
          _log('Linking anonymous user uid=${anonUser.uid}');
          final linked = await anonUser.linkWithCredential(credential);
          _log('Anonymous account linked, uid=${linked.user?.uid}');
          await syncCurrentUserData();
          return linked;
        } on FirebaseAuthException catch (e) {
          if (!_isLinkConflict(e)) rethrow;
          _log(
            'Link conflict (${e.code}), falling back to signInWithCredential.',
          );
          final signedIn = await auth.signInWithCredential(credential);
          _log(
            'Fallback sign-in completed. uid=${signedIn.user?.uid} '
            'anonymous=${signedIn.user?.isAnonymous}',
          );
          await syncCurrentUserData();
          return signedIn;
        }
      }

      _log('Signing in directly with provider=${credential.providerId}');
      final signedIn = await auth.signInWithCredential(credential);
      _log(
        'Signed in with provider. uid=${signedIn.user?.uid} '
        'anonymous=${signedIn.user?.isAnonymous}',
      );
      await syncCurrentUserData();
      return signedIn;
    } on FirebaseAuthException catch (e) {
      _log(
        'FirebaseAuthException onLogin '
        'code=${e.code} message=${e.message} plugin=${e.plugin}',
      );
      rethrow;
    }
  }

  static Future<void> syncCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final providers =
        user?.providerData.map((p) => p.providerId).toList() ?? [];
    _log(
      'Sync requested for uid=${user?.uid} anonymous=${user?.isAnonymous} providers=$providers',
    );
    await VeriYonetici.refreshForCurrentUser();
  }
}
