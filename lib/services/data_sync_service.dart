import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/local/local_store.dart';
import '../data/repositories/data_repository.dart';
import '../data/stores/firestore_store.dart';
import '../models/baby.dart';

const bool kFirestoreDebugLogs = true;

class DedupeMigrationResult {
  const DedupeMigrationResult({required this.bundle, required this.changed});

  final RepositoryDataBundle bundle;
  final bool changed;
}

class _RowDedupeResult {
  const _RowDedupeResult({required this.rows, required this.changed});

  final List<Map<String, dynamic>> rows;
  final bool changed;
}

class DataSyncService {
  DataSyncService({
    required LocalStore localStore,
    required FirestoreStore firestoreStore,
  }) : _localStore = localStore,
       _firestoreStore = firestoreStore;

  static const String migrationFlagKey = 'did_migrate_to_firestore_v1';
  static const String dedupeMigrationFlagKey = 'did_dedupe_firestore_v1';

  final LocalStore _localStore;
  final FirestoreStore _firestoreStore;

  static List<String> providerIdsForUser(User? user) {
    if (user == null) return const <String>[];
    return user.providerData
        .map((p) => p.providerId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  static String authStateSummary(User? user) {
    final providers = providerIdsForUser(user);
    return 'uid=${user?.uid} isAnonymous=${user?.isAnonymous} providerIds=$providers';
  }

  @visibleForTesting
  static bool canWriteToCloudFromValues({
    required bool isAnonymous,
    required List<String> providerIds,
  }) {
    if (isAnonymous) return false;
    if (providerIds.isEmpty) return true;
    return providerIds.any((id) => id != 'firebase');
  }

  static bool canWriteToCloud(User? user) {
    if (user == null) return false;
    return canWriteToCloudFromValues(
      isAnonymous: user.isAnonymous,
      providerIds: providerIdsForUser(user),
    );
  }

  String migrationFlagKeyForUid(String uid) => '${migrationFlagKey}_$uid';
  String dedupeMigrationFlagKeyForUid(String uid) =>
      '${dedupeMigrationFlagKey}_$uid';

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

  DateTime _resolveUpdatedAt(Map<String, dynamic> row, List<String> dateKeys) {
    final updated = _extractOptionalDate(row, 'updatedAt');
    if (updated != null) return updated;
    final localUpdated = _extractOptionalDate(row, 'localUpdatedAt');
    if (localUpdated != null) return localUpdated;
    return _extractDate(row, dateKeys);
  }

  String _stableDateToken(dynamic value) {
    final dt = value is DateTime
        ? value
        : (value is String ? DateTime.tryParse(value) : null);
    if (dt == null) return '';
    return dt.toUtc().toIso8601String();
  }

  String _naturalKeyFor(String entity, Map<String, dynamic> row) {
    final babyId = (row['babyId'] ?? '').toString();
    switch (entity) {
      case 'feeding':
        final explicitType = (row['type'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        final tur = (row['tur'] ?? '').toString().trim().toLowerCase();
        final type = explicitType.isNotEmpty
            ? explicitType
            : (tur == 'anne' ? 'nursing' : 'feeding');
        final tarih = _stableDateToken(row['tarih'] ?? row['date']);
        return 'feeding|$babyId|$type|$tarih|${row['miktar'] ?? ''}|${row['solDakika'] ?? ''}|${row['sagDakika'] ?? ''}|${row['kategori'] ?? ''}';
      case 'diaper':
        final tarih = _stableDateToken(row['tarih'] ?? row['date']);
        final diaperType = (row['diaperType'] ?? row['tur'] ?? '').toString();
        final eventType = (row['eventType'] ?? '').toString();
        return 'diaper|$babyId|$tarih|$diaperType|$eventType';
      case 'sleep':
        final start = _stableDateToken(row['baslangic'] ?? row['startAt']);
        final end = _stableDateToken(row['bitis'] ?? row['endAt']);
        return 'sleep|$babyId|$start|$end';
      case 'growth':
        final tarih = _stableDateToken(row['tarih'] ?? row['date']);
        return 'growth|$babyId|$tarih|${row['boy'] ?? ''}|${row['kilo'] ?? ''}|${row['basCevresi'] ?? ''}';
      case 'vaccine':
        final tarih = _stableDateToken(row['tarih'] ?? row['date']);
        return 'vaccine|$babyId|$tarih|${row['ad'] ?? ''}|${row['donem'] ?? ''}';
      case 'milestone':
        final date = _stableDateToken(row['date'] ?? row['tarih']);
        return 'milestone|$babyId|$date|${row['title'] ?? ''}|${row['note'] ?? ''}';
      case 'memory':
        final tarih = _stableDateToken(row['tarih'] ?? row['date']);
        return 'memory|$babyId|$tarih|${row['baslik'] ?? row['title'] ?? ''}|${row['not'] ?? row['note'] ?? ''}|${row['emoji'] ?? ''}';
      case 'medication':
        final createdAt = _stableDateToken(row['createdAt']);
        return 'medication|$babyId|$createdAt|${row['name'] ?? ''}|${row['type'] ?? ''}';
      case 'medicationLog':
        final givenAt = _stableDateToken(row['givenAt']);
        return 'medlog|$babyId|${row['medicationId'] ?? ''}|$givenAt|${row['doseIndex'] ?? ''}|${row['scheduledTime'] ?? ''}|${row['protocolStep'] ?? ''}';
    }
    return '$entity|$babyId|${row['id'] ?? ''}';
  }

  Map<String, dynamic> _resolveConflict(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming, {
    required List<String> dateKeys,
  }) {
    final existingAt = _resolveUpdatedAt(existing, dateKeys);
    final incomingAt = _resolveUpdatedAt(incoming, dateKeys);
    final chooseIncoming = incomingAt.isAfter(existingAt);
    final preferred = chooseIncoming ? incoming : existing;
    final secondary = chooseIncoming ? existing : incoming;
    final merged = Map<String, dynamic>.from(secondary)..addAll(preferred);

    final existingId = (existing['id'] ?? '').toString();
    final incomingId = (incoming['id'] ?? '').toString();
    if (existingId.isNotEmpty &&
        incomingId.isNotEmpty &&
        existingId != incomingId) {
      merged['id'] = existingId;
    } else if (existingId.isNotEmpty || incomingId.isNotEmpty) {
      merged['id'] = existingId.isNotEmpty ? existingId : incomingId;
    }
    return merged;
  }

  List<Map<String, dynamic>> _mergeById(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> remote, {
    required String entity,
    required List<String> dateKeys,
  }) {
    final merged = <String, Map<String, dynamic>>{};

    void upsertOne(Map<String, dynamic> raw) {
      final row = Map<String, dynamic>.from(raw);
      final id = (row['id'] ?? '').toString();
      final naturalKey = _naturalKeyFor(entity, row);
      final key = id.isNotEmpty ? 'id:$id' : 'nk:$naturalKey';
      final existing = merged[key];
      if (existing == null) {
        merged[key] = row;
        return;
      }
      merged[key] = _resolveConflict(existing, row, dateKeys: dateKeys);
    }

    for (final item in local) {
      upsertOne(item);
    }
    for (final item in remote) {
      upsertOne(item);
    }

    final byId = <String, Map<String, dynamic>>{};
    final byNaturalKey = <String, Map<String, dynamic>>{};
    for (final row in merged.values) {
      final id = (row['id'] ?? '').toString();
      final nk = _naturalKeyFor(entity, row);
      if (id.isNotEmpty) {
        final existing = byId[id];
        byId[id] = existing == null
            ? row
            : _resolveConflict(existing, row, dateKeys: dateKeys);
      } else {
        final existing = byNaturalKey[nk];
        byNaturalKey[nk] = existing == null
            ? row
            : _resolveConflict(existing, row, dateKeys: dateKeys);
      }
    }

    for (final row in byNaturalKey.values) {
      final nk = _naturalKeyFor(entity, row);
      final matchingEntry = byId.entries
          .where((e) => _naturalKeyFor(entity, e.value) == nk)
          .toList();
      if (matchingEntry.isEmpty) {
        byId['nk:$nk'] = row;
        continue;
      }
      final firstKey = matchingEntry.first.key;
      byId[firstKey] = _resolveConflict(
        byId[firstKey]!,
        row,
        dateKeys: dateKeys,
      );
    }

    final mergedByNatural = <String, Map<String, dynamic>>{};
    for (final row in byId.values) {
      final nk = _naturalKeyFor(entity, row);
      final existing = mergedByNatural[nk];
      mergedByNatural[nk] = existing == null
          ? row
          : _resolveConflict(existing, row, dateKeys: dateKeys);
    }

    return mergedByNatural.values.toList();
  }

  List<Baby> _mergeBabies(List<Baby> local, List<Baby> remote) {
    final byId = <String, Baby>{};
    for (final baby in local) {
      byId[baby.id] = baby;
    }
    for (final baby in remote) {
      final current = byId[baby.id];
      if (current == null) {
        byId[baby.id] = baby;
        continue;
      }

      if ((current.photoPath ?? '').trim().isEmpty &&
          (baby.photoPath ?? '').trim().isNotEmpty) {
        current.photoPath = baby.photoPath;
      }
      if ((current.photoStoragePath ?? '').trim().isEmpty &&
          (baby.photoStoragePath ?? '').trim().isNotEmpty) {
        current.photoStoragePath = baby.photoStoragePath;
      }
      if ((current.photoUrl ?? '').trim().isEmpty &&
          (baby.photoUrl ?? '').trim().isNotEmpty) {
        current.photoUrl = baby.photoUrl;
      }

      if (baby.createdAt.isAfter(current.createdAt)) {
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
        entity: 'feeding',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      kakaKayitlari: _mergeById(
        local.kakaKayitlari,
        remote.kakaKayitlari,
        entity: 'diaper',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      uykuKayitlari: _mergeById(
        local.uykuKayitlari,
        remote.uykuKayitlari,
        entity: 'sleep',
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
        entity: 'growth',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      asiKayitlari: _mergeById(
        local.asiKayitlari,
        remote.asiKayitlari,
        entity: 'vaccine',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      milestones: _mergeById(
        local.milestones,
        remote.milestones,
        entity: 'milestone',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'date', 'createdAt'],
      ),
      anilar: _mergeById(
        local.anilar,
        remote.anilar,
        entity: 'memory',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
      ),
      ilacKayitlari: _mergeById(
        local.ilacKayitlari,
        remote.ilacKayitlari,
        entity: 'medication',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'createdAt'],
      ),
      ilacDozKayitlari: _mergeById(
        local.ilacDozKayitlari,
        remote.ilacDozKayitlari,
        entity: 'medicationLog',
        dateKeys: const ['updatedAt', 'localUpdatedAt', 'givenAt', 'createdAt'],
      ),
    );
  }

  _RowDedupeResult _dedupeRowsWithTombstones(
    String entity,
    List<Map<String, dynamic>> rows, {
    required List<String> dateKeys,
  }) {
    final byNatural = <String, List<Map<String, dynamic>>>{};
    for (final raw in rows) {
      final row = Map<String, dynamic>.from(raw);
      final id = (row['id'] ?? '').toString().trim();
      if (id.isEmpty) continue;
      final nk = _naturalKeyFor(entity, row);
      byNatural.putIfAbsent(nk, () => <Map<String, dynamic>>[]).add(row);
    }

    final out = <Map<String, dynamic>>[];
    var changed = false;
    final now = DateTime.now().toUtc();

    for (final group in byNatural.values) {
      Map<String, dynamic>? winner;
      for (final row in group) {
        winner = winner == null
            ? row
            : _resolveConflict(winner, row, dateKeys: dateKeys);
      }
      if (winner == null) continue;
      out.add(Map<String, dynamic>.from(winner));

      for (final row in group) {
        final rowId = (row['id'] ?? '').toString();
        final winnerId = (winner['id'] ?? '').toString();
        if (rowId == winnerId) continue;
        changed = true;
        final tombstone = Map<String, dynamic>.from(row);
        tombstone['isDeleted'] = true;
        tombstone['deletedAt'] = now;
        tombstone['updatedAt'] = now;
        tombstone['localUpdatedAt'] = now;
        out.add(tombstone);
      }
    }

    if (!changed && out.length == rows.length) {
      return _RowDedupeResult(rows: rows, changed: false);
    }
    return _RowDedupeResult(rows: out, changed: true);
  }

  DedupeMigrationResult buildDedupeMigrationBundle(
    RepositoryDataBundle remote,
  ) {
    final feedings = _dedupeRowsWithTombstones(
      'feeding',
      remote.mamaKayitlari,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
    );
    final diapers = _dedupeRowsWithTombstones(
      'diaper',
      remote.kakaKayitlari,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
    );
    final sleeps = _dedupeRowsWithTombstones(
      'sleep',
      remote.uykuKayitlari,
      dateKeys: const [
        'updatedAt',
        'localUpdatedAt',
        'bitis',
        'endAt',
        'createdAt',
      ],
    );
    final growth = _dedupeRowsWithTombstones(
      'growth',
      remote.boyKiloKayitlari,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
    );
    final vaccines = _dedupeRowsWithTombstones(
      'vaccine',
      remote.asiKayitlari,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
    );
    final milestones = _dedupeRowsWithTombstones(
      'milestone',
      remote.milestones,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'date', 'createdAt'],
    );
    final memories = _dedupeRowsWithTombstones(
      'memory',
      remote.anilar,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'tarih', 'createdAt'],
    );
    final meds = _dedupeRowsWithTombstones(
      'medication',
      remote.ilacKayitlari,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'createdAt'],
    );
    final medLogs = _dedupeRowsWithTombstones(
      'medicationLog',
      remote.ilacDozKayitlari,
      dateKeys: const ['updatedAt', 'localUpdatedAt', 'givenAt', 'createdAt'],
    );

    final bundle = RepositoryDataBundle(
      babies: remote.babies,
      mamaKayitlari: feedings.rows,
      kakaKayitlari: diapers.rows,
      uykuKayitlari: sleeps.rows,
      boyKiloKayitlari: growth.rows,
      asiKayitlari: vaccines.rows,
      milestones: milestones.rows,
      anilar: memories.rows,
      ilacKayitlari: meds.rows,
      ilacDozKayitlari: medLogs.rows,
    );

    final changed =
        feedings.changed ||
        diapers.changed ||
        sleeps.changed ||
        growth.changed ||
        vaccines.changed ||
        milestones.changed ||
        memories.changed ||
        meds.changed ||
        medLogs.changed;

    return DedupeMigrationResult(bundle: bundle, changed: changed);
  }

  Future<bool> shouldRunInitialMigration(String uid) async {
    final should = !(_localStore.getBool(migrationFlagKeyForUid(uid)) ?? false);
    _log('shouldRunInitialMigration uid=$uid -> $should');
    return should;
  }

  Future<bool> shouldRunDedupeMigration(String uid) async {
    final should =
        !(_localStore.getBool(dedupeMigrationFlagKeyForUid(uid)) ?? false);
    _log('shouldRunDedupeMigration uid=$uid -> $should');
    return should;
  }

  Future<void> markDedupeMigrationDone(String uid) async {
    await _localStore.setBool(dedupeMigrationFlagKeyForUid(uid), true);
    _log('markDedupeMigrationDone uid=$uid');
  }

  Future<void> markInitialMigrationDone(String uid) async {
    await _localStore.setBool(migrationFlagKeyForUid(uid), true);
    _log('markInitialMigrationDone uid=$uid');
  }

  Future<RepositoryDataBundle> pullRemoteCoreData(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (!canWriteToCloud(user)) {
      _log(
        '[Sync] skip cloud read: user is anonymous (${authStateSummary(user)})',
      );
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
    final user = FirebaseAuth.instance.currentUser;
    if (!canWriteToCloud(user)) {
      _log(
        '[Sync] skip cloud write: user is anonymous (${authStateSummary(user)})',
      );
      return;
    }
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
    final user = FirebaseAuth.instance.currentUser;
    if (!canWriteToCloud(user)) {
      _log(
        '[Sync] skip cloud write: user is anonymous (${authStateSummary(user)})',
      );
      return;
    }
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
        map['photoStoragePath'] = map['photoStoragePath'];
        map['photoUrl'] = map['photoUrl'];
        return map;
      }),
    );
    rows.addAll(
      bundle.anilar.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'memory';
        map['photoLocalPath'] = map['photoPath'];
        map['photoStoragePath'] = map['photoStoragePath'];
        map['photoUrl'] = map['photoUrl'];
        return map;
      }),
    );
    return rows;
  }
}
