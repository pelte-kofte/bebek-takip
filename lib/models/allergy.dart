import 'package:cloud_firestore/cloud_firestore.dart';

class Allergy {
  final String id;
  final String name;
  final String? note;
  final DateTime createdAt;
  final bool isActive;
  final String createdBy;

  const Allergy({
    required this.id,
    required this.name,
    this.note,
    required this.createdAt,
    required this.isActive,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }

  factory Allergy.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Allergy(
      id: doc.id,
      name: data['name'] as String? ?? '',
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Allergy copyWith({bool? isActive}) {
    return Allergy(
      id: id,
      name: name,
      note: note,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
    );
  }
}
