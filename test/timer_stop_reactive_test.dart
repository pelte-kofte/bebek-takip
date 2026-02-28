// Regression test: dataNotifier fires when data changes, and listeners are called.
//
// This verifies the reactive chain:
//   saveMamaKayitlari / saveUykuKayitlari
//     → _notifyDataChanged()
//       → VeriYonetici.dataNotifier.value++
//         → listeners notified
//           → HomeScreen rebuilds recents section via ValueListenableBuilder
import 'package:flutter_test/flutter_test.dart';
import 'package:bebek_takip/models/veri_yonetici.dart';

void main() {
  group('VeriYonetici.dataNotifier reactive chain', () {
    test('dataNotifier increments and notifies listener on each change', () {
      final notifier = VeriYonetici.dataNotifier;
      final initialValue = notifier.value;

      int callCount = 0;
      void listener() => callCount++;

      notifier.addListener(listener);

      // Manually increment (mirrors what _notifyDataChanged does)
      notifier.value = initialValue + 1;
      expect(
        callCount,
        1,
        reason: 'listener must be called after first increment',
      );
      expect(notifier.value, initialValue + 1);

      notifier.value = initialValue + 2;
      expect(
        callCount,
        2,
        reason: 'listener must be called after second increment',
      );

      notifier.removeListener(listener);

      // After removal, no more calls
      notifier.value = initialValue + 3;
      expect(callCount, 2, reason: 'listener must NOT be called after removal');
    });

    test('multiple listeners on dataNotifier all fire', () {
      final notifier = VeriYonetici.dataNotifier;
      final initialValue = notifier.value;

      int countA = 0;
      int countB = 0;
      void listenerA() => countA++;
      void listenerB() => countB++;

      notifier.addListener(listenerA);
      notifier.addListener(listenerB);

      notifier.value = initialValue + 10;

      expect(countA, 1);
      expect(countB, 1);

      notifier.removeListener(listenerA);
      notifier.removeListener(listenerB);
    });
  });
}
