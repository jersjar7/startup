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
          blurb: 'Assemble it from parts. No list to recognize it in.',
          built: true,
          brief: identitiesBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'circles-conics',
      name: 'Circles & Conic Sections',
      subtopicId: 'analytic-geometry',
      games: [
        GameDef(
          id: 'place-the-center',
          rounds: 8,
          name: 'Place the Center',
          blurb: 'Put a finger where the circle sits. The signs decide.',
          built: true,
          brief: circleFormBrief,
        ),
        GameDef(
          id: 'read-the-equation',
          rounds: 8,
          name: 'Read the Equation',
          blurb: 'Point at the piece that answers the question.',
          built: true,
          brief: readingConicsBrief,
        ),
        GameDef(
          id: 'balance-both-sides',
          rounds: 5,
          name: 'Balance Both Sides',
          blurb: 'Complete the square with the equals sign enforced.',
          built: true,
          brief: completeSquareBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'derivatives-rules',
      name: 'Derivatives & Derivative Rules',
      subtopicId: 'single-var-calc',
      games: [
        GameDef(
          id: 'every-rule',
          rounds: 8,
          name: 'Every Rule It Needs',
          blurb: 'More than one can apply. Name all of them.',
          built: true,
          brief: whichRuleBrief,
        ),
        GameDef(
          id: 'point-at-the-inside',
          rounds: 6,
          name: 'Point at the Inside',
          blurb: 'Find the inner function and the chain rule writes itself.',
          built: true,
          brief: chainRuleBrief,
        ),
        GameDef(
          id: 'find-the-slip',
          rounds: 6,
          name: 'Find the Slip',
          blurb: 'One line of the working is wrong. Say which, and why.',
          built: true,
          brief: quotientOrderBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'applications-derivatives',
      name: 'Applications of Derivatives',
      subtopicId: 'single-var-calc',
      games: [
        GameDef(
          id: 'slide-to-flat',
          rounds: 6,
          name: 'Slide to the Flat Spot',
          blurb: 'Drag along the curve until the slope goes flat.',
          built: true,
          brief: criticalPointBrief,
        ),
        GameDef(
          id: 'sign-the-bend',
          rounds: 6,
          name: 'Sign the Bend',
          blurb: 'Smile or frown, region by region. The flip is the answer.',
          built: true,
          brief: concavityBrief,
        ),
        GameDef(
          id: 'what-was-asked',
          rounds: 6,
          name: 'What Was Asked',
          blurb: 'The working is right. Hand in the number it wanted.',
          built: true,
          brief: askedForBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'integral-calculus',
      name: 'Integral Calculus',
      subtopicId: 'single-var-calc',
      games: [
        GameDef(
          id: 'pick-u',
          rounds: 6,
          name: 'Pick u, Pick du',
          blurb: 'Two halves that only work as a pair.',
          built: true,
          brief: substitutionBrief,
        ),
        GameDef(
          id: 'which-way-simpler',
          rounds: 6,
          name: 'Which Way Gets Simpler',
          blurb: 'Both choices are legal. One of them helps.',
          built: true,
          brief: byPartsBrief,
        ),
        GameDef(
          id: 'whats-missing',
          rounds: 6,
          name: "What's Missing",
          blurb: 'The integration is right. The write-up may not be.',
          built: true,
          brief: finishingBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'lhopitals-rule',
      name: "L'Hopital's Rule",
      subtopicId: 'single-var-calc',
      games: [
        GameDef(
          id: 'run-the-loop',
          rounds: 6,
          name: 'Run the Loop',
          blurb: 'Drive the rule one move at a time. Check before you cut.',
          built: true,
          brief: formCheckBrief,
        ),
        GameDef(
          id: 'next-line',
          rounds: 6,
          name: 'Which Line Comes Next',
          blurb: 'One of these is the rule. One is the quotient rule.',
          built: true,
          brief: separatelyBrief,
        ),
        GameDef(
          id: 'both-sides',
          rounds: 6,
          name: 'Both Sides',
          blurb: 'It blows up. Which way, and does the limit survive?',
          built: true,
          brief: bothSidesBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'vector-basics-unit-vectors',
      name: 'Vector Basics & Unit Vectors',
      subtopicId: 'vector-operations',
      games: [
        GameDef(
          id: 'land-the-resultant',
          rounds: 6,
          name: 'Land the Resultant',
          blurb: 'Put a finger where the arrows add up to.',
          built: true,
          brief: vectorAddBrief,
        ),
        GameDef(
          id: 'stretch-it',
          rounds: 6,
          name: 'Stretch It to Fit',
          blurb: 'A direction is handed to you. Give it a size.',
          built: true,
          brief: unitVectorBrief,
        ),
        GameDef(
          id: 'reaches-further',
          rounds: 6,
          name: 'Which Reaches Further',
          blurb: 'Two arrows. Counting up the parts will not tell you.',
          built: true,
          brief: magnitudeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'dot-product-angle',
      name: 'Dot Product & Angle Between Vectors',
      subtopicId: 'vector-operations',
      games: [
        GameDef(
          id: 'take-the-diagonal',
          rounds: 6,
          name: 'Take the Diagonal',
          blurb: 'Every pairing is on screen. Only some of them count.',
          built: true,
          brief: dotProductBrief,
        ),
        GameDef(
          id: 'open-or-closed',
          rounds: 6,
          name: 'Open or Closed',
          blurb: 'Positive, zero or negative, read straight off the drawing.',
          built: true,
          brief: dotAngleBrief,
        ),
        GameDef(
          id: 'shadow-falls',
          rounds: 6,
          name: 'Where the Shadow Falls',
          blurb: 'Drop the force onto the member and see how much lands.',
          built: true,
          brief: projectionBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'cross-product-applications',
      name: 'Cross Product & Applications',
      subtopicId: 'vector-operations',
      games: [
        GameDef(
          id: 'which-way-turns',
          rounds: 6,
          name: 'Which Way Does It Turn',
          blurb: 'Sweep from the first arrow to the second and watch.',
          built: true,
          brief: rightHandBrief,
        ),
        GameDef(
          id: 'which-region',
          rounds: 6,
          name: 'Which Region',
          blurb: 'Same two edges, three shapes. Only one is the answer.',
          built: true,
          brief: areaBrief,
        ),
        GameDef(
          id: 'fix-the-sign',
          rounds: 6,
          name: 'Fix the Sign',
          blurb: 'One line of the expansion may have the wrong sign.',
          built: true,
          brief: cofactorBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'spreadsheet-computations',
      name: 'Spreadsheet Computations',
      subtopicId: 'computational-tools',
      games: [
        GameDef(
          id: 'copy-it-down',
          rounds: 6,
          name: 'Copy It Down',
          blurb: 'Where does the formula point after you copy it?',
          built: true,
          brief: referencesBrief,
        ),
        GameDef(
          id: 'happens-first',
          rounds: 6,
          name: 'Which Happens First',
          blurb: 'A sheet does not read a formula left to right.',
          built: true,
          brief: precedenceBrief,
        ),
        GameDef(
          id: 'what-shows',
          rounds: 6,
          name: 'What Does the Cell Show',
          blurb: 'It holds a formula. It displays something else.',
          built: true,
          brief: functionsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'structured-programming',
      name: 'Structured Programming',
      subtopicId: 'computational-tools',
      games: [
        GameDef(
          id: 'fill-the-trace',
          rounds: 6,
          name: 'Fill the Trace',
          blurb: 'Write the loop out, one row for every pass.',
          built: true,
          brief: tracingBrief,
        ),
        GameDef(
          id: 'first-true-wins',
          rounds: 6,
          name: 'First True Wins',
          blurb: 'The chain stops at the first condition that holds.',
          built: true,
          brief: selectionBrief,
        ),
        GameDef(
          id: 'where-it-stops',
          rounds: 6,
          name: 'Where It Stops',
          blurb: 'A WHILE leaves behind the value that broke it.',
          built: true,
          brief: iterationBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'numerical-methods',
      name: 'Numerical Methods: Root-Finding',
      subtopicId: 'computational-tools',
      games: [
        GameDef(
          id: 'follow-the-tangent',
          rounds: 6,
          name: 'Follow the Tangent',
          blurb: 'One step of Newton, read off the picture.',
          built: true,
          brief: newtonBrief,
        ),
        GameDef(
          id: 'can-it-start',
          rounds: 6,
          name: 'Can It Start Here',
          blurb: 'A root in the span is not the same as a bracket.',
          built: true,
          brief: bisectionBrief,
        ),
        GameDef(
          id: 'which-method',
          rounds: 6,
          name: 'Which Method',
          blurb: 'Fast and demanding, or slow and guaranteed.',
          built: true,
          brief: methodChoiceBrief,
        ),
      ],
    ),
  ],
);

/// Every chapter map the phone has. Chapters absent from here have no games
/// authored yet and say so rather than falling back to the old lesson list.
/// Chapter 2. Lesson and subtopic names match the web content exactly
/// (`src/data/chapters/statistics.js`, `src/data/lessons/statistics/`).
const statisticsMap = ChapterMap(
  id: 'statistics',
  number: 2,
  name: 'Probability & Statistics',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('descriptive-statistics', 'Descriptive Statistics'),
    Subtopic('probability', 'Probability'),
    Subtopic('inferential-statistics', 'Inferential Statistics'),
  ],
  lessons: [
    LessonNode(
      id: 'central-tendency-dispersion',
      name: 'Measures of Central Tendency & Dispersion',
      subtopicId: 'descriptive-statistics',
      games: [
        GameDef(
          id: 'read-the-line',
          rounds: 6,
          name: 'Read It Off the Line',
          blurb: 'Median, mode and range are places, not sums.',
          built: true,
          brief: centerBrief,
        ),
        GameDef(
          id: 'which-readout',
          rounds: 6,
          name: 'Which Line Do You Read',
          blurb: 'Six numbers on one screen. Only one answers the question.',
          built: true,
          brief: spreadBrief,
        ),
        GameDef(
          id: 'what-weights',
          rounds: 6,
          name: 'What Gets Weighted',
          blurb: 'Name the two columns. The formula does the rest.',
          built: true,
          brief: weightedBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'linear-regression-correlation',
      name: 'Linear Regression & Correlation',
      subtopicId: 'descriptive-statistics',
      games: [
        GameDef(
          id: 'read-the-scatter',
          rounds: 6,
          name: 'Read the Scatter',
          blurb: 'The lean gives the sign, the tightness gives the size.',
          built: true,
          brief: correlationBrief,
        ),
        GameDef(
          id: 'through-the-means',
          rounds: 6,
          name: 'Through the Means',
          blurb: 'Only one of these lines could be the regression.',
          built: true,
          brief: regressionLineBrief,
        ),
        GameDef(
          id: 'r-or-r2',
          rounds: 6,
          name: 'Which One Do They Want',
          blurb: 'Correlation or determination. The question is in English.',
          built: true,
          brief: determinationBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'probability-distributions',
      name: 'Probability Distributions',
      subtopicId: 'probability',
      games: [
        GameDef(
          id: 'same-pick',
          rounds: 6,
          name: 'Same Pick, or Not',
          blurb: 'Two outcomes, same names. One result, or two?',
          built: true,
          brief: countingBrief,
        ),
        GameDef(
          id: 'build-the-binomial',
          rounds: 6,
          name: 'Build the Binomial',
          blurb: 'Three factors from a tray of six. No multiplying.',
          built: true,
          brief: binomialBrief,
        ),
        GameDef(
          id: 'shade-the-tail',
          rounds: 6,
          name: 'Shade the Tail',
          blurb: 'The z is done. Point at the area they asked for.',
          built: true,
          brief: normalTableBrief,
        ),
        GameDef(
          id: 'how-do-they-sit',
          rounds: 6,
          name: 'How Do They Sit',
          blurb: 'Can both happen? Does one move the other? Then pick a rule.',
          built: true,
          brief: lawsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'expected-value-weighted-averages',
      name: 'Expected Value & Weighted Averages',
      subtopicId: 'probability',
      games: [
        GameDef(
          id: 'where-it-balances',
          rounds: 6,
          name: 'Where It Balances',
          blurb: 'Load the beam. Which fulcrum holds it level?',
          built: true,
          brief: expectedValueBrief,
        ),
        GameDef(
          id: 'mind-the-order',
          rounds: 6,
          name: 'Mind the Order',
          blurb: 'Both totals are on screen. Which one goes first?',
          built: true,
          brief: varianceShortcutBrief,
        ),
        GameDef(
          id: 'add-the-squares',
          rounds: 6,
          name: 'Add the Squares',
          blurb: 'Two spreads, one triangle. Never the sum.',
          built: true,
          brief: combiningBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'confidence-intervals-estimation',
      name: 'Confidence Intervals & Estimation',
      subtopicId: 'inferential-statistics',
      games: [
        GameDef(
          id: 'what-goes-under',
          rounds: 6,
          name: 'What Goes Under',
          blurb: 'One piece is missing. Watch the interval redraw.',
          built: true,
          brief: marginOfErrorBrief,
        ),
        GameDef(
          id: 'wider-or-narrower',
          rounds: 6,
          name: 'Wider or Narrower',
          blurb: 'One thing changes. Which way does the interval move?',
          built: true,
          brief: zOrTBrief,
        ),
        GameDef(
          id: 'how-many-samples',
          rounds: 6,
          name: 'How Many Samples',
          blurb: 'Get under the line, and round up.',
          built: true,
          brief: sampleSizeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'hypothesis-testing-goodness-of-fit',
      name: 'Hypothesis Testing & Goodness of Fit',
      subtopicId: 'inferential-statistics',
      games: [
        GameDef(
          id: 'which-way-points',
          rounds: 6,
          name: 'Which Way Does It Point',
          blurb: 'The claim decides the picture. One tail, or two.',
          built: true,
          brief: hypothesesBrief,
        ),
        GameDef(
          id: 'reject-or-not',
          rounds: 6,
          name: 'Reject or Not',
          blurb: 'Both numbers are given. The conclusion is the work.',
          built: true,
          brief: decisionRuleBrief,
        ),
        GameDef(
          id: 'which-cell-hurts',
          rounds: 6,
          name: 'Which Cell Hurts Most',
          blurb: 'The biggest gap is not always the biggest problem.',
          built: true,
          brief: goodnessOfFitBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 3. Lesson and subtopic names match the web content exactly
/// (`src/data/chapters/ethics.js`, `src/data/lessons/ethics/`). No formulas in
/// the whole chapter: every problem is a scenario, and every item here is
/// answered by judgment rather than by reading a number off anything.
const ethicsMap = ChapterMap(
  id: 'ethics',
  number: 3,
  name: 'Ethics & Professional Practice',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('professional-conduct', 'Professional Conduct'),
    Subtopic('licensure-and-law', 'Licensure & Law'),
    Subtopic('contracts-liability', 'Contracts & Liability'),
    Subtopic('broader-responsibilities', 'Broader Responsibilities'),
  ],
  lessons: [
    LessonNode(
      id: 'obligations-to-the-public',
      name: 'Obligations to the Public',
      subtopicId: 'professional-conduct',
      games: [
        GameDef(
          id: 'what-it-triggers',
          rounds: 6,
          name: 'What Does It Trigger',
          blurb: 'Five obligations, one scenario. Which one is this?',
          built: true,
          brief: publicFirstBrief,
        ),
        GameDef(
          id: 'in-what-order',
          rounds: 6,
          name: 'In What Order',
          blurb: 'Three of the four, in the order you would take them.',
          built: true,
          brief: escalationBrief,
        ),
        GameDef(
          id: 'enough-or-too-far',
          rounds: 6,
          name: 'Enough, or Too Far',
          blurb: 'Meaning well is not a procedure. Nor is quitting.',
          built: true,
          brief: proportionBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'obligations-employers-clients-peers',
      name: 'Obligations to Employers, Clients & Other Licensees',
      subtopicId: 'professional-conduct',
      games: [
        GameDef(
          id: 'can-you-seal-it',
          rounds: 6,
          name: 'Can You Seal It',
          blurb: 'Your field, and your charge. Both, or neither.',
          built: true,
          brief: competenceBrief,
        ),
        GameDef(
          id: 'who-has-to-agree',
          rounds: 6,
          name: 'Who Has to Agree',
          blurb: 'Tap everyone who has to sign off. It may be nobody.',
          built: true,
          brief: consentBrief,
        ),
        GameDef(
          id: 'can-you-claim-that',
          rounds: 6,
          name: 'Can You Claim That',
          blurb: 'Three lines for the brochure. One you may write.',
          built: true,
          brief: claimsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'definitions-practice-of-engineering',
      name: 'Definitions & Practice of Engineering',
      subtopicId: 'licensure-and-law',
      games: [
        GameDef(
          id: 'who-may-do-that',
          rounds: 6,
          name: 'Who May Do That',
          blurb: 'The lowest standing that is enough. Often nobody licensed.',
          built: true,
          brief: standingBrief,
        ),
        GameDef(
          id: 'does-it-hold',
          rounds: 6,
          name: 'Does the Exemption Hold',
          blurb: 'Two conditions. Which one does this one break?',
          built: true,
          brief: exemptionBrief,
        ),
        GameDef(
          id: 'practice-or-title',
          rounds: 6,
          name: 'Practice, or the Title',
          blurb: 'Two offenses that usually travel together.',
          built: true,
          brief: holdingOutBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'licensure-path-disciplinary-action',
      name: 'Licensure Path & Disciplinary Action',
      subtopicId: 'licensure-and-law',
      games: [
        GameDef(
          id: 'what-is-missing-yet',
          rounds: 6,
          name: 'What Is Missing Yet',
          blurb: 'A record on the board\'s desk. What does it still lack?',
          built: true,
          brief: ladderBrief,
        ),
        GameDef(
          id: 'grounds-or-not',
          rounds: 6,
          name: 'Grounds, or Not',
          blurb: 'Four events at once. Each one answered on its own.',
          built: true,
          brief: disciplineBrief,
        ),
        GameDef(
          id: 'which-section',
          rounds: 6,
          name: 'Which Section',
          blurb: 'Ask whether they hold a licence before anything else.',
          built: true,
          brief: sectionsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'engineering-contracts',
      name: 'Engineering Contracts',
      subtopicId: 'contracts-liability',
      games: [
        GameDef(
          id: 'is-there-a-deal',
          rounds: 6,
          name: 'Is There a Deal Yet',
          blurb: 'Tap the line the exchange became binding on.',
          built: true,
          brief: formationBrief,
        ),
        GameDef(
          id: 'who-pays-the-overrun',
          rounds: 6,
          name: 'Who Pays the Overrun',
          blurb: 'The bar ran past the line. Somebody absorbs it.',
          built: true,
          brief: riskBrief,
        ),
        GameDef(
          id: 'which-delivery',
          rounds: 6,
          name: 'Which Delivery',
          blurb: 'Count the lines running out of the owner.',
          built: true,
          brief: deliveryBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'professional-liability',
      name: 'Professional Liability',
      subtopicId: 'contracts-liability',
      games: [
        GameDef(
          id: 'is-that-negligence',
          rounds: 6,
          name: 'Is That Negligence',
          blurb: 'Not perfection, and not intent. A peer would have done what?',
          built: true,
          brief: standardOfCareBrief,
        ),
        GameDef(
          id: 'which-element-missing',
          rounds: 6,
          name: 'Which Element Is Missing',
          blurb: 'Four elements. A claim needs all of them.',
          built: true,
          brief: negligenceBrief,
        ),
        GameDef(
          id: 'which-clock-ran-out',
          rounds: 6,
          name: 'Which Clock Ran Out',
          blurb: 'Two windows on one line. The claim lands in both, or not.',
          built: true,
          brief: clocksBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'intellectual-property-sustainability',
      name: 'Intellectual Property & Sustainability',
      subtopicId: 'broader-responsibilities',
      games: [
        GameDef(
          id: 'which-protection',
          rounds: 6,
          name: 'Which Protection',
          blurb: 'Whether you are willing to publish decides most of it.',
          built: true,
          brief: propertyBrief,
        ),
        GameDef(
          id: 'how-many-protections',
          rounds: 6,
          name: 'How Many Protections',
          blurb: 'They do not compete. Tap every one this needs.',
          built: true,
          brief: portfolioBrief,
        ),
        GameDef(
          id: 'over-the-whole-life',
          rounds: 6,
          name: 'Over the Whole Life',
          blurb: 'Cheapest to build is not cheapest to own. Usually.',
          built: true,
          brief: lifeCycleBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 4. Lesson and subtopic names match the web content exactly
/// (`src/data/chapters/economics.js`, `src/data/lessons/economics/`).
const economicsMap = ChapterMap(
  id: 'economics',
  number: 4,
  name: 'Engineering Economics',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('time-value-of-money', 'Time Value of Money'),
    Subtopic('cost-and-economic-analysis', 'Cost & Economic Analysis'),
    Subtopic('depreciation-and-finance', 'Depreciation & Finance'),
  ],
  lessons: [
    LessonNode(
      id: 'equivalence-interest-factors',
      name: 'Equivalence & Interest Factors',
      subtopicId: 'time-value-of-money',
      games: [
        GameDef(
          id: 'which-factor',
          rounds: 6,
          name: 'Which Factor',
          blurb: 'Read the diagram. Solid is what you have.',
          built: true,
          brief: factorsBrief,
        ),
        GameDef(
          id: 'which-rate',
          rounds: 6,
          name: 'Which Rate',
          blurb: 'One quote, three numbers. Which one was asked for?',
          built: true,
          brief: ratesBrief,
        ),
        GameDef(
          id: 'what-does-it-take',
          rounds: 6,
          name: 'What Does It Take',
          blurb: 'Some diagrams are two cash flows stacked. Count them.',
          built: true,
          brief: piecesBrief,
        ),
        GameDef(
          id: 'when-does-it-land',
          rounds: 6,
          name: 'When Does It Land',
          blurb: 'Tap the period. The beginning of a year is not its number.',
          built: true,
          brief: periodBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'pw-fw-aw-analysis',
      name: 'Present Worth, Future Worth & Annual Worth',
      subtopicId: 'time-value-of-money',
      games: [
        GameDef(
          id: 'which-way-it-pushes',
          rounds: 6,
          name: 'Which Way It Pushes',
          blurb: 'Up, down, or out of the comparison altogether.',
          built: true,
          brief: annualCostBrief,
        ),
        GameDef(
          id: 'how-long-to-compare',
          rounds: 6,
          name: 'How Long to Compare Over',
          blurb: 'Two lives on one line. Where do they end together?',
          built: true,
          brief: studyPeriodBrief,
        ),
        GameDef(
          id: 'do-they-agree',
          rounds: 6,
          name: 'Do They Agree',
          blurb: 'Two methods, two answers. Something was not the same.',
          built: true,
          brief: methodsAgreeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'cost-types-breakeven',
      name: 'Cost Types & Break-Even Analysis',
      subtopicId: 'cost-and-economic-analysis',
      games: [
        GameDef(
          id: 'which-bucket',
          rounds: 6,
          name: 'Which Bucket',
          blurb: 'Five kinds of cost. Two of them nobody reaches for.',
          built: true,
          brief: costTypesBrief,
        ),
        GameDef(
          id: 'which-side-wins',
          rounds: 6,
          name: 'Which Side Wins',
          blurb: 'Two lines, one volume marked. Which is cheaper there?',
          built: true,
          brief: breakEvenBrief,
        ),
        GameDef(
          id: 'what-is-the-saving',
          rounds: 6,
          name: 'What Is the Saving',
          blurb: 'Nothing to divide. Which number goes underneath?',
          built: true,
          brief: paybackBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'benefit-cost-decision-trees',
      name: 'Benefit-Cost Analysis & Decision Trees',
      subtopicId: 'cost-and-economic-analysis',
      games: [
        GameDef(
          id: 'where-does-it-go',
          rounds: 6,
          name: 'Where Does It Go',
          blurb: 'On top, off the top, or underneath. One of three.',
          built: true,
          brief: ratioBrief,
        ),
        GameDef(
          id: 'which-one-do-you-build',
          rounds: 6,
          name: 'Which One Do You Build',
          blurb: 'The best ratio is usually the wrong answer.',
          built: true,
          brief: incrementalBrief,
        ),
        GameDef(
          id: 'roll-it-back',
          rounds: 6,
          name: 'Roll It Back',
          blurb: 'A tree with a square, some circles, and a price on every end.',
          built: true,
          brief: rollbackBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'rate-of-return',
      name: 'Rate of Return',
      subtopicId: 'cost-and-economic-analysis',
      games: [
        GameDef(
          id: 'balance-the-rate',
          rounds: 6,
          name: 'Balance the Rate',
          blurb: 'Two bars and a line. Find the rate that meets it.',
          built: true,
          brief: irrBrief,
        ),
        GameDef(
          id: 'over-the-bar',
          rounds: 6,
          name: 'Over the Bar',
          blurb: 'The hurdle is drawn. Who clears it?',
          built: true,
          brief: marrBrief,
        ),
        GameDef(
          id: 'which-earns-more',
          rounds: 6,
          name: 'Which Earns More',
          blurb: 'Two diagrams, one scale. The bigger total often loses.',
          built: true,
          brief: timingBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'depreciation-taxation-inflation',
      name: 'Depreciation, Taxation & Inflation',
      subtopicId: 'depreciation-and-finance',
      games: [
        GameDef(
          id: 'find-the-factor',
          rounds: 6,
          name: 'Find the Factor',
          blurb: 'The table is right there. Tap the cell.',
          built: true,
          brief: macrsBrief,
        ),
        GameDef(
          id: 'where-the-cost-went',
          rounds: 6,
          name: 'Where the Cost Went',
          blurb: 'One bar, three stretches. Which one answers it?',
          built: true,
          brief: bookValueBrief,
        ),
        GameDef(
          id: 'match-the-dollars',
          rounds: 6,
          name: 'Match the Dollars',
          blurb: 'Four rates, two of them a tenth of a point apart.',
          built: true,
          brief: inflationBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 5. Lesson and subtopic names match the web content exactly
/// (`src/data/chapters/statics.js`, `src/data/lessons/statics/`).
const staticsMap = ChapterMap(
  id: 'statics',
  number: 5,
  name: 'Statics',
  examLine: '8 to 12 questions on the real exam',
  subtopics: [
    Subtopic('forces-and-equilibrium', 'Forces & Equilibrium'),
    Subtopic('trusses-and-friction', 'Trusses & Friction'),
    Subtopic('section-properties', 'Section Properties'),
  ],
  lessons: [
    LessonNode(
      id: 'force-systems-resultants',
      name: 'Force Systems & Resultants',
      subtopicId: 'forces-and-equilibrium',
      games: [
        GameDef(
          id: 'which-arrow-is-that',
          rounds: 6,
          name: 'Which Arrow Is That',
          blurb: 'One number, three arrows, all drawn to scale.',
          built: true,
          brief: resolveBrief,
        ),
        GameDef(
          id: 'which-distance-counts',
          rounds: 6,
          name: 'Which Distance Counts',
          blurb: 'Every distance on the drawing is real. One is the arm.',
          built: true,
          brief: momentBrief,
        ),
        GameDef(
          id: 'which-ones-turn-it',
          rounds: 6,
          name: 'Which Ones Turn It',
          blurb: 'No magnitudes. Just which way each one rolls it.',
          built: true,
          brief: senseBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'equilibrium-free-body-diagrams',
      name: 'Equilibrium & Free-Body Diagrams',
      subtopicId: 'forces-and-equilibrium',
      games: [
        GameDef(
          id: 'what-the-support-gives',
          rounds: 6,
          name: 'What the Support Gives',
          blurb: 'Three pictures of arrows. Which one is this support?',
          built: true,
          brief: supportsBrief,
        ),
        GameDef(
          id: 'where-it-all-acts',
          rounds: 6,
          name: 'Where It All Acts',
          blurb: 'One force instead of the whole load. Tap where it goes.',
          built: true,
          brief: resultantBrief,
        ),
        GameDef(
          id: 'can-statics-solve-it',
          rounds: 6,
          name: 'Can Statics Solve It',
          blurb: 'Count the unknowns before you write anything down.',
          built: true,
          brief: determinacyBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'trusses-joints-sections',
      name: 'Trusses: Joints & Sections',
      subtopicId: 'trusses-and-friction',
      games: [
        GameDef(
          id: 'which-carry-nothing',
          rounds: 6,
          name: 'Which Ones Carry Nothing',
          blurb: 'Scan the joints. Tap every member doing no work.',
          built: true,
          brief: zeroForceBrief,
        ),
        GameDef(
          id: 'stretched-or-squashed',
          rounds: 6,
          name: 'Stretched or Squashed',
          blurb: 'One member lit up. Say which way it is being worked.',
          built: true,
          brief: senseOfForceBrief,
        ),
        GameDef(
          id: 'where-do-you-cut',
          rounds: 6,
          name: 'Where Do You Cut',
          blurb: 'Three lines across the truss. Only one of them pays.',
          built: true,
          brief: sectionBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'friction',
      name: 'Friction',
      subtopicId: 'trusses-and-friction',
      games: [
        GameDef(
          id: 'is-it-about-to-move',
          rounds: 6,
          name: 'Is It About to Move',
          blurb: 'Friction is a ceiling. Say where it is sitting right now.',
          built: true,
          brief: ceilingBrief,
        ),
        GameDef(
          id: 'which-side-is-tight',
          rounds: 6,
          name: 'Which Side Is Tight',
          blurb: 'Follow the chevrons. Tap the end carrying more.',
          built: true,
          brief: beltBrief,
        ),
        GameDef(
          id: 'harder-or-easier',
          rounds: 6,
          name: 'Harder or Easier',
          blurb: 'One thing changes. Does it take more push, or less?',
          built: true,
          brief: normalForceBrief,
        ),
        GameDef(
          id: 'will-it-hold-itself',
          rounds: 6,
          name: 'Will It Hold Itself',
          blurb: 'Two angles on one baseline. The steeper one decides.',
          built: true,
          brief: screwBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'frames-machines',
      name: 'Frames & Machines',
      subtopicId: 'trusses-and-friction',
      games: [
        GameDef(
          id: 'along-it-or-not',
          rounds: 6,
          name: 'Along It or Not',
          blurb: 'Tap the arrow, or say the shape does not settle it.',
          built: true,
          brief: twoForceBrief,
        ),
        GameDef(
          id: 'does-it-multiply',
          rounds: 6,
          name: 'Does It Multiply',
          blurb: 'Look at which arm is longer before anything else.',
          built: true,
          brief: leverBrief,
        ),
        GameDef(
          id: 'frame-truss-or-machine',
          rounds: 6,
          name: 'Frame, Truss or Machine',
          blurb: 'What it is called decides what you may assume.',
          built: true,
          brief: whatItIsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'centroids-composite-shapes',
      name: 'Centroids & Composite Shapes',
      subtopicId: 'section-properties',
      games: [
        GameDef(
          id: 'above-or-below-middle',
          rounds: 6,
          name: 'Above or Below the Middle',
          blurb: 'The centroid sits where the metal is. Which side?',
          built: true,
          brief: areaWeightedBrief,
        ),
        GameDef(
          id: 'tap-its-centroid',
          rounds: 6,
          name: 'Tap Its Centroid',
          blurb: 'One shape, three candidates. The table knows.',
          built: true,
          brief: tableBrief,
        ),
        GameDef(
          id: 'which-distance-goes-in',
          rounds: 6,
          name: 'Which Distance Goes In',
          blurb: 'One axis, every piece. Tap the one that belongs.',
          built: true,
          brief: referenceBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'area-moments-of-inertia',
      name: 'Area Moments of Inertia',
      subtopicId: 'section-properties',
      games: [
        GameDef(
          id: 'rank-by-stiffness',
          rounds: 6,
          name: 'Rank Them by Stiffness',
          blurb: 'Three sections, one scale. Tap them stiffest first.',
          built: true,
          brief: farFromAxisBrief,
        ),
        GameDef(
          id: 'move-it-right',
          rounds: 6,
          name: 'Move It Right',
          blurb: 'Two axes. Does the transfer term go on, or come off?',
          built: true,
          brief: transferBrief,
        ),
        GameDef(
          id: 'which-barely-matters',
          rounds: 6,
          name: 'Which One Barely Matters',
          blurb: 'Tap the piece you could very nearly leave out.',
          built: true,
          brief: compositeIBrief,
        ),
        GameDef(
          id: 'which-second-moment',
          rounds: 6,
          name: 'Which Second Moment',
          blurb: 'Bending or twisting? The load decides, not the shape.',
          built: true,
          brief: polarBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 7. Chapter six, Dynamics, is not built yet: this one follows
/// Statics because the centroid and second moment lessons that close chapter
/// five are exactly what bending stress needs.
const mechanicsMaterialsMap = ChapterMap(
  id: 'mechanics-materials',
  number: 7,
  name: 'Mechanics of Materials',
  examLine: '7 to 11 questions on the real exam',
  subtopics: [
    Subtopic('stress-strain-fundamentals', 'Stress, Strain & Material Behavior'),
    Subtopic('beams', 'Beams'),
    Subtopic('combined-loading-stability', 'Combined Loading & Stability'),
  ],
  lessons: [
    LessonNode(
      id: 'axial-stress-strain-deformation',
      name: 'Axial Stress, Strain & Deformation',
      subtopicId: 'stress-strain-fundamentals',
      games: [
        GameDef(
          id: 'which-stretches-more',
          rounds: 6,
          name: 'Which Stretches More',
          blurb: 'Two bars, one scale. Which one moves further?',
          built: true,
          brief: deformationBrief,
        ),
        GameDef(
          id: 'what-comes-out',
          rounds: 6,
          name: 'What Comes Out',
          blurb: 'Units on every term. Say what the answer is.',
          built: true,
          brief: unitsBrief,
        ),
        GameDef(
          id: 'does-it-build-stress',
          rounds: 6,
          name: 'Does It Build Stress',
          blurb: 'Warm it, cool it, give it room. What is it left carrying?',
          built: true,
          brief: thermalBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'torsion',
      name: 'Torsion',
      subtopicId: 'stress-strain-fundamentals',
      games: [
        GameDef(
          id: 'which-j-is-it',
          rounds: 6,
          name: 'Which J Is It',
          blurb: 'The formula is written. Pick what goes under Tc.',
          built: true,
          brief: polarJBrief,
        ),
        GameDef(
          id: 'stress-or-twist',
          rounds: 6,
          name: 'Stress or Twist',
          blurb: 'Change one thing about the shaft. Say what moved.',
          built: true,
          brief: twistBrief,
        ),
        GameDef(
          id: 'which-area-twists-it',
          rounds: 6,
          name: 'Which Area Twists It',
          blurb: 'Three shaded areas on a tube. Only one belongs in the formula.',
          built: true,
          brief: thinWallBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'stress-strain-diagrams',
      name: 'Stress-Strain Diagrams & Material Behavior',
      subtopicId: 'stress-strain-fundamentals',
      games: [
        GameDef(
          id: 'where-on-the-curve',
          rounds: 6,
          name: 'Where On the Curve',
          blurb: 'One tensile curve. Tap the point that does what is asked.',
          built: true,
          brief: curveBrief,
        ),
        GameDef(
          id: 'stiff-strong-or-stretchy',
          rounds: 6,
          name: 'Stiff, Strong or Stretchy',
          blurb: 'Two curves, one set of axes. Read the right feature.',
          built: true,
          brief: stiffStrongBrief,
        ),
        GameDef(
          id: 'can-you-get-there',
          rounds: 6,
          name: 'Can You Get There',
          blurb: 'What you have and what you want. Is there a road?',
          built: true,
          brief: linkedBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'shear-moment-diagrams',
      name: 'Shear & Moment Diagrams',
      subtopicId: 'beams',
      games: [
        GameDef(
          id: 'which-diagram-belongs',
          rounds: 6,
          name: 'Which Diagram Belongs',
          blurb: 'One beam, three diagrams. Only one of them is its own.',
          built: true,
          brief: slopeRulesBrief,
        ),
        GameDef(
          id: 'where-it-peaks',
          rounds: 6,
          name: 'Where It Peaks',
          blurb: 'Tap the place on the beam that bends the hardest.',
          built: true,
          brief: peakBrief,
        ),
        GameDef(
          id: 'jump-bend-or-neither',
          rounds: 6,
          name: 'Jump, Bend or Neither',
          blurb: 'One marked point. Say what the diagram does there.',
          built: true,
          brief: jumpBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'bending-shear-stresses',
      name: 'Bending & Shear Stresses in Beams',
      subtopicId: 'beams',
    ),
    LessonNode(
      id: 'beam-deflections',
      name: 'Beam Deflections',
      subtopicId: 'beams',
    ),
    LessonNode(
      id: 'transformed-sections-plastic',
      name: 'Transformed Sections & Plastic Moment',
      subtopicId: 'beams',
    ),
    LessonNode(
      id: 'combined-stresses-mohrs-circle',
      name: "Combined Stresses & Mohr's Circle",
      subtopicId: 'combined-loading-stability',
    ),
    LessonNode(
      id: 'column-buckling',
      name: 'Column Buckling',
      subtopicId: 'combined-loading-stability',
    ),
  ],
);

const chapterMaps = <String, ChapterMap>{
  'mathematics': mathematicsMap,
  'statistics': statisticsMap,
  'ethics': ethicsMap,
  'economics': economicsMap,
  'statics': staticsMap,
  'mechanics-materials': mechanicsMaterialsMap,
};

ChapterMap? mapForChapter(String chapterId) => chapterMaps[chapterId];
