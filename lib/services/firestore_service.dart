import '../data/repositories/data_repository.dart';
import '../data/repositories/firestore_data_repository.dart';
import '../models/baby.dart';

class FirestoreService {
  FirestoreService({DataRepository? repository})
    : _repository = repository ?? FirestoreDataRepository();

  final DataRepository _repository;

  Future<RepositoryDataBundle> fetchUserBundle(String uid) {
    return _repository.fetchAllUserData(uid);
  }

  Future<void> replaceBabies(String uid, List<Baby> babies) {
    return _repository.replaceBabies(uid, babies);
  }

  Future<void> replaceRecordsForBaby(
    String uid, {
    required String babyId,
    required Set<String> types,
    required List<Map<String, dynamic>> records,
  }) {
    return _repository.replaceRecordsForBaby(
      uid,
      babyId: babyId,
      types: types,
      records: records,
    );
  }

  Future<void> replaceMedicationsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> medications,
  }) {
    return _repository.replaceMedicationsForBaby(
      uid,
      babyId: babyId,
      medications: medications,
    );
  }

  Future<void> replaceMedicationLogsForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> logs,
  }) {
    return _repository.replaceMedicationLogsForBaby(
      uid,
      babyId: babyId,
      logs: logs,
    );
  }

  Future<void> replaceMemoriesForBaby(
    String uid, {
    required String babyId,
    required List<Map<String, dynamic>> memories,
  }) {
    return _repository.replaceMemoriesForBaby(
      uid,
      babyId: babyId,
      memories: memories,
    );
  }

  Future<void> deleteBabyData(String uid, {required String babyId}) {
    return _repository.deleteBabyData(uid, babyId: babyId);
  }

  Future<void> clearUserSubtree(String uid) {
    return _repository.clearUserSubtree(uid);
  }
}
