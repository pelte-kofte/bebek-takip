import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  static bool _isLinkConflict(FirebaseAuthException e) {
    return e.code == 'credential-already-in-use' ||
        e.code == 'email-already-in-use' ||
        e.code == 'account-exists-with-different-credential';
  }

  static Future<UserCredential> onLogin(AuthCredential credential) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    _log(
      'onLogin start uid=${currentUser?.uid} anonymous=${currentUser?.isAnonymous}',
    );
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        _log('Linking anonymous user uid=${currentUser.uid}');
        final linked = await currentUser.linkWithCredential(credential);
        _log('Anonymous account linked, uid=${linked.user?.uid}');
        return linked;
      } on FirebaseAuthException catch (e) {
        if (!_isLinkConflict(e)) rethrow;
        _log('Link conflict (${e.code}), signing in with credential.');
        final signedIn = await auth.signInWithCredential(credential);
        final newUid = signedIn.user?.uid;
        if (newUid != null && newUid.isNotEmpty) {
          _log(
            'Conflict sign-in completed. uid=$newUid. Running safe non-destructive merge migration.',
          );
          await VeriYonetici.refreshForCurrentUser();
        }
        _log(
          'Old anonymous remote subtree is intentionally untouched (non-destructive policy).',
        );
        return signedIn;
      }
    }
    final signedIn = await auth.signInWithCredential(credential);
    _log(
      'Signed in with provider. uid=${signedIn.user?.uid} anonymous=${signedIn.user?.isAnonymous}',
    );
    return signedIn;
  }

  static Future<void> syncCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    _log('Sync requested for uid=${user?.uid} anonymous=${user?.isAnonymous}');
    await VeriYonetici.refreshForCurrentUser();
  }
}
