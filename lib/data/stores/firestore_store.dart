import '../repositories/data_repository.dart';
import '../repositories/firestore_data_repository.dart';
import '../../models/baby.dart';

class FirestoreStore {
  FirestoreStore({DataRepository? repository})
    : _repository = repository ?? FirestoreDataRepository();

  final DataRepository _repository;

  Future<RepositoryDataBundle> fetchAll(String uid) =>
      _repository.fetchAllUserData(uid);

  Future<void> replaceBabies(String uid, List<Baby> babies) =>
      _repository.replaceBabies(uid, babies);

  Future<void> replaceRecordsForBaby(
    String uid, {
    required String babyId,
    required Set<String> types,
    required List<Map<String, dynamic>> records,
  }) => _repository.replaceRecordsForBaby(
    uid,
    babyId: babyId,
    types: types,
    records: records,
  );

  Future<void> replaceMedicationsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> medications,
  }) => _repository.replaceMedicationsForBaby(
    uid,
    babyId: babyId,
    medications: medications,
  );

  Future<void> replaceMedicationLogsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> logs,
  }) =>
      _repository.replaceMedicationLogsForBaby(uid, babyId: babyId, logs: logs);

  Future<void> replaceMemoriesForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> memories,
  }) => _repository.replaceMemoriesForBaby(
    uid,
    babyId: babyId,
    memories: memories,
  );

  Future<void> deleteBabyData(String uid, {required String babyId}) =>
      _repository.deleteBabyData(uid, babyId: babyId);

  Future<void> clearUserSubtree(String uid) =>
      _repository.clearUserSubtree(uid);
}
