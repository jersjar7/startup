/// The game catalog: which chapters, lessons, and games exist on the phone.
///
/// The mobile app does not ship the website's lesson text, its 3-problem
/// practice, or "Practice all [chapter]". A chapter is a path, a lesson is a
/// node on that path, and a node opens the lesson's own games. Games are
/// authored per lesson from that lesson's own problems and traps, so this list
/// grows one lesson at a time.
library;

import 'lesson_brief.dart';

class GameDef {
  const GameDef({
    required this.id,
    required this.name,
    required this.blurb,
    this.built = false,
    this.rounds = 0,
    this.brief,
  });

  final String id;
  final String name;

  /// One plain line describing what the student does, shown on the node sheet.
  final String blurb;

  /// False until the game is actually playable. The map says so out loud
  /// rather than pretending a node is there.
  final bool built;

  /// How many rounds the board has. Declared here so the MAP knows what
  /// "finished" means without opening the item: before this was declared, a
  /// fresh launch showed cleared work as untouched until you tapped in.
  final int rounds;

  /// The one concept this item leans on, reachable from inside it.
  final BriefSection? brief;
}

class LessonNode {
  const LessonNode({
    required this.id,
    required this.name,
    required this.subtopicId,
    this.games = const [],
  });

  final String id;
  final String name;
  final String subtopicId;
  final List<GameDef> games;

  List<GameDef> get builtGames =>
      games.where((g) => g.built).toList(growable: false);

  bool get playable => builtGames.isNotEmpty;
}

class Subtopic {
  const Subtopic(this.id, this.name);
  final String id;
  final String name;
}

class ChapterMap {
  const ChapterMap({
    required this.id,
    required this.number,
    required this.name,
    required this.examLine,
    required this.subtopics,
    required this.lessons,
  });

  final String id;
  final int number;
  final String name;

  /// How much of the real exam this chapter is, in plain words.
  final String examLine;
  final List<Subtopic> subtopics;
  final List<LessonNode> lessons;

  List<LessonNode> lessonsIn(String subtopicId) =>
      lessons.where((l) => l.subtopicId == subtopicId).toList(growable: false);
}

