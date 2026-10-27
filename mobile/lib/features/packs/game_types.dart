/// The game types this app can play, and the app version that first had
/// each one (ADR 0030, sections 4 and 5).
///
/// A pack names, for every lesson, the oldest app that can play it: the
/// newest version among its games' types. The builder works that out from
/// this list, and test/packs/pack_versions_test.dart checks every published
/// pack against it, so a lesson can never be offered to an app that cannot
/// play it, nor held back from one that can.
///
/// When a release adds a game type, add it here with that release's
/// version. Never change a version once the release is out.
library;

/// The pack layout this app reads. Raised only when an older app could no
/// longer make sense of a pack at all; a new game type never raises it.
const packFormat = 1;

/// The first release that reads packs. Every game type is at least this.
const firstPackApp = '1.2.0';

const gameTypes = <String, String>{
  'pick-one': '1.2.0',
  'tap-figure': '1.2.0',
  'order': '1.2.0',
  // The pick-one screen with any number of answers picked (2026-10-27).
  'pick-several': '1.2.0',
};

/// Compares two `major.minor.patch` versions: negative, zero or positive.
int compareVersions(String a, String b) {
  final x = _parts(a), y = _parts(b);
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i] - y[i];
  }
  return 0;
}

List<int> _parts(String v) {
  final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(v);
  if (m == null) throw FormatException('Not a version: $v');
  return [for (var i = 1; i <= 3; i++) int.parse(m[i]!)];
}

/// The oldest app that can play every one of [types].
String minAppFor(Iterable<String> types) {
  var min = firstPackApp;
  for (final t in types) {
    final v = gameTypes[t];
    if (v == null) throw ArgumentError('No game type $t in this app');
    if (compareVersions(v, min) > 0) min = v;
  }
  return min;
}
