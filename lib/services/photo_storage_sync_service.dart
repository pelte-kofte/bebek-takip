import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/baby.dart';

class PhotoStorageSyncResult {
  final bool babiesChanged;
  final bool memoriesChanged;
  final bool memoriesUploaded;
  final Set<String> uploadedMemoryBabyIds;

  const PhotoStorageSyncResult({
    required this.babiesChanged,
    required this.memoriesChanged,
    required this.memoriesUploaded,
    required this.uploadedMemoryBabyIds,
  });
}

class PhotoStorageSyncService {
  PhotoStorageSyncService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<PhotoStorageSyncResult> syncUserPhotos({
    required String uid,
    required List<Baby> babies,
    required List<Map<String, dynamic>> milestones,
    required List<Map<String, dynamic>> memories,
    required void Function(String message) log,
  }) async {
    if (uid.isEmpty || kIsWeb) {
      return const PhotoStorageSyncResult(
        babiesChanged: false,
        memoriesChanged: false,
        memoriesUploaded: false,
        uploadedMemoryBabyIds: <String>{},
      );
    }

    bool babiesChanged = false;
    bool memoriesChanged = false;
    bool memoriesUploaded = false;
    final uploadedMemoryBabyIds = <String>{};

    for (final baby in babies) {
      final changed = await _syncBabyPhoto(uid: uid, baby: baby, log: log);
      babiesChanged = babiesChanged || changed;
    }

    for (final row in milestones) {
      final outcome = await _syncMemoryPhoto(uid: uid, row: row, log: log);
      memoriesChanged = memoriesChanged || outcome.changed;
      memoriesUploaded = memoriesUploaded || outcome.uploaded;
      if (outcome.uploaded && outcome.babyId.isNotEmpty) {
        uploadedMemoryBabyIds.add(outcome.babyId);
      }
    }

    for (final row in memories) {
      final outcome = await _syncMemoryPhoto(uid: uid, row: row, log: log);
      memoriesChanged = memoriesChanged || outcome.changed;
      memoriesUploaded = memoriesUploaded || outcome.uploaded;
      if (outcome.uploaded && outcome.babyId.isNotEmpty) {
        uploadedMemoryBabyIds.add(outcome.babyId);
      }
    }

    return PhotoStorageSyncResult(
      babiesChanged: babiesChanged,
      memoriesChanged: memoriesChanged,
      memoriesUploaded: memoriesUploaded,
      uploadedMemoryBabyIds: uploadedMemoryBabyIds,
    );
  }

  Future<bool> _syncBabyPhoto({
    required String uid,
    required Baby baby,
    required void Function(String message) log,
  }) async {
    final localPath = (baby.photoPath ?? '').trim();
    final storagePath = (baby.photoStoragePath ?? '').trim();
    bool changed = false;

    if (storagePath.isEmpty &&
        localPath.isNotEmpty &&
        await _fileExists(localPath)) {
      final ext = _normalizedExt(localPath);
      final resolvedStoragePath = 'users/$uid/babies/${baby.id}/profile$ext';
      final file = File(localPath);
      final size = await file.length();

      try {
        log(
          'photo upload start type=baby babyId=${baby.id} size=$size storagePath=$resolvedStoragePath',
        );
        final ref = _storage.ref(resolvedStoragePath);
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        baby.photoStoragePath = resolvedStoragePath;
        baby.photoUrl = downloadUrl;
        changed = true;
        log(
          'photo upload success type=baby babyId=${baby.id} size=$size storagePath=$resolvedStoragePath',
        );
      } catch (e) {
        log(
          'photo upload fail type=baby babyId=${baby.id} size=$size storagePath=$resolvedStoragePath error=$e',
        );
      }
    }

    final currentStoragePath = (baby.photoStoragePath ?? '').trim();
    if (currentStoragePath.isNotEmpty &&
        (localPath.isEmpty || !await _fileExists(localPath))) {
      final ext = _storageExt(currentStoragePath);
      final target = await _localPhotoFile(
        subDir: 'babies/${baby.id}',
        fileName: 'profile$ext',
      );
      try {
        log(
          'photo download start type=baby babyId=${baby.id} storagePath=$currentStoragePath',
        );
        await _storage.ref(currentStoragePath).writeToFile(target);
        baby.photoPath = target.path;
        changed = true;
        log(
          'photo download success type=baby babyId=${baby.id} storagePath=$currentStoragePath localPath=${target.path}',
        );
      } catch (e) {
        log(
          'photo download fail type=baby babyId=${baby.id} storagePath=$currentStoragePath error=$e',
        );
      }
    }

    return changed;
  }

