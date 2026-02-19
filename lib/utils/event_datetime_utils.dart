import 'package:flutter/material.dart';

DateTime normalizePickedDateTime({
  required DateTime now,
  required DateTime pickedDate,
  required TimeOfDay pickedTime,
}) {
  var candidate = DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );

  if (candidate.isAfter(now)) {
    candidate = candidate.subtract(const Duration(days: 1));
  }

  return candidate;
}

bool isWithinRollingWindow({
  required DateTime now,
  required DateTime candidate,
  Duration window = const Duration(hours: 48),
}) {
  final earliest = now.subtract(window);
  return !candidate.isBefore(earliest) && !candidate.isAfter(now);
}
