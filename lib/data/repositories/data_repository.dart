import '../../models/baby.dart';

class RepositoryDataBundle {
  final List<Baby> babies;
  final List<Map<String, dynamic>> mamaKayitlari;
  final List<Map<String, dynamic>> kakaKayitlari;
  final List<Map<String, dynamic>> uykuKayitlari;
  final List<Map<String, dynamic>> boyKiloKayitlari;
  final List<Map<String, dynamic>> asiKayitlari;
  final List<Map<String, dynamic>> milestones;
  final List<Map<String, dynamic>> anilar;
  final List<Map<String, dynamic>> ilacKayitlari;
  final List<Map<String, dynamic>> ilacDozKayitlari;

  const RepositoryDataBundle({
    required this.babies,
    required this.mamaKayitlari,
    required this.kakaKayitlari,
    required this.uykuKayitlari,
    required this.boyKiloKayitlari,
    required this.asiKayitlari,
    required this.milestones,
    required this.anilar,
    required this.ilacKayitlari,
    required this.ilacDozKayitlari,
  });

  bool get hasAnyData {
    return babies.isNotEmpty ||
        mamaKayitlari.isNotEmpty ||
        kakaKayitlari.isNotEmpty ||
        uykuKayitlari.isNotEmpty ||
        boyKiloKayitlari.isNotEmpty ||
        asiKayitlari.isNotEmpty ||
        milestones.isNotEmpty ||
        anilar.isNotEmpty ||
        ilacKayitlari.isNotEmpty ||
        ilacDozKayitlari.isNotEmpty;
  }
}

abstract class DataRepository {
  Future<RepositoryDataBundle> fetchAllUserData(String uid);

  Future<void> replaceBabies(String uid, List<Baby> babies);

  Future<void> replaceRecordsForBaby(
    String uid, {
    required String babyId,
    required Set<String> types,
    required List<Map<String, dynamic>> records,
  });

  Future<void> replaceMedicationsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> medications,
  });

  Future<void> replaceMedicationLogsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> logs,
  });

  Future<void> replaceMemoriesForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> memories,
  });

  Future<void> deleteBabyData(String uid, {required String babyId});

  Future<void> clearUserSubtree(String uid);
}
