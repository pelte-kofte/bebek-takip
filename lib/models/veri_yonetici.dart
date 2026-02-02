import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'baby.dart';
import 'timer_yonetici.dart';

class VeriYonetici {
  // Singleton instance
  static SharedPreferences? _prefs;

  // In-memory cache
  static List<Map<String, dynamic>> _mamaKayitlari = [];
  static List<Map<String, dynamic>> _kakaKayitlari = [];
  static List<Map<String, dynamic>> _uykuKayitlari = [];
  static List<Map<String, dynamic>> _anilar = [];
  static List<Map<String, dynamic>> _boyKiloKayitlari = [];
  static List<Map<String, dynamic>> _milestones = [];
  static List<Map<String, dynamic>> _asiKayitlari = [];
  static final ValueNotifier<int> _vaccineVersion = ValueNotifier<int>(0);
  static bool _darkMode = false;
  static bool _firstLaunch = true;
  static String _babyName = 'Sofia';
  static DateTime _birthDate = DateTime(2024, 9, 17);
  static String? _babyPhotoPath;

  // Multi-baby support
  static List<Baby> _babies = [];
  static String _activeBabyId = '';
  static const String _migrationKey = 'multi_baby_migrated';

  // Initialize - must be called before using any other methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Run one-time migration if needed
    final migrated = _prefs!.getBool(_migrationKey) ?? false;
    if (!migrated) {
      await _migrateToMultiBaby();
    }

    // Load babies and resolve active baby
    _babies = _loadBabies();
    _activeBabyId = _prefs!.getString('active_baby_id') ?? '';

    if (_babies.isEmpty || !_babies.any((b) => b.id == _activeBabyId)) {
      if (_babies.isNotEmpty) {
        _activeBabyId = _babies.first.id;
        await _prefs!.setString('active_baby_id', _activeBabyId);
      }
    }

    // Load all data into cache (babyId included in each record)
    _mamaKayitlari = _loadMamaKayitlari();
    _kakaKayitlari = _loadKakaKayitlari();
    _uykuKayitlari = _loadUykuKayitlari();
    _anilar = _loadAnilar();
    _boyKiloKayitlari = _loadBoyKiloKayitlari();
    _milestones = _loadMilestones();
    _asiKayitlari = _loadAsiKayitlari();

    // Settings
    _darkMode = _prefs!.getBool('dark_mode') ?? false;
    _firstLaunch = _prefs!.getBool('first_launch') ?? true;

    // Sync cached baby fields from active baby
    if (_babies.isNotEmpty && _babies.any((b) => b.id == _activeBabyId)) {
      final baby = getActiveBaby();
      _babyName = baby.name;
      _birthDate = baby.birthDate;
      _babyPhotoPath = baby.photoPath;
    } else {
      _babyName = _prefs!.getString('baby_name') ?? 'Sofia';
      _babyPhotoPath = _prefs!.getString('baby_photo_path');
      final birthDateStr = _prefs!.getString('birth_date');
      _birthDate = birthDateStr != null
          ? DateTime.parse(birthDateStr)
          : DateTime(2024, 9, 17);
    }