  Future<_MemoryOutcome> _syncMemoryPhoto({
    required String uid,
    required Map<String, dynamic> row,
    required void Function(String message) log,
  }) async {
    final memoryId = (row['id'] ?? '').toString();
    if (memoryId.isEmpty) {
      return const _MemoryOutcome(changed: false, uploaded: false, babyId: '');
    }

    final babyId = (row['babyId'] ?? '').toString();
    final localPath = (row['photoPath'] ?? '').toString().trim();
    final storagePath = (row['photoStoragePath'] ?? '').toString().trim();
    bool changed = false;
    bool uploaded = false;

    if (storagePath.isEmpty &&
        localPath.isNotEmpty &&
        await _fileExists(localPath)) {
      final ext = _normalizedExt(localPath);
      final resolvedStoragePath = 'users/$uid/memories/$memoryId/photo$ext';
      final file = File(localPath);
      final size = await file.length();

      try {
        log(
          'photo upload start type=memory memoryId=$memoryId babyId=$babyId size=$size storagePath=$resolvedStoragePath',
        );
        final ref = _storage.ref(resolvedStoragePath);
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        row['photoStoragePath'] = resolvedStoragePath;
        row['photoUrl'] = downloadUrl;
        changed = true;
        uploaded = true;
        log(
          'photo upload success type=memory memoryId=$memoryId babyId=$babyId size=$size storagePath=$resolvedStoragePath',
        );
      } catch (e) {
        log(
          'photo upload fail type=memory memoryId=$memoryId babyId=$babyId size=$size storagePath=$resolvedStoragePath error=$e',
        );
      }
    }

    final currentStoragePath = (row['photoStoragePath'] ?? '')
        .toString()
        .trim();
    if (currentStoragePath.isNotEmpty &&
        (localPath.isEmpty || !await _fileExists(localPath))) {
      final ext = _storageExt(currentStoragePath);
      final target = await _localPhotoFile(
        subDir: 'memories/$memoryId',
        fileName: 'photo$ext',
      );
      try {
        log(
          'photo download start type=memory memoryId=$memoryId babyId=$babyId storagePath=$currentStoragePath',
        );
        await _storage.ref(currentStoragePath).writeToFile(target);
        row['photoPath'] = target.path;
        changed = true;
        log(
          'photo download success type=memory memoryId=$memoryId babyId=$babyId storagePath=$currentStoragePath localPath=${target.path}',
        );
      } catch (e) {
        log(
          'photo download fail type=memory memoryId=$memoryId babyId=$babyId storagePath=$currentStoragePath error=$e',
        );
      }
    }

    return _MemoryOutcome(changed: changed, uploaded: uploaded, babyId: babyId);
  }

  Future<bool> _fileExists(String path) async {
    if (path.isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  String _normalizedExt(String path) {
    final ext = _storageExt(path);
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp') {
      return ext;
    }
    return '.jpg';
  }

  String _storageExt(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '.jpg';
    return path.substring(dot).toLowerCase();
  }

  Future<File> _localPhotoFile({
    required String subDir,
    required String fileName,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/synced_photos/$subDir');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$fileName');
  }
}

class _MemoryOutcome {
  final bool changed;
  final bool uploaded;
  final String babyId;

  const _MemoryOutcome({
    required this.changed,
    required this.uploaded,
    required this.babyId,
  });
}
