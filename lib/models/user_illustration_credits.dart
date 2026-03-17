import 'package:cloud_firestore/cloud_firestore.dart';

class UserIllustrationCredits {
  final String uid;
  final bool freeIllustrationAvailable;
  final int monthlyCreditsRemaining;
  final int purchasedCreditsRemaining;
  final String planTier;
  final DateTime? updatedAt;

  const UserIllustrationCredits({
    required this.uid,
    required this.freeIllustrationAvailable,
    required this.monthlyCreditsRemaining,
    required this.purchasedCreditsRemaining,
    required this.planTier,
    required this.updatedAt,
  });

  int get totalCreditsRemaining =>
      (freeIllustrationAvailable ? 1 : 0) +
      monthlyCreditsRemaining +
      purchasedCreditsRemaining;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'freeIllustrationAvailable': freeIllustrationAvailable,
      'monthlyCreditsRemaining': monthlyCreditsRemaining,
      'purchasedCreditsRemaining': purchasedCreditsRemaining,
      'planTier': planTier,
      'updatedAt': updatedAt,
    };
  }

  factory UserIllustrationCredits.fromDoc(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserIllustrationCredits(
      uid: uid,
      freeIllustrationAvailable: data['freeIllustrationAvailable'] != false,
      monthlyCreditsRemaining: _toInt(data['monthlyCreditsRemaining']),
      purchasedCreditsRemaining: _toInt(data['purchasedCreditsRemaining']),
      planTier: (data['planTier'] ?? 'free').toString(),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