    // Initialize TimerYonetici
    await TimerYonetici().init(_prefs!);
  }

  // ============ MIGRATION ============

  static Future<void> _migrateToMultiBaby() async {
    // Check if babies key already exists (partial migration)
    final existingBabiesData = _prefs!.getString('babies');
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

      final existingName = _prefs!.getString('baby_name') ?? 'Sofia';
      final birthDateStr = _prefs!.getString('birth_date');
      final existingBirthDate = birthDateStr != null
          ? DateTime.parse(birthDateStr)
          : DateTime(2024, 9, 17);
      final existingPhoto = _prefs!.getString('baby_photo_path');

      final defaultBaby = Baby(
        id: defaultBabyId,
        name: existingName,
        birthDate: existingBirthDate,
        photoPath: existingPhoto,
      );

      await _prefs!.setString('babies', jsonEncode([defaultBaby.toJson()]));
    }

    await _prefs!.setString('active_baby_id', defaultBabyId);

    // Tag all existing records with the default baby ID
    await _tagExistingRecords('mama_kayitlari', defaultBabyId);
    await _tagExistingRecords('kaka_kayitlari', defaultBabyId);
    await _tagExistingRecords('uyku_kayitlari', defaultBabyId);
    await _tagExistingRecords('anilar', defaultBabyId);
    await _tagExistingRecords('boykilo_kayitlari', defaultBabyId);
    await _tagExistingRecords('milestones', defaultBabyId);
    await _tagExistingRecords('asi_kayitlari', defaultBabyId);

    await _prefs!.setBool(_migrationKey, true);
  }

  static Future<void> _tagExistingRecords(String key, String babyId) async {
    final data = _prefs!.getString(key);
    if (data == null || data.isEmpty) return;
    try {
      final list = jsonDecode(data) as List;
      final tagged = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['babyId'] = babyId;
        return map;
      }).toList();
      await _prefs!.setString(key, jsonEncode(tagged));
    } catch (_) {
      // Corrupt data; _load* methods handle errors
    }
  }

  // ============ BABY MANAGEMENT ============

  static List<Baby> _loadBabies() {
    try {
      final data = _prefs!.getString('babies');
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
    await _prefs!.setString('babies', jsonEncode(data));
  }

  static List<Baby> getBabies() {
    return List.from(_babies);
  }

  static Baby getActiveBaby() {
    return _babies.firstWhere((b) => b.id == _activeBabyId);
  }

  static String getActiveBabyId() {
    return _activeBabyId;
  }

  static Future<void> setActiveBaby(String babyId) async {
    if (_babies.any((b) => b.id == babyId)) {
      _activeBabyId = babyId;
      await _prefs!.setString('active_baby_id', babyId);
      final baby = getActiveBaby();
      _babyName = baby.name;
      _birthDate = baby.birthDate;
      _babyPhotoPath = baby.photoPath;
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

    if (_activeBabyId == babyId) {
      await setActiveBaby(_babies.first.id);
    }

    await _saveBabies();
    await _saveAllCollections();
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
    if (babyId == _activeBabyId) {
      _babyName = _babies[index].name;
      _birthDate = _babies[index].birthDate;
      _babyPhotoPath = _babies[index].photoPath;
    }
  }

  // ============ MAMA ============

  static List<Map<String, dynamic>> _loadMamaKayitlari() {
    try {
      final data = _prefs!.getString('mama_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'miktar': e['miktar'] ?? 0,
              'tur': e['tur'] ?? '',
              'solDakika': e['solDakika'] ?? 0,
              'sagDakika': e['sagDakika'] ?? 0,
              'babyId': e['babyId'] ?? _activeBabyId,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMamaKayitlari() {
    return _mamaKayitlari
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static Future<void> saveMamaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
    }

    _mamaKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _mamaKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _mamaKayitlari
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'miktar': e['miktar'] ?? 0,
            'tur': e['tur'] ?? '',
            'solDakika': e['solDakika'] ?? 0,
            'sagDakika': e['sagDakika'] ?? 0,
            'babyId': e['babyId'],
          },
        )
        .toList();
    await _prefs!.setString('mama_kayitlari', jsonEncode(data));
  }

  // ============ KAKA ============

  static List<Map<String, dynamic>> _loadKakaKayitlari() {
    try {
      final data = _prefs!.getString('kaka_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'tur': e['tur'],
              'babyId': e['babyId'] ?? _activeBabyId,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getKakaKayitlari() {
    return _kakaKayitlari
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static Future<void> saveKakaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
    }

    _kakaKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _kakaKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _kakaKayitlari
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'tur': e['tur'],
            'babyId': e['babyId'],
          },
        )
        .toList();
    await _prefs!.setString('kaka_kayitlari', jsonEncode(data));
  }

  // ============ UYKU ============

  static List<Map<String, dynamic>> _loadUykuKayitlari() {
    try {
      final data = _prefs!.getString('uyku_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'baslangic': DateTime.parse(e['baslangic']),
              'bitis': DateTime.parse(e['bitis']),
              'sure': Duration(minutes: e['sure']),
              'babyId': e['babyId'] ?? _activeBabyId,
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getUykuKayitlari() {
    return _uykuKayitlari
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static Future<void> saveUykuKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
    }

    _uykuKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _uykuKayitlari.addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _uykuKayitlari
        .map(
          (e) => {
            'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
            'bitis': (e['bitis'] as DateTime).toIso8601String(),
            'sure': (e['sure'] as Duration).inMinutes,
            'babyId': e['babyId'],
          },
        )
        .toList();
    await _prefs!.setString('uyku_kayitlari', jsonEncode(data));
  }

  // ============ ANILAR ============

  static List<Map<String, dynamic>> _loadAnilar() {
    try {
      final data = _prefs!.getString('anilar');
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAnilar() {
    return _anilar
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static Future<void> saveAnilar(List<Map<String, dynamic>> anilar) async {
    for (final r in anilar) {
      r['babyId'] = _activeBabyId;
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
          },
        )
        .toList();
    await _prefs!.setString('anilar', jsonEncode(data));
  }

  // ============ BOY/KILO ============

  static List<Map<String, dynamic>> _loadBoyKiloKayitlari() {
    try {
      final data = _prefs!.getString('boykilo_kayitlari');
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'boy': e['boy'],
              'kilo': e['kilo'],
              'basCevresi': e['basCevresi'],
              'babyId': e['babyId'] ?? _activeBabyId,
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
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
    }

    _boyKiloKayitlari.removeWhere((r) => r['babyId'] == _activeBabyId);
    _boyKiloKayitlari
        .addAll(kayitlar.map((e) => Map<String, dynamic>.from(e)));

    final data = _boyKiloKayitlari
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'boy': e['boy'],
            'kilo': e['kilo'],
            'basCevresi': e['basCevresi'],
            'babyId': e['babyId'],
          },
        )
        .toList();
    await _prefs!.setString('boykilo_kayitlari', jsonEncode(data));
  }

  // ============ MILESTONES ============

  static List<Map<String, dynamic>> _loadMilestones() {
    try {
      final data = _prefs!.getString('milestones');
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMilestones() {
    return _milestones
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static Future<void> saveMilestones(
    List<Map<String, dynamic>> milestones,
  ) async {
    for (final r in milestones) {
      r['babyId'] = _activeBabyId;
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
          },
        )
        .toList();
    await _prefs!.setString('milestones', jsonEncode(data));
  }

  // ============ ASILAR ============

  static List<Map<String, dynamic>> _loadAsiKayitlari() {
    try {
      final data = _prefs!.getString('asi_kayitlari');
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAsiKayitlari() {
    return _asiKayitlari
        .where((r) => r['babyId'] == _activeBabyId)
        .toList();
  }

  static ValueNotifier<int> get vaccineNotifier => _vaccineVersion;

  static Future<void> saveAsiKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    for (final r in kayitlar) {
      r['babyId'] = _activeBabyId;
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
          },
        )
        .toList();
    await _prefs!.setString('asi_kayitlari', jsonEncode(data));
    _vaccineVersion.value++;
  }

  // ============ TEMA & SETTINGS ============

  static bool isFirstLaunch() {
    return _firstLaunch;
  }

  static Future<void> setFirstLaunchComplete() async {
    _firstLaunch = false;
    await _prefs!.setBool('first_launch', false);
  }

  static bool isDarkMode() {
    return _darkMode;
  }

  static Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _prefs!.setBool('dark_mode', value);
  }

  // ============ BABY NAME & BIRTH DATE ============

  static String getBabyName() {
    return _babyName;
  }

  static Future<void> setBabyName(String name) async {
    _babyName = name;
    await _prefs!.setString('baby_name', name);
    await updateBaby(_activeBabyId, name: name);
  }

  static DateTime getBirthDate() {
    return _birthDate;
  }

  static Future<void> setBirthDate(DateTime date) async {
    _birthDate = date;
    await _prefs!.setString('birth_date', date.toIso8601String());
    await updateBaby(_activeBabyId, birthDate: date);
  }

  static String? getBabyPhotoPath() {
    return _babyPhotoPath;
  }

  static Future<void> setBabyPhotoPath(String? path) async {
    _babyPhotoPath = path;
    if (path != null) {
      await _prefs!.setString('baby_photo_path', path);
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

    await _saveAllCollections();
  }

  // ============ HELPERS ============

  static Future<void> _saveAllCollections() async {
    await _prefs!.setString(
      'mama_kayitlari',
      jsonEncode(
        _mamaKayitlari
            .map((e) => {
                  'tarih': (e['tarih'] as DateTime).toIso8601String(),
                  'miktar': e['miktar'] ?? 0,
                  'tur': e['tur'] ?? '',
                  'solDakika': e['solDakika'] ?? 0,
                  'sagDakika': e['sagDakika'] ?? 0,
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );

    await _prefs!.setString(
      'kaka_kayitlari',
      jsonEncode(
        _kakaKayitlari
            .map((e) => {
                  'tarih': (e['tarih'] as DateTime).toIso8601String(),
                  'tur': e['tur'],
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );

    await _prefs!.setString(
      'uyku_kayitlari',
      jsonEncode(
        _uykuKayitlari
            .map((e) => {
                  'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
                  'bitis': (e['bitis'] as DateTime).toIso8601String(),
                  'sure': (e['sure'] as Duration).inMinutes,
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );

    await _prefs!.setString(
      'anilar',
      jsonEncode(
        _anilar
            .map((e) => {
                  'baslik': e['baslik'],
                  'not': e['not'],
                  'tarih': (e['tarih'] as DateTime).toIso8601String(),
                  'emoji': e['emoji'],
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );

    await _prefs!.setString(
      'boykilo_kayitlari',
      jsonEncode(
        _boyKiloKayitlari
            .map((e) => {
                  'tarih': (e['tarih'] as DateTime).toIso8601String(),
                  'boy': e['boy'],
                  'kilo': e['kilo'],
                  'basCevresi': e['basCevresi'],
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );

    await _prefs!.setString(
      'milestones',
      jsonEncode(
        _milestones
            .map((e) => {
                  'id': e['id'],
                  'title': e['title'],
                  'date': (e['date'] as DateTime).toIso8601String(),
                  'note': e['note'],
                  'photoPath': e['photoPath'],
                  'photoStyle': e['photoStyle'] ?? 'softIllustration',
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );

    await _prefs!.setString(
      'asi_kayitlari',
      jsonEncode(
        _asiKayitlari
            .map((e) => {
                  'id': e['id'],
                  'ad': e['ad'],
                  'donem': e['donem'],
                  'tarih': e['tarih'] != null
                      ? (e['tarih'] as DateTime).toIso8601String()
                      : null,
                  'durum': e['durum'] ?? 'bekleniyor',
                  'notlar': e['notlar'] ?? '',
                  'babyId': e['babyId'],
                })
            .toList(),
      ),
    );
  }
}
