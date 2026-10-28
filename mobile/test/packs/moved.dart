import 'adapters.dart';
import 'construction.dart' as construction;
import 'dynamics.dart' as dynamics;
import 'economics.dart' as economics;
import 'ethics.dart' as ethics;
import 'fluids.dart' as fluids;
import 'statistics.dart' as statistics;

/// Every game moved into the FE Civil pack so far, by chapter, each as the
/// adapter that turns the built-in game into pack data. The pack builder
/// and the parity test both read this list, so a game cannot be packed
/// without being compared.
final movedByChapter = <String, Map<String, Map<String, Object?> Function()>>{
  'phase 0': {
    'per-million-what': perMillionWhat,
    'tap-the-voids': tapTheVoids,
    'in-what-order': inWhatOrder,
  },
  'construction': construction.adapters,
  'dynamics': dynamics.adapters,
  'economics': economics.adapters,
  'statistics': statistics.adapters,
  'ethics': ethics.adapters,
  'fluid-mechanics': fluids.adapters,
};

/// Every moved game, by id.
Map<String, Map<String, Object?> Function()> get movedGames => {
  for (final games in movedByChapter.values) ...games,
};
