import 'package:flutter_test/flutter_test.dart';

import 'package:bebek_takip/data/local/local_store.dart';
import 'package:bebek_takip/data/repositories/data_repository.dart';
import 'package:bebek_takip/data/stores/firestore_store.dart';
import 'package:bebek_takip/models/baby.dart';
import 'package:bebek_takip/services/data_sync_service.dart';

class _FakeLocalStore implements LocalStore {
  final Map<String, Object?> _data = <String, Object?>{};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Future<bool> remove(String key) async => _data.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }
}

class _FakeRepository implements DataRepository {
  @override
  Future<void> clearUserSubtree(String uid) async {}

  @override
  Future<void> deleteBabyData(String uid, {required String babyId}) async {}

  @override
  Future<RepositoryDataBundle> fetchAllUserData(String uid) async {
    return const RepositoryDataBundle(
      babies: <Baby>[],
      mamaKayitlari: <Map<String, dynamic>>[],
      kakaKayitlari: <Map<String, dynamic>>[],
      uykuKayitlari: <Map<String, dynamic>>[],
      boyKiloKayitlari: <Map<String, dynamic>>[],
      asiKayitlari: <Map<String, dynamic>>[],
      milestones: <Map<String, dynamic>>[],
      anilar: <Map<String, dynamic>>[],
      ilacKayitlari: <Map<String, dynamic>>[],
      ilacDozKayitlari: <Map<String, dynamic>>[],
    );
  }

  @override
  Future<void> replaceBabies(String uid, List<Baby> babies) async {}

  @override
  Future<void> replaceMedicationLogsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> logs,
  }) async {}

  @override
  Future<void> replaceMedicationsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> medications,
  }) async {}

  @override
  Future<void> replaceMemoriesForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> memories,
  }) async {}

  @override
  Future<void> replaceRecordsForBaby(
    String uid, {
    required String babyId,
    required Set<String> types,
    required List<Map<String, dynamic>> records,
  }) async {}
}

