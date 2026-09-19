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
    final variant = FontLoader('${family}_$weight')
      ..addFont(Future.value(bytes));
    await variant.load();
  }
  for (final loader in plain.values) {
    await loader.load();
  }
}
