import 'package:cloud_firestore/cloud_firestore.dart';

class IllustrationRequestStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
}

class IllustrationRequest {
  final String id;
  final String uid;
  final String babyId;
  final String memoryId;
  final String sourcePhotoStoragePath;
  final String sourcePhotoUrl;
  final String status;
  final String requestType;
  final String promptVersion;
  final String? resultStoragePath;
  final String? resultImageUrl;
  final String? errorCode;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IllustrationRequest({
    required this.id,
    required this.uid,
    required this.babyId,
    required this.memoryId,
    required this.sourcePhotoStoragePath,
    required this.sourcePhotoUrl,
    required this.status,
    required this.requestType,
    required this.promptVersion,
    required this.resultStoragePath,
    required this.resultImageUrl,
    required this.errorCode,
    required this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'babyId': babyId,
      'memoryId': memoryId,
      'sourcePhotoStoragePath': sourcePhotoStoragePath,
      'sourcePhotoUrl': sourcePhotoUrl,
      'status': status,
      'requestType': requestType,
      'promptVersion': promptVersion,
      'resultStoragePath': resultStoragePath,
      'resultImageUrl': resultImageUrl,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory IllustrationRequest.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return IllustrationRequest(
      id: doc.id,
      uid: (data['uid'] ?? '').toString(),
      babyId: (data['babyId'] ?? '').toString(),
      memoryId: (data['memoryId'] ?? '').toString(),
      sourcePhotoStoragePath: (data['sourcePhotoStoragePath'] ?? '').toString(),
      sourcePhotoUrl: (data['sourcePhotoUrl'] ?? '').toString(),
      status: (data['status'] ?? IllustrationRequestStatus.pending).toString(),
      requestType: (data['requestType'] ?? '').toString(),
      promptVersion: (data['promptVersion'] ?? '').toString(),
      resultStoragePath: data['resultStoragePath']?.toString(),
      resultImageUrl: data['resultImageUrl']?.toString(),
      errorCode: data['errorCode']?.toString(),
      errorMessage: data['errorMessage']?.toString(),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