/// Chapter 1. Lesson and subtopic names match the web content exactly
/// (`src/data/chapters/mathematics.js`, `src/data/lessons/mathematics/`).
const mathematicsMap = ChapterMap(
  id: 'mathematics',
  number: 1,
  name: 'Mathematics & Computational Tools',
  examLine: '11 to 17 questions on the real exam',
  subtopics: [
    Subtopic('analytic-geometry', 'Analytic Geometry'),
    Subtopic('single-var-calc', 'Single-Variable Calculus'),
    Subtopic('vector-operations', 'Vector Operations'),
    Subtopic('computational-tools', 'Computational Tools'),
  ],
  lessons: [
    LessonNode(
      id: 'straight-lines-quadratics',
      name: 'Straight Lines & Quadratics',
      subtopicId: 'analytic-geometry',
      games: [
        GameDef(
          id: 'perpendicular-flip',
          rounds: 8,
          name: 'Perpendicular Flip',
          blurb: 'Build the second line with two moves and watch it swing.',
          built: true,
          brief: perpendicularBrief,
        ),
        GameDef(
          id: 'discriminant-gate',
          rounds: 8,
          name: 'Discriminant Gate',
          blurb: 'Two roots, one root, or none. Judge the sign, never solve.',
          built: true,
          brief: discriminantBrief,
        ),
        GameDef(
          id: 'grade-sense',
          rounds: 6,
          name: 'Grade Sense',
          blurb: 'Rank road profiles by grade. The station trap is in there.',
          built: true,
          brief: gradeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'logarithms',
      name: 'Logarithms',
      subtopicId: 'analytic-geometry',
      games: [
        GameDef(
          id: 'rule-or-trap',
          rounds: 10,
          name: 'Rule or Trap',
          blurb: 'Legal move or no such rule. The sum inside a log is in here.',
          built: true,
          brief: logRulesBrief,
        ),
        GameDef(
          id: 'order-the-moves',
          rounds: 4,
          name: 'Order the Moves',
          blurb: 'Put a real solve in order. You never carry any of it out.',
          built: true,
          brief: undoExponentBrief,
        ),
        GameDef(
          id: 'one-log',
          rounds: 6,
          name: 'One Log',
          blurb: 'Collapse the terms into a single log, values untouched.',
          built: true,
          brief: combineLogsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'right-triangle-trig',
      name: 'Right Triangle Trigonometry',
      subtopicId: 'analytic-geometry',
      games: [
        GameDef(
          id: 'tap-the-side',
          rounds: 8,
          name: 'Tap the Side',
          blurb: 'Point at the opposite, the adjacent, the hypotenuse.',
          built: true,
          brief: sideNamesBrief,
        ),
        GameDef(
          id: 'which-ratio',
          rounds: 8,
          name: 'Which Ratio',
          blurb: 'One side known, one wanted. Pick sin, cos or tan.',
          built: true,
          brief: ratiosBrief,
        ),
        GameDef(
          id: 'resolve-it',
          rounds: 6,
          name: 'Resolve It',
          blurb: 'Split a force. Angles from the vertical are in here.',
          built: true,
          brief: componentsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'law-of-sines-cosines',
      name: 'Law of Sines & Law of Cosines',
      subtopicId: 'analytic-geometry',
      games: [
        GameDef(
          id: 'which-law',
          rounds: 8,
          name: 'Which Law',
          blurb: 'Read what you were handed and pick the way in.',
          built: true,
          brief: whichLawBrief,
        ),
        GameDef(
          id: 'set-it-up',
          rounds: 6,
          name: 'Set It Up',
          blurb: 'Write it down right. Every wrong option is a real slip.',
          built: true,
          brief: setupBrief,
        ),
        GameDef(
          id: 'acute-or-obtuse',
          rounds: 6,
          name: 'Acute or Obtuse',
          blurb: 'A negative cosine is not a mistake. Say what it means.',
          built: true,
          brief: obtuseBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'unit-circle-trig-identities',
      name: 'Unit Circle & Trig Identities',
      subtopicId: 'analytic-geometry',
      games: [
        GameDef(
          id: 'walk-the-circle',
          rounds: 8,
          name: 'Walk the Circle',
          blurb: 'Point at the angle, or at the coordinates it belongs to.',
          built: true,
          brief: unitCircleBrief,
        ),
        GameDef(
          id: 'quadrant-signs',
          rounds: 6,
          name: 'Quadrant Signs',
          blurb: 'The identity gives the size. Tap where the sign comes from.',
          built: true,
          brief: quadrantBrief,
        ),
        GameDef(
          id: 'build-the-identity',
          rounds: 6,
          name: 'Build the Identity',
          blurb: 'Assemble it from parts. No list to recognise it in.',
          built: true,
          brief: identitiesBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'circles-conics',
      name: 'Circles & Conic Sections',
      subtopicId: 'analytic-geometry',
    ),
    LessonNode(
      id: 'derivatives-rules',
      name: 'Derivatives & Derivative Rules',
      subtopicId: 'single-var-calc',
    ),
    LessonNode(
      id: 'applications-derivatives',
      name: 'Applications of Derivatives',
      subtopicId: 'single-var-calc',
    ),
    LessonNode(
      id: 'integral-calculus',
      name: 'Integral Calculus',
      subtopicId: 'single-var-calc',
    ),
    LessonNode(
      id: 'lhopitals-rule',
      name: "L'Hopital's Rule",
      subtopicId: 'single-var-calc',
    ),
    LessonNode(
      id: 'vector-basics-unit-vectors',
      name: 'Vector Basics & Unit Vectors',
      subtopicId: 'vector-operations',
    ),
    LessonNode(
      id: 'dot-product-angle',
      name: 'Dot Product & Angle Between Vectors',
      subtopicId: 'vector-operations',
    ),
    LessonNode(
      id: 'cross-product-applications',
      name: 'Cross Product & Applications',
      subtopicId: 'vector-operations',
    ),
    LessonNode(
      id: 'spreadsheet-computations',
      name: 'Spreadsheet Computations',
      subtopicId: 'computational-tools',
    ),
    LessonNode(
      id: 'structured-programming',
      name: 'Structured Programming',
      subtopicId: 'computational-tools',
    ),
    LessonNode(
      id: 'numerical-methods',
      name: 'Numerical Methods: Root-Finding',
      subtopicId: 'computational-tools',
    ),
  ],
);

/// Every chapter map the phone has. Chapters absent from here have no games
/// authored yet and say so rather than falling back to the old lesson list.
const chapterMaps = <String, ChapterMap>{'mathematics': mathematicsMap};

ChapterMap? mapForChapter(String chapterId) => chapterMaps[chapterId];
