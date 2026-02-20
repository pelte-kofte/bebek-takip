import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/baby.dart';
import 'data_repository.dart';

class FirestoreDataRepository implements DataRepository {
  FirestoreDataRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static final Map<String, DateTime> _docWriteLocks = {};
  static const bool _debugLogs = true;

  void _log(String message) {
    if (kDebugMode && _debugLogs) {
      debugPrint('[FirestoreDataRepository] $message');
    }
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

  DateTime _toDateTime(dynamic value, {DateTime? fallback}) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    }
    return fallback ?? DateTime.now();
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
  }) async {
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
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
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
    if (records.isEmpty) return;
    final col = _userCollection(uid, 'records');

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

  @override
  Future<RepositoryDataBundle> fetchAllUserData(String uid) async {
    final babiesRef = _userCollection(uid, 'babies');
    final recordsRef = _userCollection(uid, 'records');
    final medicationsRef = _userCollection(uid, 'medications');
    final medicationLogsRef = _userCollection(uid, 'medicationLogs');

    final babiesSnap = await babiesRef
        .orderBy('createdAt', descending: true)
        .get();
    final recordsSnap = await recordsRef
        .orderBy('createdAt', descending: true)
        .get();
    final medicationsSnap = await medicationsRef
        .orderBy('createdAt', descending: true)
        .get();
    final logsSnap = await medicationLogsRef
        .orderBy('createdAt', descending: true)
        .get();

    final babies = babiesSnap.docs.map((doc) {
      final data = doc.data();
      return Baby(
        id: (data['id'] ?? doc.id).toString(),
        name: (data['name'] ?? 'Baby').toString(),
        birthDate: _toDateTime(data['birthDate']),
        photoPath: data['photoLocalPath']?.toString(),
        createdAt: _toDateTime(data['createdAt']),
      );
    }).toList();

    final mama = <Map<String, dynamic>>[];
    final kaka = <Map<String, dynamic>>[];
    final uyku = <Map<String, dynamic>>[];
    final boyKilo = <Map<String, dynamic>>[];
    final asilar = <Map<String, dynamic>>[];
    final milestones = <Map<String, dynamic>>[];
    final anilar = <Map<String, dynamic>>[];

    for (final doc in recordsSnap.docs) {
      final row = doc.data();
      final type = (row['type'] ?? '').toString();
      final id = (row['id'] ?? doc.id).toString();
      final babyId = (row['babyId'] ?? '').toString();
      final updatedAt = _toDateTime(row['updatedAt'] ?? row['createdAt']);
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});

      if (type == 'feeding' || type == 'nursing') {
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
      } else if (type == 'diaper') {
        kaka.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
        });
      } else if (type == 'sleep') {
        final start = _toDateTime(
          data['baslangic'] ?? data['startAt'] ?? updatedAt,
        );
        final end = _toDateTime(data['bitis'] ?? data['endAt'] ?? updatedAt);
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
      } else if (type == 'growth') {
        boyKilo.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
        });
      } else if (type == 'vaccine') {
        asilar.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': data['tarih'] != null ? _toDateTime(data['tarih']) : null,
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
        });
      } else if (type == 'milestone') {
        milestones.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'date': _toDateTime(data['date'] ?? data['tarih'] ?? updatedAt),
          'photoPath': data['photoLocalPath'] ?? data['photoPath'],
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
        });
      } else if (type == 'memory') {
        anilar.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': _toDateTime(data['tarih'] ?? data['date'] ?? updatedAt),
          'baslik': data['baslik'] ?? data['title'],
          'not': data['not'] ?? data['note'],
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
        });
      }
    }

    final ilaclar = medicationsSnap.docs.map((doc) {
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
      };
    }).toList();

    final dozlar = logsSnap.docs.map((doc) {
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
    );
  }

  @override
  Future<void> replaceBabies(String uid, List<Baby> babies) async {
    if (babies.isEmpty) return;
    final col = _userCollection(uid, 'babies');
    for (final baby in babies) {
      if (!_acquireDocWriteLock('babies:${baby.id}')) continue;
      await _setWithServerTimestamps(col.doc(baby.id), {
        'id': baby.id,
        'name': baby.name,
        'birthDate': Timestamp.fromDate(baby.birthDate),
        'photoLocalPath': baby.photoPath,
      });
    }
  }

  @override
  Future<void> replaceRecordsForBaby(
    String uid, {
    required String babyId,
    required Set<String> types,
    required List<Map<String, dynamic>> records,
  }) async {
    if (records.isEmpty) return;
    final filtered = records.where((row) {
      final type = _resolveRecordType(row);
      return types.contains(type);
    }).toList();
    await _upsertRecordDocs(uid, babyId: babyId, records: filtered);
  }

  @override
  Future<void> replaceMedicationsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> medications,
  }) async {
    if (medications.isEmpty) return;
    final col = _userCollection(uid, 'medications');
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
    if (logs.isEmpty) return;
    final col = _userCollection(uid, 'medicationLogs');
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
    if (memories.isEmpty) return;
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
    final userRef = _firestore.collection('users').doc(uid);
    final recordsQ = userRef
        .collection('records')
        .where('babyId', isEqualTo: babyId);
    final medicationsQ = userRef
        .collection('medications')
        .where('babyId', isEqualTo: babyId);
    final logsQ = userRef
        .collection('medicationLogs')
        .where('babyId', isEqualTo: babyId);
    final memoriesQ = userRef
        .collection('memories')
        .where('babyId', isEqualTo: babyId);

    final results = await Future.wait<int>([
      _deleteAllPaginated(recordsQ),
      _deleteAllPaginated(medicationsQ),
      _deleteAllPaginated(logsQ),
      _deleteAllPaginated(memoriesQ),
    ]);

    try {
      await userRef.collection('babies').doc(babyId).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') rethrow;
    }

    _log(
      'deleteBabyData uid=$uid babyId=$babyId '
      'records=${results[0]} medications=${results[1]} '
      'medicationLogs=${results[2]} memories=${results[3]}',
    );
  }

  @override
  Future<void> clearUserSubtree(String uid) async {
    await Future.wait([
      _deleteAllPaginated(_userCollection(uid, 'records')),
      _deleteAllPaginated(_userCollection(uid, 'medications')),
      _deleteAllPaginated(_userCollection(uid, 'medicationLogs')),
      _deleteAllPaginated(_userCollection(uid, 'memories')),
      _deleteAllPaginated(_userCollection(uid, 'babies')),
    ]);
  }
}
