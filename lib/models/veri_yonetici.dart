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
      final remote = await syncService.pullRemoteCoreData(uid);
      final merged = syncService.mergeCoreData(
        local: _currentCoreBundle(),
        remote: remote,
      );

      _babies = merged.babies;
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
    _babies = _loadBabies();
    _activeBabyId = _getLocalString('active_baby_id') ?? '';

    // ALWAYS ensure at least one baby exists (critical for guest mode)
    if (_babies.isEmpty) {
      // Create default baby from legacy data or use defaults
      final defaultName = _getLocalString('baby_name') ?? 'Baby';
      final defaultPhotoPath = _getLocalString('baby_photo_path');
      final birthDateStr = _getLocalString('birth_date');
      final defaultBirthDate = birthDateStr != null
          ? DateTime.parse(birthDateStr)
          : DateTime.now().subtract(
              const Duration(days: 30),
            ); // 1 month old default

      final defaultBaby = Baby(
        id: Baby.generateId(),
        name: defaultName,
        birthDate: defaultBirthDate,
        photoPath: defaultPhotoPath,
      );

      _babies.add(defaultBaby);
      _activeBabyId = defaultBaby.id;
      await _saveBabies();
      await _setLocalString('active_baby_id', _activeBabyId);
    } else if (!_babies.any((b) => b.id == _activeBabyId)) {
      // Babies exist but active ID is invalid - use first baby
      _activeBabyId = _babies.first.id;
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
      // Fallback - should never happen after our fix above
      _babyName = _getLocalString('baby_name') ?? 'Baby';
      _babyPhotoPath = _getLocalString('baby_photo_path');
      final birthDateStr = _getLocalString('birth_date');
      _birthDate = birthDateStr != null
          ? DateTime.parse(birthDateStr)
          : DateTime.now().subtract(const Duration(days: 30));
    }

    // CRITICAL: Final validation - ensure we ALWAYS have a valid active baby
    if (_babies.isEmpty ||
        _activeBabyId.isEmpty ||
        !_babies.any((b) => b.id == _activeBabyId)) {
      // This should never happen, but if it does, create emergency default baby
      final emergencyBaby = Baby(
        id: Baby.generateId(),
        name: 'Baby',
        birthDate: DateTime.now().subtract(const Duration(days: 30)),
        photoPath: null,
      );
      _babies.add(emergencyBaby);
      _activeBabyId = emergencyBaby.id;
      _babyName = emergencyBaby.name;
      _birthDate = emergencyBaby.birthDate;
      _babyPhotoPath = emergencyBaby.photoPath;
      await _saveBabies();
      await _setLocalString('active_baby_id', _activeBabyId);
    }

    // Initialize TimerYonetici
    await TimerYonetici().init(_prefs!);
  }

  // ============ MIGRATION ============

  static Future<void> _migrateToMultiBaby() async {
    // Check if babies key already exists (partial migration)
    final existingBabiesData = _getLocalString('babies');
    String defaultBabyId;

    if (existingBabiesData != null && existingBabiesData.isNotEmpty) {
      try {
        final existing = jsonDecode(existingBabiesData) as List;
        if (existing.isNotEmpty) {
          defaultBabyId = existing[0]['id'] as String;
        } else {
          defaultBabyId = Baby.generateId();
        }
      } catch (_) {
        defaultBabyId = Baby.generateId();
      }
    } else {
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

    // Tag all existing records with the default baby ID
    await _tagExistingRecords('mama_kayitlari', defaultBabyId);
    await _tagExistingRecords('kaka_kayitlari', defaultBabyId);
    await _tagExistingRecords('uyku_kayitlari', defaultBabyId);
    await _tagExistingRecords('anilar', defaultBabyId);
    await _tagExistingRecords('boykilo_kayitlari', defaultBabyId);
    await _tagExistingRecords('milestones', defaultBabyId);
    await _tagExistingRecords('asi_kayitlari', defaultBabyId);
    await _tagExistingRecords('ilac_kayitlari', defaultBabyId);

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
    final data = _babies.map((b) => b.toJson()).toList();
    await _setLocalString('babies', jsonEncode(data));
  }

  static List<Baby> getBabies() {
    return List.from(_babies);
  }

  static Baby getActiveBaby() {
    try {
      return _babies.firstWhere((b) => b.id == _activeBabyId);
    } catch (e) {
      // Emergency fallback - should never happen after proper init
      // If it does, return first baby or create a default
      if (_babies.isNotEmpty) {
        return _babies.first;
      }
      // Absolute last resort - create and return a temp baby
      final emergencyBaby = Baby(
        id: Baby.generateId(),
        name: 'Baby',
        birthDate: DateTime.now().subtract(const Duration(days: 30)),
        photoPath: null,
      );
      _babies.add(emergencyBaby);
      _activeBabyId = emergencyBaby.id;
      _babyName = emergencyBaby.name;
      _birthDate = emergencyBaby.birthDate;
      _saveBabies(); // Save async without await
      _setLocalString('active_baby_id', _activeBabyId);
      return emergencyBaby;
    }
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
    required String name,
    required DateTime birthDate,
    String? photoPath,
  }) async {
    final baby = Baby(
      id: Baby.generateId(),
      name: name,
      birthDate: birthDate,
      photoPath: photoPath,
    );
    _babies.add(baby);
    await _saveBabies();
    await _syncBabiesToCloud();
    return baby.id;
  }

  static Future<bool> removeBaby(String babyId) async {
    if (_babies.length <= 1) return false;
    _babies.removeWhere((b) => b.id == babyId);

    _mamaKayitlari.removeWhere((r) => r['babyId'] == babyId);
    _kakaKayitlari.removeWhere((r) => r['babyId'] == babyId);
    _uykuKayitlari.removeWhere((r) => r['babyId'] == babyId);
    _anilar.removeWhere((r) => r['babyId'] == babyId);
    _boyKiloKayitlari.removeWhere((r) => r['babyId'] == babyId);
    _milestones.removeWhere((r) => r['babyId'] == babyId);
    _asiKayitlari.removeWhere((r) => r['babyId'] == babyId);
    _ilacKayitlari.removeWhere((r) => r['babyId'] == babyId);
    _ilacDozKayitlari.removeWhere((r) => r['babyId'] == babyId);

    if (_activeBabyId == babyId) {
      await setActiveBaby(_babies.first.id);
    }

    await _saveBabies();
    await _saveAllCollections();
    final uid = _currentUid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await _firestoreStore.deleteBabyData(uid, babyId: babyId);
      } catch (_) {}
      await _syncBabiesToCloud();
    }
    return true;
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
    return _anilar.where((r) => r['babyId'] == _activeBabyId).toList();
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
    return _milestones.where((r) => r['babyId'] == _activeBabyId).toList();
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

  static bool _isSameLocalDate(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
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
