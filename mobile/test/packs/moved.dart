import 'adapters.dart';
import 'construction.dart' as construction;
import 'dynamics.dart' as dynamics;
import 'economics.dart' as economics;
import 'ethics.dart' as ethics;
import 'fluids.dart' as fluids;
import 'materials_a.dart' as materials_a;
import 'materials_b.dart' as materials_b;
import 'mechanics_a.dart' as mechanics_a;
import 'mechanics_b.dart' as mechanics_b;
import 'statics_a.dart' as statics_a;
import 'statics_b.dart' as statics_b;
import 'statistics.dart' as statistics;
import 'structural_a.dart' as structural_a;
import 'structural_b.dart' as structural_b;
import 'surveying_a.dart' as surveying_a;
import 'surveying_b.dart' as surveying_b;

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
  'materials': {...materials_a.adapters, ...materials_b.adapters},
  'statics': {...statics_a.adapters, ...statics_b.adapters},
  'surveying': {...surveying_a.adapters, ...surveying_b.adapters},
  'mechanics-materials': {...mechanics_a.adapters, ...mechanics_b.adapters},
  'structural': {...structural_a.adapters, ...structural_b.adapters},
};

/// Every moved game, by id.
Map<String, Map<String, Object?> Function()> get movedGames => {
  for (final games in movedByChapter.values) ...games,
};
