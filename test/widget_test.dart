import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bebek_takip/main.dart';

void main() {
  testWidgets('BabyTrackerApp boots without exceptions', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BabyTrackerApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(BabyTrackerApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
