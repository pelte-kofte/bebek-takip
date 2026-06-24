import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/data_repository.dart';
import '../data/local/local_store.dart';
import '../data/local/shared_preferences_local_store.dart';
import '../data/stores/firestore_store.dart';
import '../services/data_sync_service.dart';
import '../services/photo_storage_sync_service.dart';
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

class _SharedBabyTruthCacheEntry {
  const _SharedBabyTruthCacheEntry({
    required this.isShared,
    required this.checkedAt,
  });

  final bool isShared;
  final DateTime checkedAt;
}

class VeriYonetici {
  // Singleton instance
  static SharedPreferences? _prefs;
  static LocalStore? _localStore;
  static const Duration _bestEffortWriteTimeout = Duration(seconds: 3);
  static const Duration _bestEffortPhotoStorageTimeout = Duration(seconds: 20);

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
  static final ValueNotifier<int> _dataVersion = ValueNotifier<int>(0);
  static bool _darkMode = false;
  static bool _firstLaunch = true;
  static bool _loginEntryShown = false;

  // Reminder settings
  static bool _feedingReminderEnabled = false;
  static int _feedingReminderInterval = 180; // 3 hours default
  static bool _diaperReminderEnabled = false;
  static int _diaperReminderInterval = 120; // 2 hours default
  static bool _dailyTipReminderEnabled = false;
  static bool _medicationRemindersEnabled = true;
  static int _feedingReminderHour = 14;
  static int _feedingReminderMinute = 0;
  static int _diaperReminderHour = 14;
  static int _diaperReminderMinute = 0;
  static int _dailyTipReminderHour = 10;
  static int _dailyTipReminderMinute = 0;

  static String _babyName = 'Sofia';
  static DateTime _birthDate = DateTime(2024, 9, 17);
  static String? _babyPhotoPath;

  // Multi-baby support
  static List<Baby> _babies = [];
  static String _activeBabyId = '';
  // IDs of babies that were shared with this user (not owned by them).
  // Populated after cloud sync. Used only for display labelling.
  static final Set<String> _sharedBabyIds = {};
  // IDs of babies owned by this user that have at least one co-parent.
  // Populated from RepositoryDataBundle.ownedBabyIdsWithMembers after sync.
  static final Set<String> _ownedBabyIdsWithMembers = {};
  static const String _migrationKey = 'multi_baby_migrated';
  static const String diaperEventType = 'diaper';
  static final FirestoreStore _firestoreStore = FirestoreStore();
  static DataSyncService? _dataSyncService;
  static final PhotoStorageSyncService _photoStorageSyncService =
      PhotoStorageSyncService();
  static const bool _verboseSyncLogs = true;
  static final Map<String, String> _lastCloudFingerprintByKey = {};
  static final Map<String, DateTime> _lastCloudWriteAtByKey = {};
  static final Map<String, _SharedBabyTruthCacheEntry>
  _sharedBabyTruthCacheByBabyId = {};
  static const Duration _sharedBabyTruthCacheTtl = Duration(minutes: 3);

  // Real-time listeners on shared-critical collections for each baby.
  // Key = babyId:collection. Started after each sync; cancelled and
  // restarted on refreshForCurrentUser() so the set stays accurate.
  static final Map<String, StreamSubscription<dynamic>> _sharedListeners = {};
  static final Map<String, Timer> _sharedRefreshDebounceByBabyId = {};
  static const String _lastAuthScopeKey = 'last_auth_scope_key';

  static const List<String> _timerKeysByBabyTemplate = <String>[
    'active_uyku_start_{babyId}',
    'active_emzirme_start_{babyId}',
    'active_emzirme_ilk_start_{babyId}',
    'active_emzirme_tur_{babyId}',
    'active_emzirme_taraf_{babyId}',
    'active_emzirme_sol_saniye_{babyId}',
    'active_emzirme_sag_saniye_{babyId}',
  ];

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
  static User? get _currentUser => FirebaseAuth.instance.currentUser;

  static String get currentUserDisplayName =>
      _currentUser?.displayName?.trim() ?? '';

  static void attachCreatorMetadataIfAbsent(Map<String, dynamic> row) {
    if ((row['createdBy'] ?? '').toString().trim().isNotEmpty) return;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    row['createdBy'] = uid;
    row['createdByName'] = currentUserDisplayName;
  }

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

  static bool _canSyncWithCloud({
    required String operation,
    required String skipMessage,
  }) {
    final user = _currentUser;
    _log('[Sync] $operation auth ${DataSyncService.authStateSummary(user)}');
    final canSync = DataSyncService.canWriteToCloud(user);
    if (!canSync) {
      _log(skipMessage);
    }
    return canSync;
  }

  static void _notifyDataChanged({required String reason}) {
    _dataVersion.value++;
    _log('UI refresh triggered (data changed signal fired) reason=$reason');
  }

  static String _sharedRecordPath(String babyId, String recordId) =>
      'babies/$babyId/records/$recordId';

