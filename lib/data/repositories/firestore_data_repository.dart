import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../models/baby.dart';
import 'data_repository.dart';

class FirestoreDataRepository implements DataRepository {
  FirestoreDataRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static final Map<String, DateTime> _docWriteLocks = {};
  static const bool _debugLogs = true;

  void _log(String message) {
    if (kDebugMode && _debugLogs) {
      debugPrint('[FirestoreDataRepository] $message');
    }
  }

  bool _isAnonymousOrSignedOut() {
    final u = _auth.currentUser;
    return u == null || u.isAnonymous;
  }

  void _skip(String op) {
    _log('[GUARD] skip Firestore $op: user is anonymous/signed-out');
  }

  bool _acquireDocWriteLock(String key) {
    final now = DateTime.now();
    final last = _docWriteLocks[key];
    if (last != null && now.difference(last) < const Duration(seconds: 1)) {
      _log('Skipping rapid duplicate write key=$key');
      return false;
    }
    _docWriteLocks[key] = now;
    return true;
  }

  CollectionReference<Map<String, dynamic>> _userCollection(
    String uid,
    String path,
  ) {
    return _firestore.collection('users').doc(uid).collection(path);
  }

  DocumentReference<Map<String, dynamic>> _sharedBabyRef(String babyId) {
    return _firestore.collection('babies').doc(babyId);
  }

  CollectionReference<Map<String, dynamic>> _sharedBabyCollection(
    String babyId,
    String path,
  ) {
    return _sharedBabyRef(babyId).collection(path);
  }

