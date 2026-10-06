import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Loads the bundled brand fonts for widget tests, under the family names
/// google_fonts actually asks the engine for: the plain family ("Inter")
/// AND one family per weight ("Inter_600", "DM Sans_800", "Inter_regular").
/// Registered only as "Inter", a first use of a new weight rendered as the
/// test font's boxes until google_fonts' own async load landed, which made
/// goldens depend on timing.
Future<void> loadBrandFonts() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final dir = Directory('assets/fonts');
  if (!dir.existsSync()) return;
  const families = {
    'DMSans': 'DM Sans',
    'Inter': 'Inter',
    'JetBrainsMono': 'JetBrains Mono',
  };
  const weights = {
    'Regular': 'regular',
    'Medium': '500',
    'SemiBold': '600',
    'Bold': '700',
    'ExtraBold': '800',
  };
  final plain = <String, FontLoader>{};
  for (final file in dir.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (!name.endsWith('.ttf')) continue;
    final parts = name.replaceAll('.ttf', '').split('-');
    final family = families[parts[0]];
    final weight = weights[parts[1]];
    if (family == null || weight == null) continue;
    final bytes = file.readAsBytesSync().buffer.asByteData();
    plain
        .putIfAbsent(family, () => FontLoader(family))
        .addFont(Future.value(bytes));
    // Registered under BOTH spellings. google_fonts asks for the file's own
    // prefix with no space ("DMSans_800"); registering only the display name
    // ("DM Sans_800") meant DM Sans and JetBrains Mono were never registered
    // under the name actually requested, and any text drawn before
    // google_fonts finished loading them from assets came out as boxes. Inter
    // hid it, because its two spellings are identical.
    for (final key in {'${family}_$weight', '${parts[0]}_$weight'}) {
      final variant = FontLoader(key)..addFont(Future.value(bytes));
      await variant.load();
    }
  }
  for (final loader in plain.values) {
    await loader.load();
  }
}

/// KaTeX's fonts, as flutter_math_fork asks for them. See the note inside.
Future<void> loadMathFonts() async {
  // The maths on these screens is drawn with KaTeX's own fonts, which ship
  // inside flutter_math_fork. A test binding does not register another
  // package's fonts, so without this every formula comes out as boxes and the
  // sheet is useless exactly where it matters most.
  final root = Directory(
    Platform.environment['PUB_CACHE'] ??
        '${Platform.environment['HOME']}/.pub-cache',
  );
  final packages = Directory('${root.path}/hosted/pub.dev')
      .listSync()
      .whereType<Directory>()
      .where((d) => d.path.contains('flutter_math_fork-'))
      .toList();
  if (packages.isEmpty) return;

  final fonts = Directory('${packages.last.path}/lib/katex_fonts/fonts');
  if (!fonts.existsSync()) return;

  final byFamily = <String, List<File>>{};
  for (final file in fonts.listSync().whereType<File>()) {
    if (!file.path.endsWith('.ttf')) continue;
    final name = file.uri.pathSegments.last.split('-').first;
    byFamily.putIfAbsent(name, () => []).add(file);
  }
  for (final entry in byFamily.entries) {
    // flutter_math asks for these fonts by their PACKAGE-qualified name, so
    // registering the bare family alone leaves every formula as boxes.
    for (final family in [
      entry.key,
      'packages/flutter_math_fork/${entry.key}',
    ]) {
      final loader = FontLoader(family);
      for (final file in entry.value) {
        loader.addFont(
          Future.value(file.readAsBytesSync().buffer.asByteData()),
        );
      }
      await loader.load();
    }
  }
}

/// The Material icon font, from the Flutter SDK's own cache.
///
/// A test binding registers the app's bundled fonts but not the engine's, so
/// every [Icon] in a widget test comes out as an empty box. Harmless in a
/// golden that is only compared against itself, fatal in a screenshot that
/// goes to Apple.
Future<void> loadIconFont() async {
  final root = Platform.environment['FLUTTER_ROOT'] ?? _flutterRootFromPath();
  if (root == null) return;
  final file = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!file.existsSync()) return;
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
  await loader.load();
}

String? _flutterRootFromPath() {
  for (final dir in (Platform.environment['PATH'] ?? '').split(':')) {
    final bin = File('$dir/flutter');
    if (!bin.existsSync()) continue;
    final resolved = File(bin.resolveSymbolicLinksSync()).parent.parent.path;
    if (Directory('$resolved/bin/cache/artifacts/material_fonts').existsSync()) {
      return resolved;
    }
  }
  return null;
}
