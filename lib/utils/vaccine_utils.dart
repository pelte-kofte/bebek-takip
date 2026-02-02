/// Vaccine utility functions for filtering and processing vaccine data
List<Map<String, dynamic>> getUpcomingVaccines(
    List<Map<String, dynamic>> allVaccines) {
  // Normalize today to midnight for accurate date comparison
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Filter and process vaccines
  final upcoming = allVaccines.where((vaccine) {
    // Ignore completed vaccines
    if (vaccine['durum'] == 'uygulandi') {
      return false;
    }

    // Ignore vaccines with null date
    final date = vaccine['tarih'] as DateTime?;
    if (date == null) {
      return false;
    }

    // Normalize vaccine date to midnight for comparison
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Include vaccines with date >= today
    return normalizedDate.isAfter(today) ||
        normalizedDate.isAtSameMomentAs(today);
  }).toList();

  // Sort by date ascending (nearest first)
  upcoming.sort((a, b) {
    final dateA = a['tarih'] as DateTime;
    final dateB = b['tarih'] as DateTime;
    return dateA.compareTo(dateB);
  });

  return upcoming;
}

/// Returns a human-readable relative date string for vaccine dates
/// Examples: "Bugün", "Yarın", "5 gün sonra", "2 ay sonra"
String getVaccineRelativeDate(DateTime vaccineDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final normalizedDate = DateTime(vaccineDate.year, vaccineDate.month, vaccineDate.day);

  final diff = normalizedDate.difference(today).inDays;

  if (diff == 0) return 'Bugün';
  if (diff == 1) return 'Yarın';
  if (diff < 30) return '$diff gün sonra';

  final months = (diff / 30).round();
  return '$months ay sonra';
}