void main() {
  final service = DataSyncService(
    localStore: _FakeLocalStore(),
    firestoreStore: FirestoreStore(repository: _FakeRepository()),
  );

  test(
    'same offline record and remote copy merge into one via natural key',
    () {
      final local = RepositoryDataBundle(
        babies: const <Baby>[],
        mamaKayitlari: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'local_a',
            'babyId': 'baby_1',
            'tur': 'formula',
            'miktar': 90,
            'tarih': DateTime.parse('2026-03-01T10:00:00Z'),
            'updatedAt': DateTime.parse('2026-03-01T10:01:00Z'),
            'localUpdatedAt': DateTime.parse('2026-03-01T10:01:00Z'),
          },
        ],
        kakaKayitlari: const <Map<String, dynamic>>[],
        uykuKayitlari: const <Map<String, dynamic>>[],
        boyKiloKayitlari: const <Map<String, dynamic>>[],
        asiKayitlari: const <Map<String, dynamic>>[],
        milestones: const <Map<String, dynamic>>[],
        anilar: const <Map<String, dynamic>>[],
        ilacKayitlari: const <Map<String, dynamic>>[],
        ilacDozKayitlari: const <Map<String, dynamic>>[],
      );
      final remote = RepositoryDataBundle(
        babies: const <Baby>[],
        mamaKayitlari: <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'remote_b',
            'babyId': 'baby_1',
            'type': 'feeding',
            'tur': 'formula',
            'miktar': 90,
            'tarih': DateTime.parse('2026-03-01T10:00:00Z'),
            'updatedAt': DateTime.parse('2026-03-01T10:02:00Z'),
            'localUpdatedAt': DateTime.parse('2026-03-01T10:02:00Z'),
          },
        ],
        kakaKayitlari: const <Map<String, dynamic>>[],
        uykuKayitlari: const <Map<String, dynamic>>[],
        boyKiloKayitlari: const <Map<String, dynamic>>[],
        asiKayitlari: const <Map<String, dynamic>>[],
        milestones: const <Map<String, dynamic>>[],
        anilar: const <Map<String, dynamic>>[],
        ilacKayitlari: const <Map<String, dynamic>>[],
        ilacDozKayitlari: const <Map<String, dynamic>>[],
      );

      final merged = service.mergeCoreData(local: local, remote: remote);
      expect(merged.mamaKayitlari.length, 1);
    },
  );

  test('anonymous local record keeps same id after merge on login', () {
    const stableId = 'stable_local_id_1';
    final local = RepositoryDataBundle(
      babies: const <Baby>[],
      mamaKayitlari: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': stableId,
          'babyId': 'baby_1',
          'tur': 'anne',
          'miktar': 0,
          'tarih': DateTime.parse('2026-03-01T09:00:00Z'),
          'updatedAt': DateTime.parse('2026-03-01T09:01:00Z'),
          'localUpdatedAt': DateTime.parse('2026-03-01T09:01:00Z'),
        },
      ],
      kakaKayitlari: const <Map<String, dynamic>>[],
      uykuKayitlari: const <Map<String, dynamic>>[],
      boyKiloKayitlari: const <Map<String, dynamic>>[],
      asiKayitlari: const <Map<String, dynamic>>[],
      milestones: const <Map<String, dynamic>>[],
      anilar: const <Map<String, dynamic>>[],
      ilacKayitlari: const <Map<String, dynamic>>[],
      ilacDozKayitlari: const <Map<String, dynamic>>[],
    );

    final remote = RepositoryDataBundle(
      babies: const <Baby>[],
      mamaKayitlari: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'different_remote_id',
          'babyId': 'baby_1',
          'type': 'nursing',
          'tur': 'anne',
          'miktar': 0,
          'tarih': DateTime.parse('2026-03-01T09:00:00Z'),
          'updatedAt': DateTime.parse('2026-03-01T08:59:00Z'),
          'localUpdatedAt': DateTime.parse('2026-03-01T08:59:00Z'),
        },
      ],
      kakaKayitlari: const <Map<String, dynamic>>[],
      uykuKayitlari: const <Map<String, dynamic>>[],
      boyKiloKayitlari: const <Map<String, dynamic>>[],
      asiKayitlari: const <Map<String, dynamic>>[],
      milestones: const <Map<String, dynamic>>[],
      anilar: const <Map<String, dynamic>>[],
      ilacKayitlari: const <Map<String, dynamic>>[],
      ilacDozKayitlari: const <Map<String, dynamic>>[],
    );

    final merged = service.mergeCoreData(local: local, remote: remote);
    expect(merged.mamaKayitlari.length, 1);
    expect(merged.mamaKayitlari.first['id'], stableId);
  });

  test('deleted local record does not reappear after pull + merge', () {
    const stableId = 'deleted_local_1';
    final local = RepositoryDataBundle(
      babies: const <Baby>[],
      mamaKayitlari: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': stableId,
          'babyId': 'baby_1',
          'tur': 'formula',
          'miktar': 60,
          'tarih': DateTime.parse('2026-03-01T07:00:00Z'),
          'isDeleted': true,
          'deletedAt': DateTime.parse('2026-03-01T07:05:00Z'),
          'updatedAt': DateTime.parse('2026-03-01T07:05:00Z'),
          'localUpdatedAt': DateTime.parse('2026-03-01T07:05:00Z'),
        },
      ],
      kakaKayitlari: const <Map<String, dynamic>>[],
      uykuKayitlari: const <Map<String, dynamic>>[],
      boyKiloKayitlari: const <Map<String, dynamic>>[],
      asiKayitlari: const <Map<String, dynamic>>[],
      milestones: const <Map<String, dynamic>>[],
      anilar: const <Map<String, dynamic>>[],
      ilacKayitlari: const <Map<String, dynamic>>[],
      ilacDozKayitlari: const <Map<String, dynamic>>[],
    );

    final remote = RepositoryDataBundle(
      babies: const <Baby>[],
      mamaKayitlari: <Map<String, dynamic>>[
        <String, dynamic>{
          'id': stableId,
          'babyId': 'baby_1',
          'type': 'feeding',
          'tur': 'formula',
          'miktar': 60,
          'tarih': DateTime.parse('2026-03-01T07:00:00Z'),
          'isDeleted': false,
          'updatedAt': DateTime.parse('2026-03-01T07:01:00Z'),
          'localUpdatedAt': DateTime.parse('2026-03-01T07:01:00Z'),
        },
      ],
      kakaKayitlari: const <Map<String, dynamic>>[],
      uykuKayitlari: const <Map<String, dynamic>>[],
      boyKiloKayitlari: const <Map<String, dynamic>>[],
      asiKayitlari: const <Map<String, dynamic>>[],
      milestones: const <Map<String, dynamic>>[],
      anilar: const <Map<String, dynamic>>[],
      ilacKayitlari: const <Map<String, dynamic>>[],
      ilacDozKayitlari: const <Map<String, dynamic>>[],
    );

    final merged = service.mergeCoreData(local: local, remote: remote);
    expect(merged.mamaKayitlari.length, 1);
    expect(merged.mamaKayitlari.first['isDeleted'], isTrue);
    final visible = merged.mamaKayitlari
        .where((row) => row['isDeleted'] != true)
        .toList();
    expect(visible, isEmpty);
  });
}
