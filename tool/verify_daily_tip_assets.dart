import 'dart:io';

class DailyTipAssetVerificationResult {
  const DailyTipAssetVerificationResult({
    required this.referencedPaths,
    required this.missingReferencedPaths,
    required this.unusedWebpPaths,
  });

  final List<String> referencedPaths;
  final List<String> missingReferencedPaths;
  final List<String> unusedWebpPaths;
}

DailyTipAssetVerificationResult analyzeDailyTipAssets() {
  final sourceFile = File('lib/models/daily_tip.dart');

  if (!sourceFile.existsSync()) {
    throw StateError('Missing source file: lib/models/daily_tip.dart');
  }

  final source = sourceFile.readAsStringSync();
  final pattern = RegExp(r"illustrationPath:\s*'([^']+)'");
  final referencedPaths = pattern
      .allMatches(source)
      .map((match) => match.group(1))
      .whereType<String>()
      .toList()
    ..sort();

  final missingPaths = <String>[];

  for (final assetPath in referencedPaths) {
    if (!File(assetPath).existsSync()) {
      missingPaths.add(assetPath);
    }
  }

  final webpFiles = Directory('assets/illustrations/tips')
      .listSync()
      .whereType<File>()
      .map((file) => file.path)
      .where((path) => path.endsWith('.webp'))
      .toList()
    ..sort();

  final referencedSet = referencedPaths.toSet();
  final unusedWebpPaths = webpFiles
      .where((path) => !referencedSet.contains(path))
      .toList();

  return DailyTipAssetVerificationResult(
    referencedPaths: referencedPaths,
    missingReferencedPaths: missingPaths,
    unusedWebpPaths: unusedWebpPaths,
  );
}

void main() {
  final result = analyzeDailyTipAssets();

  stdout.writeln(
    'Verified ${result.referencedPaths.length} daily tip asset path(s).',
  );

  if (result.unusedWebpPaths.isEmpty) {
    stdout.writeln('Unused daily tip webp assets: none');
  } else {
    stdout.writeln('Unused daily tip webp assets (${result.unusedWebpPaths.length}):');
    for (final path in result.unusedWebpPaths) {
      stdout.writeln(path);
    }
  }

  if (result.missingReferencedPaths.isNotEmpty) {
    stderr.writeln('Missing referenced daily tip assets:');
    for (final path in result.missingReferencedPaths) {
      stderr.writeln(path);
    }
    exitCode = 1;
  }
}
