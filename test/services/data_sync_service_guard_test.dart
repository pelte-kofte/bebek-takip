import 'package:flutter_test/flutter_test.dart';

import 'package:bebek_takip/services/data_sync_service.dart';

void main() {
  group('DataSyncService.canWriteToCloud', () {
    test('returns false when user is null', () {
      expect(DataSyncService.canWriteToCloud(null), isFalse);
    });

    test('returns false for anonymous auth state', () {
      expect(
        DataSyncService.canWriteToCloudFromValues(
          isAnonymous: true,
          providerIds: const ['firebase'],
        ),
        isFalse,
      );
    });

    test('returns true for non-anonymous provider auth state', () {
      expect(
        DataSyncService.canWriteToCloudFromValues(
          isAnonymous: false,
          providerIds: const ['apple.com'],
        ),
        isTrue,
      );
    });
  });
}