  DateTime _toDateTime(dynamic value, {DateTime? fallback}) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    }
    return fallback ?? DateTime.now();
  }

  DateTime? _toOptionalDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  Map<String, dynamic> _recordDataPayload(Map<String, dynamic> raw) {
    final payload = Map<String, dynamic>.from(raw);
    payload.remove('id');
    payload.remove('babyId');
    payload.remove('type');
    payload.remove('createdAt');
    payload.remove('updatedAt');
    payload.remove('localUpdatedAt');
    return payload;
  }

  Future<int> _deleteAllPaginated(
    Query<Map<String, dynamic>> query, {
    int pageSize = 400,
    String operation = 'unknown',
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip(operation);
      return 0;
    }
    int totalDeleted = 0;

    while (true) {
      final snap = await query.limit(pageSize).get();
      if (snap.docs.isEmpty) break;

      WriteBatch batch = _firestore.batch();
      int batchOps = 0;
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
        batchOps++;
        totalDeleted++;
        if (batchOps == 450) {
          await batch.commit();
          batch = _firestore.batch();
          batchOps = 0;
        }
      }
      if (batchOps > 0) {
        await batch.commit();
      }
    }
    return totalDeleted;
  }

  Future<void> _setWithServerTimestamps(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> payload,
  ) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:_setWithServerTimestamps');
      return;
    }
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final existing = snap.data();
      final existingPayload = Map<String, dynamic>.from(
        (existing?['data'] as Map?) ?? const <String, dynamic>{},
      );
      final incomingPayload = Map<String, dynamic>.from(
        (payload['data'] as Map?) ?? const <String, dynamic>{},
      );
      final existingDeleted =
          existing?['isDeleted'] == true ||
          existingPayload['isDeleted'] == true;
      final incomingDeleted =
          payload['isDeleted'] == true || incomingPayload['isDeleted'] == true;
      if (existingDeleted && !incomingDeleted) {
        _log('Skipping resurrection write for doc=${ref.id}');
        return;
      }
      final data = <String, dynamic>{
        ...payload,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (!snap.exists || snap.data()?['createdAt'] == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      tx.set(ref, data, SetOptions(merge: true));
    });
  }

  String _resolveRecordType(Map<String, dynamic> row) {
    final explicit = (row['type'] ?? '').toString().trim().toLowerCase();
    if (explicit.isNotEmpty) return explicit;

    if (row.containsKey('baslangic') || row.containsKey('bitis')) {
      return 'sleep';
    }
    if (row.containsKey('diaperType') || row.containsKey('notlar')) {
      return 'diaper';
    }
    if (row.containsKey('boy') || row.containsKey('kilo')) return 'growth';
    if (row.containsKey('donem') || row.containsKey('durum')) return 'vaccine';
    if (row.containsKey('photoStyle') || row.containsKey('photoPath')) {
      return 'milestone';
    }
    if (row.containsKey('baslik') || row.containsKey('emoji')) return 'memory';

    final tur = (row['tur'] ?? '').toString().trim().toLowerCase();
    if (tur == 'anne') return 'nursing';
    return 'feeding';
  }

  Future<void> _upsertRecordDocs(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> records,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:_upsertRecordDocs');
      return;
    }
    if (records.isEmpty) return;
    final col = _sharedBabyCollection(babyId, 'records');

    for (final row in records) {
      final id = (row['id'] ?? '').toString();
      if (id.isEmpty) continue;
      final lockKey = 'records:$id';
      if (!_acquireDocWriteLock(lockKey)) continue;

      final type = _resolveRecordType(row);
      final payload = _recordDataPayload(row);
      final ref = col.doc(id);

      await _setWithServerTimestamps(ref, {
        'id': id,
        'babyId': babyId,
        'type': type,
        'data': payload,
      });
    }
  }

  Future<void> _deleteRecordDocsByTypes(
    String uid, {
    required String babyId,
    required Set<String> types,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:_deleteRecordDocsByTypes');
      return;
    }
    final col = _sharedBabyCollection(babyId, 'records');
    for (final type in types) {
      await _deleteAllPaginated(
        col.where('type', isEqualTo: type),
        operation: 'write:_deleteRecordDocsByTypes:$type',
      );
    }
  }

  Future<void> _deleteDocsByBabyId(
    String uid, {
    required String collection,
    required String babyId,
    required String operation,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip(operation);
      return;
    }
    await _deleteAllPaginated(
      _sharedBabyCollection(babyId, collection),
      operation: operation,
    );
  }

  Future<void> _copyLegacyDocsToSharedCollection(
    QuerySnapshot<Map<String, dynamic>> legacySnap,
    CollectionReference<Map<String, dynamic>> sharedCol, {
    required String operation,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip(operation);
      return;
    }
    if (legacySnap.docs.isEmpty) return;

    WriteBatch batch = _firestore.batch();
    var batchOps = 0;
    for (final doc in legacySnap.docs) {
      batch.set(sharedCol.doc(doc.id), doc.data(), SetOptions(merge: true));
      batchOps++;
      if (batchOps == 450) {
        await batch.commit();
        batch = _firestore.batch();
        batchOps = 0;
      }
    }
    if (batchOps > 0) {
      await batch.commit();
    }
  }

  Baby _parseBabyDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Baby(
      id: (data['id'] ?? doc.id).toString(),
      name: (data['name'] ?? 'Baby').toString(),
      birthDate: _toDateTime(data['birthDate']),
      photoPath:
          data['photoLocalPath']?.toString() ??
          data['baby_photo_path']?.toString() ??
          data['photoPath']?.toString(),
      photoStoragePath: data['photoStoragePath']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  @override
  Future<RepositoryDataBundle> fetchAllUserData(String uid) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('read:fetchAllUserData');
      return const RepositoryDataBundle(
        babies: [],
        mamaKayitlari: [],
        kakaKayitlari: [],
        uykuKayitlari: [],
        boyKiloKayitlari: [],
        asiKayitlari: [],
        milestones: [],
        anilar: [],
        ilacKayitlari: [],
        ilacDozKayitlari: [],
      );
    }
    final userBabiesRef = _userCollection(uid, 'babies');
    final sharedIndexRef = _userCollection(uid, 'sharedBabies');

    final userBabiesSnap = await userBabiesRef
        .orderBy('createdAt', descending: true)
        .get();
    final sharedIndexSnap = await sharedIndexRef.get();

    final legacyBabyDocsById =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    final orderedBabyIds = <String>[];

    for (final doc in userBabiesSnap.docs) {
      legacyBabyDocsById[doc.id] = doc;
      orderedBabyIds.add(doc.id);
    }

    for (final doc in sharedIndexSnap.docs) {
      final babyId = (doc.data()['babyId'] as String?) ?? doc.id;
      if (babyId.isEmpty || orderedBabyIds.contains(babyId)) continue;
      orderedBabyIds.add(babyId);
    }

    final babies = <Baby>[];
    final allRecordDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    final allMedicationDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    final allMedicationLogDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    final ownedWithMembers = <String>{};

    for (final babyId in orderedBabyIds) {
      final legacyBabyDoc = legacyBabyDocsById[babyId];

      if (legacyBabyDoc != null) {
        await _writeSharedBabiesIndexIfMissing(uid, babyId);
        // Legacy owner babies may not have a top-level mirror yet.
        // Create/merge the mirror before the first read so startup sync does
        // not hit a permission-denied read on a missing babies/{babyId} doc.
        await _writeBabyMirrorDoc(uid, _parseBabyDoc(legacyBabyDoc));
      }

      final sharedBabySnap = await _sharedBabyRef(babyId).get();
      final sharedBabyData = sharedBabySnap.data();
      final sharedOwnerId = sharedBabyData?['ownerId'] as String?;
      final isOwnedByCurrentUser =
          (sharedOwnerId != null && sharedOwnerId == uid) ||
          legacyBabyDoc != null;

      // Track owned babies that have co-parents so the UI can show a badge.
      if (isOwnedByCurrentUser) {
        final membersMap = sharedBabyData?['members'];
        if (membersMap is Map && membersMap.isNotEmpty) {
          ownedWithMembers.add(babyId);
        }
      }

      var sharedRecordsSnap = await _sharedBabyCollection(babyId, 'records')
          .orderBy('createdAt', descending: true)
          .get();
      var sharedMedicationsSnap = await _sharedBabyCollection(
        babyId,
        'medications',
      ).orderBy('createdAt', descending: true).get();
      var sharedMedicationLogsSnap = await _sharedBabyCollection(
        babyId,
        'medicationLogs',
      ).orderBy('createdAt', descending: true).get();

      if (isOwnedByCurrentUser && legacyBabyDoc != null) {
        final legacyRecordsSnap = await _userCollection(uid, 'records')
            .where('babyId', isEqualTo: babyId)
            .orderBy('createdAt', descending: true)
            .get();
        final legacyMedicationsSnap = await _userCollection(uid, 'medications')
            .where('babyId', isEqualTo: babyId)
            .orderBy('createdAt', descending: true)
            .get();
        final legacyMedicationLogsSnap =
            await _userCollection(uid, 'medicationLogs')
                .where('babyId', isEqualTo: babyId)
                .orderBy('createdAt', descending: true)
                .get();

        final shouldMigrateRecords =
            sharedRecordsSnap.docs.isEmpty && legacyRecordsSnap.docs.isNotEmpty;
        final shouldMigrateMedications =
            sharedMedicationsSnap.docs.isEmpty &&
            legacyMedicationsSnap.docs.isNotEmpty;
        final shouldMigrateMedicationLogs =
            sharedMedicationLogsSnap.docs.isEmpty &&
            legacyMedicationLogsSnap.docs.isNotEmpty;

        if (shouldMigrateRecords ||
            shouldMigrateMedications ||
            shouldMigrateMedicationLogs) {
          _log('Lazy-migrating shared baby data babyId=$babyId uid=$uid');
          if (shouldMigrateRecords) {
            await _copyLegacyDocsToSharedCollection(
              legacyRecordsSnap,
              _sharedBabyCollection(babyId, 'records'),
              operation: 'migrate:records:$babyId',
            );
          }
          if (shouldMigrateMedications) {
            await _copyLegacyDocsToSharedCollection(
              legacyMedicationsSnap,
              _sharedBabyCollection(babyId, 'medications'),
              operation: 'migrate:medications:$babyId',
            );
          }
          if (shouldMigrateMedicationLogs) {
            await _copyLegacyDocsToSharedCollection(
              legacyMedicationLogsSnap,
              _sharedBabyCollection(babyId, 'medicationLogs'),
              operation: 'migrate:medicationLogs:$babyId',
            );
          }

          sharedRecordsSnap = await _sharedBabyCollection(babyId, 'records')
              .orderBy('createdAt', descending: true)
              .get();
          sharedMedicationsSnap = await _sharedBabyCollection(
            babyId,
            'medications',
          ).orderBy('createdAt', descending: true).get();
          sharedMedicationLogsSnap = await _sharedBabyCollection(
            babyId,
            'medicationLogs',
          ).orderBy('createdAt', descending: true).get();
        }
      }

      final babyData = sharedBabySnap.data() ?? legacyBabyDoc?.data();
      if (babyData != null) {
        babies.add(
          Baby(
            id: babyId,
            name: (babyData['name'] ?? 'Baby').toString(),
            birthDate: _toDateTime(babyData['birthDate']),
            photoPath:
                babyData['photoLocalPath']?.toString() ??
                babyData['baby_photo_path']?.toString() ??
                babyData['photoPath']?.toString(),
            photoStoragePath: babyData['photoStoragePath']?.toString(),
            photoUrl: babyData['photoUrl']?.toString(),
            createdAt: _toDateTime(babyData['createdAt']),
          ),
        );
      }

      allRecordDocs.addAll(sharedRecordsSnap.docs);
      allMedicationDocs.addAll(sharedMedicationsSnap.docs);
      allMedicationLogDocs.addAll(sharedMedicationLogsSnap.docs);
    }

    final mama = <Map<String, dynamic>>[];
    final kaka = <Map<String, dynamic>>[];
    final uyku = <Map<String, dynamic>>[];
    final boyKilo = <Map<String, dynamic>>[];
    final asilar = <Map<String, dynamic>>[];
    final milestones = <Map<String, dynamic>>[];
    final anilar = <Map<String, dynamic>>[];

    for (final doc in allRecordDocs) {
      final row = doc.data();
      final type = (row['type'] ?? '').toString();
      final id = (row['id'] ?? doc.id).toString();
      final babyId = (row['babyId'] ?? '').toString();
      final updatedAt = _toDateTime(row['updatedAt'] ?? row['createdAt']);
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});
      final isDeleted = data['isDeleted'] == true || row['isDeleted'] == true;
      final deletedAt = _toOptionalDateTime(
        data['deletedAt'] ?? row['deletedAt'],
      );

      if (type == 'feeding' || type == 'nursing') {
        if (isDeleted) {
          mama.add({
            'id': id,
            'babyId': babyId,
            'tur': data['tur'] ?? (type == 'nursing' ? 'anne' : ''),
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          mama.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'tur':
                data['tur'] ?? (type == 'nursing' ? 'anne' : data['tur'] ?? ''),
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      } else if (type == 'diaper') {
        if (isDeleted) {
          kaka.add({
            'id': id,
            'babyId': babyId,
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          kaka.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      } else if (type == 'sleep') {
        final start = _toDateTime(
          data['baslangic'] ?? data['startAt'] ?? updatedAt,
        );
        final end = _toDateTime(data['bitis'] ?? data['endAt'] ?? updatedAt);
        if (isDeleted) {
          uyku.add({
            'id': id,
            'babyId': babyId,
            'baslangic': start,
            'bitis': end,
            'sure': Duration(
              minutes: _toInt(
                data['sure'] ?? data['durationMinutes'],
                fallback: end.difference(start).inMinutes,
              ),
            ),
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          uyku.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'baslangic': start,
            'bitis': end,
            'sure': Duration(
              minutes: _toInt(
                data['sure'] ?? data['durationMinutes'],
                fallback: end.difference(start).inMinutes,
              ),
            ),
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      } else if (type == 'growth') {
        if (isDeleted) {
          boyKilo.add({
            'id': id,
            'babyId': babyId,
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          boyKilo.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      } else if (type == 'vaccine') {
        if (isDeleted) {
          asilar.add({
            'id': id,
            'babyId': babyId,
            'tarih': data['tarih'] != null ? _toDateTime(data['tarih']) : null,
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          asilar.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'tarih': data['tarih'] != null ? _toDateTime(data['tarih']) : null,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      } else if (type == 'milestone') {
        if (isDeleted) {
          milestones.add({
            'id': id,
            'babyId': babyId,
            'date': _toDateTime(data['date'] ?? data['tarih'] ?? updatedAt),
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          milestones.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'date': _toDateTime(data['date'] ?? data['tarih'] ?? updatedAt),
            'photoPath': data['photoLocalPath'] ?? data['photoPath'],
            'photoStoragePath': data['photoStoragePath'],
            'photoUrl': data['photoUrl'],
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      } else if (type == 'memory') {
        if (isDeleted) {
          anilar.add({
            'id': id,
            'babyId': babyId,
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'isDeleted': true,
            'deletedAt': deletedAt,
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        } else {
          anilar.add({
            ...data,
            'id': id,
            'babyId': babyId,
            'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
            'baslik': data['baslik'] ?? data['title'],
            'not': data['not'] ?? data['note'],
            'photoPath': data['photoLocalPath'] ?? data['photoPath'],
            'photoStoragePath': data['photoStoragePath'],
            'photoUrl': data['photoUrl'],
            'updatedAt': updatedAt,
            'localUpdatedAt': updatedAt,
          });
        }
      }
    }

    final ilaclar = allMedicationDocs.map((doc) {
      final row = doc.data();
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});
      final updatedAt = _toDateTime(row['updatedAt'] ?? row['createdAt']);
      return <String, dynamic>{
        ...data,
        'id': (row['id'] ?? doc.id).toString(),
        'babyId': (row['babyId'] ?? '').toString(),
        'createdAt': _toDateTime(row['createdAt'], fallback: updatedAt),
        'updatedAt': updatedAt,
        'localUpdatedAt': updatedAt,
        'isDeleted': data['isDeleted'] == true || row['isDeleted'] == true,
        'deletedAt': _toOptionalDateTime(data['deletedAt'] ?? row['deletedAt']),
      };
    }).toList();

    final dozlar = allMedicationLogDocs.map((doc) {
      final row = doc.data();
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});
      final updatedAt = _toDateTime(row['updatedAt'] ?? row['createdAt']);
      return <String, dynamic>{
        ...data,
        'id': (row['id'] ?? doc.id).toString(),
        'babyId': (row['babyId'] ?? '').toString(),
        'medicationId': row['medicationId'] ?? data['medicationId'],
        'givenAt': _toDateTime(
          data['givenAt'] ?? row['createdAt'] ?? updatedAt,
        ),
        'updatedAt': updatedAt,
        'localUpdatedAt': updatedAt,
        'isDeleted': data['isDeleted'] == true || row['isDeleted'] == true,
        'deletedAt': _toOptionalDateTime(data['deletedAt'] ?? row['deletedAt']),
      };
    }).toList();

    return RepositoryDataBundle(
      babies: babies,
      mamaKayitlari: mama,
      kakaKayitlari: kaka,
      uykuKayitlari: uyku,
      boyKiloKayitlari: boyKilo,
      asiKayitlari: asilar,
      milestones: milestones,
      anilar: anilar,
      ilacKayitlari: ilaclar,
      ilacDozKayitlari: dozlar,
      ownedBabyIdsWithMembers: ownedWithMembers,
    );
  }

  @override
  Future<void> replaceBabies(String uid, List<Baby> babies) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:replaceBabies');
      return;
    }
    if (babies.isEmpty) return;
    for (final baby in babies) {
      if (!_acquireDocWriteLock('babies:${baby.id}')) continue;
      DocumentSnapshot<Map<String, dynamic>>? sharedBabySnap;
      try {
        sharedBabySnap = await _sharedBabyRef(baby.id).get();
      } catch (e) {
        _log('replaceBabies shared mirror read fallback babyId=${baby.id}: $e');
      }
      final sharedOwnerId = sharedBabySnap?.data()?['ownerId'] as String?;
      final isSharedMemberBaby =
          (sharedBabySnap?.exists ?? false) &&
          sharedOwnerId != null &&
          sharedOwnerId != uid;

      if (!isSharedMemberBaby) {
        final col = _userCollection(uid, 'babies');
        await _setWithServerTimestamps(col.doc(baby.id), {
          'id': baby.id,
          'name': baby.name,
          'birthDate': Timestamp.fromDate(baby.birthDate),
          'photoLocalPath': baby.photoPath,
          'baby_photo_path': baby.photoPath,
          'photoStoragePath': baby.photoStoragePath,
          'photoUrl': baby.photoUrl,
        });
        await _writeOwnershipFieldsIfMissing(uid, baby.id);
      }

      await _writeBabyMirrorDoc(
        uid,
        baby,
        ownerId: sharedOwnerId ?? uid,
      );
    }
  }

  /// Writes a lightweight mirror of the baby document to the top-level
  /// babies/{babyId} collection. Cloud Functions (sendInvitation, acceptInvitation)
  /// and co-parent devices read from this path.
  /// Uses merge:true — the members map written by acceptInvitation is preserved.
  Future<void> _writeBabyMirrorDoc(
    String uid,
    Baby baby, {
    String? ownerId,
  }) async {
    if (_isAnonymousOrSignedOut()) return;
    final ref = _firestore.collection('babies').doc(baby.id);
    try {
      await ref.set({
        'name': baby.name,
        'birthDate': Timestamp.fromDate(baby.birthDate),
        'photoUrl': baby.photoUrl,
        'photoStoragePath': baby.photoStoragePath,
        'ownerId': ownerId ?? uid,
      }, SetOptions(merge: true));
    } catch (e) {
      _log('_writeBabyMirrorDoc error babyId=${baby.id}: $e');
    }
  }

  /// Writes ownerId and members map on the baby document only when they are
  /// absent. Safe to call on every sync — uses set(merge:true) with a
  /// transaction that no-ops if the fields already exist.
  Future<void> _writeOwnershipFieldsIfMissing(
    String uid,
    String babyId,
  ) async {
    if (_isAnonymousOrSignedOut()) return;
    final ref = _userCollection(uid, 'babies').doc(babyId);
    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) return;
        final data = snap.data()!;
        // Only write if either field is missing.
        final hasOwner = data.containsKey('ownerId');
        final hasMembers = data.containsKey('members');
        if (hasOwner && hasMembers) return;
        final patch = <String, dynamic>{};
        if (!hasOwner) patch['ownerId'] = uid;
        if (!hasMembers) {
          patch['members'] = {
            uid: {
              'role': 'owner',
              'joinedAt': FieldValue.serverTimestamp(),
            },
          };
        }
        tx.set(ref, patch, SetOptions(merge: true));
      });
      // Also ensure the sharedBabies index entry exists for the owner.
      await _writeSharedBabiesIndexIfMissing(uid, babyId);
    } catch (e) {
      _log('_writeOwnershipFieldsIfMissing error babyId=$babyId: $e');
    }
  }

  /// Writes users/{uid}/sharedBabies/{babyId} if the document does not yet
  /// exist. This is the helper index used for future shared-parenting queries.
  Future<void> _writeSharedBabiesIndexIfMissing(
    String uid,
    String babyId,
  ) async {
    if (_isAnonymousOrSignedOut()) return;
    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('sharedBabies')
        .doc(babyId);
    try {
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) return;
        tx.set(ref, {
          'babyId': babyId,
          'role': 'owner',
          'addedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      _log('_writeSharedBabiesIndexIfMissing error babyId=$babyId: $e');
    }
  }

  @override
  Future<void> replaceRecordsForBaby(
    String uid, {
    required String babyId,
    required Set<String> types,
    required List<Map<String, dynamic>> records,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:replaceRecordsForBaby');
      return;
    }
    // Empty local set means explicit local clear/reset; reflect that in cloud too.
    if (records.isEmpty) {
      await _deleteRecordDocsByTypes(uid, babyId: babyId, types: types);
      return;
    }
    final filtered = records.where((row) {
      final type = _resolveRecordType(row);
      return types.contains(type);
    }).toList();
    // If nothing survives filtering, clear requested types remotely to avoid resurrection.
    if (filtered.isEmpty) {
      await _deleteRecordDocsByTypes(uid, babyId: babyId, types: types);
      return;
    }
    await _upsertRecordDocs(uid, babyId: babyId, records: filtered);
  }

  @override
  Future<void> replaceMedicationsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> medications,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:replaceMedicationsForBaby');
      return;
    }
    if (medications.isEmpty) {
      await _deleteDocsByBabyId(
        uid,
        collection: 'medications',
        babyId: babyId,
        operation: 'write:replaceMedicationsForBaby:clear',
      );
      return;
    }
    final col = _sharedBabyCollection(babyId, 'medications');
    for (final med in medications) {
      final id = (med['id'] ?? '').toString();
      if (id.isEmpty) continue;
      if (!_acquireDocWriteLock('medications:$id')) continue;
      final data = Map<String, dynamic>.from(med)
        ..remove('id')
        ..remove('babyId')
        ..remove('createdAt')
        ..remove('updatedAt')
        ..remove('localUpdatedAt');
      await _setWithServerTimestamps(col.doc(id), {
        'id': id,
        'babyId': babyId,
        'data': data,
      });
    }
  }

  @override
  Future<void> replaceMedicationLogsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> logs,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:replaceMedicationLogsForBaby');
      return;
    }
    if (logs.isEmpty) {
      await _deleteDocsByBabyId(
        uid,
        collection: 'medicationLogs',
        babyId: babyId,
        operation: 'write:replaceMedicationLogsForBaby:clear',
      );
      return;
    }
    final col = _sharedBabyCollection(babyId, 'medicationLogs');
    for (final log in logs) {
      final id = (log['id'] ?? '').toString();
      if (id.isEmpty) continue;
      if (!_acquireDocWriteLock('medicationLogs:$id')) continue;
      final data = Map<String, dynamic>.from(log)
        ..remove('id')
        ..remove('babyId')
        ..remove('medicationId')
        ..remove('createdAt')
        ..remove('updatedAt')
        ..remove('localUpdatedAt');
      await _setWithServerTimestamps(col.doc(id), {
        'id': id,
        'babyId': babyId,
        'medicationId': (log['medicationId'] ?? '').toString(),
        'data': data,
      });
    }
  }

  @override
  Future<void> replaceMemoriesForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> memories,
  }) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:replaceMemoriesForBaby');
      return;
    }
    if (memories.isEmpty) {
      await _deleteRecordDocsByTypes(
        uid,
        babyId: babyId,
        types: const {'memory', 'milestone'},
      );
      return;
    }
    final converted = memories.map((m) {
      final map = Map<String, dynamic>.from(m);
      map['type'] = (map['type'] ?? '').toString().isNotEmpty
          ? map['type']
          : ((map['photoStyle'] != null || map['photoLocalPath'] != null)
                ? 'milestone'
                : 'memory');
      return map;
    }).toList();
    await _upsertRecordDocs(uid, babyId: babyId, records: converted);
  }

  @override
  Future<void> deleteBabyData(String uid, {required String babyId}) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:deleteBabyData');
      return;
    }
    final userRef = _firestore.collection('users').doc(uid);
    final sharedBabySnap = await _sharedBabyRef(babyId).get();
    final sharedOwnerId = sharedBabySnap.data()?['ownerId'] as String?;
    final isOwner = sharedOwnerId == null || sharedOwnerId == uid;

    final results = await Future.wait<int>([
      _deleteAllPaginated(
        userRef.collection('records').where('babyId', isEqualTo: babyId),
        operation: 'write:deleteBabyData:legacyRecords',
      ),
      _deleteAllPaginated(
        userRef.collection('medications').where('babyId', isEqualTo: babyId),
        operation: 'write:deleteBabyData:legacyMedications',
      ),
      _deleteAllPaginated(
        userRef
            .collection('medicationLogs')
            .where('babyId', isEqualTo: babyId),
        operation: 'write:deleteBabyData:legacyMedicationLogs',
      ),
      _deleteAllPaginated(
        userRef.collection('memories').where('babyId', isEqualTo: babyId),
        operation: 'write:deleteBabyData:legacyMemories',
      ),
      if (isOwner)
        _deleteAllPaginated(
          _sharedBabyCollection(babyId, 'records'),
          operation: 'write:deleteBabyData:sharedRecords',
        )
      else
        Future.value(0),
      if (isOwner)
        _deleteAllPaginated(
          _sharedBabyCollection(babyId, 'medications'),
          operation: 'write:deleteBabyData:sharedMedications',
        )
      else
        Future.value(0),
      if (isOwner)
        _deleteAllPaginated(
          _sharedBabyCollection(babyId, 'medicationLogs'),
          operation: 'write:deleteBabyData:sharedMedicationLogs',
        )
      else
        Future.value(0),
      if (isOwner)
        _deleteAllPaginated(
          _sharedBabyCollection(babyId, 'allergies'),
          operation: 'write:deleteBabyData:sharedAllergies',
        )
      else
        Future.value(0),
    ]);

    try {
      await userRef.collection('babies').doc(babyId).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') rethrow;
    }

    if (isOwner) {
      try {
        await _sharedBabyRef(babyId).delete();
      } on FirebaseException catch (e) {
        if (e.code != 'not-found') rethrow;
      }
    }

    _log(
      'deleteBabyData uid=$uid babyId=$babyId '
      'legacyRecords=${results[0]} legacyMedications=${results[1]} '
      'legacyMedicationLogs=${results[2]} legacyMemories=${results[3]} '
      'sharedRecords=${results[4]} sharedMedications=${results[5]} '
      'sharedMedicationLogs=${results[6]} sharedAllergies=${results[7]} '
      'owner=$isOwner',
    );
  }

  @override
  Future<void> clearUserSubtree(String uid) async {
    if (_isAnonymousOrSignedOut()) {
      _skip('write:clearUserSubtree');
      return;
    }
    await Future.wait([
      _deleteAllPaginated(
        _userCollection(uid, 'records'),
        operation: 'write:clearUserSubtree:records',
      ),
      _deleteAllPaginated(
        _userCollection(uid, 'medications'),
        operation: 'write:clearUserSubtree:medications',
      ),
      _deleteAllPaginated(
        _userCollection(uid, 'medicationLogs'),
        operation: 'write:clearUserSubtree:medicationLogs',
      ),
      _deleteAllPaginated(
        _userCollection(uid, 'memories'),
        operation: 'write:clearUserSubtree:memories',
      ),
      _deleteAllPaginated(
        _userCollection(uid, 'babies'),
        operation: 'write:clearUserSubtree:babies',
      ),
    ]);
  }
}
