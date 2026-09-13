import '../games/game_catalog.dart';

/// The three bands the fifteen chapters are shown in.
///
/// These are OURS, not NCEES's. The FE Civil specification lists fourteen
/// knowledge areas flat, with no grouping, so any bracketing is an editorial
/// choice. This one earns its place by costing nothing: the bands fall on
/// chapters 1-4, 5-9 and 10-15, which is the order the catalog already has,
/// so nothing is renumbered or moved and the grouping can be pulled back out
/// without touching anything else.
///
/// The question ranges are the sum of the chapters' own `examLine` ranges,
/// computed rather than typed, so they cannot drift from the catalog.
class ChapterBand {
  const ChapterBand({required this.name, required this.chapterIds});

  final String name;
  final List<String> chapterIds;

  List<ChapterMap> get chapters => [
        for (final id in chapterIds)
          if (chapterMaps[id] != null) chapterMaps[id]!,
      ];

  /// "23-35 q", summed from the chapters in the band.
  String get examRange {
    var low = 0;
    var high = 0;
    for (final chapter in chapters) {
      final range = _rangeOf(chapter.examLine);
      low += range.$1;
      high += range.$2;
    }
    return '$low-$high q';
  }

  /// Pulls the two numbers out of a line like
  /// "11 to 17 questions on the real exam".
  static (int, int) _rangeOf(String examLine) {
    final found = RegExp(r'(\d+)\s+to\s+(\d+)').firstMatch(examLine);
    if (found == null) return (0, 0);
    return (int.parse(found.group(1)!), int.parse(found.group(2)!));
  }
}

const chapterBands = <ChapterBand>[
  ChapterBand(
    name: 'Before the engineering',
    chapterIds: ['mathematics', 'statistics', 'ethics', 'economics'],
  ),
  ChapterBand(
    name: 'Mechanics',
    chapterIds: [
      'statics',
      'dynamics',
      'mechanics-materials',
      'materials',
      'fluid-mechanics',
    ],
  ),
  ChapterBand(
    name: 'Civil practice',
    chapterIds: [
      'surveying',
      'water-resources',
      'structural',
      'geotechnical',
      'transportation',
      'construction',
    ],
  ),
];

/// What a chapter is called on a card.
///
/// The catalog carries the website's names, which match the lesson content
/// exactly and must not be changed there. One of them is long enough to push
/// a card to three lines and make its whole row taller: "Mathematics &
/// Computational Tools". On a card, where the number and the drawing already
/// say which chapter this is, the first word is enough.
const chapterCardNames = <String, String>{
  'mathematics': 'Mathematics',
};

String cardNameFor(ChapterMap chapter) =>
    chapterCardNames[chapter.id] ?? chapter.name;
