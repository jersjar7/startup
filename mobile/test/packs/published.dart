import 'dart:convert';
import 'dart:io';

/// The latest version an exam's folder in service/packs/ publishes, put
/// back together as the builder wrote it: its index with every chapter's
/// games under `games` (ADR 0033).
Map<String, Object?> latestPublished(Directory dir) {
  Map<String, Object?> read(String name) =>
      jsonDecode(File('${dir.path}/$name').readAsStringSync())
          as Map<String, Object?>;
  final manifest = read('manifest.json');
  final pack = read((manifest['latest']! as Map)['file']! as String);
  return {
    ...pack,
    'games': {
      for (final c in (pack['chapters']! as Map).values)
        ...(read((c as Map)['file']! as String)['games']! as Map),
    },
  };
}
