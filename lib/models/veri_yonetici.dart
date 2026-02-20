import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/data_repository.dart';
import '../data/local/local_store.dart';
import '../data/local/shared_preferences_local_store.dart';
import '../data/stores/firestore_store.dart';
import '../services/data_sync_service.dart';
import 'baby.dart';
import 'timer_yonetici.dart';

class BabyDeleteResult {
  final bool deleted;
  final bool cloudDeleteFailed;
  final bool hasRemainingBabies;

  const BabyDeleteResult({
    required this.deleted,
    required this.cloudDeleteFailed,
    required this.hasRemainingBabies,
  });
}

class MedicationDoseMarkResult {
  final String logId;
  final bool alreadyMarked;

  const MedicationDoseMarkResult({
    required this.logId,
    required this.alreadyMarked,
  });
}

class VeriYonetici {
  // Singleton instance
  static SharedPreferences? _prefs;
  static LocalStore? _localStore;

  // In-memory cache
  static List<Map<String, dynamic>> _mamaKayitlari = [];
  static List<Map<String, dynamic>> _kakaKayitlari = [];
  static List<Map<String, dynamic>> _uykuKayitlari = [];
  static List<Map<String, dynamic>> _anilar = [];
  static List<Map<String, dynamic>> _boyKiloKayitlari = [];
  static List<Map<String, dynamic>> _milestones = [];
  static List<Map<String, dynamic>> _asiKayitlari = [];
  static List<Map<String, dynamic>> _ilacKayitlari = [];
  static List<Map<String, dynamic>> _ilacDozKayitlari = [];
  static final ValueNotifier<int> _vaccineVersion = ValueNotifier<int>(0);
  static bool _darkMode = false;
  static bool _firstLaunch = true;
  static bool _loginEntryShown = false;

  // Reminder settings
  static bool _feedingReminderEnabled = false;
  static int _feedingReminderInterval = 180; // 3 hours default
  static bool _diaperReminderEnabled = false;
  static int _diaperReminderInterval = 120; // 2 hours default
  static bool _medicationRemindersEnabled = true;
  static int _feedingReminderHour = 14;
  static int _feedingReminderMinute = 0;
  static int _diaperReminderHour = 14;
  static int _diaperReminderMinute = 0;

  static String _babyName = 'Sofia';
  static DateTime _birthDate = DateTime(2024, 9, 17);
  static String? _babyPhotoPath;

  // Multi-baby support
  static List<Baby> _babies = [];
  static String _activeBabyId = '';
  static const String _migrationKey = 'multi_baby_migrated';
  static const String diaperEventType = 'diaper';
  static int _recordIdCounter = 0;
  static final FirestoreStore _firestoreStore = FirestoreStore();
  static DataSyncService? _dataSyncService;
  static const bool _verboseSyncLogs = true;
  static final Map<String, String> _lastCloudFingerprintByKey = {};
  static final Map<String, DateTime> _lastCloudWriteAtByKey = {};

  static const List<String> _timerKeysByBabyTemplate = <String>[
    'active_uyku_start_{babyId}',
    'active_emzirme_start_{babyId}',
    'active_emzirme_ilk_start_{babyId}',
    'active_emzirme_tur_{babyId}',
    'active_emzirme_taraf_{babyId}',
    'active_emzirme_sol_saniye_{babyId}',
    'active_emzirme_sag_saniye_{babyId}',
  ];

  static String _newRecordId(String prefix) {
    _recordIdCounter++;
    return '${prefix}_${DateTime.now().microsecondsSinceEpoch}_$_recordIdCounter';
  }

  static String _normalizeDiaperToken(dynamic rawValue) {
    final value = (rawValue ?? '').toString().trim().toLowerCase();
    return value
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c');
  }

  static String normalizeDiaperType(dynamic rawValue) {
    final value = _normalizeDiaperToken(rawValue);
    if (value == 'wet' || value == 'islak') return 'wet';
    if (value == 'dirty' || value == 'kirli') return 'dirty';
    if (value == 'both' || value == 'ikisi birden') return 'both';
    return 'both';
  }

  static String normalizeDiaperEventType(dynamic rawValue) {
    final value = _normalizeDiaperToken(rawValue);
    if (value == 'diaper' || value == 'bez degisimi') {
      return diaperEventType;
    }
    return diaperEventType;
  }

  static String? get _currentUid => FirebaseAuth.instance.currentUser?.uid;

  static String? _getLocalString(String key) {
    return _localStore?.getString(key) ?? _prefs?.getString(key);
  }

  static Future<void> _setLocalString(String key, String value) async {
    if (_localStore != null) {
      await _localStore!.setString(key, value);
      return;
    }
    await _prefs?.setString(key, value);
  }

  static void _log(String message) {
    if (kDebugMode && _verboseSyncLogs) {
      debugPrint('[VeriYonetici] $message');
    }
  }

