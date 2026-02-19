import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/local/local_store.dart';
import '../data/repositories/data_repository.dart';
import '../data/stores/firestore_store.dart';
import '../models/baby.dart';

const bool kFirestoreDebugLogs = true;

class DataSyncService {
  DataSyncService({
    required LocalStore localStore,
    required FirestoreStore firestoreStore,
  }) : _localStore = localStore,
       _firestoreStore = firestoreStore;

  static const String migrationFlagKey = 'did_migrate_to_firestore_v1';

  final LocalStore _localStore;
  final FirestoreStore _firestoreStore;

  String migrationFlagKeyForUid(String uid) => '${migrationFlagKey}_$uid';

  void _log(String message) {
    if (kDebugMode && kFirestoreDebugLogs) {
      debugPrint('[DataSyncService] $message');
    }
  }

  DateTime _extractDate(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      final value = row[key];
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  DateTime? _extractOptionalDate(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  List<Map<String, dynamic>> _mergeById(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> remote, {
    required List<String> dateKeys,
  }) {
    final merged = <String, Map<String, dynamic>>{};

    for (final item in local) {
      final id = (item['id'] ?? '').toString();
      if (id.isEmpty) continue;
      merged[id] = Map<String, dynamic>.from(item);
    }

    for (final item in remote) {
      final id = (item['id'] ?? '').toString();
      if (id.isEmpty) continue;
      final existing = merged[id];
      if (existing == null) {
        merged[id] = Map<String, dynamic>.from(item);
        continue;
      }

      final localDate = _extractDate(existing, const [
        'localUpdatedAt',
        'updatedAt',
      ]);
      final remoteUpdatedAt = _extractOptionalDate(item, 'updatedAt');

      if (remoteUpdatedAt == null) {
        final mergedRow = Map<String, dynamic>.from(item);
        mergedRow.addAll(existing);
        merged[id] = mergedRow;
        _log(
          'Conflict resolved from local (id=$id, remote.updatedAt missing/null).',
        );
        continue;
      }

      if (remoteUpdatedAt.isAfter(localDate)) {
        final mergedRow = Map<String, dynamic>.from(existing);
        mergedRow.addAll(Map<String, dynamic>.from(item));
        merged[id] = mergedRow;
        _log(
          'Conflict resolved from Firestore (id=$id, remote.updatedAt newer).',
        );
      } else {
        final mergedRow = Map<String, dynamic>.from(item);
        mergedRow.addAll(existing);
        merged[id] = mergedRow;
        _log(
          'Conflict resolved from local (id=$id, local.localUpdatedAt newer).',
        );
      }
    }

    return merged.values.toList();
  }

  List<Baby> _mergeBabies(List<Baby> local, List<Baby> remote) {
    final byId = <String, Baby>{};
    for (final baby in local) {
      byId[baby.id] = baby;
    }
    for (final baby in remote) {
      final current = byId[baby.id];
      if (current == null || baby.createdAt.isAfter(current.createdAt)) {
        byId[baby.id] = baby;
      }
    }
    return byId.values.toList();
  }

  RepositoryDataBundle mergeCoreData({
    required RepositoryDataBundle local,
    required RepositoryDataBundle remote,
  }) {
    return RepositoryDataBundle(
      babies: _mergeBabies(local.babies, remote.babies),
      mamaKayitlari: _mergeById(
        local.mamaKayitlari,
        remote.mamaKayitlari,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      kakaKayitlari: _mergeById(
        local.kakaKayitlari,
        remote.kakaKayitlari,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      uykuKayitlari: _mergeById(
        local.uykuKayitlari,
        remote.uykuKayitlari,
        dateKeys: const [
          'updatedAt',
          'localUpdatedAt',
          'bitis',
          'endAt',
          'createdAt',
        ],
      ),
      boyKiloKayitlari: _mergeById(
        local.boyKiloKayitlari,
        remote.boyKiloKayitlari,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      asiKayitlari: _mergeById(
        local.asiKayitlari,
        remote.asiKayitlari,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      milestones: _mergeById(
        local.milestones,
        remote.milestones,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'date', 'createdAt'],
      ),
      anilar: _mergeById(
        local.anilar,
        remote.anilar,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      ilacKayitlari: _mergeById(
        local.ilacKayitlari,
        remote.ilacKayitlari,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'createdAt'],
      ),
      ilacDozKayitlari: _mergeById(
        local.ilacDozKayitlari,
        remote.ilacDozKayitlari,
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'givenAt', 'createdAt'],
      ),
    );
  }

  Future<bool> shouldRunInitialMigration(String uid) async {
    final should = !(_localStore.getBool(migrationFlagKeyForUid(uid)) ?? false);
    _log('shouldRunInitialMigration uid=$uid -> $should');
    return should;
  }

  Future<void> markInitialMigrationDone(String uid) async {
    await _localStore.setBool(migrationFlagKeyForUid(uid), true);
    _log('markInitialMigrationDone uid=$uid');
  }

  Future<RepositoryDataBundle> pullRemoteCoreData(String uid) async {
    _log('Pulling core data from Firestore for uid=$uid');
    return _firestoreStore.fetchAll(uid);
  }

  void logMigrationSummary({
    required RepositoryDataBundle bundle,
    required bool initialMigration,
  }) {
    _log(
      'Migration done. initialMigration=$initialMigration babies=${bundle.babies.length} '
      'feedings=${bundle.mamaKayitlari.length} sleep=${bundle.uykuKayitlari.length} '
      'diaper=${bundle.kakaKayitlari.length} growth=${bundle.boyKiloKayitlari.length} '
      'vaccines=${bundle.asiKayitlari.length} meds=${bundle.ilacKayitlari.length} '
      'medLogs=${bundle.ilacDozKayitlari.length}',
    );
  }

  Future<UserCredential?> onLogin(AuthCredential credential) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      final signedIn = await auth.signInWithCredential(credential);
      await migrateIfNeeded(signedIn.user?.uid);
      return signedIn;
    }

    if (currentUser.isAnonymous) {
      try {
        final linked = await currentUser.linkWithCredential(credential);
        await migrateIfNeeded(linked.user?.uid);
        return linked;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'credential-already-in-use' &&
            e.code != 'email-already-in-use' &&
            e.code != 'account-exists-with-different-credential') {
          rethrow;
        }
      }
    }

    final signedIn = await auth.signInWithCredential(credential);
    await migrateIfNeeded(signedIn.user?.uid);
    return signedIn;
  }

  Future<void> ensureSignedInUser() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return;
    _log('No firebase user found, signing in anonymously.');
    await auth.signInAnonymously();
  }

