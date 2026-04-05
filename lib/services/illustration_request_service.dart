import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/repositories/illustration_request_repository.dart';
import '../models/illustration_request.dart';
import '../models/user_illustration_credits.dart';

// ---------------------------------------------------------------------------
// Credit exception — thrown before the request is created.
// The sheet catches this to show the out-of-credits upsell.
// ---------------------------------------------------------------------------

class IllustrationCreditException implements Exception {
  final int monthlyRemaining;
  final int purchasedRemaining;

  const IllustrationCreditException({
    required this.monthlyRemaining,
    required this.purchasedRemaining,
  });
}

// ---------------------------------------------------------------------------

class IllustrationRequestService {
  IllustrationRequestService({
    IllustrationRequestRepository? repository,
    FirebaseAuth? auth,
  }) : _repository = repository ?? IllustrationRequestRepository(),
       _auth = auth ?? FirebaseAuth.instance;

  final IllustrationRequestRepository _repository;
  final FirebaseAuth _auth;
  static const String memoryPhotoRequestType = 'memory-photo-illustration';
  static const String memoryPhotoPromptVersion = 'memory-photo-v1';

  void _log(String message) {
    if (kDebugMode) debugPrint('[IllustrationRequestService] $message');
  }

  /// Creates an illustration request after checking and consuming one credit.
  ///
  /// Credit priority:
  ///   1. Monthly included (3 per month, resets each calendar month)
  ///   2. Purchased credits (carry over across months)
  ///
  /// Throws [IllustrationCreditException] if no credits are available.
  /// Credits are only consumed when the Firestore write succeeds.
  Future<IllustrationRequest> createMemoryIllustrationRequest({
    required Map<String, dynamic> memory,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw StateError('Illustration requests require a signed-in account.');
    }

    final memoryId = (memory['id'] ?? '').toString().trim();
    final babyId = (memory['babyId'] ?? '').toString().trim();
    final sourcePhotoStoragePath =
        (memory['photoStoragePath'] ?? '').toString().trim();
    final sourcePhotoUrl = (memory['photoUrl'] ?? '').toString().trim();

    if (memoryId.isEmpty || babyId.isEmpty) {
      throw StateError('Memory is missing required identifiers.');
    }
    if (sourcePhotoStoragePath.isEmpty) {
      throw StateError('Memory photo must be uploaded to cloud first.');
    }

    // ── Credit check (read before write — do not consume yet) ─────────────
    final credits = await _repository.readCredits(user.uid);
    if (!credits.canGenerate) {
      _log(
        'No credits: monthly=${credits.monthlyRemaining} '
        'purchased=${credits.purchasedCreditsRemaining}',
      );
      throw IllustrationCreditException(
        monthlyRemaining: credits.monthlyRemaining,
        purchasedRemaining: credits.purchasedCreditsRemaining,
      );
    }

    _log(
      'Creating illustration request memoryId=$memoryId '
      'babyId=$babyId uid=${user.uid}',
    );

    // ── Create the Firestore document ──────────────────────────────────────
    // Credit consumption is handled server-side by the Cloud Function worker.
    // The read above is a UX-only gate; the worker is the authoritative check.
    final request = await _repository.createRequest(
      uid: user.uid,
      babyId: babyId,
      memoryId: memoryId,
      sourcePhotoStoragePath: sourcePhotoStoragePath,
      sourcePhotoUrl: sourcePhotoUrl,
      requestType: memoryPhotoRequestType,
      promptVersion: memoryPhotoPromptVersion,
    );

    return request;
  }

  Stream<IllustrationRequest?> watchRequest(String requestId) {
    return _repository.watchRequest(requestId);
  }

  Stream<List<IllustrationRequest>> watchMyRequests() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return const Stream<List<IllustrationRequest>>.empty();
    }
    return _repository.watchUserRequests(user.uid);
  }

  Stream<UserIllustrationCredits> watchMyCredits() {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) {
      return Stream<UserIllustrationCredits>.value(
        UserIllustrationCredits.empty(''),
      );
    }
    return _repository.watchCredits(user.uid);
  }
}