  static dynamic _canonicalize(dynamic value) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      final map = <String, dynamic>{};
      for (final key in keys) {
        map[key] = _canonicalize(value[key]);
      }
      return map;
    }
    if (value is List) {
      return value.map(_canonicalize).toList();
    }
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Duration) return value.inMilliseconds;
    return value;
  }

  static bool _shouldSkipDuplicateCloudWrite(String key, dynamic payload) {
    final fp = jsonEncode(_canonicalize(payload));
    final now = DateTime.now();
    final lastFp = _lastCloudFingerprintByKey[key];
    final lastAt = _lastCloudWriteAtByKey[key];
    if (lastFp == fp &&
        lastAt != null &&
        now.difference(lastAt) < const Duration(seconds: 2)) {
      _log('Skipping duplicate cloud write for key=$key');
      return true;
    }
    _lastCloudFingerprintByKey[key] = fp;
    _lastCloudWriteAtByKey[key] = now;
    return false;
  }

  static Future<void> _withIdempotentCloudWrite(
    String key,
    dynamic payload,
    Future<void> Function() action,
  ) async {
    if (_shouldSkipDuplicateCloudWrite(key, payload)) return;
    await action();
  }

  static RepositoryDataBundle _currentCoreBundle() {
    return RepositoryDataBundle(
      babies: List<Baby>.from(_babies),
      mamaKayitlari: _mamaKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      kakaKayitlari: _kakaKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      uykuKayitlari: _uykuKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      boyKiloKayitlari: _boyKiloKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      asiKayitlari: _asiKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      milestones: _milestones.map((e) => Map<String, dynamic>.from(e)).toList(),
      anilar: _anilar.map((e) => Map<String, dynamic>.from(e)).toList(),
      ilacKayitlari: _ilacKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      ilacDozKayitlari: _ilacDozKayitlari
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  static String _deterministicDocId({
    required String babyId,
    required String type,
    required String keyTime,
    String extra = '',
    int doseIndex = 0,
  }) {
    final uid = _currentUid ?? 'anonymous';
    final raw = '$uid:$babyId:$type:$keyTime:$doseIndex:$extra';
    return sha1.convert(utf8.encode(raw)).toString();
  }

  static Future<void> _syncFromCloudIfSignedIn() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;

    try {
      _log('Starting cloud sync for uid=$uid');
      final syncService = _dataSyncService;
      if (syncService == null) return;
      final localBabiesBefore = _babies.length;
      final remote = await syncService.pullRemoteCoreData(uid);
      final authUser = FirebaseAuth.instance.currentUser;
      _log(
        'Startup auth uid=${authUser?.uid} anonymous=${authUser?.isAnonymous} '
        'babies local=$localBabiesBefore remote=${remote.babies.length}',
      );
      final merged = syncService.mergeCoreData(
        local: _currentCoreBundle(),
        remote: remote,
      );

      final dedupedBabies = _dedupeBabiesById(merged.babies);
      final didDedupeBabies = dedupedBabies.length != merged.babies.length;
      _babies = dedupedBabies;
      _mamaKayitlari = merged.mamaKayitlari;
      _kakaKayitlari = merged.kakaKayitlari;
      _uykuKayitlari = merged.uykuKayitlari;
      _boyKiloKayitlari = merged.boyKiloKayitlari;
      _asiKayitlari = merged.asiKayitlari;
      _milestones = merged.milestones;
      _anilar = merged.anilar;
      _ilacKayitlari = merged.ilacKayitlari;
      _ilacDozKayitlari = merged.ilacDozKayitlari;

      await _saveBabies();
      if (didDedupeBabies) {
        _log('Sync dedupe detected. Rewriting baby docs for uid=$uid.');
        await _syncBabiesToCloud();
      }
      await _saveAllCollections();
      final shouldMigrate = await syncService.shouldRunInitialMigration(uid);
      if (shouldMigrate) {
        _log('Running one-time local->cloud migration for uid=$uid');
        await _pushAllToCloud(uid);
        await syncService.markInitialMigrationDone(uid);
      }
      syncService.logMigrationSummary(
        bundle: merged,
        initialMigration: shouldMigrate,
      );
      _log('Cloud sync completed for uid=$uid');
    } catch (_) {
      _log('Cloud sync failed, keeping local cache.');
      // Keep local cache if cloud is temporarily unavailable.
    }
  }

  static Future<void> refreshForCurrentUser() async {
    await _syncFromCloudIfSignedIn();
    if (_babies.isNotEmpty && !_babies.any((b) => b.id == _activeBabyId)) {
      _activeBabyId = _babies.first.id;
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    if (_babies.isNotEmpty) {
      final active = getActiveBaby();
      _babyName = active.name;
      _birthDate = active.birthDate;
      _babyPhotoPath = active.photoPath;
    } else {
      _activeBabyId = '';
      await _setLocalString('active_baby_id', _activeBabyId);
    }
  }

  static List<Map<String, dynamic>> _recordsForBundleBaby(
    RepositoryDataBundle bundle,
    String babyId,
  ) {
    final records = <Map<String, dynamic>>[];
    records.addAll(
      bundle.mamaKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        final tur = (map['tur'] ?? '').toString().trim().toLowerCase();
        map['type'] = tur == 'anne' ? 'nursing' : 'feeding';
        map['date'] = map['tarih'];
        return map;
      }),
    );
    records.addAll(
      bundle.kakaKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'diaper';
        map['date'] = map['tarih'];
        return map;
      }),
    );
    records.addAll(
      bundle.uykuKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'sleep';
        map['startAt'] = map['baslangic'];
        map['endAt'] = map['bitis'];
        map['durationMinutes'] = (map['sure'] as Duration).inMinutes;
        return map;
      }),
    );
    records.addAll(
      bundle.boyKiloKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'growth';
        map['date'] = map['tarih'];
        return map;
      }),
    );
    records.addAll(
      bundle.asiKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = 'vaccine';
        map['date'] = map['tarih'];
        return map;
      }),
    );
    return records;
  }

  static List<Map<String, dynamic>> _memoryDocsForBundleBaby(
    RepositoryDataBundle bundle,
    String babyId,
  ) {
    final Map<String, Map<String, dynamic>> byId = {};

    for (final m in bundle.milestones.where((e) => e['babyId'] == babyId)) {
      final id = (m['id'] ?? _newRecordId('memory')).toString();
      byId[id] = {
        'id': id,
        'type': 'milestone',
        'babyId': babyId,
        'title': m['title'],
        'note': m['note'],
        'date': m['date'],
        'photoLocalPath': m['photoPath'],
        'photoStyle': m['photoStyle'] ?? 'softIllustration',
      };
    }

    for (final a in bundle.anilar.where((e) => e['babyId'] == babyId)) {
      final id = (a['id'] ?? _newRecordId('memory')).toString();
      byId[id] = {
        'id': id,
        'type': 'memory',
        'babyId': babyId,
        'title': a['baslik'],
        'note': a['not'],
        'date': a['tarih'],
        'emoji': a['emoji'],
        'photoLocalPath': a['photoPath'],
      };
    }

    return byId.values.toList();
  }

  static Future<RepositoryDataBundle> exportUserDataSnapshot({
    String? uid,
  }) async {
    final targetUid = uid ?? _currentUid;
    if (targetUid == null || targetUid.isEmpty) {
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
    try {
      return await _firestoreStore.fetchAll(targetUid);
    } catch (_) {
      return RepositoryDataBundle(
        babies: List<Baby>.from(_babies),
        mamaKayitlari: _mamaKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        kakaKayitlari: _kakaKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        uykuKayitlari: _uykuKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        boyKiloKayitlari: _boyKiloKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        asiKayitlari: _asiKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        milestones: _milestones
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        anilar: _anilar.map((e) => Map<String, dynamic>.from(e)).toList(),
        ilacKayitlari: _ilacKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
        ilacDozKayitlari: _ilacDozKayitlari
            .map((e) => Map<String, dynamic>.from(e))
            .toList(),
      );
    }
  }

  static Future<void> clearFirestoreDataForUid(String uid) async {
    if (uid.isEmpty) return;
    try {
      await _firestoreStore.clearUserSubtree(uid);
    } catch (_) {
      // Best-effort cleanup only.
    }
  }

  static Future<void> clearCachedUserDataForGuest() async {
    _lastCloudFingerprintByKey.clear();
    _lastCloudWriteAtByKey.clear();
    _log(
      'Guest session metadata reset completed (non-destructive; local data preserved).',
    );
  }

  static Future<void> restoreDataBundleToUid(
    String uid,
    RepositoryDataBundle bundle,
  ) async {
    if (uid.isEmpty) return;
    try {
      await _firestoreStore.replaceBabies(uid, bundle.babies);

      for (final baby in bundle.babies) {
        final babyId = baby.id;
        final records = _recordsForBundleBaby(bundle, babyId);
        await _firestoreStore.replaceRecordsForBaby(
          uid,
          babyId: babyId,
          types: {'feeding', 'nursing', 'diaper', 'sleep', 'growth', 'vaccine'},
          records: records,
        );

        await _firestoreStore.replaceMemoriesForBaby(
          uid,
          babyId: babyId,
          memories: _memoryDocsForBundleBaby(bundle, babyId),
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
    } catch (_) {
      // Best-effort restore only.
    }
  }

  static Future<void> _pushAllToCloud(String uid) async {
    try {
      await _firestoreStore.replaceBabies(uid, _babies);
      for (final baby in _babies) {
        await _syncActiveBabyRecordsToCloud(babyId: baby.id);
        await _syncActiveBabyMemoriesToCloud(babyId: baby.id);
        await _syncActiveBabyMedicationsToCloud(babyId: baby.id);
        await _syncActiveBabyMedicationLogsToCloud(babyId: baby.id);
      }
    } catch (_) {
      // Best-effort sync only.
    }
  }

  static Future<void> _syncBabiesToCloud() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    try {
      await _withIdempotentCloudWrite('babies:$uid', _babies, () async {
        await _firestoreStore.replaceBabies(uid, _babies);
      });
    } catch (_) {}
  }

  static Future<void> _syncActiveBabyRecordsToCloud({String? babyId}) async {
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;

    try {
      final mama = _mamaKayitlari.where((r) => r['babyId'] == targetBabyId).map(
        (r) {
          final map = Map<String, dynamic>.from(r);
          final tur = (map['tur'] ?? '').toString().trim().toLowerCase();
          final type = tur == 'anne' ? 'nursing' : 'feeding';
          map['type'] = type;
          map['date'] = map['tarih'];
          return map;
        },
      ).toList();

      await _withIdempotentCloudWrite(
        'records:feedings:$uid:$targetBabyId',
        mama,
        () async {
          await _firestoreStore.replaceRecordsForBaby(
            uid,
            babyId: targetBabyId,
            types: {'feeding', 'nursing'},
            records: mama,
          );
        },
      );

      final kaka = _kakaKayitlari.where((r) => r['babyId'] == targetBabyId).map(
        (r) {
          final map = Map<String, dynamic>.from(r);
          map['type'] = 'diaper';
          map['date'] = map['tarih'];
          return map;
        },
      ).toList();
      await _withIdempotentCloudWrite(
        'records:diaper:$uid:$targetBabyId',
        kaka,
        () async {
          await _firestoreStore.replaceRecordsForBaby(
            uid,
            babyId: targetBabyId,
            types: {'diaper'},
            records: kaka,
          );
        },
      );

      final uyku = _uykuKayitlari.where((r) => r['babyId'] == targetBabyId).map(
        (r) {
          final map = Map<String, dynamic>.from(r);
          map['type'] = 'sleep';
          map['startAt'] = map['baslangic'];
          map['endAt'] = map['bitis'];
          map['durationMinutes'] = (map['sure'] as Duration).inMinutes;
          return map;
        },
      ).toList();
      await _withIdempotentCloudWrite(
        'records:sleep:$uid:$targetBabyId',
        uyku,
        () async {
          await _firestoreStore.replaceRecordsForBaby(
            uid,
            babyId: targetBabyId,
            types: {'sleep'},
            records: uyku,
          );
        },
      );

      final growth = _boyKiloKayitlari
          .where((r) => r['babyId'] == targetBabyId)
          .map((r) {
            final map = Map<String, dynamic>.from(r);
            map['type'] = 'growth';
            map['date'] = map['tarih'];
            return map;
          })
          .toList();
      await _withIdempotentCloudWrite(
        'records:growth:$uid:$targetBabyId',
        growth,
        () async {
          await _firestoreStore.replaceRecordsForBaby(
            uid,
            babyId: targetBabyId,
            types: {'growth'},
            records: growth,
          );
        },
      );

      final vaccines = _asiKayitlari
          .where((r) => r['babyId'] == targetBabyId)
          .map((r) {
            final map = Map<String, dynamic>.from(r);
            map['type'] = 'vaccine';
            map['date'] = map['tarih'];
            return map;
          })
          .toList();
      await _withIdempotentCloudWrite(
        'records:vaccine:$uid:$targetBabyId',
        vaccines,
        () async {
          await _firestoreStore.replaceRecordsForBaby(
            uid,
            babyId: targetBabyId,
            types: {'vaccine'},
            records: vaccines,
          );
        },
      );
    } catch (_) {}
  }

  static List<Map<String, dynamic>> _memoryDocsForBaby(String babyId) {
    final Map<String, Map<String, dynamic>> byId = {};

    for (final m in _milestones.where((e) => e['babyId'] == babyId)) {
      final id = (m['id'] ?? _newRecordId('memory')).toString();
      byId[id] = {
        'id': id,
        'type': 'milestone',
        'babyId': babyId,
        'title': m['title'],
        'note': m['note'],
        'date': m['date'],
        'photoLocalPath': m['photoPath'],
        'photoStyle': m['photoStyle'] ?? 'softIllustration',
      };
    }

    for (final a in _anilar.where((e) => e['babyId'] == babyId)) {
      final id = (a['id'] ?? _newRecordId('memory')).toString();
      byId[id] = {
        'id': id,
        'type': 'memory',
        'babyId': babyId,
        'title': a['baslik'],
        'note': a['not'],
        'date': a['tarih'],
        'emoji': a['emoji'],
        'photoLocalPath': a['photoPath'],
      };
    }

    return byId.values.toList();
  }

  static Future<void> _syncActiveBabyMemoriesToCloud({String? babyId}) async {
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    try {
      final memories = _memoryDocsForBaby(targetBabyId);
      await _withIdempotentCloudWrite(
        'memories:$uid:$targetBabyId',
        memories,
        () async {
          await _firestoreStore.replaceMemoriesForBaby(
            uid,
            babyId: targetBabyId,
            memories: memories,
          );
        },
      );
    } catch (_) {}
  }

  static Future<void> _syncActiveBabyMedicationsToCloud({
    String? babyId,
  }) async {
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    try {
      final meds = _ilacKayitlari
          .where((r) => r['babyId'] == targetBabyId)
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      await _withIdempotentCloudWrite(
        'meds:$uid:$targetBabyId',
        meds,
        () async {
          await _firestoreStore.replaceMedicationsForBaby(
            uid,
            babyId: targetBabyId,
            medications: meds,
          );
        },
      );
    } catch (_) {}
  }

  static Future<void> _syncActiveBabyMedicationLogsToCloud({
    String? babyId,
  }) async {
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    try {
      final logs = _ilacDozKayitlari
          .where((r) => r['babyId'] == targetBabyId)
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      await _withIdempotentCloudWrite(
        'medlogs:$uid:$targetBabyId',
        logs,
        () async {
          await _firestoreStore.replaceMedicationLogsForBaby(
            uid,
            babyId: targetBabyId,
            logs: logs,
          );
        },
      );
    } catch (_) {}
  }

  // Initialize - must be called before using any other methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _localStore = SharedPreferencesLocalStore(_prefs!);
    _dataSyncService = DataSyncService(
      localStore: _localStore!,
      firestoreStore: _firestoreStore,
    );

    // Run one-time migration if needed
    final migrated = _prefs!.getBool(_migrationKey) ?? false;
    if (!migrated) {
      await _migrateToMultiBaby();
    }

    // Load babies and resolve active baby
    final loadedBabies = _loadBabies();
    _babies = _dedupeBabiesById(loadedBabies);
    if (_babies.length != loadedBabies.length) {
      await _saveBabies();
      await _syncBabiesToCloud();
    }
    _activeBabyId = _getLocalString('active_baby_id') ?? '';

    if (_babies.isNotEmpty && !_babies.any((b) => b.id == _activeBabyId)) {
      // Babies exist but active ID is invalid - use first baby
      _activeBabyId = _babies.first.id;
      await _setLocalString('active_baby_id', _activeBabyId);
    } else if (_babies.isEmpty && _activeBabyId.isNotEmpty) {
      _activeBabyId = '';
      await _setLocalString('active_baby_id', _activeBabyId);
    }

    // Load all data into cache (babyId included in each record)
    _mamaKayitlari = _loadMamaKayitlari();
    _kakaKayitlari = _loadKakaKayitlari();
    _uykuKayitlari = _loadUykuKayitlari();
    _anilar = _loadAnilar();
    _boyKiloKayitlari = _loadBoyKiloKayitlari();
    _milestones = _loadMilestones();
    _asiKayitlari = _loadAsiKayitlari();
    _ilacKayitlari = _loadIlacKayitlari();
    _ilacDozKayitlari = _loadIlacDozKayitlari();

    final authUser = FirebaseAuth.instance.currentUser;
    _log(
      'Startup auth uid=${authUser?.uid} anonymous=${authUser?.isAnonymous} '
      'babies local=${_babies.length} remote=pending',
    );

    // If signed in, prefer Firestore-backed data scoped to current uid.
    await _syncFromCloudIfSignedIn();

    // Settings
    _darkMode = _prefs!.getBool('dark_mode') ?? false;
    _firstLaunch = _prefs!.getBool('first_launch') ?? true;
    _loginEntryShown = _prefs!.getBool('login_entry_shown') ?? false;

    // Reminder settings
    _feedingReminderEnabled =
        _prefs!.getBool('feeding_reminder_enabled') ?? false;
    _feedingReminderInterval =
        _prefs!.getInt('feeding_reminder_interval') ?? 180;
    _diaperReminderEnabled =
        _prefs!.getBool('diaper_reminder_enabled') ?? false;
    _diaperReminderInterval = _prefs!.getInt('diaper_reminder_interval') ?? 120;
    _medicationRemindersEnabled =
        _prefs!.getBool('medication_reminder_enabled') ?? true;
    _feedingReminderHour = _prefs!.getInt('feeding_reminder_time_h') ?? 14;
    _feedingReminderMinute = _prefs!.getInt('feeding_reminder_time_m') ?? 0;
    _diaperReminderHour = _prefs!.getInt('diaper_reminder_time_h') ?? 14;
    _diaperReminderMinute = _prefs!.getInt('diaper_reminder_time_m') ?? 0;

    // Sync cached baby fields from active baby
    // After our guarantees above, this should always succeed
    if (_babies.isNotEmpty && _babies.any((b) => b.id == _activeBabyId)) {
      final baby = getActiveBaby();
      _babyName = baby.name;
      _birthDate = baby.birthDate;
      _babyPhotoPath = baby.photoPath;
    } else {
      _babyName = 'Baby';
      _birthDate = DateTime.now().subtract(const Duration(days: 30));
      _babyPhotoPath = null;
      _activeBabyId = '';
      await _setLocalString('active_baby_id', _activeBabyId);
    }

    // Initialize TimerYonetici
    await TimerYonetici().init(_prefs!);
  }

  // ============ MIGRATION ============

  static Future<void> _migrateToMultiBaby() async {
    // Check if babies key already exists (partial migration)
    final existingBabiesData = _getLocalString('babies');
    String defaultBabyId = '';

    if (existingBabiesData != null && existingBabiesData.isNotEmpty) {
      try {
        final existing = jsonDecode(existingBabiesData) as List;
        if (existing.isNotEmpty) {
          defaultBabyId = existing[0]['id'] as String;
        }
      } catch (_) {
        defaultBabyId = '';
      }
    } else {
      if (!_hasLegacyDataToMigrate()) {
        await _setLocalString('babies', jsonEncode([]));
        await _setLocalString('active_baby_id', '');
        await _prefs!.setBool(_migrationKey, true);
        return;
      }

      defaultBabyId = Baby.generateId();

      final existingName = _getLocalString('baby_name') ?? 'Sofia';
      final birthDateStr = _getLocalString('birth_date');
      final existingBirthDate = birthDateStr != null
          ? DateTime.parse(birthDateStr)
          : DateTime(2024, 9, 17);
      final existingPhoto = _getLocalString('baby_photo_path');

      final defaultBaby = Baby(
        id: defaultBabyId,
        name: existingName,
        birthDate: existingBirthDate,
        photoPath: existingPhoto,
      );

      await _setLocalString('babies', jsonEncode([defaultBaby.toJson()]));
    }

    await _setLocalString('active_baby_id', defaultBabyId);

    if (defaultBabyId.isNotEmpty) {
      // Tag all existing records with the default baby ID
      await _tagExistingRecords('mama_kayitlari', defaultBabyId);
      await _tagExistingRecords('kaka_kayitlari', defaultBabyId);
      await _tagExistingRecords('uyku_kayitlari', defaultBabyId);
      await _tagExistingRecords('anilar', defaultBabyId);
      await _tagExistingRecords('boykilo_kayitlari', defaultBabyId);
      await _tagExistingRecords('milestones', defaultBabyId);
      await _tagExistingRecords('asi_kayitlari', defaultBabyId);
      await _tagExistingRecords('ilac_kayitlari', defaultBabyId);
    }

    await _prefs!.setBool(_migrationKey, true);
  }

  static Future<void> _tagExistingRecords(String key, String babyId) async {
    final data = _getLocalString(key);
    if (data == null || data.isEmpty) return;
    try {
      final list = jsonDecode(data) as List;
      final tagged = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['babyId'] = babyId;
        return map;
      }).toList();
      await _setLocalString(key, jsonEncode(tagged));
    } catch (_) {
      // Corrupt data; _load* methods handle errors
    }
  }

  static bool _hasLegacyDataToMigrate() {
    if (_getLocalString('baby_name') != null) return true;
    if (_getLocalString('birth_date') != null) return true;
    if (_getLocalString('baby_photo_path') != null) return true;

    const dataKeys = <String>[
      'mama_kayitlari',
      'kaka_kayitlari',
      'uyku_kayitlari',
      'anilar',
      'boykilo_kayitlari',
      'milestones',
      'asi_kayitlari',
      'ilac_kayitlari',
      'ilac_doz_kayitlari',
    ];

    for (final key in dataKeys) {
      final raw = _getLocalString(key);
      if (raw == null) continue;
      final normalized = raw.trim();
      if (normalized.isNotEmpty && normalized != '[]') return true;
    }
    return false;
  }

  static List<Baby> _dedupeBabiesById(List<Baby> babies) {
    if (babies.length <= 1) return babies;

    final byId = <String, Baby>{};
    final duplicateHits = <String, int>{};
    for (final baby in babies) {
      final existing = byId[baby.id];
      if (existing == null) {
        byId[baby.id] = baby;
        continue;
      }
      duplicateHits[baby.id] = (duplicateHits[baby.id] ?? 1) + 1;
      byId[baby.id] = _preferBaby(existing, baby);
    }

    if (duplicateHits.isNotEmpty) {
      for (final entry in duplicateHits.entries) {
        _log(
          'Deduped babies id=${entry.key} duplicates=${entry.value} '
          'keptScore=${_babyQualityScore(byId[entry.key]!)}',
        );
      }
    }
    return byId.values.toList();
  }

  static Baby _preferBaby(Baby a, Baby b) {
    final aScore = _babyQualityScore(a);
    final bScore = _babyQualityScore(b);
    if (bScore > aScore) return b;
    if (aScore > bScore) return a;
    return b.createdAt.isAfter(a.createdAt) ? b : a;
  }

  static int _babyQualityScore(Baby baby) {
    var score = _recordCountForBabyId(baby.id) * 100;
    if (baby.name.trim().isNotEmpty &&
        baby.name.trim().toLowerCase() != 'baby') {
      score += 10;
    }
    if ((baby.photoPath ?? '').trim().isNotEmpty) score += 5;
    return score;
  }

  static int _recordCountForBabyId(String babyId) {
    int count = 0;
    count += _mamaKayitlari.where((r) => r['babyId'] == babyId).length;
    count += _kakaKayitlari.where((r) => r['babyId'] == babyId).length;
    count += _uykuKayitlari.where((r) => r['babyId'] == babyId).length;
    count += _anilar.where((r) => r['babyId'] == babyId).length;
    count += _boyKiloKayitlari.where((r) => r['babyId'] == babyId).length;
    count += _milestones.where((r) => r['babyId'] == babyId).length;
    count += _asiKayitlari.where((r) => r['babyId'] == babyId).length;
    count += _ilacKayitlari.where((r) => r['babyId'] == babyId).length;
    count += _ilacDozKayitlari.where((r) => r['babyId'] == babyId).length;
    return count;
  }

  static int _removeRowsForBaby(
    List<Map<String, dynamic>> rows,
    String babyId,
  ) {
    final before = rows.length;
    rows.removeWhere((row) => row['babyId'] == babyId);
    return before - rows.length;
  }

  static Future<int> _clearTimerKeysForBaby(String babyId) async {
    int removed = 0;
    for (final template in _timerKeysByBabyTemplate) {
      final key = template.replaceAll('{babyId}', babyId);
      final hadKey = _prefs?.containsKey(key) ?? false;
      await _prefs?.remove(key);
      if (hadKey) removed++;
    }

    final sleepTimerOwner = _prefs?.getString('active_uyku_baby_id');
    if (sleepTimerOwner == babyId) {
      await _prefs?.remove('active_uyku_baby_id');
      removed++;
    }
    final nursingTimerOwner = _prefs?.getString('active_emzirme_baby_id');
    if (nursingTimerOwner == babyId) {
      await _prefs?.remove('active_emzirme_baby_id');
      removed++;
    }
    return removed;
  }

  // ============ BABY MANAGEMENT ============

  static List<Baby> _loadBabies() {
    try {
      final data = _getLocalString('babies');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map((e) => Baby.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveBabies() async {
    _babies = _dedupeBabiesById(_babies);
    final data = _babies.map((b) => b.toJson()).toList();
    await _setLocalString('babies', jsonEncode(data));
  }

  static List<Baby> getBabies() {
    return List.from(_dedupeBabiesById(_babies));
  }

  static bool hasActiveBaby() {
    return _activeBabyId.isNotEmpty &&
        _babies.any((b) => b.id == _activeBabyId);
  }

  static Baby? getActiveBabyOrNull() {
    if (_babies.isEmpty) return null;
    final index = _babies.indexWhere((b) => b.id == _activeBabyId);
    if (index >= 0) return _babies[index];
    return _babies.first;
  }

  static Baby getActiveBaby() {
    final active = getActiveBabyOrNull();
    if (active != null) return active;
    throw StateError('No active baby is available.');
  }

  static String getActiveBabyId() {
    return _activeBabyId;
  }

  static Future<void> setActiveBaby(String babyId) async {
    if (_babies.any((b) => b.id == babyId)) {
      _activeBabyId = babyId;
      await _setLocalString('active_baby_id', babyId);
      final baby = getActiveBaby();
      _babyName = baby.name;
      _birthDate = baby.birthDate;
      _babyPhotoPath = baby.photoPath;
      // Reload timer state for the new baby
      await TimerYonetici().onActiveBabyChanged(babyId);
    }
  }

  static Future<String> addBaby({
    String? id,
    required String name,
    required DateTime birthDate,
    String? photoPath,
  }) async {
    final babyId = id ?? Baby.generateId();
    final existingIndex = _babies.indexWhere((b) => b.id == babyId);
    if (existingIndex >= 0) {
      final existing = _babies[existingIndex];
      _babies[existingIndex] = Baby(
        id: existing.id,
        name: name,
        birthDate: birthDate,
        photoPath: photoPath ?? existing.photoPath,
        createdAt: existing.createdAt,
      );
    } else {
      final baby = Baby(
        id: babyId,
        name: name,
        birthDate: birthDate,
        photoPath: photoPath,
      );
      _babies.add(baby);
    }

    if (_activeBabyId.isEmpty && _babies.any((b) => b.id == babyId)) {
      _activeBabyId = babyId;
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    await _saveBabies();
    await _syncBabiesToCloud();
    return babyId;
  }

  static Future<BabyDeleteResult> deleteBaby(String babyId) async {
    final exists = _babies.any((b) => b.id == babyId);
    if (!exists) {
      return const BabyDeleteResult(
        deleted: false,
        cloudDeleteFailed: false,
        hasRemainingBabies: false,
      );
    }

    final removedLocalCounts = <String, int>{};
    final uid = _currentUid;
    final authUser = FirebaseAuth.instance.currentUser;
    bool cloudDeleteFailed = false;

    _log(
      'Delete baby requested babyId=$babyId uid=$uid anonymous=${authUser?.isAnonymous}',
    );

    final beforeBabies = _babies.length;
    _babies.removeWhere((b) => b.id == babyId);
    removedLocalCounts['babies'] = beforeBabies - _babies.length;

    removedLocalCounts['mama_kayitlari'] = _removeRowsForBaby(
      _mamaKayitlari,
      babyId,
    );
    removedLocalCounts['kaka_kayitlari'] = _removeRowsForBaby(
      _kakaKayitlari,
      babyId,
    );
    removedLocalCounts['uyku_kayitlari'] = _removeRowsForBaby(
      _uykuKayitlari,
      babyId,
    );
    removedLocalCounts['anilar'] = _removeRowsForBaby(_anilar, babyId);
    removedLocalCounts['boykilo_kayitlari'] = _removeRowsForBaby(
      _boyKiloKayitlari,
      babyId,
    );
    removedLocalCounts['milestones'] = _removeRowsForBaby(_milestones, babyId);
    removedLocalCounts['asi_kayitlari'] = _removeRowsForBaby(
      _asiKayitlari,
      babyId,
    );
    removedLocalCounts['ilac_kayitlari'] = _removeRowsForBaby(
      _ilacKayitlari,
      babyId,
    );
    removedLocalCounts['ilac_doz_kayitlari'] = _removeRowsForBaby(
      _ilacDozKayitlari,
      babyId,
    );

    final removedTimerKeys = await _clearTimerKeysForBaby(babyId);
    removedLocalCounts['timer_keys'] = removedTimerKeys;
    await TimerYonetici().clearBabyTimerState(babyId);

    if (_activeBabyId == babyId) {
      if (_babies.isNotEmpty) {
        _activeBabyId = _babies.first.id;
      } else {
        _activeBabyId = '';
      }
      await _setLocalString('active_baby_id', _activeBabyId);
      if (_activeBabyId.isNotEmpty) {
        await TimerYonetici().onActiveBabyChanged(_activeBabyId);
      }
    }

    if (_babies.isNotEmpty && _babies.any((b) => b.id == _activeBabyId)) {
      final active = getActiveBaby();
      _babyName = active.name;
      _birthDate = active.birthDate;
      _babyPhotoPath = active.photoPath;
    } else {
      _babyName = 'Baby';
      _birthDate = DateTime.now().subtract(const Duration(days: 30));
      _babyPhotoPath = null;
    }

    await _saveBabies();
    await _saveAllCollections();

    if (uid != null && uid.isNotEmpty) {
      try {
        await _firestoreStore.deleteBabyData(uid, babyId: babyId);
        await _syncBabiesToCloud();
      } catch (e) {
        cloudDeleteFailed = true;
        _log(
          'Cloud delete failed for babyId=$babyId uid=$uid. '
          'Deleted locally. TODO: add retry queue. error=$e',
        );
      }
    }

    _log('Deleted babyId=$babyId localCounts=$removedLocalCounts');

    return BabyDeleteResult(
      deleted: true,
      cloudDeleteFailed: cloudDeleteFailed,
      hasRemainingBabies: _babies.isNotEmpty,
    );
  }

  static Future<bool> removeBaby(String babyId) async {
    final result = await deleteBaby(babyId);
    return result.deleted;
  }

  static Future<void> updateBaby(
    String babyId, {
    String? name,
    DateTime? birthDate,
    String? photoPath,
    bool clearPhoto = false,
  }) async {
    final index = _babies.indexWhere((b) => b.id == babyId);
    if (index == -1) return;
    if (name != null) _babies[index].name = name;
    if (birthDate != null) _babies[index].birthDate = birthDate;
    if (clearPhoto) {
      _babies[index].photoPath = null;
    } else if (photoPath != null) {
      _babies[index].photoPath = photoPath;
    }
    await _saveBabies();
    await _syncBabiesToCloud();
    if (babyId == _activeBabyId) {
      _babyName = _babies[index].name;
      _birthDate = _babies[index].birthDate;
      _babyPhotoPath = _babies[index].photoPath;
    }
  }

  // ============ MAMA ============

  static List<Map<String, dynamic>> _loadMamaKayitlari() {
    try {
      final data = _getLocalString('mama_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'id': (e['id'] ?? _newRecordId('feeding')).toString(),
              'miktar': e['miktar'] ?? 0,
              'tur': e['tur'] ?? '',
              'solDakika': e['solDakika'] ?? 0,
              'sagDakika': e['sagDakika'] ?? 0,
              'kategori': e['kategori'] ?? 'Milk',
              'solidAciklama': e['solidAciklama'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMamaKayitlari() {
    return _mamaKayitlari.where((r) => r['babyId'] == _activeBabyId).toList();
  }

  static Future<void> saveMamaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final now = DateTime.now();
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
      final tarih = (r['tarih'] as DateTime?) ?? now;
      final existingId = r['id']?.toString();
      r['id'] = (existingId != null && existingId.isNotEmpty)
          ? existingId
          : _deterministicDocId(
              babyId: _activeBabyId,
              type: 'feeding',
              keyTime: tarih.toUtc().toIso8601String(),
              extra: '${r['tur'] ?? ''}:${r['miktar'] ?? 0}',
            );
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _mamaKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _mamaKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _mamaKayitlari
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'id': e['id'],
            'miktar': e['miktar'] ?? 0,
            'tur': e['tur'] ?? '',
            'solDakika': e['solDakika'] ?? 0,
            'sagDakika': e['sagDakika'] ?? 0,
            'kategori': e['kategori'] ?? 'Milk',
            'solidAciklama': e['solidAciklama'],
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('mama_kayitlari', jsonEncode(data));
    await _syncActiveBabyRecordsToCloud();
  }

  static Future<bool> updateMamaKaydiById(
    String id,
    Map<String, dynamic> updated,
  ) async {
    final kayitlar = getMamaKayitlari();
    final index = kayitlar.indexWhere((k) => k['id'] == id);
    if (index == -1) return false;
    updated['id'] = id;
    updated['babyId'] = _activeBabyId;
    kayitlar[index] = updated;
    await saveMamaKayitlari(kayitlar);
    return true;
  }

  static Future<bool> deleteMamaKaydiById(String id) async {
    final kayitlar = getMamaKayitlari();
    final before = kayitlar.length;
    kayitlar.removeWhere((k) => k['id'] == id);
    if (kayitlar.length == before) return false;
    await saveMamaKayitlari(kayitlar);
    return true;
  }

  // ============ KAKA ============

  static List<Map<String, dynamic>> _loadKakaKayitlari() {
    try {
      final data = _getLocalString('kaka_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'id': (e['id'] ?? _newRecordId('diaper')).toString(),
              'tur': normalizeDiaperType(e['diaperType'] ?? e['tur']),
              'diaperType': normalizeDiaperType(e['diaperType'] ?? e['tur']),
              'eventType': normalizeDiaperEventType(
                e['eventType'] ?? e['kategori'] ?? e['category'],
              ),
              'notlar': e['notlar'] ?? '',
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getKakaKayitlari() {
    return _kakaKayitlari.where((r) => r['babyId'] == _activeBabyId).toList();
  }

  static Future<void> saveKakaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final now = DateTime.now();
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
      final tarih = (r['tarih'] as DateTime?) ?? now;
      final existingId = r['id']?.toString();
      r['id'] = (existingId != null && existingId.isNotEmpty)
          ? existingId
          : _deterministicDocId(
              babyId: _activeBabyId,
              type: 'diaper',
              keyTime: tarih.toUtc().toIso8601String(),
              extra: '${r['diaperType'] ?? r['tur'] ?? ''}',
            );
      final normalizedType = normalizeDiaperType(r['diaperType'] ?? r['tur']);
      r['tur'] = normalizedType;
      r['diaperType'] = normalizedType;
      r['eventType'] = diaperEventType;
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _kakaKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _kakaKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _kakaKayitlari
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'id': e['id'],
            'tur': normalizeDiaperType(e['diaperType'] ?? e['tur']),
            'diaperType': normalizeDiaperType(e['diaperType'] ?? e['tur']),
            'eventType': normalizeDiaperEventType(
              e['eventType'] ?? e['kategori'] ?? e['category'],
            ),
            'notlar': e['notlar'] ?? '',
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('kaka_kayitlari', jsonEncode(data));
    await _syncActiveBabyRecordsToCloud();
  }

  static Future<bool> updateKakaKaydiById(
    String id,
    Map<String, dynamic> updated,
  ) async {
    final kayitlar = getKakaKayitlari();
    final index = kayitlar.indexWhere((k) => k['id'] == id);
    if (index == -1) return false;
    updated['id'] = id;
    updated['babyId'] = _activeBabyId;
    kayitlar[index] = updated;
    await saveKakaKayitlari(kayitlar);
    return true;
  }

  static Future<bool> deleteKakaKaydiById(String id) async {
    final kayitlar = getKakaKayitlari();
    final before = kayitlar.length;
    kayitlar.removeWhere((k) => k['id'] == id);
    if (kayitlar.length == before) return false;
    await saveKakaKayitlari(kayitlar);
    return true;
  }

  // ============ UYKU ============

  static List<Map<String, dynamic>> _loadUykuKayitlari() {
    try {
      final data = _getLocalString('uyku_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'baslangic': DateTime.parse(e['baslangic']),
              'bitis': DateTime.parse(e['bitis']),
              'id': (e['id'] ?? _newRecordId('sleep')).toString(),
              'sure': Duration(minutes: e['sure']),
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['bitis']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['bitis']),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getUykuKayitlari() {
    return _uykuKayitlari.where((r) => r['babyId'] == _activeBabyId).toList();
  }

  static Future<void> saveUykuKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final now = DateTime.now();
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
      final start = (r['baslangic'] as DateTime?) ?? now;
      final end = (r['bitis'] as DateTime?) ?? now;
      final existingId = r['id']?.toString();
      r['id'] = (existingId != null && existingId.isNotEmpty)
          ? existingId
          : _deterministicDocId(
              babyId: _activeBabyId,
              type: 'sleep',
              keyTime: start.toUtc().toIso8601String(),
              extra: end.toUtc().toIso8601String(),
            );
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _uykuKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _uykuKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _uykuKayitlari
        .map(
          (e) => {
            'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
            'bitis': (e['bitis'] as DateTime).toIso8601String(),
            'id': e['id'],
            'sure': (e['sure'] as Duration).inMinutes,
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('uyku_kayitlari', jsonEncode(data));
    await _syncActiveBabyRecordsToCloud();
  }

  static Future<bool> updateUykuKaydiById(
    String id,
    Map<String, dynamic> updated,
  ) async {
    final kayitlar = getUykuKayitlari();
    final index = kayitlar.indexWhere((k) => k['id'] == id);
    if (index == -1) return false;
    updated['id'] = id;
    updated['babyId'] = _activeBabyId;
    kayitlar[index] = updated;
    await saveUykuKayitlari(kayitlar);
    return true;
  }

  static Future<bool> deleteUykuKaydiById(String id) async {
    final kayitlar = getUykuKayitlari();
    final before = kayitlar.length;
    kayitlar.removeWhere((k) => k['id'] == id);
    if (kayitlar.length == before) return false;
    await saveUykuKayitlari(kayitlar);
    return true;
  }

  // ============ ANILAR ============

  static List<Map<String, dynamic>> _loadAnilar() {
    try {
      final data = _getLocalString('anilar');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'baslik': e['baslik'],
              'not': e['not'],
              'tarih': DateTime.parse(e['tarih']),
              'emoji': e['emoji'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAnilar() {
    final rows = _anilar.where((r) => r['babyId'] == _activeBabyId).toList();
    rows.sort((a, b) {
      final ad =
          a['tarih'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd =
          b['tarih'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final byDate = bd.compareTo(ad);
      if (byDate != 0) return byDate;
      final au =
          a['updatedAt'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bu =
          b['updatedAt'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bu.compareTo(au);
    });
    return rows;
  }

  static Future<void> saveAnilar(List<Map<String, dynamic>> anilar) async {
    final now = DateTime.now();
    for (final r in anilar) {
      r['babyId'] = _activeBabyId;
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _anilar.removeWhere((r) => r['babyId'] == _activeBabyId);
    _anilar.addAll(anilar.map((e) => Map<String, dynamic>.from(e)));

    final data = _anilar
        .map(
          (e) => {
            'baslik': e['baslik'],
            'not': e['not'],
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'emoji': e['emoji'],
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('anilar', jsonEncode(data));
    await _syncActiveBabyMemoriesToCloud();
  }

  // ============ BOY/KILO ============

  static List<Map<String, dynamic>> _loadBoyKiloKayitlari() {
    try {
      final data = _getLocalString('boykilo_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'id':
                  (e['id'] ??
                          _deterministicDocId(
                            babyId: e['babyId'] ?? _activeBabyId,
                            type: 'growth',
                            keyTime: e['tarih'],
                            extra:
                                '${e['boy'] ?? ''}:${e['kilo'] ?? ''}:${e['basCevresi'] ?? ''}',
                          ))
                      .toString(),
              'boy': e['boy'],
              'kilo': e['kilo'],
              'basCevresi': e['basCevresi'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getBoyKiloKayitlari() {
    return _boyKiloKayitlari
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static Future<void> saveBoyKiloKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final now = DateTime.now();
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
      final tarih = (r['tarih'] as DateTime?) ?? now;
      final existingId = r['id']?.toString();
      r['id'] = (existingId != null && existingId.isNotEmpty)
          ? existingId
          : _deterministicDocId(
              babyId: _activeBabyId,
              type: 'growth',
              keyTime: tarih.toUtc().toIso8601String(),
              extra:
                  '${r['boy'] ?? ''}:${r['kilo'] ?? ''}:${r['basCevresi'] ?? ''}',
            );
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _boyKiloKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _boyKiloKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _boyKiloKayitlari
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'id': e['id'],
            'boy': e['boy'],
            'kilo': e['kilo'],
            'basCevresi': e['basCevresi'],
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('boykilo_kayitlari', jsonEncode(data));
    await _syncActiveBabyRecordsToCloud();
  }

  // ============ MILESTONES ============

  static List<Map<String, dynamic>> _loadMilestones() {
    try {
      final data = _getLocalString('milestones');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'id': e['id'],
              'title': e['title'],
              'date': DateTime.parse(e['date']),
              'note': e['note'],
              'photoPath': e['photoPath'],
              'photoStyle': e['photoStyle'] ?? 'softIllustration',
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['date']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['date']),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMilestones() {
    final rows = _milestones
        .where((r) => r['babyId'] == _activeBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    rows.sort((a, b) {
      final ad =
          a['date'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd =
          b['date'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final byDate = bd.compareTo(ad);
      if (byDate != 0) return byDate;

      final au =
          a['updatedAt'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bu =
          b['updatedAt'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0);
      final byUpdated = bu.compareTo(au);
      if (byUpdated != 0) return byUpdated;

      return (b['id']?.toString() ?? '').compareTo(a['id']?.toString() ?? '');
    });

    if (kDebugMode) {
      final top = rows
          .take(3)
          .map((e) => (e['date'] as DateTime?)?.toIso8601String() ?? '-')
          .toList();
      _log('Milestones sorted by date desc. Top3 dates=$top');
    }

    return rows;
  }

  static Future<void> saveMilestones(
    List<Map<String, dynamic>> milestones,
  ) async {
    final now = DateTime.now();
    for (final r in milestones) {
      r['babyId'] = _activeBabyId;
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _milestones.removeWhere((r) => r['babyId'] == _activeBabyId);
    _milestones.addAll(milestones.map((e) => Map<String, dynamic>.from(e)));

    final data = _milestones
        .map(
          (e) => {
            'id': e['id'],
            'title': e['title'],
            'date': (e['date'] as DateTime).toIso8601String(),
            'note': e['note'],
            'photoPath': e['photoPath'],
            'photoStyle': e['photoStyle'] ?? 'softIllustration',
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('milestones', jsonEncode(data));
    await _syncActiveBabyMemoriesToCloud();
  }

  // ============ ASILAR ============

  static List<Map<String, dynamic>> _loadAsiKayitlari() {
    try {
      final data = _getLocalString('asi_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'id': e['id'],
              'ad': e['ad'],
              'donem': e['donem'],
              'tarih': e['tarih'] != null ? DateTime.parse(e['tarih']) : null,
              'durum': e['durum'] ?? 'bekleniyor',
              'notlar': e['notlar'] ?? '',
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : (e['tarih'] != null
                        ? DateTime.parse(e['tarih'])
                        : DateTime.now()),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : (e['tarih'] != null
                        ? DateTime.parse(e['tarih'])
                        : DateTime.now()),
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAsiKayitlari() {
    return _asiKayitlari.where((r) => r['babyId'] == _activeBabyId).toList();
  }

  static ValueNotifier<int> get vaccineNotifier => _vaccineVersion;

  static Future<void> saveAsiKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final now = DateTime.now();
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
      final tarih = (r['tarih'] as DateTime?) ?? now;
      final existingId = r['id']?.toString();
      r['id'] = (existingId != null && existingId.isNotEmpty)
          ? existingId
          : _deterministicDocId(
              babyId: _activeBabyId,
              type: 'vaccine',
              keyTime: tarih.toUtc().toIso8601String(),
              extra: '${r['ad'] ?? ''}:${r['donem'] ?? ''}',
            );
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _asiKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _asiKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _asiKayitlari
        .map(
          (e) => {
            'id': e['id'],
            'ad': e['ad'],
            'donem': e['donem'],
            'tarih': e['tarih'] != null
                ? (e['tarih'] as DateTime).toIso8601String()
                : null,
            'durum': e['durum'] ?? 'bekleniyor',
            'notlar': e['notlar'] ?? '',
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('asi_kayitlari', jsonEncode(data));
    _vaccineVersion.value++;
    await _syncActiveBabyRecordsToCloud();
  }

  // ============ İLAÇLAR ============

  static List<Map<String, dynamic>> _loadIlacKayitlari() {
    try {
      final data = _getLocalString('ilac_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'id': e['id'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'name': e['name'] ?? '',
              'type': e['type'] ?? 'medication',
              'dosage': e['dosage'],
              'scheduleText': e['scheduleText'],
              'scheduleType': _resolveMedicationScheduleType(e),
              'dailyTimes': _resolveMedicationDailyTimes(e),
              'vaccineId': e['vaccineId'],
              'protocolOffsets': _resolveMedicationProtocolOffsets(e),
              'repeatEveryHours': e['repeatEveryHours'],
              'maxDoses': e['maxDoses'],
              'notes': e['notes'],
              'isActive': e['isActive'] ?? true,
              'remindersEnabled': e['remindersEnabled'] == true,
              'createdAt': DateTime.parse(e['createdAt']),
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['createdAt']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['createdAt']),
            }),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String _resolveMedicationScheduleType(dynamic raw) {
    if (raw is! Map) return 'prn';
    final scheduleType = raw['scheduleType'] as String?;
    if (scheduleType == 'daily' ||
        scheduleType == 'prn' ||
        scheduleType == 'vaccine_protocol') {
      return scheduleType!;
    }
    final scheduleText = (raw['scheduleText'] as String?)?.trim() ?? '';
    return scheduleText.isNotEmpty ? 'daily' : 'prn';
  }

  static List<String>? _resolveMedicationDailyTimes(dynamic raw) {
    if (raw is! Map) return null;
    final scheduleType = _resolveMedicationScheduleType(raw);
    if (scheduleType != 'daily') return null;

    final existing = raw['dailyTimes'];
    if (existing is List) {
      final parsed = existing
          .map((e) => e?.toString() ?? '')
          .where((e) => RegExp(r'^\d{2}:\d{2}$').hasMatch(e))
          .toList();
      if (parsed.isNotEmpty) return parsed;
    }

    final scheduleText = (raw['scheduleText'] as String?) ?? '';
    final matches = RegExp(
      r'\b([01]\d|2[0-3]):([0-5]\d)\b',
    ).allMatches(scheduleText).map((m) => m.group(0)!).toList();
    if (matches.isNotEmpty) return matches;
    return ['09:00'];
  }

  static List<Map<String, dynamic>>? _resolveMedicationProtocolOffsets(
    dynamic raw,
  ) {
    if (raw is! Map) return null;
    final scheduleType = _resolveMedicationScheduleType(raw);
    if (scheduleType != 'vaccine_protocol') return null;

    final offsets = raw['protocolOffsets'];
    if (offsets is! List) return null;

    return offsets.map((entry) {
      final map = Map<String, dynamic>.from(entry as Map);
      final kind = (map['kind'] as String?) == 'before' ? 'before' : 'after';
      final minutes = (map['minutes'] as num?)?.toInt() ?? 0;
      return {'kind': kind, 'minutes': minutes};
    }).toList();
  }

  static List<Map<String, dynamic>> getIlacKayitlari() {
    return _ilacKayitlari.where((r) => r['babyId'] == _activeBabyId).toList();
  }

  static Future<void> saveIlacKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final now = DateTime.now();
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
      final createdAt = (r['createdAt'] as DateTime?) ?? now;
      final existingId = r['id']?.toString();
      r['id'] = (existingId != null && existingId.isNotEmpty)
          ? existingId
          : _deterministicDocId(
              babyId: _activeBabyId,
              type: 'medication',
              keyTime: createdAt.toUtc().toIso8601String(),
              extra: '${r['name'] ?? ''}:${r['type'] ?? ''}',
            );
      r['createdAt'] = createdAt;
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
    }

    _ilacKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _ilacKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _ilacKayitlari
        .map(
          (e) => {
            'id': e['id'],
            'babyId': e['babyId'],
            'name': e['name'],
            'type': e['type'],
            'dosage': e['dosage'],
            'scheduleText': e['scheduleText'],
            'scheduleType': e['scheduleType'] ?? 'prn',
            'dailyTimes': e['dailyTimes'],
            'vaccineId': e['vaccineId'],
            'protocolOffsets': e['protocolOffsets'],
            'repeatEveryHours': e['repeatEveryHours'],
            'maxDoses': e['maxDoses'],
            'notes': e['notes'],
            'isActive': e['isActive'] ?? true,
            'remindersEnabled': e['remindersEnabled'] == true,
            'createdAt': (e['createdAt'] as DateTime).toIso8601String(),
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('ilac_kayitlari', jsonEncode(data));
    await _syncActiveBabyMedicationsToCloud();
  }

  static List<Map<String, dynamic>> _loadIlacDozKayitlari() {
    try {
      final data = _getLocalString('ilac_doz_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'id': e['id'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'medicationId': e['medicationId'],
              'vaccineId': e['vaccineId'],
              'givenAt': DateTime.parse(e['givenAt']),
              'doseIndex': (e['doseIndex'] as num?)?.toInt(),
              'scheduledTime': e['scheduledTime']?.toString(),
              'scheduledTimeKey': e['scheduledTimeKey']?.toString(),
              'protocolStep': e['protocolStep']?.toString(),
              'note': e['note'],
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['givenAt']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['givenAt']),
            }),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getIlacDozKayitlari({
    String? medicationId,
    String? vaccineId,
  }) {
    return _ilacDozKayitlari.where((r) {
      if (r['babyId'] != _activeBabyId) return false;
      if (medicationId != null && r['medicationId'] != medicationId) {
        return false;
      }
      if (vaccineId != null && r['vaccineId'] != vaccineId) return false;
      return true;
    }).toList();
  }

  static Future<String> addIlacDozKaydi({
    required String medicationId,
    String? vaccineId,
    DateTime? givenAt,
    int? doseIndex,
    String? scheduledTime,
    String? protocolStep,
    String? note,
  }) async {
    final now = DateTime.now();
    final targetAt = (givenAt ?? now).toUtc().toIso8601String();
    final id = _deterministicDocId(
      babyId: _activeBabyId,
      type: 'medication_log',
      keyTime: targetAt,
      extra: medicationId,
      doseIndex: _normalizeDoseIndex(doseIndex),
    );
    _ilacDozKayitlari.insert(0, {
      'id': id,
      'babyId': _activeBabyId,
      'medicationId': medicationId,
      'vaccineId': vaccineId,
      'givenAt': givenAt ?? DateTime.now(),
      'doseIndex': doseIndex,
      'scheduledTime': scheduledTime,
      'protocolStep': protocolStep,
      'note': note,
      'updatedAt': now,
      'localUpdatedAt': now,
    });
    await _saveIlacDozKayitlari();
    return id;
  }

  static int _normalizeDoseIndex(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static String _localDateKey(DateTime dt) {
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  static String? _scheduledTimeKey(String? scheduledTime) {
    if (scheduledTime == null) return null;
    final t = scheduledTime.trim();
    if (t.isEmpty) return null;
    final normalized = t.replaceAll(':', '');
    if (RegExp(r'^\d{4}$').hasMatch(normalized)) return normalized;
    return null;
  }

  static String _medicationDoseSlotLogId({
    required String medicationId,
    required DateTime dayRef,
    required int doseIndex,
    String? scheduledTime,
    String? protocolStep,
  }) {
    final dayKey = _localDateKey(dayRef);
    final normalizedStep = protocolStep?.trim().toLowerCase();
    if (normalizedStep != null && normalizedStep.isNotEmpty) {
      return '${medicationId}_${dayKey}_$normalizedStep';
    }
    final timeKey = _scheduledTimeKey(scheduledTime);
    if (timeKey != null) {
      return '${medicationId}_${dayKey}_${timeKey}_dose$doseIndex';
    }
    return '${medicationId}_${dayKey}_dose$doseIndex';
  }

  static bool _isSameLocalDate(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  static Future<MedicationDoseMarkResult> markIlacDozKaydiIfAbsent({
    required String medicationId,
    String? vaccineId,
    DateTime? givenAt,
    int? doseIndex,
    String? scheduledTime,
    String? protocolStep,
    String? note,
  }) async {
    final targetGivenAt = givenAt ?? DateTime.now();
    final normalizedDose = _normalizeDoseIndex(doseIndex);
    final normalizedStep = protocolStep?.trim().toLowerCase();
    final scheduledKey = _scheduledTimeKey(scheduledTime);
    final logId = _medicationDoseSlotLogId(
      medicationId: medicationId,
      dayRef: targetGivenAt,
      doseIndex: normalizedDose,
      scheduledTime: scheduledTime,
      protocolStep: normalizedStep,
    );

    final exists = _ilacDozKayitlari.any(
      (r) => r['babyId'] == _activeBabyId && r['id'] == logId,
    );
    _log(
      'Medication onTap logId=$logId exists=$exists '
      'medicationId=$medicationId doseIndex=$normalizedDose scheduledTimeKey=$scheduledKey',
    );
    if (exists) {
      return MedicationDoseMarkResult(logId: logId, alreadyMarked: true);
    }

    final now = DateTime.now();
    _ilacDozKayitlari.insert(0, {
      'id': logId,
      'babyId': _activeBabyId,
      'medicationId': medicationId,
      'vaccineId': vaccineId,
      'givenAt': targetGivenAt,
      'doseIndex': normalizedDose,
      'scheduledTime': scheduledTime,
      'scheduledTimeKey': scheduledKey,
      'protocolStep': normalizedStep,
      'note': note,
      'updatedAt': now,
      'localUpdatedAt': now,
    });
    await _saveIlacDozKayitlari();
    return MedicationDoseMarkResult(logId: logId, alreadyMarked: false);
  }

  static Future<bool> undoIlacDozKaydiBySlot({
    required String medicationId,
    DateTime? dayRef,
    int? doseIndex,
    String? scheduledTime,
    String? protocolStep,
  }) async {
    final ref = dayRef ?? DateTime.now();
    final normalizedDose = _normalizeDoseIndex(doseIndex);
    final normalizedStep = protocolStep?.trim().toLowerCase();
    final logId = _medicationDoseSlotLogId(
      medicationId: medicationId,
      dayRef: ref,
      doseIndex: normalizedDose,
      scheduledTime: scheduledTime,
      protocolStep: normalizedStep,
    );
    final existed = _ilacDozKayitlari.any(
      (r) => r['babyId'] == _activeBabyId && r['id'] == logId,
    );
    if (existed) {
      await deleteIlacDozKaydi(logId);
    }
    _log('Medication onUndo logId=$logId existed=$existed deleted=$existed');
    return existed;
  }

  static Future<String> upsertIlacDozKaydi({
    required String medicationId,
    String? vaccineId,
    DateTime? givenAt,
    int? doseIndex,
    String? scheduledTime,
    String? protocolStep,
    String? note,
  }) async {
    final targetGivenAt = givenAt ?? DateTime.now();
    final targetDoseIndex = _normalizeDoseIndex(doseIndex);
    final targetProtocolStep = protocolStep?.trim().toLowerCase();
    final matchingIndexes = <int>[];
    for (int i = 0; i < _ilacDozKayitlari.length; i++) {
      final r = _ilacDozKayitlari[i];
      if (r['babyId'] != _activeBabyId) continue;
      if (r['medicationId'] != medicationId) continue;
      final existingGivenAt = r['givenAt'] as DateTime?;
      if (existingGivenAt == null) continue;
      if (!_isSameLocalDate(existingGivenAt, targetGivenAt)) continue;
      if (targetProtocolStep != null && targetProtocolStep.isNotEmpty) {
        final existingStep = r['protocolStep']?.toString().trim().toLowerCase();
        if (existingStep != targetProtocolStep) continue;
      } else {
        if (_normalizeDoseIndex(r['doseIndex']) != targetDoseIndex) continue;
      }
      matchingIndexes.add(i);
    }

    if (matchingIndexes.isNotEmpty) {
      int primaryIndex = matchingIndexes.first;
      for (final idx in matchingIndexes.skip(1)) {
        final current = _ilacDozKayitlari[idx]['givenAt'] as DateTime;
        final primary = _ilacDozKayitlari[primaryIndex]['givenAt'] as DateTime;
        if (current.isAfter(primary)) primaryIndex = idx;
      }

      for (final idx in matchingIndexes.reversed) {
        if (idx == primaryIndex) continue;
        _ilacDozKayitlari.removeAt(idx);
        if (idx < primaryIndex) primaryIndex--;
      }

      final existing = _ilacDozKayitlari[primaryIndex];
      existing['givenAt'] = targetGivenAt;
      existing['vaccineId'] = vaccineId;
      existing['doseIndex'] = targetDoseIndex;
      existing['scheduledTime'] = scheduledTime;
      existing['protocolStep'] = targetProtocolStep;
      existing['note'] = note;
      existing['updatedAt'] = DateTime.now();
      existing['localUpdatedAt'] = DateTime.now();
      await _saveIlacDozKayitlari();
      return existing['id'] as String;
    }

    return addIlacDozKaydi(
      medicationId: medicationId,
      vaccineId: vaccineId,
      givenAt: targetGivenAt,
      doseIndex: targetDoseIndex,
      scheduledTime: scheduledTime,
      protocolStep: targetProtocolStep,
      note: note,
    );
  }

  static Future<void> deleteIlacDozKaydi(String doseId) async {
    _ilacDozKayitlari.removeWhere(
      (r) => r['babyId'] == _activeBabyId && r['id'] == doseId,
    );
    await _saveIlacDozKayitlari();
  }

  static Future<void> _saveIlacDozKayitlari() async {
    final now = DateTime.now();
    for (final row in _ilacDozKayitlari) {
      row['updatedAt'] = row['updatedAt'] ?? now;
      row['localUpdatedAt'] = row['localUpdatedAt'] ?? now;
    }
    await _setLocalString(
      'ilac_doz_kayitlari',
      jsonEncode(
        _ilacDozKayitlari
            .map(
              (e) => {
                'id': e['id'],
                'babyId': e['babyId'],
                'medicationId': e['medicationId'],
                'vaccineId': e['vaccineId'],
                'givenAt': (e['givenAt'] as DateTime).toIso8601String(),
                'doseIndex': e['doseIndex'],
                'scheduledTime': e['scheduledTime'],
                'scheduledTimeKey': e['scheduledTimeKey'],
                'protocolStep': e['protocolStep'],
                'note': e['note'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
    await _syncActiveBabyMedicationLogsToCloud();
  }

  // ============ TEMA & SETTINGS ============

  static bool isFirstLaunch() {
    return _firstLaunch;
  }

  static Future<void> setFirstLaunchComplete() async {
    _firstLaunch = false;
    await _prefs!.setBool('first_launch', false);
  }

  static bool isLoginEntryShown() {
    return _loginEntryShown;
  }

  static Future<void> setLoginEntryShown() async {
    _loginEntryShown = true;
    await _prefs!.setBool('login_entry_shown', true);
  }

  static bool isDarkMode() {
    return _darkMode;
  }

  static Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _prefs!.setBool('dark_mode', value);
  }

  // ============ REMINDER SETTINGS ============

  static bool isFeedingReminderEnabled() => _feedingReminderEnabled;

  static Future<void> setFeedingReminderEnabled(bool value) async {
    _feedingReminderEnabled = value;
    await _prefs!.setBool('feeding_reminder_enabled', value);
  }

  static int getFeedingReminderInterval() => _feedingReminderInterval;

  static Future<void> setFeedingReminderInterval(int minutes) async {
    _feedingReminderInterval = minutes;
    await _prefs!.setInt('feeding_reminder_interval', minutes);
  }

  static int getFeedingReminderHour() => _feedingReminderHour;

  static int getFeedingReminderMinute() => _feedingReminderMinute;

  static Future<void> setFeedingReminderTime(int hour, int minute) async {
    _feedingReminderHour = hour;
    _feedingReminderMinute = minute;
    await _prefs!.setInt('feeding_reminder_time_h', hour);
    await _prefs!.setInt('feeding_reminder_time_m', minute);
  }

  static bool isDiaperReminderEnabled() => _diaperReminderEnabled;

  static Future<void> setDiaperReminderEnabled(bool value) async {
    _diaperReminderEnabled = value;
    await _prefs!.setBool('diaper_reminder_enabled', value);
  }

  static bool isMedicationReminderEnabled() => _medicationRemindersEnabled;

  static Future<void> setMedicationReminderEnabled(bool value) async {
    _medicationRemindersEnabled = value;
    await _prefs!.setBool('medication_reminder_enabled', value);
  }

  static int getDiaperReminderInterval() => _diaperReminderInterval;

  static Future<void> setDiaperReminderInterval(int minutes) async {
    _diaperReminderInterval = minutes;
    await _prefs!.setInt('diaper_reminder_interval', minutes);
  }

  static int getDiaperReminderHour() => _diaperReminderHour;

  static int getDiaperReminderMinute() => _diaperReminderMinute;

  static Future<void> setDiaperReminderTime(int hour, int minute) async {
    _diaperReminderHour = hour;
    _diaperReminderMinute = minute;
    await _prefs!.setInt('diaper_reminder_time_h', hour);
    await _prefs!.setInt('diaper_reminder_time_m', minute);
  }

  // ============ BABY NAME & BIRTH DATE ============

  static String getBabyName() {
    // Safety: ensure we never return empty name
    if (_babyName.isEmpty) {
      return 'Baby';
    }
    return _babyName;
  }

  static Future<void> setBabyName(String name) async {
    _babyName = name;
    await _setLocalString('baby_name', name);
    await updateBaby(_activeBabyId, name: name);
  }

  static DateTime getBirthDate() {
    // Safety: ensure we never return invalid date
    if (_birthDate.year < 1900) {
      return DateTime.now().subtract(const Duration(days: 30));
    }
    return _birthDate;
  }

  static Future<void> setBirthDate(DateTime date) async {
    _birthDate = date;
    await _setLocalString('birth_date', date.toIso8601String());
    await updateBaby(_activeBabyId, birthDate: date);
  }

  static String? getBabyPhotoPath() {
    return _babyPhotoPath;
  }

  static Future<void> setBabyPhotoPath(String? path) async {
    _babyPhotoPath = path;
    if (path != null) {
      await _setLocalString('baby_photo_path', path);
      await updateBaby(_activeBabyId, photoPath: path);
    } else {
      await _prefs!.remove('baby_photo_path');
      await updateBaby(_activeBabyId, clearPhoto: true);
    }
  }

  // ============ VERİLERİ TEMİZLE (active baby only) ============

  static Future<void> verileriTemizle() async {
    _mamaKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _kakaKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _uykuKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _anilar.removeWhere((r) => r['babyId'] == _activeBabyId);
    _boyKiloKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _milestones.removeWhere((r) => r['babyId'] == _activeBabyId);
    _asiKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _ilacKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _ilacDozKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);

    await _saveAllCollections();
    await _syncActiveBabyRecordsToCloud();
    await _syncActiveBabyMemoriesToCloud();
    await _syncActiveBabyMedicationsToCloud();
    await _syncActiveBabyMedicationLogsToCloud();
  }

  // ============ HELPERS ============

  static Future<void> _saveAllCollections() async {
    await _setLocalString(
      'mama_kayitlari',
      jsonEncode(
        _mamaKayitlari
            .map(
              (e) => {
                'tarih': (e['tarih'] as DateTime).toIso8601String(),
                'id': e['id'],
                'miktar': e['miktar'] ?? 0,
                'tur': e['tur'] ?? '',
                'solDakika': e['solDakika'] ?? 0,
                'sagDakika': e['sagDakika'] ?? 0,
                'kategori': e['kategori'] ?? 'Milk',
                'solidAciklama': e['solidAciklama'],
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'kaka_kayitlari',
      jsonEncode(
        _kakaKayitlari
            .map(
              (e) => {
                'tarih': (e['tarih'] as DateTime).toIso8601String(),
                'id': e['id'],
                'tur': normalizeDiaperType(e['diaperType'] ?? e['tur']),
                'diaperType': normalizeDiaperType(e['diaperType'] ?? e['tur']),
                'eventType': normalizeDiaperEventType(
                  e['eventType'] ?? e['kategori'] ?? e['category'],
                ),
                'notlar': e['notlar'] ?? '',
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'uyku_kayitlari',
      jsonEncode(
        _uykuKayitlari
            .map(
              (e) => {
                'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
                'bitis': (e['bitis'] as DateTime).toIso8601String(),
                'id': e['id'],
                'sure': (e['sure'] as Duration).inMinutes,
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'anilar',
      jsonEncode(
        _anilar
            .map(
              (e) => {
                'baslik': e['baslik'],
                'not': e['not'],
                'tarih': (e['tarih'] as DateTime).toIso8601String(),
                'emoji': e['emoji'],
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'boykilo_kayitlari',
      jsonEncode(
        _boyKiloKayitlari
            .map(
              (e) => {
                'tarih': (e['tarih'] as DateTime).toIso8601String(),
                'id': e['id'],
                'boy': e['boy'],
                'kilo': e['kilo'],
                'basCevresi': e['basCevresi'],
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'milestones',
      jsonEncode(
        _milestones
            .map(
              (e) => {
                'id': e['id'],
                'title': e['title'],
                'date': (e['date'] as DateTime).toIso8601String(),
                'note': e['note'],
                'photoPath': e['photoPath'],
                'photoStyle': e['photoStyle'] ?? 'softIllustration',
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'asi_kayitlari',
      jsonEncode(
        _asiKayitlari
            .map(
              (e) => {
                'id': e['id'],
                'ad': e['ad'],
                'donem': e['donem'],
                'tarih': e['tarih'] != null
                    ? (e['tarih'] as DateTime).toIso8601String()
                    : null,
                'durum': e['durum'] ?? 'bekleniyor',
                'notlar': e['notlar'] ?? '',
                'babyId': e['babyId'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'ilac_kayitlari',
      jsonEncode(
        _ilacKayitlari
            .map(
              (e) => {
                'id': e['id'],
                'babyId': e['babyId'],
                'name': e['name'],
                'type': e['type'],
                'dosage': e['dosage'],
                'scheduleText': e['scheduleText'],
                'scheduleType': e['scheduleType'] ?? 'prn',
                'dailyTimes': e['dailyTimes'],
                'vaccineId': e['vaccineId'],
                'protocolOffsets': e['protocolOffsets'],
                'remindersEnabled': e['remindersEnabled'] == true,
                'repeatEveryHours': e['repeatEveryHours'],
                'maxDoses': e['maxDoses'],
                'notes': e['notes'],
                'isActive': e['isActive'] ?? true,
                'createdAt': (e['createdAt'] as DateTime).toIso8601String(),
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _setLocalString(
      'ilac_doz_kayitlari',
      jsonEncode(
        _ilacDozKayitlari
            .map(
              (e) => {
                'id': e['id'],
                'babyId': e['babyId'],
                'medicationId': e['medicationId'],
                'vaccineId': e['vaccineId'],
                'givenAt': (e['givenAt'] as DateTime).toIso8601String(),
                'doseIndex': e['doseIndex'],
                'scheduledTime': e['scheduledTime'],
                'protocolStep': e['protocolStep'],
                'note': e['note'],
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
  }
}