  static String _sharedCollectionPath(String babyId, String collection) =>
      'babies/$babyId/$collection';

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
    if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
    if (value is Duration) return value.inMilliseconds;
    return value;
  }

  static String _cloudWriteFingerprint(dynamic payload) {
    return jsonEncode(_canonicalize(payload));
  }

  static bool _shouldSkipDuplicateCloudWrite(String key, String fp) {
    final now = DateTime.now();
    final lastFp = _lastCloudFingerprintByKey[key];
    final lastAt = _lastCloudWriteAtByKey[key];
    if (lastFp == fp &&
        lastAt != null &&
        now.difference(lastAt) < const Duration(seconds: 2)) {
      _log('Skipping duplicate cloud write for key=$key');
      return true;
    }
    return false;
  }

  static void _rememberSuccessfulCloudWrite(String key, String fp) {
    final now = DateTime.now();
    _lastCloudFingerprintByKey[key] = fp;
    _lastCloudWriteAtByKey[key] = now;
  }

  static Future<void> _withIdempotentCloudWrite(
    String key,
    dynamic payload,
    Future<void> Function() action,
  ) async {
    final fp = _cloudWriteFingerprint(payload);
    if (_shouldSkipDuplicateCloudWrite(key, fp)) return;
    await action();
    _rememberSuccessfulCloudWrite(key, fp);
  }

  static String _authScopeKeyForUser(User? user) {
    if (user == null) return 'signed_out';
    if (user.isAnonymous) return 'anonymous:${user.uid}';
    return 'user:${user.uid}';
  }

  static Future<void> _resetLocalCachesForAuthScopeChange({
    required String fromScope,
    required String toScope,
  }) async {
    _log(
      'Auth scope changed from $fromScope to $toScope; clearing local caches',
    );
    _stopSharedRecordListeners();
    _babies = [];
    _mamaKayitlari = [];
    _kakaKayitlari = [];
    _uykuKayitlari = [];
    _anilar = [];
    _boyKiloKayitlari = [];
    _milestones = [];
    _asiKayitlari = [];
    _ilacKayitlari = [];
    _ilacDozKayitlari = [];
    _activeBabyId = '';
    _sharedBabyIds.clear();
    _ownedBabyIdsWithMembers.clear();
    _sharedBabyTruthCacheByBabyId.clear();
    _lastCloudFingerprintByKey.clear();
    _lastCloudWriteAtByKey.clear();
    await _saveBabies();
    await _saveAllCollections();
    await _setLocalString('active_baby_id', '');
    await _setLocalString(_lastAuthScopeKey, toScope);
    _syncCachedActiveBabyFields();
    _notifyDataChanged(reason: 'auth-scope-reset');
  }

  static Future<void> _pruneLocalCachesForAuthScopeIfNeeded() async {
    final currentScope = _authScopeKeyForUser(_currentUser);
    final previousScope = _getLocalString(_lastAuthScopeKey);
    if (previousScope == null || previousScope.isEmpty) {
      await _setLocalString(_lastAuthScopeKey, currentScope);
      return;
    }
    if (previousScope == currentScope) return;
    await _resetLocalCachesForAuthScopeChange(
      fromScope: previousScope,
      toScope: currentScope,
    );
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

  static Future<void> _restoreCoreBundle(
    RepositoryDataBundle bundle, {
    required String reason,
  }) async {
    _babies = _dedupeBabiesById(List<Baby>.from(bundle.babies));
    _mamaKayitlari = bundle.mamaKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _kakaKayitlari = bundle.kakaKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _uykuKayitlari = bundle.uykuKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _boyKiloKayitlari = bundle.boyKiloKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _asiKayitlari = bundle.asiKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _milestones = bundle.milestones
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _anilar = bundle.anilar.map((e) => Map<String, dynamic>.from(e)).toList();
    _ilacKayitlari = bundle.ilacKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _ilacDozKayitlari = bundle.ilacDozKayitlari
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (_activeBabyId.isNotEmpty &&
        !_babies.any((b) => b.id == _activeBabyId)) {
      _activeBabyId = _babies.isNotEmpty ? _babies.first.id : '';
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    await _saveBabies();
    await _saveAllCollections();
    _syncCachedActiveBabyFields();
    _notifyDataChanged(reason: reason);
  }

  static String _deterministicDocId({
    required String babyId,
    required String type,
    required String keyTime,
    String extra = '',
    int doseIndex = 0,
  }) {
    final raw = '$babyId:$type:$keyTime:$doseIndex:$extra';
    return sha1.convert(utf8.encode(raw)).toString();
  }

  static String _stableDateToken(dynamic value) {
    final dt = value is DateTime
        ? value
        : (value is String ? DateTime.tryParse(value) : null);
    if (dt == null) return '';
    return dt.toUtc().toIso8601String();
  }

  static bool _isNursingMamaRow(Map<String, dynamic> row) {
    final explicitType = (row['type'] ?? '').toString().trim().toLowerCase();
    if (explicitType == 'nursing') return true;
    final kategori = (row['kategori'] ?? 'Milk')
        .toString()
        .trim()
        .toLowerCase();
    final tur = (row['tur'] ?? '').toString().trim().toLowerCase();
    return kategori != 'solid' &&
        tur.contains('anne') &&
        !tur.contains('biberon');
  }

  static String _repairNaturalKeyFor(String entity, Map<String, dynamic> row) {
    final babyId = (row['babyId'] ?? _activeBabyId).toString();
    switch (entity) {
      case 'feeding':
        final explicitType = (row['type'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        final type = explicitType.isNotEmpty
            ? explicitType
            : (_isNursingMamaRow(row) ? 'nursing' : 'feeding');
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
      case 'medication_log':
        final givenAt = _stableDateToken(row['givenAt']);
        return 'medlog|$babyId|${row['medicationId'] ?? ''}|$givenAt|${row['doseIndex'] ?? ''}|${row['scheduledTime'] ?? ''}|${row['protocolStep'] ?? ''}';
      default:
        return '$entity|$babyId';
    }
  }

  static String _ensureStableIdForRow(
    Map<String, dynamic> row, {
    required String entity,
    int seed = 0,
  }) {
    final existing = (row['id'] ?? '').toString().trim();
    if (existing.isNotEmpty) return existing;

    final nk = _repairNaturalKeyFor(entity, row);
    final nkHasSignal = nk.replaceAll('|', '').trim().isNotEmpty;
    final keyTime = nkHasSignal
        ? nk
        : '${DateTime.now().microsecondsSinceEpoch}:$seed';
    final repaired = _deterministicDocId(
      babyId: (row['babyId'] ?? _activeBabyId).toString(),
      type: entity,
      keyTime: keyTime,
      extra: nkHasSignal ? 'legacy-repair' : 'legacy-fallback',
      doseIndex: seed,
    );
    row['id'] = repaired;
    return repaired;
  }

  static bool _repairMissingIdsInRows({
    required List<Map<String, dynamic>> rows,
    required String entity,
  }) {
    var changed = false;
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final before = (row['id'] ?? '').toString().trim();
      final after = _ensureStableIdForRow(row, entity: entity, seed: i);
      if (before != after) changed = true;
    }
    return changed;
  }

  // Legacy repair: assign stable IDs once for old rows that were saved without id.
  static Future<void> _repairMissingIdsAndPersistIfNeeded() async {
    var changed = false;
    changed =
        _repairMissingIdsInRows(rows: _mamaKayitlari, entity: 'feeding') ||
        changed;
    changed =
        _repairMissingIdsInRows(rows: _kakaKayitlari, entity: 'diaper') ||
        changed;
    changed =
        _repairMissingIdsInRows(rows: _uykuKayitlari, entity: 'sleep') ||
        changed;
    changed =
        _repairMissingIdsInRows(rows: _anilar, entity: 'memory') || changed;
    changed =
        _repairMissingIdsInRows(rows: _milestones, entity: 'milestone') ||
        changed;
    changed =
        _repairMissingIdsInRows(rows: _boyKiloKayitlari, entity: 'growth') ||
        changed;
    changed =
        _repairMissingIdsInRows(rows: _asiKayitlari, entity: 'vaccine') ||
        changed;
    changed =
        _repairMissingIdsInRows(rows: _ilacKayitlari, entity: 'medication') ||
        changed;
    changed =
        _repairMissingIdsInRows(
          rows: _ilacDozKayitlari,
          entity: 'medication_log',
        ) ||
        changed;
    if (changed) {
      _log('Legacy ID repair applied for missing ids; persisting once.');
      await _saveAllCollections();
    }
  }

  static bool _rowIsDeleted(Map<String, dynamic> row) =>
      row['isDeleted'] == true;

  static Map<String, dynamic> _tombstoneRowFrom(
    Map<String, dynamic> source, {
    required DateTime now,
  }) {
    final map = Map<String, dynamic>.from(source);
    map['isDeleted'] = true;
    map['deletedAt'] = now;
    map['updatedAt'] = now;
    map['localUpdatedAt'] = now;
    return map;
  }

  static List<Map<String, dynamic>> _mergeActiveRowsWithTombstones({
    required String babyId,
    required List<Map<String, dynamic>> existingAll,
    required List<Map<String, dynamic>> incomingActive,
    required DateTime now,
  }) {
    final existingForBaby = existingAll
        .where((r) => r['babyId'] == babyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final existingActive = existingForBaby.where((r) => !_rowIsDeleted(r));
    final existingTombstones = existingForBaby.where(_rowIsDeleted);
    final incomingIds = incomingActive
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    final generatedTombstones = existingActive
        .where((r) => !incomingIds.contains((r['id'] ?? '').toString()))
        .map((r) => _tombstoneRowFrom(r, now: now));

    final merged = <Map<String, dynamic>>[];
    merged.addAll(incomingActive.map((e) => Map<String, dynamic>.from(e)));
    merged.addAll(
      existingTombstones
          .where((r) => !incomingIds.contains((r['id'] ?? '').toString()))
          .map((e) => Map<String, dynamic>.from(e)),
    );
    merged.addAll(generatedTombstones);
    return merged;
  }

  static Future<void> _syncFromCloudIfSignedIn() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncFromCloudIfSignedIn',
      skipMessage: '[Sync] skip cloud read: user is anonymous',
    )) {
      return;
    }

    try {
      _log('Starting cloud sync for uid=$uid');
      final syncService = _dataSyncService;
      if (syncService == null) return;
      final localBabiesBefore = _babies.length;
      var remote = await syncService.pullRemoteCoreData(uid);
      final shouldRunDedupe = await syncService.shouldRunDedupeMigration(uid);
      if (shouldRunDedupe) {
        final dedupeResult = syncService.buildDedupeMigrationBundle(remote);
        remote = dedupeResult.bundle;
        if (dedupeResult.changed) {
          _log('Running one-time remote dedupe migration for uid=$uid');
          await _pushBundleToCloudStrict(uid, dedupeResult.bundle);
        }
        await syncService.markDedupeMigrationDone(uid);
      }
      final authUser = _currentUser;
      _log(
        'Startup auth uid=${authUser?.uid} anonymous=${authUser?.isAnonymous} '
        'providers=${DataSyncService.providerIdsForUser(authUser)} '
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
      _ownedBabyIdsWithMembers
        ..clear()
        ..addAll(remote.ownedBabyIdsWithMembers);

      await _saveBabies();
      if (didDedupeBabies) {
        _log('Sync dedupe detected. Rewriting baby docs for uid=$uid.');
      }
      // Always sync babies to cloud to ensure the top-level babies/{babyId}
      // mirror docs exist. This is required by sendInvitation / acceptInvitation
      // which read babies/{babyId} directly. The write is idempotent — skipped
      // if the data fingerprint hasn't changed within the last 2 seconds.
      await _syncBabiesToCloud();
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

  /// Reads users/{uid}/sharedBabies, resolves each baby document from the
  /// top-level babies/{babyId} collection, and merges them into _babies.
  /// Own babies are never replaced. Safe to call every startup — skipped for
  /// anonymous/signed-out users and when no sharedBabies entries exist.
  static Future<void> _loadSharedBabiesFromCloud() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    final user = _currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final sharedSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sharedBabies')
          .get();

      if (sharedSnap.docs.isEmpty) return;

      for (final indexDoc in sharedSnap.docs) {
        final babyId = (indexDoc.data()['babyId'] as String?) ?? indexDoc.id;
        if (babyId.isEmpty) continue;

        // Skip if already present as an owned baby.
        final alreadyOwned = _babies.any(
          (b) => b.id == babyId && !_sharedBabyIds.contains(b.id),
        );
        if (alreadyOwned) continue;

        try {
          final babyDoc = await FirebaseFirestore.instance
              .collection('babies')
              .doc(babyId)
              .get();

          if (!babyDoc.exists) continue;
          final d = babyDoc.data()!;

          final baby = Baby(
            id: babyId,
            name: (d['name'] as String?) ?? 'Baby',
            birthDate: _parseBabyDate(d['birthDate']),
            photoStoragePath: d['photoStoragePath'] as String?,
            photoUrl: d['photoUrl'] as String?,
          );

          _sharedBabyIds.add(babyId);
          // Insert or update in _babies without evicting owned babies.
          final existingIdx = _babies.indexWhere((b) => b.id == babyId);
          if (existingIdx >= 0) {
            _babies[existingIdx] = baby;
          } else {
            _babies.add(baby);
          }
        } catch (e) {
          _log('_loadSharedBabiesFromCloud: skip babyId=$babyId error=$e');
        }
      }

      _log(
        '_loadSharedBabiesFromCloud: merged ${_sharedBabyIds.length} '
        'shared babies, total=${_babies.length}',
      );
    } catch (e) {
      _log('_loadSharedBabiesFromCloud failed: $e');
    }
  }

  // ── Shared-baby real-time listeners ──────────────────────────────────────

  /// Cancels all active shared-record listeners and clears the map.
  static void _stopSharedRecordListeners() {
    for (final timer in _sharedRefreshDebounceByBabyId.values) {
      timer.cancel();
    }
    _sharedRefreshDebounceByBabyId.clear();
    for (final sub in _sharedListeners.values) {
      sub.cancel();
    }
    _sharedListeners.clear();
    _log('_stopSharedRecordListeners: all listeners cancelled');
  }

  static void _scheduleSharedBabyRefresh(
    String babyId, {
    required String reason,
  }) {
    final existing = _sharedRefreshDebounceByBabyId.remove(babyId);
    existing?.cancel();
    _sharedRefreshDebounceByBabyId[babyId] = Timer(
      const Duration(milliseconds: 400),
      () async {
        _sharedRefreshDebounceByBabyId.remove(babyId);
        _log(
          '_sharedCollectionListener: applying scoped refresh '
          'babyId=$babyId reason=$reason',
        );
        try {
          await _refreshSharedBabyFromCloud(babyId);
        } catch (e, st) {
          _log('_refreshSharedBabyFromCloud failed babyId=$babyId: $e');
          if (kDebugMode) {
            _log('_refreshSharedBabyFromCloud stack: $st');
          }
          refreshForCurrentUser().ignore();
        }
      },
    );
  }

  static void _cacheSharedBabyTruth(String babyId, bool isShared) {
    if (babyId.isEmpty) return;
    _sharedBabyTruthCacheByBabyId[babyId] = _SharedBabyTruthCacheEntry(
      isShared: isShared,
      checkedAt: DateTime.now(),
    );
  }

  static void _invalidateSharedBabyTruth(String babyId) {
    if (babyId.isEmpty) return;
    _sharedBabyTruthCacheByBabyId.remove(babyId);
  }

  static _SharedBabyTruthCacheEntry? _sharedBabyTruthCacheEntryFor(
    String babyId,
  ) {
    final entry = _sharedBabyTruthCacheByBabyId[babyId];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.checkedAt) <=
        _sharedBabyTruthCacheTtl) {
      return entry;
    }
    _sharedBabyTruthCacheByBabyId.remove(babyId);
    return null;
  }

  static Future<bool> _isSharedBabyUsingCloudTruth(String babyId) async {
    if (babyId.isEmpty) return false;
    if (isBabyVisiblyShared(babyId)) {
      _cacheSharedBabyTruth(babyId, true);
      return true;
    }

    final cached = _sharedBabyTruthCacheEntryFor(babyId);
    if (cached != null) return cached.isShared;

    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return false;
    final user = _currentUser;
    if (user == null || user.isAnonymous) return false;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('babies')
          .doc(babyId)
          .get();
      if (!snap.exists) {
        _cacheSharedBabyTruth(babyId, false);
        return false;
      }

      final data = snap.data() ?? const <String, dynamic>{};
      final ownerId = (data['ownerId'] ?? '').toString().trim();
      final members = data['members'];
      final hasCoParentMembers = members is Map && members.isNotEmpty;
      final isSharedMember = ownerId.isNotEmpty && ownerId != uid;
      final isOwnerOfSharedBaby = ownerId == uid && hasCoParentMembers;
      final isShared = isSharedMember || isOwnerOfSharedBaby;
      if (isSharedMember) {
        _sharedBabyIds.add(babyId);
      }
      if (isOwnerOfSharedBaby) {
        _ownedBabyIdsWithMembers.add(babyId);
      } else {
        _ownedBabyIdsWithMembers.remove(babyId);
      }
      if (!isSharedMember) {
        _sharedBabyIds.remove(babyId);
      }
      _cacheSharedBabyTruth(babyId, isShared);
      return isShared;
    } catch (e, st) {
      _log('_isSharedBabyUsingCloudTruth failed babyId=$babyId: $e');
      if (kDebugMode) {
        _log('_isSharedBabyUsingCloudTruth stack: $st');
      }
      return false;
    }
  }

  static Set<String> _activeIdsFromRows(Iterable<Map<String, dynamic>> rows) {
    return rows
        .where((row) => !_rowIsDeleted(row))
        .map((row) => (row['id'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static Future<void> _notifySharedActivityIfNeeded({
    required String babyId,
    required String activityType,
    required bool createdNewRecord,
  }) async {
    if (!createdNewRecord || babyId.isEmpty) return;
    if (!await _isSharedBabyUsingCloudTruth(babyId)) return;

    final babyName = _babies
        .firstWhere(
          (baby) => baby.id == babyId,
          orElse: () =>
              Baby(id: babyId, name: 'Baby', birthDate: DateTime.now()),
        )
        .name;

    try {
      await FirebaseFunctions.instance
          .httpsCallable('notifySharedActivity')
          .call<Map<String, dynamic>>({
            'babyId': babyId,
            'activityType': activityType,
            'babyName': babyName,
          });
    } catch (e, st) {
      _log(
        '_notifySharedActivityIfNeeded failed '
        'babyId=$babyId activityType=$activityType error=$e',
      );
      if (kDebugMode) {
        _log('_notifySharedActivityIfNeeded stack: $st');
      }
    }
  }

  static void _scheduleSharedActivityNotificationIfNeeded({
    required String babyId,
    required String activityType,
    required bool createdNewRecord,
  }) {
    _scheduleBestEffortCloudWrite(
      () => _notifySharedActivityIfNeeded(
        babyId: babyId,
        activityType: activityType,
        createdNewRecord: createdNewRecord,
      ),
      label: '$activityType notification',
    );
  }

  static Future<void> _syncSharedCriticalOrBestEffort({
    required String babyId,
    required String label,
    required Future<void> Function() sync,
    bool? isSharedBaby,
    Future<void> Function(Object error, StackTrace st)? onSharedSyncFailure,
    Duration timeout = _bestEffortWriteTimeout,
  }) async {
    final shared = isSharedBaby ?? await _isSharedBabyUsingCloudTruth(babyId);
    if (shared) {
      try {
        await sync();
      } catch (e, st) {
        _log('Shared sync failed label=$label babyId=$babyId error=$e');
        if (kDebugMode) {
          _log('Shared sync stack label=$label babyId=$babyId: $st');
        }
        if (onSharedSyncFailure != null) {
          await onSharedSyncFailure(e, st);
        }
        rethrow;
      }
      return;
    }
    _scheduleBestEffortCloudWrite(sync, label: label, timeout: timeout);
  }

  static Object? _canonicalRowValue(dynamic value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Timestamp) return value.toDate().toUtc().toIso8601String();
    if (value is Duration) return value.inMicroseconds;
    if (value is List) {
      return value.map(_canonicalRowValue).toList(growable: false);
    }
    if (value is Map) {
      final out = <String, Object?>{};
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      for (final key in keys) {
        out[key] = _canonicalRowValue(value[key]);
      }
      return out;
    }
    return value;
  }

  static String _rowComparableSignature(Map<String, dynamic> row) {
    final comparable = Map<String, dynamic>.from(row)
      ..remove('updatedAt')
      ..remove('localUpdatedAt')
      ..remove('deletedAt')
      ..remove('createdAt');
    return jsonEncode(_canonicalRowValue(comparable));
  }

  static String _rowsFingerprint(List<Map<String, dynamic>> rows) {
    final normalized = rows.map((row) {
      final map = Map<String, dynamic>.from(row)
        ..remove('updatedAt')
        ..remove('localUpdatedAt')
        ..remove('createdAt');
      return _canonicalRowValue(map);
    }).toList()..sort((a, b) => jsonEncode(a).compareTo(jsonEncode(b)));
    return jsonEncode(normalized);
  }

  static bool _replaceRowsForBaby(
    List<Map<String, dynamic>> target,
    String babyId,
    List<Map<String, dynamic>> incoming,
  ) {
    final before = target
        .where((row) => row['babyId'] == babyId)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    final beforeFingerprint = _rowsFingerprint(before);
    final incomingCopies = incoming
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
    final afterFingerprint = _rowsFingerprint(incomingCopies);
    final changed = beforeFingerprint != afterFingerprint;
    if (!changed) return false;
    target.removeWhere((row) => row['babyId'] == babyId);
    target.addAll(incomingCopies);
    return true;
  }

  static Map<String, dynamic> _recordDocRowForCloud(Map<String, dynamic> row) {
    final doc = Map<String, dynamic>.from(row);
    final explicitType = (doc['type'] ?? '').toString().trim().toLowerCase();
    if (doc.containsKey('baslangic') || doc.containsKey('bitis')) {
      doc['type'] = 'sleep';
      doc['startAt'] = doc['baslangic'];
      doc['endAt'] = doc['bitis'];
      doc['durationMinutes'] = (doc['sure'] as Duration).inMinutes;
      return doc;
    }
    if (explicitType == 'vaccine' ||
        doc.containsKey('donem') ||
        doc.containsKey('durum')) {
      doc['type'] = 'vaccine';
      doc['date'] = doc['tarih'];
      return doc;
    }
    if (doc.containsKey('diaperType') || doc.containsKey('notlar')) {
      doc['type'] = 'diaper';
      doc['date'] = doc['tarih'];
      return doc;
    }
    doc['type'] = _isNursingMamaRow(doc) ? 'nursing' : 'feeding';
    doc['date'] = doc['tarih'];
    return doc;
  }

  static String _recordActivityTypeForLogs(Map<String, dynamic> row) {
    final explicit = (row['type'] ?? '').toString().trim().toLowerCase();
    if (explicit.isNotEmpty) return explicit;
    if (row.containsKey('baslangic') || row.containsKey('bitis')) {
      return 'sleep';
    }
    if (row.containsKey('donem') || row.containsKey('durum')) {
      return 'vaccine';
    }
    if (row.containsKey('diaperType') || row.containsKey('notlar')) {
      return 'diaper';
    }
    return _isNursingMamaRow(row) ? 'nursing' : 'feeding';
  }

  static Future<void> _syncScopedRecordRowsToCloud({
    required String babyId,
    required List<Map<String, dynamic>> rows,
    required bool shared,
  }) async {
    if (rows.isEmpty) return;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncScopedRecordRowsToCloud',
      skipMessage: '[Sync] skip scoped record write: user is anonymous',
    )) {
      return;
    }

    String ownerId = '';
    if (kDebugMode) {
      try {
        final babySnap = await FirebaseFirestore.instance
            .collection('babies')
            .doc(babyId)
            .get();
        ownerId = (babySnap.data()?['ownerId'] ?? '').toString().trim();
      } catch (e) {
        _log(
          'scoped record write owner lookup failed babyId=$babyId uid=$uid '
          'error=$e',
        );
      }
    }

    for (final row in rows) {
      final doc = _recordDocRowForCloud(row);
      final recordId = (doc['id'] ?? '').toString();
      if (recordId.isEmpty) continue;
      final activityType = _recordActivityTypeForLogs(doc);
      final path = _sharedRecordPath(babyId, recordId);
      final createdBy = (doc['createdBy'] ?? '').toString().trim();
      final stopwatch = Stopwatch()..start();
      if (kDebugMode) {
        _log(
          'scoped record write start babyId=$babyId uid=$uid '
          'isSharedBaby=$shared ownerId=$ownerId createdBy=$createdBy '
          'activityType=$activityType recordId=$recordId path=$path '
          'isDeleted=${doc['isDeleted'] == true}',
        );
      }
      try {
        await _firestoreStore.upsertRecordForBaby(
          uid,
          babyId: babyId,
          record: doc,
        );
        if (kDebugMode) {
          _log(
            'scoped record write success babyId=$babyId uid=$uid '
            'isSharedBaby=$shared ownerId=$ownerId createdBy=$createdBy '
            'activityType=$activityType recordId=$recordId path=$path '
            'elapsedMs=${stopwatch.elapsedMilliseconds}',
          );
        }
      } catch (e, st) {
        final code = e is FirebaseException ? e.code : 'unknown';
        final message = e is FirebaseException
            ? e.message ?? e.toString()
            : e.toString();
        if (kDebugMode) {
          _log(
            'scoped record write failed babyId=$babyId uid=$uid '
            'isSharedBaby=$shared ownerId=$ownerId createdBy=$createdBy '
            'activityType=$activityType recordId=$recordId path=$path '
            'elapsedMs=${stopwatch.elapsedMilliseconds} '
            'firestoreCode=$code firestoreMessage=$message',
          );
          _log('scoped record write stack path=$path: $st');
        }
        rethrow;
      } finally {
        stopwatch.stop();
      }
    }
  }

  static Future<void> ensureBabySharedCloudSync(String babyId) async {
    if (babyId.isEmpty) return;
    await _repairMissingIdsAndPersistIfNeeded();
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: 'ensureBabySharedCloudSync',
      skipMessage: '[Sync] skip shared baby flush: user is anonymous',
    )) {
      return;
    }

    try {
      await _syncBabiesToCloud();
      await _syncActiveBabyRecordsToCloud(babyId: babyId);
      await _syncActiveBabyMemoriesToCloud(babyId: babyId);
      await _syncActiveBabyMedicationsToCloud(babyId: babyId);
      await _syncActiveBabyMedicationLogsToCloud(babyId: babyId);
      _log('ensureBabySharedCloudSync completed babyId=$babyId uid=$uid');
    } catch (e, st) {
      _log('ensureBabySharedCloudSync failed babyId=$babyId uid=$uid: $e');
      if (kDebugMode) {
        _log('ensureBabySharedCloudSync stack: $st');
      }
      rethrow;
    }
  }

  static Future<void> _pruneBabyLocally(
    String babyId, {
    required String reason,
    bool notify = true,
  }) async {
    final listenerKeys = _sharedListeners.keys
        .where((key) => key.startsWith('$babyId:'))
        .toList(growable: false);
    for (final key in listenerKeys) {
      final sub = _sharedListeners.remove(key);
      if (sub != null) {
        await sub.cancel();
      }
    }
    _sharedRefreshDebounceByBabyId.remove(babyId)?.cancel();
    final removed = <String, int>{};
    _babies.removeWhere((baby) => baby.id == babyId);
    removed['mama'] = _removeRowsForBaby(_mamaKayitlari, babyId);
    removed['kaka'] = _removeRowsForBaby(_kakaKayitlari, babyId);
    removed['uyku'] = _removeRowsForBaby(_uykuKayitlari, babyId);
    removed['anilar'] = _removeRowsForBaby(_anilar, babyId);
    removed['boykilo'] = _removeRowsForBaby(_boyKiloKayitlari, babyId);
    removed['milestones'] = _removeRowsForBaby(_milestones, babyId);
    removed['asi'] = _removeRowsForBaby(_asiKayitlari, babyId);
    removed['ilac'] = _removeRowsForBaby(_ilacKayitlari, babyId);
    removed['ilac_doz'] = _removeRowsForBaby(_ilacDozKayitlari, babyId);
    _sharedBabyIds.remove(babyId);
    _ownedBabyIdsWithMembers.remove(babyId);
    _invalidateSharedBabyTruth(babyId);
    if (_activeBabyId == babyId) {
      _activeBabyId = _babies.isNotEmpty ? _babies.first.id : '';
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    _syncCachedActiveBabyFields();
    await _saveBabies();
    await _saveAllCollections();
    _log('Pruned local babyId=$babyId reason=$reason removed=$removed');
    if (notify) {
      _notifyDataChanged(reason: 'prune:$reason');
    }
  }

  static Future<void> _pruneInaccessibleBabiesForCurrentUser() async {
    final uid = _currentUid;
    final user = _currentUser;
    if (uid == null || uid.isEmpty || user == null || user.isAnonymous) return;

    final ownedSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('babies')
        .get();
    final sharedSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sharedBabies')
        .get();

    final allowedIds = <String>{
      ...ownedSnap.docs.map((doc) => doc.id),
      ...sharedSnap.docs.map(
        (doc) => (doc.data()['babyId'] as String?) ?? doc.id,
      ),
    }..removeWhere((id) => id.trim().isEmpty);

    final staleLocalIds = _babies
        .map((baby) => baby.id)
        .where((babyId) => !allowedIds.contains(babyId))
        .toList();
    if (staleLocalIds.isEmpty) return;

    var prunedAny = false;
    for (final babyId in staleLocalIds) {
      try {
        final topLevelSnap = await FirebaseFirestore.instance
            .collection('babies')
            .doc(babyId)
            .get();
        final ownerId = (topLevelSnap.data()?['ownerId'] ?? '')
            .toString()
            .trim();
        final shouldKeepOwnedBaby = ownerId.isNotEmpty && ownerId == uid;
        if (shouldKeepOwnedBaby) continue;
      } catch (_) {
        // If the caller cannot read the baby anymore, treat it as stale.
      }
      await _pruneBabyLocally(
        babyId,
        reason: 'membership-refresh',
        notify: false,
      );
      prunedAny = true;
    }

    if (prunedAny) {
      _notifyDataChanged(reason: 'membership-refresh');
    }
  }

  static DateTime _sharedDocDateTime(dynamic value, {DateTime? fallback}) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    }
    return fallback ?? DateTime.now();
  }

  static DateTime? _sharedDocOptionalDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static bool _applySharedRecordDocs(
    String babyId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final mama = <Map<String, dynamic>>[];
    final kaka = <Map<String, dynamic>>[];
    final uyku = <Map<String, dynamic>>[];
    final boyKilo = <Map<String, dynamic>>[];
    final asilar = <Map<String, dynamic>>[];
    final milestones = <Map<String, dynamic>>[];
    final anilar = <Map<String, dynamic>>[];

    for (final doc in docs) {
      final row = doc.data();
      final type = (row['type'] ?? '').toString();
      final id = (row['id'] ?? doc.id).toString();
      final updatedAt = _sharedDocDateTime(
        row['updatedAt'] ?? row['createdAt'],
      );
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});
      final isDeleted = data['isDeleted'] == true || row['isDeleted'] == true;
      final deletedAt = _sharedDocOptionalDateTime(
        data['deletedAt'] ?? row['deletedAt'],
      );

      if (type == 'feeding' || type == 'nursing') {
        mama.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tur':
              data['tur'] ?? (type == 'nursing' ? 'anne' : data['tur'] ?? ''),
          'tarih': _sharedDocDateTime(
            data['tarih'] ?? data['date'] ?? updatedAt,
          ),
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      } else if (type == 'diaper') {
        kaka.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': _sharedDocDateTime(
            data['tarih'] ?? data['date'] ?? updatedAt,
          ),
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      } else if (type == 'sleep') {
        final start = _sharedDocDateTime(data['baslangic'] ?? data['startAt']);
        final end = _sharedDocDateTime(
          data['bitis'] ?? data['endAt'] ?? updatedAt,
        );
        uyku.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'baslangic': start,
          'bitis': end,
          'sure': Duration(
            minutes:
                (data['durationMinutes'] as num?)?.toInt() ??
                end.difference(start).inMinutes,
          ),
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      } else if (type == 'growth') {
        boyKilo.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': _sharedDocDateTime(
            data['tarih'] ?? data['date'] ?? updatedAt,
          ),
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      } else if (type == 'vaccine') {
        asilar.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': data['tarih'] != null
              ? _sharedDocDateTime(data['tarih'])
              : null,
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      } else if (type == 'milestone') {
        milestones.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'date': _sharedDocDateTime(
            data['date'] ?? data['tarih'] ?? updatedAt,
          ),
          'photoPath': data['photoLocalPath'] ?? data['photoPath'],
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      } else if (type == 'memory') {
        anilar.add({
          ...data,
          'id': id,
          'babyId': babyId,
          'tarih': _sharedDocDateTime(
            data['tarih'] ?? data['date'] ?? updatedAt,
          ),
          'baslik': data['baslik'] ?? data['title'],
          'not': data['not'] ?? data['note'],
          'photoPath': data['photoLocalPath'] ?? data['photoPath'],
          'updatedAt': updatedAt,
          'localUpdatedAt': updatedAt,
          'isDeleted': isDeleted,
          'deletedAt': deletedAt,
        });
      }
    }

    final changed =
        _replaceRowsForBaby(_mamaKayitlari, babyId, mama) |
        _replaceRowsForBaby(_kakaKayitlari, babyId, kaka) |
        _replaceRowsForBaby(_uykuKayitlari, babyId, uyku) |
        _replaceRowsForBaby(_boyKiloKayitlari, babyId, boyKilo) |
        _replaceRowsForBaby(_asiKayitlari, babyId, asilar) |
        _replaceRowsForBaby(_milestones, babyId, milestones) |
        _replaceRowsForBaby(_anilar, babyId, anilar);
    if (kDebugMode) {
      _log(
        '_applySharedRecordDocs babyId=$babyId docs=${docs.length} '
        'changed=$changed feeding=${mama.length} diaper=${kaka.length} '
        'sleep=${uyku.length} growth=${boyKilo.length} vaccine=${asilar.length} '
        'milestone=${milestones.length} memory=${anilar.length}',
      );
    }
    return changed;
  }

  static bool _applySharedMedicationDocs(
    String babyId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final meds = docs.map((doc) {
      final row = doc.data();
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});
      final updatedAt = _sharedDocDateTime(
        row['updatedAt'] ?? row['createdAt'],
      );
      return <String, dynamic>{
        ...data,
        'id': (row['id'] ?? doc.id).toString(),
        'babyId': babyId,
        'createdAt': _sharedDocDateTime(row['createdAt'], fallback: updatedAt),
        'updatedAt': updatedAt,
        'localUpdatedAt': updatedAt,
        'isDeleted': data['isDeleted'] == true || row['isDeleted'] == true,
        'deletedAt': _sharedDocOptionalDateTime(
          data['deletedAt'] ?? row['deletedAt'],
        ),
      };
    }).toList();
    final changed = _replaceRowsForBaby(_ilacKayitlari, babyId, meds);
    if (kDebugMode) {
      _log(
        '_applySharedMedicationDocs babyId=$babyId docs=${docs.length} '
        'changed=$changed rows=${meds.length}',
      );
    }
    return changed;
  }

  static bool _applySharedMedicationLogDocs(
    String babyId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final logs = docs.map((doc) {
      final row = doc.data();
      final data = Map<String, dynamic>.from((row['data'] as Map?) ?? {});
      final updatedAt = _sharedDocDateTime(
        row['updatedAt'] ?? row['createdAt'],
      );
      return <String, dynamic>{
        ...data,
        'id': (row['id'] ?? doc.id).toString(),
        'babyId': babyId,
        'medicationId': row['medicationId'] ?? data['medicationId'],
        'givenAt': _sharedDocDateTime(
          data['givenAt'] ?? row['createdAt'] ?? updatedAt,
        ),
        'updatedAt': updatedAt,
        'localUpdatedAt': updatedAt,
        'isDeleted': data['isDeleted'] == true || row['isDeleted'] == true,
        'deletedAt': _sharedDocOptionalDateTime(
          data['deletedAt'] ?? row['deletedAt'],
        ),
      };
    }).toList();
    final changed = _replaceRowsForBaby(_ilacDozKayitlari, babyId, logs);
    if (kDebugMode) {
      _log(
        '_applySharedMedicationLogDocs babyId=$babyId docs=${docs.length} '
        'changed=$changed rows=${logs.length}',
      );
    }
    return changed;
  }

  static Future<void> _refreshSharedBabyFromCloud(String babyId) async {
    final uid = _currentUid;
    final user = _currentUser;
    if (uid == null || uid.isEmpty || user == null || user.isAnonymous) return;
    final stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      _log(
        'shared refresh start uid=$uid babyId=$babyId '
        'metadataPath=babies/$babyId recordsPath=${_sharedCollectionPath(babyId, 'records')} '
        'medicationsPath=${_sharedCollectionPath(babyId, 'medications')} '
        'medicationLogsPath=${_sharedCollectionPath(babyId, 'medicationLogs')}',
      );
    }

    try {
      final babySnap = await FirebaseFirestore.instance
          .collection('babies')
          .doc(babyId)
          .get();
      if (!babySnap.exists) {
        await _pruneBabyLocally(babyId, reason: 'remote-baby-missing');
        return;
      }

      final data = babySnap.data() ?? const <String, dynamic>{};
      final ownerId = (data['ownerId'] ?? '').toString().trim();
      final members = data['members'];
      final hasMemberAccess = members is Map && members[uid] != null;
      final isOwner = ownerId == uid;
      if (!isOwner && !hasMemberAccess) {
        await _pruneBabyLocally(babyId, reason: 'remote-access-revoked');
        return;
      }

      final hasCoParentMembers = members is Map && members.isNotEmpty;
      if (isOwner && hasCoParentMembers) {
        _ownedBabyIdsWithMembers.add(babyId);
        _sharedBabyIds.remove(babyId);
      } else if (!isOwner) {
        _sharedBabyIds.add(babyId);
        _ownedBabyIdsWithMembers.remove(babyId);
      } else {
        _sharedBabyIds.remove(babyId);
        _ownedBabyIdsWithMembers.remove(babyId);
      }

      final baby = Baby(
        id: babyId,
        name: (data['name'] as String?) ?? 'Baby',
        birthDate: _parseBabyDate(data['birthDate']),
        photoStoragePath: data['photoStoragePath'] as String?,
        photoUrl: data['photoUrl'] as String?,
      );
      final existingIdx = _babies.indexWhere((b) => b.id == babyId);
      if (existingIdx >= 0) {
        _babies[existingIdx] = baby;
      } else {
        _babies.add(baby);
      }

      final recordsSnap = await FirebaseFirestore.instance
          .collection('babies')
          .doc(babyId)
          .collection('records')
          .orderBy('createdAt', descending: true)
          .get();
      final medsSnap = await FirebaseFirestore.instance
          .collection('babies')
          .doc(babyId)
          .collection('medications')
          .orderBy('createdAt', descending: true)
          .get();
      final medLogsSnap = await FirebaseFirestore.instance
          .collection('babies')
          .doc(babyId)
          .collection('medicationLogs')
          .orderBy('createdAt', descending: true)
          .get();

      final recordsChanged = _applySharedRecordDocs(babyId, recordsSnap.docs);
      final medsChanged = _applySharedMedicationDocs(babyId, medsSnap.docs);
      final logsChanged = _applySharedMedicationLogDocs(
        babyId,
        medLogsSnap.docs,
      );
      await _saveBabies();
      await _saveAllCollections();
      _syncCachedActiveBabyFields();
      _notifyDataChanged(reason: 'scoped-shared-refresh');
      if (kDebugMode) {
        _log(
          'shared refresh success uid=$uid babyId=$babyId ownerId=$ownerId '
          'recordsPath=${_sharedCollectionPath(babyId, 'records')} records=${recordsSnap.docs.length} '
          'medications=${medsSnap.docs.length} medicationLogs=${medLogsSnap.docs.length} '
          'recordsChanged=$recordsChanged medsChanged=$medsChanged logsChanged=$logsChanged '
          'elapsedMs=${stopwatch.elapsedMilliseconds}',
        );
      }
    } catch (e, st) {
      final code = e is FirebaseException ? e.code : 'unknown';
      final message = e is FirebaseException
          ? (e.message ?? e.toString())
          : e.toString();
      if (kDebugMode) {
        _log(
          'shared refresh failed uid=$uid babyId=$babyId '
          'elapsedMs=${stopwatch.elapsedMilliseconds} firestoreCode=$code '
          'firestoreMessage=$message',
        );
        _log('shared refresh stack babyId=$babyId: $st');
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  static void _syncCachedActiveBabyFields() {
    if (_babies.isNotEmpty && _babies.any((b) => b.id == _activeBabyId)) {
      final active = getActiveBaby();
      _babyName = active.name;
      _birthDate = active.birthDate;
      _babyPhotoPath = active.photoPath;
      return;
    }
    _babyName = 'Baby';
    _birthDate = DateTime.now().subtract(const Duration(days: 30));
    _babyPhotoPath = null;
  }

  static Future<void> _applySharedCollectionSnapshot(
    String babyId, {
    required String collection,
    required QuerySnapshot<Map<String, dynamic>> snap,
  }) async {
    final changedDocIds = snap.docChanges
        .map((change) => change.doc.id)
        .toList(growable: false);
    final changeTypes = snap.docChanges
        .map((change) => change.type.name)
        .toList(growable: false);
    if (kDebugMode) {
      _log(
        'shared listener snapshot babyId=$babyId '
        'collectionPath=${_sharedCollectionPath(babyId, collection)} '
        'docCount=${snap.docs.length} changedDocIds=$changedDocIds '
        'changeTypes=$changeTypes',
      );
    }

    final isOwnerSharedBaby =
        _ownedBabyIdsWithMembers.contains(babyId) &&
        !_sharedBabyIds.contains(babyId);
    final hasLocalRowsForCollection = switch (collection) {
      'records' =>
        _mamaKayitlari.any((row) => row['babyId'] == babyId) ||
            _kakaKayitlari.any((row) => row['babyId'] == babyId) ||
            _uykuKayitlari.any((row) => row['babyId'] == babyId) ||
            _boyKiloKayitlari.any((row) => row['babyId'] == babyId) ||
            _asiKayitlari.any((row) => row['babyId'] == babyId) ||
            _milestones.any((row) => row['babyId'] == babyId) ||
            _anilar.any((row) => row['babyId'] == babyId),
      'medications' => _ilacKayitlari.any((row) => row['babyId'] == babyId),
      'medicationLogs' => _ilacDozKayitlari.any(
        (row) => row['babyId'] == babyId,
      ),
      _ => false,
    };
    if (snap.docs.isEmpty && isOwnerSharedBaby && hasLocalRowsForCollection) {
      if (kDebugMode) {
        _log(
          'shared listener snapshot skipped local wipe babyId=$babyId '
          'collection=$collection reason=owner-local-data-awaiting-cloud-sync',
        );
      }
      _scheduleBestEffortCloudWrite(
        () => ensureBabySharedCloudSync(babyId),
        label: 'shared listener heal:$babyId:$collection',
        timeout: const Duration(seconds: 20),
      );
      return;
    }

    bool changed = false;
    switch (collection) {
      case 'records':
        changed = _applySharedRecordDocs(babyId, snap.docs);
        break;
      case 'medications':
        changed = _applySharedMedicationDocs(babyId, snap.docs);
        break;
      case 'medicationLogs':
        changed = _applySharedMedicationLogDocs(babyId, snap.docs);
        break;
      default:
        return;
    }

    if (!changed) {
      if (kDebugMode) {
        _log(
          'shared listener apply skipped notify babyId=$babyId '
          'collection=$collection changed=false',
        );
      }
      return;
    }

    await _saveAllCollections();
    _syncCachedActiveBabyFields();
    _notifyDataChanged(reason: 'shared-listener:$collection');
    if (kDebugMode) {
      _log(
        'shared listener apply updated local state babyId=$babyId '
        'collection=$collection dataNotifierFired=true',
      );
    }
  }

  static void _startSharedRecordListeners() {
    _stopSharedRecordListeners();
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    final user = _currentUser;
    if (user == null || user.isAnonymous) return;

    final metadataBabyIds = _babies.map((baby) => baby.id).toSet();
    final sharedBabyIds = _babies
        .where((baby) => isBabyVisiblyShared(baby.id))
        .map((baby) => baby.id)
        .toSet();
    if (metadataBabyIds.isEmpty) return;

    _log(
      '_startSharedRecordListeners: metadata=${metadataBabyIds.length} '
      'sharedCollections=${sharedBabyIds.length}',
    );

    for (final babyId in metadataBabyIds) {
      final babyListenerKey = '$babyId:metadata';
      final babySub = FirebaseFirestore.instance
          .collection('babies')
          .doc(babyId)
          .snapshots()
          .listen(
            (snap) {
              _log(
                '_sharedBabyListener: metadata change detected '
                'babyId=$babyId exists=${snap.exists}',
              );
              _invalidateSharedBabyTruth(babyId);
              final wasVisiblyShared = isBabyVisiblyShared(babyId);
              final wasOwnedWithMembers = _ownedBabyIdsWithMembers.contains(
                babyId,
              );
              if (!snap.exists) {
                _sharedBabyIds.remove(babyId);
                _ownedBabyIdsWithMembers.remove(babyId);
                _pruneBabyLocally(
                  babyId,
                  reason: 'metadata-listener-missing',
                ).ignore();
                return;
              } else {
                final data = snap.data();
                final ownerId = (data?['ownerId'] ?? '').toString().trim();
                final members = data?['members'];
                final hasCoParentMembers = members is Map && members.isNotEmpty;
                final hasMemberAccess = members is Map && members[uid] != null;
                if (ownerId.isNotEmpty && ownerId != uid) {
                  _sharedBabyIds.add(babyId);
                } else {
                  _sharedBabyIds.remove(babyId);
                }
                if (ownerId == uid && hasCoParentMembers) {
                  _ownedBabyIdsWithMembers.add(babyId);
                } else {
                  _ownedBabyIdsWithMembers.remove(babyId);
                }
                final becameOwnerOfSharedBaby =
                    !wasOwnedWithMembers &&
                    ownerId == uid &&
                    hasCoParentMembers;
                final accessRevoked = ownerId != uid && !hasMemberAccess;
                if (becameOwnerOfSharedBaby) {
                  _scheduleBestEffortCloudWrite(
                    () => ensureBabySharedCloudSync(babyId),
                    label: 'shared baby activation sync:$babyId',
                    timeout: const Duration(seconds: 20),
                  );
                }
                if (accessRevoked) {
                  _pruneBabyLocally(
                    babyId,
                    reason: 'metadata-listener-access-revoked',
                  ).ignore();
                  return;
                }
              }
              final isNowVisiblyShared = isBabyVisiblyShared(babyId);
              if (wasVisiblyShared != isNowVisiblyShared) {
                _log(
                  '_sharedBabyListener: visibility changed babyId=$babyId '
                  'before=$wasVisiblyShared after=$isNowVisiblyShared '
                  'restarting listeners',
                );
                Future<void>.microtask(_startSharedRecordListeners);
              }
              if (!isNowVisiblyShared) {
                return;
              }
              _scheduleSharedBabyRefresh(babyId, reason: 'metadata');
            },
            onError: (Object e) =>
                _log('_sharedBabyListener error babyId=$babyId: $e'),
          );
      _sharedListeners[babyListenerKey] = babySub;
      if (kDebugMode) {
        _log(
          'shared listener start babyId=$babyId collectionPath=babies/$babyId '
          'kind=metadata',
        );
      }
    }

    for (final babyId in sharedBabyIds) {
      const collections = <String>[
        'records',
        'medications',
        'medicationLogs',
        'allergies',
      ];
      for (final collection in collections) {
        final listenerKey = '$babyId:$collection';
        final sub = FirebaseFirestore.instance
            .collection('babies')
            .doc(babyId)
            .collection(collection)
            .snapshots()
            .listen(
              (snap) async {
                if (collection == 'allergies') {
                  if (snap.docChanges.isEmpty) return;
                  _log(
                    '_sharedCollectionListener: remote change detected '
                    'babyId=$babyId collection=$collection changes=${snap.docChanges.length}',
                  );
                  _scheduleSharedBabyRefresh(babyId, reason: collection);
                  return;
                }
                try {
                  await _applySharedCollectionSnapshot(
                    babyId,
                    collection: collection,
                    snap: snap,
                  );
                } catch (e, st) {
                  _log(
                    '_sharedCollectionListener apply failed babyId=$babyId '
                    'collection=$collection error=$e',
                  );
                  if (kDebugMode) {
                    _log(
                      '_sharedCollectionListener apply stack babyId=$babyId '
                      'collection=$collection: $st',
                    );
                  }
                  _scheduleSharedBabyRefresh(
                    babyId,
                    reason: '$collection-fallback',
                  );
                }
              },
              onError: (Object e) => _log(
                '_sharedCollectionListener error babyId=$babyId '
                'collection=$collection: $e',
              ),
            );
        _sharedListeners[listenerKey] = sub;
        if (kDebugMode) {
          _log(
            'shared listener start babyId=$babyId '
            'collectionPath=${_sharedCollectionPath(babyId, collection)} '
            'kind=$collection',
          );
        }
      }
    }
  }

  /// Parses a Firestore Timestamp or ISO-8601 string into a DateTime.
  static DateTime _parseBabyDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ??
          DateTime.now().subtract(const Duration(days: 30));
    }
    return DateTime.now().subtract(const Duration(days: 30));
  }

  static void _scheduleBestEffortCloudWrite(
    Future<void> Function() action, {
    required String label,
    Duration timeout = _bestEffortWriteTimeout,
  }) {
    if (!_canSyncWithCloud(
      operation: 'schedule:$label',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
    unawaited(() async {
      try {
        await action().timeout(timeout);
      } on TimeoutException catch (e, st) {
        _log('Best-effort $label timed out after ${timeout.inSeconds}s: $e');
        if (kDebugMode) {
          _log('Best-effort $label stack: $st');
        }
      } catch (e, st) {
        _log('Best-effort $label failed: $e');
        if (kDebugMode) {
          _log('Best-effort $label stack: $st');
        }
      }
    }());
  }

  static Future<void> _syncMemoryPhotosAfterSave() async {
    if (_canSyncWithCloud(
      operation: '_syncMemoryPhotosAfterSave',
      skipMessage:
          '[Sync] skip immediate photo storage sync: user is anonymous',
    )) {
      await _syncPhotosWithStorageBestEffort();
      return;
    }
    _scheduleBestEffortCloudWrite(
      _syncPhotosWithStorageBestEffort,
      label: 'photo storage sync',
      timeout: _bestEffortPhotoStorageTimeout,
    );
  }

  static Future<void> _syncPhotosWithStorageBestEffort() async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    final user = _currentUser;
    if (!_canSyncWithCloud(
      operation: '_syncPhotosWithStorageBestEffort',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      _log(
        'photo upload skip type=memory reason=anonymous uid=$uid memories=${_anilar.length}',
      );
      return;
    }
    _log('Starting photo storage sync uid=$uid anonymous=${user?.isAnonymous}');

    final result = await _photoStorageSyncService.syncUserPhotos(
      uid: uid,
      babies: _babies,
      milestones: _milestones,
      memories: _anilar,
      log: _log,
    );

    if (result.babiesChanged) {
      await _saveBabies();
      await _syncBabiesToCloud();
    }
    if (result.memoriesChanged) {
      await _persistAnilarToLocalStore();
      await _persistMilestonesToLocalStore();
    }
    if (result.memoriesUploaded && result.uploadedMemoryBabyIds.isNotEmpty) {
      for (final babyId in result.uploadedMemoryBabyIds) {
        await _syncBabyMemoriesToCloud(babyId: babyId);
      }
    }
    _log(
      'Photo storage sync finished '
      'babiesChanged=${result.babiesChanged} '
      'memoriesChanged=${result.memoriesChanged} '
      'uploadedMemoryBabies=${result.uploadedMemoryBabyIds.length}',
    );
  }

  static Future<void> _syncBabyMemoriesToCloud({required String babyId}) async {
    await _repairMissingIdsAndPersistIfNeeded();
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || babyId.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncBabyMemoriesToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
    final bundle = _currentCoreBundle();
    final docs = _memoryDocsForBundleBaby(bundle, babyId);
    await _firestoreStore.replaceMemoriesForBaby(
      uid,
      babyId: babyId,
      memories: docs,
    );
  }

  static Future<void> refreshForCurrentUser() async {
    _log('refreshForCurrentUser: start');
    await _pruneLocalCachesForAuthScopeIfNeeded();
    await _syncFromCloudIfSignedIn();
    _sharedBabyIds.clear();
    _ownedBabyIdsWithMembers.clear();
    await _loadSharedBabiesFromCloud();
    await _pruneInaccessibleBabiesForCurrentUser();
    // (Re)start real-time listeners so both owner and co-parent see each
    // other's writes without relying on notifications.
    _startSharedRecordListeners();
    _scheduleBestEffortCloudWrite(
      _syncPhotosWithStorageBestEffort,
      label: 'photo storage sync',
      timeout: _bestEffortPhotoStorageTimeout,
    );
    if (_babies.isNotEmpty && !_babies.any((b) => b.id == _activeBabyId)) {
      _activeBabyId = _babies.first.id;
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    if (_babies.isEmpty) {
      _activeBabyId = '';
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    _syncCachedActiveBabyFields();
    // Notify UI that fresh data is available. This bumps _dataVersion so all
    // ValueListenableBuilder widgets rebuild with the merged records.
    _notifyDataChanged(reason: 'remote-sync');
    _log('refreshForCurrentUser: done — UI notified');
  }

  static List<Map<String, dynamic>> _recordsForBundleBaby(
    RepositoryDataBundle bundle,
    String babyId,
  ) {
    final records = <Map<String, dynamic>>[];
    records.addAll(
      bundle.mamaKayitlari.where((r) => r['babyId'] == babyId).map((r) {
        final map = Map<String, dynamic>.from(r);
        map['type'] = _isNursingMamaRow(map) ? 'nursing' : 'feeding';
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
      final row = Map<String, dynamic>.from(m);
      final id = _ensureStableIdForRow(row, entity: 'milestone');
      byId[id] = {
        'id': id,
        'type': 'milestone',
        'babyId': babyId,
        'title': row['title'],
        'note': row['note'],
        'date': row['date'],
        'photoLocalPath': row['photoPath'],
        'photoStoragePath': row['photoStoragePath'],
        'photoUrl': row['photoUrl'],
        'photoStyle': row['photoStyle'] ?? 'softIllustration',
        'isDeleted': row['isDeleted'] == true,
        'deletedAt': row['deletedAt'],
      };
    }

    for (final a in bundle.anilar.where((e) => e['babyId'] == babyId)) {
      final row = Map<String, dynamic>.from(a);
      final id = _ensureStableIdForRow(row, entity: 'memory');
      byId[id] = {
        'id': id,
        'type': 'memory',
        'babyId': babyId,
        'title': row['baslik'],
        'note': row['not'],
        'date': row['tarih'],
        'emoji': row['emoji'],
        'photoLocalPath': row['photoPath'],
        'photoStoragePath': row['photoStoragePath'],
        'photoUrl': row['photoUrl'],
        'isDeleted': row['isDeleted'] == true,
        'deletedAt': row['deletedAt'],
      };
    }

    return byId.values.toList();
  }

  static Future<RepositoryDataBundle> exportUserDataSnapshot({
    String? uid,
  }) async {
    await _repairMissingIdsAndPersistIfNeeded();
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
    if (!_canSyncWithCloud(
      operation: 'exportUserDataSnapshot',
      skipMessage: '[Sync] skip cloud read: user is anonymous',
    )) {
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
    if (!_canSyncWithCloud(
      operation: 'clearFirestoreDataForUid',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
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
    if (!_canSyncWithCloud(
      operation: 'restoreDataBundleToUid',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
    try {
      await _pushBundleToCloudStrict(uid, bundle);
    } catch (_) {
      // Best-effort restore only.
    }
  }

  static Future<void> _pushBundleToCloudStrict(
    String uid,
    RepositoryDataBundle bundle,
  ) async {
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
  }

  static Future<void> _pushAllToCloud(String uid) async {
    await _repairMissingIdsAndPersistIfNeeded();
    if (!_canSyncWithCloud(
      operation: '_pushAllToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
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
    if (!_canSyncWithCloud(
      operation: '_syncBabiesToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
    try {
      await _withIdempotentCloudWrite('babies:$uid', _babies, () async {
        await _firestoreStore.replaceBabies(uid, _babies);
      });
    } catch (e, st) {
      _log('_syncBabiesToCloud failed uid=$uid: $e');
      if (kDebugMode) {
        _log('_syncBabiesToCloud stack: $st');
      }
    }
  }

  static Future<void> _syncActiveBabyRecordsToCloud({String? babyId}) async {
    await _repairMissingIdsAndPersistIfNeeded();
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncActiveBabyRecordsToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }

    try {
      final mama = _mamaKayitlari.where((r) => r['babyId'] == targetBabyId).map(
        (r) {
          final map = Map<String, dynamic>.from(r);
          map['type'] = _isNursingMamaRow(map) ? 'nursing' : 'feeding';
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
    } catch (e, st) {
      _log('_syncActiveBabyRecordsToCloud failed babyId=$targetBabyId: $e');
      if (kDebugMode) {
        _log('_syncActiveBabyRecordsToCloud stack: $st');
      }
      if (await _isSharedBabyUsingCloudTruth(targetBabyId)) rethrow;
    }
  }

  static List<Map<String, dynamic>> _memoryDocsForBaby(String babyId) {
    final Map<String, Map<String, dynamic>> byId = {};

    for (final m in _milestones.where((e) => e['babyId'] == babyId)) {
      final row = Map<String, dynamic>.from(m);
      final id = _ensureStableIdForRow(row, entity: 'milestone');
      byId[id] = {
        'id': id,
        'type': 'milestone',
        'babyId': babyId,
        'title': row['title'],
        'note': row['note'],
        'date': row['date'],
        'photoLocalPath': row['photoPath'],
        'photoStoragePath': row['photoStoragePath'],
        'photoUrl': row['photoUrl'],
        'photoStyle': row['photoStyle'] ?? 'softIllustration',
        'illustrationUrl': row['illustrationUrl'],
        'isDeleted': row['isDeleted'] == true,
        'deletedAt': row['deletedAt'],
      };
    }

    for (final a in _anilar.where((e) => e['babyId'] == babyId)) {
      final row = Map<String, dynamic>.from(a);
      final id = _ensureStableIdForRow(row, entity: 'memory');
      byId[id] = {
        'id': id,
        'type': 'memory',
        'babyId': babyId,
        'title': row['baslik'],
        'note': row['not'],
        'date': row['tarih'],
        'emoji': row['emoji'],
        'photoLocalPath': row['photoPath'],
        'photoStoragePath': row['photoStoragePath'],
        'photoUrl': row['photoUrl'],
        'isDeleted': row['isDeleted'] == true,
        'deletedAt': row['deletedAt'],
      };
    }

    return byId.values.toList();
  }

  static Future<void> _syncActiveBabyMemoriesToCloud({String? babyId}) async {
    await _repairMissingIdsAndPersistIfNeeded();
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncActiveBabyMemoriesToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
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
    } catch (e, st) {
      _log('_syncActiveBabyMemoriesToCloud failed babyId=$targetBabyId: $e');
      if (kDebugMode) {
        _log('_syncActiveBabyMemoriesToCloud stack: $st');
      }
      if (await _isSharedBabyUsingCloudTruth(targetBabyId)) rethrow;
    }
  }

  static Future<void> _syncActiveBabyMedicationsToCloud({
    String? babyId,
  }) async {
    await _repairMissingIdsAndPersistIfNeeded();
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncActiveBabyMedicationsToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
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
    } catch (e, st) {
      _log('_syncActiveBabyMedicationsToCloud failed babyId=$targetBabyId: $e');
      if (kDebugMode) {
        _log('_syncActiveBabyMedicationsToCloud stack: $st');
      }
      if (await _isSharedBabyUsingCloudTruth(targetBabyId)) rethrow;
    }
  }

  static Future<void> _syncActiveBabyMedicationLogsToCloud({
    String? babyId,
  }) async {
    await _repairMissingIdsAndPersistIfNeeded();
    final targetBabyId = babyId ?? _activeBabyId;
    final uid = _currentUid;
    if (uid == null || uid.isEmpty || targetBabyId.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_syncActiveBabyMedicationLogsToCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
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
    } catch (e, st) {
      _log(
        '_syncActiveBabyMedicationLogsToCloud failed '
        'babyId=$targetBabyId: $e',
      );
      if (kDebugMode) {
        _log('_syncActiveBabyMedicationLogsToCloud stack: $st');
      }
      if (await _isSharedBabyUsingCloudTruth(targetBabyId)) rethrow;
    }
  }

  // Initialize - must be called before using any other methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _localStore = SharedPreferencesLocalStore(_prefs!);
    _dataSyncService = DataSyncService(
      localStore: _localStore!,
      firestoreStore: _firestoreStore,
    );
    await _pruneLocalCachesForAuthScopeIfNeeded();

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
    final storedActiveBabyId = _getLocalString('active_baby_id') ?? '';
    _activeBabyId = storedActiveBabyId;

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
    await _repairMissingIdsAndPersistIfNeeded();

    final authUser = _currentUser;
    _log(
      'Startup auth uid=${authUser?.uid} anonymous=${authUser?.isAnonymous} '
      'providers=${DataSyncService.providerIdsForUser(authUser)} '
      'babies local=${_babies.length} remote=pending',
    );

    // If signed in, prefer Firestore-backed data scoped to current uid.
    await _syncFromCloudIfSignedIn();
    // Load shared babies (accepted invitations) and merge into _babies.
    _sharedBabyIds.clear();
    await _loadSharedBabiesFromCloud();
    await _pruneInaccessibleBabiesForCurrentUser();
    if (storedActiveBabyId.isNotEmpty &&
        _babies.any((b) => b.id == storedActiveBabyId)) {
      _activeBabyId = storedActiveBabyId;
      await _setLocalString('active_baby_id', _activeBabyId);
    }
    // Start real-time listeners so shared activities appear without restart.
    _startSharedRecordListeners();
    _scheduleBestEffortCloudWrite(
      _syncPhotosWithStorageBestEffort,
      label: 'photo storage sync',
      timeout: _bestEffortPhotoStorageTimeout,
    );

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
    _dailyTipReminderEnabled =
        _prefs!.getBool('daily_tip_reminder_enabled') ?? false;
    _medicationRemindersEnabled =
        _prefs!.getBool('medication_reminder_enabled') ?? true;
    _feedingReminderHour = _prefs!.getInt('feeding_reminder_time_h') ?? 14;
    _feedingReminderMinute = _prefs!.getInt('feeding_reminder_time_m') ?? 0;
    _diaperReminderHour = _prefs!.getInt('diaper_reminder_time_h') ?? 14;
    _diaperReminderMinute = _prefs!.getInt('diaper_reminder_time_m') ?? 0;
    _dailyTipReminderHour = _prefs!.getInt('daily_tip_reminder_time_h') ?? 10;
    _dailyTipReminderMinute = _prefs!.getInt('daily_tip_reminder_time_m') ?? 0;

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
    if ((baby.photoStoragePath ?? '').trim().isNotEmpty) score += 3;
    if ((baby.photoUrl ?? '').trim().isNotEmpty) score += 2;
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

  /// Returns true when [babyId] was shared with this user (not owned).
  static bool isSharedBaby(String babyId) => _sharedBabyIds.contains(babyId);

  /// Returns true when [babyId] should show the Shared badge — covers both:
  /// • babies shared *with* this user (_sharedBabyIds), AND
  /// • babies *owned* by this user that have at least one co-parent member.
  static bool isBabyVisiblyShared(String babyId) =>
      _sharedBabyIds.contains(babyId) ||
      _ownedBabyIdsWithMembers.contains(babyId);

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
    late final Baby baby;
    if (existingIndex >= 0) {
      final existing = _babies[existingIndex];
      baby = Baby(
        id: existing.id,
        name: name,
        birthDate: birthDate,
        photoPath: photoPath ?? existing.photoPath,
        photoStoragePath: existing.photoStoragePath,
        photoUrl: existing.photoUrl,
        createdAt: existing.createdAt,
      );
      _babies[existingIndex] = baby;
    } else {
      baby = Baby(
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
    await _createBabyInCloud(baby);
    await _syncBabiesToCloud();
    return babyId;
  }

  static Future<void> _createBabyInCloud(Baby baby) async {
    final uid = _currentUid;
    if (uid == null || uid.isEmpty) return;
    if (!_canSyncWithCloud(
      operation: '_createBabyInCloud',
      skipMessage: '[Sync] skip cloud write: user is anonymous',
    )) {
      return;
    }
    try {
      await _firestoreStore.replaceBabies(uid, [baby]);
    } catch (_) {}
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

    if (isSharedBaby(babyId)) {
      _log('Delete skipped for shared babyId=$babyId');
      return BabyDeleteResult(
        deleted: false,
        cloudDeleteFailed: false,
        hasRemainingBabies: _babies.isNotEmpty,
      );
    }

    final removedLocalCounts = <String, int>{};
    final uid = _currentUid;
    final authUser = _currentUser;
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

    if (uid != null &&
        uid.isNotEmpty &&
        _canSyncWithCloud(
          operation: 'deleteBaby',
          skipMessage: '[Sync] skip cloud write: user is anonymous',
        )) {
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
    String? photoStoragePath,
    String? photoUrl,
    bool clearPhoto = false,
  }) async {
    final index = _babies.indexWhere((b) => b.id == babyId);
    if (index == -1) return;
    final previousPhotoPath = _babies[index].photoPath;
    final previousPhotoStoragePath = (_babies[index].photoStoragePath ?? '')
        .trim();
    String? profilePhotoDeletePath;
    if (name != null) _babies[index].name = name;
    if (birthDate != null) _babies[index].birthDate = birthDate;
    if (clearPhoto) {
      if (previousPhotoStoragePath.isNotEmpty) {
        profilePhotoDeletePath = previousPhotoStoragePath;
      } else {
        _log('profile photo delete skip babyId=$babyId reason=no-remote-photo');
      }
      _babies[index].photoPath = null;
      _babies[index].photoStoragePath = null;
      _babies[index].photoUrl = null;
    } else if (photoPath != null) {
      _babies[index].photoPath = photoPath;
      if ((previousPhotoPath ?? '') != photoPath) {
        if (previousPhotoStoragePath.isNotEmpty) {
          profilePhotoDeletePath = previousPhotoStoragePath;
        } else {
          _log(
            'profile photo delete skip babyId=$babyId reason=no-remote-photo',
          );
        }
        _babies[index].photoStoragePath = null;
        _babies[index].photoUrl = null;
      }
    }
    if (photoStoragePath != null) {
      _babies[index].photoStoragePath = photoStoragePath;
    }
    if (photoUrl != null) {
      _babies[index].photoUrl = photoUrl;
    }
    await _saveBabies();
    await _syncBabiesToCloud();
    _scheduleBestEffortCloudWrite(
      _syncPhotosWithStorageBestEffort,
      label: 'photo storage sync',
      timeout: _bestEffortPhotoStorageTimeout,
    );
    if ((profilePhotoDeletePath ?? '').isNotEmpty) {
      final storagePathToDelete = profilePhotoDeletePath!;
      _scheduleBestEffortCloudWrite(
        () async {
          final uid = _currentUid;
          if (uid == null || uid.isEmpty) return;
          await _photoStorageSyncService.deleteBabyPhoto(
            uid: uid,
            babyId: babyId,
            storagePath: storagePathToDelete,
            log: _log,
          );
        },
        label: 'profile photo delete',
        timeout: _bestEffortPhotoStorageTimeout,
      );
    }
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
              'id': (e['id'] ?? '').toString(),
              'miktar': e['miktar'] ?? 0,
              'tur': e['tur'] ?? '',
              'solDakika': e['solDakika'] ?? 0,
              'sagDakika': e['sagDakika'] ?? 0,
              'kategori': e['kategori'] ?? 'Milk',
              'solidAciklama': e['solidAciklama'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'createdBy': (e['createdBy'] ?? '').toString(),
              'createdByName': (e['createdByName'] ?? '').toString(),
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMamaKayitlari() {
    return _mamaKayitlari
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
        .toList();
  }

  static Future<void> saveMamaKayitlari(
    List<Map<String, dynamic>> kayitlar, {
    String? sharedNoopHealRecordId,
  }) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final existingFeedings = _mamaKayitlari
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final existingById = <String, Map<String, dynamic>>{
      for (final row in existingFeedings)
        (row['id'] ?? '').toString(): Map<String, dynamic>.from(row),
    };
    final beforeIds = _activeIdsFromRows(existingFeedings);
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    final changedRows = <Map<String, dynamic>>[];
    for (final r in kayitlar) {
      r['babyId'] = targetBabyId;
      final id = _ensureStableIdForRow(r, entity: 'feeding');
      final existing = existingById[id];
      final preparedRow = Map<String, dynamic>.from(r);
      final changed =
          existing == null ||
          _rowIsDeleted(existing) ||
          _rowComparableSignature(existing) !=
              _rowComparableSignature(preparedRow);
      preparedRow['updatedAt'] = changed ? now : existing['updatedAt'] ?? now;
      preparedRow['localUpdatedAt'] = changed
          ? now
          : existing['localUpdatedAt'] ?? existing['updatedAt'] ?? now;
      preparedRow['isDeleted'] = false;
      preparedRow['deletedAt'] = null;
      prepared.add(preparedRow);
      if (changed) {
        changedRows.add(Map<String, dynamic>.from(preparedRow));
      }
    }

    final incomingIds = prepared
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final generatedTombstones = existingFeedings
        .where((r) => !_rowIsDeleted(r))
        .where((r) => !incomingIds.contains((r['id'] ?? '').toString()))
        .map((r) => _tombstoneRowFrom(r, now: now))
        .toList();
    changedRows.addAll(
      generatedTombstones.map((e) => Map<String, dynamic>.from(e)),
    );
    if (isSharedBaby &&
        changedRows.isEmpty &&
        sharedNoopHealRecordId != null &&
        sharedNoopHealRecordId.trim().isNotEmpty) {
      final healId = sharedNoopHealRecordId.trim();
      final healRow = prepared.where(
        (row) => (row['id'] ?? '').toString().trim() == healId,
      );
      changedRows.addAll(healRow.map((row) => Map<String, dynamic>.from(row)));
    }

    _mamaKayitlari.removeWhere((r) => r['babyId'] == targetBabyId);
    _mamaKayitlari.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingFeedings,
        incomingActive: prepared,
        now: now,
      ),
    );
    _notifyDataChanged(reason: 'mama_kayitlari');

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
            'createdBy': e['createdBy'] ?? '',
            'createdByName': e['createdByName'] ?? '',
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('mama_kayitlari', jsonEncode(data));
    if (kDebugMode) {
      _log('record persisted type=feeding count=${kayitlar.length}');
    }
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'feeding sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:feeding-sync',
            ),
      sync: () => _syncScopedRecordRowsToCloud(
        babyId: targetBabyId,
        rows: changedRows,
        shared: isSharedBaby,
      ),
    );
    final afterIds = _activeIdsFromRows(prepared);
    final createdIds = afterIds.difference(beforeIds);
    final createdRows = prepared
        .where((row) => createdIds.contains((row['id'] ?? '').toString()))
        .toList();
    final notificationActivityType =
        createdRows.isNotEmpty &&
            createdRows.every((row) => _isNursingMamaRow(row))
        ? 'nursing'
        : 'feeding';
    _scheduleSharedActivityNotificationIfNeeded(
      babyId: _activeBabyId,
      activityType: notificationActivityType,
      createdNewRecord: createdIds.isNotEmpty,
    );
  }

  static Future<bool> updateMamaKaydiById(
    String id,
    Map<String, dynamic> updated,
  ) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      _log('updateMamaKaydiById failed: empty id');
      return false;
    }
    final kayitlar = getMamaKayitlari();
    final index = kayitlar.indexWhere(
      (k) => (k['id'] ?? '').toString().trim() == normalizedId,
    );
    if (index == -1) {
      _log(
        'updateMamaKaydiById failed: id=$normalizedId not found among active records',
      );
      return false;
    }
    updated['id'] = normalizedId;
    updated['babyId'] = _activeBabyId;
    kayitlar[index] = updated;
    await saveMamaKayitlari(kayitlar);
    return true;
  }

  static Future<bool> deleteMamaKaydiById(String id) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final idx = _mamaKayitlari.indexWhere(
      (k) => k['babyId'] == targetBabyId && k['id'] == id && !_rowIsDeleted(k),
    );
    if (idx == -1) return false;
    _mamaKayitlari[idx] = _tombstoneRowFrom(
      _mamaKayitlari[idx],
      now: DateTime.now(),
    );
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
                'createdBy': e['createdBy'] ?? '',
                'createdByName': e['createdByName'] ?? '',
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
    _notifyDataChanged(reason: 'mama_kayitlari');
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'feeding delete sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:feeding-delete-sync',
            ),
      sync: () => _syncScopedRecordRowsToCloud(
        babyId: targetBabyId,
        rows: [_mamaKayitlari[idx]],
        shared: isSharedBaby,
      ),
    );
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
              'id': (e['id'] ?? '').toString(),
              'tur': normalizeDiaperType(e['diaperType'] ?? e['tur']),
              'diaperType': normalizeDiaperType(e['diaperType'] ?? e['tur']),
              'eventType': normalizeDiaperEventType(
                e['eventType'] ?? e['kategori'] ?? e['category'],
              ),
              'notlar': e['notlar'] ?? '',
              'babyId': e['babyId'] ?? _activeBabyId,
              'createdBy': (e['createdBy'] ?? '').toString(),
              'createdByName': (e['createdByName'] ?? '').toString(),
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getKakaKayitlari() {
    return _kakaKayitlari
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
        .toList();
  }

  static Future<void> saveKakaKayitlari(
    List<Map<String, dynamic>> kayitlar, {
    String? sharedNoopHealRecordId,
  }) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final existingDiapers = _kakaKayitlari
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final existingById = <String, Map<String, dynamic>>{
      for (final row in existingDiapers)
        (row['id'] ?? '').toString(): Map<String, dynamic>.from(row),
    };
    final beforeIds = _activeIdsFromRows(existingDiapers);
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    final changedRows = <Map<String, dynamic>>[];
    for (final r in kayitlar) {
      r['babyId'] = targetBabyId;
      final id = _ensureStableIdForRow(r, entity: 'diaper');
      final normalizedType = normalizeDiaperType(r['diaperType'] ?? r['tur']);
      final existing = existingById[id];
      final preparedRow = Map<String, dynamic>.from(r);
      preparedRow['tur'] = normalizedType;
      preparedRow['diaperType'] = normalizedType;
      preparedRow['eventType'] = diaperEventType;
      final changed =
          existing == null ||
          _rowIsDeleted(existing) ||
          _rowComparableSignature(existing) !=
              _rowComparableSignature(preparedRow);
      preparedRow['updatedAt'] = changed ? now : existing['updatedAt'] ?? now;
      preparedRow['localUpdatedAt'] = changed
          ? now
          : existing['localUpdatedAt'] ?? existing['updatedAt'] ?? now;
      preparedRow['isDeleted'] = false;
      preparedRow['deletedAt'] = null;
      prepared.add(preparedRow);
      if (changed) {
        changedRows.add(Map<String, dynamic>.from(preparedRow));
      }
    }

    final incomingIds = prepared
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final generatedTombstones = existingDiapers
        .where((r) => !_rowIsDeleted(r))
        .where((r) => !incomingIds.contains((r['id'] ?? '').toString()))
        .map((r) => _tombstoneRowFrom(r, now: now))
        .toList();
    changedRows.addAll(
      generatedTombstones.map((e) => Map<String, dynamic>.from(e)),
    );
    if (isSharedBaby &&
        changedRows.isEmpty &&
        sharedNoopHealRecordId != null &&
        sharedNoopHealRecordId.trim().isNotEmpty) {
      final healId = sharedNoopHealRecordId.trim();
      final healRow = prepared.where(
        (row) => (row['id'] ?? '').toString().trim() == healId,
      );
      changedRows.addAll(healRow.map((row) => Map<String, dynamic>.from(row)));
    }

    _kakaKayitlari.removeWhere((r) => r['babyId'] == targetBabyId);
    _kakaKayitlari.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingDiapers,
        incomingActive: prepared,
        now: now,
      ),
    );
    _notifyDataChanged(reason: 'kaka_kayitlari');

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
            'createdBy': e['createdBy'] ?? '',
            'createdByName': e['createdByName'] ?? '',
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('kaka_kayitlari', jsonEncode(data));
    if (kDebugMode) {
      _log('record persisted type=diaper count=${kayitlar.length}');
    }
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'diaper sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:diaper-sync',
            ),
      sync: () => _syncScopedRecordRowsToCloud(
        babyId: targetBabyId,
        rows: changedRows,
        shared: isSharedBaby,
      ),
    );
    final afterIds = _activeIdsFromRows(prepared);
    _scheduleSharedActivityNotificationIfNeeded(
      babyId: _activeBabyId,
      activityType: 'diaper',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
  }

  static Future<bool> updateKakaKaydiById(
    String id,
    Map<String, dynamic> updated,
  ) async {
    String canonicalId(dynamic value) =>
        value?.toString().trim().toLowerCase() ?? '';

    final rawId = id.trim();
    final normalizedId = canonicalId(id);
    final kayitlar = getKakaKayitlari();

    _log(
      'updateKakaKaydiById start rawId="$rawId" normalizedId="$normalizedId" '
      'activeCount=${kayitlar.length} payloadTarih=${updated['tarih']} '
      'payloadType=${updated['diaperType'] ?? updated['tur']}',
    );

    var index = kayitlar.indexWhere(
      (k) => (k['id'] ?? '').toString().trim() == rawId,
    );
    if (index == -1 && normalizedId.isNotEmpty) {
      index = kayitlar.indexWhere((k) => canonicalId(k['id']) == normalizedId);
    }

    var matchedByFallback = false;
    if (index == -1) {
      final payloadTarih = updated['tarih'];
      if (payloadTarih is DateTime) {
        final payloadType = normalizeDiaperType(
          updated['diaperType'] ?? updated['tur'],
        );
        final fallbackMatches = kayitlar
            .where(
              (k) =>
                  k['tarih'] is DateTime &&
                  (k['tarih'] as DateTime).isAtSameMomentAs(payloadTarih) &&
                  normalizeDiaperType(k['diaperType'] ?? k['tur']) ==
                      payloadType,
            )
            .toList();
        if (fallbackMatches.length == 1) {
          final fallbackId = (fallbackMatches.first['id'] ?? '')
              .toString()
              .trim();
          index = kayitlar.indexWhere(
            (k) => (k['id'] ?? '').toString().trim() == fallbackId,
          );
          matchedByFallback = index != -1;
        }
      }
    }

    if (index == -1) {
      final sampleIds = kayitlar
          .take(5)
          .map((k) => (k['id'] ?? '').toString().trim())
          .toList();
      _log(
        'updateKakaKaydiById failed: rawId="$rawId" normalizedId="$normalizedId" '
        'not found among active records sampleIds=$sampleIds',
      );
      return false;
    }

    final matchedId = (kayitlar[index]['id'] ?? '').toString().trim();
    _log(
      'updateKakaKaydiById matched index=$index matchedId="$matchedId" '
      'matchedByFallback=$matchedByFallback',
    );

    try {
      updated['id'] = matchedId;
      updated['babyId'] = _activeBabyId;
      kayitlar[index] = updated;
      await saveKakaKayitlari(kayitlar, sharedNoopHealRecordId: matchedId);
      _log(
        'updateKakaKaydiById result=true rawId="$rawId" matchedId="$matchedId"',
      );
      return true;
    } catch (e, st) {
      _log('updateKakaKaydiById exception rawId="$rawId" error=$e\n$st');
      return false;
    }
  }

  static Future<bool> deleteKakaKaydiById(String id) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final idx = _kakaKayitlari.indexWhere(
      (k) => k['babyId'] == targetBabyId && k['id'] == id && !_rowIsDeleted(k),
    );
    if (idx == -1) return false;
    _kakaKayitlari[idx] = _tombstoneRowFrom(
      _kakaKayitlari[idx],
      now: DateTime.now(),
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
                'createdBy': e['createdBy'] ?? '',
                'createdByName': e['createdByName'] ?? '',
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
    _notifyDataChanged(reason: 'kaka_kayitlari');
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'diaper delete sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:diaper-delete-sync',
            ),
      sync: () => _syncScopedRecordRowsToCloud(
        babyId: targetBabyId,
        rows: [_kakaKayitlari[idx]],
        shared: isSharedBaby,
      ),
    );
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
              'id': (e['id'] ?? '').toString(),
              'sure': Duration(minutes: e['sure']),
              'babyId': e['babyId'] ?? _activeBabyId,
              'createdBy': (e['createdBy'] ?? '').toString(),
              'createdByName': (e['createdByName'] ?? '').toString(),
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['bitis']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['bitis']),
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getUykuKayitlari() {
    return _uykuKayitlari
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
        .toList();
  }

  static Future<void> saveUykuKayitlari(
    List<Map<String, dynamic>> kayitlar, {
    String? sharedNoopHealRecordId,
  }) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final existingSleeps = _uykuKayitlari
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final existingById = <String, Map<String, dynamic>>{
      for (final row in existingSleeps)
        (row['id'] ?? '').toString(): Map<String, dynamic>.from(row),
    };
    final beforeIds = _activeIdsFromRows(existingSleeps);
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    final changedRows = <Map<String, dynamic>>[];
    for (final r in kayitlar) {
      r['babyId'] = targetBabyId;
      final id = _ensureStableIdForRow(r, entity: 'sleep');
      final existing = existingById[id];
      final preparedRow = Map<String, dynamic>.from(r);
      final changed =
          existing == null ||
          _rowIsDeleted(existing) ||
          _rowComparableSignature(existing) !=
              _rowComparableSignature(preparedRow);
      preparedRow['updatedAt'] = changed ? now : existing['updatedAt'] ?? now;
      preparedRow['localUpdatedAt'] = changed
          ? now
          : existing['localUpdatedAt'] ?? existing['updatedAt'] ?? now;
      preparedRow['isDeleted'] = false;
      preparedRow['deletedAt'] = null;
      prepared.add(preparedRow);
      if (changed) {
        changedRows.add(Map<String, dynamic>.from(preparedRow));
      }
    }

    final incomingIds = prepared
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final generatedTombstones = existingSleeps
        .where((r) => !_rowIsDeleted(r))
        .where((r) => !incomingIds.contains((r['id'] ?? '').toString()))
        .map((r) => _tombstoneRowFrom(r, now: now))
        .toList();
    changedRows.addAll(
      generatedTombstones.map((e) => Map<String, dynamic>.from(e)),
    );
    if (isSharedBaby &&
        changedRows.isEmpty &&
        sharedNoopHealRecordId != null &&
        sharedNoopHealRecordId.trim().isNotEmpty) {
      final healId = sharedNoopHealRecordId.trim();
      final healRow = prepared.where(
        (row) => (row['id'] ?? '').toString().trim() == healId,
      );
      changedRows.addAll(healRow.map((row) => Map<String, dynamic>.from(row)));
    }

    _uykuKayitlari.removeWhere((r) => r['babyId'] == targetBabyId);
    _uykuKayitlari.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingSleeps,
        incomingActive: prepared,
        now: now,
      ),
    );
    _notifyDataChanged(reason: 'uyku_kayitlari');

    final data = _uykuKayitlari
        .map(
          (e) => {
            'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
            'bitis': (e['bitis'] as DateTime).toIso8601String(),
            'id': e['id'],
            'sure': (e['sure'] as Duration).inMinutes,
            'babyId': e['babyId'],
            'createdBy': e['createdBy'] ?? '',
            'createdByName': e['createdByName'] ?? '',
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('uyku_kayitlari', jsonEncode(data));
    if (kDebugMode) {
      _log('record persisted type=sleep count=${kayitlar.length}');
    }
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'sleep sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:sleep-sync',
            ),
      sync: () => _syncScopedRecordRowsToCloud(
        babyId: targetBabyId,
        rows: changedRows,
        shared: isSharedBaby,
      ),
    );
    final afterIds = _activeIdsFromRows(prepared);
    _scheduleSharedActivityNotificationIfNeeded(
      babyId: _activeBabyId,
      activityType: 'sleep',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
  }

  static Future<bool> updateUykuKaydiById(
    String id,
    Map<String, dynamic> updated,
  ) async {
    String canonicalId(dynamic value) =>
        value?.toString().trim().toLowerCase() ?? '';

    final rawId = id.trim();
    final normalizedId = canonicalId(id);
    final kayitlar = getUykuKayitlari();

    _log(
      'updateUykuKaydiById start rawId="$rawId" normalizedId="$normalizedId" '
      'activeCount=${kayitlar.length} payloadStart=${updated['baslangic']} '
      'payloadEnd=${updated['bitis']} payloadSure=${updated['sure']}',
    );

    var index = kayitlar.indexWhere(
      (k) => (k['id'] ?? '').toString().trim() == rawId,
    );
    if (index == -1 && normalizedId.isNotEmpty) {
      index = kayitlar.indexWhere((k) => canonicalId(k['id']) == normalizedId);
    }

    var matchedByFallback = false;
    if (index == -1) {
      final payloadStart = updated['baslangic'];
      final payloadEnd = updated['bitis'];
      if (payloadStart is DateTime && payloadEnd is DateTime) {
        final fallbackMatches = kayitlar
            .where(
              (k) =>
                  k['baslangic'] is DateTime &&
                  k['bitis'] is DateTime &&
                  (k['baslangic'] as DateTime).isAtSameMomentAs(payloadStart) &&
                  (k['bitis'] as DateTime).isAtSameMomentAs(payloadEnd),
            )
            .toList();
        if (fallbackMatches.length == 1) {
          final fallbackId = (fallbackMatches.first['id'] ?? '')
              .toString()
              .trim();
          index = kayitlar.indexWhere(
            (k) => (k['id'] ?? '').toString().trim() == fallbackId,
          );
          matchedByFallback = index != -1;
        }
      }
    }

    if (index == -1) {
      final sampleIds = kayitlar
          .take(5)
          .map((k) => (k['id'] ?? '').toString().trim())
          .toList();
      _log(
        'updateUykuKaydiById failed: rawId="$rawId" normalizedId="$normalizedId" '
        'not found among active records sampleIds=$sampleIds',
      );
      return false;
    }

    final matchedId = (kayitlar[index]['id'] ?? '').toString().trim();
    _log(
      'updateUykuKaydiById matched index=$index matchedId="$matchedId" '
      'matchedByFallback=$matchedByFallback',
    );

    try {
      updated['id'] = matchedId;
      updated['babyId'] = _activeBabyId;
      kayitlar[index] = updated;
      await saveUykuKayitlari(kayitlar, sharedNoopHealRecordId: matchedId);
      _log(
        'updateUykuKaydiById result=true rawId="$rawId" matchedId="$matchedId"',
      );
      return true;
    } catch (e, st) {
      _log('updateUykuKaydiById exception rawId="$rawId" error=$e\n$st');
      return false;
    }
  }

  static Future<bool> deleteUykuKaydiById(String id) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final idx = _uykuKayitlari.indexWhere(
      (k) => k['babyId'] == targetBabyId && k['id'] == id && !_rowIsDeleted(k),
    );
    if (idx == -1) return false;
    _uykuKayitlari[idx] = _tombstoneRowFrom(
      _uykuKayitlari[idx],
      now: DateTime.now(),
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
                'createdBy': e['createdBy'] ?? '',
                'createdByName': e['createdByName'] ?? '',
                'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
                'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                    ?.toIso8601String(),
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
    _notifyDataChanged(reason: 'uyku_kayitlari');
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'sleep delete sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:sleep-delete-sync',
            ),
      sync: () => _syncScopedRecordRowsToCloud(
        babyId: targetBabyId,
        rows: [_uykuKayitlari[idx]],
        shared: isSharedBaby,
      ),
    );
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
              'id': (e['id'] ?? '').toString(),
              'tarih': DateTime.parse(e['tarih']),
              'emoji': e['emoji'],
              'photoPath': e['photoLocalPath'] ?? e['photoPath'],
              'photoLocalPath': e['photoLocalPath'] ?? e['photoPath'],
              'photoStoragePath': e['photoStoragePath'],
              'photoUrl': e['photoUrl'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['tarih']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['tarih']),
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAnilar() {
    final rows = _anilar
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
        .toList();
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
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    final beforeIds = _activeIdsFromRows(
      _anilar
          .where((r) => r['babyId'] == targetBabyId)
          .map((e) => Map<String, dynamic>.from(e)),
    );
    for (final r in anilar) {
      final normalizedPhotoPath = (r['photoPath'] ?? r['photoLocalPath'] ?? '')
          .toString()
          .trim();
      r['babyId'] = targetBabyId;
      _ensureStableIdForRow(r, entity: 'memory');
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
      r['isDeleted'] = false;
      r['deletedAt'] = null;
      if (normalizedPhotoPath.isEmpty) {
        r['photoPath'] = null;
        r['photoLocalPath'] = null;
        r['photoStoragePath'] = null;
        r['photoUrl'] = null;
      } else {
        r['photoPath'] = normalizedPhotoPath;
        r['photoLocalPath'] = normalizedPhotoPath;
      }
      prepared.add(Map<String, dynamic>.from(r));
    }

    final existingAnilar = _anilar
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final incomingIds = prepared
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final deletedRowsWithPhotos = existingAnilar
        .where(
          (r) =>
              r['babyId'] == targetBabyId &&
              !_rowIsDeleted(r) &&
              !incomingIds.contains((r['id'] ?? '').toString()) &&
              (r['photoStoragePath'] ?? '').toString().trim().isNotEmpty,
        )
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _anilar.removeWhere((r) => r['babyId'] == targetBabyId);
    _anilar.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingAnilar,
        incomingActive: prepared,
        now: now,
      ),
    );
    await _persistAnilarToLocalStore();
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'memory sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:memory-sync',
            ),
      sync: () => _syncActiveBabyMemoriesToCloud(babyId: targetBabyId),
    );
    final afterIds = _activeIdsFromRows(prepared);
    await _notifySharedActivityIfNeeded(
      babyId: targetBabyId,
      activityType: 'memory',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
    await _syncMemoryPhotosAfterSave();
    if (deletedRowsWithPhotos.isNotEmpty) {
      final rowsToDelete = deletedRowsWithPhotos;
      _scheduleBestEffortCloudWrite(
        () async {
          final uid = _currentUid;
          if (uid == null || uid.isEmpty) return;
          await _photoStorageSyncService.deleteMemoryPhotos(
            uid: uid,
            rows: rowsToDelete,
            log: _log,
          );
        },
        label: 'memory photo delete',
        timeout: _bestEffortPhotoStorageTimeout,
      );
    }
  }

  static Future<void> _persistAnilarToLocalStore() async {
    final data = _anilar
        .map(
          (e) => {
            'baslik': e['baslik'],
            'not': e['not'],
            'id': e['id'],
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'emoji': e['emoji'],
            'photoPath': e['photoPath'],
            'photoLocalPath': e['photoLocalPath'] ?? e['photoPath'],
            'photoStoragePath': e['photoStoragePath'],
            'photoUrl': e['photoUrl'],
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('anilar', jsonEncode(data));
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
              'id': (e['id'] ?? '').toString(),
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
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getBoyKiloKayitlari() {
    return _boyKiloKayitlari
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
        .toList();
  }

  static Future<void> saveBoyKiloKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final beforeIds = _activeIdsFromRows(
      _boyKiloKayitlari
          .where((r) => r['babyId'] == targetBabyId)
          .map((e) => Map<String, dynamic>.from(e)),
    );
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    for (final r in kayitlar) {
      r['babyId'] = targetBabyId;
      _ensureStableIdForRow(r, entity: 'growth');
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
      r['isDeleted'] = false;
      r['deletedAt'] = null;
      prepared.add(Map<String, dynamic>.from(r));
    }

    final existingGrowth = _boyKiloKayitlari
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _boyKiloKayitlari.removeWhere((r) => r['babyId'] == targetBabyId);
    _boyKiloKayitlari.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingGrowth,
        incomingActive: prepared,
        now: now,
      ),
    );

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
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('boykilo_kayitlari', jsonEncode(data));
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'growth sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:growth-sync',
            ),
      sync: () => _syncActiveBabyRecordsToCloud(babyId: targetBabyId),
    );
    final afterIds = _activeIdsFromRows(prepared);
    await _notifySharedActivityIfNeeded(
      babyId: targetBabyId,
      activityType: 'growth',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
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
              'id': (e['id'] ?? '').toString(),
              'title': e['title'],
              'date': DateTime.parse(e['date']),
              'note': e['note'],
              'photoPath': e['photoPath'],
              'photoStoragePath': e['photoStoragePath'],
              'photoUrl': e['photoUrl'],
              'photoStyle': e['photoStyle'] ?? 'softIllustration',
              'illustrationUrl': e['illustrationUrl'],
              'babyId': e['babyId'] ?? _activeBabyId,
              'updatedAt': e['updatedAt'] != null
                  ? DateTime.parse(e['updatedAt'])
                  : DateTime.parse(e['date']),
              'localUpdatedAt': e['localUpdatedAt'] != null
                  ? DateTime.parse(e['localUpdatedAt'])
                  : DateTime.parse(e['date']),
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMilestones() {
    final rows = _milestones
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
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
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    final beforeIds = _activeIdsFromRows(
      _milestones
          .where((r) => r['babyId'] == targetBabyId)
          .map((e) => Map<String, dynamic>.from(e)),
    );
    for (final r in milestones) {
      r['babyId'] = targetBabyId;
      _ensureStableIdForRow(r, entity: 'milestone');
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
      r['isDeleted'] = false;
      r['deletedAt'] = null;
      if ((r['photoPath'] ?? '').toString().trim().isEmpty) {
        r['photoStoragePath'] = null;
        r['photoUrl'] = null;
      }
      prepared.add(Map<String, dynamic>.from(r));
    }

    final existingMilestones = _milestones
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final incomingIds = prepared
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final deletedRowsWithPhotos = existingMilestones
        .where(
          (r) =>
              r['babyId'] == targetBabyId &&
              !_rowIsDeleted(r) &&
              !incomingIds.contains((r['id'] ?? '').toString()) &&
              (r['photoStoragePath'] ?? '').toString().trim().isNotEmpty,
        )
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _milestones.removeWhere((r) => r['babyId'] == targetBabyId);
    _milestones.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingMilestones,
        incomingActive: prepared,
        now: now,
      ),
    );
    await _persistMilestonesToLocalStore();
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'milestone sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:milestone-sync',
            ),
      sync: () => _syncActiveBabyMemoriesToCloud(babyId: targetBabyId),
    );
    final afterIds = _activeIdsFromRows(prepared);
    await _notifySharedActivityIfNeeded(
      babyId: targetBabyId,
      activityType: 'milestone',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
    await _syncMemoryPhotosAfterSave();
    if (deletedRowsWithPhotos.isNotEmpty) {
      final rowsToDelete = deletedRowsWithPhotos;
      _scheduleBestEffortCloudWrite(
        () async {
          final uid = _currentUid;
          if (uid == null || uid.isEmpty) return;
          await _photoStorageSyncService.deleteMemoryPhotos(
            uid: uid,
            rows: rowsToDelete,
            log: _log,
          );
        },
        label: 'memory photo delete',
        timeout: _bestEffortPhotoStorageTimeout,
      );
    }
  }

  /// Writes [illustrationUrl] back to the in-memory milestone record and
  /// schedules a local + cloud persist. Called after a generation completes.
  static Future<void> patchMilestoneIllustrationUrl(
    String milestoneId,
    String illustrationUrl,
  ) async {
    final idx = _milestones.indexWhere(
      (r) => (r['id'] ?? '').toString() == milestoneId,
    );
    if (idx < 0) return;
    final now = DateTime.now();
    _milestones[idx]['illustrationUrl'] = illustrationUrl;
    _milestones[idx]['updatedAt'] = now;
    _milestones[idx]['localUpdatedAt'] = now;
    await _persistMilestonesToLocalStore();
    await _syncSharedCriticalOrBestEffort(
      babyId: (_milestones[idx]['babyId'] ?? '').toString(),
      label: 'illustration url sync',
      sync: () => _syncActiveBabyMemoriesToCloud(
        babyId: (_milestones[idx]['babyId'] ?? '').toString(),
      ),
    );
    _notifyDataChanged(reason: 'illustration-url-patched');
  }

  static Future<void> _persistMilestonesToLocalStore() async {
    final data = _milestones
        .map(
          (e) => {
            'id': e['id'],
            'title': e['title'],
            'date': (e['date'] as DateTime).toIso8601String(),
            'note': e['note'],
            'photoPath': e['photoPath'],
            'photoStoragePath': e['photoStoragePath'],
            'photoUrl': e['photoUrl'],
            'photoStyle': e['photoStyle'] ?? 'softIllustration',
            'illustrationUrl': e['illustrationUrl'],
            'babyId': e['babyId'],
            'updatedAt': (e['updatedAt'] as DateTime?)?.toIso8601String(),
            'localUpdatedAt': (e['localUpdatedAt'] as DateTime?)
                ?.toIso8601String(),
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('milestones', jsonEncode(data));
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
              'id': (e['id'] ?? '').toString(),
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
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAsiKayitlari() {
    return getAsiKayitlariForBaby(_activeBabyId);
  }

  static List<Map<String, dynamic>> getAsiKayitlariForBaby(String babyId) {
    final targetBabyId = babyId.trim();
    if (targetBabyId.isEmpty) {
      if (kDebugMode) {
        _log('getAsiKayitlariForBaby: empty target babyId');
      }
      return [];
    }
    final rows = _asiKayitlari
        .where((r) => r['babyId'] == targetBabyId && !_rowIsDeleted(r))
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    if (kDebugMode) {
      _log(
        'getAsiKayitlariForBaby babyId=$targetBabyId '
        'count=${rows.length} ids=${rows.map((r) => r['id']).join(',')}',
      );
    }
    return rows;
  }

  static ValueNotifier<int> get vaccineNotifier => _vaccineVersion;
  static ValueNotifier<int> get dataNotifier => _dataVersion;

  static Future<void> saveAsiKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    await saveAsiKayitlariForBaby(_activeBabyId, kayitlar);
  }

  static Future<void> saveAsiKayitlariForBaby(
    String babyId,
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final targetBabyId = babyId.trim();
    if (targetBabyId.isEmpty) {
      throw StateError('No active baby selected.');
    }
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final existingVaccines = _asiKayitlari
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    final existingById = <String, Map<String, dynamic>>{
      for (final row in existingVaccines)
        (row['id'] ?? '').toString(): Map<String, dynamic>.from(row),
    };
    final beforeCount = _asiKayitlari
        .where((r) => r['babyId'] == targetBabyId && !_rowIsDeleted(r))
        .length;
    final beforeIds = _activeIdsFromRows(
      existingVaccines,
    );
    if (kDebugMode) {
      _log(
        'saveAsiKayitlariForBaby start babyId=$targetBabyId '
        'beforeCount=$beforeCount incomingCount=${kayitlar.length} '
        'isSharedBaby=$isSharedBaby syncPath=${isSharedBaby ? 'scoped' : 'broad'}',
      );
    }
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    final changedRows = <Map<String, dynamic>>[];
    for (final r in kayitlar) {
      r['babyId'] = targetBabyId;
      final id = _ensureStableIdForRow(r, entity: 'vaccine');
      final existing = existingById[id];
      final preparedRow = Map<String, dynamic>.from(r);
      attachCreatorMetadataIfAbsent(preparedRow);
      preparedRow['type'] = 'vaccine';
      final changed =
          existing == null ||
          _rowIsDeleted(existing) ||
          _rowComparableSignature(existing) !=
              _rowComparableSignature(preparedRow);
      preparedRow['updatedAt'] = changed ? now : existing['updatedAt'] ?? now;
      preparedRow['localUpdatedAt'] = changed
          ? now
          : existing['localUpdatedAt'] ?? existing['updatedAt'] ?? now;
      preparedRow['isDeleted'] = false;
      preparedRow['deletedAt'] = null;
      prepared.add(preparedRow);
      if (changed) {
        changedRows.add(Map<String, dynamic>.from(preparedRow));
      }
      if (kDebugMode) {
        _log(
          'saveAsiKayitlariForBaby row '
          'id=${preparedRow['id']} babyId=${preparedRow['babyId']} '
          'ad=${preparedRow['ad']} durum=${preparedRow['durum']} '
          'donem=${preparedRow['donem']} isDeleted=${preparedRow['isDeleted']}',
        );
      }
    }

    final incomingIds = prepared
        .map((r) => (r['id'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();
    final generatedTombstones = existingVaccines
        .where((r) => !_rowIsDeleted(r))
        .where((r) => !incomingIds.contains((r['id'] ?? '').toString()))
        .map((r) {
          final tombstone = _tombstoneRowFrom(r, now: now);
          tombstone['type'] = 'vaccine';
          return tombstone;
        })
        .toList();
    changedRows.addAll(
      generatedTombstones.map((e) => Map<String, dynamic>.from(e)),
    );
    _asiKayitlari.removeWhere((r) => r['babyId'] == targetBabyId);
    _asiKayitlari.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingVaccines,
        incomingActive: prepared,
        now: now,
      ),
    );
    if (targetBabyId == _activeBabyId) {
      _notifyDataChanged(reason: 'asi_kayitlari');
    }
    final afterRows = _asiKayitlari
        .where((r) => r['babyId'] == targetBabyId && !_rowIsDeleted(r))
        .map((r) => Map<String, dynamic>.from(r))
        .toList(growable: false);
    if (kDebugMode) {
      _log(
        'saveAsiKayitlariForBaby local-apply babyId=$targetBabyId '
        'afterCount=${afterRows.length} ids=${afterRows.map((r) => r['id']).join(',')} '
        'activeBabyId=$_activeBabyId dataVersion=${_dataVersion.value} '
        'vaccineVersion=${_vaccineVersion.value}',
      );
    }

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
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('asi_kayitlari', jsonEncode(data));
    _vaccineVersion.value++;
    if (kDebugMode) {
      _log(
        'saveAsiKayitlariForBaby persisted babyId=$targetBabyId '
        'afterCount=${afterRows.length} ids=${afterRows.map((r) => r['id']).join(',')} '
        'dataVersion=${_dataVersion.value} vaccineVersion=${_vaccineVersion.value}',
      );
      if (isSharedBaby) {
        _log(
          'saveAsiKayitlariForBaby shared sync babyId=$targetBabyId '
          'syncPath=scoped changedRows=${changedRows.length} '
          'rowIds=${changedRows.map((r) => r['id']).join(',')}',
        );
      } else {
        _log(
          'saveAsiKayitlariForBaby private sync babyId=$targetBabyId '
          'syncPath=broad recordCount=${afterRows.length}',
        );
      }
    }
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'vaccine sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:vaccine-sync',
            ),
      sync: () => isSharedBaby
          ? _syncScopedRecordRowsToCloud(
              babyId: targetBabyId,
              rows: changedRows,
              shared: isSharedBaby,
            )
          : _syncActiveBabyRecordsToCloud(babyId: targetBabyId),
    );
    final afterIds = _activeIdsFromRows(prepared);
    await _notifySharedActivityIfNeeded(
      babyId: targetBabyId,
      activityType: 'vaccine',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
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
              'id': (e['id'] ?? '').toString(),
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
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
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
    return _ilacKayitlari
        .where((r) => r['babyId'] == _activeBabyId && !_rowIsDeleted(r))
        .toList();
  }

  static Future<void> saveIlacKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final beforeIds = _activeIdsFromRows(
      _ilacKayitlari
          .where((r) => r['babyId'] == targetBabyId)
          .map((e) => Map<String, dynamic>.from(e)),
    );
    final now = DateTime.now();
    final prepared = <Map<String, dynamic>>[];
    for (final r in kayitlar) {
      r['babyId'] = targetBabyId;
      final createdAt = (r['createdAt'] as DateTime?) ?? now;
      _ensureStableIdForRow(r, entity: 'medication');
      r['createdAt'] = createdAt;
      r['updatedAt'] = now;
      r['localUpdatedAt'] = now;
      r['isDeleted'] = false;
      r['deletedAt'] = null;
      prepared.add(Map<String, dynamic>.from(r));
    }

    final existingMedications = _ilacKayitlari
        .where((r) => r['babyId'] == targetBabyId)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    _ilacKayitlari.removeWhere((r) => r['babyId'] == targetBabyId);
    _ilacKayitlari.addAll(
      _mergeActiveRowsWithTombstones(
        babyId: targetBabyId,
        existingAll: existingMedications,
        incomingActive: prepared,
        now: now,
      ),
    );

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
            'isDeleted': e['isDeleted'] == true,
            'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
          },
        )
        .toList();
    await _setLocalString('ilac_kayitlari', jsonEncode(data));
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'medication sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:medication-sync',
            ),
      sync: () => _syncActiveBabyMedicationsToCloud(babyId: targetBabyId),
    );
    final afterIds = _activeIdsFromRows(prepared);
    await _notifySharedActivityIfNeeded(
      babyId: targetBabyId,
      activityType: 'medication',
      createdNewRecord: afterIds.difference(beforeIds).isNotEmpty,
    );
  }

  static List<Map<String, dynamic>> _loadIlacDozKayitlari() {
    try {
      final data = _getLocalString('ilac_doz_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'id': (e['id'] ?? '').toString(),
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
              'isDeleted': e['isDeleted'] == true,
              'deletedAt': e['deletedAt'] != null
                  ? DateTime.parse(e['deletedAt'])
                  : null,
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
      if (_rowIsDeleted(r)) return false;
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
    final targetAt = givenAt ?? now;
    final normalizedDose = _normalizeDoseIndex(doseIndex);
    final normalizedStep = protocolStep?.trim().toLowerCase();
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final id = _medicationDoseSlotLogId(
      medicationId: medicationId,
      dayRef: targetAt,
      doseIndex: normalizedDose,
      scheduledTime: scheduledTime,
      protocolStep: normalizedStep,
    );
    _ilacDozKayitlari.insert(0, {
      'id': id,
      'babyId': targetBabyId,
      'medicationId': medicationId,
      'vaccineId': vaccineId,
      'givenAt': targetAt,
      'doseIndex': normalizedDose,
      'scheduledTime': scheduledTime,
      'scheduledTimeKey': _scheduledTimeKey(scheduledTime),
      'protocolStep': normalizedStep,
      'note': note,
      'updatedAt': now,
      'localUpdatedAt': now,
      'isDeleted': false,
      'deletedAt': null,
    });
    await _saveIlacDozKayitlari(
      rollbackBundle: rollbackBundle,
      isSharedBaby: isSharedBaby,
    );
    await _notifySharedActivityIfNeeded(
      babyId: _activeBabyId,
      activityType: 'medication_log',
      createdNewRecord: true,
    );
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
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final logId = _medicationDoseSlotLogId(
      medicationId: medicationId,
      dayRef: targetGivenAt,
      doseIndex: normalizedDose,
      scheduledTime: scheduledTime,
      protocolStep: normalizedStep,
    );

    final exists = _ilacDozKayitlari.any(
      (r) => r['babyId'] == targetBabyId && r['id'] == logId,
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
      'babyId': targetBabyId,
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
    await _saveIlacDozKayitlari(
      rollbackBundle: rollbackBundle,
      isSharedBaby: isSharedBaby,
    );
    await _notifySharedActivityIfNeeded(
      babyId: _activeBabyId,
      activityType: 'medication_log',
      createdNewRecord: true,
    );
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
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final matchingIndexes = <int>[];
    for (int i = 0; i < _ilacDozKayitlari.length; i++) {
      final r = _ilacDozKayitlari[i];
      if (r['babyId'] != targetBabyId) continue;
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
      await _saveIlacDozKayitlari(
        rollbackBundle: rollbackBundle,
        isSharedBaby: isSharedBaby,
      );
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
    final targetBabyId = _activeBabyId;
    final isSharedBaby = await _isSharedBabyUsingCloudTruth(targetBabyId);
    final rollbackBundle = isSharedBaby ? _currentCoreBundle() : null;
    final idx = _ilacDozKayitlari.indexWhere(
      (r) =>
          r['babyId'] == targetBabyId && r['id'] == doseId && !_rowIsDeleted(r),
    );
    if (idx == -1) return;
    _ilacDozKayitlari[idx] = _tombstoneRowFrom(
      _ilacDozKayitlari[idx],
      now: DateTime.now(),
    );
    await _saveIlacDozKayitlari(
      rollbackBundle: rollbackBundle,
      isSharedBaby: isSharedBaby,
    );
  }

  static Future<void> _saveIlacDozKayitlari({
    RepositoryDataBundle? rollbackBundle,
    bool? isSharedBaby,
  }) async {
    final targetBabyId = _activeBabyId;
    final now = DateTime.now();
    for (final row in _ilacDozKayitlari) {
      row['updatedAt'] = row['updatedAt'] ?? now;
      row['localUpdatedAt'] = row['localUpdatedAt'] ?? now;
      row['isDeleted'] = row['isDeleted'] == true;
      if (row['isDeleted'] != true) row['deletedAt'] = null;
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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );
    await _syncSharedCriticalOrBestEffort(
      babyId: targetBabyId,
      label: 'medication log sync',
      isSharedBaby: isSharedBaby,
      onSharedSyncFailure: rollbackBundle == null
          ? null
          : (error, st) => _restoreCoreBundle(
              rollbackBundle,
              reason: 'rollback:medication-log-sync',
            ),
      sync: () => _syncActiveBabyMedicationLogsToCloud(babyId: targetBabyId),
    );
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

  static bool isDailyTipReminderEnabled() => _dailyTipReminderEnabled;

  static Future<void> setDailyTipReminderEnabled(bool value) async {
    _dailyTipReminderEnabled = value;
    await _prefs!.setBool('daily_tip_reminder_enabled', value);
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

  static int getDailyTipReminderHour() => _dailyTipReminderHour;

  static int getDailyTipReminderMinute() => _dailyTipReminderMinute;

  static Future<void> setDailyTipReminderTime(int hour, int minute) async {
    _dailyTipReminderHour = hour;
    _dailyTipReminderMinute = minute;
    await _prefs!.setInt('daily_tip_reminder_time_h', hour);
    await _prefs!.setInt('daily_tip_reminder_time_m', minute);
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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _persistAnilarToLocalStore();

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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
              },
            )
            .toList(),
      ),
    );

    await _persistMilestonesToLocalStore();

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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
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
                'isDeleted': e['isDeleted'] == true,
                'deletedAt': (e['deletedAt'] as DateTime?)?.toIso8601String(),
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
  }
}
