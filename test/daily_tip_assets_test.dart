import 'package:flutter_test/flutter_test.dart';

import '../tool/verify_daily_tip_assets.dart' as verifier;

void main() {
  test('all referenced daily tip assets exist on disk', () {
    final result = verifier.analyzeDailyTipAssets();

    expect(
      result.missingReferencedPaths,
      isEmpty,
      reason: result.missingReferencedPaths.join('\n'),
    );
  });
}
