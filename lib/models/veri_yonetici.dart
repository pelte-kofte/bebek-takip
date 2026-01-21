import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  static bool _darkMode = false;
  static bool _firstLaunch = true;
  static String _babyName = 'Sofia';
  static DateTime _birthDate = DateTime(2024, 9, 17);

  // Initialize - must be called before using any other methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Load all data into cache
    _mamaKayitlari = _loadMamaKayitlari();
    _kakaKayitlari = _loadKakaKayitlari();
    _uykuKayitlari = _loadUykuKayitlari();
    _anilar = _loadAnilar();
    _boyKiloKayitlari = _loadBoyKiloKayitlari();
    _milestones = _loadMilestones();
    _asiKayitlari = _loadAsiKayitlari();
    _darkMode = _prefs!.getBool('dark_mode') ?? false;
    _firstLaunch = _prefs!.getBool('first_launch') ?? true;
    _babyName = _prefs!.getString('baby_name') ?? 'Sofia';
    final birthDateStr = _prefs!.getString('birth_date');
    _birthDate = birthDateStr != null ? DateTime.parse(birthDateStr) : DateTime(2024, 9, 17);

    // Initialize TimerYonetici
    await TimerYonetici().init(_prefs!);
  }

  // Private load methods
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // MAMA - returns from cache (sync)
  static List<Map<String, dynamic>> getMamaKayitlari() {
    return List.from(_mamaKayitlari);
  }

  static Future<void> saveMamaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    // Update cache
    _mamaKayitlari = List.from(kayitlar);

    // Save to shared_preferences
    final data = kayitlar
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'miktar': e['miktar'] ?? 0,
            'tur': e['tur'] ?? '',
            'solDakika': e['solDakika'] ?? 0,
            'sagDakika': e['sagDakika'] ?? 0,
          },
        )
        .toList();
    await _prefs!.setString('mama_kayitlari', jsonEncode(data));
  }

  // KAKA
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getKakaKayitlari() {
    return List.from(_kakaKayitlari);
  }

  static Future<void> saveKakaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    // Update cache
    _kakaKayitlari = List.from(kayitlar);

    // Save to shared_preferences
    final data = kayitlar
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'tur': e['tur'],
          },
        )
        .toList();
    await _prefs!.setString('kaka_kayitlari', jsonEncode(data));
  }

  // UYKU
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getUykuKayitlari() {
    return List.from(_uykuKayitlari);
  }

  static Future<void> saveUykuKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    // Update cache
    _uykuKayitlari = List.from(kayitlar);

    // Save to shared_preferences
    final data = kayitlar
        .map(
          (e) => {
            'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
            'bitis': (e['bitis'] as DateTime).toIso8601String(),
            'sure': (e['sure'] as Duration).inMinutes,
          },
        )
        .toList();
    await _prefs!.setString('uyku_kayitlari', jsonEncode(data));
  }

  // ANILAR
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAnilar() {
    return List.from(_anilar);
  }

  static Future<void> saveAnilar(List<Map<String, dynamic>> anilar) async {
    // Update cache
    _anilar = List.from(anilar);

    // Save to shared_preferences
    final data = anilar
        .map(
          (e) => {
            'baslik': e['baslik'],
            'not': e['not'],
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'emoji': e['emoji'],
          },
        )
        .toList();
    await _prefs!.setString('anilar', jsonEncode(data));
  }

  // BOY/KİLO
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getBoyKiloKayitlari() {
    return List.from(_boyKiloKayitlari);
  }

  static Future<void> saveBoyKiloKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    // Update cache
    _boyKiloKayitlari = List.from(kayitlar);

    // Save to shared_preferences
    final data = kayitlar
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'boy': e['boy'],
            'kilo': e['kilo'],
            'basCevresi': e['basCevresi'],
          },
        )
        .toList();
    await _prefs!.setString('boykilo_kayitlari', jsonEncode(data));
  }

  // MILESTONES
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getMilestones() {
    return List.from(_milestones);
  }

  static Future<void> saveMilestones(
    List<Map<String, dynamic>> milestones,
  ) async {
    // Update cache
    _milestones = List.from(milestones);

    // Save to shared_preferences
    final data = milestones
        .map(
          (e) => {
            'id': e['id'],
            'title': e['title'],
            'date': (e['date'] as DateTime).toIso8601String(),
            'note': e['note'],
            'photoPath': e['photoPath'],
            'photoStyle': e['photoStyle'] ?? 'softIllustration',
          },
        )
        .toList();
    await _prefs!.setString('milestones', jsonEncode(data));
  }

  // ASILAR
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
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static List<Map<String, dynamic>> getAsiKayitlari() {
    return List.from(_asiKayitlari);
  }

  static Future<void> saveAsiKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    // Update cache
    _asiKayitlari = List.from(kayitlar);

    // Save to shared_preferences
    final data = kayitlar
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
          },
        )
        .toList();
    await _prefs!.setString('asi_kayitlari', jsonEncode(data));
  }

  // TEMA & SETTINGS
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

  // BABY NAME & BIRTH DATE
  static String getBabyName() {
    return _babyName;
  }

  static Future<void> setBabyName(String name) async {
    _babyName = name;
    await _prefs!.setString('baby_name', name);
  }

  static DateTime getBirthDate() {
    return _birthDate;
  }

  static Future<void> setBirthDate(DateTime date) async {
    _birthDate = date;
    await _prefs!.setString('birth_date', date.toIso8601String());
  }

  // VERİLERİ TEMİZLE
  static Future<void> verileriTemizle() async {
    _mamaKayitlari.clear();
    _kakaKayitlari.clear();
    _uykuKayitlari.clear();
    _anilar.clear();
    _boyKiloKayitlari.clear();
    _milestones.clear();
    _asiKayitlari.clear();

    await _prefs!.remove('mama_kayitlari');
    await _prefs!.remove('kaka_kayitlari');
    await _prefs!.remove('uyku_kayitlari');
    await _prefs!.remove('anilar');
    await _prefs!.remove('boykilo_kayitlari');
    await _prefs!.remove('milestones');
    await _prefs!.remove('asi_kayitlari');
  }
}