  Future<void> migrateIfNeeded(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    final should = await shouldRunInitialMigration(uid);
    if (!should) return;
    _log(
      'Initial migration is pending for uid=$uid (will be executed by orchestrator).',
    );
  }

  Future<RepositoryDataBundle> syncPull(String uid) async {
    return pullRemoteCoreData(uid);
  }

  Future<void> syncPush(String uid, RepositoryDataBundle bundle) async {
    await _firestoreStore.replaceBabies(uid, bundle.babies);
    for (final baby in bundle.babies) {
      final babyId = baby.id;
      await _firestoreStore.replaceRecordsForBaby(
        uid,
        babyId: babyId,
        types: const {
          'feeding',
          'nursing',
          'sleep',
          'diaper',
          'growth',
          'vaccine',
        },
        records: _recordsForBaby(bundle, babyId),
      );
      await _firestoreStore.replaceMemoriesForBaby(
        uid,
        babyId: babyId,
        memories: _memoriesForBaby(bundle, babyId),
      );
      await _firestoreStore.replaceMedicationsForBaby(
        uid,
        babyId: babyId,
        medications: bundle.ilacKayitlari
            .where((r) => r['babyId'] == babyId)
            .map((r) => Map<String, dynamic>.from(r))
            .toList(),
      );
      await _firestoreStore.replaceMedicationLogsForBaby(
        uid,
        babyId: babyId,
        logs: bundle.ilacDozKayitlari
            .where((r) => r['babyId'] == babyId)
            .map((r) => Map<String, dynamic>.from(r))
            .toList(),
      );
    }
  }

  Future<void> syncSingleWrite(
    String uid, {
    required String entityType,
    required String babyId,
    required Map<String, dynamic> payload,
  }) async {
    final copy = Map<String, dynamic>.from(payload);
    if (entityType == 'medication') {
      await _firestoreStore.replaceMedicationsForBaby(
        uid,
        babyId: babyId,
        medications: [copy],
      );
      return;
    }
    if (entityType == 'medicationLog') {
      await _firestoreStore.replaceMedicationLogsForBaby(
        uid,
        babyId: babyId,
        logs: [copy],
      );
      return;
    }
    await _firestoreStore.replaceRecordsForBaby(
      uid,
      babyId: babyId,
      types: {entityType},
      records: [copy],
    );
  }

  List<Map<String, dynamic>> _recordsForBaby(
    RepositoryDataBundle bundle,
    String babyId,
  ) {
    final rows = <Map<String, dynamic>>[];
    rows.addAll(
      bundle.mamaKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        final tur = (map['tur'] ?? '').toString().trim().toLowerCase();
        map['type'] = tur == 'anne' ? 'nursing' : 'feeding';
        return map;
      }),
    );
    rows.addAll(
      bundle.kakaKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'diaper';
        return map;
      }),
    );
    rows.addAll(
      bundle.uykuKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'sleep';
        return map;
      }),
    );
    rows.addAll(
      bundle.boyKiloKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'growth';
        return map;
      }),
    );
    rows.addAll(
      bundle.asiKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'vaccine';
        return map;
      }),
    );
    return rows;
  }

  List<Map<String, dynamic>> _memoriesForBaby(
    RepositoryDataBundle bundle,
    String babyId,
  ) {
    final rows = <Map<String, dynamic>>[];
    rows.addAll(
      bundle.milestones.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'milestone';
        map['photoLocalPath'] = map['photoPath'];
        return map;
      }),
    );
    rows.addAll(
      bundle.anilar.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'memory';
        map['photoLocalPath'] = map['photoPath'];
        return map;
      }),
    );
    return rows;
  }
}
