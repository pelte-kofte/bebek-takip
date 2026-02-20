import 'package:flutter_test/flutter_test.dart';
import 'package:bebek_takip/services/reminder_service.dart';

void main() {
  group('ReminderService medication IDs', () {
    test('medicationReminderId is deterministic per medication + slot', () {
      final a = ReminderService.medicationReminderId(
        medicationId: 'med_1',
        slotKey: 'daily_09:00_0',
      );
      final b = ReminderService.medicationReminderId(
        medicationId: 'med_1',
        slotKey: 'daily_09:00_0',
      );
      final c = ReminderService.medicationReminderId(
        medicationId: 'med_1',
        slotKey: 'daily_21:00_1',
      );

      expect(a, b);
      expect(a, isNot(c));
      expect(a, greaterThanOrEqualTo(ReminderService.medicationReminderBaseId));
    });

    test('medicationReminderIdsFor returns stable unique IDs', () {
      final service = ReminderService();
      final med = <String, dynamic>{
        'id': 'med_42',
        'scheduleType': 'daily',
        'dailyTimes': ['09:00', '09:00', '18:30'],
      };

      final ids = service.medicationReminderIdsFor(med);
      final second = service.medicationReminderIdsFor(med);

      expect(ids, orderedEquals(second));
      expect(ids.toSet().length, ids.length);
    });
  });
}
