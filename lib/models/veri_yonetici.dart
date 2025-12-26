import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class VeriYonetici {
  // MAMA
  static List<Map<String, dynamic>> getMamaKayitlari() {
    try {
      final data = html.window.localStorage['mama_kayitlari'];
      if (data == null || data.isEmpty) return [];
      final list = jsonDecode(data) as List;
      return list
          .map(
            (e) => Map<String, dynamic>.from({
              'tarih': DateTime.parse(e['tarih']),
              'miktar': e['miktar'],
              'tur': e['tur'],
            }),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveMamaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final data = kayitlar
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'miktar': e['miktar'],
            'tur': e['tur'],
          },
        )
        .toList();
    html.window.localStorage['mama_kayitlari'] = jsonEncode(data);
  }

  // KAKA
  static List<Map<String, dynamic>> getKakaKayitlari() {
    try {
      final data = html.window.localStorage['kaka_kayitlari'];
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

  static Future<void> saveKakaKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final data = kayitlar
        .map(
          (e) => {
            'tarih': (e['tarih'] as DateTime).toIso8601String(),
            'tur': e['tur'],
          },
        )
        .toList();
    html.window.localStorage['kaka_kayitlari'] = jsonEncode(data);
  }

  // UYKU
  static List<Map<String, dynamic>> getUykuKayitlari() {
    try {
      final data = html.window.localStorage['uyku_kayitlari'];
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

  static Future<void> saveUykuKayitlari(
    List<Map<String, dynamic>> kayitlar,
  ) async {
    final data = kayitlar
        .map(
          (e) => {
            'baslangic': (e['baslangic'] as DateTime).toIso8601String(),
            'bitis': (e['bitis'] as DateTime).toIso8601String(),
            'sure': (e['sure'] as Duration).inMinutes,
          },
        )
        .toList();
    html.window.localStorage['uyku_kayitlari'] = jsonEncode(data);
  }

  // ANILAR
  static List<Map<String, dynamic>> getAnilar() {
    try {
      final data = html.window.localStorage['anilar'];
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

  static Future<void> saveAnilar(List<Map<String, dynamic>> anilar) async {
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
    html.window.localStorage['anilar'] = jsonEncode(data);
  }
}
