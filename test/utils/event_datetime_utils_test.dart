import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bebek_takip/utils/event_datetime_utils.dart';

void main() {
  test(
    'normalizePickedDateTime maps 23:50 today to yesterday when now is 00:05',
    () {
      final now = DateTime(2026, 2, 19, 0, 5);
      final pickedDate = DateTime(2026, 2, 19);
      const pickedTime = TimeOfDay(hour: 23, minute: 50);

      final result = normalizePickedDateTime(
        now: now,
        pickedDate: pickedDate,
        pickedTime: pickedTime,
      );

      expect(result, DateTime(2026, 2, 18, 23, 50));
    },
  );
}
