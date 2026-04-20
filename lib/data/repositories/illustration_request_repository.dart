import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/illustration_request.dart';
import '../../models/user_illustration_credits.dart';

class IllustrationRequestRepository {
  IllustrationRequestRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const bool _debugLogs = true;

  void _log(String message) {
    if (kDebugMode && _debugLogs) {
      debugPrint('[IllustrationRequestRepository] $message');
    }
  }

  bool _isAnonymousOrSignedOut() {
    final user = _auth.currentUser;
    return user == null || user.isAnonymous;
  }

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('illustrationRequests');

  DocumentReference<Map<String, dynamic>> _creditsDoc(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('illustrationCredits')
        .doc('balance');
  }

  Future<IllustrationRequest> createRequest({
    required String uid,
    required String babyId,
    required String memoryId,
    required String sourcePhotoStoragePath,
    required String sourcePhotoUrl,
    required String requestType,
    required String promptVersion,
    String style = IllustrationStyle.defaultStyle,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      throw StateError('Illustration requests require a signed-in user.');
    }

    final now = DateTime.now();
    final doc = _requests.doc();
    final request = IllustrationRequest(
      id: doc.id,
      uid: uid,
      babyId: babyId,
      memoryId: memoryId,
      sourcePhotoStoragePath: sourcePhotoStoragePath,
      sourcePhotoUrl: sourcePhotoUrl,
      status: IllustrationRequestStatus.pending,
      requestType: requestType,
      promptVersion: promptVersion,
      style: IllustrationStyle.sanitize(style),
      resultStoragePath: null,
      resultImageUrl: null,
      errorCode: null,
      errorMessage: null,
      createdAt: now,
      updatedAt: now,
    );

    await doc.set(request.toMap());
    _log(
      'Created illustration request requestId=${request.id} '
      'memoryId=$memoryId babyId=$babyId type=$requestType style=$style',
    );

    // TODO(backend): Cloud Function worker should:
    // 1) validate caller auth and request ownership
    // 2) validate and reserve illustration credits atomically
    // 3) load source photo from Firebase Storage
    // 4) call Replicate image-to-image with the active prompt version
    // 5) save the result image back to Firebase Storage
    // 6) update request status/result fields and decrement credits
    return request;
  }

  Stream<IllustrationRequest?> watchRequest(String requestId) {
    return _requests.doc(requestId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return IllustrationRequest.fromDoc(doc);
    });
  }

  Stream<List<IllustrationRequest>> watchUserRequests(String uid) {
    return _requests
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map(IllustrationRequest.fromDoc).toList(),
        );
  }

  Stream<UserIllustrationCredits> watchCredits(String uid) {
    return _creditsDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return UserIllustrationCredits.empty(uid);
      return UserIllustrationCredits.fromDoc(uid, doc);
    });
  }

  /// One-shot read. Returns empty credits if doc does not exist yet.
  Future<UserIllustrationCredits> readCredits(String uid) async {
    final doc = await _creditsDoc(uid).get();
    if (!doc.exists) return UserIllustrationCredits.empty(uid);
    return UserIllustrationCredits.fromDoc(uid, doc);
  }

}
