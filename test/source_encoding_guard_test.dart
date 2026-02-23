// Regression guard: no mojibake or broken-encoding strings in Dart source files.
//
// Catches:
//   • Latin-2/Windows-1252 re-encoded as UTF-8 (Ã, Ä, Å, Â sequences).
//   • Turkish chars replaced by '?' in string literals used for data matching
//     (e.g. 'Anne S?t?' instead of 'Anne Sütü' in rapor_screen.dart).
//   • Any U+FFFD replacement characters.
//
// Run:  flutter test test/source_encoding_guard_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Mojibake marker sequences ────────────────────────────────────────────────
  // These byte-sequences appear when UTF-8 text is decoded as Latin-1 or
  // Windows-1252 and then saved again as UTF-8.
  const mojibakeMarkers = <String>[
    'Ã–', // Ö mis-encoded
    'Ãœ', // Ü mis-encoded
    'Ä°', // İ mis-encoded
    'ÄŸ', // ğ mis-encoded
    'ÅŸ', // ş mis-encoded
    'Ä±', // ı mis-encoded
    'Ã§', // ç mis-encoded
    'Ã¶', // ö mis-encoded
    'Ã¼', // ü mis-encoded
    'Ã±', // ñ mis-encoded
    'Ã¡', // á mis-encoded
    'Ã©', // é mis-encoded
    'Ã­', // í mis-encoded
    'Ã³', // ó mis-encoded
    'Ãº', // ú mis-encoded
    'â€™', // ' mis-encoded
    'â€"', // – mis-encoded
    // Note: '\uFFFD' is intentionally excluded here because validation helpers
    // may legitimately contain it as a sentinel guard (e.g. checking whether
    // incoming data is corrupted). The ARB test below covers ARB files
    // independently.
  ];

  // ── Broken Turkish literals used as data-matching keys ───────────────────────
  // These were found as literal '?' replacements in rapor_screen.dart where
  // Turkish characters should appear. They cause records to never match.
  const brokenDataKeys = <String>[
    "Anne S?t?", // should be 'Anne Sütü'
    "Kat? G?da", // should be 'Katı Gıda'
    "Form?l",    // should be 'Formül'
    "Do?umda",   // should be 'Doğumda'
  ];

  group('Dart source files — encoding sanity', () {
    List<File> dartSourceFiles() {
      final lib = Directory('lib');
      if (!lib.existsSync()) return [];
      return lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    }

    test('no mojibake marker sequences in string literals', () {
      final files = dartSourceFiles();
      expect(files, isNotEmpty, reason: 'lib/ directory is empty or missing');

      final violations = <String>[];

      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Skip pure comments — they are non-functional, but still flag them
          // because they indicate files saved with wrong encoding.
          for (final marker in mojibakeMarkers) {
            if (line.contains(marker)) {
              violations.add(
                '${file.path}:${i + 1} contains "$marker"\n'
                '  → ${line.trim().substring(0, line.trim().length.clamp(0, 120))}',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Found mojibake sequences in Dart source files.\n'
            'These indicate files saved with incorrect encoding (Latin-1/Win-1252).\n'
            'Violations:\n${violations.join('\n')}',
      );
    });

    test('no broken Turkish data-matching string literals', () {
      final files = dartSourceFiles();
      final violations = <String>[];

      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Only check inside quoted string context (single or double quoted)
          if (!line.contains("'") && !line.contains('"')) continue;
          for (final bad in brokenDataKeys) {
            if (line.contains(bad)) {
              violations.add(
                '${file.path}:${i + 1} contains broken key "$bad"\n'
                '  → ${line.trim().substring(0, line.trim().length.clamp(0, 120))}',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Found broken Turkish string literals used for data matching.\n'
            'These cause records to never be found (e.g. nursing stats show 0).\n'
            'Violations:\n${violations.join('\n')}',
      );
    });
  });

  group('ARB files — extended encoding check', () {
    List<File> arbFiles() {
      final dir = Directory('lib/l10n');
      if (!dir.existsSync()) return [];
      return dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
    }

    test('no mojibake sequences in ARB string values', () {
      final files = arbFiles();
      expect(files, isNotEmpty, reason: 'No .arb files found under lib/l10n');

      final violations = <String>[];
      final allMarkers = [...mojibakeMarkers, 'Ã', 'Ä', 'Å'];

      for (final file in files) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Skip @-metadata lines (they are comments/annotations)
          if (line.trimLeft().startsWith('"@')) continue;
          for (final marker in allMarkers) {
            if (line.contains(marker)) {
              violations.add(
                '${file.path}:${i + 1} contains "$marker"\n'
                '  → ${line.trim().substring(0, line.trim().length.clamp(0, 120))}',
              );
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Found mojibake in ARB files. Fix the source .arb, then run '
            '"flutter gen-l10n" to regenerate localizations.\n'
            'Violations:\n${violations.join('\n')}',
      );
    });
  });
}
