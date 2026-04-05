import 'package:cloud_firestore/cloud_firestore.dart';

class UserIllustrationCredits {
  /// Monthly included illustrations granted to every premium user.
  static const int monthlyIncludedLimit = 3;

  final String uid;

  /// "YYYY-MM" of the month whose usage is recorded in [usedThisMonth].
  /// Empty string means the user has never generated an illustration.
  final String usageMonth;

  /// How many monthly-included illustrations have been used in [usageMonth].
  final int usedThisMonth;

  /// Extra purchased credits that carry over across months.
  final int purchasedCreditsRemaining;

  final DateTime? updatedAt;

  const UserIllustrationCredits({
    required this.uid,
    required this.usageMonth,
    required this.usedThisMonth,
    required this.purchasedCreditsRemaining,
    required this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Derived helpers
  // ---------------------------------------------------------------------------

  /// How many monthly-included illustrations remain this calendar month.
  int get monthlyRemaining {
    if (usageMonth != _currentYearMonth()) return monthlyIncludedLimit;
    return (monthlyIncludedLimit - usedThisMonth).clamp(
      0,
      monthlyIncludedLimit,
    );
  }

  bool get hasMonthlyCredits => monthlyRemaining > 0;
  bool get hasPurchasedCredits => purchasedCreditsRemaining > 0;

  /// True when the user may generate at least one more illustration.
  /// Monthly included usage is consumed first, then purchased credits.
  bool get canGenerate => hasMonthlyCredits || hasPurchasedCredits;

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  factory UserIllustrationCredits.fromDoc(
    String uid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserIllustrationCredits(
      uid: uid,
      usageMonth: (data['usageMonth'] ?? '').toString(),
      usedThisMonth: _toInt(data['usedThisMonth']),
      purchasedCreditsRemaining: _toInt(data['purchasedCreditsRemaining']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  /// Used when no credits doc exists yet (first-time user).
  factory UserIllustrationCredits.empty(String uid) =>
      UserIllustrationCredits(
        uid: uid,
        usageMonth: '',
        usedThisMonth: 0,
        purchasedCreditsRemaining: 0,
        updatedAt: null,
      );

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _currentYearMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
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
