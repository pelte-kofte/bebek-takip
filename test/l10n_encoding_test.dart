import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const mojibakeMarkers = <String>[
    'Ã',
    'Å',
    'Ð',
    'Ñ',
    'Â',
    'â€™',
    'â€',
    'â€œ',
    'â€ ',
  ];

  test('ARB locale values do not contain mojibake markers', () {
    final l10nDir = Directory('lib/l10n');
    expect(
      l10nDir.existsSync(),
      isTrue,
      reason: 'lib/l10n directory not found',
    );

    final arbFiles =
        l10nDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.arb'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(arbFiles, isNotEmpty, reason: 'No ARB files found under lib/l10n');

    final violations = <String>[];

    for (final file in arbFiles) {
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      decoded.forEach((key, value) {
        if (key.startsWith('@') || value is! String) {
          return;
        }

        for (final marker in mojibakeMarkers) {
          if (value.contains(marker)) {
            violations.add('${file.path} -> $key contains "$marker"');
          }
        }
      });
    }

    expect(
      violations,
      isEmpty,
      reason: violations.isEmpty ? null : violations.join('\n'),
    );
  });
}
