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
          brief: trussRouteBrief,
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
          brief: foodRatioBrief,
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
          brief: tieLineBrief,
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
          brief: catchmentBrief,
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

/// Chapter 6.
const dynamicsMap = ChapterMap(
  id: 'dynamics',
  number: 6,
  name: 'Dynamics',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('kinematics', 'Kinematics'),
    Subtopic('kinetics-and-energy', 'Kinetics & Energy'),
    Subtopic('momentum-and-vibrations', 'Momentum & Vibrations'),
  ],
  lessons: [
    LessonNode(
      id: 'particle-kinematics',
      name: 'Particle Kinematics',
      subtopicId: 'kinematics',
      games: [
        GameDef(
          id: 'what-is-missing',
          rounds: 6,
          name: 'What Is Missing',
          blurb: 'Four equations, and the one you want is decided by absence.',
          built: true,
          brief: missingBrief,
        ),
        GameDef(
          id: 'tap-the-trajectory',
          rounds: 6,
          name: 'Tap the Trajectory',
          blurb: 'One arc, five moments. Which one is the question about?',
          built: true,
          brief: flightBrief,
        ),
        GameDef(
          id: 'speeding-up-or-turning',
          rounds: 6,
          name: 'Speeding Up or Turning',
          blurb: 'On a bend, two accelerations at right angles. Which is which?',
          built: true,
          brief: bendBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'rigid-body-kinematics-mass-moi',
      name: 'Rigid Body Kinematics & Mass Moments of Inertia',
      subtopicId: 'kinematics',
      games: [
        GameDef(
          id: 'same-spin-different-speed',
          rounds: 6,
          name: 'Same Spin, Different Speed',
          blurb: 'One body turning. Every point at its own speed.',
          built: true,
          brief: spinBrief,
        ),
        GameDef(
          id: 'harder-to-spin',
          rounds: 6,
          name: 'Harder to Spin',
          blurb: 'Same mass both sides. Where it sits decides.',
          built: true,
          brief: spinInertiaBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'force-and-acceleration',
      name: 'Force & Acceleration',
      subtopicId: 'kinetics-and-energy',
      games: [
        GameDef(
          id: 'mass-or-weight',
          rounds: 6,
          name: 'Mass or Weight',
          blurb: 'Read the units before you write anything down.',
          built: true,
          brief: weightBrief,
        ),
        GameDef(
          id: 'which-piece-drives-it',
          rounds: 6,
          name: 'Which Piece Drives It',
          blurb: 'Gravity pulls down. The slope decides what gets through.',
          built: true,
          brief: slopeBrief,
        ),
        GameDef(
          id: 'push-it-or-spin-it',
          rounds: 6,
          name: 'Push It or Spin It',
          blurb: 'One force, two equations. Which one does this need?',
          built: true,
          brief: twoEquationsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'work-energy-power',
      name: 'Work, Energy & Power',
      subtopicId: 'kinetics-and-energy',
      games: [
        GameDef(
          id: 'where-the-energy-goes',
          rounds: 6,
          name: 'Where the Energy Goes',
          blurb: 'Before and after, in buckets. Which account is this?',
          built: true,
          brief: ledgerBrief,
        ),
        GameDef(
          id: 'does-the-mass-matter',
          rounds: 6,
          name: 'Does the Mass Matter',
          blurb: 'Heavy, light, or no difference at all?',
          built: true,
          brief: cancelBrief,
        ),
        GameDef(
          id: 'more-in-than-out',
          rounds: 6,
          name: 'More In Than Out',
          blurb: 'Power in one step, and which way efficiency runs.',
          built: true,
          brief: powerBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'impulse-and-momentum',
      name: 'Impulse & Momentum',
      subtopicId: 'momentum-and-vibrations',
      games: [
        GameDef(
          id: 'stick-or-bounce',
          rounds: 6,
          name: 'Stick or Bounce',
          blurb: 'Read the sentence. It tells you how many equations.',
          built: true,
          brief: impactBrief,
        ),
        GameDef(
          id: 'what-survives-the-crash',
          rounds: 6,
          name: 'What Survives the Crash',
          blurb: 'Momentum always. Energy hardly ever.',
          built: true,
          brief: survivesBrief,
        ),
        GameDef(
          id: 'stretch-the-time',
          rounds: 6,
          name: 'Stretch the Time',
          blurb: 'Same area, different shape. That is a crumple zone.',
          built: true,
          brief: impulseBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'vibrations-natural-frequency',
      name: 'Vibrations & Natural Frequency',
      subtopicId: 'momentum-and-vibrations',
      games: [
        GameDef(
          id: 'faster-or-slower',
          rounds: 6,
          name: 'Faster or Slower',
          blurb: 'Stiffness over mass, and nothing else gets a say.',
          built: true,
          brief: naturalBrief,
        ),
        GameDef(
          id: 'when-it-runs-away',
          rounds: 6,
          name: 'When It Runs Away',
          blurb: 'Two frequencies, three units. Are they too close?',
          built: true,
          brief: resonanceBrief,
        ),
        GameDef(
          id: 'how-it-settles',
          rounds: 6,
          name: 'How It Settles',
          blurb: 'Pulled aside and let go. Which curve is this?',
          built: true,
          brief: dampingBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 7, which follows Statics because the centroid and second moment
/// lessons that close chapter five are exactly what bending stress needs.
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
      games: [
        GameDef(
          id: 'which-fiber-is-worst',
          rounds: 6,
          name: 'Which Fiber Is Worst',
          blurb: 'Tap the layer of the section that is working hardest.',
          built: true,
          brief: fiberBrief,
        ),
        GameDef(
          id: 'which-width-which-area',
          rounds: 6,
          name: 'Which Width, Which Area',
          blurb: 'One cut, three candidates. What goes into VQ over Ib?',
          built: true,
          brief: cutBrief,
        ),
        GameDef(
          id: 'which-one-gets-worse',
          rounds: 6,
          name: 'Which One Gets Worse',
          blurb: 'Change one thing about the beam. Say which stress goes up.',
          built: true,
          brief: governsBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'beam-deflections',
      name: 'Beam Deflections',
      subtopicId: 'beams',
      games: [
        GameDef(
          id: 'which-line-in-the-table',
          rounds: 6,
          name: 'Which Line in the Table',
          blurb: 'Read the supports and the load. Pick the entry.',
          built: true,
          brief: tableBrief2,
        ),
        GameDef(
          id: 'fix-the-bounce',
          rounds: 6,
          name: 'Fix the Bounce',
          blurb: 'The floor is springy. Which one change buys the most?',
          built: true,
          brief: bounceBrief,
        ),
        GameDef(
          id: 'add-it-up',
          rounds: 6,
          name: 'Add It Up',
          blurb: 'Two loads at once. Which split adds back up to the beam?',
          built: true,
          brief: addBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'transformed-sections-plastic',
      name: 'Transformed Sections & Plastic Moment',
      subtopicId: 'beams',
      games: [
        GameDef(
          id: 'widen-the-stiff-one',
          rounds: 6,
          name: 'Widen the Stiff One',
          blurb: 'Two materials, one section. Tap the transformed one.',
          built: true,
          brief: transformBrief,
        ),
        GameDef(
          id: 'same-strain',
          rounds: 6,
          name: 'Same Strain, Different Stress',
          blurb: 'At the join, which one is carrying more?',
          built: true,
          brief: joinBrief,
        ),
        GameDef(
          id: 'how-far-has-it-yielded',
          rounds: 6,
          name: 'How Far Has It Yielded',
          blurb: 'Four stages from elastic to fully plastic. Tap the block.',
          built: true,
          brief: plasticBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'combined-stresses-mohrs-circle',
      name: "Combined Stresses & Mohr's Circle",
      subtopicId: 'combined-loading-stability',
      games: [
        GameDef(
          id: 'read-the-circle',
          rounds: 6,
          name: 'Read the Circle',
          blurb: 'Every answer is a place on it. Tap the right one.',
          built: true,
          brief: circleBrief,
        ),
        GameDef(
          id: 'which-circle-is-it',
          rounds: 6,
          name: 'Which Circle Is It',
          blurb: 'One stressed point, three circles. Only one fits.',
          built: true,
          brief: buildBrief,
        ),
        GameDef(
          id: 'is-r-the-worst',
          rounds: 6,
          name: 'Is R the Worst',
          blurb: 'The radius, or something worse out of the page?',
          built: true,
          brief: worstBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'column-buckling',
      name: 'Column Buckling',
      subtopicId: 'combined-loading-stability',
      games: [
        GameDef(
          id: 'what-are-the-ends-worth',
          rounds: 6,
          name: 'What Are the Ends Worth',
          blurb: 'Read how each end is held. Pick the factor.',
          built: true,
          brief: endsBrief,
        ),
        GameDef(
          id: 'which-way-does-it-fold',
          rounds: 6,
          name: 'Which Way Does It Fold',
          blurb: 'A column picks its weakest axis. Which one is it?',
          built: true,
          brief: weakAxisBrief,
        ),
        GameDef(
          id: 'buckle-or-squash',
          rounds: 6,
          name: 'Buckle or Squash',
          blurb: 'One curve says which failure gets there first.',
          built: true,
          brief: slenderBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 8. Its first lesson shares a name with chapter seven's opener and
/// almost nothing else: this one is about what a test REPORT says, which is
/// where engineering and true values part company.
const materialsMap = ChapterMap(
  id: 'materials',
  number: 8,
  name: 'Materials',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('mechanical-properties', 'Mechanical Properties'),
    Subtopic('concrete-technology', 'Concrete Technology'),
    Subtopic('construction-materials', 'Construction Materials'),
    Subtopic('composites-selection', 'Composites & Selection'),
  ],
  lessons: [
    LessonNode(
      id: 'stress-strain-material-behavior',
      name: 'Stress-Strain Behavior & Material Properties',
      subtopicId: 'mechanical-properties',
      // Stiffness against strength is this lesson's other idea, and chapter
      // seven already teaches it in Stiff, Strong or Stretchy. Building it
      // twice would be a worse item and a wasted sitting, so it is not here.
      games: [
        GameDef(
          id: 'before-or-during',
          rounds: 6,
          name: 'Before or During',
          blurb: 'Force over which area? Stretch over which length?',
          built: true,
          brief: underneathBrief,
        ),
        GameDef(
          id: 'true-or-engineering',
          rounds: 6,
          name: 'True or Engineering',
          blurb: 'One test, two curves. Which one is a report quoting?',
          built: true,
          brief: trueStressBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'hardness-impact-fatigue',
      name: 'Hardness, Impact & Fatigue Testing',
      subtopicId: 'mechanical-properties',
      // The lesson's other three topics have no problem behind them: hardness
      // is one multiplication, and the Charpy transition and the endurance
      // limit are taught here but never asked. Items are built from problems,
      // so those stay on paper.
      games: [
        GameDef(
          id: 'edge-or-inside',
          rounds: 6,
          name: 'Edge or Inside',
          blurb: 'Where the crack sits decides both numbers you feed in.',
          built: true,
          brief: crackBrief,
        ),
        GameDef(
          id: 'which-cracks-first',
          rounds: 6,
          name: 'Which One Cracks First',
          blurb: 'A crack length means nothing without the stress beside it.',
          built: true,
          brief: toughnessBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'thermal-processing-phase-diagrams',
      name: 'Thermal Effects, Processing & Phase Diagrams',
      subtopicId: 'mechanical-properties',
      games: [
        GameDef(
          id: 'which-one-moves-most',
          rounds: 6,
          name: 'Which One Moves Most',
          blurb: 'Material, length, temperature change. All three multiply.',
          built: true,
          brief: expandBrief,
        ),
        GameDef(
          id: 'out-of-the-furnace',
          rounds: 6,
          name: 'Out of the Furnace',
          blurb: 'How high it went and how fast it came down. That is all.',
          built: true,
          brief: furnaceBrief,
        ),
        GameDef(
          id: 'which-arm',
          rounds: 6,
          name: 'Which Arm',
          blurb: 'The lever rule, as a picture rather than a subtraction.',
          built: true,
          brief: tieLineBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'concrete-mix-design',
      name: 'Concrete Mix Design',
      subtopicId: 'concrete-technology',
      games: [
        GameDef(
          id: 'stronger-or-weaker',
          rounds: 6,
          name: 'Stronger or Weaker',
          blurb: 'Somebody changes the mix. Which way does the strength go?',
          built: true,
          brief: mixBrief,
        ),
        GameDef(
          id: 'what-this-job-needs',
          rounds: 6,
          name: 'What This Job Needs',
          blurb: 'How strong, and does it freeze? Two separate questions.',
          built: true,
          brief: exposureBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'concrete-curing-strength',
      name: 'Concrete Curing & Strength Development',
      subtopicId: 'concrete-technology',
      // Why concrete is reinforced is taught here and asked by no problem in
      // the lesson, so it is not an item.
      games: [
        GameDef(
          id: 'times-or-divided',
          rounds: 6,
          name: 'Times or Divided',
          blurb: 'One percentage, two directions. Which one is this?',
          built: true,
          brief: curingBrief,
        ),
        GameDef(
          id: 'does-it-make-the-number',
          rounds: 6,
          name: 'Does It Make the Number',
          blurb: 'The cylinder was cured in a lab. The slab was not.',
          built: true,
          brief: fieldBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'aggregate-properties',
      name: 'Aggregate Properties & Gradation',
      subtopicId: 'construction-materials',
      games: [
        GameDef(
          id: 'which-weighing',
          rounds: 6,
          name: 'Which Weighing',
          blurb: 'Three weighings, four numbers, and they are not alike.',
          built: true,
          brief: weighingBrief,
        ),
        GameDef(
          id: 'coarse-or-fine',
          rounds: 6,
          name: 'Coarse or Fine',
          blurb: 'A higher fineness modulus means coarser. Read the curve.',
          built: true,
          brief: gradingBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'asphalt-mix-design',
      name: 'Asphalt Concrete Mix Design',
      subtopicId: 'construction-materials',
      games: [
        GameDef(
          id: 'tap-the-voids',
          rounds: 6,
          name: 'Tap the Voids',
          blurb: 'Air, binder, stone. Which share is the question about?',
          built: true,
          brief: voidsBrief,
        ),
        GameDef(
          id: 'something-is-wrong',
          rounds: 6,
          name: 'Something Is Wrong Here',
          blurb: 'A mix report with one line on it that cannot be true.',
          built: true,
          brief: checkBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'wood-masonry',
      name: 'Wood & Masonry',
      subtopicId: 'construction-materials',
      games: [
        GameDef(
          id: 'above-the-point',
          rounds: 6,
          name: 'Above the Point',
          blurb: 'Thirty percent decides whether drying changes anything.',
          built: true,
          brief: moistureBrief,
        ),
        GameDef(
          id: 'which-mortar',
          rounds: 6,
          name: 'Which Mortar',
          blurb: 'Four letters in an order you cannot work out. Learn it.',
          built: true,
          brief: mortarBrief,
        ),
        GameDef(
          id: 'does-it-go-up',
          rounds: 6,
          name: 'Does It Go Up',
          blurb: 'Wood carries more the more briefly you ask it to.',
          built: true,
          brief: factorBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'composite-materials',
      name: 'Composite Materials',
      subtopicId: 'composites-selection',
      games: [
        GameDef(
          id: 'along-or-across',
          rounds: 6,
          name: 'Along or Across',
          blurb: 'Two rules for one composite. The load direction picks.',
          built: true,
          brief: catchmentBrief,
        ),
        GameDef(
          id: 'same-stretch',
          rounds: 6,
          name: 'Same Stretch, Different Stress',
          blurb: 'Whichever one the two phases share, the other one splits.',
          built: true,
          brief: isostrainBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'corrosion-material-selection',
      name: 'Corrosion & Material Selection',
      subtopicId: 'composites-selection',
      games: [
        GameDef(
          id: 'which-one-goes',
          rounds: 6,
          name: 'Which One Goes',
          blurb: 'Two metals and some water. One of them is being eaten.',
          built: true,
          brief: galvanicBrief,
        ),
        GameDef(
          id: 'check-every-box',
          rounds: 6,
          name: 'Check Every Box',
          blurb: 'The metal that wins a column rarely passes them all.',
          built: true,
          brief: pickingBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 9.
const fluidMechanicsMap = ChapterMap(
  id: 'fluid-mechanics',
  number: 9,
  name: 'Fluid Mechanics',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('fluid-properties-statics', 'Properties & Statics'),
    Subtopic('fluid-dynamics', 'Fluid Dynamics'),
    Subtopic('flow-analysis-measurement', 'Flow Analysis & Measurement'),
  ],
  lessons: [
    LessonNode(
      id: 'fluid-properties',
      name: 'Fluid Properties',
      subtopicId: 'fluid-properties-statics',
      games: [
        GameDef(
          id: 'which-property',
          rounds: 6,
          name: 'Which Property Is That',
          blurb: 'Three properties, and the units tell you which is which.',
          built: true,
          brief: threeNumbersBrief,
        ),
        GameDef(
          id: 'which-drags-more',
          rounds: 6,
          name: 'Which One Drags More',
          blurb: 'A thinner film drags harder. That is the surprising one.',
          built: true,
          brief: viscosityBrief,
        ),
        GameDef(
          id: 'which-tube-climbs',
          rounds: 6,
          name: 'Which Tube Climbs Higher',
          blurb: 'Narrow climbs higher, and mercury goes the other way.',
          built: true,
          brief: capillaryBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'hydrostatic-pressure',
      name: 'Hydrostatic Pressure & Manometers',
      subtopicId: 'fluid-properties-statics',
      games: [
        GameDef(
          id: 'same-depth',
          rounds: 6,
          name: 'Same Depth, Same Pressure',
          blurb: 'The shape of the vessel is not in the formula anywhere.',
          built: true,
          brief: depthBrief,
        ),
        GameDef(
          id: 'gauge-or-absolute',
          rounds: 6,
          name: 'Gauge or Absolute',
          blurb: 'Which zero the number you are holding counts from.',
          built: true,
          brief: gaugeBrief,
        ),
        GameDef(
          id: 'walk-the-manometer',
          rounds: 6,
          name: 'Walk the Manometer',
          blurb: 'Down adds, up subtracts, sideways does nothing.',
          built: true,
          brief: manometerBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'hydrostatic-forces-buoyancy',
      name: 'Hydrostatic Forces & Buoyancy',
      subtopicId: 'fluid-properties-statics',
      games: [
        GameDef(
          id: 'where-it-pushes',
          rounds: 6,
          name: 'Where It Pushes',
          blurb: 'Force from the centroid, moment from somewhere lower.',
          built: true,
          brief: gateBrief,
        ),
        GameDef(
          id: 'float-or-sink',
          rounds: 6,
          name: 'Float or Sink',
          blurb: 'Its weight against the weight of what it shoves aside.',
          built: true,
          brief: buoyancyBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'continuity-bernoulli',
      name: 'Continuity & Bernoulli\'s Equation',
      subtopicId: 'fluid-dynamics',
      games: [
        GameDef(
          id: 'how-much-faster',
          rounds: 6,
          name: 'How Much Faster',
          blurb: 'Half the bore is four times the speed. Mind the square.',
          built: true,
          brief: continuityBrief,
        ),
        GameDef(
          id: 'where-the-pressure-is',
          rounds: 6,
          name: 'Where the Pressure Is',
          blurb: 'Faster water is at lower pressure. It feels backwards.',
          built: true,
          brief: bernoulliBrief,
        ),
        GameDef(
          id: 'how-fast-the-jet',
          rounds: 6,
          name: 'How Fast the Jet',
          blurb: 'The head decides it. The hole decides how much.',
          built: true,
          brief: torricelliBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'pipe-flow-head-loss',
      name: 'Pipe Flow & Head Loss',
      subtopicId: 'fluid-dynamics',
      // Hazen-Williams is in the lesson and in no problem, so it stays on
      // paper rather than getting an item with nothing behind it.
      games: [
        GameDef(
          id: 'laminar-or-turbulent',
          rounds: 6,
          name: 'Laminar or Turbulent',
          blurb: 'The number decides which method comes next.',
          built: true,
          brief: reynoldsBrief,
        ),
        GameDef(
          id: 'what-happens-to-the-loss',
          rounds: 6,
          name: 'What Happens to the Loss',
          blurb: 'The velocity is squared. One pipe size up is worth thirty.',
          built: true,
          brief: seepageBrief,
        ),
        GameDef(
          id: 'add-up-the-losses',
          rounds: 6,
          name: 'Add Up the Losses',
          blurb: 'A line of working with one piece missing, or in twice.',
          built: true,
          brief: minorBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'momentum-equation',
      name: 'Momentum Equation',
      subtopicId: 'fluid-dynamics',
      // Working the force out is paper: it is an area, a flow rate, two
      // terms and a resultant, and no phone should be adding those up. What
      // the phone can carry is the judgment around it: what makes a force at
      // all, how big the turn makes it, and which way it goes.
      games: [
        GameDef(
          id: 'which-target-takes-more',
          rounds: 6,
          name: 'Which Target Takes More',
          blurb: 'It pushes by being turned, not by arriving.',
          built: true,
          brief: deflectionBrief,
        ),
        GameDef(
          id: 'which-one-needs-a-block',
          rounds: 6,
          name: 'Which One Needs a Block',
          blurb: 'Pressure alone moves nothing. Change does.',
          built: true,
          brief: thrustBrief,
        ),
        GameDef(
          id: 'where-the-block-goes',
          rounds: 6,
          name: 'Where the Block Goes',
          blurb: 'Always out on the outside of the turn.',
          built: true,
          brief: blockBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'flow-measurement',
      name: 'Flow Measurement',
      subtopicId: 'flow-analysis-measurement',
      // Two items, not three. The third thing the lesson teaches is how to
      // read a Pitot tube, and that is Bernoulli with one velocity set to
      // zero: the same concept as the Bernoulli lesson two nodes back, and
      // it does not earn a second item of its own.
      games: [
        GameDef(
          id: 'which-area-goes-in',
          rounds: 6,
          name: 'Which Area Goes In',
          blurb: 'The throat, and the tappings are how you find it.',
          built: true,
          brief: meteringBrief,
        ),
        GameDef(
          id: 'too-big-or-too-small',
          rounds: 6,
          name: 'Too Big or Too Small',
          blurb: 'Which way each slip pushes a number nobody can check.',
          built: true,
          brief: coefficientBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'dimensional-analysis-similitude',
      name: 'Dimensional Analysis & Similitude',
      subtopicId: 'flow-analysis-measurement',
      // Buckingham Pi is a subtraction, and the phone does not do
      // arithmetic. Counting variables and dimensions belongs on paper; what
      // is left, and what the two model problems are really about, is which
      // law governs and what it then asks of the model.
      games: [
        GameDef(
          id: 'which-one-to-match',
          rounds: 6,
          name: 'Which One to Match',
          blurb: 'Look for the free surface. It settles which number.',
          built: true,
          brief: similitudeBrief,
        ),
        GameDef(
          id: 'does-the-model-run-faster',
          rounds: 6,
          name: 'Does the Model Run Faster',
          blurb: 'One law says slower, the other says ten times faster.',
          built: true,
          brief: scalingBrief,
        ),
      ],
    ),
  ],
);

/// Chapter 10.
const surveyingMap = ChapterMap(
  id: 'surveying',
  number: 10,
  name: 'Surveying',
  examLine: '4 to 6 questions on the real exam',
  subtopics: [
    Subtopic('measurement-leveling', 'Measurement & Leveling'),
    Subtopic('area-volume-traverse', 'Area, Volume & Traverse'),
    Subtopic('curves', 'Horizontal & Vertical Curves'),
  ],
  lessons: [
    LessonNode(
      id: 'angles-distances-bearings',
      name: 'Angles, Distances & Bearings',
      subtopicId: 'measurement-leveling',
      // The traverse check is a sum of five angles against (n-2) times 180,
      // which is arithmetic and stays on paper. The card carries it.
      games: [
        GameDef(
          id: 'find-it-on-the-plan',
          rounds: 6,
          name: 'Find It on the Plan',
          blurb: 'The same angle sits in all four quadrants.',
          built: true,
          brief: bearingBrief,
        ),
        GameDef(
          id: 'which-rule-turns-it',
          rounds: 6,
          name: 'Which Rule Turns It',
          blurb: 'A clock face with north at twelve settles it.',
          built: true,
          brief: azimuthBrief,
        ),
        GameDef(
          id: 'which-length-is-which',
          rounds: 6,
          name: 'Which Length Is Which',
          blurb: 'One shot, three lengths, three different answers.',
          built: true,
          brief: shotBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'leveling',
      name: 'Differential Leveling',
      subtopicId: 'measurement-leveling',
      games: [
        GameDef(
          id: 'higher-or-lower',
          rounds: 6,
          name: 'Higher or Lower',
          blurb: 'The bigger reading is the lower point. Always.',
          built: true,
          brief: sightBrief,
        ),
        GameDef(
          id: 'what-is-that-point',
          rounds: 6,
          name: 'What Is That Point',
          blurb: 'Count the instruments that can see the rod.',
          built: true,
          brief: runBrief,
        ),
        GameDef(
          id: 'which-run-is-allowed-more',
          rounds: 6,
          name: 'Which Run Is Allowed More',
          blurb: 'Four times the distance buys twice the room.',
          built: true,
          brief: closureBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'traverse-computations',
      name: 'Traverse Computations',
      subtopicId: 'area-volume-traverse',
      // The sines, the square root and the ratio are all desk work. What
      // travels is the judgment around them: the two signs, how the closure
      // is shared out, and why precision is written as a ratio at all.
      games: [
        GameDef(
          id: 'plus-or-minus',
          rounds: 6,
          name: 'Plus or Minus',
          blurb: 'The quadrant settles both signs before any trigonometry.',
          built: true,
          brief: latDepBrief,
        ),
        GameDef(
          id: 'which-course-takes-the-most',
          rounds: 6,
          name: 'Which Course Takes the Most',
          blurb: 'By length. Not by latitude, not an equal share each.',
          built: true,
          brief: compassBrief,
        ),
        GameDef(
          id: 'which-traverse-closed-better',
          rounds: 6,
          name: 'Which Traverse Closed Better',
          blurb: 'The gap alone says nothing about the work.',
          built: true,
          brief: precisionBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'area-computations',
      name: 'Area Computations',
      subtopicId: 'area-volume-traverse',
      games: [
        GameDef(
          id: 'which-method-fits',
          rounds: 6,
          name: 'Which Method Fits the Ground',
          blurb: 'Corners or offsets, and then the count decides.',
          built: true,
          brief: methodBrief,
        ),
        GameDef(
          id: 'what-weight-does-it-get',
          rounds: 6,
          name: 'What Weight Does It Get',
          blurb: 'One, four, two, four, one. The weights are the rule.',
          built: true,
          brief: weightsBrief,
        ),
        GameDef(
          id: 'does-the-listing-close',
          rounds: 6,
          name: 'Does the Listing Close',
          blurb: 'A bowtie gives a tidy number for nothing on the ground.',
          built: true,
          brief: shoelaceBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'earthwork-volumes',
      name: 'Earthwork & Volume Computations',
      subtopicId: 'area-volume-traverse',
      games: [
        GameDef(
          id: 'which-formula-gives-more',
          rounds: 6,
          name: 'Which Formula Gives More',
          blurb: 'Compare the middle section to the average of the ends.',
          built: true,
          brief: endAreaBrief,
        ),
        GameDef(
          id: 'can-you-skip-a-section',
          rounds: 6,
          name: 'Can You Skip a Section',
          blurb: 'End to end, a hill between two zeros books nothing.',
          built: true,
          brief: stationBrief,
        ),
        GameDef(
          id: 'how-much-of-the-box',
          rounds: 6,
          name: 'How Much of the Box',
          blurb: 'To an edge is a half. To a point is a third.',
          built: true,
          brief: solidBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'coordinate-geometry',
      name: 'Coordinate Geometry & Systems',
      subtopicId: 'area-volume-traverse',
      // State Plane gets a paragraph in the lesson and no problem, and a
      // scale factor with no numbers behind it would be an item about
      // nothing. It stays on the page.
      games: [
        GameDef(
          id: 'which-way-are-you-working',
          rounds: 6,
          name: 'Which Way Are You Working',
          blurb: 'Count the points that already have coordinates.',
          built: true,
          brief: cogoBrief,
        ),
        GameDef(
          id: 'where-does-that-pair-land',
          rounds: 6,
          name: 'Where Does That Pair Land',
          blurb: 'Easting first. A swapped pair computes perfectly well.',
          built: true,
          brief: pairBrief,
        ),
        GameDef(
          id: 'what-do-you-add',
          rounds: 6,
          name: 'What Do You Add',
          blurb: 'The arctangent only ever knows half the compass.',
          built: true,
          brief: arctanBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'horizontal-curves',
      name: 'Horizontal Curves',
      subtopicId: 'curves',
      // Superelevation has a formula in the lesson and no problem behind
      // it, so there is no item: a round citing a problem that does not
      // exist would be a round about nothing.
      games: [
        GameDef(
          id: 'which-piece-is-that',
          rounds: 6,
          name: 'Which Piece Is That',
          blurb: 'Six lengths on one curve, and five get confused.',
          built: true,
          brief: roadCurveBrief,
        ),
        GameDef(
          id: 'which-curve-is-sharper',
          rounds: 6,
          name: 'Which Curve Is Sharper',
          blurb: 'Radius and degree of curve run opposite ways.',
          built: true,
          brief: degreeBrief,
        ),
        GameDef(
          id: 'which-is-longer',
          rounds: 6,
          name: 'Which Is Longer',
          blurb: 'The arc, until about 134 degrees. Then the tangent.',
          built: true,
          brief: roadCurveBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'vertical-curves',
      name: 'Vertical Curves',
      subtopicId: 'curves',
      // K and the sight distance tables have a formula in the lesson and no
      // problem behind them: K shows up only as a wrong answer. It sits on
      // the second card, where it belongs, rather than in an item that would
      // have nothing to ask.
      games: [
        GameDef(
          id: 'road-or-grade-line',
          rounds: 6,
          name: 'Road or Grade Line',
          blurb: 'Two elevations at one station, and the gap between them.',
          built: true,
          brief: tangentOffsetBrief,
        ),
        GameDef(
          id: 'where-it-flattens-out',
          rounds: 6,
          name: 'Where It Flattens Out',
          blurb: 'The top of the road is rarely under the PVI.',
          built: true,
          brief: highPointBrief,
        ),
      ],
    ),
  ],
);

const waterResourcesMap = ChapterMap(
  id: 'water-resources',
  number: 11,
  name: 'Water Resources & Environmental',
  examLine: '14 to 21 questions on the real exam',
  subtopics: [
    Subtopic('hydraulics', 'Hydraulics'),
    Subtopic('hydrology-groundwater', 'Hydrology & Groundwater'),
    Subtopic('water-quality-treatment', 'Water Quality & Treatment'),
  ],
  lessons: [
    LessonNode(
      id: 'open-channel-flow',
      name: 'Open-Channel Flow & Manning\'s Equation',
      subtopicId: 'hydraulics',
      games: [
        GameDef(
          id: 'what-the-water-touches',
          rounds: 6,
          name: 'What the Water Touches',
          blurb: 'The surface is open to the air, so it never counts.',
          built: true,
          brief: wettedBrief,
        ),
        GameDef(
          id: 'which-one-runs-faster',
          rounds: 6,
          name: 'Which One Runs Faster',
          blurb: 'Change one thing at a time and watch what it buys.',
          built: true,
          brief: manningBrief,
        ),
        GameDef(
          id: 'which-number-goes-in-front',
          rounds: 6,
          name: 'Which Number Goes In Front',
          blurb: 'The lengths decide it. Nothing else does.',
          built: true,
          brief: unitFactorBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'energy-critical-flow',
      name: 'Specific Energy & Critical Flow',
      subtopicId: 'hydraulics',
      // The conjugate depth itself is a square root and a subtraction, so
      // it stays on paper. What crosses the jump does not, and that is the
      // third item.
      games: [
        GameDef(
          id: 'which-way-does-the-ripple-go',
          rounds: 6,
          name: 'Which Way Does the Ripple Go',
          blurb: 'The Froude number is a race between two speeds.',
          built: true,
          brief: froudeBrief,
        ),
        GameDef(
          id: 'what-moves-the-critical-depth',
          rounds: 6,
          name: 'What Moves the Critical Depth',
          blurb: 'The flow and the width. Not the slope, not the lining.',
          built: true,
          brief: criticalBrief,
        ),
        GameDef(
          id: 'what-survives-the-jump',
          rounds: 6,
          name: 'What Survives the Jump',
          blurb: 'Momentum crosses it. Energy is thrown away.',
          built: true,
          brief: hydraulicJumpBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'pipe-systems-weirs',
      name: 'Hazen-Williams & Weir Formulas',
      subtopicId: 'hydraulics',
      // Which C belongs to which pipe material is a table the handbook
      // hands you in the exam, so there is no item for memorizing it. The
      // direction it runs in is a different matter and gets one.
      games: [
        GameDef(
          id: 'which-formula-fits-this-weir',
          rounds: 6,
          name: 'Which Formula Fits This Weir',
          blurb: 'The shape of the opening picks it.',
          built: true,
          brief: weirBrief,
        ),
        GameDef(
          id: 'which-weir-notices-more',
          rounds: 6,
          name: 'Which Weir Notices More',
          blurb: 'An exponent is a sensitivity, not a piece of notation.',
          built: true,
          brief: exponentBrief,
        ),
        GameDef(
          id: 'smoother-or-rougher',
          rounds: 6,
          name: 'Smoother or Rougher',
          blurb: 'A bigger C is a smoother pipe. Manning is the reverse.',
          built: true,
          brief: hazenBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'pumps-water-distribution',
      name: 'Pumps & Water Distribution',
      subtopicId: 'hydraulics',
      // Two items, not three. The system curve and the operating point are
      // in the lesson text but no problem asks about them, and the 550 and
      // 746 horsepower conversions are a units table the handbook hands you
      // in the exam. Both sit on the cards instead.
      games: [
        GameDef(
          id: 'what-happens-to-the-power',
          rounds: 6,
          name: 'What Happens to the Power',
          blurb: 'Everything multiplies except the efficiency.',
          built: true,
          brief: pumpPowerBrief,
        ),
        GameDef(
          id: 'helps-or-hurts',
          rounds: 6,
          name: 'Helps or Hurts',
          blurb: 'What is left before the water boils at the inlet.',
          built: true,
          brief: npshBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'rainfall-runoff',
      name: 'Rainfall-Runoff Methods',
      subtopicId: 'hydrology-groundwater',
      // The surface water budget is in the lesson text and no problem uses
      // it, so it stays on paper.
      games: [
        GameDef(
          id: 'which-one-sheds-more',
          rounds: 6,
          name: 'Which One Sheds More',
          blurb: 'Cover times acreage, and neither wins on its own.',
          built: true,
          brief: rationalBrief,
        ),
        GameDef(
          id: 'where-the-blend-lands',
          rounds: 6,
          name: 'Where the Blend Lands',
          blurb: 'It leans toward whichever cover has more ground.',
          built: true,
          brief: catchmentBrief,
        ),
        GameDef(
          id: 'does-any-of-it-run-off',
          rounds: 6,
          name: 'Does Any of It Run Off',
          blurb: 'Below the threshold the answer is a hard zero.',
          built: true,
          brief: curveNumberBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'hydrograph-watershed',
      name: 'Hydrographs & Watershed Analysis',
      subtopicId: 'hydrology-groundwater',
      // Naming the parts of a hydrograph, the limbs and the baseflow, is in
      // the lesson text with no problem behind it. The cards carry it.
      games: [
        GameDef(
          id: 'what-does-the-storm-do',
          rounds: 6,
          name: 'What Does the Storm Do to the Curve',
          blurb: 'Depth sets the volume. Duration sets the shape.',
          built: true,
          brief: unitHydrographBrief,
        ),
        GameDef(
          id: 'why-is-this-peak-smaller',
          rounds: 6,
          name: 'Why Is This Peak Smaller',
          blurb: 'Too short for the area, or too long for the intensity.',
          built: true,
          brief: concentrationBrief,
        ),
        GameDef(
          id: 'filling-or-emptying',
          rounds: 6,
          name: 'Filling or Emptying',
          blurb: 'One subtraction, and the sign is the whole answer.',
          built: true,
          brief: routingBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'groundwater-wells',
      name: 'Groundwater & Wells',
      subtopicId: 'hydrology-groundwater',
      games: [
        GameDef(
          id: 'which-speed-is-that',
          rounds: 6,
          name: 'Which Speed Is That',
          blurb: 'Two speeds and a volume, and one of them is real.',
          built: true,
          brief: seepageBrief,
        ),
        GameDef(
          id: 'which-well-formula',
          rounds: 6,
          name: 'Which Well Formula',
          blurb: 'Clay on top decides it. Nothing else does.',
          built: true,
          brief: wellBrief,
        ),
        GameDef(
          id: 'double-the-drawdown',
          rounds: 6,
          name: 'Double the Drawdown',
          blurb: 'Why the squared heads are doing something.',
          built: true,
          brief: wellBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'water-quality',
      name: 'Water Quality & BOD',
      subtopicId: 'water-quality-treatment',
      // The dissolved oxygen sag and the critical point are in the lesson
      // text with no problem behind them, so they stay on paper.
      games: [
        GameDef(
          id: 'how-much-is-used-up',
          rounds: 6,
          name: 'How Much Is Used Up',
          blurb: 'The 68 percent is a rate, not a rule.',
          built: true,
          brief: bodBrief,
        ),
        GameDef(
          id: 'multiply-or-divide',
          rounds: 6,
          name: 'Multiply or Divide',
          blurb: 'The ultimate is always the larger number.',
          built: true,
          brief: bodBrief,
        ),
        GameDef(
          id: 'warmer-or-colder',
          rounds: 6,
          name: 'Warmer or Colder',
          blurb: 'It moves the rate and leaves the total alone.',
          built: true,
          brief: temperatureBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'water-treatment',
      name: 'Water & Wastewater Treatment',
      subtopicId: 'water-quality-treatment',
      games: [
        GameDef(
          id: 'does-it-settle-out',
          rounds: 6,
          name: 'Does It Settle Out',
          blurb: 'The overflow rate is a speed. Read it as one.',
          built: true,
          brief: overflowBrief,
        ),
        GameDef(
          id: 'hours-or-days',
          rounds: 6,
          name: 'Hours or Days',
          blurb: 'The water goes through once. The solids go round.',
          built: true,
          brief: residenceBrief,
        ),
        GameDef(
          id: 'what-moves-the-ratio',
          rounds: 6,
          name: 'What Moves the Ratio',
          blurb: 'Two quantities are food and two are mouths.',
          built: true,
          brief: foodRatioBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'drinking-water-treatment',
      name: 'Drinking Water Treatment & Disinfection',
      subtopicId: 'water-quality-treatment',
      // Two items. The order of the treatment train is in the lesson text
      // with no problem behind it, and the filter loading rate is the
      // clarifier's overflow rate applied to a different box, which the
      // settling item already teaches. Both are on the cards.
      games: [
        GameDef(
          id: 'what-do-you-feed',
          rounds: 6,
          name: 'What Do You Feed',
          blurb: 'Demand, residual, dose, and only one goes in the pump.',
          built: true,
          brief: doseBrief,
        ),
        GameDef(
          id: 'what-buys-the-ct',
          rounds: 6,
          name: 'What Buys the CT',
          blurb: 'The residual, the time, and which time counts.',
          built: true,
          brief: contactBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'water-quality-standards',
      name: 'Drinking Water Standards & Hardness',
      subtopicId: 'water-quality-treatment',
      games: [
        GameDef(
          id: 'health-or-taste',
          rounds: 6,
          name: 'Health or Taste',
          blurb: 'The size of a limit says nothing about its tier.',
          built: true,
          brief: standardsBrief,
        ),
        GameDef(
          id: 'which-ion-counts-more',
          rounds: 6,
          name: 'Which Ion Counts More',
          blurb: 'Magnesium, milligram for milligram. It is lighter.',
          built: true,
          brief: hardnessBrief,
        ),
        GameDef(
          id: 'removed-or-remaining',
          rounds: 6,
          name: 'Removed or Remaining',
          blurb: 'The flow cancels. Only the ratio matters.',
          built: true,
          brief: efficiencyBrief,
        ),
      ],
    ),
  ],
);

const structuralMap = ChapterMap(
  id: 'structural',
  number: 12,
  name: 'Structural Engineering',
  examLine: '12 to 18 questions on the real exam',
  subtopics: [
    Subtopic('analysis-loads', 'Analysis & Load Combinations'),
    Subtopic('rc-design', 'Reinforced Concrete Design'),
    Subtopic('steel-design', 'Steel Design'),
  ],
  lessons: [
    LessonNode(
      id: 'determinacy-stability',
      name: 'Determinacy & Stability',
      subtopicId: 'analysis-loads',
      // Two items, not three. What each support is worth in reactions is
      // already an item in statics, and so is telling a truss from a frame
      // by looking at it. What is new here is the COUNT those two feed, and
      // the fact that passing it guarantees nothing.
      games: [
        GameDef(
          id: 'enough-or-too-many',
          rounds: 6,
          name: 'Enough or Too Many',
          blurb: 'Short of it moves. Over it needs compatibility.',
          built: true,
          brief: countBrief,
        ),
        GameDef(
          id: 'the-count-says-yes',
          rounds: 6,
          name: 'The Count Says Yes',
          blurb: 'And the structure falls over anyway.',
          built: true,
          brief: stabilityBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'truss-analysis-methods',
      name: 'Truss Analysis: Joints & Sections',
      subtopicId: 'analysis-loads',
      // Zero force members, the tension and compression convention, and
      // where to put the cut are all items in statics already. What is left
      // to this lesson is what comes after the cut.
      games: [
        GameDef(
          id: 'where-do-you-take-moments',
          rounds: 6,
          name: 'Where Do You Take Moments',
          blurb: 'Put the pivot where the other two cross.',
          built: true,
          brief: momentCenterBrief,
        ),
        GameDef(
          id: 'bigger-than-the-load',
          rounds: 6,
          name: 'Bigger Than the Load',
          blurb: 'A diagonal always carries more than it holds up.',
          built: true,
          brief: jointForceBrief,
        ),
        GameDef(
          id: 'joints-or-sections',
          rounds: 6,
          name: 'Joints or Sections',
          blurb: 'And the reactions before either of them.',
          built: true,
          brief: trussRouteBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'deflection-virtual-work',
      name: 'Deflection of Determinate Structures',
      subtopicId: 'analysis-loads',
      // Two items, not three. Reading the handbook deflection table and
      // ranking what makes a beam stiffer are both items in mechanics of
      // materials already, and so is adding two load cases together. What is
      // new here is the unit-load method, and the arithmetic in it belongs on
      // paper: what the phone can settle is what to hang on the structure and
      // which terms of the sum survive.
      games: [
        GameDef(
          id: 'what-do-you-hang-on-it',
          rounds: 6,
          name: 'What Do You Hang On It',
          blurb: 'A force for a movement, a moment for a turn.',
          built: true,
          brief: unitLoadBrief,
        ),
        GameDef(
          id: 'does-this-one-count',
          rounds: 6,
          name: 'Does This One Count',
          blurb: 'Half the members drop out. The signs do the rest.',
          built: true,
          brief: termSignBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'indeterminate-structures',
      name: 'Elementary Indeterminate Structures',
      subtopicId: 'analysis-loads',
      // Two items, not three. Counting the degree is the determinacy
      // lesson's own item and is not repeated here, and looking a standard
      // case up in the handbook table is an item in mechanics of materials.
      // What belongs to this lesson is what you do once the count says you
      // are short, and which way each standard result moves.
      games: [
        GameDef(
          id: 'what-do-you-let-go',
          rounds: 6,
          name: 'What Do You Let Go',
          blurb: 'Release it, then pay for it with a deflection.',
          built: true,
          brief: redundantBrief,
        ),
        GameDef(
          id: 'more-less-or-the-same',
          rounds: 6,
          name: 'More, Less or the Same',
          blurb: 'What building an end in moves, and what it leaves alone.',
          built: true,
          brief: fixityBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'load-combinations',
      name: 'Loads & Load Combinations',
      subtopicId: 'analysis-loads',
      games: [
        GameDef(
          id: 'factored-or-service',
          rounds: 6,
          name: 'Factored or Service',
          blurb: 'Both halves of a check come from the same method.',
          built: true,
          brief: lrfdBrief,
        ),
        GameDef(
          id: 'which-one-controls',
          rounds: 6,
          name: 'Which One Controls',
          blurb: 'The big factor follows the big load.',
          built: true,
          brief: controlsBrief,
        ),
        GameDef(
          id: 'how-much-comes-off',
          rounds: 6,
          name: 'How Much Comes Off',
          blurb: 'A big floor is never full everywhere at once.',
          built: true,
          brief: reductionBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'influence-lines',
      name: 'Influence Lines',
      subtopicId: 'analysis-loads',
      games: [
        GameDef(
          id: 'what-the-height-means',
          rounds: 6,
          name: 'What the Height Means',
          blurb: 'Across is where the load stands, not where you are looking.',
          built: true,
          brief: influenceBrief,
        ),
        GameDef(
          id: 'which-line-is-it',
          rounds: 6,
          name: 'Which Line Is It',
          blurb: 'Three shapes, and the step of one gives shear away.',
          built: true,
          brief: shapesBrief,
        ),
        GameDef(
          id: 'where-do-you-park-it',
          rounds: 6,
          name: 'Where Do You Park It',
          blurb: 'The heaviest load goes on the tallest part of the line.',
          built: true,
          brief: placeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'rc-flexure-shear',
      name: 'RC Beams: Flexure & Shear',
      subtopicId: 'rc-design',
      games: [
        GameDef(
          id: 'which-one-is-d',
          rounds: 6,
          name: 'Which One Is d',
          blurb: 'It stops at the middle of the bars, not the bottom.',
          built: true,
          brief: whichDepthBrief,
        ),
        GameDef(
          id: 'stirrups-or-not',
          rounds: 6,
          name: 'Stirrups or Not',
          blurb: 'Four answers, and the ladder decides which.',
          built: true,
          brief: stirrupBrief,
        ),
        GameDef(
          id: 'nominal-or-design',
          rounds: 6,
          name: 'Nominal or Design',
          blurb: 'What it can do against what you may count on.',
          built: true,
          brief: phiBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'rc-columns',
      name: 'RC Columns',
      subtopicId: 'rc-design',
      // Two items, not three. The strain classification that decides phi is
      // a ladder to read, and the beams lesson already asks why a ductile
      // failure earns the bigger factor: a second ladder would be the same
      // item wearing a different hat. What is left here is the pair of
      // multipliers and the window round the steel.
      games: [
        GameDef(
          id: 'both-factors-or-one',
          rounds: 6,
          name: 'Both Factors or One',
          blurb: 'The eccentricity allowance, and then phi.',
          built: true,
          brief: columnFactorBrief,
        ),
        GameDef(
          id: 'too-little-or-too-much',
          rounds: 6,
          name: 'Too Little or Too Much',
          blurb: 'One per cent to eight, and both ends are inclusive.',
          built: true,
          brief: steelWindowBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'steel-beams',
      name: 'Steel Beams',
      subtopicId: 'steel-design',
      games: [
        GameDef(
          id: 'how-far-between-braces',
          rounds: 6,
          name: 'How Far Between Braces',
          blurb: 'The section is only half the story.',
          built: true,
          brief: bracingBrief,
        ),
        GameDef(
          id: 'z-or-s',
          rounds: 6,
          name: 'Z or S',
          blurb: 'Yielded right through, or just at the outer fiber.',
          built: true,
          brief: modulusBrief,
        ),
        GameDef(
          id: 'which-flange-needs-holding',
          rounds: 6,
          name: 'Which Flange Needs Holding',
          blurb: 'Over a support it is the bottom one.',
          built: true,
          brief: flangeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'steel-columns',
      name: 'Steel Columns',
      subtopicId: 'steel-design',
      // Two items, not three. What the ends are worth, which axis a bare
      // column folds about and whether it buckles or squashes are three
      // items in mechanics of materials already. What is left to steel
      // design is what happens when the two axes are held differently, and
      // what the column table hands over.
      games: [
        GameDef(
          id: 'which-axis-wins-now',
          rounds: 6,
          name: 'Which Axis Wins Now',
          blurb: 'A brace shortens one direction and not the other.',
          built: true,
          brief: axisBrief,
        ),
        GameDef(
          id: 'what-the-table-gives-you',
          rounds: 6,
          name: 'What the Table Gives You',
          blurb: 'A design stress with the factor already in it.',
          built: true,
          brief: tableBrief3,
        ),
      ],
    ),
    LessonNode(
      id: 'steel-tension',
      name: 'Steel Tension Members',
      subtopicId: 'steel-design',
      games: [
        GameDef(
          id: 'gross-or-net',
          rounds: 6,
          name: 'Gross or Net',
          blurb: 'Two checks, two areas, and the smaller answer wins.',
          built: true,
          brief: twoLimitsBrief,
        ),
        GameDef(
          id: 'how-big-is-the-hole',
          rounds: 6,
          name: 'How Big Is the Hole',
          blurb: 'The bolt plus an eighth, off the width.',
          built: true,
          brief: netAreaBrief,
        ),
        GameDef(
          id: 'is-all-of-it-connected',
          rounds: 6,
          name: 'Is All of It Connected',
          blurb: 'What the bolts miss has to catch up along the length.',
          built: true,
          brief: shearLagBrief,
        ),
      ],
    ),
  ],
);

const geotechnicalMap = ChapterMap(
  id: 'geotechnical',
  number: 13,
  name: 'Geotechnical Engineering',
  examLine: '9 to 14 questions on the real exam',
  subtopics: [
    Subtopic('soil-properties', 'Soil Properties & Classification'),
    Subtopic('consolidation-strength', 'Consolidation & Shear Strength'),
    Subtopic('seepage-stability', 'Seepage & Slope Stability'),
    Subtopic('foundations-walls', 'Foundations & Earth Pressures'),
    // The web calls this one Deep Foundations & Soil Improvement, which is
    // a character too long for the heading pill on a phone.
    Subtopic('deep-foundations-improvement', 'Deep Foundations & Improvement'),
  ],
  lessons: [
    LessonNode(
      id: 'phase-relations',
      name: 'Phase Relations',
      subtopicId: 'soil-properties',
      games: [
        GameDef(
          id: 'over-what',
          rounds: 6,
          name: 'Over What',
          blurb: 'The denominators are not all the same, on purpose.',
          built: true,
          brief: phaseBrief,
        ),
        GameDef(
          id: 'when-does-it-simplify',
          rounds: 6,
          name: 'When Does It Simplify',
          blurb: 'One line crosses the diagram. It needs S to be one.',
          built: true,
          brief: masterBrief,
        ),
        GameDef(
          id: 'which-gamma',
          rounds: 6,
          name: 'Which Gamma',
          blurb: 'One soil, four weights, in a fixed order.',
          built: true,
          brief: gammaBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'soil-classification',
      name: 'Soil Classification',
      subtopicId: 'soil-properties',
      games: [
        GameDef(
          id: 'which-fork-first',
          rounds: 6,
          name: 'Which Fork First',
          blurb: 'The No. 200 sieve asks the first question.',
          built: true,
          brief: forkBrief,
        ),
        GameDef(
          id: 'above-or-below-the-line',
          rounds: 6,
          name: 'Above or Below the Line',
          blurb: 'Two lines on a chart, and four soils.',
          built: true,
          brief: chartBrief,
        ),
        GameDef(
          id: 'both-or-neither',
          rounds: 6,
          name: 'Both or Neither',
          blurb: 'One coefficient passing is not enough.',
          built: true,
          brief: gradationBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'effective-stress',
      name: 'Effective Stress',
      subtopicId: 'soil-properties',
      games: [
        GameDef(
          id: 'which-stress-is-that',
          rounds: 6,
          name: 'Which Stress Is That',
          blurb: 'Three at every point, and only one of them decides.',
          built: true,
          brief: threeStressBrief,
        ),
        GameDef(
          id: 'what-the-water-table-does',
          rounds: 6,
          name: 'What the Water Table Does',
          blurb: 'Pump it down and the grains take up the slack.',
          built: true,
          brief: waterTableBrief,
        ),
        GameDef(
          id: 'the-short-way-down',
          rounds: 6,
          name: 'The Short Way Down',
          blurb: 'Buoyant below the table, and never above it.',
          built: true,
          brief: shortWayBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'consolidation',
      name: 'Consolidation & Settlement',
      subtopicId: 'consolidation-strength',
      games: [
        GameDef(
          id: 'which-case-is-it',
          rounds: 6,
          name: 'Which Case Is It',
          blurb: 'Three formulas, and the memory picks one.',
          built: true,
          brief: caseBrief,
        ),
        GameDef(
          id: 'stiff-until-it-remembers',
          rounds: 6,
          name: 'Stiff Until It Remembers',
          blurb: 'A shallow line, a corner, and a steep one.',
          built: true,
          brief: memoryBrief,
        ),
        GameDef(
          id: 'how-long-does-it-take',
          rounds: 6,
          name: 'How Long Does It Take',
          blurb: 'The wait goes as the square of the journey.',
          built: true,
          brief: drainageBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'shear-strength',
      name: 'Shear Strength of Soils',
      subtopicId: 'consolidation-strength',
      games: [
        GameDef(
          id: 'two-terms',
          rounds: 6,
          name: 'Two Terms',
          blurb: 'One is there anyway, one grows with pressing.',
          built: true,
          brief: mohrCoulombBrief,
        ),
        GameDef(
          id: 'drained-or-not',
          rounds: 6,
          name: 'Drained or Not',
          blurb: 'Which set of parameters is a question about time.',
          built: true,
          brief: drainedBrief,
        ),
        GameDef(
          id: 'reading-the-circle',
          rounds: 6,
          name: 'Reading the Circle',
          blurb: 'Sine, not tangent, and half the deviator.',
          built: true,
          brief: mohrCircleBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'permeability-seepage',
      name: 'Permeability & Seepage',
      subtopicId: 'seepage-stability',
      // Two items, not three. The discharge velocity against the real speed
      // of the water is an item in water resources already, on the
      // groundwater lesson, and it is the same idea in the same units.
      games: [
        GameDef(
          id: 'counting-the-net',
          rounds: 6,
          name: 'Counting the Net',
          blurb: 'Channels over drops, and never the other way.',
          built: true,
          brief: flowNetBrief,
        ),
        GameDef(
          id: 'when-the-sand-boils',
          rounds: 6,
          name: 'When the Sand Boils',
          blurb: 'Upward seepage carrying the grains it passes.',
          built: true,
          brief: quickBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'slope-stability',
      name: 'Slope Stability',
      subtopicId: 'seepage-stability',
      games: [
        GameDef(
          id: 'steeper-than-its-friction',
          rounds: 6,
          name: 'Steeper Than Its Friction',
          blurb: 'Two angles, and the depth cancels out.',
          built: true,
          brief: infiniteSlopeBrief,
        ),
        GameDef(
          id: 'after-the-rain',
          rounds: 6,
          name: 'After the Rain',
          blurb: 'Seepage takes about half of it away.',
          built: true,
          brief: seepageSlopeBrief,
        ),
        GameDef(
          id: 'what-holds-the-wedge',
          rounds: 6,
          name: 'What Holds the Wedge',
          blurb: 'The weight drives it and holds it, both.',
          built: true,
          brief: wedgeBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'bearing-capacity',
      name: 'Bearing Capacity',
      subtopicId: 'foundations-walls',
      games: [
        GameDef(
          id: 'which-term-drops-out',
          rounds: 6,
          name: 'Which Term Drops Out',
          blurb: 'Most problems kill one before you start.',
          built: true,
          brief: terzaghiBrief,
        ),
        GameDef(
          id: 'wider-or-deeper',
          rounds: 6,
          name: 'Wider or Deeper',
          blurb: 'On a clay, widening buys no pressure at all.',
          built: true,
          brief: footingFixBrief,
        ),
        GameDef(
          id: 'what-gets-divided',
          rounds: 6,
          name: 'What Gets Divided',
          blurb: 'The capacity, never the load.',
          built: true,
          brief: allowableBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'lateral-earth-pressure',
      name: 'Lateral Earth Pressure',
      subtopicId: 'foundations-walls',
      games: [
        GameDef(
          id: 'which-way-did-the-wall-move',
          rounds: 6,
          name: 'Which Way Did the Wall Move',
          blurb: 'Three states, and the wall picks one.',
          built: true,
          brief: rankineBrief,
        ),
        GameDef(
          id: 'triangle-or-rectangle',
          rounds: 6,
          name: 'Triangle or Rectangle',
          blurb: 'The soil grows with depth. A surcharge does not.',
          built: true,
          brief: diagramShapeBrief,
        ),
        GameDef(
          id: 'double-the-wall',
          rounds: 6,
          name: 'Double the Wall',
          blurb: 'Four times the force, eight times the moment.',
          built: true,
          brief: wallForceBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'retaining-walls',
      name: 'Retaining Wall Stability',
      subtopicId: 'foundations-walls',
      games: [
        // The idea that a factor of safety is what resists over what drives
        // is NOT new here: the slope lesson taught it. What this item
        // teaches is what is particular to a wall, that there are three
        // separate checks comparing three different kinds of quantity.
        GameDef(
          id: 'moments-or-forces',
          rounds: 6,
          name: 'Moments or Forces',
          blurb: 'Three checks, and they compare different things.',
          built: true,
          brief: threeChecksBrief,
        ),
        GameDef(
          id: 'from-the-toe-or-the-center',
          rounds: 6,
          name: 'From the Toe or the Center',
          blurb: 'Two distances, and only one is the eccentricity.',
          built: true,
          brief: middleThirdBrief,
        ),
        GameDef(
          id: 'what-tips-the-pressure',
          rounds: 6,
          name: 'What Tips the Pressure',
          blurb: 'Uniform only when the load lands dead center.',
          built: true,
          brief: basePressureBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'compaction-stabilization',
      name: 'Compaction & Soil Improvement',
      subtopicId: 'deep-foundations-improvement',
      games: [
        GameDef(
          id: 'wetter-is-not-denser',
          rounds: 6,
          name: 'Wetter Is Not Denser',
          blurb: 'The Proctor curve is a hump, not a slope.',
          built: true,
          brief: proctorBrief,
        ),
        GameDef(
          id: 'which-measure-is-it',
          rounds: 6,
          name: 'Which Measure Is It',
          blurb: 'Two ways to say how tight, and they do not mix.',
          built: true,
          brief: relativeDensityBrief,
        ),
        GameDef(
          id: 'lime-or-cement',
          rounds: 6,
          name: 'Lime or Cement',
          blurb: 'Match the help to the soil.',
          built: true,
          brief: stabilizerBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'deep-foundations',
      name: 'Deep Foundations',
      subtopicId: 'deep-foundations-improvement',
      games: [
        GameDef(
          id: 'tip-or-shaft',
          rounds: 6,
          name: 'Tip or Shaft',
          blurb: 'Two resistances, and each has its own area.',
          built: true,
          brief: pileCapacityBrief,
        ),
        // The lesson prints no pile GROUP problem, only text, so the group
        // rounds here are authored from that text and cite the problem that
        // sets the scene. Worth knowing: they are the only rounds in the
        // chapter not taken from a problem of their own.
        GameDef(
          id: 'why-go-deeper',
          rounds: 6,
          name: 'Why Go Deeper',
          blurb: 'Past the layer that settles, and what a group changes.',
          built: true,
          brief: goingDeepBrief,
        ),
        GameDef(
          id: 'which-way-the-friction-acts',
          rounds: 6,
          name: 'Which Way the Friction Acts',
          blurb: 'Sometimes it holds the pile up. Sometimes it hangs on it.',
          built: true,
          brief: downdragBrief,
        ),
      ],
    ),
  ],
);

const transportationMap = ChapterMap(
  id: 'transportation',
  number: 14,
  name: 'Transportation Engineering',
  examLine: '8 to 12 questions on the real exam',
  subtopics: [
    Subtopic('geometric-design', 'Geometric Design'),
    Subtopic('traffic-engineering', 'Traffic Engineering'),
    // The web calls this Planning & Traffic Operations, which is wider than
    // the heading pill on a phone.
    Subtopic('planning-operations', 'Planning & Operations'),
    Subtopic('pavement-earthwork', 'Pavement Design & Earthwork'),
  ],
  lessons: [
    LessonNode(
      id: 'stopping-sight-distance',
      name: 'Stopping Sight Distance & PHF',
      subtopicId: 'geometric-design',
      games: [
        GameDef(
          id: 'think-then-brake',
          rounds: 6,
          name: 'Think Then Brake',
          blurb: 'Two stretches of road, and they grow differently.',
          built: true,
          brief: sightDistanceBrief,
        ),
        GameDef(
          id: 'uphill-or-down',
          rounds: 6,
          name: 'Uphill or Down',
          blurb: 'One sign, and it moves the answer the unsafe way.',
          built: true,
          brief: gradeSignBrief,
        ),
        GameDef(
          id: 'the-worst-fifteen-minutes',
          rounds: 6,
          name: 'The Worst Fifteen Minutes',
          blurb: 'A road is designed for the surge, not the hour.',
          built: true,
          brief: peakHourBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'vertical-curves',
      name: 'Vertical Curve Design',
      subtopicId: 'geometric-design',
      // Two items, not three. This lesson's third problem is the tangent
      // offset at the PVI, and the SURVEYING chapter already teaches that
      // one twice over: `road-or-grade-line` is built on the two elevations
      // at a station and its card carries E = AL/8. Building it again here
      // would be the same item with a different hat on.
      games: [
        GameDef(
          id: 'crest-or-sag',
          rounds: 6,
          name: 'Crest or Sag',
          blurb: 'Seeing over a hill, or lighting into a dip.',
          built: true,
          brief: crestSagBrief,
        ),
        GameDef(
          id: 'how-big-is-the-break',
          rounds: 6,
          name: 'How Big Is the Break',
          blurb: 'Plus three into minus five is eight, not two.',
          built: true,
          brief: gradeBreakBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'horizontal-curves',
      name: 'Horizontal Curve Design',
      subtopicId: 'geometric-design',
      // One item only. Two of this lesson's three problems are the radius
      // against the degree of curve and the tangent out to the PI, and the
      // SURVEYING chapter teaches both already: `which-curve-is-sharper`
      // has the 5,729.58, and `which-piece-is-that` has all six lengths
      // including T = R tan(I/2). Superelevation is the part that is new.
      games: [
        GameDef(
          id: 'how-much-bank',
          rounds: 6,
          name: 'How Much Bank',
          blurb: 'The tires take a share, the tilt takes the rest.',
          built: true,
          brief: superelevationBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'signal-timing',
      name: 'Traffic Signal Timing',
      subtopicId: 'traffic-engineering',
      games: [
        GameDef(
          id: 'feet-not-miles',
          rounds: 6,
          name: 'Feet, Not Miles',
          blurb: 'A second to react, then the time to stop.',
          built: true,
          brief: yellowBrief,
        ),
        GameDef(
          id: 'all-the-way-across',
          rounds: 6,
          name: 'All the Way Across',
          blurb: 'Clear means the back bumper, not the nose.',
          built: true,
          brief: allRedBrief,
        ),
        GameDef(
          id: 'three-parts-of-a-walk',
          rounds: 6,
          name: 'Three Parts of a Walk',
          blurb: 'Getting going, walking, and the crowd.',
          built: true,
          brief: pedestrianGreenBrief,
        ),
      ],
    ),
    LessonNode(
      id: 'traffic-flow',
      name: 'Traffic Flow & Crash Rates',
      subtopicId: 'traffic-engineering',
      games: [
        GameDef(
          id: 'half-of-each',
          rounds: 6,
          name: 'Half of Each',
          blurb: 'The peak sits at half the speed and half the density.',
          built: true,
          brief: greenshieldsBrief,
        ),
        GameDef(
          id: 'what-is-left-of-the-speed',
          rounds: 6,
          name: 'What Is Left of the Speed',
          blurb: 'Start full, subtract what the traffic took.',
          built: true,
          brief: speedDensityBrief,
        ),
        GameDef(
          id: 'per-million-what',
          rounds: 6,
          name: 'Per Million What',
          blurb: 'A count ranks nothing until it is divided.',
          built: true,
          brief: crashRateBrief,
        ),
      ],
    ),
  ],
);

const chapterMaps = <String, ChapterMap>{
  'mathematics': mathematicsMap,
  'statistics': statisticsMap,
  'ethics': ethicsMap,
  'economics': economicsMap,
  'statics': staticsMap,
  'dynamics': dynamicsMap,
  'mechanics-materials': mechanicsMaterialsMap,
  'materials': materialsMap,
  'fluid-mechanics': fluidMechanicsMap,
  'surveying': surveyingMap,
  'water-resources': waterResourcesMap,
  'structural': structuralMap,
  'geotechnical': geotechnicalMap,
  'transportation': transportationMap,
};

ChapterMap? mapForChapter(String chapterId) => chapterMaps[chapterId];
