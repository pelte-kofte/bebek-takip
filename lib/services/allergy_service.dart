import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/allergy.dart';
import '../models/baby.dart';
import '../models/veri_yonetici.dart';

class AllergyAccessDeniedException implements Exception {
  const AllergyAccessDeniedException([
    this.message = "You don't have access to this baby's data.",
  ]);

  final String message;

  @override
  String toString() => message;
}

class AllergyService {
  AllergyService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _babyDoc(String babyId) =>
      _firestore.collection('babies').doc(babyId);

  CollectionReference<Map<String, dynamic>> _collection(String babyId) =>
      _firestore.collection('babies').doc(babyId).collection('allergies');

  Future<User> _ensureAuthenticatedUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Authentication is unavailable');
    }
    return user;
  }

  Baby? _babyForId(String babyId) {
    for (final baby in VeriYonetici.getBabies()) {
      if (baby.id == babyId) {
        return baby;
      }
    }
    return null;
  }

  bool _isKnownOwnedBaby(String babyId) {
    if (VeriYonetici.isSharedBaby(babyId)) {
      return false;
    }
    final activeBaby = VeriYonetici.getActiveBabyOrNull();
    return _babyForId(babyId) != null || activeBaby?.id == babyId;
  }

  void _logAccessState({
    required String babyId,
    required String uid,
    required bool exists,
    required bool isKnownOwnedBaby,
    required String? ownerId,
    required Map<String, dynamic> members,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '[AllergyService] babyId=$babyId currentUser.uid=$uid '
      'babyDoc.exists=$exists isKnownOwnedBaby=$isKnownOwnedBaby '
      'ownerId=$ownerId members=$members',
    );
  }

  static String formatUserFacingError(Object error) {
    if (error is AllergyAccessDeniedException) {
      return error.message;
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return "You don't have access to this baby's data.";
        case 'unavailable':
          return 'The allergy service is temporarily unavailable. Please try again.';
        default:
          return 'Could not save the allergy. Please try again.';
      }
    }
    if (error is StateError || error is ArgumentError) {
      return error.toString();
    }
    return 'Could not save the allergy. Please try again.';
  }

  Future<void> _ensureBabyAccess(
    String babyId,
    String uid, {
    bool createIfMissing = false,
  }) async {
    final doc = _babyDoc(babyId);
    final snapshot = await doc.get();
    final data = snapshot.data();
    final isKnownOwnedBaby = _isKnownOwnedBaby(babyId);
    final ownerId = data?['ownerId'] as String?;
    final members = data?['members'] is Map
        ? Map<String, dynamic>.from(data!['members'] as Map)
        : <String, dynamic>{};

    _logAccessState(
      babyId: babyId,
      uid: uid,
      exists: snapshot.exists,
      isKnownOwnedBaby: isKnownOwnedBaby,
      ownerId: ownerId,
      members: members,
    );

    if (!snapshot.exists) {
      if (!createIfMissing || !isKnownOwnedBaby) {
        throw const AllergyAccessDeniedException();
      }

      await _repairOwnedBabyMirror(doc, babyId, uid);
      return;
    }

    if (ownerId == uid || members.containsKey(uid)) {
      return;
    }

    if (createIfMissing && isKnownOwnedBaby && ownerId == null) {
      await _repairOwnedBabyMirror(doc, babyId, uid);
      return;
    }

    throw const AllergyAccessDeniedException();
  }

  Future<void> _repairOwnedBabyMirror(
    DocumentReference<Map<String, dynamic>> doc,
    String babyId,
    String uid,
  ) async {
    final baby = _babyForId(babyId) ?? VeriYonetici.getActiveBabyOrNull();
    await doc.set({
      'name': baby?.name ?? VeriYonetici.getBabyName(),
      'birthDate': Timestamp.fromDate(
        baby?.birthDate ?? VeriYonetici.getBirthDate(),
      ),
      'photoUrl': baby?.photoUrl,
      'photoStoragePath': baby?.photoStoragePath,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Allergy>> watchAllergies(String babyId) async* {
    final user = await _ensureAuthenticatedUser();
    await _ensureBabyAccess(babyId, user.uid, createIfMissing: true);

    yield* _collection(babyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (snap, sink) {
              sink.add(snap.docs.map(Allergy.fromFirestore).toList());
            },
            handleError: (error, stackTrace, sink) {
              sink.addError(
                error is FirebaseException && error.code == 'permission-denied'
                    ? const AllergyAccessDeniedException()
                    : error,
                stackTrace,
              );
            },
          ),
        );
  }

  Future<void> addAllergy(String babyId, String name, {String? note}) async {
    final user = await _ensureAuthenticatedUser();

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) throw ArgumentError('Name must not be empty');

    await _ensureBabyAccess(babyId, user.uid, createIfMissing: true);

    await _collection(babyId).add({
      'name': trimmedName,
      'note': note?.trim().isEmpty == true ? null : note?.trim(),
      'createdAt': Timestamp.now(),
      'isActive': true,
      'createdBy': user.uid,
    });
  }

  Future<void> removeAllergy(String babyId, String allergyId) async {
    await _collection(babyId).doc(allergyId).delete();
  }

  Future<void> toggleAllergyActive(
    String babyId,
    String allergyId,
    bool isActive,
  ) async {
    await _collection(babyId).doc(allergyId).update({'isActive': isActive});
  }
}
