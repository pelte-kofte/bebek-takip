import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const suspiciousSubstrings = <String>['Ã', 'Â', 'â€', '�'];
  const brokenBullet = 'â€¢';

  test('ARB files do not contain mojibake substrings', () {
    final l10nDir = Directory('lib/l10n');
    expect(
      l10nDir.existsSync(),
      isTrue,
      reason: 'Directory not found: lib/l10n',
    );

    final arbFiles =
        l10nDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.arb'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(arbFiles, isNotEmpty, reason: 'No ARB files found under lib/l10n');

    final issues = <String>[];

    for (final file in arbFiles) {
      final bytes = file.readAsBytesSync();
      final content = const Utf8Decoder(allowMalformed: false).convert(bytes);
      final lines = const LineSplitter().convert(content);
      final normalizedPath = file.path.replaceAll('\\', '/');

      for (var i = 0; i < lines.length; i++) {
        final lineNo = i + 1;
        final line = lines[i];

        for (final token in suspiciousSubstrings) {
          if (line.contains(token)) {
            issues.add(
              '$normalizedPath:$lineNo contains "$token" -> ${line.trim()}',
            );
          }
        }

        if (line.contains(brokenBullet)) {
          issues.add(
            '$normalizedPath:$lineNo contains broken bullet "$brokenBullet" -> ${line.trim()}',
          );
        }
      }
    }

    expect(
      issues,
      isEmpty,
      reason: issues.isEmpty
          ? null
          : 'Mojibake patterns detected:\n${issues.join('\n')}',
    );
  });
}
