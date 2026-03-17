import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/repositories/illustration_request_repository.dart';
import '../models/illustration_request.dart';
import '../models/user_illustration_credits.dart';

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
    if (kDebugMode) {
      debugPrint('[IllustrationRequestService] $message');
    }
  }

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
    if (sourcePhotoStoragePath.isEmpty || sourcePhotoUrl.isEmpty) {
      throw StateError('Memory photo must be uploaded to cloud first.');
    }

    _log(
      'Creating illustration request memoryId=$memoryId '
      'babyId=$babyId uid=${user.uid}',
    );

    return _repository.createRequest(
      uid: user.uid,
      babyId: babyId,
      memoryId: memoryId,
      sourcePhotoStoragePath: sourcePhotoStoragePath,
      sourcePhotoUrl: sourcePhotoUrl,
      requestType: memoryPhotoRequestType,
      promptVersion: memoryPhotoPromptVersion,
    );
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
        const UserIllustrationCredits(
          uid: '',
          freeIllustrationAvailable: true,
          monthlyCreditsRemaining: 0,
          purchasedCreditsRemaining: 0,
          planTier: 'anonymous',
          updatedAt: null,
        ),
      );
    }
    return _repository.watchCredits(user.uid);
  }
}
