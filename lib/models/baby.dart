class Baby {
  final String id;
  String name;
  DateTime birthDate;
  String? photoPath;
  String? photoStoragePath;
  String? photoUrl;
  final DateTime createdAt;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.photoPath,
    this.photoStoragePath,
    this.photoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'photoPath': photoPath,
      'photoStoragePath': photoStoragePath,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      photoPath: json['photoPath'] as String?,
      photoStoragePath: json['photoStoragePath'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
