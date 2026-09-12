import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'discriminant_gate_game.dart' show Para, ParaPainter;
import 'oblique_figures.dart';
import 'trig_figures.dart';
import 'unit_circle_figures.dart';

/// The idea behind a lesson, in a few lines and a picture, reachable both from
/// the lesson node and from inside a sitting. It is a reference, not a
/// question: nothing here is graded, and every word traces to the lesson's own
/// content blocks.
@immutable
class BriefSection {
  const BriefSection({
    required this.title,
    required this.body,
    required this.figure,
    this.formula,
    this.formulas = const [],
    this.handbook,
  });

  final String title;
  final String body;

  /// A single expression, shown big under the body.
  final String? formula;

  /// Named expressions, for a concept that IS a formula rather than one that
  /// merely uses one. Without these a card can explain when to reach for a law
  /// and never show the law, which reads as arbitrary.
  final List<(String, String)> formulas;
  final BriefFigure figure;
  final String? handbook;
}

enum BriefFigure {
  slopePair,
  discriminant,
  grade,
  logRules,
  undoExponent,
  combineLogs,
  ratios,
  sideNames,
  components,
  unitCircle,
  quadrants,
  identities,
  circleForm,
  conicForms,
  completingSquare,
  whichRule,
  chainRule,
  quotientOrder,
  maxMin,
  bendFlip,
  whereOrHowMuch,
  substitution,
  liate,
  finishing,
  formCheck,
  separately,
  bothSides,
  vectorAdd,
  unitVector,
  magnitude,
  dotProduct,
  dotAngle,
  projection,
  rightHand,
  crossArea,
  cofactor,
  references,
  precedence,
  functions,
  tracing,
  selection,
  iteration,
  newton,
  bisection,
  methodChoice,
  center,
  spread,
  weighted,
  correlation,
  regressionLine,
  determination,
  counting,
  binomial,
  normalTable,
  expectedValue,
  varianceShortcut,
  combining,
  marginOfError,
  zOrT,
  sampleSize,
  hypotheses,
  decisionRule,
  goodnessOfFit,
  publicFirst,
  escalation,
  proportion,
  competence,
  consent,
  claims,
  standing,
  exemption,
  holdingOut,
  ladder,
  discipline,
  sections,
  formation,
  risk,
  delivery,
  standardOfCare,
  negligence,
  clocks,
  property,
  portfolio,
  lifeCycle,
  factors,
  rates,
  pieces,
  annualCost,
  studyPeriod,
  methodsAgree,
  costTypes,
  breakEven,
  payback,
  lawChoice,
  lawForms,
  cosineSign,
  bcRatio,
  incremental,
  rollback,
  internalRate,
  hurdle,
  ratePerYear,
  macrs,
  bookValue,
  dollarsMatch,
  resolve,
  moment,
  sense,
  supports,
  resultant,
  determinacy,
  zeroForce,
  senseOfForce,
  section,
  laws,
  period,
  ceiling,
  belt,
  normalForce,
  screw,
  twoForce,
  lever,
  whatItIs,
  areaWeighted,
  table,
  reference,
  farFromAxis,
  transfer,
  compositeI,
  polar,
  deformation,
  units,
  thermal,
  polarJ,
  twist,
  thinWall,
  curve,
  stiffStrong,
  linked,
  slopeRules,
  peak,
  jump,
  fiber,
  cut,
  governs,
  tableLine,
  bounce,
  addUp,
  transform,
  join,
  plastic,
  circle,
  build,
  worst,
  ends,
  weakAxis,
  slender,
  missing,
  flight,
  bend,
  spin,
  spinInertia,
  weight,
  slope,
  twoEquations,
  ledger,
  cancel,
  power,
  impact,
  survives,
  impulse,
  natural,
  resonance,
  damping,
  underneath,
  trueStress,
  crack,
  toughness,
  expand,
  furnace,
  tieLine,
  mix,
  exposure,
  curing,
  field,
  weighing,
  grading,
  voids,
  check,
  moisture,
  mortar,
  factor,
  blend,
  isostrain,
  galvanic,
  picking,
  threeNumbers,
  viscosity,
  capillary,
  depth,
  manometer,
  gauge,
  gate,
  buoyancy,
  continuity,
  bernoulli,
  torricelli,
  reynolds,
  darcy,
  minor,
  deflection,
  thrust,
  block,
  metering,
  coefficient,
  similitude,
  scaling,
  bearing,
  azimuth,
  shot,
  sightLine,
  runRoles,
  closure,
  latDep,
  compass,
  precision,
  shoelace,
  weights,
  method,
  endArea,
  stations,
  solidShare,
  cogo,
  pair,
  arctan,
  roadCurve,
  degreeOfCurve,
  tangentOffset,
  highPoint,
  wetted,
  manning,
  unitFactor,
  froude,
  criticalDepth,
  hydraulicJump,
  weirShape,
  weirExponent,
  hazen,
  pumpPower,
  npsh,
  rational,
  runoffBlend,
  curveNumber,
  unitHydrograph,
  concentration,
  routing,
  seepage,
  wells,
  bod,
  rateTemperature,
  overflow,
  residence,
  foodRatio,
  chlorineDose,
  contactTime,
  tiers,
  hardness,
  efficiency,
  determinacyCount,
  stability,
  momentCenter,
  jointForce,
  trussRoute,
  unitLoad,
  termSign,
  redundant,
  fixity,
  lrfd,
  controls,
  reduction,
  influenceRead,
  influenceShapes,
  influencePlace,
  effectiveDepth,
  stirrupLadder,
  phiFactors,
  columnFactors,
  steelWindow,
  bracing,
  moduli,
  flanges,
  whichAxis,
  columnTable,
  twoLimits,
  netArea,
  shearLag,
  phaseDiagram,
  masterRelation,
  unitWeights,
  uscsTree,
  plasticityChart,
  gradation,
  threeStresses,
  waterTable,
  buoyantWalk,
  settlementCase,
  clayMemory,
  drainagePath,
  mohrCoulomb,
  drainage,
  soilCircle,
  flowNet,
  quickCondition,
  infiniteSlope,
  slopeSeepage,
  slipWedge,
  threeTerms,
  footingFix,
  allowablePressure,
  rankine,
  pressureShape,
  wallForce,
  threeChecks,
  middleThird,
  basePressure,
  proctor,
  relativeDensity,
  stabilizer,
  pileCapacity,
  goingDeep,
  downdrag,
  sightDistance,
  gradeSign,
  peakHour,
  crestSag,
  gradeBreak,
  superelevation,
  yellowInterval,
  allRed,
  pedestrianGreen,
  greenshields,
  speedDensity,
  crashRate,
  heavyVehicle,
  demandFlow,
  levelOfService,
  fourStep,
  gravity,
  friction,
  signCategory,
  signalWarrant,
  structuralNumber,
  layerThickness,
  esal,
  rigidVsFlexible,
  pavementJoint,
  subgradeReaction,
  forwardPass,
  projectDuration,
  passes,
  float,
  criticalPath,
  earnedValue,
  forecast,
  excavation,
  fallProtection,
  yards,
  deliveryFit,
  curveConversion,
  cornerOffset,
  stiffness,
  filterRate,
}

/// One concept per item. Each is the reference for the item it sits behind and
/// nothing else: opening it mid-round should answer the question in front of
/// you, not make you hunt through the rest of the lesson.
const perpendicularBrief = BriefSection(
  title: 'Parallel and perpendicular',
  body:
      'Parallel lines never meet, and that is the same as saying they have '
      'the same slope. Perpendicular lines cross at a right angle, and their '
      'slopes are negative reciprocals: flip the fraction and change the '
      'sign. Doing only one of the two gets you a line that looks plausible '
      'and is wrong.',
  formulas: [
    ('Parallel', r'm_1 = m_2'),
    ('Perpendicular', r'm_{\perp} = -\frac{1}{m}'),
  ],
  figure: BriefFigure.slopePair,
  handbook: 'Handbook p. 36',
);

const discriminantBrief = BriefSection(
  title: 'The discriminant',
  body:
      'In the quadratic formula, the part under the square root is the '
      'discriminant. Its sign alone tells you how many real roots there are: '
      'positive gives two, zero gives one, negative gives none. You can read '
      'that off a graph without solving anything, and on the exam it lets '
      'you throw out answers before you start.',
  formulas: [
    ('The quadratic formula', r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}'),
    ('The discriminant is the part under the root', r'b^2 - 4ac'),
  ],
  figure: BriefFigure.discriminant,
  handbook: 'Handbook p. 36',
);

const gradeBrief = BriefSection(
  title: 'Grade, rise and run',
  body:
      'Grade is rise over run, written as a percent. Stations are the trap: '
      'a station is distance in hundreds of feet, so 3+00 means 300 feet, '
      'never 3. Convert the stations before you compare anything, or a flat '
      'road will look like a cliff.',
  formulas: [
    ('Grade', r'\text{grade} = \frac{\text{rise}}{\text{run}} \times 100\%'),
    ('A station is hundreds of feet', r'3{+}00 = 300\ \text{ft}'),
  ],
  figure: BriefFigure.grade,
  handbook: 'Handbook p. 36',
);

// ── Logarithms ──────────────────────────────────────────────────────────────
// This lesson has no figure of its own anywhere in the web content, so its
// references show the rules themselves rather than a picture of something.

const logRulesBrief = BriefSection(
  title: 'The log rules, and the one that does not exist',
  body:
      'A logarithm asks what power the base is raised to. Three moves are '
      'legal: a product inside becomes a sum outside, a quotient becomes a '
      'difference, and an exponent comes down in front. A sum inside a log has '
      'no rule at all. Splitting one is the cheapest way to lose a mark on '
      'this topic.',
  formulas: [('What a log means', r'\log_b x = c \iff b^c = x')],
  figure: BriefFigure.logRules,
  handbook: 'Handbook p. 36',
);

const undoExponentBrief = BriefSection(
  title: 'Undoing an exponent',
  body:
      'When the unknown sits in the exponent, the log is what gets it down. '
      'A log undoes its own base exactly: ln undoes e, and log undoes 10. '
      'Clear anything multiplying the exponential first, then take the log of '
      'both sides, and what is left is linear.',
  formulas: [
    (
      'A log undoes its own base',
      r'\ln(e^{x}) = x \qquad \log_{10}(10^{x}) = x',
    ),
    ('Which is the definition, read backwards', r'\log_b x = c \iff b^c = x'),
  ],
  figure: BriefFigure.undoExponent,
  handbook: 'Handbook p. 36',
);

const combineLogsBrief = BriefSection(
  title: 'Combining logs into one',
  body:
      'Terms in the same base collapse into a single log before you evaluate '
      'anything: added terms multiply inside, subtracted terms divide inside, '
      'and a coefficient becomes an exponent. Doing it in this order is faster '
      'and it avoids the classic error of multiplying the separate log values '
      'together.',
  formulas: [('Only within one base', r'\log_b(xy) = \log_b x + \log_b y')],
  figure: BriefFigure.combineLogs,
  handbook: 'Handbook pp. 36-37',
);

// ── Right Triangle Trigonometry ─────────────────────────────────────────────

const ratiosBrief = BriefSection(
  title: 'The three ratios',
  body:
      'Every right triangle gives you three ratios relative to the angle you '
      'marked. Pick the one that connects what you know to what you want: '
      'opposite over hypotenuse is sine, adjacent over hypotenuse is cosine, '
      'opposite over adjacent is tangent. Cos is cozy with the adjacent side, '
      'the one touching the angle.',
  formulas: [
    ('SOH', r'\sin\theta = \frac{\text{opp}}{\text{hyp}}'),
    ('CAH', r'\cos\theta = \frac{\text{adj}}{\text{hyp}}'),
    ('TOA', r'\tan\theta = \frac{\text{opp}}{\text{adj}}'),
  ],
  figure: BriefFigure.ratios,
  handbook: 'Handbook p. 23',
);

const sideNamesBrief = BriefSection(
  title: 'Opposite, adjacent, hypotenuse',
  body:
      'The hypotenuse is always the side across from the right angle, so it '
      'never moves. The other two names belong to the angle you marked, not to '
      'the page: opposite is the side that does not touch it, and adjacent is '
      'the OTHER side that does, the one that is not the hypotenuse. Mark the '
      'other corner and those two swap without a line moving.',
  formulas: [
    ('Always across from the right angle', r'\text{hyp}'),
    ('Named against the marked angle', r'\text{opp} \;/\; \text{adj}'),
  ],
  figure: BriefFigure.sideNames,
  handbook: 'Handbook p. 23',
);

const componentsBrief = BriefSection(
  title: 'Resolving a force',
  body:
      'A force at an angle splits into two sides of a right triangle. The '
      'component along the axis the angle is measured FROM is the adjacent one, '
      'so it takes the cosine, and the other takes the sine. That is why an '
      'angle quoted from the vertical swaps the two, and it is the single '
      'biggest trap in this topic.',
  formulas: [
    (
      'Angle from the horizontal',
      r'F_x = F\cos\theta \qquad F_y = F\sin\theta',
    ),
    (
      'Angle from the vertical, the two swap',
      r'F_x = F\sin\theta \qquad F_y = F\cos\theta',
    ),
  ],
  figure: BriefFigure.components,
  handbook: 'Handbook p. 23',
);

// ── Law of Sines & Law of Cosines ───────────────────────────────────────────

const whichLawBrief = BriefSection(
  title: 'Which law, and when',
  body:
      'An oblique triangle has no right angle, so there is no hypotenuse and '
      'no opposite-over-adjacent to fall back on. Two relations hold in every '
      'triangle instead. The Law of Sines says each side is proportional to '
      'the sine of the angle facing it, so a side and its own angle fix the '
      'scale for the whole triangle. The Law of Cosines is the Pythagorean '
      'theorem with a correction: it subtracts a term that vanishes at 90 '
      'degrees, because cos 90 is zero, and grows as the angle opens or '
      'closes.\n\nSo: a side with the angle opposite it opens Sines. Two '
      'sides with the angle between them, or all three sides, leaves nothing '
      'paired and it is Cosines.',
  formulas: [
    ('Law of Sines', r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C}'),
    ('Law of Cosines', r'c^2 = a^2 + b^2 - 2ab\cos C'),
  ],
  figure: BriefFigure.lawChoice,
  handbook: 'Handbook p. 23',
);

const setupBrief = BriefSection(
  title: 'Writing the two laws',
  body:
      'Every side sits over the sine of its OWN angle, which is what makes '
      'the ratio easy to flip by accident. The Law of Cosines is the '
      'Pythagorean theorem with a correction term subtracted, never added, and '
      'the angle in it is always the one opposite the side you are after.',
  formulas: [
    ('Law of Sines', r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C}'),
    ('Law of Cosines', r'c^2 = a^2 + b^2 - 2ab\cos C'),
    ('Rearranged for an angle', r'\cos C = \frac{a^2 + b^2 - c^2}{2ab}'),
  ],
  figure: BriefFigure.lawForms,
  handbook: 'Handbook p. 23',
);

const obtuseBrief = BriefSection(
  title: 'What a negative cosine means',
  body:
      'Rearranged for an angle, the Law of Cosines puts the side opposite '
      'that angle on the top with a minus in front. When the longest side '
      'squared beats the other two put together, the top goes negative, the '
      'cosine goes negative, and the angle is obtuse. Inverse cosine already '
      'returns the obtuse angle, so nothing needs subtracting from 180.',
  formulas: [
    ('Rearranged for the angle', r'\cos C = \frac{a^2 + b^2 - c^2}{2ab}'),
    ('And the test that follows', r'c^2 > a^2 + b^2 \iff C > 90^\circ'),
  ],
  figure: BriefFigure.cosineSign,
  handbook: 'Handbook p. 23',
);

// ── Unit Circle & Trig Identities ───────────────────────────────────────────

const unitCircleBrief = BriefSection(
  title: 'Reading the unit circle',
  body:
      'A circle of radius one, with an angle swept from the positive x-axis. '
      'Wherever that angle lands, the point is (cos, sin): cosine is how far '
      'ACROSS and sine is how far UP. That is the whole definition, and it is '
      'why swapping the two swaps 30 degrees for 60. Learn the first quadrant '
      'and the rest is a mirror.',
  formulas: [
    ('The point at any angle', r'(\cos\theta,\; \sin\theta)'),
    (
      'The three worth knowing cold',
      r'30^\circ:\left(\tfrac{\sqrt{3}}{2},\tfrac{1}{2}\right)\quad '
          r'45^\circ:\left(\tfrac{\sqrt{2}}{2},\tfrac{\sqrt{2}}{2}\right)\quad '
          r'60^\circ:\left(\tfrac{1}{2},\tfrac{\sqrt{3}}{2}\right)',
    ),
  ],
  figure: BriefFigure.unitCircle,
  handbook: 'Handbook p. 23',
);

const quadrantBrief = BriefSection(
  title: 'Signs by quadrant',
  body:
      'The Pythagorean identity can only ever give you the size of a value, '
      'because squaring throws the sign away. The quadrant puts it back. '
      'Across is positive to the right, up is positive above, so cosine is '
      'positive in quadrants one and four and sine is positive in one and '
      'two. Solving for a value and stopping before the quadrant is the '
      'mistake this exists for.',
  formulas: [
    ('It gives the size', r'\cos\theta = \pm\sqrt{1 - \sin^2\theta}'),
    (
      'The quadrant gives the sign',
      r'\text{Q1}: ++ \quad \text{Q2}: -+ \quad \text{Q3}: -- \quad \text{Q4}: +-',
    ),
  ],
  figure: BriefFigure.quadrants,
  handbook: 'Handbook p. 23',
);

const identitiesBrief = BriefSection(
  title: 'The identities worth knowing',
  body:
      'Know the Pythagorean identity cold and recognize the double angles '
      'when they appear. Doubling an angle is NOT doubling its sine: sin 2θ '
      'needs both functions and a factor of two out front, and cos 2θ is a '
      'difference of squares in that order.',
  formulas: [
    ('Pythagorean', r'\sin^2\theta + \cos^2\theta = 1'),
    ('Double angle, sine', r'\sin 2\theta = 2\sin\theta\cos\theta'),
    ('Double angle, cosine', r'\cos 2\theta = \cos^2\theta - \sin^2\theta'),
  ],
  figure: BriefFigure.identities,
  handbook: 'Handbook p. 23',
);

// ── Circles & Conic Sections ────────────────────────────────────────────────

const circleFormBrief = BriefSection(
  title: 'Reading a circle',
  body:
      'A circle in standard form hands you everything: the center and the '
      'radius, with no work. Two things bite. The sign inside each bracket is '
      'the OPPOSITE of the coordinate, so (y + 3) puts the center three below '
      'the axis. And the number on the right is the radius SQUARED, so 64 is a '
      'circle of radius eight.',
  formulas: [
    ('Standard form', r'(x-h)^2 + (y-k)^2 = r^2'),
    ('Which reads as', r'\text{center } (h,k), \quad \text{radius } r'),
  ],
  figure: BriefFigure.circleForm,
  handbook: 'Handbook p. 24',
);

const readingConicsBrief = BriefSection(
  title: 'The three forms',
  body:
      'A circle has both squares, both positive, with the same coefficient. '
      'A parabola has exactly ONE square, and the sign in front of it decides '
      'which way the curve opens. An ellipse has both squares over different '
      'denominators, and the larger denominator lies under the long axis. Most '
      'of what the exam asks about conics is reading which of the three you '
      'are holding.',
  formulas: [
    ('Circle', r'(x-h)^2 + (y-k)^2 = r^2'),
    ('Parabola', r'y = a(x-h)^2 + k'),
    ('Ellipse', r'\frac{(x-h)^2}{a^2} + \frac{(y-k)^2}{b^2} = 1'),
    ('And a parabola\'s peak', r'x = -\frac{b}{2a}'),
  ],
  figure: BriefFigure.conicForms,
  handbook: 'Handbook p. 24',
);

const completeSquareBrief = BriefSection(
  title: 'Completing the square',
  body:
      'General form hides the center, so you rewrite it. Take the coefficient '
      'of the plain x term, halve it, square it, and add that. The sign inside '
      'does not matter, because squaring removes it. The whole of the '
      'difficulty is that whatever you add has to be added on BOTH sides: add '
      'it only on the left and you have quietly changed the equation, and the '
      'radius you read off at the end is wrong.',
  formulas: [
    ('General form', r'x^2 + y^2 + Dx + Ey + F = 0'),
    ('Halve, square, add to both sides', r'x^2 - 10x \;\to\; (x-5)^2 - 25'),
  ],
  figure: BriefFigure.completingSquare,
  handbook: 'Handbook p. 24',
);

// ── Derivatives & Derivative Rules ──────────────────────────────────────────

const whichRuleBrief = BriefSection(
  title: 'Which rule, and how many',
  body:
      'The handbook has the table; what it cannot tell you is which rule the '
      'shape of your function calls for. Ask two questions. Is anything '
      'multiplied or divided? That is the product or quotient rule. Is any '
      'argument something other than plain x? That is the chain rule. Both '
      'answers can be yes at once, and on this exam they usually are.',
  formulas: [
    ('Product', r'\frac{d}{dx}(uv) = u\frac{dv}{dx} + v\frac{du}{dx}'),
    (
      'Quotient',
      r'\frac{d}{dx}\!\left(\frac{u}{v}\right) = \frac{v\frac{du}{dx} - u\frac{dv}{dx}}{v^2}',
    ),
    ('Chain', r"\frac{d}{dx}f(g(x)) = f'(g(x)) \cdot g'(x)"),
  ],
  figure: BriefFigure.whichRule,
  handbook: 'Handbook p. 49',
);

const chainRuleBrief = BriefSection(
  title: 'The chain rule, and the factor people drop',
  body:
      'If the argument is anything other than plain x, differentiating the '
      'outside is only half the job: the derivative of the inside multiplies '
      'it, from outside. It never moves into the argument. Almost every '
      'derivative on this exam is a chain rule in disguise, and the missing '
      'inner factor is the single most common wrong answer.',
  formulas: [
    ('The rule', r"\frac{d}{dx}f(g(x)) = f'(g(x)) \cdot g'(x)"),
    ('So', r'\frac{d}{dx}(3x+5)^4 = 4(3x+5)^3 \cdot 3'),
  ],
  figure: BriefFigure.chainRule,
  handbook: 'Handbook p. 49',
);

const quotientOrderBrief = BriefSection(
  title: 'Lo d-hi minus hi d-lo',
  body:
      'The quotient rule is the biggest generator of sign errors on this '
      'exam, and the order is the whole reason. The BOTTOM function comes '
      'first, multiplying the derivative of the top. Swap the two terms and '
      'the answer comes out with the wrong sign throughout. And the '
      'denominator is squared, which is the other half people drop.',
  formulas: [
    (
      'Quotient rule',
      r'\frac{d}{dx}\!\left(\frac{u}{v}\right) = \frac{v\frac{du}{dx} - u\frac{dv}{dx}}{v^2}',
    ),
    ('Said out loud', r'\text{lo d-hi} - \text{hi d-lo, over lo-lo}'),
  ],
  figure: BriefFigure.quotientOrder,
  handbook: 'Handbook p. 49',
);

// ── Applications of Derivatives ─────────────────────────────────────────────

const criticalPointBrief = BriefSection(
  title: 'Flat first, then which way it bends',
  body:
      'A curve is at its highest or lowest where its slope is zero, so the '
      'first move is always the same: differentiate and set it to zero. That '
      'alone does not tell you which one you found. The second derivative '
      'does. Negative means the curve frowns, so you are on a hilltop; '
      'positive means it smiles, so you are in a valley. A curve can have '
      'both, and on this exam it often does.',
  formulas: [
    ("Maximum", r"f'(a) = 0 \;\text{and}\; f''(a) < 0"),
    ("Minimum", r"f'(a) = 0 \;\text{and}\; f''(a) > 0"),
  ],
  figure: BriefFigure.maxMin,
  handbook: 'Handbook p. 46',
);

const concavityBrief = BriefSection(
  title: 'Smiles, frowns, and the flip',
  body:
      'The second derivative is not about the slope, it is about the bend. '
      'Positive is concave up, a smile; negative is concave down, a frown. An '
      'inflection point is where the bend changes, and it takes TWO things: '
      'the second derivative reaches zero AND it comes out the other side '
      'with the opposite sign. Reaching zero on its own is not enough, and a '
      'flat spot is not an inflection point.',
  formulas: [
    ('Concave up, a smile', r"f''(x) > 0"),
    ('Concave down, a frown', r"f''(x) < 0"),
    (
      'Inflection point',
      r"f''(a) = 0 \;\text{and}\; f'' \text{ changes sign}",
    ),
  ],
  figure: BriefFigure.bendFlip,
  handbook: 'Handbook p. 46',
);

const askedForBrief = BriefSection(
  title: 'Where it happens, or how much',
  body:
      'Setting the derivative to zero gives you a LOCATION. Almost half the '
      'time the question wants the value there instead, which means putting '
      'that location back into the original function. Both numbers are on '
      'your page by then and the exam will offer you both. Read the sentence '
      'again before you pick one.',
  formulas: [
    ('Where it happens', r"f'(a) = 0 \Rightarrow a"),
    ('How much it is there', r'f(a)'),
  ],
  figure: BriefFigure.whereOrHowMuch,
  handbook: 'Handbook p. 46',
);

// ── Integral Calculus ───────────────────────────────────────────────────────

const substitutionBrief = BriefSection(
  title: 'Substitution, and what du has to be',
  body:
      'Substitution works on one shape and one shape only: something composed '
      'with something else, multiplied by the derivative of the inside. Call '
      'the inside u, and the leftover has to BE du, or du off by a constant '
      'factor. If the derivative of your u is nowhere in the integrand, '
      'substitution is not the tool and no amount of rearranging will make it '
      'one.',
  formulas: [
    ('The shape it needs', r"\int f(g(x))\,g'(x)\,dx"),
    ('Let u be the inside', r"u = g(x) \;\Rightarrow\; du = g'(x)\,dx"),
    ('And it becomes', r'\int f(u)\,du'),
  ],
  figure: BriefFigure.substitution,
  handbook: 'Handbook p. 50',
);

const byPartsBrief = BriefSection(
  title: 'By parts, and which one is u',
  body:
      'By parts trades the integral you have for a different one. It is worth '
      'doing only when the trade leaves you better off, and what decides that '
      'is which factor you put in the u slot: u gets differentiated, dv gets '
      'integrated. LIATE names the order to prefer, Logs then Inverse trig '
      'then Algebraic then Trig then Exponential, and the reason is that the '
      'earlier ones get easier when you differentiate them.',
  formulas: [
    ('The rule', r'\int u\,dv = uv - \int v\,du'),
    ('LIATE, best first', r'\text{L} \;\;\text{I} \;\;\text{A} \;\;\text{T} \;\;\text{E}'),
  ],
  figure: BriefFigure.liate,
  handbook: 'Handbook p. 50',
);

const finishingBrief = BriefSection(
  title: 'Finishing an integral',
  body:
      'The antiderivative is most of the work and none of the marks. An '
      'indefinite integral is a family of functions, so it ends in plus C. A '
      'definite integral is a number: put in the top limit, subtract the '
      'bottom one, and the constant cancels itself, so plus C has no business '
      'being there. And if you substituted, the limits belong to the new '
      'variable.',
  formulas: [
    ('Indefinite, a family', r'\int f(x)\,dx = F(x) + C'),
    ('Definite, a number', r'\int_a^b f(x)\,dx = F(b) - F(a)'),
  ],
  figure: BriefFigure.finishing,
  handbook: 'Handbook p. 50',
);

// ── L'Hopital's Rule ────────────────────────────────────────────────────────

const formCheckBrief = BriefSection(
  title: 'Check the form before you differentiate',
  body:
      'The rule is a loop with a test in the middle of it. Put the value in '
      'first. Zero over zero or infinity over infinity means the rule applies, '
      'so differentiate the top and the bottom and put the value in again. A '
      'real number means you already have the answer and the rule would only '
      'change it. A nonzero number over zero is not indeterminate at all, it '
      'is a blow up, and the rule has nothing to say about it.',
  formulas: [
    (
      'The rule, when the form allows it',
      r"\lim_{x \to a}\frac{f(x)}{g(x)} = \lim_{x \to a}\frac{f'(x)}{g'(x)}",
    ),
    ('The two forms that allow it', r'\frac{0}{0} \quad \frac{\infty}{\infty}'),
  ],
  figure: BriefFigure.formCheck,
  handbook: 'Handbook p. 48',
);

const separatelyBrief = BriefSection(
  title: 'Top and bottom, separately',
  body:
      'This is not the quotient rule. The quotient rule is for the derivative '
      'of a fraction; this is the limit of one, and they are different jobs '
      'with different answers. Differentiate the numerator on its own, '
      'differentiate the denominator on its own, and put the two results back '
      'over each other. Nothing multiplies, nothing gets squared.',
  formulas: [
    ('What the rule does', r"\frac{f}{g} \;\Rightarrow\; \frac{f'}{g'}"),
    (
      'What the quotient rule does, which is not this',
      r"\frac{f'g - fg'}{g^2}",
    ),
  ],
  figure: BriefFigure.separately,
  handbook: 'Handbook p. 48',
);

const bothSidesBrief = BriefSection(
  title: 'Both sides have to agree',
  body:
      'When the top settles on something other than zero and the bottom goes '
      'to zero, the fraction blows up. Which way it blows up depends on the '
      'sign of the bottom, and that can be different on the two sides of the '
      'point. If both sides run the same way the limit is that infinity. If '
      'they run opposite ways there is no two-sided limit at all, and the '
      'answer is that it does not exist, not that it is infinite.',
  formulas: [
    ('Sides agree', r'\lim_{x \to 0}\frac{1}{x^2} = +\infty'),
    (
      'Sides disagree',
      r'\lim_{x \to 0}\frac{1}{x} \;\Rightarrow\; \text{does not exist}',
    ),
  ],
  figure: BriefFigure.bothSides,
  handbook: 'Handbook p. 48',
);

// ── Vector Basics & Unit Vectors ────────────────────────────────────────────

const vectorAddBrief = BriefSection(
  title: 'Adding arrows, one direction at a time',
  body:
      'Vectors add component by component: all the across parts together, all '
      'the up parts together, signs kept. Never length by length. Two forces '
      'of 500 do not make 1000 unless they point the same way, and if they '
      'point opposite ways they make nothing at all. Lay them head to tail and '
      'the resultant is the arrow from where you started to where you ended.',
  formulas: [
    ('Component form', r'\vec{A} = A_x\hat{i} + A_y\hat{j} + A_z\hat{k}'),
    (
      'Added component by component',
      r'\vec{A} + \vec{B} = (A_x + B_x)\hat{i} + (A_y + B_y)\hat{j}',
    ),
  ],
  figure: BriefFigure.vectorAdd,
  handbook: 'Handbook p. 94',
);

const unitVectorBrief = BriefSection(
  title: 'Direction without size',
  body:
      'A unit vector points where you want and is exactly one long, so it '
      'carries a direction and nothing else. Get one by dividing a vector by '
      'its own length. Then a force along that line is just the magnitude '
      'times the unit vector, and every component falls out of it. Multiplying '
      'by a negative scalar keeps the line and turns the arrow around.',
  formulas: [
    ('Divide by its own length', r'\hat{u}_A = \frac{\vec{A}}{|\vec{A}|}'),
    ('Then size it', r'\vec{F} = F\,\hat{u}'),
    ('From one point to another', r'\vec{AB} = B - A'),
  ],
  figure: BriefFigure.unitVector,
  handbook: 'Handbook p. 94',
);

const magnitudeBrief = BriefSection(
  title: 'A magnitude is not a component',
  body:
      'The length of a vector is the square root of the sum of its squared '
      'components. It is never the components added up, and the squaring is '
      'why: an arrow that splits its length between two directions gets less '
      'far than one that spends it all on a single direction. A component on '
      'its own is only a shadow on one axis, and it is allowed to be negative. '
      'A length never is.',
  formulas: [
    ('Length', r'|\vec{A}| = \sqrt{A_x^2 + A_y^2 + A_z^2}'),
    ('Worth knowing on sight', r'3, 4, 5 \quad 6, 8, 10'),
  ],
  figure: BriefFigure.magnitude,
  handbook: 'Handbook p. 94',
);

// ── Dot Product & Angle Between Vectors ─────────────────────────────────────

const dotProductBrief = BriefSection(
  title: 'Matching components, and a number at the end',
  body:
      'The dot product pairs each component with its OWN partner: across with '
      'across, up with up, and signs kept. Multiply the pairs and add them. '
      'Pairing across with up is the cross product wearing the wrong name, and '
      'it is the fastest way to lose this question. Whatever comes out is a '
      'plain number: if your answer still has an i or a j in it, you have done '
      'the other product.',
  formulas: [
    (
      'Component form',
      r'\vec{A} \cdot \vec{B} = A_xB_x + A_yB_y + A_zB_z',
    ),
    ('And it is a scalar', r'\vec{A} \cdot \vec{B} \in \mathbb{R}'),
  ],
  figure: BriefFigure.dotProduct,
  handbook: 'Handbook p. 94',
);

const dotAngleBrief = BriefSection(
  title: 'The sign is the angle',
  body:
      'The other formula for the same number is the two lengths times the '
      'cosine of the angle between them. Lengths are always positive, so the '
      'sign of a dot product is nothing but the sign of that cosine. Under '
      'ninety degrees it is positive, over ninety it is negative, and exactly '
      'ninety makes it zero. That last one is the fastest perpendicularity '
      'check there is. For the angle itself, rearrange and take the inverse '
      'cosine, and remember that the cosine is not the angle.',
  formulas: [
    ('Angle form', r'\vec{A} \cdot \vec{B} = |\vec{A}||\vec{B}|\cos\theta'),
    (
      'Rearranged for the angle',
      r'\theta = \cos^{-1}\!\left(\frac{\vec{A} \cdot \vec{B}}{|\vec{A}||\vec{B}|}\right)',
    ),
    ('Perpendicular', r'\vec{A} \cdot \vec{B} = 0'),
  ],
  figure: BriefFigure.dotAngle,
  handbook: 'Handbook p. 94',
);

const projectionBrief = BriefSection(
  title: "How much of a force lands on a member",
  body:
      'The component of a force along a direction is the length of its shadow '
      'on that direction. Take the dot product and divide by the length of the '
      'DIRECTION, not of the force. Leaving it undivided gives you the shadow '
      'multiplied by the member length, which is not a force at all, and '
      'dividing by the force instead gives you a number that forgot what it '
      'was measuring. The sign survives: negative means the force runs back '
      'along the member rather than out along it.',
  formulas: [
    (
      'Scalar projection',
      r'\text{proj}_{\vec{B}}\vec{A} = \frac{\vec{A} \cdot \vec{B}}{|\vec{B}|}',
    ),
    ('Which is just', r'\vec{A} \cdot \hat{u}_B'),
  ],
  figure: BriefFigure.projection,
  handbook: 'Handbook p. 94',
);

// ── Cross Product & Applications ────────────────────────────────────────────

const rightHandBrief = BriefSection(
  title: 'Which way it turns, and why order matters',
  body:
      'A cross product is a VECTOR, and it points perpendicular to both of the '
      'arrows that made it. Which of the two perpendicular directions is '
      'settled by the right hand: fingers along the first arrow, curl them to '
      'the second, and the thumb is the answer. Sweeping counterclockwise '
      'brings it out of the page, clockwise sends it in. Swap the two arrows '
      'and the answer flips, which is why a moment is r cross F and never the '
      'other way. Two arrows on the same line cross to nothing.',
  formulas: [
    ('The moment of a force', r'\vec{M}_O = \vec{r} \times \vec{F}'),
    ('Order flips it', r'\vec{A} \times \vec{B} = -(\vec{B} \times \vec{A})'),
    ('And a vector with itself', r'\vec{A} \times \vec{A} = \vec{0}'),
  ],
  figure: BriefFigure.rightHand,
  handbook: 'Handbook p. 94',
);

const areaBrief = BriefSection(
  title: 'The parallelogram, and half of it',
  body:
      'The size of a cross product is the area of the parallelogram the two '
      'arrows span. A triangle with those two edges is half of that, so a plot '
      'bounded by them takes a division by two that the formula will not '
      'remind you about. The sine is what accounts for the lean: multiplying '
      'the two lengths on their own would give the box around the whole thing, '
      'which is only right when the edges meet square.',
  formulas: [
    (
      'Parallelogram',
      r'|\vec{A} \times \vec{B}| = |\vec{A}||\vec{B}|\sin\theta',
    ),
    ('Triangle', r'\tfrac{1}{2}|\vec{A} \times \vec{B}|'),
  ],
  figure: BriefFigure.crossArea,
  handbook: 'Handbook p. 94',
);

const cofactorBrief = BriefSection(
  title: 'Plus, minus, plus',
  body:
      'The cross product comes out of a three by three determinant with i, j '
      'and k across the top. Expanding it gives three components and the '
      'middle one is SUBTRACTED. That is the whole of the tip and it is worth '
      'the space: a minus in front of a bracket that already holds a negative '
      'number is the single most reliable way to hand in a moment that points '
      'the wrong way. Whatever comes out is a vector, so if the question '
      'wanted a size, take the magnitude afterwards.',
  formulas: [
    (
      'The determinant',
      r'\vec{A} \times \vec{B} = \begin{vmatrix} \hat{i} & \hat{j} & \hat{k} \\ A_x & A_y & A_z \\ B_x & B_y & B_z \end{vmatrix}',
    ),
    (
      'Expanded',
      r'(A_yB_z - A_zB_y)\hat{i} - (A_xB_z - A_zB_x)\hat{j} + (A_xB_y - A_yB_x)\hat{k}',
    ),
  ],
  figure: BriefFigure.cofactor,
  handbook: 'Handbook p. 94',
);

// ── Spreadsheet Computations ────────────────────────────────────────────────

const referencesBrief = BriefSection(
  title: 'What moves when you copy',
  body:
      'A plain reference like A1 is relative: copy the formula somewhere else '
      'and it shifts by however far you moved. A dollar sign pins whatever '
      'comes straight after it, so \$A\$1 never moves, A\$1 keeps its row and '
      'slides across, and \$A1 keeps its column and slides down. This is the '
      'most tested spreadsheet idea on the exam and the missing dollar sign is '
      'the most common mistake made on it: the rate drifts down the column and '
      'every row under the first is quietly wrong.',
  formulas: [
    ('Moves with the copy', r'\text{A1}'),
    ('Pinned completely', r'\text{\$A\$1}'),
    ('Row pinned, column free', r'\text{A\$1}'),
    ('Column pinned, row free', r'\text{\$A1}'),
  ],
  figure: BriefFigure.references,
  handbook: 'FE Handbook, spreadsheet section',
);

const precedenceBrief = BriefSection(
  title: 'A sheet does not read left to right',
  body:
      'Formulas follow the same precedence as algebra: brackets first, then '
      'powers, then multiplication and division, then addition and '
      'subtraction. Anything of equal rank runs left to right. So a formula '
      'adding one cell to another divided by a third does the division first, '
      'whatever the reading order suggests, and brackets are the only way to '
      'change that.',
  formulas: [
    ('Times before plus', r'\text{=2+3*4} \;\Rightarrow\; 14'),
    ('Brackets force it', r'\text{=(2+3)*4} \;\Rightarrow\; 20'),
  ],
  figure: BriefFigure.precedence,
  handbook: 'FE Handbook, spreadsheet section',
);

const functionsBrief = BriefSection(
  title: 'What the common functions actually return',
  body:
      'SUM adds a range, AVERAGE takes its mean, MAX and MIN pull the biggest '
      'and smallest, and COUNT counts only the cells holding NUMBERS, so a '
      'cell of text inside the range is skipped. A colon means every cell from '
      'one end to the other. IF checks its test first and hands back the '
      'second argument when the test passes and the third when it fails; it '
      'returns that value, never a 1 for true.',
  formulas: [
    ('A range', r'\text{=SUM(B1:B3)}'),
    ('Test, then true, then false', r'\text{=IF(A1>=10, A1*2, A1+5)}'),
  ],
  figure: BriefFigure.functions,
  handbook: 'FE Handbook, spreadsheet section',
);

// ── Structured Programming ──────────────────────────────────────────────────

const tracingBrief = BriefSection(
  title: 'Trace it, one row per pass',
  body:
      'Every routine is built out of three things: statements in order, a '
      'choice between paths, and a repeat. On this exam you trace them by '
      'hand, and the way to do that is to write the variables in a column and '
      'update them pass by pass rather than trying to hold the whole loop in '
      'your head. A counted loop from one to four runs FOUR times, because '
      'both ends are included, and the off-by-one is the trap. The answer is '
      'usually the last row of the table, not the number of rows.',
  formulas: [
    ('Runs four times', r'\text{FOR i = 1 TO 4}'),
    ('The rows it makes', r'1,\; 3,\; 6,\; 10'),
  ],
  figure: BriefFigure.tracing,
  handbook: 'FE Handbook, computational tools',
);

const selectionBrief = BriefSection(
  title: 'The first true condition wins',
  body:
      'A chain of conditions is checked from the top down and it stops at the '
      'first one that holds. Everything below is skipped, including a later '
      'test that would also have been true, so a chain is not a search for the '
      'best fit. The closing ELSE only runs when every test above it has '
      'failed, and reading the whole chain before deciding is how people end '
      'up there by mistake. Watch the boundaries: greater than excludes the '
      'number itself, greater than or equal to includes it.',
  formulas: [
    ('Checked in this order', r'\text{IF} \to \text{ELSE IF} \to \text{ELSE}'),
    ('x = 7 lands here', r'\text{ELSE IF x > 5} \;\Rightarrow\; \text{y = 2}'),
  ],
  figure: BriefFigure.selection,
  handbook: 'FE Handbook, computational tools',
);

const iterationBrief = BriefSection(
  title: 'A WHILE checks before it acts',
  body:
      'A WHILE loop tests its condition before every pass, including the very '
      'first one. That has two consequences people lose marks on. The value '
      'left in the variable at the end is the one that BROKE the condition, '
      'not the last one that satisfied it, and nothing is capped at the limit '
      'in the condition. And if the condition is already false when the loop '
      'is reached, the body never runs at all.',
  formulas: [
    ('Doubling from 1 while under 100', r'1,\;2,\;4,\;8,\;16,\;32,\;64,\;128'),
    ('What is left', r'x = 128'),
  ],
  figure: BriefFigure.iteration,
  handbook: 'FE Handbook, computational tools',
);

// ── Numerical Methods: Root-Finding ─────────────────────────────────────────

const newtonBrief = BriefSection(
  title: 'Slide down the tangent',
  body:
      "Newton's method is a picture before it is a formula. Stand on the curve "
      'at your guess, follow the tangent down to the axis, and stand there '
      'instead. That is what dividing the function by its slope does. Nearer a '
      'root every curve is almost straight, which is why the method closes in '
      'so fast once it is close, and why a nearly flat slope is a disaster: '
      'the tangent then meets the axis a very long way from anywhere useful.',
  formulas: [
    ('One iteration', r"x_{j+1} = x_j - \frac{f(x_j)}{f'(x_j)}"),
    ('From 4 on x squared minus 4', r'4 - \frac{12}{8} = 2.5'),
  ],
  figure: BriefFigure.newton,
  handbook: 'Handbook p. 61',
);

const bisectionBrief = BriefSection(
  title: 'Opposite sides, then halve it',
  body:
      'Bisection asks for one thing: the function on opposite sides of the '
      'axis at the two ends of the interval, which is the same as the two '
      'values multiplying to something negative. Then it halves the interval '
      'and keeps whichever half still has the sign change. Same-signed ends do '
      'NOT mean there is no root in there, they mean this method cannot be '
      'started, which is a different thing. An interval holding two roots '
      'fails the test for exactly that reason.',
  formulas: [
    ('The whole requirement', r'f(a)\cdot f(b) < 0'),
    ('Then keep the half that still has it', r'[a, m] \text{ or } [m, b]'),
  ],
  figure: BriefFigure.bisection,
  handbook: 'Handbook p. 61',
);

const methodChoiceBrief = BriefSection(
  title: 'Fast, or guaranteed',
  body:
      "Newton is fast and demanding: it wants the derivative and a guess that "
      'is already near the root. Give it either a poor guess or a slope near '
      'zero and it can wander off or swing back and forth without settling. '
      'Bisection is slow and undemanding: no derivative, no good guess, just a '
      'sign change to start from, and it cannot fail once it has one. Which '
      'you reach for is decided by what you have, not by which is cleverer.',
  formulas: [
    ('Newton wants', r"f'(x) \text{ and a close } x_0"),
    ('Bisection wants', r'f(a)\cdot f(b) < 0'),
  ],
  figure: BriefFigure.methodChoice,
  handbook: 'Handbook p. 61',
);

// ── Measures of Central Tendency & Dispersion ───────────────────────────────

const centerBrief = BriefSection(
  title: 'Three centers, and when they disagree',
  body:
      'The mean adds everything up and divides by the count. The median is the '
      'middle value once the readings are sorted, and with an even count it is '
      'the average of the middle two. The mode is whatever turns up most often, '
      'and a set can have none or several of them. They agree on tidy data and '
      'part company the moment one reading is a long way out: the mean gets '
      'dragged toward it and the median does not move at all.',
  formulas: [
    ('Mean', r'\bar{x} = \frac{1}{n}\sum x_i'),
    ('Median', r'\text{the middle value, once sorted}'),
  ],
  figure: BriefFigure.center,
  handbook: 'Handbook p. 63',
);

const spreadBrief = BriefSection(
  title: 'Sample or population, and the square root',
  body:
      'Variance is the average squared distance from the mean, and the standard '
      'deviation is its square root, in the units of the data. The only '
      'difference between the sample and the population version is the '
      'denominator: n minus one for a sample, N for the whole population. This '
      'exam almost always means a sample, and dividing by n instead is the '
      'single most common mistake on the topic. On a calculator that is Sx '
      'against sigma x, two lines apart on the same screen. The coefficient of '
      'variation is the standard deviation over the mean, which is '
      'dimensionless and lets two data sets in different units be compared.',
  formulas: [
    ('Sample variance', r's^2 = \frac{\sum (x_i - \bar{x})^2}{n-1}'),
    ('Population variance', r'\sigma^2 = \frac{\sum (x_i - \mu)^2}{N}'),
    ('Coefficient of variation', r'CV = \frac{s}{\bar{x}}'),
  ],
  figure: BriefFigure.spread,
  handbook: 'Handbook p. 63',
);

const weightedBrief = BriefSection(
  title: 'What is averaged, and what counts for more',
  body:
      'A weighted average is the same average with some readings counting for '
      'more than others. The whole difficulty is naming the two roles: what is '
      'being averaged, and how much each row gets to say. Weight by how long a '
      'count ran, how many cylinders were tested, how thick a layer is. If the '
      'weights are all equal it collapses back to the ordinary mean, and if you '
      'swap the two roles the arithmetic runs perfectly to the wrong answer.',
  formulas: [
    ('Weighted mean', r'\bar{x}_w = \frac{\sum w_i x_i}{\sum w_i}'),
  ],
  figure: BriefFigure.weighted,
  handbook: 'Handbook p. 63',
);

const correlationBrief = BriefSection(
  title: 'What r is telling you',
  body:
      'The correlation coefficient runs from minus one to plus one. Its sign '
      'is the direction the cloud leans and its size is how tightly the '
      'readings hug a line, and both of those are read off the plot rather '
      'than computed. What it will not tell you is whether there is a '
      'relationship at all: r only measures agreement with a STRAIGHT line, '
      'so a cloud that rises and then falls can have an obvious shape and a '
      'correlation of nothing.',
  formulas: [
    ('The range it lives in', r'-1 \le r \le +1'),
    (
      'Correlation',
      r'r = \frac{n\sum x_i y_i - \sum x_i \sum y_i}'
          r'{\sqrt{\left[n\sum x_i^2 - (\sum x_i)^2\right]'
          r'\left[n\sum y_i^2 - (\sum y_i)^2\right]}}',
    ),
  ],
  figure: BriefFigure.correlation,
  handbook: 'Handbook p. 69',
);

const regressionLineBrief = BriefSection(
  title: 'The line goes through the means',
  body:
      'A least-squares line is an intercept plus a slope times x, and it '
      'always passes through the point where the two means meet. That one '
      'fact is where the intercept comes from: rearranged, it is the mean of '
      'y less the slope times the mean of x. It is also why a prediction '
      'needs both terms. Slope times x and nothing else is a line through the '
      'origin, which is the right lean in the wrong place.',
  formulas: [
    ('The line', r'\hat{y} = a + bx'),
    ('The intercept', r'a = \bar{y} - b\bar{x}'),
    (
      'Slope',
      r'b = \frac{n\sum x_i y_i - \sum x_i \sum y_i}'
          r'{n\sum x_i^2 - (\sum x_i)^2}',
    ),
  ],
  figure: BriefFigure.regressionLine,
  handbook: 'Handbook p. 69',
);

const determinationBrief = BriefSection(
  title: 'Correlation, or determination',
  body:
      'These are two numbers and the exam asks for them in English. The '
      'correlation is r, it carries a sign, and it says which way and how '
      'tightly. The coefficient of determination is r squared, it is always '
      'positive, and it is the share of the variation in y that x accounts '
      'for. Squaring is not the hard part; hearing which one the sentence '
      'asked for is. And a negative coefficient of determination is not so '
      'much a wrong answer as an impossible one.',
  formulas: [
    ('Determination', r'R^2 = r^2'),
    ('So', r'r = -0.92 \;\Rightarrow\; R^2 = 0.846'),
    ('And what is left unexplained', r'1 - R^2'),
  ],
  figure: BriefFigure.determination,
  handbook: 'Handbook p. 69',
);

const countingBrief = BriefSection(
  title: 'Order, or just a group',
  body:
      'Both counts start from the same pool and the same number of picks. The '
      'only question is whether the same picks in a different order count as a '
      'second result. If the positions mean something different from one '
      'another, a rank, a job, a place in a sequence, then order matters and '
      'it is a permutation. If the picks all get the same treatment, it is a '
      'combination, and the permutation answer will be too big by exactly r '
      'factorial.',
  formulas: [
    ('Order matters', r'P(n, r) = \frac{n!}{(n-r)!}'),
    ('Order does not', r'C(n, r) = \frac{n!}{r!\,(n-r)!}'),
    ('So', r'P(8,3) = 336 \;\Rightarrow\; C(8,3) = \frac{336}{3!} = 56'),
  ],
  figure: BriefFigure.counting,
  handbook: 'Handbook p. 64',
);

const binomialBrief = BriefSection(
  title: 'Three factors, every time',
  body:
      'Use it when there is a fixed number of independent trials and each one '
      'either works or does not. The formula is always the same three pieces '
      'multiplied: how many ways the successes could be arranged, the '
      'successes themselves, and the failures. The count in front is a '
      'COMBINATION, because three failures out of ten is three failures '
      'whichever three they were. Two cheap checks: the exponents add up to n, '
      'and whichever outcome you call the success has to be the one x counts.',
  formulas: [
    ('The distribution', r'P(X = x) = C(n, x)\,p^x(1-p)^{n-x}'),
    ('Variance', r'\sigma^2 = npq \quad \text{where } q = 1 - p'),
  ],
  figure: BriefFigure.binomial,
  handbook: 'Handbook p. 66',
);

const normalTableBrief = BriefSection(
  title: 'Which area the table gives you',
  body:
      'The z-score turns any normal variable into the one the handbook has a '
      'table for. Reading the table is then the whole job, and it has three '
      'columns: F is everything left of z, R is everything right of it, and W '
      'is the band between minus z and plus z. The table only runs on positive '
      'z, so an area on the left of a negative cut comes from the flip. Before '
      'any of that, decide which piece of the picture the sentence asked for: '
      'the fail rate and the pass rate come off the same curve and the same '
      'line.',
  formulas: [
    ('Z-score', r'z = \frac{x - \mu}{\sigma}'),
    ('The flip', r'F(-z) = 1 - F(z)'),
    ('The other tail', r'R(z) = 1 - F(z)'),
  ],
  figure: BriefFigure.normalTable,
  handbook: 'Handbook p. 67',
);

const expectedValueBrief = BriefSection(
  title: 'A balance point, not a favorite',
  body:
      'An expected value is a weighted average where the weights are the '
      'probabilities. Picture the outcomes loaded onto a beam with those '
      'weights and it is the point where the beam sits level. That picture '
      'settles both of the usual mistakes at once: the most likely outcome is '
      'the tallest block and not the balance point, and the plain average of '
      'the outcomes throws the weights away. It also explains why the answer '
      'is often a value that can never actually occur.',
  formulas: [
    ('Expected value', r'E(X) = \sum_{k=1}^{n} x_k \cdot P(x_k)'),
    (
      'So',
      r'120(0.25) + 80(0.50) + 20(0.25) = 75',
    ),
  ],
  figure: BriefFigure.expectedValue,
  handbook: 'Handbook p. 65',
);

const varianceShortcutBrief = BriefSection(
  title: 'The mean of the squares, less the square of the mean',
  body:
      'Two columns of scratch work and one subtraction. Total x times P of x '
      'to get the mean, total x squared times P of x to get the mean of the '
      'squares, then subtract the SQUARE of the first from the second. The '
      'order is the whole trap: E of X squared and E of X, squared, are '
      'written almost the same and are different numbers, and taking them the '
      'wrong way round gives a negative variance, which cannot happen.',
  formulas: [
    ('Variance', r'\text{Var}(X) = E(X^2) - [E(X)]^2'),
    ('The two columns', r'E(X) = \sum x P(x), \quad E(X^2) = \sum x^2 P(x)'),
    ('So', r'8.10 - (2.70)^2 = 8.10 - 7.29 = 0.81'),
  ],
  figure: BriefFigure.varianceShortcut,
  handbook: 'Handbook p. 65',
);

const combiningBrief = BriefSection(
  title: 'Variances add, spreads do not',
  body:
      'Means add straight, and they add whether or not the variables are '
      'independent. Variances add only when they are independent, and any '
      'coefficient gets SQUARED on the way in. Standard deviations never add '
      'at all: square them, add, and take the root at the end. Two independent '
      'spreads combine the way two perpendicular legs do, so the total is the '
      'hypotenuse, and a hypotenuse is always shorter than going round the '
      'two sides.',
  formulas: [
    ('Means', r'E(a_1X_1 + a_2X_2) = a_1E(X_1) + a_2E(X_2)'),
    ('Variances', r'\text{Var}(a_1X_1 + a_2X_2) = a_1^2\sigma_1^2 + a_2^2\sigma_2^2'),
    ('So', r'\sigma_T = \sqrt{3^2 + 8^2} = \sqrt{73} = 8.54'),
  ],
  figure: BriefFigure.combining,
  handbook: 'Handbook p. 65',
);

const marginOfErrorBrief = BriefSection(
  title: 'What sets the width',
  body:
      'An interval is a sample mean with a margin on either side, and the '
      'margin is the multiplier times sigma over the ROOT of n. The root is '
      'the part that gets dropped, and it is the part that decides everything: '
      'divide by n instead and the interval collapses to a sliver that claims '
      'a precision the samples cannot buy. The multiplier comes from the '
      'confidence level, and the handbook has all three.',
  formulas: [
    (
      'Sigma known',
      r'\bar{x} - z_{\alpha/2}\frac{\sigma}{\sqrt{n}} \le \mu \le '
          r'\bar{x} + z_{\alpha/2}\frac{\sigma}{\sqrt{n}}',
    ),
    ('The three multipliers', r'90\% : 1.645 \quad 95\% : 1.960 \quad 99\% : 2.576'),
    ('So', r'42 \pm 1.960\frac{5}{\sqrt{25}} = 42 \pm 1.96'),
  ],
  figure: BriefFigure.marginOfError,
  handbook: 'Handbook p. 74',
);

const zOrTBrief = BriefSection(
  title: 'Sigma or s, and which way the width moves',
  body:
      'If the problem hands you sigma, the population spread, use z. If it '
      'hands you s, computed from the sample, use t with n minus one degrees '
      'of freedom. The t interval is always the wider one at the same '
      'confidence, because the spread is now a guess as well and the interval '
      'pays for it. Three things move the width and the sample mean is not one '
      'of them: the confidence level, sigma, and how many samples you took.',
  formulas: [
    (
      'Sigma unknown',
      r'\bar{x} \pm t_{\alpha/2,\,n-1}\frac{s}{\sqrt{n}}, \quad v = n - 1',
    ),
    ('Ten samples, 95%', r'z = 1.960 \;\Rightarrow\; t_{0.025,\,9} = 2.262'),
  ],
  figure: BriefFigure.zOrT,
  handbook: 'Handbook p. 74',
);

const sampleSizeBrief = BriefSection(
  title: 'Working backwards to n',
  body:
      'When the margin is fixed before the data is collected, rearrange for n. '
      'The whole ratio gets SQUARED, which is where both of the usual mistakes '
      'live: stopping before the square gives a number about eight when the '
      'answer is sixty two, and the square is also why halving the margin '
      'costs four times the samples. Then round UP, always. A sample size that '
      'misses the specification is not a sample size, and there is no such '
      'thing as most of a test.',
  formulas: [
    ('Required n', r'n = \left(\frac{z_{\alpha/2} \cdot \sigma}{e}\right)^2'),
    ('So', r'\left(\frac{1.960 \times 800}{200}\right)^2 = 7.84^2 = 61.47'),
    ('Which means', r'n = 62'),
  ],
  figure: BriefFigure.sampleSize,
  handbook: 'Handbook p. 75',
);

const hypothesesBrief = BriefSection(
  title: 'What the claim sets up',
  body:
      'The null is the status quo and it is what the test assumes until the '
      'data makes it uncomfortable. The alternative is what somebody is trying '
      'to show. A directional word, exceeds, reduces, falls short, puts the '
      'whole of alpha in ONE tail. A claim with no direction in it splits alpha '
      'between two, which is a different row of the table and a bigger critical '
      'value. Rejecting a true null is a Type I error and alpha is its chance; '
      'missing a false one is Type II.',
  formulas: [
    ('One-tailed', r'H_1: \mu > \mu_0 \quad \text{or} \quad H_1: \mu < \mu_0'),
    ('Two-tailed', r'H_1: \mu \neq \mu_0 \;\Rightarrow\; \tfrac{\alpha}{2}'
        r'\text{ in each tail}'),
  ],
  figure: BriefFigure.hypotheses,
  handbook: 'Handbook p. 72',
);

const decisionRuleBrief = BriefSection(
  title: 'Bigger means reject',
  body:
      'Three different tests in this topic and one decision rule between them: '
      'if the statistic is bigger than the critical value, reject. For a '
      'two-tailed test that comparison is on SIZE, so a statistic of minus 2.9 '
      'against a critical value of 2.131 rejects. And failing to reject is '
      'never a finding. It says the data did not catch the null out, not that '
      'the null is true, and an answer that says the mean equals the '
      'hypothesised value is wrong however right the decision beside it looks.',
  formulas: [
    ('Z-test', r'z = \frac{\bar{x} - \mu_0}{\sigma / \sqrt{n}}'),
    ('t-test', r't = \frac{\bar{x} - \mu_0}{s / \sqrt{n}}, \quad v = n - 1'),
    ('The rule', r'|\text{statistic}| > \text{critical} \;\Rightarrow\; '
        r'\text{reject } H_0'),
  ],
  figure: BriefFigure.decisionRule,
  handbook: 'Handbook p. 73',
);

const goodnessOfFitBrief = BriefSection(
  title: 'Every cell pays its own way',
  body:
      'Chi-square asks whether counts match a model. Work out what the model '
      'expects in each category, then add up the gap SQUARED divided by that '
      'expectation. The division is the whole point and it is the step the '
      'exam watches for: a gap of ten where a hundred was expected is a small '
      'surprise, and a gap of eight where twenty was expected is a large one. '
      'Degrees of freedom are the number of categories less one, and bigger '
      'means a worse fit.',
  formulas: [
    ('Chi-square', r'\chi^2 = \sum_{i=1}^{k} \frac{(O_i - E_i)^2}{E_i}'),
    ('Degrees of freedom', r'v = k - 1'),
    ('So', r'\frac{(60-50)^2}{50} = 2.0 \quad \text{but} \quad '
        r'\frac{(28-20)^2}{20} = 3.2'),
  ],
  figure: BriefFigure.goodnessOfFit,
  handbook: 'Handbook p. 75',
);

const publicFirstBrief = BriefSection(
  title: 'The public comes first',
  body:
      'Ten rules sit in Section A and one of them outranks everything else in '
      'the book: your first responsibility is the health, safety and welfare '
      'of the public. It beats the client, the schedule and your employer. '
      'From there the tree is short. Are you being asked to seal something '
      'that does not meet code? Refuse. Has your judgment been overruled and '
      'is the public in danger? Tell your employer and then the authority. Has '
      'another licensee broken the rules and nobody has fixed it? Tell the '
      'board. And if none of those is true, a disagreement is only a '
      'disagreement.',
  formulas: [
    ('A.1', r'\text{Safeguard the health, safety and welfare of the public.}'),
    ('A.2', r'\text{Seal only what meets accepted standards.}'),
    ('A.3', r'\text{If overruled and the public is endangered, notify.}'),
    ('A.8', r'\text{Report a licensee who is violating the rules.}'),
  ],
  figure: BriefFigure.publicFirst,
  handbook: 'Handbook pp. 4-5, Model Rules 240.15',
);

const escalationBrief = BriefSection(
  title: 'Up the chain, one rung at a time',
  body:
      'Almost every ethics scenario is about ORDER rather than about caring. '
      'Start with the person closest to the problem, who may simply not have '
      'seen it. Then the firm, which has both the standing and the duty to '
      'correct its own work. Then the authority or the board, when the rungs '
      'below have been tried and nothing has changed. Skipping a rung turns a '
      'correctable error into an argument about you. The one exception is '
      'imminent danger: when people are about to be hurt, you stop the work '
      'first and explain afterwards.',
  formulas: [
    ('The ladder', r'\text{colleague} \to \text{firm} \to \text{board}'),
    ('Overruled', r'\text{in writing} \to \text{employer} \to \text{authority}'),
    ('Imminent danger', r'\text{stop the work, then the chain}'),
  ],
  figure: BriefFigure.escalation,
  handbook: 'Handbook pp. 4-5, Model Rules A.3, A.8',
);

const proportionBrief = BriefSection(
  title: 'The right amount, not the most',
  body:
      'The rules ask for a specific amount of action, and there are two ways '
      'to miss it. Under-doing it looks like meaning well: evaluating the bids '
      'objectively without saying anything, or sealing the drawing and writing '
      'the deviation in the file. Over-doing it looks like conviction: '
      'resigning from the committee, or calling the client before the firm has '
      'heard about it. On a conflict of interest the answer is almost always '
      'the same size, disclose it and step out of that decision, and nothing '
      'larger is being asked for.',
  formulas: [
    ('Too little', r'\text{Meaning well, and saying nothing.}'),
    ('The rule', r'\text{Disclose, then recuse from that decision.}'),
    ('Too much', r'\text{Resign from the body altogether.}'),
  ],
  figure: BriefFigure.proportion,
  handbook: 'Handbook p. 5, Model Rules B.6, B.8',
);

const competenceBrief = BriefSection(
  title: 'Your field, and your charge',
  body:
      'Take on work you are qualified for by education or experience in the '
      'SPECIFIC technical field, not the one next door. A seal needs two '
      'things at once: the work has to be in your field, and it has to have '
      'been prepared under your responsible charge, which means direct control '
      'and personal supervision. Reading somebody else\'s calculations '
      'carefully is not responsible charge, and a colleague reviewing your '
      'work does not make you competent. Coordinating a whole project is fine, '
      'as long as each technical segment carries the seal of whoever prepared '
      'it.',
  formulas: [
    ('B.1', r'\text{Only accept work you are qualified for.}'),
    ('B.2', r'\text{Seal only your field, under your responsible charge.}'),
    ('B.3', r'\text{You may coordinate, if each segment is sealed by its own.}'),
  ],
  figure: BriefFigure.competence,
  handbook: 'Handbook p. 5, Model Rules B.1 to B.3',
);

const consentBrief = BriefSection(
  title: 'Everyone with an interest, in writing',
  body:
      'A conflict of interest is not fatal and it is not free. Disclose it, '
      'and where more than one party is paying you on the same subject matter, '
      'get every one of them to agree in writing. Silence is not an option '
      'because the scopes look different, and refusing outright is more than '
      'the rules ask. What consent cannot repair: a gratuity from somebody '
      'bidding on your work, and taking work from a public body you sit on. '
      'Confidential facts belong to the client whose money found them, and '
      'only they can release them.',
  formulas: [
    ('B.4', r'\text{Do not reveal client facts without their consent.}'),
    ('B.6', r'\text{Disclose every conflict, real or apparent.}'),
    ('B.7', r'\text{Two payers, one subject: written consent from all.}'),
    ('B.5 and B.8', r'\text{No gratuities. No work from a body you sit on.}'),
  ],
  figure: BriefFigure.consent,
  handbook: 'Handbook p. 5, Model Rules B.4 to B.8',
);

const claimsBrief = BriefSection(
  title: 'What you may say you did',
  body:
      'Do not misrepresent or exaggerate your responsibility on past work, and '
      'that applies hardest to anything written to win the next job. The rule '
      'is not aimed at outright lies. It is aimed at sentences that are true '
      'if read slowly and flattering if read quickly: managing a bridge is not '
      'designing it, one system is not the whole plant, and a peer review is '
      'not the design. Say what you did, say who did the rest, and the claim '
      'survives the follow-up question.',
  formulas: [
    ('C.1', r'\text{Do not exaggerate your role in prior assignments.}'),
    ('C.3', r"\text{Do not damage another licensee's reputation.}"),
    ('C.4', r'\text{Tell a licensee directly about a material error.}'),
  ],
  figure: BriefFigure.claims,
  handbook: 'Handbook p. 5, Model Rules C.1 to C.4',
);

const standingBrief = BriefSection(
  title: 'Certified, and licensed',
  body:
      'Two words that sound alike and are not. An Engineer Intern has passed '
      'the FE and been CERTIFIED by the board, which entitles them to the '
      'title and to sit the second exam once the experience is behind them. A '
      'Professional Engineer has passed both exams and been LICENSED, and a '
      'licence is what a seal is an act of. Nothing lends it: not competence, '
      'not a licensed colleague reading the drawing afterwards, and not '
      'writing your intern status beside your name. A great deal of real '
      'engineering work, meanwhile, needs no licence at all.',
  formulas: [
    ('Engineer Intern', r'\text{Passed the FE. Certified by the board.}'),
    ('Professional Engineer', r'\text{Passed both. Licensed by the board.}'),
    ('The seal', r'\text{Only a licensed PE may sign and seal.}'),
  ],
  figure: BriefFigure.standing,
  handbook: 'Handbook p. 6, Model Law 110.20',
);

const exemptionBrief = BriefSection(
  title: 'When unlicensed work is allowed',
  body:
      'The exemption clause is what lets a firm employ anybody at all. An '
      'unlicensed employee may prepare calculations, produce drawings and '
      'check documents against one another, on two conditions that both have '
      'to hold: a licensed engineer is in responsible charge of the work, and '
      'the final engineering decisions are not the employee\'s. Responsible '
      'charge means direct control and personal supervision, so telling '
      'somebody afterwards is not it, and neither is being in the same firm as '
      'somebody licensed who is not directing you.',
  formulas: [
    ('170.20 C', r'\text{A subordinate under the responsible charge of a PE}'),
    ('And', r'\text{no final engineering designs or decisions}'),
    ('Responsible charge', r'\text{direct control and personal supervision}'),
  ],
  figure: BriefFigure.exemption,
  handbook: 'Handbook p. 11, Model Law 170.20 C',
);

const holdingOutBrief = BriefSection(
  title: 'The work, or the title',
  body:
      'Two separate offenses. The first is doing the work: any service that '
      'takes engineering education and judgment and reaches the health, safety '
      'or welfare of the public is the practice of engineering, and the Model '
      'Law has never cared what it is delivered on. Drawings, a spreadsheet, a '
      'book of tables, an app; the medium is not part of the test and pushing '
      'the last tap onto the user does not move the judgment out of the '
      'software. The second is the title: representing yourself as a '
      'Professional Engineer when you are not, by sign, card, letterhead or '
      'website, is a violation even if you never do a day of engineering.',
  formulas: [
    ('110.20 A.3', r'\text{Work needing engineering judgment, reaching the public.}'),
    ('A.3(a)', r'\text{Practices, or holds out as able to practice.}'),
    ('A.3(b)', r'\text{Represents themselves as a PE by any means.}'),
  ],
  figure: BriefFigure.holdingOut,
  handbook: 'Handbook p. 6, Model Law 110.20 A.3',
);

const ladderBrief = BriefSection(
  title: 'The ladder, and the years on it',
  body:
      'Five general requirements for anybody: good character, the education, '
      'the experience, the examinations, and five references acceptable to the '
      'board. The path runs in order. An accredited degree and the FE make you '
      'an Engineer Intern; the PE exam and the years make you a Professional '
      'Engineer. The years depend on the degree, and the degree that bought '
      'the education requirement cannot be spent again on the experience.',
  formulas: [
    ("Bachelor's", r'\text{4 years of progressive experience}'),
    ("Master's", r'\text{3 years}'),
    ('Doctorate, with the FE', r'\text{2 years}'),
    ('Comity', r'\text{another jurisdiction, if the credentials meet ours}'),
  ],
  figure: BriefFigure.ladder,
  handbook: 'Handbook pp. 8-9, Model Law 130.10',
);

const disciplineBrief = BriefSection(
  title: 'What the board can act on',
  body:
      'For a licensee: fraud in obtaining the licence, negligence or '
      'incompetence, practising outside your competence, failing to comply '
      'with a board rule, and conviction of ANY felony, whether or not it '
      'touches engineering. Misdemeanours are the opposite shape and only '
      'count when they involve dishonesty or the practice itself, which is why '
      'a falsified timesheet is grounds and a speeding ticket is not. A clean '
      'record affects what the board does about it, never whether it may act.',
  formulas: [
    ('Any felony', r'\text{whether or not related to the practice}'),
    ('A misdemeanour', r'\text{only if dishonesty, or the practice}'),
    ('Also', r'\text{fraud, negligence, incompetence, board rules}'),
  ],
  figure: BriefFigure.discipline,
  handbook: 'Handbook p. 9, Model Law 150.10',
);

const sectionsBrief = BriefSection(
  title: 'Licensed, or not, first',
  body:
      'Ask whether they hold a licence before anything else, because the two '
      'lists are different. A licensee can be suspended, revoked, fined or '
      'reprimanded. Somebody who is not licensed is fined instead, for '
      'practising, for using the title, for presenting a seal that is not '
      'theirs, and for using the word engineering in a business name without '
      'board authorisation; each day of continued violation is a separate '
      'offense. Revoked, suspended and expired all mean the same thing here, '
      'which is that there is no licence.',
  formulas: [
    ('150.10', r'\text{A licensee: suspend, revoke, fine, reprimand}'),
    ('150.30', r'\text{Not licensed: fined, each day counted again}'),
    ('And', r'\text{revoked or expired} \;\Rightarrow\; \text{not licensed}'),
  ],
  figure: BriefFigure.sections,
  handbook: 'Handbook pp. 9-10, Model Law 150.10 and 150.30',
);

const formationBrief = BriefSection(
  title: 'When it becomes a contract',
  body:
      'Five elements, and none of them is a notary. There has to be an OFFER, '
      'an ACCEPTANCE of that offer as it stands, CONSIDERATION moving both '
      'ways, parties with the CAPACITY to agree, and a LAWFUL purpose. Two '
      'things follow that catch people out. A counter-offer is a rejection, so '
      'the number on the table before it is gone and cannot be taken later. '
      'And an invitation to bid is not an offer: the bidder makes the offer '
      'and the award accepts it, which is why the firms that lost have nothing '
      'to enforce.',
  formulas: [
    ('The five', r'\text{offer, acceptance, consideration, capacity, legality}'),
    ('Not required', r'\text{notarisation, or a witness}'),
    ('A counter-offer', r'\text{ends the offer it answered}'),
  ],
  figure: BriefFigure.formation,
  handbook: 'Model Rules, contracts',
);

const riskBrief = BriefSection(
  title: 'Who carries the overrun',
  body:
      'The pricing decides the risk. Lump sum fixes the number, so the '
      'contractor absorbs anything above it and the owner buys certainty. Cost '
      'plus a fee and time and materials reimburse what the work actually '
      'cost, so the owner carries it and an estimate was never a promise. Unit '
      'price is not an overrun at all: it fixes a rate, and the owner pays for '
      'every yard that goes in. A guaranteed maximum draws a line and swaps '
      'the parties at it. And changing the scope hands the risk back whatever '
      'was signed.',
  formulas: [
    ('Lump sum', r'\text{the contractor}'),
    ('Cost plus, and T and M', r'\text{the owner}'),
    ('Unit price', r'\text{the owner, per unit actually placed}'),
    ('Above a GMP', r'\text{the manager at risk}'),
  ],
  figure: BriefFigure.risk,
  handbook: 'Model Rules, contract types',
);

const deliveryBrief = BriefSection(
  title: 'Count the lines out of the owner',
  body:
      'A delivery method is a contract shape wearing an acronym. Design, bid, '
      'build gives the owner two agreements, one with the designer and one '
      'with the builder, and nothing between them; the design is finished '
      'before anybody prices it. Design-build gives the owner ONE agreement, '
      'and the designer is a subcontractor the owner cannot write to. A '
      'manager at risk is two agreements again, with the builder advising '
      'through design and then committing to a guaranteed maximum.',
  formulas: [
    ('Design, bid, build', r'\text{two contracts, design finished first}'),
    ('Design-build', r'\text{one contract, everybody else beneath it}'),
    ('CM at risk', r'\text{two contracts, and a guaranteed maximum}'),
  ],
  figure: BriefFigure.delivery,
  handbook: 'Model Rules, project delivery',
);

const standardOfCareBrief = BriefSection(
  title: 'Not perfection, and not intent',
  body:
      'An engineer is measured against the degree of skill and diligence a '
      'reasonably competent engineer would exercise in similar circumstances. '
      'That cuts both ways. A design that later proves imperfect is not a '
      'breach if a competent peer would have produced it, and where competent '
      'engineers could reasonably differ, choosing one of the options is not '
      'negligence. It also does not need intent: forgetting a required check '
      'is negligence, and knowing the truth and writing the opposite is '
      'something worse that the word does not cover.',
  formulas: [
    ('The measure', r'\text{what a reasonably competent peer would do}'),
    ('Not', r'\text{a guarantee of a perfect result}'),
    ('Not', r'\text{intent, which is a different and graver claim}'),
  ],
  figure: BriefFigure.standardOfCare,
  handbook: 'Model Rules, liability',
);

const negligenceBrief = BriefSection(
  title: 'Four elements, all four',
  body:
      'A claim needs a DUTY owed to this plaintiff, a BREACH of it, CAUSATION '
      'linking the breach to the harm, and DAMAGES that can be measured. '
      'Intent is not on the list and gets added to it. Causation is on the '
      'list and gets dropped: a genuine breach beside a genuine loss that had '
      'nothing to do with each other is still not negligence, and it is where '
      'most claims against engineers actually fail.',
  formulas: [
    ('The four', r'\text{duty, breach, causation, damages}'),
    ('Not one of them', r'\text{intent}'),
    ('No damages', r'\text{no claim, however plain the breach}'),
  ],
  figure: BriefFigure.negligence,
  handbook: 'Model Rules, negligence',
);

const clocksBrief = BriefSection(
  title: 'Two clocks, two starting guns',
  body:
      'A statute of LIMITATIONS runs from when the harm happened or was '
      'discovered, so it waits for the injury. A statute of REPOSE runs from a '
      'fixed event, usually substantial completion, and nothing that happens '
      'afterwards extends it. That is the whole difference and it has a sharp '
      'consequence: repose can bar a claim before the harm has appeared, '
      'because the window is measured from the day the job finished and not '
      'from the day anything went wrong. A claim has to land inside both.',
  formulas: [
    ('Limitations', r'\text{from the harm, or from its discovery}'),
    ('Repose', r'\text{from substantial completion, absolutely}'),
    ('So', r'\text{repose can shut before the injury exists}'),
  ],
  figure: BriefFigure.clocks,
  handbook: 'Model Rules, time limits',
);

const propertyBrief = BriefSection(
  title: 'Four protections, one question',
  body:
      'Disclosure decides most of it. A PATENT is a bargain: publish the '
      'invention and get twenty years from the filing date, and there are '
      'three kinds, for inventions, for the ornamental look of a made article, '
      'and for a plant variety reproduced without seed. A TRADE SECRET is the '
      'opposite bargain, protecting whatever nobody else knows for as long as '
      'that stays true. A TRADEMARK protects the name and not the goods, so '
      'anybody may make the same thing under a different mark. A COPYRIGHT '
      'protects the writing and not the idea inside it.',
  formulas: [
    ('Patent', r'\text{published, and 20 years from filing}'),
    ('Trade secret', r'\text{unpublished, and lasts while it holds}'),
    ('Trademark', r'\text{the name, not the goods}'),
    ('Copyright', r'\text{the expression, not the idea}'),
  ],
  figure: BriefFigure.property,
  handbook: 'Handbook pp. 12-13',
);

const portfolioBrief = BriefSection(
  title: 'They do not compete',
  body:
      'One project regularly needs several at once, because they attach to '
      'different things. An invention, the name it is sold under, the paper '
      'describing it and the process left out of that paper are four separate '
      'assets and take four separate protections. A firm that patents the '
      'invention and stops has protected one of the four. The one pairing that '
      'cannot happen is a patent and a trade secret on the SAME thing, because '
      'filing publishes it and a secret only exists while it is not published.',
  formulas: [
    ('The invention', r'\text{a patent}'),
    ('The name', r'\text{a trademark}'),
    ('The paper', r'\text{a copyright}'),
    ('What was left out of it', r'\text{a trade secret}'),
  ],
  figure: BriefFigure.portfolio,
  handbook: 'Handbook pp. 12-13',
);

const lifeCycleBrief = BriefSection(
  title: 'Add the whole bar',
  body:
      'A life-cycle assessment adds what a thing costs across its whole life: '
      'building it, running it, keeping it, and taking it away at the end. The '
      'option that is cheapest to build is regularly not the cheapest to own, '
      'and the segment that decides it is often the one nobody prices, either '
      'because it arrives as maintenance years later or because it arrives as '
      'demolition after everybody involved has retired. It is a method rather '
      'than a verdict: sometimes the cheap option really is the cheap option, '
      'and the assessment is what tells you which case you are in.',
  formulas: [
    ('The whole life', r'\text{build} + \text{operate} + \text{maintain} + '
        r'\text{take away}'),
    ('Not', r'\text{the first segment on its own}'),
    ('The triple bottom line', r'\text{economic, environmental, social}'),
  ],
  figure: BriefFigure.lifeCycle,
  handbook: 'Handbook pp. 12-13',
);

const factorsBrief = BriefSection(
  title: 'Six factors, one question',
  body:
      'Every one of them answers the same question: what have you got, and '
      'what do you want instead. Money comes in three forms, a single amount '
      'now or later, and an equal series, and the factor is named for the pair '
      'it moves between. The two that get swapped are the sinking fund and '
      'capital recovery. Both connect a series to a single amount, and what '
      'separates them is whether the known amount is sitting in your hand '
      'today or waiting at the end.',
  formulas: [
    ('Carried forward', r'F = P(1+i)^n'),
    ('Brought back', r'P = F(1+i)^{-n}'),
    ('Sinking fund', r'A = F\,\frac{i}{(1+i)^n - 1}'),
    ('Capital recovery', r'A = P\,\frac{i(1+i)^n}{(1+i)^n - 1}'),
  ],
  figure: BriefFigure.factors,
  handbook: 'Handbook p. 229, tables pp. 232-236',
);

const ratesBrief = BriefSection(
  title: 'Three numbers, one label',
  body:
      'Twelve percent compounded monthly is three different numbers. The '
      'PERIODIC rate is one percent, the quoted rate divided by the periods, '
      'and it is the one that goes beside an n counted in the same units. The '
      'NOMINAL rate is the twelve on the paperwork, and it answers almost '
      'nothing. The EFFECTIVE rate is 12.68 percent, what a year actually '
      'costs once the compounding has happened, and it is the only one worth '
      'comparing between offers with different compounding. Compounded '
      'annually all three collapse into the same number.',
  formulas: [
    ('Periodic', r'i = \frac{r}{m}'),
    ('Effective', r'i_e = \left(1 + \frac{r}{m}\right)^m - 1'),
    ('So', r'12\% \text{ monthly} \;\Rightarrow\; 1\%,\ 12\%,\ 12.68\%'),
  ],
  figure: BriefFigure.rates,
  handbook: 'Handbook p. 229',
);

const piecesBrief = BriefSection(
  title: 'Count the pieces first',
  body:
      'A diagram is often more than one cash flow drawn on top of another, and '
      'each piece takes its own factor. A series that grows by the same step '
      'every period is a FLAT series plus a TRIANGLE, so it takes two, and '
      'doing the flat part and stopping is the commonest way to lose the '
      'question. Anything landing on a single date takes a third. Add the '
      'pieces up at the end; do not look for one factor that covers a picture '
      'made of several.',
  formulas: [
    ('A single amount', r'P = F(1+i)^{-n}'),
    ('The flat part', r'P = A\,\frac{(1+i)^n - 1}{i(1+i)^n}'),
    ('The growing part', r'P = G\,(P/G, i, n)'),
    ('Together', r'P = A(P/A) + G(P/G)'),
  ],
  figure: BriefFigure.pieces,
  handbook: 'Handbook p. 229',
);

const annualCostBrief = BriefSection(
  title: 'What owning it costs a year',
  body:
      'Spread the purchase across the life with capital recovery, add the '
      'annual running costs as they are, bring any one-off costs inside the '
      'life back and spread them too, and SUBTRACT the salvage. That last sign '
      'is the one the exam watches: money coming back at the end reduces what '
      'the thing costs you, and it sits at the bottom of the problem next to a '
      'column of costs waiting to be added by mistake. Anything already spent '
      'before the decision stays out entirely.',
  formulas: [
    ('Annual worth', r'AW = -P(A/P) - A_{\text{op}} + S(A/F)'),
    ('Not', r'\text{dividing the purchase by } n'),
    ('A sunk cost', r'\text{is in neither alternative}'),
  ],
  figure: BriefFigure.annualCost,
  handbook: 'Handbook p. 229',
);

const studyPeriodBrief = BriefSection(
  title: 'Over the same amount of time',
  body:
      'A present worth prices a PERIOD, so two present worths only compare if '
      'they cover the same one. Equal lives need nothing. Unequal lives have '
      'to be repeated until they end together, at the least common multiple, '
      'or the shorter option looks cheap for the simple reason that it is '
      'buying less service. Annual worth avoids the whole business: it is '
      'dollars per year, a rate, and two rates compare directly however long '
      'each alternative lasts.',
  formulas: [
    ('Equal lives', r'\text{compare over the life}'),
    ('Unequal lives, by PW', r'\text{repeat to the least common multiple}'),
    ('Unequal lives, by AW', r'\text{nothing to do}'),
  ],
  figure: BriefFigure.studyPeriod,
  handbook: 'Handbook p. 229',
);

const methodsAgreeBrief = BriefSection(
  title: 'One comparison, three clocks',
  body:
      'Present worth, future worth and annual worth convert the same cash '
      'flows to time zero, to the end, and to a rate per year. They are the '
      'same comparison and for the same alternatives, over the same period, at '
      'the same rate they cannot rank two options differently. If two methods '
      'disagree, one of those three was not the same: usually the periods, '
      'because unequal lives were compared as they stand, and sometimes the '
      'rate. If all three really were identical, the disagreement is a slip in '
      'the working.',
  formulas: [
    ('Same ranking', r'PW,\ FW,\ AW \text{ agree}'),
    ('Unless', r'\text{the periods differ}'),
    ('Or', r'\text{the rate differs}'),
  ],
  figure: BriefFigure.methodsAgree,
  handbook: 'Handbook p. 229',
);

const costTypesBrief = BriefSection(
  title: 'Sort the costs first',
  body:
      'FIXED costs do not move with the volume, so they are where a cost line '
      'starts. VARIABLE costs scale with it, so they are how steeply it rises. '
      'A SUNK cost is already spent and unrecoverable whatever is decided next, '
      'and it stays out of the comparison entirely: belonging to one option '
      'physically does not put it there financially, and depreciating it does '
      'not either. An OPPORTUNITY cost is what choosing this gives up and '
      'never appears on an invoice. A MARGINAL cost is the next unit, not the '
      'average of them all.',
  formulas: [
    ('Total cost', r'TC = FC + VC \cdot Q'),
    ('A sunk cost', r'\text{is in neither alternative}'),
    ('An opportunity cost', r'\text{is in, invoice or not}'),
  ],
  figure: BriefFigure.costTypes,
  handbook: 'Handbook pp. 230-231',
);

const breakEvenBrief = BriefSection(
  title: 'Two lines and where they cross',
  body:
      'Set the two total costs equal and solve for the volume. The option with '
      'the cheaper START wins below that volume and the one with the cheaper '
      'RATE wins above it, which is the whole of the topic. Two things go '
      'wrong: comparing the per-unit rates on their own, which ignores where '
      'each line begins, and subtracting the variable costs the wrong way '
      'round, which produces a negative volume. And when one option starts '
      'higher AND rises faster the lines never cross, so there is no '
      'break-even volume to find.',
  formulas: [
    ('Break even', r'FC_1 + VC_1 Q = FC_2 + VC_2 Q'),
    ('So', r'Q = \frac{FC_1 - FC_2}{VC_2 - VC_1}'),
    ('Below it', r'\text{the cheaper start wins}'),
  ],
  figure: BriefFigure.breakEven,
  handbook: 'Handbook pp. 230-231',
);

const paybackBrief = BriefSection(
  title: 'Only what is left over pays it back',
  body:
      'A simple payback is the investment divided by the NET annual saving: '
      'everything the change brings in, less everything new it costs to run. '
      'The exam offers the gross saving because it is the larger number and '
      'the one printed first, and using it makes a seven year payback look '
      'like five. Only amounts that repeat every year belong underneath; a '
      'one-off grant comes off the investment instead. And if the new annual '
      'cost is larger than the saving there is no payback period at all.',
  formulas: [
    ('Simple payback', r'n = \frac{\text{investment}}{\text{net annual saving}}'),
    ('Net saving', r'\text{savings} - \text{new annual costs}'),
    ('So', r'\frac{1{,}400{,}000}{280{,}000 - 80{,}000} = 7 \text{ years}'),
  ],
  figure: BriefFigure.payback,
  handbook: 'Handbook pp. 230-231',
);

const ratioBrief = BriefSection(
  title: 'Three places a number can land',
  body:
      'A benefit-cost ratio is what the project does for the public over what '
      'it costs the government. Benefits go on top, and so do disbenefits, '
      'except they come off rather than on. Costs go underneath, and that '
      'includes every year of operating and maintaining the thing, not only '
      'the building of it. Harm to the public is the one people misfile: '
      'moving it into the denominator is a different division and gives a '
      'different answer. A project stands up when the ratio reaches one.',
  formulas: [
    ('Plain', r'B/C = \frac{B}{C}'),
    ('With disbenefits', r'B/C = \frac{B - D}{C}'),
    ('Justified when', r'B/C \geq 1'),
  ],
  figure: BriefFigure.bcRatio,
  handbook: 'Handbook p. 231',
);

const incrementalBrief = BriefSection(
  title: 'Is the step up worth it',
  body:
      'With mutually exclusive alternatives you do not pick the highest '
      'benefit-cost ratio. That number answers a question nobody asked, which '
      'is how much each dollar returns, and it is blind to how many dollars '
      'are on offer. Throw out anything that cannot reach one on its own, put '
      'the survivors in order of cost, and ask of each step up whether the '
      'extra benefit covers the extra cost. Keep stepping while it does. The '
      'comparison is always against the last one that survived, not the one '
      'printed above it.',
  formulas: [
    ('Each on its own', r'B/C \geq 1'),
    ('Then each step', r'\Delta B/C = \frac{B_2 - B_1}{C_2 - C_1}'),
    ('Step up when', r'\Delta B/C \geq 1'),
  ],
  figure: BriefFigure.incremental,
  handbook: 'Handbook p. 231',
);

const rollbackBrief = BriefSection(
  title: 'Work a tree backwards',
  body:
      'Squares are where you choose and circles are where you do not. Start at '
      'the endings and work back: a circle is worth its endings weighted by '
      'how likely each one is, which always lands between the cheapest and the '
      'dearest and leans toward the likely one. Then stand at the square and '
      'take the best line, lowest for costs and highest for returns. The '
      'probabilities at any one circle add to one, so a branch left unlabeled '
      'carries whatever is left over and still has to be counted.',
  formulas: [
    ('At a circle', r'EV = p_1 C_1 + p_2 C_2 + \cdots + p_n C_n'),
    ('Which sums to', r'\sum p_i = 1'),
    ('So', r'0.4(10) + 0.6(5) = 7'),
  ],
  figure: BriefFigure.rollback,
  handbook: 'Handbook p. 231',
);

const irrBrief = BriefSection(
  title: 'The rate that balances it',
  body:
      'The internal rate of return is the interest rate at which everything '
      'coming in is worth exactly what goes out, which is the same as saying '
      'net present worth is zero. Nothing else it gets confused with is a rate '
      'at all: undiscounted profit ignores time entirely, a payback period is '
      'measured in years, and a salvage value is money. Over a single period '
      'the return is just the gain over what you PUT IN, so a thousand coming '
      'back as 1,150 earns fifteen percent, not the thirteen you get by '
      'dividing by the 1,150.',
  formulas: [
    ('At the rate', r'PW_{\text{in}} - PW_{\text{out}} = 0'),
    ('One period', r'i = \frac{F - P}{P}'),
    ('So', r'\frac{1{,}150 - 1{,}000}{1{,}000} = 15\%'),
  ],
  figure: BriefFigure.internalRate,
  handbook: 'Handbook p. 229',
);

const marrBrief = BriefSection(
  title: 'Over the hurdle or not',
  body:
      'Accept a project when its return reaches the minimum the money is '
      'required to earn, and reject it when it does not. Exactly on the '
      'hurdle is an acceptance: the project breaks even in time-value terms '
      'and nothing is lost. A positive return is not the test, a near miss is '
      'not a pass, and the same project can clear one year and fail the next '
      'because the hurdle belongs to the money rather than to the project. '
      'One thing this rule does NOT do is choose between mutually exclusive '
      'alternatives: for that, take the rate of return on the DIFFERENCE '
      'between them and put that against the hurdle instead.',
  formulas: [
    ('Accept', r'IRR \geq MARR'),
    ('Reject', r'IRR < MARR'),
    ('Choosing between two', r'IRR_{\Delta} \geq MARR'),
  ],
  figure: BriefFigure.hurdle,
  handbook: 'Handbook p. 229',
);

const timingBrief = BriefSection(
  title: 'A rate is not a total',
  body:
      'A return is money per year on the money at risk, so two things move it '
      'and one thing does not. Money that comes back sooner earns a higher '
      'rate than the same money later. A smaller stake earning the same '
      'dollars is a higher rate than a larger one. And multiplying every cash '
      'flow in a project by the same number leaves the rate exactly where it '
      'was, which is why the biggest total on the page is so often the lower '
      'return.',
  formulas: [
    ('Sooner', r'\frac{1{,}200}{1{,}000} \text{ in one year} = 20\%'),
    ('Later', r'\sqrt{\frac{1{,}200}{1{,}000}} - 1 = 9.5\%'),
    ('Scaled', r'\frac{2{,}300}{2{,}000} = \frac{1{,}150}{1{,}000}'),
  ],
  figure: BriefFigure.ratePerYear,
  handbook: 'Handbook p. 229',
);

const macrsBrief = BriefSection(
  title: 'Read the table, not the name',
  body:
      'Straight line spreads the cost evenly and takes the salvage off first. '
      'MACRS does neither: it front-loads the deduction using percentages the '
      'handbook prints for you, it depreciates the FULL cost with no salvage '
      'subtraction, and it runs the book value to zero. The class name is not '
      'the number of years, because the half-year convention takes half a year '
      'at each end. Five year property is written off over six years, three '
      'year over four, seven year over eight. Find the column first, then '
      'count the rows.',
  formulas: [
    ('Straight line', r'D_j = \frac{C - S_n}{n}'),
    ('MACRS', r'D_j = d_j \times C'),
    ('So', r'0.32 \times 60{,}000 = 19{,}200'),
  ],
  figure: BriefFigure.macrs,
  handbook: 'Handbook p. 231, MACRS factors',
);

const bookValueBrief = BriefSection(
  title: 'What has not been written off',
  body:
      'Book value is the cost less EVERY year of depreciation taken so far, '
      'not less the current year alone. The number people hand in instead is '
      'the accumulated depreciation, which is the same subtraction read from '
      'the wrong end: one is what has gone, the other is what is left, and '
      'together they come to the cost. Book value is also not what the asset '
      'would fetch. Under MACRS it walks to zero on a schedule while the thing '
      'itself may still be worth real money.',
  formulas: [
    ('Book value', r'BV_j = C - \sum_{k=1}^{j} D_k'),
    ('Which means', r'BV_j + \textstyle\sum D = C'),
    ('So', r'500{,}000 - 281{,}350 = 218{,}650'),
  ],
  figure: BriefFigure.bookValue,
  handbook: 'Handbook p. 231',
);

const inflationBrief = BriefSection(
  title: 'Match the rate to the dollars',
  body:
      'Actual dollars are the money that will really change hands and they '
      'have inflation in them, so they are discounted at the combined rate. '
      'Constant dollars are stated in today\'s purchasing power with inflation '
      'stripped out, so they are discounted at the real rate. Using one on the '
      'other charges for inflation twice or not at all. And the combined rate '
      'has three terms: adding the two and stopping is close at small rates '
      'and most of a point out at large ones.',
  formulas: [
    ('Combined', r'd = i + f + i f'),
    ('Actual dollars', r'\text{discount at } d'),
    ('Constant dollars', r'\text{discount at } i'),
  ],
  figure: BriefFigure.dollarsMatch,
  handbook: 'Handbook p. 230',
);

const resolveBrief = BriefSection(
  title: 'Which component gets the cosine',
  body:
      'The cosine goes with the axis the angle is measured FROM, and nothing '
      'else decides it. An angle off the horizontal gives a horizontal '
      'component of F cos and a vertical one of F sin; an angle off the '
      'vertical swaps them. When the direction is given as geometry instead of '
      'an angle there is no trig at all: the horizontal leg over the '
      'hypotenuse, times the force. Whichever route you take, a component is '
      'always shorter than the force it came out of, so a component equal to '
      'the whole force means something was divided by the wrong number.',
  formulas: [
    ('From the horizontal', r'F_x = F\cos\theta, \; F_y = F\sin\theta'),
    ('By geometry', r'F_x = \frac{x}{R} F, \; R = \sqrt{x^2 + y^2}'),
    ('So', r'\frac{5}{13}(1{,}300) = 500'),
  ],
  figure: BriefFigure.resolve,
  handbook: 'Handbook p. 94',
);

const momentBrief = BriefSection(
  title: 'The arm is a perpendicular',
  body:
      'A moment is the force times the PERPENDICULAR distance from the point '
      'to the force\'s line of action. Draw that line first: the arm is '
      'measured to the line, not to the place the force happens to be applied, '
      'so the length of the member is almost never the answer. A vertical '
      'force has a horizontal arm and a horizontal force has a vertical one. '
      'A force whose line passes through the point makes no moment at all, '
      'however large it is. Splitting the force into components and taking '
      'each one\'s moment separately gives the same answer and is usually '
      'quicker.',
  formulas: [
    ('In general', r'M = F d_{\perp}'),
    ('In two dimensions', r'M_z = x F_y - y F_x'),
    ('A couple', r'M = F d \text{, about any point}'),
  ],
  figure: BriefFigure.moment,
  handbook: 'Handbook p. 94',
);

const senseBrief = BriefSection(
  title: 'Pick a direction and hold it',
  body:
      'Which way a force turns a body depends on which SIDE of the point it '
      'acts as well as which way it points: a downward force to the right of a '
      'pin and an upward force to the left both turn it clockwise. Choose '
      'clockwise or counterclockwise as positive at the start of a problem and '
      'do not change your mind halfway, because mixing the two is the fastest '
      'way to a wrong answer that looks reasonable. A force aimed through the '
      'point counts as zero, and two equal opposite forces on opposite sides '
      'add rather than cancel.',
  formulas: [
    ('Sense', r'M_z = x F_y - y F_x'),
    ('Positive', r'\text{counterclockwise, if you choose it so}'),
    ('Through the point', r'd_{\perp} = 0 \;\Rightarrow\; M = 0'),
  ],
  figure: BriefFigure.sense,
  handbook: 'Handbook p. 94',
);

const supportsBrief = BriefSection(
  title: 'Whatever it prevents, it supplies',
  body:
      'A free body diagram takes the thing off its supports and puts back what '
      'each support was doing. A roller stops one direction and gives one '
      'force, square to whatever it runs on: on a slope that force is not '
      'vertical, and on a wall it is horizontal. A pin stops the end going '
      'anywhere and gives two forces, but the beam can still turn on it, so '
      'there is no moment. A fixed end stops the turn as well and gives two '
      'forces and a moment. A cable is a roller that can only pull.',
  formulas: [
    ('Roller or cable', r'\text{1 unknown}'),
    ('Pin', r'\text{2 unknowns}'),
    ('Fixed', r'\text{3 unknowns}'),
  ],
  figure: BriefFigure.supports,
  handbook: 'Handbook p. 94',
);

const resultantBrief = BriefSection(
  title: 'A spread load acts at its centroid',
  body:
      'Replace a load spread along a member by one force: its size is the area '
      'of the load shape, and it acts at the centroid of that shape. Uniform '
      'puts it in the middle of the LOADED part, which is not the middle of '
      'the member unless the load covers all of it. A triangle puts it a third '
      'of the way in from the heavy end. Anything in between lands in between. '
      'Using the far end of the load as the arm is the mistake that doubles a '
      'cantilever moment.',
  formulas: [
    ('Uniform', r'W = wL \text{ at } L/2'),
    ('Triangle', r'W = \tfrac{1}{2} w L \text{ at } L/3 \text{ from the heavy end}'),
    ('So', r'3(4) = 12 \text{ kN at } 2 \text{ m}'),
  ],
  figure: BriefFigure.resultant,
  handbook: 'Handbook p. 94',
);

const zeroForceBrief = BriefSection(
  title: 'Members carrying nothing',
  body:
      'Two rules, and they are worth a minute before any calculation. Two '
      'members meeting at a joint with nothing applied to it: both are zero. '
      'Three members at such a joint with two of them in line: the odd one out '
      'is zero. Both rules need the joint UNLOADED, so a reaction or a hung '
      'load at that joint switches them off. A zero-force member is not spare. '
      'It braces the joint and it takes over the moment the loading changes.',
  formulas: [
    ('Two at an unloaded joint', r'F_1 = F_2 = 0'),
    ('Three, two collinear', r'F_{\text{odd}} = 0'),
    ('What turns it off', r'\text{any load or reaction at the joint}'),
  ],
  figure: BriefFigure.zeroForce,
  handbook: 'Handbook p. 95',
);

const senseOfForceBrief = BriefSection(
  title: 'Tension, compression, and the sign',
  body:
      'Draw every unknown member force pulling AWAY from the joint, which is '
      'assuming tension. Then the algebra tells you the truth: positive means '
      'the member really is stretched, negative means it is squashed. Answer '
      'with both parts. Four point two kilonewtons is not an answer on this '
      'exam. Four point two kilonewtons compression is. Under downward load a '
      'simply supported truss squashes its top chord and stretches its bottom '
      'chord, and a cantilever does the opposite.',
  formulas: [
    ('The assumption', r'\text{all members in tension}'),
    ('Positive', r'T > 0 \;\Rightarrow\; \text{tension}'),
    ('Negative', r'T < 0 \;\Rightarrow\; \text{compression}'),
  ],
  figure: BriefFigure.senseOfForce,
  handbook: 'Handbook p. 95',
);

const sectionBrief = BriefSection(
  title: 'Cutting straight to one member',
  body:
      'The method of joints walks the truss one pin at a time. A section skips '
      'the walk: slice right through the truss, throw one half away, and put '
      'the three equilibrium equations on what is left. The cut has to cross '
      'the member you were asked for, and it has to cross no more than three '
      'members altogether, because three equations is all a flat body gives '
      'you. It does not have to be vertical. Take moments about the point '
      'where two of the three cut members meet and the third falls out on its '
      'own.',
  formulas: [
    ('On the piece you keep', r'\sum F_x = 0, \; \sum F_y = 0, \; \sum M = 0'),
    ('The limit', r'\text{members cut} \le 3'),
    ('The shortcut', r'\sum M \text{ about where the other two meet}'),
  ],
  figure: BriefFigure.section,
  handbook: 'Handbook p. 95',
);

const deformationBrief = BriefSection(
  title: 'What makes a bar move',
  body:
      'Four things decide how far an axially loaded bar stretches, and which '
      'side of the fraction each one sits on is the whole of it. The load and '
      'the length are on top: pull harder or use a longer bar and it moves '
      'further, in direct proportion. The area and the modulus are underneath: '
      'a fatter bar or a stiffer material moves less. Stress is a different '
      'question with a shorter answer, because length does not appear in it at '
      'all, so two bars of different lengths under the same pull carry exactly '
      'the same stress and move different distances.',
  formulas: [
    ('Stress', r'\sigma = \frac{P}{A}'),
    ('Stretch', r'\delta = \frac{PL}{AE}'),
    ('Strain', r'\varepsilon = \frac{\delta}{L} = \frac{\sigma}{E}'),
  ],
  figure: BriefFigure.deformation,
  handbook: 'Handbook p. 130',
);

const unitsBrief = BriefSection(
  title: 'One set of units, all the way through',
  body:
      'Mixing meters and millimeters is named in this lesson as the commonest '
      'source of wrong answers, and the reason it is so hard to catch is that '
      'it is dimensionally perfect: the units cancel exactly as they should '
      'and the answer is a thousand times out. Checking your dimensions will '
      'not find it. Converting before you start will. Newtons, millimeters and '
      'newtons per square millimeter go together and never need converting '
      'again, and a megapascal IS a newton per square millimeter. Strain is '
      'the one quantity with no unit at all, so a strain quoted in anything is '
      'a strain someone has misread.',
  formulas: [
    ('The set that never needs converting', r'\mathrm{N},\; \mathrm{mm},\; \mathrm{N/mm^2}'),
    ('And that last one is', r'1\ \mathrm{MPa} = 1\ \mathrm{N/mm^2}'),
    ('Strain', r'\varepsilon \text{ has no unit}'),
  ],
  figure: BriefFigure.units,
  handbook: 'Handbook p. 130',
);

const thermalBrief = BriefSection(
  title: 'Stopped from moving',
  body:
      'Heat does not make stress. Being prevented from moving makes stress. A '
      'bar free at one end simply gets longer and carries nothing. Hold both '
      'ends and warm it and the growth it was not allowed to make becomes '
      'compression; cool it and the shrinkage it was not allowed to make '
      'becomes tension. Leave it a gap and it may close the gap and never '
      'touch, in which case nothing happens at all, or close it and then fight '
      'for what is left over. When it does build stress, the length and the '
      'cross-section cancel out and only the material and the temperature '
      'change are left.',
  formulas: [
    ('Free movement', r'\delta_t = \alpha L \Delta T'),
    ('Fully restrained', r'\sigma_t = E \alpha \Delta T'),
    ('With a gap to close first', r'\sigma_t = \frac{E(\delta_t - \text{gap})}{L}'),
  ],
  figure: BriefFigure.thermal,
  handbook: 'Handbook p. 130',
);

const polarJBrief = BriefSection(
  title: 'What goes under Tc',
  body:
      'Torsion in a round shaft is one formula and two chances to be out by a '
      'factor of two. The J is the POLAR moment, pi d to the fourth over '
      'THIRTY-TWO. The area moment I, over sixty-four, is the bending one, and '
      'it is half as big, so reaching for it doubles the stress you report and '
      'doubles the twist as well. The c is the outer RADIUS, and using the '
      'diameter there doubles the stress too. A bore is taken '
      'out by subtracting fourth powers, not diameters and not areas: the '
      'metal nearest the middle was barely working, so removing it costs far '
      'less stiffness than it saves weight, which is why shafts are hollow. '
      'And c stays the OUTER radius on a hollow shaft, because that is still '
      'where the stress is highest.',
  formulas: [
    ('Round shaft', r'\tau = \frac{Tc}{J}'),
    ('Solid', r'J = \frac{\pi d^4}{32}'),
    ('Hollow', r'J = \frac{\pi (d_o^4 - d_i^4)}{32}'),
    ('And', r'c = \frac{d_o}{2},\quad J = 2I'),
  ],
  figure: BriefFigure.polarJ,
  handbook: 'Handbook p. 133',
);

const twistBrief = BriefSection(
  title: 'What moves the stress and what moves the twist',
  body:
      'Two formulas share a shaft and they do not respond to the same things. '
      'The stress cares about the torque and the shape of the section and '
      'nothing else: make the shaft longer and the stress does not move, '
      'change to a softer metal and the stress does not move. The twist cares '
      'about all four, length and stiffness included, so a longer shaft or a '
      'softer metal twists further under the same torque and at the same '
      'stress. The stiffness is just that formula turned around, the torque '
      'needed per radian. Note which modulus appears: torsion uses G, the '
      'shear modulus, never E. For steel G is about 80 GPa against E at 200.',
  formulas: [
    ('Stress', r'\tau = \frac{Tc}{J}'),
    ('Twist, in radians', r'\phi = \frac{TL}{GJ}'),
    ('Stiffness', r'k = \frac{T}{\phi} = \frac{GJ}{L}'),
    ('And the two moduli', r'G = \frac{E}{2(1+\nu)}'),
  ],
  figure: BriefFigure.twist,
  handbook: 'Handbook p. 134',
);

const thinWallBrief = BriefSection(
  title: 'The area the wall encloses',
  body:
      'A thin tube of any shape, round or square or oblong, gets its own '
      'formula, and the area in it is the one the MIDDLE of the wall encloses. '
      'That is not the metal, which is the area anybody would name if asked '
      'for the area of a tube and which on a thin wall is a small fraction of '
      'the right number. It is not the bore and it is not the outside face '
      'either, though on a thin wall those two sit close on each side of the '
      'answer. Draw the line halfway through the wall all the way round and '
      'take everything inside it, metal or not. Use this only while the wall '
      'is thin, under about a tenth of the radius; thicker than that and you '
      'are back to the round-shaft formula.',
  formulas: [
    ('Thin-walled tube', r'\tau = \frac{T}{2\,t\,A_m}'),
    ('Where A is', r'A_m = \text{enclosed by the median line}'),
    ('Good while', r't < 0.1\,r'),
  ],
  figure: BriefFigure.thinWall,
  handbook: 'Handbook p. 133',
);

const curveBrief = BriefSection(
  title: 'The five points on the curve',
  body:
      'One tensile test, read left to right. The PROPORTIONAL LIMIT is where '
      'the straight run ends and Hooke\'s law gives out; it is the last point E '
      'can be read from. The ELASTIC LIMIT is a hair past it and is the last '
      'point the bar still springs back from, and on a real curve the two are '
      'so close that nobody separates them. The YIELD POINT is where it '
      'stretches on without carrying any more, the flat run that mild steel '
      'has and aluminum does not. The ULTIMATE STRENGTH is the top of the '
      'curve, and it is also the moment necking starts. The FRACTURE POINT is '
      'the end, and it is LOWER than the top: engineering stress keeps '
      'dividing by the area the bar started with, while the bar itself has '
      'necked down to something thinner.',
  formulas: [
    ('Slope of the straight run', r'E = \frac{\Delta\sigma}{\Delta\varepsilon}'),
    ('Top of the curve', r'\sigma_u \text{, where necking starts}'),
    ('Engineering stress uses', r'A_0 \text{, the original area}'),
  ],
  figure: BriefFigure.curve,
  handbook: 'Handbook p. 129',
);

const stiffStrongBrief = BriefSection(
  title: 'Stiff, strong and stretchy are three things',
  body:
      'They are read off three different features of the same curve and they '
      'do not travel together. STIFF is the slope of the straight run: how '
      'hard it is to move at all, which is E. STRONG is how high the curve '
      'gets: the yield stress for when it stops being usable, the ultimate for '
      'when it is carrying the most. STRETCHY, which is ductility, is how far '
      'to the right it goes before it ends, quoted as percent elongation. A '
      'material can be strong and brittle, like cast iron or a hardened bolt, '
      'and it can be weak and very ductile, like annealed copper. The two '
      'tells for brittle are on the report before you ever see a curve: yield '
      'and ultimate almost equal, and elongation of a percent or two.',
  formulas: [
    ('Stiff', r'E = \frac{\sigma}{\varepsilon} \text{, the slope}'),
    ('Strong', r'\sigma_y \text{ and } \sigma_u \text{, the height}'),
    ('Stretchy', r'\%\,El = \frac{L_f - L_0}{L_0}\times 100'),
    ('Brittle reads as', r'\sigma_y \approx \sigma_u \text{ with } \%\,El \text{ tiny}'),
  ],
  figure: BriefFigure.stiffStrong,
  handbook: 'Handbook p. 129',
);

const linkedBrief = BriefSection(
  title: 'Three constants, any two give the third',
  body:
      'E, G and Poisson\'s ratio are not three independent facts about a '
      'material. They are tied by one equation, so any two of them hand you '
      'the third, and E itself comes straight out of a stress and a strain in '
      'the elastic range. That is what makes the extra numbers in an exam '
      'question worth spotting: the specimen\'s length and diameter, before and '
      'after, are a full page of arithmetic that changes nothing if E and nu '
      'are already sitting there. Read what is asked, find the shortest road '
      'to it, and stop. Watch the direction of the one that catches people: '
      'the 2 belongs in the denominator, so G comes out well under half of E, '
      'about 0.38 of it at a Poisson\'s ratio of 0.3.',
  formulas: [
    ('The link', r'G = \frac{E}{2(1+\nu)}'),
    ('E from a test point', r'E = \frac{\sigma}{\varepsilon}'),
    ("Poisson's ratio", r'\nu = -\frac{\varepsilon_{lat}}{\varepsilon_{axial}}'),
    ('For steel', r'\nu \approx 0.3,\quad G \approx 0.38E'),
  ],
  figure: BriefFigure.linked,
  handbook: 'Handbook p. 130',
);

const slopeRulesBrief = BriefSection(
  title: 'Two rules decide both shapes',
  body:
      'The slope of the shear diagram is minus the load, and the slope of the '
      'moment diagram is the shear. Everything a diagram does follows from '
      'those. Nothing spread along a stretch of beam means the shear is FLAT '
      'there and the moment runs STRAIGHT. A uniform load means the shear '
      'SLOPES and the moment CURVES, and drawing that curve as a pair of '
      'straight lines to the peak is the commonest wrong diagram in the '
      'topic. One step further up: a load that itself changes as it goes, a '
      'triangle, gives a curved shear and a moment curving harder still. The '
      'same rules read the other way are the area method: the change in '
      'moment between two points is the AREA under the shear between them.',
  formulas: [
    ('Load to shear', r'\frac{dV}{dx} = -w(x)'),
    ('Shear to moment', r'\frac{dM}{dx} = V(x)'),
    ('Which is to say', r'M_B - M_A = \int_A^B V\,dx'),
  ],
  figure: BriefFigure.slopeRules,
  handbook: 'Handbook p. 140',
);

const peakBrief = BriefSection(
  title: 'The moment peaks where the shear crosses zero',
  body:
      'A beam is sized for its worst moment, so finding WHERE that is comes '
      'before working out how big it is. It is wherever the shear passes '
      'through zero, which follows from the moment climbing at the rate of '
      'the shear: while the shear is positive the moment is still rising, and '
      'the moment it turns negative the moment starts coming back down. Under '
      'a single load, that is under the load, wherever the load happens to '
      'be. On a symmetric uniform load it is the middle. On a cantilever it is '
      'at the wall, and on an overhang it is over the support, hogging rather '
      'than sagging. Midspan is the right answer often enough to be a habit '
      'and it is the named trap in this lesson\'s hard problem.',
  formulas: [
    ('Peak where', r'V = 0'),
    ('Load at midspan', r'M_{max} = \frac{PL}{4}'),
    ('Load anywhere', r'M_{max} = \frac{Pab}{L}'),
    ('Uniform load', r'M_{max} = \frac{wL^2}{8}'),
  ],
  figure: BriefFigure.peak,
  handbook: 'Handbook p. 140',
);

const jumpBrief = BriefSection(
  title: 'What each thing does at the point it acts',
  body:
      'A vertical force STEPS the shear by its own size, upward forces up and '
      'downward forces down, and that includes the reactions: an upward '
      'reaction steps the shear up. It does nothing sudden to the moment, '
      'which merely changes the rate it is climbing at, so the moment diagram '
      'bends there without a break. A couple is the opposite: it steps the '
      'MOMENT by its own size and leaves the shear untouched, because no '
      'vertical force has been added. Where a spread load starts or stops, '
      'nothing steps at all, the shear just changes the angle it is running '
      'at. And a pinned or rolling end holds no moment, so both ends of a '
      'simply supported beam start and finish at zero.',
  formulas: [
    ('A force', r'\Delta V = \pm P \text{, and } M \text{ only bends}'),
    ('A couple', r'\Delta M = \pm C \text{, and } V \text{ is unchanged}'),
    ('A pin or roller end', r'M = 0'),
  ],
  figure: BriefFigure.jump,
  handbook: 'Handbook p. 140',
);

const fiberBrief = BriefSection(
  title: 'The two stresses live in opposite places',
  body:
      'Through the depth of a beam, bending stress is NOTHING at the neutral '
      'axis and worst at the two faces, running straight between them. That is '
      'the c in M c over I: the distance from the axis to the fiber you care '
      'about, and the fiber that decides the beam is the furthest one. Shear '
      'stress does the opposite: nothing at the faces, worst at the neutral '
      'axis, running as a parabola, and on a rectangle its peak is half again '
      'the plain average of V over A. Sagging stretches the bottom and squashes '
      'the top; over a support it is the other way round, which is where the '
      'reinforcement in a continuous beam moves to. And the neutral axis is '
      'the CENTROID of the section, which is halfway up only when the section '
      'is symmetric about it.',
  formulas: [
    ('Bending, at distance c', r'\sigma = \frac{Mc}{I}'),
    ('Worst shear in a rectangle', r'\tau_{max} = \frac{3V}{2A}'),
    ('Which is', r'1.5 \times \text{the average } V/A'),
    ('The neutral axis is', r'\text{the centroid of the section}'),
  ],
  figure: BriefFigure.fiber,
  handbook: 'Handbook p. 135',
);

const cutBrief = BriefSection(
  title: 'Q and b both belong to the cut',
  body:
      'The shear formula is written for a PLACE in the section, and its two '
      'awkward ingredients both change when you move that place. The b is the '
      'width of the material at the cut. On an I-beam just under the flange '
      'that is the web thickness, not the flange width, and this lesson names '
      'that swap as an error of fifteen times. The Q is the first moment of '
      'the material beyond the cut, its area times the distance from ITS OWN '
      'centroid to the neutral axis. Taking the material on the other side of '
      'the cut gives the same number, because the two sides balance about the '
      'centroid; taking the WHOLE section gives exactly zero, which is what '
      'being the centroid means. On a rectangle the width never changes, which '
      'is the only reason the three V over two A shortcut exists.',
  formulas: [
    ('Shear at a cut', r'\tau = \frac{VQ}{Ib}'),
    ('Q is', r'Q = A_{beyond}\,\bar{y}_{beyond}'),
    ('b is', r'\text{the width AT the cut}'),
    ('Shear flow, for the fixings', r'q = \frac{VQ}{I}'),
  ],
  figure: BriefFigure.cut,
  handbook: 'Handbook p. 135',
);

const governsBrief = BriefSection(
  title: 'What each stress answers to',
  body:
      'The span is in the moment and not in the shear: double the span and the '
      'bending stress doubles while every support carries exactly what it did '
      'before. That one fact is why a long beam is a bending problem and a '
      'short stubby one is a shear problem. Depth is in both, unevenly: the '
      'section modulus carries it SQUARED, so twice the depth quarters the '
      'bending stress, while the area carries it once and only halves the '
      'shear. Turning a joist on its side changes the bending badly and leaves '
      'the shear alone, since the area is the same timber either way up. And '
      'the material is in NEITHER formula: a steel beam of the same size under '
      'the same load carries the same stresses as a timber one. What it has is '
      'more strength to meet them with.',
  formulas: [
    ('Section modulus', r'S = \frac{I}{c},\quad \sigma = \frac{M}{S}'),
    ('For a rectangle', r'S = \frac{bh^2}{6}'),
    ('Span moves', r'M \text{, not } V'),
    ('Neither formula holds', r'E'),
  ],
  figure: BriefFigure.governs,
  handbook: 'Handbook p. 135',
);

const tableBrief2 = BriefSection(
  title: 'Read the supports, then the load',
  body:
      'Nothing in this lesson is derived. The handbook has a table of beams '
      'and you match the one in front of you to a line in it, so the whole '
      'skill is reading the picture: is it held at BOTH ENDS or built in at '
      'one, and is the load GATHERED at a point or SPREAD along? Those two '
      'questions pick the line. Getting them wrong is not a few percent out: '
      'the same load on a cantilever instead of a simply supported beam is '
      'sixteen times the sag, and a spread load taken as a cantilever rather '
      'than simply supported is nearly ten. Note which powers appear: a point '
      'load brings L cubed and a spread load brings L to the fourth, because '
      'the longer the beam the more spread load there is on it.',
  formulas: [
    ('Held both ends, load in the middle', r'\delta = \frac{PL^3}{48EI}'),
    ('Held both ends, load spread', r'\delta = \frac{5wL^4}{384EI}'),
    ('Built in, load at the tip', r'\delta = \frac{PL^3}{3EI}'),
    ('Built in, load spread', r'\delta = \frac{wL^4}{8EI}'),
  ],
  figure: BriefFigure.tableLine,
  handbook: 'Handbook pp. 140 to 141',
);

const bounceBrief = BriefSection(
  title: 'What actually stiffens a beam',
  body:
      'Deflection, not strength, is what usually decides a beam: a floor can '
      'be perfectly safe and still feel like a trampoline, which is why the '
      'codes cap it at around the span over three hundred and sixty. When one '
      'is too soft, the powers tell you what to change. SPAN is cubed under a '
      'point load and to the fourth under a spread one, so it is the biggest '
      'lever and usually the one you cannot touch. DEPTH is cubed inside I, so '
      'a quarter more depth is nearly double the stiffness. WIDTH and LOAD '
      'each count once. The MATERIAL counts once through E, which is nothing '
      'between two grades of steel, since every grade has the same E, and '
      'everything between timber and steel.',
  formulas: [
    ('Everything sits on', r'EI'),
    ('For a rectangle', r'I = \frac{bh^3}{12}'),
    ('Serviceability, typically', r'\delta \le \frac{L}{360}'),
    ('A stronger steel', r'\text{same } E \Rightarrow \text{same sag}'),
  ],
  figure: BriefFigure.bounce,
  handbook: 'Handbook pp. 140 to 141',
);

const addBrief = BriefSection(
  title: 'Two loads, two lookups, one sum',
  body:
      'A beam carrying more than one thing is rarely in the table, and it does '
      'not need to be. Work out the sag from each load as though the others '
      'were not there, then ADD the answers. That is allowed because sag is '
      'proportional to load while the material stays elastic: double the load '
      'and you double the sag, so the pieces cannot interfere with each other. '
      'The rule that keeps it honest is that you split the LOAD and never the '
      'supports: every piece must be the same beam, held the same way, '
      'carrying part of what the real one carries. The same line can be used '
      'twice with different numbers, and a beam that is already in the table '
      'needs no splitting at all.',
  formulas: [
    ('Superposition', r'\delta_{total} = \delta_1 + \delta_2 + \dots'),
    ('Because', r'\delta \propto \text{load, while elastic}'),
    ('Split', r'\text{the load, not the supports}'),
  ],
  figure: BriefFigure.addUp,
  handbook: 'Handbook pp. 140 to 141',
);

const transformBrief = BriefSection(
  title: 'Write it as one material',
  body:
      'Two materials bonded together bend as one thing, and the trick is to '
      'rewrite the section as though it were all made of the SOFTER one. The '
      'stiffer material gets n times WIDER, where n is its modulus divided by '
      'the softer modulus, because that is how much of the soft stuff it '
      'would take to do the same job. Three things that must not happen: the '
      'widening never goes to the softer material, it is never a division, and '
      'it is never a change of DEPTH. Depth is how far material sits from the '
      'axis and that is what bending is about, so moving it would be a '
      'different beam. Once transformed, everything from the bending lesson '
      'works unchanged: find the centroid, find I, use M y over I.',
  formulas: [
    ('Modular ratio', r'n = \frac{E_{stiff}}{E_{soft}} > 1'),
    ('Transform by', r'b_{new} = n\,b_{stiff}'),
    ('Never', r'\text{a depth, and never the soft one}'),
  ],
  figure: BriefFigure.transform,
  handbook: 'Handbook p. 136',
);

const joinBrief = BriefSection(
  title: 'Strain is shared, stress is not',
  body:
      'Two materials glued together cannot stretch by different amounts where '
      'they meet, so the STRAIN is the same on both sides of the join. Their '
      'stiffnesses are not the same, and stress is stiffness times strain, so '
      'the STRESS jumps across that line by exactly the modular ratio. That is '
      'the whole of the extra n in the formula: the transformed section hands '
      'you the stress the SOFT material would feel, and the stiff material at '
      'the same height feels n times it. It also explains something worth '
      'carrying into design: the stiffer material attracts load whether or not '
      'you meant it to.',
  formulas: [
    ('Across the join', r'\varepsilon_1 = \varepsilon_2'),
    ('So', r'\sigma = E\varepsilon \Rightarrow \sigma_1 = n\,\sigma_2'),
    ('In the transformed section', r'\sigma_1 = \frac{nMy}{I_T}'),
    ('And', r'\sigma_2 = \frac{My}{I_T}'),
  ],
  figure: BriefFigure.join,
  handbook: 'Handbook p. 136',
);

const plasticBrief = BriefSection(
  title: 'First yield is not the end of the beam',
  body:
      'Load a ductile section and the stress through its depth goes through '
      'four pictures. A straight line while everything is elastic. A straight '
      'line just touching yield at the two faces, which is the YIELD moment, '
      'F y times the elastic S. Then yielding eats inward from both faces '
      'while an elastic core holds on in the middle, with the moment still '
      'climbing. Finally it goes square, yielded right through, and that is '
      'the PLASTIC moment, F y times Z. Z is the plastic section modulus and '
      'it is bigger than S; using S for the plastic moment is this lesson\'s '
      'named trap. The ratio between them, the shape factor, is about one and '
      'a half for a rectangle and only about one and a tenth for a wide '
      'flange, which already has most of its material at the faces.',
  formulas: [
    ('First yield', r'M_y = F_y S'),
    ('Fully plastic', r'M_p = F_y Z'),
    ('Shape factor', r'\frac{Z}{S} \approx 1.5 \text{ rectangle}'),
    ('And', r'\frac{Z}{S} \approx 1.1 \text{ wide flange}'),
  ],
  figure: BriefFigure.plastic,
  handbook: 'Handbook pp. 136 and 281',
);

const circleBrief = BriefSection(
  title: 'Every answer is a place on the circle',
  body:
      'Mohr\'s circle is not a drawing exercise, it is a map of every plane '
      'through one point. The CENTER sits on the normal stress axis at the '
      'average of the two normal stresses, and rotating the element never '
      'moves it. The RADIUS is the worst shear on any plane in the page. The '
      'two ENDS are the principal stresses, where the shear has run out to '
      'nothing: sigma one is the right hand end and sigma two the left, '
      'whatever the signs are, so on a circle that sits entirely in '
      'compression sigma one is the SMALLEST squeeze. The face your numbers '
      'came from is just another point on the circle, at the normal stress you '
      'were given and the shear you were given. And angles double: a plane '
      'turned by theta in the material moves two theta round the circle, which '
      'is why the worst shear sits forty five degrees from the principal '
      'planes.',
  formulas: [
    ('Center', r'C = \frac{\sigma_x + \sigma_y}{2}'),
    ('Radius', r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}'),
    ('Ends', r'\sigma_{1,2} = C \pm R'),
    ('Angles', r'\theta \text{ in the material} = 2\theta \text{ on the circle}'),
  ],
  figure: BriefFigure.circle,
  handbook: 'Handbook p. 131',
);

const buildBrief = BriefSection(
  title: 'Three special circles worth knowing on sight',
  body:
      'PURE SHEAR, with no normal stress on either face, is a circle centered '
      'on the origin: principal stresses of plus tau and minus tau, so pure '
      'shear is tension one way and compression square to it at forty five '
      'degrees. That is why a brittle shaft in torsion cracks on a spiral. '
      'UNIAXIAL TENSION runs from zero out to the stress applied, with its '
      'worst shear at half of it on a forty five degree plane, which is why a '
      'ductile bar necks on the slant. EQUAL STRESS BOTH WAYS with no shear is '
      'not a circle at all but a single POINT: no shear on any plane, and '
      'turning the element changes nothing. In every other case, remember that '
      'any shear at all pushes sigma one further out than the normal stress '
      'you started with.',
  formulas: [
    ('Pure shear', r'\sigma_{1,2} = \pm\tau \text{, centered on } 0'),
    ('Uniaxial', r'\sigma_1 = \sigma,\ \sigma_2 = 0,\ R = \frac{\sigma}{2}'),
    ('Equal both ways', r'R = 0 \text{, a point}'),
    ('With any shear', r'\sigma_1 > \sigma_x'),
  ],
  figure: BriefFigure.build,
  handbook: 'Handbook p. 131',
);

const worstBrief = BriefSection(
  title: 'The third principal stress is zero, and it counts',
  body:
      'The radius is the worst shear on the planes you can see in the page. '
      'The worst shear AT THE POINT is half the spread between the largest and '
      'smallest of all THREE principal stresses, and the third one, out of the '
      'page, is zero at any free surface. So the test is one look at the '
      'drawing: if the circle crosses the zero mark, zero is already inside '
      'the spread and the radius is the answer. If the whole circle sits to '
      'one side of zero, which happens whenever both principal stresses have '
      'the same sign, the real spread runs from zero to the far end and the '
      'worst shear is half of THAT, which is always bigger than the radius. '
      'The case that punishes a habit hardest is two similar tensions: a tiny '
      'circle a long way out, almost no in-plane shear, and a serious shear on '
      'a plane out of the page.',
  formulas: [
    ('Worst at the point', r'\tau_{abs} = \frac{\sigma_{max} - \sigma_{min}}{2}'),
    ('Out of plane', r'\sigma_3 = 0'),
    ('Circle crosses zero', r'\tau_{abs} = R'),
    ('Circle clear of zero', r'\tau_{abs} = \frac{|\sigma_{far}|}{2} > R'),
  ],
  figure: BriefFigure.worst,
  handbook: 'Handbook p. 132',
);

const endsBrief = BriefSection(
  title: 'The ends decide almost everything',
  body:
      'Euler\'s load does not use the length of the column, it uses the '
      'EFFECTIVE length, which is the distance between the points the buckled '
      'shape passes straight through. The handbook gives four cases and you '
      'match the picture to one of them. Both ends pinned is the base case at '
      'one. Both ends fixed against turning bends the column into an S and '
      'halves it, and half the length is four times the load. One of each is '
      'zero point seven. And anything with a FREE end is two, because the '
      'column bends like half of a pinned one twice as long: that is the case '
      'students forget, and it is sixteen times weaker than the fixed pair. '
      'Since the effective length is squared, getting this wrong is never a '
      'small error.',
  formulas: [
    ('Euler', r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}'),
    ('Pinned both ends', r'K = 1.0'),
    ('Fixed both ends', r'K = 0.5'),
    ('One of each, and a free end', r'K = 0.7,\quad K = 2.0'),
  ],
  figure: BriefFigure.ends,
  handbook: 'Handbook p. 136',
);

const weakAxisBrief = BriefSection(
  title: 'It folds about the axis it is weakest around',
  body:
      'The I in Euler\'s formula is the MINIMUM one. A column has no say in '
      'which way it goes and it will not wait for the strong axis, so the only '
      'second moment that matters is the smaller of the two. Using the bigger '
      'one does not fail safely: it says the column is stronger than it is. On '
      'a wide flange section that means the minor axis, which is why building '
      'columns get braced sideways rather than front to back. A section that '
      'is the same both ways, a square tube or a round one, has no weak axis '
      'at all, and that is exactly what makes it a good column: none of the '
      'material is wasted propping up a strong axis that will never be tested. '
      'The same idea in stress form is the minimum radius of gyration, r '
      'equals the square root of I over A.',
  formulas: [
    ('Use', r'I_{min} \text{, always}'),
    ('Or in stress form', r'r = \sqrt{\frac{I}{A}} \text{, the smaller one}'),
    ('Square or round', r'I_x = I_y \text{, no weak axis}'),
  ],
  figure: BriefFigure.weakAxis,
  handbook: 'Handbook p. 136',
);

const slenderBrief = BriefSection(
  title: 'Long columns buckle, short ones squash',
  body:
      'Euler describes a column bowing sideways while the material is still '
      'elastic, and a stocky column never gets the chance: it reaches its '
      'yield stress and squashes. So the formula is only allowed when the '
      'stress it gives comes out BELOW yield, which is the check the lesson\'s '
      'hardest problem is really asking for. Draw the two ideas together and '
      'it is one picture: Euler\'s hyperbola falling away as the column gets '
      'slenderer, the yield stress capping the short end, and a crossing '
      'between them at a slenderness of pi times the square root of E over the '
      'yield stress, about eighty nine for ordinary steel. And note what is '
      'NOT in Euler\'s formula: the strength of the material. A stronger steel '
      'does nothing for a slender column and everything for a stocky one.',
  formulas: [
    ('Critical stress', r'\sigma_{cr} = \frac{\pi^2 E}{(KL/r)^2}'),
    ('Only when', r'\sigma_{cr} < \sigma_y'),
    ('They cross at', r'\frac{KL}{r} = \pi\sqrt{\frac{E}{\sigma_y}}'),
    ('Which for mild steel is', r'\approx 89'),
  ],
  figure: BriefFigure.slender,
  handbook: 'Handbook p. 136',
);

const missingBrief = BriefSection(
  title: 'The equation is chosen by what is absent',
  body:
      'Straight line motion at a steady acceleration has five quantities: the '
      'speed you started at, the speed you ended at, how far, how long, and '
      'the acceleration. Any three of them give you the other two, and each '
      'equation leaves exactly ONE of the five out. So the question that picks '
      'the equation is which quantity the problem never mentions and never '
      'asks for. No seconds anywhere is the commonest, and it points at v '
      'squared equals v naught squared plus two a s. Two warnings: slowing '
      'down means the acceleration is negative, and none of these equations '
      'is allowed unless the acceleration is CONSTANT.',
  formulas: [
    ('No distance', r'v = v_0 + at'),
    ('No time', r'v^2 = v_0^2 + 2a(s - s_0)'),
    ('No final speed', r's = s_0 + v_0t + \tfrac{1}{2}at^2'),
    ('No acceleration', r's = s_0 + \tfrac{1}{2}(v_0 + v)t'),
  ],
  figure: BriefFigure.missing,
  handbook: 'Handbook p. 104',
);

const flightBrief = BriefSection(
  title: 'Across and up and down never mix',
  body:
      'A projectile is two problems side by side. ACROSS there is no force at '
      'all once it has left, so that speed never changes for the whole flight: '
      'it is the same at the launch, at the top and at the landing. UP AND '
      'DOWN gravity pulls the whole time, so that speed runs steadily downhill '
      'through zero and out the other side, and the instant it passes zero is '
      'the top of the arc. That is what makes the top solvable: the vertical '
      'speed there is nothing, and the lesson\'s own problem is exactly that '
      'step. Two things people say that are wrong: that the ball stops at the '
      'top, when it is still traveling across, and that its acceleration is '
      'less there, when gravity is pulling just as hard as it was at the '
      'start. Split it into the two directions before anything else, and use '
      'the vertical PIECE of the launch speed, never the whole of it.',
  formulas: [
    ('Across', r'v_x = v_0\cos\theta \text{, unchanging}'),
    ('Up and down', r'v_y = v_0\sin\theta - gt'),
    ('At the top', r'v_y = 0'),
    ('Everywhere', r'a = g \text{, downward}'),
  ],
  figure: BriefFigure.flight,
  handbook: 'Handbook p. 104',
);

const bendBrief = BriefSection(
  title: 'Two accelerations at right angles',
  body:
      'Anything on a curved path is accelerating in two ways at once. ALONG '
      'the path, the tangential piece, changes how fast it is going and is the '
      'only one the speedometer knows about. Square to the path, pointing at '
      'the middle of the bend, the normal piece changes which way it is going, '
      'and it is v SQUARED over the radius, so speed counts twice over and a '
      'tighter bend is worse. The one worth holding on to: something going '
      'round a bend at a perfectly steady speed IS accelerating, because its '
      'direction is changing, and that is what the tires and the rails have to '
      'push against. The two sit at right angles, so the total is the two '
      'combined as the sides of a right triangle and never the two added up.',
  formulas: [
    ('Along the path', r'a_t = \dot{v}'),
    ('Toward the middle', r'a_n = \frac{v^2}{\rho}'),
    ('Together', r'a = \sqrt{a_t^2 + a_n^2}'),
    ('Steady speed', r'a_t = 0 \text{, and } a_n \text{ is still there}'),
  ],
  figure: BriefFigure.bend,
  handbook: 'Handbook p. 103',
);

const spinBrief = BriefSection(
  title: 'One spin, a speed for every radius',
  body:
      'A rigid body has ONE angular velocity: every point on it turns through '
      'the same angle in the same time, which is what being rigid means. It '
      'does not have one speed. A point\'s speed is r times omega, so it grows '
      'straight with the distance out from the axis and the rim of a wheel can '
      'be doing fifty meters a second while a point near the hub strolls. The '
      'pull toward the middle grows too, as r omega squared. Neither depends '
      'on where a point sits AROUND the circle, only on how far out it is. And '
      'the units trap the lesson names: rpm is not omega. Turns a minute times '
      'two pi over sixty gets you radians a second, and using rpm straight in '
      'v equals r omega is out by a factor of about ten.',
  formulas: [
    ('Speed of a point', r'v = r\omega'),
    ('Toward the middle', r'a_n = r\omega^2 = \frac{v^2}{r}'),
    ('Along the path', r'a_t = r\alpha'),
    ('From rpm', r'\omega = \text{rpm}\times\frac{2\pi}{60}'),
  ],
  figure: BriefFigure.spin,
  handbook: 'Handbook p. 103',
);

const spinInertiaBrief = BriefSection(
  title: 'How hard it is to spin up',
  body:
      'Mass moment of inertia is the rotating twin of mass: it is what decides '
      'how much moment it takes to get something turning. It is not a property '
      'of the body alone, it belongs to the body AND the axis, and the '
      'handbook gives the standard shapes so nothing is derived. Read the '
      'coefficients as a story about where the material sits: a hoop, with '
      'everything at the rim, is m r squared; a solid disc, with most of it '
      'closer in, is half that; a sphere, closer in still, is two fifths. A '
      'rod about its middle is a twelfth of m L squared and about its END it '
      'is a third, four times more, with nothing about the rod changed. To '
      'move an axis, add m d squared, and only ever FROM the centroid: going '
      'between two off-center axes needs two steps through the middle. Once '
      'the axis is further off than the body is wide, that transfer term is '
      'the whole answer.',
  formulas: [
    ('Hoop, disc, sphere', r'mr^2,\quad \tfrac{1}{2}mr^2,\quad \tfrac{2}{5}mr^2'),
    ('Rod, middle and end', r'\tfrac{1}{12}mL^2,\quad \tfrac{1}{3}mL^2'),
    ('Moving the axis', r'I = I_c + md^2'),
    ('Only ever', r'\text{from the centroid outward}'),
  ],
  figure: BriefFigure.spinInertia,
  handbook: 'Handbook pp. 110 and 114 to 115',
);

const weightBrief = BriefSection(
  title: 'Kilograms are not newtons',
  body:
      'F equals m a wants a FORCE on one side and a MASS on the other, so the '
      'first job on any dynamics problem is reading which of the two you were '
      'handed. Kilograms and slugs are mass. Newtons and pounds are force, '
      'which is to say a weight when gravity is what is causing it. A five '
      'hundred newton block has a mass of about fifty one kilograms, and using '
      'the five hundred as a mass makes it nearly ten times heavier than it '
      'is. Going the other way, a fifty kilogram block weighs four hundred and '
      'ninety newtons. The conversion is one multiply or one divide by g, '
      'which is nine point eight one in metric and thirty two point two in US '
      'units, and the commonest mistake after using the wrong one is doing the '
      'conversion to something that never needed it.',
  formulas: [
    ('Weight from mass', r'W = mg'),
    ('Mass from weight', r'm = \frac{W}{g}'),
    ('And', r'g = 9.81\ \mathrm{m/s^2} = 32.2\ \mathrm{ft/s^2}'),
  ],
  figure: BriefFigure.weight,
  handbook: 'Handbook p. 105',
);

const slopeBrief = BriefSection(
  title: 'Gravity pulls down, and the slope splits it',
  body:
      'Draw the free body diagram first: every problem in this lesson is won '
      'or lost there. On a slope, the weight still points straight down, and '
      'because the block cannot go straight down it is worth splitting that '
      'pull into two pieces along the directions that matter. The piece '
      'running DOWN THE SURFACE, weight times the SINE of the slope, is the '
      'only one that accelerates the block. The piece pressing INTO the '
      'surface, weight times the COSINE, is answered exactly by the surface '
      'pushing back, so it accelerates nothing, though it is what sets the '
      'friction available. Swapping the two is the named trap. Note where they '
      'cross: past forty five degrees the driving piece is the bigger of the '
      'two, and on a frictionless slope the acceleration is g sine theta '
      'whatever the block weighs.',
  formulas: [
    ('Down the slope', r'W\sin\theta = ma'),
    ('Into the slope', r'N = W\cos\theta'),
    ('So', r'a = g\sin\theta \text{, whatever the mass}'),
  ],
  figure: BriefFigure.slope,
  handbook: 'Handbook p. 105',
);

const twoEquationsBrief = BriefSection(
  title: 'A rigid body has two equations',
  body:
      'Forces move the mass center and moments about that center spin the '
      'body, and a rigid body problem can need either or both. What decides it '
      'is what is HOLDING the body and where the force LANDS. An axle through '
      'the middle stops the body moving off, so only the moment equation is '
      'left. A force whose line passes through the mass center has no arm '
      'about it, so it spins nothing and only the force equation is left. A '
      'free body pushed off center does both at once. And a force is not a '
      'moment until you multiply it by its distance from the center: dropping '
      'that step is a named trap, and so is reaching for F equals m a on a '
      'problem where nothing moves off anywhere.',
  formulas: [
    ('Forces', r'\sum F = ma_c'),
    ('Moments about the center', r'\sum M_c = I_c\alpha'),
    ('A force becomes a moment by', r'M = F d'),
  ],
  figure: BriefFigure.twoEquations,
  handbook: 'Handbook pp. 105 and 109',
);

const ledgerBrief = BriefSection(
  title: 'Energy is an account, and it balances',
  body:
      'What a thing started with, plus anything put in from outside, minus '
      'anything rubbed away, is what it ends with. That one sentence is the '
      'work energy theorem, and the whole skill is reading which of those '
      'buckets a situation actually has. Height and movement trade with each '
      'other freely. A SPRING is a store, not a loss: what was squeezed into '
      'it comes back out. FRICTION and drag take and never return, which is '
      'the one term that makes the after side smaller than the before. A motor '
      'or an engine ADDS from outside. When nothing is taken and nothing '
      'added, the two sides are equal and it is a conservation problem. Energy '
      'methods are the fast road when you know two positions and a speed and '
      'do not care about the time between them.',
  formulas: [
    ('The full account', r'T_1 + V_1 + U^{nc}_{1\to2} = T_2 + V_2'),
    ('Moving', r'T = \tfrac{1}{2}mv^2'),
    ('Height and spring', r'V_g = mgh, \quad V_e = \tfrac{1}{2}ks^2'),
  ],
  figure: BriefFigure.ledger,
  handbook: 'Handbook p. 106',
);

const cancelBrief = BriefSection(
  title: 'When the mass cancels, and when it does not',
  body:
      'Two of this lesson\'s three problems have the mass drop out, and it is '
      'worth knowing which way a problem will go before starting it. Mass '
      'cancels when it sits on BOTH sides of an energy balance: a heavier '
      'block starts with more energy and needs more of it to reach any given '
      'speed or height, so the speed at the bottom of a ramp, the height of a '
      'throw and even the stopping distance under friction are the same '
      'whatever it weighs, since friction scales with weight too. Mass does '
      'NOT cancel when it appears on one side only: the energy a thing '
      'carries, the power to lift it, and the speed a spring of fixed squeeze '
      'can give it. The last one catches people, because a lighter block '
      'leaves the same spring FASTER.',
  formulas: [
    ('Cancels', r'v = \sqrt{2gh}, \quad d = \frac{v^2}{2\mu g}'),
    ('Does not', r'T = \tfrac{1}{2}mv^2, \quad P = \dot{m}gh'),
    ('And a spring gives', r'v = \sqrt{\frac{ks^2}{m}}'),
  ],
  figure: BriefFigure.cancel,
  handbook: 'Handbook p. 106',
);

const powerBrief = BriefSection(
  title: 'Power, and the direction efficiency runs',
  body:
      'Power is the rate of doing work, and there are two ways to write it '
      'that mean the same thing: the energy divided by the time it took, or '
      'the force multiplied by the speed. The second is the one line answer '
      'whenever something moves steadily against a resistance. Efficiency is '
      'where the marks go. A machine always takes in MORE than it gives out, '
      'so the useful output is the input times the efficiency, and the input '
      'you need is the output DIVIDED by it. Stopping at the useful power when '
      'the question asked for the motor is the named trap in this lesson, and '
      'multiplying where you should divide gives an answer smaller than the '
      'work being done, which is the check that catches it.',
  formulas: [
    ('Power', r'P = \frac{dU}{dt} = F v'),
    ('Efficiency', r'\eta = \frac{P_{out}}{P_{in}} < 1'),
    ('So the motor needs', r'P_{in} = \frac{P_{out}}{\eta}'),
  ],
  figure: BriefFigure.power,
  handbook: 'Handbook p. 107',
);

const impactBrief = BriefSection(
  title: 'Stuck, bounced, or somewhere between',
  body:
      'The first thing to read out of a collision problem is the word that '
      'tells you what kind it is. STUCK together, locked, coupled, embedded, '
      'buried: all of them mean the coefficient of restitution is nothing, the '
      'two move off as one, and ONE equation does the whole job, with both '
      'masses added together on the after side. A perfect bounce is an e of '
      'one and never quite happens in the world. Anything in between needs TWO '
      'equations, because there are two unknown speeds: the momentum of the '
      'pair, and the restitution relation, which compares how fast they '
      'separate with how fast they closed. Note which velocities that '
      'comparison uses: the ones square to the surface they hit on, never the '
      'ones sliding along it.',
  formulas: [
    ('Momentum of the pair', r"m_1v_1 + m_2v_2 = m_1v_1' + m_2v_2'"),
    ('Restitution', r"e = \frac{v_2' - v_1'}{v_1 - v_2}"),
    ('Stuck together', r"e = 0,\quad v_1' = v_2'"),
    ('Perfect bounce', r'e = 1'),
  ],
  figure: BriefFigure.impact,
  handbook: 'Handbook p. 108',
);

const survivesBrief = BriefSection(
  title: 'Momentum always, energy almost never',
  body:
      'Momentum comes through every collision unchanged, because nothing '
      'outside is pushing on the pair while the bang lasts. Kinetic energy '
      'does not: it survives ONLY a perfect bounce, and everything else spends '
      'some of it on bending, heating and noise. A crash where things stick '
      'together spends the most, and a bullet burying itself in a block spends '
      'over ninety nine percent of it. That is why conserving energy in a '
      'plastic collision is the named trap in this lesson, and why a ballistic '
      'pendulum is worked with momentum for the impact and energy only for the '
      'swing that follows. One more thing worth holding: momentum is conserved '
      'across the PAIR, never by one body on its own.',
  formulas: [
    ('Always', r'\sum p \text{ before} = \sum p \text{ after}'),
    ('Only when e = 1', r'\sum T \text{ before} = \sum T \text{ after}'),
    ('Sticking together', r'\text{loses the most}'),
  ],
  figure: BriefFigure.survives,
  handbook: 'Handbook p. 108',
);

const impulseBrief = BriefSection(
  title: 'Force times time is the whole of it',
  body:
      'Impulse is a force multiplied by how long it acts, and it equals the '
      'change in momentum exactly. Drawn as force against time, it is the AREA '
      'under the line. That one sentence explains the safest thing in a '
      'vehicle: a crash fixes how much momentum has to disappear, so the only '
      'thing a designer can change is how LONG the stopping takes, and the '
      'force follows. Twice as long is half as hard, which is a crumple zone, '
      'an airbag, a catcher drawing their hands back and a run off area. Turn '
      'it over and you have a pile driver: the same momentum in the shortest '
      'possible time is the biggest possible force. And if a question gives a '
      'force and a time, the answer is a momentum, not a force: divide by the '
      'time only when you want the force back.',
  formulas: [
    ('Impulse', r'\int F\,dt = F_{avg}\,\Delta t'),
    ('Which is', r'F\,\Delta t = m v_2 - m v_1'),
    ('So a longer stop', r'\text{means a smaller force}'),
  ],
  figure: BriefFigure.impulse,
  handbook: 'Handbook p. 107',
);

const underneathBrief = BriefSection(
  title: 'What goes underneath',
  body:
      'Every number on this page is a force or a stretch over one measurement, '
      'and the whole skill is knowing which. ENGINEERING stress and strain '
      'divide by the bar you put in the machine: the area it started with and '
      'the gauge length it started with. They keep dividing by those even '
      'after the bar has thinned, which is exactly why the reported stress '
      'falls at the end of a test while the steel is doing nothing of the '
      'kind. TRUE stress and strain divide by the bar you have at that '
      'instant, the waist included. And a strain is a length over a length, '
      'so it comes out a bare number with no units on it. If what you wrote '
      'down still has millimeters after it, it is a stretch, and using it as '
      'a strain puts the modulus out by the whole gauge length.',
  formulas: [
    ('Engineering stress', r'\sigma = \frac{F}{A_0}'),
    ('Engineering strain', r'\varepsilon = \frac{\Delta L}{L_0}'),
    ('True stress', r'\sigma_T = \frac{F}{A}'),
    ('True strain', r'\varepsilon_T = \ln(1 + \varepsilon)'),
  ],
  figure: BriefFigure.underneath,
  handbook: 'Handbook p. 121',
);

const trueStressBrief = BriefSection(
  title: 'The same test, divided twice',
  body:
      'One tensile test gives two curves, and they are the same line until '
      'the stretching gets serious. Past that, true stress is always the '
      'bigger of the two, because the area underneath it is shrinking while '
      'the engineering one holds the original area fixed. Volume is conserved '
      'while the bar thins evenly, which is where the conversion comes from, '
      'so check the direction before you trust a number: multiplying by one '
      'plus the strain RAISES it. The engineering curve turns over and comes '
      'down once a waist forms, and its highest point is the ultimate tensile '
      'strength, which is the number a mill certificate quotes. The true '
      'curve has no peak at all. It climbs until the bar parts.',
  formulas: [
    ('True from engineering', r'\sigma_T = \sigma(1 + \varepsilon)'),
    ('True strain', r'\varepsilon_T = \ln(1 + \varepsilon)'),
    ('Why', r'A \approx \frac{A_0}{1 + \varepsilon}'),
  ],
  figure: BriefFigure.trueStress,
  handbook: 'Handbook p. 121',
);

const crackBrief = BriefSection(
  title: 'Where the crack is',
  body:
      'One formula covers cracking, and the two numbers you feed it are both '
      'decided by where the crack sits rather than by any arithmetic. A crack '
      'running in from an EDGE takes a geometry factor of 1.1, and the a is '
      'the whole depth of it, because there is nothing behind it holding it '
      'shut. A crack buried INSIDE the plate takes 1.0, and the a is HALF the '
      'length you can see: an internal crack is described as being of length '
      '2a, and that halving is the single most missed step in the whole '
      'lesson. Then convert to meters. A crack left in millimeters puts the '
      'answer out by more than thirty times, which is the kind of wrong that '
      'looks like a different question.',
  formulas: [
    ('The formula', r'K_{IC} = Y\sigma\sqrt{\pi a}'),
    ('From an edge', r'Y = 1.1,\quad a = \text{the whole depth}'),
    ('Inside', r'Y = 1.0,\quad a = \tfrac{1}{2}\,\text{of the length}'),
  ],
  figure: BriefFigure.crack,
  handbook: 'Handbook p. 122',
);

const toughnessBrief = BriefSection(
  title: 'A crack and a stress together',
  body:
      'Fracture toughness is a property of the material, like a strength, and '
      'what it is held against is the stress and the crack TOGETHER. Neither '
      'means anything alone: a long crack at a low stress and a short one at '
      'a high stress can sit in exactly the same trouble. The crack is under '
      'a square root and the stress is not, which is worth knowing in the '
      'field: four times the crack is only twice the driving force, while '
      'twice the load is twice the driving force straight off. That is why a '
      'cracked member can often be de-rated and kept in service, and why the '
      'same flaw in aluminum is nearer to going than it is in steel.',
  formulas: [
    ('Driving the crack', r'K = Y\sigma\sqrt{\pi a}'),
    ('The most stress it can take',
        r'\sigma_{max} = \frac{K_{IC}}{Y\sqrt{\pi a}}'),
    ('The biggest crack it can carry',
        r'a_{max} = \frac{1}{\pi}\left(\frac{K_{IC}}{Y\sigma}\right)^2'),
  ],
  figure: BriefFigure.toughness,
  handbook: 'Handbook p. 122',
);

const expandBrief = BriefSection(
  title: 'Three things, all multiplying',
  body:
      'How far something moves when the temperature changes is the '
      'coefficient times the length times the change, and all three matter '
      'equally. The coefficient is the material: aluminum moves about twice '
      'as readily as steel, and steel and concrete are close enough to each '
      'other that reinforced concrete survives a summer. The length counts in '
      'direct proportion, which is why the long uninterrupted run is where '
      'movement shows up. And the temperature change is a DIFFERENCE between '
      'two readings, never a sum of them, which is the easiest mark on the '
      'whole page to throw away. Nothing about the cross-section appears '
      'anywhere: a heavy column and a thin rod of the same length move the '
      'same amount.',
  formulas: [
    ('How far it moves', r'\Delta L = \alpha L \Delta T'),
    ('Which is a strain', r'\alpha = \frac{\varepsilon}{\Delta T}'),
    ('Steel, concrete, aluminum',
        r'11.7,\; 10,\; 23 \times 10^{-6}\,/^{\circ}C'),
  ],
  figure: BriefFigure.expand,
  handbook: 'Handbook p. 126',
);

const furnaceBrief = BriefSection(
  title: 'How fast it came down',
  body:
      'Two questions read any heat treatment on this page. Did the steel get '
      'up above about seven hundred and twenty seven degrees, where it is '
      'austenite? And how fast did it come back down through that change? '
      'Fast enough and the atoms never get to move, so the structure is '
      'trapped part way and what you have is martensite: very hard, very '
      'brittle. Slow, and they do move, giving the mixture of ferrite and '
      'cementite that the phase diagram calls for: softer and ductile. '
      'Reheating a quenched part to a few hundred degrees is tempering, which '
      'keeps most of the hardness and takes away most of the brittleness. If '
      'it never reached austenite, a quench does nothing at all.',
  formulas: [
    ('Fast from austenite', r'\gamma \rightarrow \text{martensite}'),
    ('Slow from austenite',
        r'\gamma \rightarrow \alpha + Fe_3C'),
    ('Then reheated', r'\text{martensite} \rightarrow \text{tempered}'),
  ],
  figure: BriefFigure.furnace,
  handbook: 'Handbook p. 116',
);

const tieLineBrief = BriefSection(
  title: 'The arm on the far side',
  body:
      'Inside a two phase region, the horizontal tie line at your temperature '
      'runs from the solid boundary to the liquid boundary, and your alloy '
      'sits somewhere along it. The fraction of a phase is the arm on the FAR '
      'side from that phase, divided by the whole tie line. So the liquid '
      'fraction uses the arm running back to the SOLID boundary, which is the '
      'step that feels backwards and is the most missed on the page. Two '
      'checks cost nothing: the two fractions must add to one, and an alloy '
      'sitting close to a boundary must be mostly that phase. The '
      'denominator is measured between the two boundaries, never from zero.',
  formulas: [
    ('Fraction liquid', r'f_L = \frac{x_0 - x_\alpha}{x_L - x_\alpha}'),
    ('Fraction solid', r'f_\alpha = \frac{x_L - x_0}{x_L - x_\alpha}'),
    ('Always', r'f_L + f_\alpha = 1'),
  ],
  figure: BriefFigure.tieLine,
  handbook: 'Handbook p. 127',
);

const mixBrief = BriefSection(
  title: 'Water over cement',
  body:
      'One ratio runs this page: the weight of the water divided by the '
      'weight of the CEMENT. Not the total batch, not the aggregate, and not '
      'the other way up. Lower is stronger, which is the direction people get '
      'backwards because more water feels like it ought to help. It does help '
      'the concrete flow, and that is the trap: about 0.40 reaches something '
      'near 6,500 psi, and by 0.80 there is only about 2,000 left. So you get '
      'a smaller ratio by adding cement or by taking water out, and when the '
      'only problem is that the mix will not pour, the answer is a water '
      'reducer rather than a hose.',
  formulas: [
    ('The ratio', r'W/C = \frac{\text{water}}{\text{cement}}'),
    ('Low ratio', r'0.40 \approx 6{,}500\ \text{psi}'),
    ('High ratio', r'0.80 \approx 2{,}000\ \text{psi}'),
  ],
  figure: BriefFigure.mix,
  handbook: 'Handbook p. 125',
);

const exposureBrief = BriefSection(
  title: 'Strength and exposure are two questions',
  body:
      'Choosing a mix means answering two things that have nothing to do with '
      'each other. How strong must it be, which sets the water-cement ratio '
      'off the curve. And will this piece of concrete freeze while it is wet, '
      'which decides whether air is entrained, usually four to seven percent. '
      'Air is not a free upgrade: it buys freeze and thaw durability and it '
      'costs roughly a fifth of the strength, so a job that needs both has to '
      'start from a lower ratio to pay for it. Note that the question is '
      'whether THIS concrete freezes, not whether the city is cold: a garage '
      'deck and the footing buried under it get different mixes.',
  formulas: [
    ('Strength sets', r'W/C'),
    ('Exposure sets', r'\text{air, } 4\text{ to }7\%'),
    ('Air costs', r'\approx 20\%\ \text{of the strength}'),
  ],
  figure: BriefFigure.exposure,
  handbook: 'Handbook p. 125',
);

const curingBrief = BriefSection(
  title: 'Which way the percentage goes',
  body:
      'All of this page is one percentage applied to one strength, and every '
      'wrong answer in it is that percentage applied the wrong way round. Two '
      'habits fix it. First, decide before you touch the number whether the '
      'answer should come out BIGGER or smaller: going toward the smaller '
      'figure multiplies, coming back to the bigger one divides. Second, use '
      'the share you were given and not what is left over: ninety percent '
      'means multiply by 0.90, never by 0.10. The numbers worth carrying are '
      'that seven day strength runs near seventy percent of the twenty eight '
      'day figure, and that concrete allowed to dry early may keep only '
      'fifty five to sixty five percent of what it could have had.',
  formulas: [
    ('Seven days', r'f_{c,7} \approx 0.70\, f_{c,28}'),
    ('So the later one', r'f_{c,28} = \frac{f_{c,7}}{0.70}'),
    ('Dried out early', r'0.55 \text{ to } 0.65 \text{ of the best}'),
  ],
  figure: BriefFigure.curing,
  handbook: 'Handbook p. 125',
);

const fieldBrief = BriefSection(
  title: 'The cylinder is not the slab',
  body:
      'A test cylinder is cured in a laboratory under water. The structure it '
      'came from is cured by whoever is on site that week, and the difference '
      'is worth more than most changes to the mix. So the lab break is never '
      'the number to hold against the specification: take the curing off '
      'first, and compare what is LEFT. A pour kept wet for a fortnight might '
      'keep ninety five percent of its cylinder strength, while one stripped '
      'at three days into hot wind keeps around sixty. That gap is bigger '
      'than the gap between a good mix and a mediocre one, which is why '
      'curing is the cheapest strength on the job and the first thing a tight '
      'schedule gives away.',
  formulas: [
    ('What the slab gets', r'f_{c,\text{field}} = k \, f_{c,\text{lab}}'),
    ('Cured properly', r'k \approx 0.92 \text{ to } 0.95'),
    ('Dried out early', r'k \approx 0.60'),
  ],
  figure: BriefFigure.field,
  handbook: 'Handbook p. 125',
);

const weighingBrief = BriefSection(
  title: 'Three weighings, four numbers',
  body:
      'An aggregate sample gets weighed three ways: oven dry with the pores '
      'empty (A), saturated with the surface wiped dry (B), and hanging in '
      'water (C). Everything on this page is built from those three, and the '
      'differences matter. B minus C is the water the WHOLE particle pushed '
      'aside, pores included, which is what makes a specific gravity bulk. A '
      'minus C leaves the water-filled pores out of the volume, which makes '
      'it apparent, and apparent always comes out the largest of the three. '
      'Absorption is the water the pores hold divided by the DRY mass: over '
      'the saturated weight instead is the slip the lesson names.',
  formulas: [
    ('Bulk, oven dry', r'G_{sb} = \frac{A}{B - C}'),
    ('Bulk, saturated', r'G_{ssd} = \frac{B}{B - C}'),
    ('Apparent', r'G_{sa} = \frac{A}{A - C}'),
    ('Absorption', r'\frac{B - A}{A} \times 100'),
  ],
  figure: BriefFigure.weighing,
  handbook: 'Handbook p. 123',
);

const gradingBrief = BriefSection(
  title: 'One number for a whole curve',
  body:
      'A sieve analysis reports how much of a sand passes each standard '
      'sieve, and the fineness modulus squeezes that whole curve into one '
      'number: add up the CUMULATIVE percent retained on the standard sieves '
      'and divide by a hundred. Retained, not passing, and cumulative, not '
      'sieve by sieve. A higher modulus means COARSER, which reads backwards '
      'off the name, and a concrete sand is normally asked to fall between '
      '2.3 and 3.1. Remember what one number cannot do: two sands with the '
      'same modulus can have completely different curves, and a gap in the '
      'sizes leaves voids that have to be filled with paste.',
  formulas: [
    ('The modulus', r'FM = \frac{\sum \text{cumulative \% retained}}{100}'),
    ('A concrete sand', r'2.3 \le FM \le 3.1'),
    ('Higher means', r'\text{coarser}'),
  ],
  figure: BriefFigure.grading,
  handbook: 'Handbook p. 123',
);

const voidsBrief = BriefSection(
  title: 'Three bands and a bracket',
  body:
      'A compacted asphalt specimen is stone, binder and air, and every '
      'number on this page is one of those as a share of something else. Air '
      'voids are the air against the WHOLE specimen, which is what the two '
      'gravities give you: how far the compacted mix is from the same mix '
      'with no air in it. VMA is the air and the binder together, all the '
      'space between the stones however it is filled, and it is what the '
      'hundred minus the stone volume leaves. VFA is the binder as a share of '
      'that space, never of the whole mix. Design sits near four percent air, '
      'with enough VMA to carry a proper film of binder around every stone.',
  formulas: [
    ('Air voids', r'V_a = 100\,\frac{G_{mm} - G_{mb}}{G_{mm}}'),
    ('Space between stones', r'VMA = 100 - \frac{G_{mb} P_s}{G_{sb}}'),
    ('Filled with asphalt', r'VFA = 100\,\frac{VMA - V_a}{VMA}'),
  ],
  figure: BriefFigure.voids,
  handbook: 'Handbook p. 124',
);

const checkBrief = BriefSection(
  title: 'Four checks, no calculator',
  body:
      'Asphalt volumetrics are numbers that must agree with each other, and '
      'four checks catch nearly every slip before the arithmetic does. The '
      'theoretical maximum gravity is ALWAYS bigger than the bulk one, '
      'because it is the same materials with the air taken out, so a negative '
      'air void means the two were swapped. The VMA is always bigger than the '
      'air voids, since the air is only part of that space. The VFA is a '
      'share of the VMA and therefore stops at a hundred. And a VMA up near '
      'eighty is not void space at all: it is the stone volume, the term the '
      'formula was supposed to subtract.',
  formulas: [
    ('Always', r'G_{mm} > G_{mb}'),
    ('Always', r'VMA > V_a'),
    ('And', r'VFA \le 100\%'),
  ],
  figure: BriefFigure.check,
  handbook: 'Handbook p. 124',
);

const moistureBrief = BriefSection(
  title: 'One threshold in wood',
  body:
      'Moisture content in timber is the water divided by the OVEN DRY weight '
      'of the wood, never by the wet weight, which is why green timber can '
      'read well over a hundred percent: there can be more water than wood. '
      'The number matters against one threshold, the fiber saturation point '
      'at about thirty percent. Above it the cell walls are already full and '
      'the extra water sits loose in the cavities, so it can come and go and '
      'the timber is no stronger or weaker for it. Below it the water is in '
      'the walls themselves: drying shrinks the wood and stiffens and '
      'strengthens it, and wetting swells and softens it again.',
  formulas: [
    ('Moisture content', r'MC = \frac{W_{wet} - W_{OD}}{W_{OD}} \times 100'),
    ('The threshold', r'FSP \approx 30\%'),
    ('Below it', r'\text{drier} \Rightarrow \text{smaller and stronger}'),
  ],
  figure: BriefFigure.moisture,
  handbook: 'Handbook p. 129',
);

const mortarBrief = BriefSection(
  title: 'M, S, N, O',
  body:
      'Four mortar types, strongest to weakest, in an order that follows '
      'nothing you could work out: M, S, N, O. They are the every-other '
      'letters of MaSoN wOrK, which is the only reason anybody remembers '
      'them. Strength is not the whole story and the strongest is not the '
      'best: high strength mortars are stiffer to work with and less '
      'forgiving of movement, and a joint harder than the brick around it '
      'puts the cracking into the brick, which costs far more to put right. '
      'M goes below grade, S where there is lateral load or soil contact, N '
      'is general purpose above grade, and O is for soft old masonry indoors.',
  formulas: [
    ('Strongest to weakest', r'M > S > N > O'),
    ('The phrase', r'\text{MaSoN wOrK}'),
    ('And', r'\text{strength} \downarrow \Rightarrow \text{workability} \uparrow'),
  ],
  figure: BriefFigure.mortar,
  handbook: 'Handbook p. 130',
);

const factorBrief = BriefSection(
  title: 'The factors and their directions',
  body:
      'A wood design value is a published reference number multiplied by a '
      'string of adjustment factors, and what the exam asks is which way each '
      'one pushes. Nearly all of them are penalties: wet service, sustained '
      'heat, and size all take capacity away. The load duration factor is the '
      'exception, and the one to know cold. Wood carries MORE the more '
      'briefly it is loaded, so the ladder runs from 0.9 for a permanent load '
      'through 1.0 for normal occupancy, which is the case the reference '
      'values were quoted for, up to 1.25 for a week and 1.6 for wind or '
      'seismic. Shorter is always higher, which is the direction people get '
      'backwards.',
  formulas: [
    ('The chain', r'F\prime = F \times C_D \times C_M \times C_t \times \dots'),
    ('Wind or seismic', r'C_D = 1.6'),
    ('Permanent load', r'C_D = 0.9'),
  ],
  figure: BriefFigure.factor,
  handbook: 'Handbook p. 129',
);

const blendBrief = BriefSection(
  title: 'Two rules, and the direction picks',
  body:
      'A composite has a direction in it, and that is the whole of this page. '
      'Loaded ALONG the fibers, both materials are forced to stretch by the '
      'same amount, so their moduli add up weighted by volume: the additive '
      'rule, and a stiff composite. Loaded ACROSS them, the two sit one '
      'behind the other carrying the same stress, the soft matrix gives way, '
      'and the reciprocals add instead: always a smaller answer, usually not '
      'much more than the matrix on its own. The exam nearly always asks the '
      'parallel case. Density is different: it is a weighted average by '
      'volume whichever way the fibers run, because weight has no direction.',
  formulas: [
    ('Along the fibers', r'E_c = f_1 E_1 + f_2 E_2'),
    ('Across them', r'\frac{1}{E_c} = \frac{f_1}{E_1} + \frac{f_2}{E_2}'),
    ('Density, either way', r'\rho_c = f_1\rho_1 + f_2\rho_2'),
  ],
  figure: BriefFigure.blend,
  handbook: 'Handbook p. 123',
);

const isostrainBrief = BriefSection(
  title: 'Whichever one is shared',
  body:
      'Pulled along the fibers, the two materials are stuck together and have '
      'to stretch by the same amount. Equal STRAIN, so the stresses are not '
      'equal at all: stress is modulus times strain, and the stiff fiber can '
      'sit at many times the stress in the matrix. That is why a composite '
      'carrying a hundred megapascals overall can have four hundred in its '
      'fibers, and why fibers at a quarter of the volume carry almost all of '
      'the load. Turn the load across the fibers and it reverses: the same '
      'STRESS passes through both and the soft matrix does nearly all the '
      'moving. Whichever quantity is shared, the other one is not.',
  formulas: [
    ('Along: shared strain', r'\varepsilon_1 = \varepsilon_2'),
    ('So the stresses split', r'\sigma_1 = E_1\varepsilon,\; \sigma_2 = E_2\varepsilon'),
    ('Across: shared stress', r'\sigma_1 = \sigma_2'),
  ],
  figure: BriefFigure.isostrain,
  handbook: 'Handbook p. 123',
);

const galvanicBrief = BriefSection(
  title: 'The more active one is eaten',
  body:
      'Corrosion in a couple needs four things at once: two DIFFERENT metals, '
      'an electrolyte such as rainwater or damp soil, and an electrical path '
      'between them. Given all four, the more active metal of the pair '
      'becomes the anode and dissolves, and the nobler one is the cathode and '
      'is protected. No metal is safe or unsafe on its own: steel is '
      'protected beside aluminum and eaten beside copper. That is the whole '
      'of galvanizing, and of a sacrificial anode bolted to a hull. And it is '
      'the whole of the fix as well: take away any one of the four, usually '
      'the water or the path, and nothing happens at all.',
  formulas: [
    ('At the anode', r'M^0 \rightarrow M^{n+} + ne^-'),
    ('Active to noble', r'Mg,\; Zn,\; Al,\; \text{steel},\; Cu,\; Ti'),
    ('A cell needs', r'\text{two metals} + \text{water} + \text{a path}'),
  ],
  figure: BriefFigure.galvanic,
  handbook: 'Handbook p. 116',
);

const pickingBrief = BriefSection(
  title: 'Cross them off one column at a time',
  body:
      'A selection question hands you a table and a list of requirements, and '
      'the metal that wins any one column is rarely the one that passes them '
      'all. Copper conducts heat better than anything else on the page and is '
      'three times too heavy for a light part. Titanium survives seawater '
      'that eats everything and barely conducts at all. Steel is cheap and '
      'rusts. So take the requirements one at a time, in whatever order is '
      'quickest to check, and cross candidates off until one is left. Two '
      'outcomes are worth recognizing: when a requirement rules nothing out '
      'it is not doing any work, and when nothing passes, the specification '
      'is what needs changing.',
  formulas: [
    ('Copper', r'403\ \text{W/mK},\; 8{,}933\ \text{kg/m}^3'),
    ('Aluminum', r'236\ \text{W/mK},\; 2{,}698\ \text{kg/m}^3'),
    ('Steel, titanium', r'83.5\ \text{and}\ 22\ \text{W/mK}'),
  ],
  figure: BriefFigure.picking,
  handbook: 'Handbook p. 119',
);

const threeNumbersBrief = BriefSection(
  title: 'Density, weight, and the ratio',
  body:
      'Three properties and two multiplications tie them together, and the '
      'units tell you which is which. DENSITY is the mass packed into a cubic '
      'meter, so it is kilograms per cubic meter, and water is a thousand of '
      'them. SPECIFIC WEIGHT is what that cubic meter weighs, so it is '
      'newtons per cubic meter, and water is 9,810: multiply a density by g '
      'and you have it. SPECIFIC GRAVITY is the fluid held against water, so '
      'it has no units at all, and multiplying it by water\'s 9,810 gives the '
      'fluid\'s specific weight. Pressure formulas want the specific weight, '
      'because a pressure needs a force in it; feeding them a density leaves '
      'you a factor of g short.',
  formulas: [
    ('Weight from mass', r'\gamma = \rho g'),
    ('The ratio to water', r'SG = \frac{\rho}{\rho_w} = \frac{\gamma}{\gamma_w}'),
    ('Water', r'1{,}000\ \text{kg/m}^3,\quad 9{,}810\ \text{N/m}^3'),
  ],
  figure: BriefFigure.threeNumbers,
  handbook: 'Handbook p. 176',
);

const viscosityBrief = BriefSection(
  title: 'Speed over gap',
  body:
      'Viscosity turns a velocity GRADIENT into a shear stress, and the '
      'gradient is what matters rather than the speed on its own. Across a '
      'thin film with a straight-line profile that gradient is just the plate '
      'speed divided by the film thickness, so the oil and the speed multiply '
      'and the thickness divides: a thinner film drags harder, which is the '
      'part that reads backwards, and it is why a bearing runs on a film of '
      'thousandths. Two cautions. The thickness is almost always given in '
      'millimeters and the formula wants meters, which is a factor of a '
      'thousand. And the viscosity here is the DYNAMIC one in pascal '
      'seconds, never the kinematic one in meters squared a second.',
  formulas: [
    ('Newton\'s law', r'\tau = \mu \frac{dv}{dy}'),
    ('Across a thin film', r'\tau = \mu \frac{v}{\delta}'),
    ('The other viscosity', r'\nu = \frac{\mu}{\rho}'),
  ],
  figure: BriefFigure.viscosity,
  handbook: 'Handbook p. 176',
);

const capillaryBrief = BriefSection(
  title: 'Narrow climbs higher',
  body:
      'Surface tension pulls a liquid up the inside of a tube, and the weight '
      'of the column it has lifted stops it. The pull grows with the '
      'circumference and the weight grows with the AREA, so the diameter ends '
      'up underneath: half the bore is twice the climb, and the effect only '
      'matters in openings a fraction of a millimeter across, which is why it '
      'governs soil and concrete and not pipework. A heavier liquid climbs '
      'less, and one that pulls harder at the surface climbs more. The '
      'contact angle sits inside a cosine: past ninety degrees, which is a '
      'liquid that will not wet the glass, the cosine goes negative and the '
      'liquid is pushed DOWN the tube instead. Mercury does exactly that.',
  formulas: [
    ('Capillary rise', r'h = \frac{4\sigma \cos\beta}{\gamma d}'),
    ('Wets the glass', r'\beta < 90^\circ \Rightarrow h > 0'),
    ('Does not', r'\beta > 90^\circ \Rightarrow h < 0'),
  ],
  figure: BriefFigure.capillary,
  handbook: 'Handbook p. 176',
);

const depthBrief = BriefSection(
  title: 'Only depth and the liquid',
  body:
      'Pressure in a still liquid is the specific weight times the DEPTH of '
      'the point below the free surface, and nothing else is in it. Not the '
      'shape of the vessel, not how much liquid there is, not how wide the '
      'surface is: a thin pipe of water and a lake press equally hard at the '
      'same depth, which is why a header tank on a roof can pressurize a '
      'whole building and why the pressure on a dam is drawn as a triangle, '
      'nothing at the top and most at the bottom. Sideways makes no '
      'difference either: two points at the same depth in the same connected '
      'liquid are at the same pressure. Use the specific weight, not the '
      'density, or the answer is short by a factor of g.',
  formulas: [
    ('Pressure at depth', r'p = \gamma h = \rho g h'),
    ('Water', r'\gamma_w = 9{,}810\ \text{N/m}^3'),
    ('So five meters', r'\approx 49\ \text{kPa}'),
  ],
  figure: BriefFigure.depth,
  handbook: 'Handbook p. 177',
);

const manometerBrief = BriefSection(
  title: 'Start where you know, then walk',
  body:
      'A manometer is solved by walking it, not by recalling a formula. Start '
      'at the end where the pressure is known, usually the open one where the '
      'gauge pressure is zero, and step along the tube. Going DOWN a column '
      'adds its weight; coming UP one subtracts it; moving sideways in the '
      'same connected fluid changes nothing at all, because pressure depends '
      'on depth alone; and a stretch of air changes nothing worth counting, '
      'since air weighs almost nothing beside a liquid. Each fluid carries '
      'its OWN specific weight, so a meter of water adds about a thirteenth '
      'of what a meter of mercury would. And the higher column always stands '
      'on the lower-pressure side.',
  formulas: [
    ('Down a column', r'+\,\gamma h'),
    ('Up a column', r'-\,\gamma h'),
    ('A simple U-tube', r'P_0 = P_2 + \gamma_2 h_2 - \gamma_1 h_1'),
  ],
  figure: BriefFigure.manometer,
  handbook: 'Handbook p. 178',
);

const gaugeBrief = BriefSection(
  title: 'Which zero you are counting from',
  body:
      'Gauge pressure counts from atmospheric and absolute counts from a '
      'vacuum, so they differ by one constant: about 101.3 kilopascals of '
      'air. Anything open to the sky is at zero gauge on its surface, which '
      'is why the depth formula hands you a gauge pressure directly, and why '
      'a manometer with one open end reads one too. Civil work quotes gauge '
      'almost always, because the atmosphere presses on both sides of nearly '
      'everything we build and cancels itself out. Convert only when the '
      'problem says the word absolute, and remember that a gauge pressure can '
      'be negative, which is a vacuum, while an absolute one never can.',
  formulas: [
    ('The link', r'P_{abs} = P_{atm} + P_{gauge}'),
    ('The atmosphere', r'101.3\ \text{kPa} = 14.7\ \text{psi}'),
    ('Open to the air', r'P_{gauge} = 0'),
  ],
  figure: BriefFigure.gauge,
  handbook: 'Handbook p. 177',
);

const gateBrief = BriefSection(
  title: 'Two depths, not one',
  body:
      'A submerged gate has two depths in play and they are never the same '
      'one. The FORCE is the pressure at the CENTROID times the area, because '
      'the pressure at the centroid is the average over the face. But it does '
      'not act there: the pressure grows with depth, so the push is bottom '
      'heavy and the resultant sits below the middle, at the center of '
      'pressure. For a rectangle with its top at the surface that works out '
      'to two thirds of the way down, which is a result worth knowing by '
      'heart. The offset is the second moment over the centroid depth times '
      'the area, so it shrinks as the gate goes deeper: a gate far down is '
      'very nearly uniformly loaded. Force from the centroid, moment from the '
      'center of pressure.',
  formulas: [
    ('The force', r'F_R = \gamma h_C A'),
    ('Where it acts', r'y_{CP} = y_C + \frac{I_{xC}}{y_C A}'),
    ('A rectangle', r'I_{xC} = \frac{bh^3}{12}'),
  ],
  figure: BriefFigure.gate,
  handbook: 'Handbook p. 179',
);

const buoyancyBrief = BriefSection(
  title: 'What the water it shoves aside weighs',
  body:
      'The push on a submerged body is the weight of the fluid it displaces, '
      'and nothing else: not what the body is made of, not whether it is '
      'hollow. Hold that against the body\'s own weight. Push bigger and it '
      'rises, weight bigger and it sinks, equal and it hangs where it is, '
      'which is what a floating body has already arranged: it settles until '
      'it has shoved aside exactly its own weight. Two consequences worth '
      'carrying. A steel box floats and a steel block does not, because the '
      'box displaces far more water for the same steel. And an empty buried '
      'tank in wet ground is pushed UP, which is a real way for tanks to '
      'leave the ground they were buried in.',
  formulas: [
    ('The push', r'F_B = \gamma V_{displaced}'),
    ('Net', r'F_{net} = F_B - W'),
    ('Floating', r'F_B = W'),
  ],
  figure: BriefFigure.buoyancy,
  handbook: 'Handbook p. 179',
);

const continuityBrief = BriefSection(
  title: 'The same water, a smaller hole',
  body:
      'Whatever goes in has to come out, so the flow through every section of '
      'a pipe is the same and the speed rises exactly as much as the opening '
      'falls. The catch is that an opening goes as the SQUARE of a diameter '
      'or a side: halve the bore and the area quarters, so the speed '
      'quadruples, and a third of the bore is nine times the speed. Read the '
      'question carefully, because a change quoted as an AREA is a speed '
      'change in direct proportion with no squaring at all. Length never '
      'enters it: a longer pipe of the same bore carries the same water at '
      'the same speed, and what the length costs is pressure, through '
      'friction, which is a different equation.',
  formulas: [
    ('Flow', r'Q = Av'),
    ('Continuity', r'A_1 v_1 = A_2 v_2'),
    ('For a round pipe', r'\frac{v_2}{v_1} = \left(\frac{D_1}{D_2}\right)^2'),
  ],
  figure: BriefFigure.continuity,
  handbook: 'Handbook p. 180',
);

const bernoulliBrief = BriefSection(
  title: 'The three heads trade',
  body:
      'Bernoulli is an energy statement written in meters: pressure head, '
      'velocity head and elevation head add to the same total everywhere '
      'along a streamline, as long as there is no friction. So they trade '
      'against each other, and the trade is the part that feels backwards. '
      'Where a pipe narrows the water speeds up, the velocity head grows, and '
      'the PRESSURE falls. Where it opens out again the water slows and the '
      'pressure comes back. A venturi is that drop sold as an instrument. Two '
      'warnings: use continuity to get the velocity BEFORE you use Bernoulli, '
      'and the moment a problem mentions pipe length, roughness or head loss '
      'you need the energy equation instead, with its friction term.',
  formulas: [
    ('Bernoulli',
        r'\frac{P_1}{\gamma} + \frac{v_1^2}{2g} + z_1 = \frac{P_2}{\gamma} + \frac{v_2^2}{2g} + z_2'),
    ('Level pipe', r'P_2 = P_1 + \frac{\rho}{2}(v_1^2 - v_2^2)'),
    ('With friction', r'\dots + h_f'),
  ],
  figure: BriefFigure.bernoulli,
  handbook: 'Handbook p. 180',
);

const torricelliBrief = BriefSection(
  title: 'Only the head',
  body:
      'A tank open to the air, discharging to the air, with a surface that '
      'barely moves: the pressures cancel and the surface velocity drops out, '
      'and Bernoulli collapses to one line. The jet leaves at the root of '
      'twice g times the head, which is the same speed a stone would reach '
      'falling that far, and no wonder: it is the same energy trade. What is '
      'NOT in it is worth more than what is. Not the size of the hole, which '
      'decides how much comes out and not how fast. Not the width of the '
      'tank, nor how much water is behind it. A thin tube eight meters tall '
      'beats a broad pan half a meter deep, four times over. And the square '
      'root softens the head: four times the depth is twice the jet.',
  formulas: [
    ('Torricelli', r'v = \sqrt{2gh}'),
    ('Which came from', r'z_1 = \frac{v_2^2}{2g}'),
    ('Four times the head', r'\Rightarrow 2 \times \text{the speed}'),
  ],
  figure: BriefFigure.torricelli,
  handbook: 'Handbook p. 180',
);

const reynoldsBrief = BriefSection(
  title: 'Which band the flow is in',
  body:
      'The Reynolds number is the speed times the diameter over the kinematic '
      'viscosity, and what it buys you is not a number but a DECISION. Under '
      '2,100 the flow is laminar and the friction factor is simply 64 over '
      'the Reynolds number, with no diagram to read. Over 10,000 it is fully '
      'turbulent and the factor comes off the Moody diagram or out of '
      'Colebrook. Between the two it is transitional, uncertain, and no place '
      'to design. Water is so thin that anything moving at a sensible speed '
      'in a pipe you could crawl through is deeply turbulent, so a Reynolds '
      'number in the thousands for a water main usually means the diameter '
      'went in as millimeters.',
  formulas: [
    ('Reynolds', r'Re = \frac{\rho v D}{\mu} = \frac{vD}{\nu}'),
    ('Laminar', r'Re < 2{,}100 \Rightarrow f = \frac{64}{Re}'),
    ('Turbulent', r'Re > 10{,}000 \Rightarrow \text{Moody}'),
  ],
  figure: BriefFigure.reynolds,
  handbook: 'Handbook p. 181',
);

const darcyBrief = BriefSection(
  title: 'What the friction costs',
  body:
      'Darcy-Weisbach is four things multiplied: the friction factor, the '
      'length over the diameter, and the velocity head. Two of them behave as '
      'you would guess, since the length and the factor are in direct '
      'proportion, and two do not. The velocity is SQUARED, so twice the '
      'speed is four times the loss, which is why pipes are sized by '
      'velocity. And the diameter does more than the formula shows: at a '
      'fixed FLOW, doubling the bore quarters the velocity as well as halving '
      'the L over D, so the loss falls by about thirty times. One pipe size '
      'up is the cheapest head on any job. The factor here is the DARCY one; '
      'the Fanning factor is a quarter of it.',
  formulas: [
    ('Darcy-Weisbach', r'h_f = f \frac{L}{D} \frac{v^2}{2g}'),
    ('Laminar factor', r'f = \frac{64}{Re}'),
    ('At fixed flow', r'2D \Rightarrow \approx \frac{h_f}{32}'),
  ],
  figure: BriefFigure.darcy,
  handbook: 'Handbook p. 182',
);

const minorBrief = BriefSection(
  title: 'Add the pipe and the fittings',
  body:
      'The total head loss is the pipe friction PLUS every fitting, and each '
      'fitting is its own coefficient times the same velocity head, because '
      'the water is going the same speed through all of them. They are called '
      'minor losses and frequently are not minor: a globe valve at C = 10 can '
      'cost more than a hundred meters of the pipe it sits in. Three things '
      'go wrong with the addition, and they are the three wrong answers on '
      'the lesson\'s own problem: the fittings quoted alone, the friction '
      'quoted alone, and a total that has had the friction added to it twice. '
      'Count the fittings off the drawing one at a time, and label every '
      'number you write down.',
  formulas: [
    ('Each fitting', r'h = C \frac{v^2}{2g}'),
    ('The total', r'h_{total} = h_f + \Sigma C \frac{v^2}{2g}'),
    ('One velocity head', r'\text{serves them all}'),
  ],
  figure: BriefFigure.minor,
  handbook: 'Handbook p. 182',
);

const deflectionBrief = BriefSection(
  title: 'A jet pushes by being turned',
  body:
      'A jet delivers force by having its momentum changed, not by arriving '
      'somewhere. Run it through a sleeve and it leaves the same way at the '
      'same speed: nothing changed, no force, whatever the pressure or the '
      'size of the jet. Stop its motion along the jet with a flat plate and '
      'you take all of it, which is the rho A v squared in the lesson\'s own '
      'problem. Turn it right back on itself and you take that twice, which '
      'is where the wrong answer of 4,500 N comes from: correct for a cup, '
      'and double for a plate. Speed sits in the sum twice over, once in how '
      'much water arrives each second and once in what each kilogram '
      'carries, so twice the speed is four times the push. So is twice the '
      'bore, for the same reason on the area side.',
  formulas: [
    ('A jet turned through an angle', r'F = \rho Q v (1 - \cos\alpha)'),
    ('Flat plate', r'F = \rho A v^2'),
    ('Turned right back', r'F = 2\rho A v^2'),
  ],
  figure: BriefFigure.deflection,
  handbook: 'Handbook p. 186',
);

const thrustBrief = BriefSection(
  title: 'Where a main needs holding',
  body:
      'Pressure on its own pushes a straight pipe nowhere. It presses '
      'outward everywhere at once, and along the line those pushes face each '
      'other off, which is why a plain joint in a straight length of one '
      'bore needs nothing holding it at any pressure at all. A net force '
      'turns up only where the water is made to do something different: '
      'change direction at a bend, change speed at a reducer, or stop at a '
      'dead end or a shut valve. Those three get thrust blocks or restrained '
      'joints. The force is the pressure term plus the momentum term, and '
      'on a water main the pressure term is usually the far bigger of the '
      'two, which is why the mistake of leaving it out is so expensive.',
  formulas: [
    ('Each direction', r'F = PA + \rho Q v'),
    ('A straight length', r'\text{the two ends cancel}'),
    ('What leaves a force', r'\text{turn, change of bore, stop}'),
  ],
  figure: BriefFigure.thrust,
  handbook: 'Handbook p. 186',
);

const blockBrief = BriefSection(
  title: 'Which way a bend is shoved',
  body:
      'Write the bend as vectors and both halves of the force line up the '
      'same way: the water arriving still wants to carry on the way it came '
      'in, and the pressure on the inlet face pushes that way too, while the '
      'outlet leg pushes back along where the water is going. What is left '
      'runs along the inlet direction minus the outlet direction, and that '
      'always lands on the OUTSIDE of the turn, splitting the angle the two '
      'legs make and heading away from the corner. Never along one leg, '
      'never into the inside of the elbow. On a square bend the two '
      'components are equal, and the whole push is one of them times the '
      'root of two, not twice one of them.',
  formulas: [
    ('Which way', r'F \propto \hat{u}_{in} - \hat{u}_{out}'),
    ('A square bend', r'F_x = F_y = PA + \rho Q v'),
    ('Put together', r'F_R = F_x\sqrt{2}'),
  ],
  figure: BriefFigure.block,
  handbook: 'Handbook p. 186',
);

const meteringBrief = BriefSection(
  title: 'Which opening the meter meters on',
  body:
      'A venturi and an orifice plate are the same formula with a different '
      'coefficient in front, and in both of them every area is the SMALL '
      'one: the throat or the hole. The upstream pipe appears once, inside '
      'the ratio underneath, and never on its own. Metering on the pipe '
      'instead is the biggest single mistake in the lesson, and on a meter '
      'that halves the bore it makes the answer four times too large. The '
      'way to find the right opening on a drawing is the pair of pressure '
      'tappings, not the search for the narrowest thing in sight: a reducer '
      'or a valve can be narrower than the throat and it is measuring '
      'nothing, because nobody is reading a difference across it. The jet '
      'squeezes below the hole just past an orifice plate, and that squeeze '
      'is already paid for by the coefficient.',
  formulas: [
    ('Venturi', r'Q = C_v A_2 \sqrt{\frac{2gh}{1 - (A_2/A_1)^2}}'),
    ('Orifice', r'Q = C A_0 \sqrt{\frac{2gh}{1 - (A_0/A_1)^2}}'),
    ('The head', r'h = \frac{P_1 - P_2}{\gamma} + z_1 - z_2'),
  ],
  figure: BriefFigure.metering,
  handbook: 'Handbook p. 195',
);

const coefficientBrief = BriefSection(
  title: 'Which way a slip pushes the answer',
  body:
      'You never get to check a meter reading against the truth, so knowing '
      'which way each mistake moves the number is the whole defense. Every '
      'coefficient is below one, because it is there to bring the ideal '
      'formula down to what a real meter passes, so leaving one out or '
      'putting in a bigger one sends the answer up. So does anything that '
      'shrinks the correction underneath, since it sits under the line. '
      'Losing the 2 in front of g sends it down, though only by three tenths, '
      'because the loss happens under a square root. Leaving pressure in '
      'kilopascals sends it down by about thirty times, which is far enough '
      'to look ridiculous and be caught. And on a level meter the elevation '
      'terms change nothing at all.',
  formulas: [
    ('Every coefficient', r'C < 1'),
    ('Under the line', r'\text{smaller} \Rightarrow \text{bigger } Q'),
    ('A level meter', r'z_1 - z_2 = 0'),
  ],
  figure: BriefFigure.coefficient,
  handbook: 'Handbook p. 194',
);

const similitudeBrief = BriefSection(
  title: 'Froude or Reynolds',
  body:
      'Two flows are alike when the numbers that matter to them are alike, '
      'and which number matters follows from what is shaping the flow. Look '
      'for a free water surface. If there is one and the thing being studied '
      'happens at it, gravity is doing the shaping and the Froude number has '
      'to match: spillways, weirs, rivers, hulls. If there is no surface in '
      'it, gravity has nothing to pull against, and what is left is '
      'viscosity against momentum, which is the Reynolds number: pipe '
      'fittings, valves, submerged bodies, wind tunnels. At the same scale '
      'in the same fluid you cannot hold both at once, which is why a river '
      'model is run on Froude and its Reynolds mismatch is simply accepted, '
      'with the model made big enough to stay turbulent.',
  formulas: [
    ('Gravity', r'Fr = \frac{v}{\sqrt{gl}}'),
    ('Viscosity', r'Re = \frac{\rho v l}{\mu}'),
    ('Buckingham Pi', r'k = n - r'),
  ],
  figure: BriefFigure.similitude,
  handbook: 'Handbook p. 196',
);

const scalingBrief = BriefSection(
  title: 'What the law asks of the model',
  body:
      'Once the law is chosen it fixes the model speed, and the two laws '
      'pull opposite ways. Froude has the speed sitting over the square root '
      'of the length, so the speed follows the size by its square root: a '
      'model a twenty fifth the size runs at a fifth the speed. Reynolds has '
      'the speed multiplying the length, so to hold the product still the '
      'speed goes the other way by the whole ratio: a model a tenth the size '
      'must run ten times as fast. Neither law means faster or slower by '
      'itself, it depends which way the size went. And the Reynolds demand '
      'is often the end of a plan: ten times the speed through a small tank '
      'may be impossible, which is why those models get built oversized '
      'instead.',
  formulas: [
    ('Froude', r'\frac{v_m}{v_p} = \sqrt{\frac{l_m}{l_p}}'),
    ('Reynolds, same fluid', r'\frac{v_m}{v_p} = \frac{l_p}{l_m}'),
    ('At full size', r'\text{both ask the same}'),
  ],
  figure: BriefFigure.scaling,
  handbook: 'Handbook p. 196',
);

const bearingBrief = BriefSection(
  title: 'Reading a bearing off a plan',
  body:
      'A bearing is an instruction rather than a number: face the letter it '
      'starts with, turn that many degrees toward the letter it ends with, '
      'and stop. N 52 E means stand facing north and swing 52 degrees toward '
      'the east. Because it is measured off the nearer end of the meridian '
      'it is never more than a right angle, which means the angle on its own '
      'tells you almost nothing: the same 52 degrees appears in all four '
      'quadrants and the two letters are what separate them. A bearing near '
      '90 lies almost along the east and west line, and one near nothing '
      'lies almost along the meridian. Read both halves before converting '
      'anything.',
  formulas: [
    ('A bearing', r'\text{N or S}, \text{ angle} \le 90°, \text{ E or W}'),
    ('The meridian', r'\text{north is up the sheet}'),
    ('Back bearing', r'\text{same angle, both letters flipped}'),
  ],
  figure: BriefFigure.bearing,
  handbook: 'Handbook p. 309',
);

const azimuthBrief = BriefSection(
  title: 'Bearing to azimuth, by the clock',
  body:
      'An azimuth is the whole turn clockwise from north, 0 to 360, so which '
      'conversion applies is just a question of where the line sits in that '
      'turn. North-east is reached first and its azimuth IS the bearing '
      'angle. South-east stops short of due south, so it is 180 less the '
      'angle. South-west has carried on past due south, so it is 180 plus '
      'the angle, and this is the one the lesson warns about: taking it off '
      '360 instead throws the line to the opposite corner of the sheet. '
      'North-west is nearly the whole way round, so it is 360 less the '
      'angle. Picture a clock face with north at twelve and the list is not '
      'worth memorizing.',
  formulas: [
    ('NE', r'Az = \text{angle}'),
    ('SE and SW', r'Az = 180° \mp \text{angle}'),
    ('NW', r'Az = 360° - \text{angle}'),
  ],
  figure: BriefFigure.azimuth,
  handbook: 'Handbook p. 309',
);

const shotBrief = BriefSection(
  title: 'Three lengths out of one shot',
  body:
      'A shot up or down a slope makes a right triangle, and the three sides '
      'are three different answers. The instrument measures along its line '
      'of sight, and so does a tape dragged over the ground: that is the '
      'slope distance, and it is the hypotenuse, so it is the longest of the '
      'three every time. The plan wants the flat distance underneath it, '
      'which is the slope distance times the cosine and therefore always '
      'shorter. The upright at the far end is the difference in elevation, '
      'the slope distance times the sine. Every wrong answer on the '
      'lesson\'s own problem is one of these three swapped for another, and '
      'a flat distance that comes out LONGER than the slope distance means '
      'the cosine went underneath instead of on top.',
  formulas: [
    ('Flat, for the plan', r'HD = SD\cos\alpha'),
    ('Upright, the elevation', r'VD = SD\sin\alpha'),
    ('Always', r'HD \le SD'),
  ],
  figure: BriefFigure.shot,
  handbook: 'Handbook p. 309',
);

const sightBrief = BriefSection(
  title: 'One level plane over the whole setup',
  body:
      'A level\'s line of sight is dead horizontal, so over one setup it is a '
      'single flat plane hanging above the ground, and a rod reading is '
      'nothing more than how far the ground at that rod sits below it. Two '
      'things follow and both are worth more than the formula. The BIGGER '
      'reading is the LOWER point, which catches most sign errors before '
      'they happen. And two equal readings mean two points at the same '
      'elevation, which is how a level checks a slab or a row of bases with '
      'no arithmetic at all. The height of instrument is just where that '
      'plane sits: add the backsight to the elevation you know, then take '
      'the foresight off it to get the one you want.',
  formulas: [
    ('Up to the plane', r'HI = \text{Elev} + BS'),
    ('Back down from it', r'\text{Elev} = HI - FS'),
    ('The check', r'\text{bigger reading} \Rightarrow \text{lower ground}'),
  ],
  figure: BriefFigure.sightLine,
  handbook: 'Handbook p. 309',
);

const runBrief = BriefSection(
  title: 'Three kinds of point in a run',
  body:
      'Count the instruments that can see the rod and the bookkeeping tells '
      'itself. One instrument, at the start: a backsight, taken on the only '
      'elevation you already know, and added. One instrument, at the end: a '
      'foresight, taken on the point you want, and subtracted. Two '
      'instruments: a turning point, read forward from the old setup to fix '
      'its elevation and then back from the new one to fix the new height of '
      'instrument. That second reading is the part people drop, and dropping '
      'it means carrying the old height of instrument forward, which is the '
      'lesson\'s own trap and its 252.67. A run has exactly one backsight '
      'point at the start, exactly one foresight point at the end, and a '
      'turning point everywhere the level moved.',
  formulas: [
    ('Start', r'BS \text{ on a known point, added}'),
    ('End', r'FS \text{ on the wanted point, subtracted}'),
    ('Between', r'\text{turning point: FS then BS}'),
  ],
  figure: BriefFigure.runRoles,
  handbook: 'Handbook p. 309',
);

const closureBrief = BriefSection(
  title: 'What a loop may be out by',
  body:
      'Run a loop back to the benchmark it started from and the elevation '
      'you compute will not be the elevation you started with. The gap is '
      'the misclosure, and whether it is acceptable depends on two things: '
      'the class of work, which sets the constant, and the length of the '
      'run, which enters under a square root. That root is the part worth '
      'remembering. Four times the distance is only twice the allowance, '
      'because errors in a long run cancel as often as they pile up. Below a '
      'mile it works the other way and tightens the allowance instead. A '
      'tight constant on a long run can allow less than a loose one on a '
      'short run, so work out both sides before deciding. If the misclosure '
      'is bigger than the allowance, the run is done again.',
  formulas: [
    ('The gap', r'\text{misclosure} = \text{computed} - \text{known}'),
    ('What is allowed', r'C\sqrt{M}'),
    ('So', r'4M \Rightarrow 2\times \text{ the allowance}'),
  ],
  figure: BriefFigure.closure,
  handbook: 'Handbook p. 309',
);

const latDepBrief = BriefSection(
  title: 'How far north, how far east',
  body:
      'A course of a traverse is turned into two numbers: the latitude, '
      'which is how far north it went, and the departure, which is how far '
      'east. Latitude takes the cosine of the azimuth because north is where '
      'the azimuth is measured from, and departure takes the sine. The two '
      'sines and cosines are desk work. The two SIGNS are not, and they are '
      'where the damage happens, because a sign error produces a perfectly '
      'believable pair of numbers that puts the next station in the wrong '
      'quarter of the county. The quadrant settles both: north-east both '
      'plus, south-east latitude minus, south-west both minus, north-west '
      'departure minus. A closed traverse has to run through more than one '
      'quarter, because latitudes that are all positive can never add to '
      'nothing.',
  formulas: [
    ('North and south', r'\text{Lat} = L\cos\theta'),
    ('East and west', r'\text{Dep} = L\sin\theta'),
    ('Closed', r'\Sigma \text{Lat} = 0, \; \Sigma \text{Dep} = 0'),
  ],
  figure: BriefFigure.latDep,
  handbook: 'Handbook p. 309',
);

const compassBrief = BriefSection(
  title: 'Spreading the closure by length',
  body:
      'A traverse never closes exactly, and the compass rule is the ordinary '
      'way of tidying it up. Its one assumption is that the error crept in '
      'evenly along the way, so each course is handed the total error times '
      'its own length over the whole perimeter: the longest course takes the '
      'largest share. Not the course that covered the most latitude, not an '
      'equal share each, and never the whole closure dumped on the one '
      'course that felt wrong in the field. If you actually know which '
      'course is bad, the answer is to measure it again rather than to '
      'adjust it. And the correction always carries the opposite sign to the '
      'error: a traverse that drifted north gets pushed south.',
  formulas: [
    ('Each course', r'\text{Corr}_i = -E \times \frac{L_i}{\Sigma L}'),
    ('Longest course', r'\text{biggest share}'),
    ('Sign', r'\text{opposite to the drift}'),
  ],
  figure: BriefFigure.compass,
  handbook: 'Handbook p. 309',
);

const precisionBrief = BriefSection(
  title: 'Why precision is a ratio',
  body:
      'The closing gap is the two sums put together the way any two '
      'perpendicular things are put together, under a square root, so it '
      'comes out bigger than either sum and smaller than the two added. '
      'Then it is divided by the whole length the traverse ran, and written '
      'as one over something. That division is the part that matters: the '
      'gap on its own says nothing about the quality of the work. A '
      'centimeter out around a small lot can be worse than thirty '
      'centimeters out around three kilometers of control. Double the gap '
      'and double the distance and the ratio has not moved, which is why a '
      'specification can ask for 1 in 10,000 and mean the same thing on '
      'every job. The shape of the figure never comes into it.',
  formulas: [
    ('The gap', r'E = \sqrt{E_L^2 + E_D^2}'),
    ('The ratio', r'\frac{E}{\Sigma L} = \frac{1}{N}'),
    ('Bigger N', r'\text{better work}'),
  ],
  figure: BriefFigure.precision,
  handbook: 'Handbook p. 309',
);

const methodBrief = BriefSection(
  title: 'Which of the three methods',
  body:
      'The ground decides. Straight sides between corners you have '
      'coordinates for: the coordinate method, and it is EXACT, however '
      'irregular the figure and however many sides it has. A boundary that '
      'wanders, a creek or a wetland edge: run a baseline and measure '
      'offsets off it at a constant interval, and then the count of offsets '
      'decides which rule. Simpson fits a parabola across every PAIR of '
      'intervals, so it needs an even number of intervals, which is an odd '
      'number of offsets. Odd count, use Simpson and get a better answer on '
      'a curve. Even count, Simpson does not apply at all and the '
      'trapezoidal rule is what is left.',
  formulas: [
    ('Corners', r'A = \tfrac{1}{2}\left|\sum (x_i y_{i+1} - x_{i+1} y_i)\right|'),
    ('Odd offsets', r'\text{Simpson: } \tfrac{w}{3}(1,4,2,\dots,1)'),
    ('Even offsets', r'\text{trapezoidal}'),
  ],
  figure: BriefFigure.method,
  handbook: 'Handbook p. 310',
);

const weightsBrief = BriefSection(
  title: 'The weights are the rule',
  body:
      'Both offset rules have the same shape: multiply every offset by '
      'something, add them up, multiply by the interval. The list of '
      'somethings is the only difference. The trapezoidal rule halves the '
      'two ENDS and takes everything between them whole, because a middle '
      'offset is shared by the strip on each side of it while an end offset '
      'belongs to one strip. Simpson takes the ends once and then alternates '
      'four and two: the middle of each parabola carries it, and the offsets '
      'where one parabola hands over to the next are counted for both. One, '
      'four, two, four, one. If the pattern does not end on a one with a '
      'four before it, something has been miscounted.',
  formulas: [
    ('Trapezoidal', r'\tfrac{1}{2}, 1, 1, \dots, \tfrac{1}{2}'),
    ('Simpson', r'1, 4, 2, 4, \dots, 1'),
    ('Then', r'\times w, \text{ and } \div 3 \text{ for Simpson}'),
  ],
  figure: BriefFigure.weights,
  handbook: 'Handbook p. 310',
);

const shoelaceBrief = BriefSection(
  title: 'The formula does not check the listing',
  body:
      'Area by coordinates is exact, and that is what makes it dangerous: it '
      'returns a tidy number for any list of coordinates handed to it, '
      'including lists that are not the parcel. Two things go wrong and '
      'neither shows in the arithmetic. Corners listed out of order draw a '
      'bowtie, and the sum comes back as the difference between two loops '
      'rather than the area of anything. A corner left out draws a smaller '
      'figure that closes perfectly well and gives an area that is simply '
      'too small. Walking the boundary backwards is fine: the sum turns '
      'negative and the absolute value is there for exactly that. Plot the '
      'listing before trusting it.',
  formulas: [
    ('Round the boundary', r'A = \tfrac{1}{2}\left|\sum (x_i y_{i+1} - x_{i+1} y_i)\right|'),
    ('Close it', r'\text{last corner pairs back to the first}'),
    ('Either direction', r'\text{the absolute value covers it}'),
  ],
  figure: BriefFigure.shoelace,
  handbook: 'Handbook p. 310',
);

const endAreaBrief = BriefSection(
  title: 'End areas against the prismoid',
  body:
      'Both volume formulas take the sections and the length between them, '
      'and they disagree for one reason. The average end area method assumes '
      'the section runs straight from one end to the other, which is the '
      'same as assuming the middle of the run is the average of the two '
      'ends. The prismoidal formula asks what the middle section actually '
      'is. So compare the two: a middle standing ABOVE the average of the '
      'ends means the prismoidal answer is bigger, a middle sagging BELOW it '
      'means the end area answer is, and a middle sitting exactly on it '
      'means the two agree to the digit. A fill closing to a point sags a '
      'long way below, which is the overestimate the end area method is '
      'known for, and a constant section or an even taper sits right on the '
      'line, where the end area method is not an approximation at all.',
  formulas: [
    ('End areas', r'V = \frac{L}{2}(A_1 + A_2)'),
    ('Prismoidal', r'V = \frac{L}{6}(A_1 + 4A_m + A_2)'),
    ('They agree when', r'A_m = \frac{A_1 + A_2}{2}'),
  ],
  figure: BriefFigure.endArea,
  handbook: 'Handbook p. 309',
);

const stationBrief = BriefSection(
  title: 'Station by station, then add',
  body:
      'The end area formula knows about two sections and the distance '
      'between them, and nothing in it objects if those two are a thousand '
      'feet apart with a hill in between. Used once across a whole run it '
      'reports whatever the two end sections happen to suggest: a hump '
      'between them goes unbooked, a saddle gets paid for twice, and a run '
      'that starts and finishes at nothing comes out as no dirt at all, '
      'which is the lesson\'s own trap. Work every pair of adjacent stations '
      'separately and add the segments up. The one case where skipping is '
      'safe is a section that climbs evenly the whole way, because then the '
      'ends already carry the story. And a station is a hundred feet: 1+00 '
      'is 100, 2+00 is 200.',
  formulas: [
    ('Each segment', r'V_i = \frac{L_i}{2}(A_i + A_{i+1})'),
    ('Then', r'V = \Sigma V_i'),
    ('A station', r'1{+}00 = 100 \text{ ft}'),
  ],
  figure: BriefFigure.stations,
  handbook: 'Handbook p. 309',
);

const solidBrief = BriefSection(
  title: 'All of it, half of it, a third of it',
  body:
      'Carry the section the whole length to make a box around the solid, '
      'then ask what the far end does. Nothing changes and the solid IS the '
      'box: area times length. It closes down to an EDGE and the solid is '
      'half the box, because the section falls away evenly, which is exactly '
      'what the end area formula gives with one section at zero. It closes '
      'to a POINT and the solid is a third, because the section is lost in '
      'two directions at once and falls away as a square: that is the '
      'pyramid formula, base times height over three, and it holds whether '
      'the base is round or square. The gap between the half and the third '
      'is the whole of the end area method\'s overestimate on a taper.',
  formulas: [
    ('Constant', r'V = A L'),
    ('To an edge', r'V = \tfrac{1}{2} A L'),
    ('To a point', r'V = \tfrac{1}{3} A h'),
  ],
  figure: BriefFigure.solidShare,
  handbook: 'Handbook p. 309',
);

const cogoBrief = BriefSection(
  title: 'Forward one way, inverse the other',
  body:
      'Coordinate work runs in two directions on the same two formulas. '
      'FORWARD takes a point you hold and a course you measured and gives '
      'you a point you did not have: the length times the sine of the '
      'azimuth is how far east it went, the length times the cosine is how '
      'far north, and both are added to the point you started from. INVERSE '
      'takes two points you hold and gives back the course between them: the '
      'distance is the hypotenuse of the two differences and the direction '
      'is their arctangent. Count the points that already have coordinates '
      'and the job tells you which it is. Most real work is one of each: '
      'inverse to find out where a line points, then forward to put '
      'something new along it.',
  formulas: [
    ('Forward', r'E_2 = E_1 + L\sin Az, \; N_2 = N_1 + L\cos Az'),
    ('Inverse', r'L = \sqrt{\Delta E^2 + \Delta N^2}'),
    ('And', r'Az = \tan^{-1}(\Delta E / \Delta N)'),
  ],
  figure: BriefFigure.cogo,
  handbook: 'Handbook p. 310',
);

const pairBrief = BriefSection(
  title: 'Easting first, northing second',
  body:
      'A coordinate pair is two numbers and an agreement about which is '
      'which. Surveying writes the easting first and the northing second, '
      'across and then up, the same order as x and then y. Plenty of field '
      'books, deeds and older records write them the other way round, and a '
      'pair read backwards lands on the far side of the diagonal and then '
      'behaves perfectly well: every distance and direction computed from it '
      'comes out as a believable number for the wrong point. When the two '
      'numbers are far apart the error is obvious. When they are close it is '
      'small enough to survive a glance and large enough to put a wall on '
      'the wrong side of a line. Label the columns E and N, and plot the '
      'point.',
  formulas: [
    ('The pair', r'(E, N)'),
    ('Easting', r'\text{across, the x of the grid}'),
    ('Northing', r'\text{up, the y of the grid}'),
  ],
  figure: BriefFigure.pair,
  handbook: 'Handbook p. 310',
);

const arctanBrief = BriefSection(
  title: 'The calculator only knows half the compass',
  body:
      'An arctangent of one number returns something between minus a right '
      'angle and a right angle. That is half the compass, and an azimuth '
      'needs all of it, so the other half has to come from the SIGNS of the '
      'two differences. A negative northing difference means the line runs '
      'south, and every southbound line has an azimuth between 90 and 270: '
      'add 180. North and west takes 360. North and east is the one quarter '
      'the calculator gets right by itself. The trap is that the two minus '
      'signs of a south-west line cancel inside the division, so the '
      'calculator hands back a small positive number that looks entirely '
      'usable and is 180 degrees wrong. A negative answer is never an '
      'azimuth: azimuths run from 0 to 360.',
  formulas: [
    (r'\Delta N > 0, \Delta E > 0', r'Az = \tan^{-1}(\Delta E/\Delta N)'),
    (r'\Delta N < 0', r'Az = 180° + \tan^{-1}(\Delta E/\Delta N)'),
    (r'\Delta N > 0, \Delta E < 0', r'Az = 360° + \tan^{-1}(\Delta E/\Delta N)'),
  ],
  figure: BriefFigure.arctan,
  handbook: 'Handbook p. 310',
);

const roadCurveBrief = BriefSection(
  title: 'Six lengths on one curve',
  body:
      'A circular curve is fixed by two numbers, the radius and the angle the '
      'road turns through, and everything else is worked out of those. The '
      'TANGENT runs from the PC out to the PI, along the line the road was on '
      'before it started turning, and the second tangent from the PI to the '
      'PT is the same length. The CURVE LENGTH is the arc itself, which is '
      'the road, and it is what the stationing runs along: never out through '
      'the PI. The LONG CHORD cuts straight across from PC to PT. The '
      'EXTERNAL measures from the PI in to the middle of the arc, which is '
      'how far the road misses the corner by, and the MIDDLE ORDINATE '
      'measures from the middle of the chord out to the same point. Mistaking '
      'the arc for the tangent is the confusion the lesson names twice.',
  formulas: [
    ('Out to the PI', r'T = R\tan\frac{I}{2}'),
    ('Round the arc', r'L = \frac{\pi R I}{180}'),
    ('Across, and the two bulges', r'LC = 2R\sin\frac{I}{2}, \; E, \; M'),
  ],
  figure: BriefFigure.roadCurve,
  handbook: 'Handbook p. 302',
);

const degreeBrief = BriefSection(
  title: 'Radius one way, degree the other',
  body:
      'A curve gets quoted two ways and they run in opposite directions. The '
      'RADIUS is a length, and a bigger one is a gentler curve. The DEGREE '
      'OF CURVE is an angle, the one that a hundred feet of arc turns '
      'through, so a bigger one is a SHARPER curve. Their product is always '
      '5,729.58, which is simply the radius whose hundred foot arc turns '
      'through one degree, so either number gives the other and comparing a '
      'curve quoted one way against a curve quoted the other is a single '
      'division. Degree of curve suits laying a curve out in the field by '
      'deflection angles, and the radius suits coordinate work, so the same '
      'drawing often carries both.',
  formulas: [
    ('Either way', r'D = \frac{5{,}729.58}{R}'),
    ('So', r'D \times R \approx 5{,}730'),
    ('Sharper means', r'\text{small } R, \text{ large } D'),
  ],
  figure: BriefFigure.degreeOfCurve,
  handbook: 'Handbook p. 302',
);

const tangentOffsetBrief = BriefSection(
  title: 'Two elevations at one station',
  body:
      'A vertical curve is a parabola hung between two straight grades, and at '
      'any station there are TWO elevations to be had. The grade line produced '
      'from the PVC gives one, and at the middle of the curve that line is the '
      'PVI elevation, because the PVI is simply where the two straight grades '
      'meet. The road itself gives the other. The gap between them starts at '
      'nothing at the PVC, grows as the SQUARE of the distance from it, and is '
      'largest under the PVI. Which way the road bends off its incoming grade '
      'is decided by the sign of the grade CHANGE: down to a lower grade and '
      'the road runs below the line, up to a higher one and it runs above, '
      'whether or not the road ever crests or sags. Reading the tangent '
      'elevation where the question wanted the road is the mistake this lesson '
      'is built around.',
  formulas: [
    ('On the grade line', r'Y = Y_{PVC} + g_1 x'),
    ('On the road', r'Y = Y_{PVC} + g_1 x + \frac{g_2 - g_1}{2L}x^2'),
    ('The gap under the PVI', r'E = \frac{A L}{8}'),
  ],
  figure: BriefFigure.tangentOffset,
  handbook: 'Handbook p. 301',
);

const highPointBrief = BriefSection(
  title: 'Where the road turns around',
  body:
      'The road stops climbing, or stops falling, where the grade it arrived '
      'with has been used up. That point is measured from the PVC and it leans '
      'toward the SHALLOWER of the two grades: on a curve from plus 4 to minus '
      '2, two thirds of the way along. It sits halfway, under the PVI, only '
      'when the two grades are equal and opposite, which is the case common '
      'enough to make the midpoint a habit and wrong the rest of the time. '
      'When both grades run the same way the formula returns a distance '
      'outside 0 to L, and that is it telling you the turning point is off the '
      'curve: the road simply climbs, or falls, from end to end. The rate K is '
      'a different quantity entirely, the feet of curve bought per percent of '
      'grade change, and a bigger K is a gentler curve. K is not a distance '
      'along the road.',
  formulas: [
    ('From the PVC', r'x_m = \frac{-g_1 L}{g_2 - g_1}'),
    ('The grade change', r'A = |g_1 - g_2|'),
    ('The rate, not a distance', r'K = \frac{L}{A}'),
  ],
  figure: BriefFigure.highPoint,
  handbook: 'Handbook p. 301',
);

const wettedBrief = BriefSection(
  title: 'What the water is rubbing against',
  body:
      'Manning\'s equation runs on the hydraulic radius, the flow AREA divided '
      'by the WETTED PERIMETER, and the perimeter is where the mistakes live. '
      'It is the length of boundary the water is in contact with, so two '
      'things are never in it: the free water surface, because the top is open '
      'to the air and air does not hold water back, and anything above the '
      'water line, however tall the wall is built. For a rectangle that leaves '
      'the bed plus TWICE the depth, one wall on each side. For a trapezoid it '
      'is the bed plus both sides measured ALONG the slope, which is longer '
      'than the depth. For a pipe running full there is no free surface at '
      'all, so the whole circle counts. The hydraulic radius is not a radius '
      'of anything: it is area per unit of rubbing, and more of it means '
      'faster water.',
  formulas: [
    ('Area per unit of rubbing', r'R_H = \frac{A}{P}'),
    ('A rectangle', r'P = b + 2y'),
    ('A trapezoid', r'P = b + 2y\sqrt{1 + z^2}'),
    ('A pipe running full', r'R_H = \frac{D}{4}'),
  ],
  figure: BriefFigure.wetted,
  handbook: 'Handbook p. 297',
);

const manningBrief = BriefSection(
  title: 'What actually sets the speed',
  body:
      'Manning\'s equation is one line with three things in it that a channel '
      'can differ by, and they do not pull equally. ROUGHNESS sits underneath, '
      'so it acts in full: concrete at 0.013 against bare earth at 0.025 is '
      'nearly twice the velocity, and the ratio is the roughnesses the other '
      'way up. SLOPE is under a square root, so four times the grade buys only '
      'twice the speed, which is why steepening a sewer is an expensive way to '
      'buy capacity. The HYDRAULIC RADIUS is to the two thirds power, and it '
      'rewards a section that holds a lot of water against not much boundary: '
      'deep and narrow beats wide and shallow at the same flow area. One '
      'consequence is worth memorizing. A pipe running half full has the same '
      'hydraulic radius as the same pipe running full, a quarter of the '
      'diameter, so it carries half the water at exactly the same velocity.',
  formulas: [
    ('The velocity', r'v = \frac{K}{n} R_H^{2/3} S^{1/2}'),
    ('Roughness, in full', r'\frac{v_1}{v_2} = \frac{n_2}{n_1}'),
    ('Slope, under a root', r'4S \Rightarrow 2v'),
    ('Full or half full', r'R_H = \frac{D}{4} \text{ either way}'),
  ],
  figure: BriefFigure.manning,
  handbook: 'Handbook p. 297',
);

const unitFactorBrief = BriefSection(
  title: 'The only place the units show up',
  body:
      'Manning\'s equation carries a constant in front of it that is nothing '
      'but a unit conversion. In meters it is 1.0, which is to say there is '
      'nothing to convert. In feet it is 1.486, and leaving it out makes every '
      'answer a third too small, which is the trap the lesson names first. '
      'What decides it is the units the LENGTHS are in, and nothing else: the '
      'roughness n is dimensionless and is the same number in both systems, '
      'the slope is a rise over a run and has no units either, and the units '
      'somebody wants the answer reported in have no bearing at all. Work the '
      'equation in the units of the drawing and convert the answer once at the '
      'end. Inches and millimeters are not units the equation takes, so a '
      'drawing in either gets fixed before anything else happens, and a pipe '
      'diameter left in inches is the usual way that goes wrong.',
  formulas: [
    ('In feet', r'K = 1.486'),
    ('In meters', r'K = 1.0'),
    ('Dimensionless, both ways', r'n, \; S'),
  ],
  figure: BriefFigure.unitFactor,
  handbook: 'Handbook p. 297',
);

const froudeBrief = BriefSection(
  title: 'Two speeds, and which one wins',
  body:
      'The Froude number is not a piece of vocabulary, it is a race. The top '
      'of the fraction is how fast the water is moving. The bottom is how fast '
      'a ripple travels over still water of that depth, the square root of g '
      'times the depth, and nothing else sets it. When the ripple is the '
      'quicker of the two, a disturbance can work its way UPSTREAM: the flow '
      'is SUBCRITICAL, deep and tranquil, and a gate or a weir far downstream '
      'is felt above it. When the water is quicker, nothing gets back up and '
      'the flow is SUPERCRITICAL, shallow and rapid, which is what a spillway '
      'or a steep chute produces. When they are equal the upstream edge of a '
      'ring stands still, and the depth is the critical depth. Getting the '
      'number right and the label backward is the mistake this lesson names, '
      'and it stops happening once the fraction is read as a race.',
  formulas: [
    ('The race', r'Fr = \frac{v}{\sqrt{g y}}'),
    ('News gets upstream', r'Fr < 1 \text{: subcritical}'),
    ('Nothing gets upstream', r'Fr > 1 \text{: supercritical}'),
  ],
  figure: BriefFigure.froude,
  handbook: 'Handbook p. 296',
);

const criticalBrief = BriefSection(
  title: 'The depth that needs the least energy',
  body:
      'Draw the specific energy of a flow against the depth it is running at '
      'and you get a curve with two arms and a nose. Every energy above the '
      'minimum can be carried at TWO depths, one deep and slow on the upper '
      'arm and one shallow and fast on the lower one, and the nose between '
      'them is the CRITICAL DEPTH, the depth at which this flow gets by on the '
      'least energy it possibly can. For a rectangular channel that depth '
      'comes out of the flow per unit width and nothing else: q to the two '
      'thirds power, so twice the flow raises it by about 1.6 times and twice '
      'the width lowers it by the same factor. The slope, the lining, the '
      'length of the channel and the depth the water happens to be running at '
      'do not appear and do not move it. What they move is where the flow '
      'sits on the curve, which is the flow regime, and that is a different '
      'question.',
  formulas: [
    ('Rectangular channel', r'y_c = \left(\frac{q^2}{g}\right)^{1/3}'),
    ('Flow per unit width', r'q = \frac{Q}{B}'),
    ('At the nose', r'E_{min} = 1.5\,y_c'),
    ('Any shape', r'\frac{Q^2}{g} = \frac{A^3}{T}'),
  ],
  figure: BriefFigure.criticalDepth,
  handbook: 'Handbook p. 296',
);

const hydraulicJumpBrief = BriefSection(
  title: 'What crosses the jump and what does not',
  body:
      'A hydraulic jump runs one way only, from supercritical to '
      'subcritical: fast shallow water arrives, a churning roller stands in '
      'the channel, and slow deep water leaves. The DISCHARGE comes through '
      'unchanged, because nothing is added or taken away, and so does the '
      'MOMENTUM FUNCTION, which is what the conjugate depth formula is built '
      'from. The ENERGY does not: a jump is turbulent and throws energy away '
      'as heat and noise, which is precisely why one is built at the foot of '
      'a spillway, where the problem is that the water is carrying too much. '
      'Solving a jump with an energy balance is the classic way to get it '
      'wrong. The depth goes up, the velocity comes down, and the Froude '
      'number crosses one on the way, which is the definition of a jump '
      'rather than a consequence of it.',
  formulas: [
    ('Conjugate depth', r'y_2 = \frac{y_1}{2}\left(-1 + \sqrt{1 + 8Fr_1^2}\right)'),
    ('What balances', r'M = \frac{y^2}{2} + \frac{q^2}{gy}'),
    ('What is lost', r'\Delta E = E_1 - E_2 > 0'),
  ],
  figure: BriefFigure.hydraulicJump,
  handbook: 'Handbook p. 297',
);

const weirBrief = BriefSection(
  title: 'The shape of the hole picks the formula',
  body:
      'A weir measures flow by how deep the water stands above its crest, and '
      'three formulas sit next to each other on the handbook page. Which one '
      'applies is decided by the opening and nothing else. A crest running '
      'wall to wall is SUPPRESSED and takes C times L times H to the three '
      'halves. A crest that stops short of the walls is CONTRACTED: the water '
      'curls in around each end, so a tenth of the head comes off each side '
      'and the length used is L minus 0.2H. A V-NOTCH has no crest length at '
      'all, and takes C times H to the five halves. The coefficients are '
      'different for each shape AND for each unit system: a rectangular weir '
      'takes 3.33 in feet and 1.84 in meters, a 90 degree V-notch 2.54 and '
      '1.40. Reaching for the wrong exponent is the trap both of this '
      'lesson\'s weir problems name.',
  formulas: [
    ('Wall to wall', r'Q = C\,L\,H^{3/2}'),
    ('Stopping short', r'Q = C\,(L - 0.2H)\,H^{3/2}'),
    ('A 90 degree V', r'Q = C\,H^{5/2}'),
  ],
  figure: BriefFigure.weirShape,
  handbook: 'Handbook p. 297',
);

const exponentBrief = BriefSection(
  title: 'What an exponent is really telling you',
  body:
      'The power on the head is a SENSITIVITY, and reading it that way makes '
      'a whole class of question answerable without arithmetic. Three halves '
      'means that doubling the head multiplies the flow by 2 to the three '
      'halves, about 2.8. Five halves means doubling it multiplies the flow '
      'by about 5.7. Halving the head cuts them by the same factors the other '
      'way, to about a third and about a sixth. Only the RATIO the head '
      'changed by matters, never where it started, and the crest length sits '
      'outside the power so it scales the flow without ever changing the '
      'response. That steepness is why a V-notch is what gets installed to '
      'measure a small flow well, and why it runs out of range so quickly '
      'when the flow comes up.',
  formulas: [
    ('A flat crest', r'2H \Rightarrow 2^{3/2} \approx 2.8\,Q'),
    ('A V-notch', r'2H \Rightarrow 2^{5/2} \approx 5.7\,Q'),
    ('Only the ratio counts', r'\frac{Q_2}{Q_1} = \left(\frac{H_2}{H_1}\right)^{n}'),
  ],
  figure: BriefFigure.weirExponent,
  handbook: 'Handbook p. 297',
);

const hazenBrief = BriefSection(
  title: 'A coefficient that runs the other way',
  body:
      'Hazen-Williams sizes water mains on one number for the pipe wall, and '
      'that number runs OPPOSITE to the one in Manning\'s equation two pages '
      'away. A bigger C is a SMOOTHER pipe carrying MORE water: plastic is '
      'about 150, new cast iron about 130, and the same cast iron after '
      'twenty years in the ground about 100. Manning\'s n is the reverse, '
      'bigger meaning rougher, and mixing the two up inverts the answer. C '
      'sits on the top of the equation in the FIRST power, so two mains alike '
      'in everything but material carry flows in the plain ratio of their '
      'coefficients: twice the C is twice the water. The 0.63 and the 0.54 '
      'belong to the hydraulic radius and the gradient, and applying either '
      'of them to C is the second trap the lesson names.',
  formulas: [
    ('The equation', r'Q = k_1 C A R_H^{0.63} S_v^{0.54}'),
    ('Two like mains', r'\frac{Q_A}{Q_B} = \frac{C_A}{C_B}'),
    ('The constant', r'k_1 = 1.318 \text{ (ft)}, \; 0.849 \text{ (m)}'),
  ],
  figure: BriefFigure.hazen,
  handbook: 'Handbook p. 297',
);

const pumpPowerBrief = BriefSection(
  title: 'Three powers, and they only get bigger',
  body:
      'The power a pump costs is a product, so every term in the numerator '
      'behaves the same simple way: double the FLOW, or the HEAD, or the unit '
      'weight of what is being moved, and the power doubles. What breaks the '
      'pattern is the efficiency, which sits UNDERNEATH. Dividing by a number '
      'below one makes the answer LARGER, so the three powers come in a fixed '
      'order and never any other: the fluid power that ends up in the water is '
      'the smallest, the brake power at the shaft is bigger by the pump '
      'efficiency, and the input power off the meter is bigger again by the '
      'motor efficiency. Multiplying by the efficiency instead of dividing is '
      'the mistake the lesson names first, and the giveaway is that it makes '
      'the shaft work less hard than the water, which cannot happen. A motor '
      'nameplate is a ceiling, not a consumption: a bigger motor on the same '
      'duty draws the same power.',
  formulas: [
    ('Into the water', r'\dot W_{fluid} = \gamma Q H'),
    ('At the shaft', r'\dot W_{brake} = \frac{\gamma Q H}{\eta_{pump}}'),
    ('Off the meter', r'\dot W_{in} = \frac{\dot W_{brake}}{\eta_{motor}}'),
    ('In US units', r'WHP = \frac{\gamma Q H}{550}'),
  ],
  figure: BriefFigure.pumpPower,
  handbook: 'Handbook p. 191',
);

const npshBrief = BriefSection(
  title: 'The margin before the water boils',
  body:
      'Water boils at whatever pressure its temperature says it should, and '
      'inside a pump inlet the pressure is the lowest it gets anywhere in the '
      'system. NPSH AVAILABLE is how much head is left above that boiling '
      'point, and cavitation is what happens when it runs out: vapor bubbles '
      'form and then collapse against the impeller, which sounds like gravel '
      'and wears metal away. Two things add to the margin. The atmosphere '
      'pressing on the supply, worth about 10.3 meters at sea level and less '
      'up a mountain, and any water standing ABOVE the pump. Three things take '
      'from it: a suction LIFT, which makes the static term negative and is '
      'the sign error this lesson is built around, friction in the SUCTION '
      'pipework, and the vapor pressure of the liquid, which climbs steeply '
      'with temperature. Nothing on the discharge side appears anywhere in '
      'it. The margin has to beat the NPSH the pump itself requires.',
  formulas: [
    ('The margin', r'NPSH_A = H_{pa} + H_s - \sum h_L - H_{vp}'),
    ('A lift', r'H_s < 0'),
    ('A flooded suction', r'H_s > 0'),
    ('No cavitation', r'NPSH_A > NPSH_R'),
  ],
  figure: BriefFigure.npsh,
  handbook: 'Handbook p. 191',
);

const rationalBrief = BriefSection(
  title: 'Three numbers multiplied, and the units are built in',
  body:
      'The Rational Method is Q equals C times I times A, and the thing that '
      'makes it pleasant is that the units come out right on their own: an '
      'acre of ground under an inch an hour of rain is almost exactly one '
      'cubic foot a second, so there is no conversion to do and reaching for '
      'one is a mistake. C is the fraction of the rain that runs off rather '
      'than soaking in, from about 0.95 for paving down to about 0.15 for '
      'woodland, and it is dimensionless. With the same storm on two '
      'catchments the intensity cancels and only C TIMES A separates them, '
      'which means neither cover nor acreage wins on its own: a small hard '
      'site and a large soft one can come to the same peak. The method is '
      'for SMALL catchments, under about 200 acres; past that the SCS method '
      'takes over.',
  formulas: [
    ('The peak', r'Q = C I A'),
    ('Why no conversion', r'1 \text{ acre-in/hr} \approx 1.008 \text{ cfs}'),
    ('Several covers', r'Q = I \sum C_i A_i'),
  ],
  figure: BriefFigure.rational,
  handbook: 'Handbook p. 290',
);

const catchmentBrief = BriefSection(
  title: 'One coefficient for a patchwork',
  body:
      'A catchment draining to one inlet needs one runoff coefficient, and '
      'when the ground has two covers on it that coefficient is weighted BY '
      'AREA: add up C times A for each piece and divide by the total area. '
      'Averaging the two coefficients on their own is the trap this lesson '
      'names, and it goes wrong in proportion to how unequal the areas are. '
      'The useful form of the rule is a direction rather than a formula: the '
      'blend always leans toward whichever cover has more ground under it, '
      'and it lands halfway only when the two areas are equal, which is the '
      'one case where the plain average happens to be right. Naming which end '
      'it leans toward is usually enough to reject half the choices on an '
      'exam question before any arithmetic starts.',
  formulas: [
    ('Weighted by area', r'C = \frac{\sum C_i A_i}{\sum A_i}'),
    ('Or equivalently', r'Q = I \sum C_i A_i'),
  ],
  figure: BriefFigure.runoffBlend,
  handbook: 'Handbook p. 290',
);

const curveNumberBrief = BriefSection(
  title: 'The ground takes its share first',
  body:
      'The SCS method answers a different question from the Rational Method '
      'and answers it in different units: it gives the DEPTH of runoff in '
      'inches, not a discharge in cubic feet a second. Reporting it as a flow '
      'is the trap the lesson names. It works off a curve number, which is a '
      'measure of how readily the ground sheds water: about 98 for paving, '
      'around 70 for ordinary mixed ground, down into the fifties for woods '
      'on good soil. From it comes the RETENTION, the most the ground could '
      'hold, and the ground takes the first fifth of that, the initial '
      'abstraction, before anything at all runs off. Below that threshold the '
      'runoff is a hard zero rather than something small. Above it the '
      'fraction that runs off climbs with the storm, slowly at first and then '
      'approaching all of it.',
  formulas: [
    ('Runoff depth', r'Q = \frac{(P - 0.2S)^2}{P + 0.8S}'),
    ('Retention', r'S = \frac{1{,}000}{CN} - 10'),
    ('Nothing below', r'P \le 0.2S \Rightarrow Q = 0'),
  ],
  figure: BriefFigure.curveNumber,
  handbook: 'Handbook p. 290',
);

const unitHydrographBrief = BriefSection(
  title: 'One inch, and everything else is a multiple',
  body:
      'A UNIT HYDROGRAPH is the watershed\'s answer to one inch of excess '
      'rainfall falling evenly over a stated DURATION. Two numbers define it '
      'and both matter. For a deeper storm of the same duration, multiply '
      'every ordinate by the depth and leave the times exactly where they '
      'are: three inches gives three times the peak at the same hour, and '
      'three times the volume under the curve, because the watershed routes '
      'water at its own speed whatever the storm does. For a storm of a '
      'DIFFERENT duration, no scaling will do. Rain spread over three hours '
      'gives a lower, longer, flatter response than the same total in one, '
      'and the way across is to build the three hour hydrograph by lagging '
      'and adding, not by stretching. Depth sets the volume; duration sets '
      'the shape. Total streamflow is this direct runoff plus the baseflow '
      'that was there anyway.',
  formulas: [
    ('Scaling for depth', r'Q(t) = P \times Q_{UH}(t)'),
    ('The times', r'\text{unchanged}'),
    ('What is under it', r'\text{1 inch over the watershed}'),
  ],
  figure: BriefFigure.unitHydrograph,
  handbook: 'Handbook p. 292',
);

const concentrationBrief = BriefSection(
  title: 'Why the design storm lasts exactly that long',
  body:
      'The TIME OF CONCENTRATION is how long water takes to travel from the '
      'most distant corner of a watershed to the outlet, and the Rational '
      'Method is always run with the storm duration set equal to it. That is '
      'not a convention, it is where the peak is largest, and the reason is a '
      'trade. A SHORTER storm is more intense, because intensity and duration '
      'run opposite ways on an IDF curve, but it ends before the far ground '
      'has reported in, so the high intensity is applied to only part of the '
      'area. A LONGER storm has the whole watershed contributing but must use '
      'the lower intensity quoted for that duration. Both give a smaller peak '
      'than the storm that lasts exactly the travel time, and knowing which '
      'of the two reasons applies is what tells you what to change.',
  formulas: [
    ('The design storm', r'D = t_c'),
    ('Then', r'Q = C I_{t_c} A'),
    ('Shorter', r'\text{part of } A'),
    ('Longer', r'\text{smaller } I'),
  ],
  figure: BriefFigure.concentration,
  handbook: 'Handbook p. 290',
);

const routingBrief = BriefSection(
  title: 'One subtraction, and the sign is the answer',
  body:
      'Storage routing is inflow minus outflow equals the rate the storage '
      'changes. Positive means the pond is FILLING, and getting the '
      'subtraction the wrong way round gives the right number with the wrong '
      'story attached, which is this lesson\'s named trap. Everything a '
      'detention pond does follows from it. On the rising limb far more '
      'arrives than the small outlet can pass, so the pond fills and the '
      'catchment downstream never sees the peak that arrived. There is one '
      'instant when the two flows are equal, and that is when the pond is at '
      'its fullest and its outflow at its greatest: it falls on the FALLING '
      'limb of the inflow hydrograph, where the outflow curve crosses it. '
      'After that the pond empties, and it has to finish emptying before the '
      'next storm or it has no room left to be useful.',
  formulas: [
    ('The rate', r'I - O = \frac{\Delta S}{\Delta t}'),
    ('Filling', r'I > O'),
    ('Fullest', r'I = O \text{ on the falling limb}'),
  ],
  figure: BriefFigure.routing,
  handbook: 'Handbook p. 290',
);

const seepageBrief = BriefSection(
  title: 'Three numbers that are easy to mix up',
  body:
      'Darcy\'s law gives K times the hydraulic gradient, and that quantity '
      'has the units of a speed while being the speed of nothing at all. It '
      'is the DARCY VELOCITY, also called the specific discharge: the volume '
      'passing through a square meter of soil, grains and voids together, as '
      'if the grains were not in the way. Water can only use the voids, so it '
      'has to move faster than that, and the SEEPAGE VELOCITY, the Darcy '
      'velocity divided by the porosity, is what a dye tracer actually '
      'travels at. It is always the larger of the two, and multiplying by the '
      'porosity instead of dividing is the mistake the lesson names. '
      'Multiplying the Darcy velocity by the cross-section gives a third '
      'thing entirely, a volume a second, which is a discharge and not a '
      'speed. Read the units of what is being asked for before reaching for '
      'a formula.',
  formulas: [
    ('Through the whole face', r'q = K i'),
    ('Through the pores', r'v = \frac{q}{n}'),
    ('The volume', r'Q = q A = K i A'),
  ],
  figure: BriefFigure.seepage,
  handbook: 'Handbook p. 292',
);

const wellBrief = BriefSection(
  title: 'Clay on top decides everything',
  body:
      'Two well formulas, and the only question that picks between them is '
      'whether something impermeable caps the aquifer. Under clay the aquifer '
      'is CONFINED: it cannot change thickness however hard you pump, the '
      'transmissivity is a fixed K times b, and the heads go into THIEM as '
      'they are. The surface the heads describe is a pressure level in a '
      'standpipe, not a water table, and water standing above the top of the '
      'aquifer is the giveaway. With a free water table the aquifer is '
      'UNCONFINED: the saturated thickness falls as the water table is drawn '
      'down, so there is less ground to carry water near the well, and '
      'DUPUIT squares the heads to account for it. That squaring is not a '
      'convention. Since the difference of two squares is the difference '
      'times the sum, pulling the well down twice as far buys LESS than twice '
      'the water, while a wetter year that lifts the whole water table buys '
      'more. Both formulas divide by the natural log of the radius ratio, '
      'never the base ten log.',
  formulas: [
    ('Unconfined', r'Q = \frac{\pi K (h_2^2 - h_1^2)}{\ln(r_2/r_1)}'),
    ('Confined', r'Q = \frac{2\pi T (h_2 - h_1)}{\ln(r_2/r_1)}'),
    ('Transmissivity', r'T = K b'),
  ],
  figure: BriefFigure.wells,
  handbook: 'Handbook pp. 292 to 293',
);

const bodBrief = BriefSection(
  title: 'The five day test is not the whole of it',
  body:
      'BOD is the oxygen that bacteria will take while they break down the '
      'organic matter in a sample, and it arrives over time rather than all '
      'at once. The ULTIMATE BOD is the whole of it, and the standard '
      'laboratory test reads a bottle at FIVE DAYS at twenty degrees, which '
      'catches only part. How much part depends on the decay rate: 68 percent '
      'at the standard k of 0.23 a day, under 40 percent in slow cold water, '
      'and nearly all of it in a fast warm sample. The 68 percent figure is '
      'not a law. Two numbers matter at any moment and they add to the '
      'ultimate: the BOD EXERTED, which is what the test measures, and the '
      'BOD REMAINING, which is still to come. Going from the ultimate to a '
      'measurement you MULTIPLY by the fraction and the answer gets smaller; '
      'going from a measurement back to the ultimate you DIVIDE and it gets '
      'larger. The ultimate is always the bigger of the two, which is the '
      'check that catches a division done upside down.',
  formulas: [
    ('Exerted by day t', r'BOD_t = L_0\left(1 - e^{-kt}\right)'),
    ('Still to come', r'L_0 - BOD_t = L_0 e^{-kt}'),
    ('Working backward', r'L_0 = \frac{BOD_t}{1 - e^{-kt}}'),
  ],
  figure: BriefFigure.bod,
  handbook: 'Handbook p. 321',
);

const temperatureBrief = BriefSection(
  title: 'Temperature moves the rate, not the total',
  body:
      'Warm water means busy bacteria, so a rate constant quoted at twenty '
      'degrees has to be corrected for the temperature the water is actually '
      'at. The exponent is T MINUS 20: above the reference the factor is '
      'greater than one and the decay speeds up, below it the factor is less '
      'than one and the decay crawls. Writing 20 minus T gives a slower rate '
      'for a warmer river, which cannot happen, and it is the trap this '
      'lesson names. What the correction does NOT touch is the ultimate BOD: '
      'the same organic matter needs the same oxygen in the end, it simply '
      'gets there sooner, so the warm curve climbs more steeply to the same '
      'ceiling. Which theta to use depends on the process and the range: '
      '1.135 for BOD from 4 to 20 degrees, 1.056 from 21 to 30, and 1.024 for '
      'reaeration.',
  formulas: [
    ('The correction', r'k_T = k_{20}\,\theta^{(T-20)}'),
    ('BOD, warm', r'\theta = 1.056'),
    ('BOD, cold', r'\theta = 1.135'),
    ('Reaeration', r'\theta = 1.024'),
  ],
  figure: BriefFigure.rateTemperature,
  handbook: 'Handbook p. 322',
);

const overflowBrief = BriefSection(
  title: 'A rate with the units of a speed',
  body:
      'The OVERFLOW RATE of a settling tank is the flow divided by the '
      'SURFACE area, and although it gets quoted in gallons a day per square '
      'foot, those units cancel to a velocity. Read it that way and the tank '
      'explains itself: it is the speed the water rises on its way to the '
      'weir, so a particle that falls faster than that reaches the floor and '
      'one that falls slower is carried out. Everything the tank removes is '
      'decided by that one comparison. The depth appears nowhere in it. '
      'Building the tank deeper buys DETENTION TIME, which is volume over '
      'flow and matters for other things, and captures not one extra '
      'particle; building it wider buys capture. Doubling the flow doubles '
      'the overflow rate, which is why a storm can wash a clarifier out. '
      'Primary tanks run at 800 to 1,200 and secondary ones at 400 to 800, '
      'because biological floc settles far more slowly than grit.',
  formulas: [
    ('The overflow rate', r'v_o = \frac{Q}{A_{surface}}'),
    ('Captured when', r'v_s > v_o'),
    ('Detention time', r'\theta = \frac{V}{Q}'),
  ],
  figure: BriefFigure.overflow,
  handbook: 'Handbook p. 339',
);

const residenceBrief = BriefSection(
  title: 'Two clocks in one plant',
  body:
      'An activated sludge plant runs two residence times and they are not '
      'the same one. The HYDRAULIC time is volume over flow: how long the '
      'WATER spends crossing the plant, a few hours, because the water goes '
      'through once and leaves. The SOLIDS time is the mass of solids held in '
      'the system over the mass leaving each day, and it comes out in DAYS, '
      'typically four to fifteen, because the solids settle in the clarifier '
      'and are pumped back to the basin to go round again until they are '
      'deliberately wasted. The units are the quickest way to tell which is '
      'which: hours means water, days means solids. The denominator of the '
      'solids time has two parts, the waste sludge AND the solids that escape '
      'over the weir, and dropping the second is a common slip. Wasting more '
      'sludge shortens the solids time and does nothing at all to the '
      'hydraulic one.',
  formulas: [
    ('The water', r'\theta = \frac{V}{Q}'),
    ('The solids', r'\theta_c = \frac{V X_A}{Q_w X_w + Q_e X_e}'),
  ],
  figure: BriefFigure.residence,
  handbook: 'Handbook p. 333',
);

const foodRatioBrief = BriefSection(
  title: 'Food over the mouths that eat it',
  body:
      'The food to microorganism ratio is the organic load arriving each day '
      'divided by the mass of biology available to treat it, and the four '
      'quantities in it sort themselves by which side of the line they sit '
      'on. The FLOW and the influent BOD are the food, and only their PRODUCT '
      'matters: a storm that doubles the flow and halves the strength brings '
      'the same kilograms of BOD and moves the ratio not at all. The BASIN '
      'VOLUME and the MIXED LIQUOR SOLIDS are the bugs, and their product is '
      'the biomass being carried, so a second basin at the same concentration '
      'halves the ratio just as surely as doubling the concentration would. '
      'The concentration units cancel, which is why the answer comes out per '
      'day. Conventional plants are held between about 0.2 and 0.4, and the '
      'waste pump is the lever that gets them there.',
  formulas: [
    ('The ratio', r'F{:}M = \frac{Q S_0}{V X_A}'),
    ('The food', r'Q S_0 \text{, a load per day}'),
    ('The bugs', r'V X_A \text{, a mass}'),
  ],
  figure: BriefFigure.foodRatio,
  handbook: 'Handbook p. 333',
);

const doseBrief = BriefSection(
  title: 'Three numbers, and the pump is set to the sum',
  body:
      'Chlorination has three quantities in it and two of them get confused. '
      'The DEMAND belongs to the water: the organic matter, ammonia and iron '
      'in it consume chlorine before any is left over, and a dirty raw water '
      'has a high demand. The RESIDUAL is what must still be measurable at '
      'the far end of the distribution system, and it is the only one of the '
      'three anybody can sample for out in the mains, which is why '
      'regulations are written on it. The DOSE is what the feed pump is set '
      'to, and it is the SUM of the other two: feed only the demand and '
      'nothing reaches the customer, feed only the residual and the water '
      'consumes it before it leaves the works. Mass per day comes off the '
      'dose, not the demand, and a milligram a liter is a gram a cubic meter, '
      'so the conversion is easier than it looks.',
  formulas: [
    ('The balance', r'\text{dose} = \text{demand} + \text{residual}'),
    ('Mass per day', r'\dot m = \text{dose} \times Q'),
    ('The handy identity', r'1 \text{ mg/L} = 1 \text{ g/m}^3'),
  ],
  figure: BriefFigure.chlorineDose,
  handbook: 'Handbook p. 346',
);

const contactBrief = BriefSection(
  title: 'Credit is a product, and the time is the honest one',
  body:
      'Disinfection credit is CT, the free chlorine RESIDUAL multiplied by '
      'the contact time, so there are two ways to buy it and they trade off '
      'exactly: half again the residual does what half again the time would. '
      'Note that it runs on the residual and not on the dose, so chlorine '
      'consumed by the demand buys no credit at all. The time is the part '
      'worth care. It is not the volume over the flow, which assumes every '
      'drop takes the same path, but t10, the time the fastest TENTH of the '
      'water gets, and in an unbaffled tank that can be a third of the '
      'theoretical figure or less because some water short circuits from the '
      'inlet to the outlet. Baffles are the cheap way to close the gap, and '
      'compliance is checked at peak flow, when the time is shortest.',
  formulas: [
    ('The credit', r'CT = C \times t_{10}'),
    ('The honest time', r't_{10} < \frac{V}{Q}'),
    ('What it is for', r'3\text{-log Giardia}, \; 4\text{-log virus}'),
  ],
  figure: BriefFigure.contactTime,
  handbook: 'Handbook p. 346',
);

const standardsBrief = BriefSection(
  title: 'Two tiers, and only one is law',
  body:
      'The Safe Drinking Water Act sets PRIMARY standards, which are health '
      'based and legally enforceable, and SECONDARY standards, which cover '
      'taste, color, staining and scale and are advisory. Exceeding a primary '
      'limit is a violation with public notice attached; exceeding a '
      'secondary one produces complaints. Primary: arsenic at 0.010 mg/L, '
      'nitrate as nitrogen at 10, the lead action level at 0.015, turbidity, '
      'the pathogens. Secondary: iron at 0.3, manganese at 0.05, total '
      'dissolved solids at 500, chloride at 250, pH between 6.5 and 8.5. The '
      'SIZE of a limit says nothing about which tier it belongs to, only '
      'about how harmful the substance is. Wastewater is a different act '
      'entirely: the Clean Water Act licenses discharges through NPDES '
      'permits, and conventional secondary treatment is about 30 mg/L of BOD '
      'and suspended solids, roughly 85 percent removal.',
  formulas: [
    ('Primary', r'\text{health, enforceable}'),
    ('Secondary', r'\text{aesthetic, advisory}'),
    ('Secondary treatment', r'\approx 30 \text{ mg/L BOD}_5'),
  ],
  figure: BriefFigure.tiers,
  handbook: 'Handbook, water quality standards',
);

const hardnessBrief = BriefSection(
  title: 'Everything on one basis',
  body:
      'Hardness comes from divalent cations, mostly calcium and magnesium, '
      'and they cannot be added together as they come because a milligram of '
      'one is not chemically equal to a milligram of the other. Converting '
      'each to an equivalent concentration of calcium carbonate puts them on '
      'one basis, and the multiplier is 50 divided by the ion\'s own '
      'equivalent weight: 50 over 20 is 2.5 for calcium, and 50 over 12.15 is '
      '4.12 for magnesium. Magnesium therefore counts for MORE, milligram '
      'for milligram, because it is the lighter ion. The conversion can '
      'reverse which of the two dominates, so it has to be done before '
      'anything is compared as well as before anything is added, and adding '
      'the raw concentrations understates the hardness every time. The bands '
      'are soft under 60, moderately hard to 120, hard to 180, and very hard '
      'above that.',
  formulas: [
    ('On one basis', r'\text{as CaCO}_3 = \sum C_i \frac{50}{EW_i}'),
    ('Calcium', r'\times 2.5'),
    ('Magnesium', r'\times 4.12'),
  ],
  figure: BriefFigure.hardness,
  handbook: 'Handbook, hardness',
);

const efficiencyBrief = BriefSection(
  title: 'What came out, over what went in',
  body:
      'Removal efficiency is the influent less the effluent, over the '
      'influent, and the trap is reporting the other piece: the fraction '
      'still there, which is the effluent over the influent. The two add to '
      'one, so a plant at 87.5 percent leaves 12.5, and both numbers usually '
      'appear among the choices. The FLOW is in neither term and cancels '
      'entirely, so only the ratio of the two concentrations matters, and '
      'doubling the influent and the permit together changes nothing at all '
      'even though the plant is removing twice the mass. The last part is '
      'worth carrying: near the top of the range five percentage points '
      'halves what is discharged, 90 to 95 taking a 20 mg/L effluent down to '
      '10. Percentages flatter a good plant, which is why permits are written '
      'on concentrations.',
  formulas: [
    ('Removed', r'E = \frac{S_0 - S}{S_0}'),
    ('Left', r'\frac{S}{S_0} = 1 - E'),
  ],
  figure: BriefFigure.efficiency,
  handbook: 'Handbook, treatment performance',
);

const countBrief = BriefSection(
  title: 'Two counts, and the joints pick which',
  body:
      'Before anything is analyzed a structure has to be classified, and the '
      'count depends on what the joints do rather than on what the outline '
      'looks like. PINNED joints throughout carry no moment, so each joint '
      'gives two equations and the count is m plus r against 2j. RIGID joints '
      'carry moment, each gives three equations, and the count is 3m plus r '
      'against 3j plus c, where c is one for every internal hinge or other '
      'release, because each of those hands you an extra equation for free. A '
      'triangle with welded corners is a frame, however much it resembles a '
      'truss. Count the reactions carefully: a roller is one component, a pin '
      'two, a fixed support three. Short of the requirement is a mechanism, '
      'exactly it is determinate, and over it is indeterminate by the '
      'difference, which is how many extra unknowns equilibrium cannot '
      'reach.',
  formulas: [
    ('A truss', r'm + r \text{ vs } 2j'),
    ('A frame', r'3m + r \text{ vs } 3j + c'),
    ('The degree', r'\text{supply} - \text{need}'),
    ('Reactions', r'\text{roller } 1, \text{ pin } 2, \text{ fixed } 3'),
  ],
  figure: BriefFigure.determinacyCount,
  handbook: 'Handbook p. 271',
);

const stabilityBrief = BriefSection(
  title: 'Necessary, and never sufficient',
  body:
      'The determinacy count can be satisfied exactly and the structure can '
      'still fall over, which is the single most examinable idea in this '
      'lesson. The count sees how many members, joints and reactions there '
      'are; it cannot see where any of them POINT. Two arrangements give it '
      'away. Reactions all PARALLEL, three rollers on level ground being the '
      'usual case, can sum to nothing across their own direction, so any load '
      'sideways has nothing to react against and the structure slides. '
      'Reactions all CONCURRENT, passing through a single point, have no '
      'lever arm about that point, so the structure turns about it as a rigid '
      'body. Neither is cured by adding more of the same: a structure with '
      'four parallel reactions is indeterminate by the count and just as '
      'unstable. Check the count, then look at the picture.',
  formulas: [
    ('Necessary', r'm + r \ge 2j'),
    ('Not sufficient', r'\text{parallel or concurrent} \Rightarrow \text{unstable}'),
  ],
  figure: BriefFigure.stability,
  handbook: 'Handbook p. 271',
);

const momentCenterBrief = BriefSection(
  title: 'Where the pivot goes',
  body:
      'A section cut through three members leaves three unknown forces on the '
      'piece you keep, and three equations to find them with. The moment '
      'equation is the one worth spending carefully: take moments about the '
      'point where the TWO MEMBERS YOU DO NOT WANT cross, and neither of them '
      'has a lever arm about it, so both fall out and the equation has one '
      'unknown left. The pivot therefore moves with the member you are after: '
      'the same cut takes a different point for the top chord than for the '
      'bottom one, and the point can sit outside the piece of truss you are '
      'holding, because it is a point in space rather than a joint. When the '
      'two unwanted members are the parallel chords of a parallel chord truss '
      'they never cross, so no pivot works: use the vertical force equation '
      'instead, which is why the diagonals of such a truss are said to carry '
      'the shear.',
  formulas: [
    ('The pivot', r'\sum M_{point} = 0'),
    ('Chords', r'\text{pivot where the other two meet}'),
    ('Diagonals', r'\sum F_y = 0'),
  ],
  figure: BriefFigure.momentCenter,
  handbook: 'Handbook p. 271',
);

const jointForceBrief = BriefSection(
  title: 'Why the diagonal is the big one',
  body:
      'At a joint carrying a vertical load, the only member with anything '
      'pointing upward is the diagonal, so the whole load has to be carried '
      'by its vertical COMPONENT. A member is always bigger than its own '
      'component, so the diagonal force is bigger than the load, every time: '
      'the load over the sine of the angle. How much bigger is all in the '
      'geometry. At 75 degrees the factor is 1.04 and the member barely '
      'notices; at 45 it is 1.41; on the three four five triangle that hides '
      'in most textbook trusses it is 1.67, with sine 0.6 and cosine 0.8 '
      'worth knowing by sight; at 10 degrees it is nearly six. The flatter '
      'the member, the more force it takes to hold the same load, running '
      'away toward infinity as it approaches horizontal. Steep is efficient, '
      'which is why depth is worth paying for in a truss.',
  formulas: [
    ('The diagonal', r'F = \frac{P}{\sin\theta}'),
    ('The flat member', r'F\cos\theta'),
    ('Always', r'F > P'),
  ],
  figure: BriefFigure.jointForce,
  handbook: 'Handbook p. 271',
);

const unitLoadBrief = BriefSection(
  title: 'The load that asks the question',
  body:
      'The unit load is not a load on the structure so much as the question '
      'written in a form the equation can answer, and three things about it '
      'are decided before any arithmetic starts. It MATCHES what is wanted: a '
      'unit force pairs with a movement, a unit moment pairs with a rotation. '
      'It sits AT the point asked about, not where the real load happens to '
      'be and not where a handbook table happens to have an entry, and it '
      'points in the direction being measured, so a sideways answer needs a '
      'sideways unit load. And it acts ALONE, in a second analysis of the '
      'same structure with every real load taken off: the real loads give N, '
      'the unit load by itself gives n, and the formula multiplies the two '
      'sets together afterward. Adding the unit load on top of the real loads '
      'produces one set of forces that is neither, and everything after that '
      'is wasted.',
  formulas: [
    ('A truss', r'\delta = \sum \frac{n N L}{A E}'),
    ('A beam or frame', r'\delta = \int \frac{m M}{E I}\,dx'),
    ('A rotation', r'\text{unit moment, not a unit force}'),
  ],
  figure: BriefFigure.unitLoad,
  handbook: 'Handbook p. 271',
);

const termSignBrief = BriefSection(
  title: 'Which terms survive, and which way',
  body:
      'The sum has one term per member and most of them can be settled by '
      'looking. Either factor zero and the term is zero: a member the unit '
      'load does not reach contributes nothing however hard it is working, '
      'and a zero-force member in the real structure contributes nothing '
      'however much the unit load stretches it. Running the unit-load '
      'analysis first and crossing off every member it leaves at zero often '
      'halves the work. What is left is decided by the two signs AGREEING, '
      'not by their being positive: tension with tension and compression with '
      'compression both give a positive term that moves the joint the way the '
      'unit load points, and one of each pulls the joint back. Two '
      'compressions catching people out is the reason to carry the signs '
      'through rather than the sizes. A total that comes out negative is not '
      'an error either: it says the joint moved opposite to the direction the '
      'unit load was pointed.',
  formulas: [
    ('One term', r'\frac{n N L}{A E}'),
    ('Drops out', r'n = 0 \;\text{ or }\; N = 0'),
    ('Same signs', r'nN > 0 \Rightarrow \text{with the unit load}'),
  ],
  figure: BriefFigure.termSign,
  handbook: 'Handbook p. 271',
);

const redundantBrief = BriefSection(
  title: 'Let one thing go, and pay for it',
  body:
      'An indeterminate structure has more unknowns than the three equations '
      'equilibrium hands out, so something from outside statics has to make '
      'up the difference, and that something is how far the structure '
      'actually bends. The method is the same every time. RELEASE as many '
      'things as the count is over by, choosing releases that leave a stable '
      'determinate structure behind, and carry each released thing as an '
      'unknown. Then write the movement the real support would not have '
      'allowed: release a force and the deflection there has to come back to '
      'zero, release a moment and the rotation there has to come back to '
      'zero. That is one equation per release, which is exactly the shortfall. '
      'Which thing to release is a free choice and the finished forces are '
      'the same whichever is picked, so pick the one whose deflection is '
      'easiest to work out. Once the redundant has a number it is an ordinary '
      'known force and statics finishes the rest.',
  formulas: [
    ('The shortfall', r'DSI = (\text{unknowns}) - 3'),
    ('A released force', r'\delta = 0 \text{ where the support was}'),
    ('A released moment', r'\theta = 0 \text{ where the wall was}'),
  ],
  figure: BriefFigure.redundant,
  handbook: 'Handbook p. 271',
);

const fixityBrief = BriefSection(
  title: 'What building an end in changes',
  body:
      'Every standard result in this lesson is the same story told with '
      'numbers, and knowing the direction of each one beats memorizing any of '
      'them. Building an end in makes it STIFF, and load goes where the '
      'stiffness is: the propped cantilever gives its prop three eighths of '
      'the load where a simple support would take a half, and the built-in '
      'end picks up the other five eighths. Moment moves the same way. A '
      'simple support carries none, a built-in end carries plenty, and what '
      'appears at the ends comes out of the middle: a fixed-fixed beam under '
      'a uniform load carries wL squared over 12 at each support and only wL '
      'squared over 24 at midspan, against wL squared over 8 in the middle of '
      'a simple span. The sag drops for the same reason, to a fifth of the '
      'simply supported value. The one thing fixity does NOT change is the '
      'vertical split on a symmetric beam: half at each end, built in or not.',
  formulas: [
    ('The prop', r'R = \frac{3wL}{8}'),
    ('A fixed end', r'M = \frac{wL^2}{12}'),
    ('A simple span', r'M = \frac{wL^2}{8}'),
  ],
  figure: BriefFigure.fixity,
  handbook: 'Handbook p. 271',
);

const lrfdBrief = BriefSection(
  title: 'Read the stem before the numbers',
  body:
      'There are two ways to buy the same margin and the halves do not mix. '
      'LRFD multiplies the loads UP, dead by 1.2 because its weight is '
      'already drawn and well known, floor live by 1.6 because it is a guess '
      'about how the place will be used, and compares the total with the '
      'design strength, the nominal strength cut down by a resistance factor. '
      'Allowable stress design takes the loads exactly as the building sees '
      'them and divides the STRENGTH instead, by a safety factor. Both are in '
      'the code and either may be used, and their numbers are not comparable '
      'with each other. The one real error is taking half of one and half of '
      'the other: factor the loads AND divide the strength and the member '
      'pays twice, take service loads against an undivided strength and it '
      'hardly pays at all.',
  formulas: [
    ('LRFD', r'1.2D + 1.6L \le \phi R_n'),
    ('ASD', r'D + L \le R_n / \Omega'),
    ('Why 1.2 and 1.6', r'\text{how well the load is known}'),
  ],
  figure: BriefFigure.lrfd,
  handbook: 'Handbook, design loads',
);

const controlsBrief = BriefSection(
  title: 'The big factor follows the big load',
  body:
      'Three combinations cover ordinary gravity work and which of them wins '
      'can be read off the loading before any arithmetic. Combination 2 puts '
      '1.6 on the FLOOR live load and brings the roof load along at half, so '
      'it wins whenever the floor live load is the big one, which is most of '
      'the time. Combination 3 puts 1.6 on the ROOF load, snow or roof live '
      'or rain, and brings the floor live load along at its face value, so it '
      'takes over when the roof load is the bigger of the two. Combination 1 '
      'is 1.4 on the dead load alone, and it only matters when there is '
      'hardly any live load for the 1.6 to work on, a heavy slab carrying '
      'next to nothing. Whichever combination points its big factor at the '
      'load that is actually there is the one to design for.',
  formulas: [
    ('Combination 1', r'1.4D'),
    ('Combination 2', r'1.2D + 1.6L + 0.5S'),
    ('Combination 3', r'1.2D + 1.6S + L'),
  ],
  figure: BriefFigure.controls,
  handbook: 'Handbook, design loads',
);

const reductionBrief = BriefSection(
  title: 'A big floor is never full at once',
  body:
      'Live load may be reduced because the chance of every square foot of a '
      'large floor being loaded to the full at the same moment is small, so '
      'the more floor a member carries the less of the nominal load it will '
      'ever see together. The rule multiplies the tributary area by K first, '
      'which is 4 for a column and 2 for a beam because that is roughly how '
      'much floor can reach each of them, and a column therefore gets the '
      'bigger reduction off the same bay. Three things bound it. It never '
      'becomes an increase, so below 400 for K times the area there is no '
      'reduction at all. It stops at half the unreduced load for a member '
      'carrying one floor and at four tenths for one carrying two or more. '
      'And it touches live load only: the slab weighs what it weighs.',
  formulas: [
    ('The rule', r'L = L_o\left(0.25 + \frac{15}{\sqrt{K_{LL} A_T}}\right)'),
    ('The element factor', r'K_{LL} = 4 \text{ column}, \; 2 \text{ beam}'),
    ('The floor', r'L \ge 0.50 L_o \text{ for one floor}'),
  ],
  figure: BriefFigure.reduction,
  handbook: 'Handbook, design loads',
);

const influenceBrief = BriefSection(
  title: 'One answer, as the load walks across',
  body:
      'An influence line answers a different question from every other '
      'diagram in the chapter, and looking exactly like them is what makes it '
      'hard. A shear or moment DIAGRAM is drawn for one fixed set of loads '
      'and reads across the beam: this is what the beam is carrying, here. An '
      'influence line is drawn for one fixed PLACE and reads across all the '
      'positions a moving load might take: this is what that one place feels '
      'while the load is over there. So the across-axis is where the load is '
      'standing, and the height is the reaction, shear or moment at the '
      'marked place while it stands there. The two pictures agree by '
      'coincidence for a moment at midspan under a single central load, and '
      'nowhere else. Because the line is built from a UNIT load, a real load '
      'is simply its own size times the height beneath it, and several loads '
      'add up.',
  formulas: [
    ('Using it', r'R = \sum P_i \, \eta_i'),
    ('A spread load', r'\text{the area under the line beneath it}'),
    ('Across', r'\text{where the moving load stands}'),
  ],
  figure: BriefFigure.influenceRead,
  handbook: 'Handbook, influence lines',
);

const shapesBrief = BriefSection(
  title: 'Three shapes and no others',
  body:
      'On a simply supported span every influence line in the lesson is made '
      'of straight pieces, and there are only three of them to know. A '
      'REACTION line runs straight from one, over its own support, down to '
      'nothing over the other: a load standing on a support is carried '
      'entirely by it. A MOMENT line at a section is a triangle whose peak '
      'sits over that section and is worth a times (L minus a) over L, which '
      'comes to a quarter of the span when the section is at midspan. A SHEAR '
      'line at a section has two sloping pieces and a STEP of exactly one '
      'where the section is, because the load crossing the cut changes sides '
      'all at once. The step is the only sure way to tell a shear line from a '
      'moment line, since both are drawn about a section, and the two '
      'reaction lines always add to one at every position, which checks a '
      'pair of them in a second.',
  formulas: [
    ('A reaction', r'\eta = \frac{L - x}{L}'),
    ('A moment at a', r'\eta_{peak} = \frac{a(L-a)}{L}'),
    ('A shear at a', r'1 - \frac{a}{L} \text{ and } -\frac{a}{L}'),
  ],
  figure: BriefFigure.influenceShapes,
  handbook: 'Handbook, influence lines',
);

const placeBrief = BriefSection(
  title: 'Park it where the line is tallest',
  body:
      'The exam question is usually not what the line is but where to stand '
      'the load, and the answer is always the same: on the tallest part of '
      'the line, because the effect is the load times the height under it. '
      'For a moment that means on the section itself, wherever the section '
      'is, and not at midspan out of habit. For a positive shear it means '
      'just to the RIGHT of the section, since a step to the left of it turns '
      'the ordinate negative and the same load now works the other way. For a '
      'reaction it means over the support. When several loads travel together '
      'they cannot all stand on the peak, so the HEAVIEST one takes it: '
      'straddling the peak fairly gives every load a middling height and is '
      'worth less. A load that is spread out contributes the area under the '
      'line beneath it, so it covers only the ground where the line is on the '
      'side you want and stops there.',
  formulas: [
    ('One load', r'\text{on the peak}'),
    ('Several', r'\text{the heaviest on the peak}'),
    ('Spread', r'\text{cover the positive part only}'),
  ],
  figure: BriefFigure.influencePlace,
  handbook: 'Handbook, influence lines',
);

const whichDepthBrief = BriefSection(
  title: 'd is not the height of the beam',
  body:
      'Every reinforced concrete formula in the lesson leans on d, the '
      'EFFECTIVE depth, which runs from the top of the beam down to the '
      'CENTROID of the tension steel. It is the overall height less the clear '
      'cover, less the stirrup, less half a bar diameter, and it gets shorter '
      'again when there are two layers of bars. Using the height instead '
      'overstates the capacity of everything you check, which is why the '
      'lesson says outright that getting d wrong changes everything. The '
      'lever arm is shorter still: the beam carries moment as a couple, steel '
      'pulling low and concrete pushing high, and what counts is the distance '
      'BETWEEN those two forces, which is d less half the depth of the '
      'compression block. More steel deepens that block and quietly shortens '
      'the arm.',
  formulas: [
    ('The effective depth', r'd = h - \text{cover} - \text{stirrup} - d_b/2'),
    ('The block', r'a = \frac{A_s f_y}{0.85 f_c^{\prime} b}'),
    ('The couple', r'M_n = A_s f_y\left(d - \frac{a}{2}\right)'),
  ],
  figure: BriefFigure.effectiveDepth,
  handbook: 'Handbook, reinforced concrete',
);

const stirrupBrief = BriefSection(
  title: 'Four answers on one ladder',
  body:
      'The shear question is always which band the section has landed in, and '
      'the bands are marked off against what the concrete can be leaned on '
      'for, which is phi times its own capacity and not the capacity itself. '
      'Below HALF of that, no stirrups are required at all. Between half and '
      'all of it, minimum stirrups: the concrete could manage, but the code '
      'wants a cage in there to hold the crack together and to give the beam '
      'some warning before it goes. Above it, stirrups are sized for what is '
      'left once the demand has been divided by phi and the concrete taken '
      'off. And there is a ceiling: ask the stirrups for more than four times '
      'the concrete\'s own share and the concrete between them crushes '
      'whatever the spacing, so the section has to grow instead.',
  formulas: [
    ('The concrete', r'V_c = 2\lambda\sqrt{f_c^{\prime}}\, b_w d'),
    ('The stirrups', r'V_s = \frac{V_u}{\phi} - V_c'),
    ('The spacing', r's = \frac{A_v f_y d}{V_s}'),
  ],
  figure: BriefFigure.stirrupLadder,
  handbook: 'Handbook, reinforced concrete',
);

const phiBrief = BriefSection(
  title: 'What it can do, and what you may count on',
  body:
      'Every capacity in reinforced concrete comes in two versions and the '
      'exam hands out marks for telling them apart. The NOMINAL strength is '
      'what the section can actually reach. The DESIGN strength is nominal '
      'times phi, and it is all you are allowed to count on. Bending gets '
      '0.90 and shear gets 0.75, because a properly proportioned beam fails '
      'in bending slowly and visibly while shear failure arrives without '
      'notice, and the code leans hardest on the failures that give no '
      'warning. In the check itself the loads are factored UP and the '
      'capacity is cut DOWN, so margin is bought at both ends. One '
      'consequence is worth carrying: when the stirrups are being sized, the '
      'demand is divided by phi BEFORE the concrete is taken off, because '
      'both capacities are nominal numbers and phi applies to their sum.',
  formulas: [
    ('Bending', r'\phi M_n \ge M_u, \; \phi = 0.90'),
    ('Shear', r'\phi V_n \ge V_u, \; \phi = 0.75'),
    ('The stirrups', r'V_s = \frac{V_u}{\phi} - V_c'),
  ],
  figure: BriefFigure.phiFactors,
  handbook: 'Handbook, reinforced concrete',
);

const columnFactorBrief = BriefSection(
  title: 'Two multipliers, doing two jobs',
  body:
      'The bracket in the column formula is the squash load of the section, '
      'the concrete on its own area plus the steel on its own, and TWO things '
      'multiply it. The first, 0.80 for a tied column, is an allowance for '
      'eccentricity: no column is really loaded down its middle, floors land '
      'a little off center and members are built a little out of plumb, so '
      'rather than ask for a moment nobody can predict the code takes a flat '
      'fifth off. It belongs to columns alone, and seeing it in a problem '
      'tells you what you are looking at. The second is phi, and for a tied '
      'column in compression it is 0.65, the smallest in the code, because a '
      'column that crushes gives no warning and takes the floors above with '
      'it. A SPIRAL improves both to 0.85 and 0.75, because a spiral confines '
      'the core and buys toughness. Dropping either multiplier is the wrong '
      'answer the exam offers most often.',
  formulas: [
    ('Tied', r'\phi P_n = 0.80\phi\left[0.85f_c^{\prime}(A_g - A_{st}) + A_{st}f_y\right]'),
    ('Tied factors', r'0.80 \text{ and } \phi = 0.65'),
    ('Spiral factors', r'0.85 \text{ and } \phi = 0.75'),
  ],
  figure: BriefFigure.columnFactors,
  handbook: 'Handbook, reinforced concrete',
);

const steelWindowBrief = BriefSection(
  title: 'One per cent to eight',
  body:
      'The longitudinal steel in a column has a window round it and both ends '
      'are there for a reason. Below one per cent the column behaves like '
      'plain concrete as soon as any bending arrives, and plain concrete '
      'fails without warning; the minimum also covers creep and shrinkage, '
      'which quietly hand load from the concrete to whatever steel is there '
      'to take it. Above eight per cent there is nowhere to put the bars: '
      'they cannot be lapped, and concrete cannot be got down between them, '
      'so the cage that was drawn is not the cage that gets built. Both '
      'limits are INCLUSIVE, so a column landing exactly on one per cent is '
      'inside. Most real columns sit near two per cent. Check the window '
      'before working anything out, because a capacity computed for a column '
      'outside it is not a capacity anybody may use.',
  formulas: [
    ('The ratio', r'\rho_g = \frac{A_{st}}{A_g}'),
    ('The window', r'0.01 \le \rho_g \le 0.08'),
    ('Where most land', r'\rho_g \approx 0.02'),
  ],
  figure: BriefFigure.steelWindow,
  handbook: 'Handbook, reinforced concrete',
);

const bracingBrief = BriefSection(
  title: 'The same beam is worth different amounts',
  body:
      'A steel beam\'s bending capacity is not a property of the section on '
      'its own: it depends on how often the compression flange is held '
      'against going sideways. Three bands, and each shape brings its own two '
      'limits from the table. Braced closer together than the first limit, '
      'the beam reaches its full plastic moment and the whole buckling check '
      'can be skipped, which is what a problem means when it says fully '
      'braced or continuously supported. Between the two limits the capacity '
      'slides down a straight line from the plastic moment toward a lower '
      'value, interpolating on the unbraced length. Past the second limit the '
      'flange goes over while the steel is still elastic and the beam never '
      'gets near yielding. A beam in that last band is being decided by its '
      'bracing rather than its steel, and another brace is a better answer '
      'than a heavier section.',
  formulas: [
    ('Fully braced', r'L_b \le L_p \Rightarrow M_n = M_p = F_y Z_x'),
    ('In between', r'L_p < L_b \le L_r \Rightarrow \text{straight line down}'),
    ('Past it', r'L_b > L_r \Rightarrow \text{elastic buckling}'),
  ],
  figure: BriefFigure.bracing,
  handbook: 'Handbook, steel beams',
);

const modulusBrief = BriefSection(
  title: 'Two moduli, one shape',
  body:
      'Every steel shape carries two section moduli and they are not '
      'interchangeable. S, the elastic modulus, describes the section when '
      'its outermost fiber has just reached yield, with the stress varying '
      'straight across the depth. Z, the plastic modulus, describes the same '
      'section yielded right through, half of it at yield in tension and half '
      'in compression, and for a rolled W shape it is the larger by ten to '
      'fifteen per cent. The plastic moment uses Z, and it does so in BOTH '
      'design methods: the nominal strength belongs to the member, and the '
      'methods differ only in what they do with it afterward, 0.90 times in '
      'LRFD against divided by 1.67 in allowable stress design. S appears '
      'wherever the steel is still elastic, which in this lesson means inside '
      'the buckling equation. Using S where Z was wanted costs about a tenth '
      'of the capacity and looks entirely plausible.',
  formulas: [
    ('Yielded through', r'M_p = F_y Z_x'),
    ('First yield', r'M_y = F_y S_x'),
    ('The gap', r'Z_x \approx 1.1 \text{ to } 1.15\, S_x'),
  ],
  figure: BriefFigure.moduli,
  handbook: 'Handbook, steel beams',
);

const flangeBrief = BriefSection(
  title: 'Hold the flange that is being squashed',
  body:
      'Lateral-torsional buckling is the compression flange going over '
      'sideways and dragging the section into a twist, so a brace only counts '
      'if it holds THAT flange and stops the twist. Which flange that is '
      'depends on which way the beam is bending. Sagging in the middle of a '
      'span, it is the top one, and a slab cast on it braces it continuously '
      'for nothing. Hogging over an interior support, the bending is the '
      'other way round and the BOTTOM flange is in compression, with the slab '
      'sitting uselessly overhead: that region needs bracing underneath, and '
      'forgetting it is a real mistake rather than an exam trick. A member '
      'that merely stops the beam moving down is not a brace at all. Shear is '
      'a separate story and belongs to the web: the whole depth times the web '
      'thickness, at 0.6 of the yield stress.',
  formulas: [
    ('Sagging', r'\text{top flange in compression}'),
    ('Hogging', r'\text{bottom flange in compression}'),
    ('Shear', r'V_n = 0.6 F_y A_w'),
  ],
  figure: BriefFigure.flanges,
  handbook: 'Handbook, steel beams',
);

const axisBrief = BriefSection(
  title: 'Each axis brings its own length',
  body:
      'That a bare column folds about its weak axis is a mechanics of '
      'materials idea and it holds only while both directions are held the '
      'same way. In a real frame they rarely are: a wall or a beam catches '
      'the column partway up in ONE direction and does nothing in the other. '
      'A brace shortens the free length for the axis it is fitted to and for '
      'no other, so the two directions have to be worked out separately, each '
      'with its own radius and its own length, and the LARGER of the two '
      'slendernesses decides the column. Halving the shallow length divides '
      'that slenderness by two, so the deep way takes over only when its '
      'radius is less than twice the shallow one. Stocky shapes chosen as '
      'columns usually are; deep shapes chosen as beams are not. And once the '
      'deep way has taken over, further bracing the shallow way buys nothing '
      'at all.',
  formulas: [
    ('Each axis', r'\frac{K L}{r} \text{ with its own } L \text{ and } r'),
    ('Which wins', r'\text{the larger ratio}'),
    ('One brace', r'\text{halves } L \text{ for that axis only}'),
  ],
  figure: BriefFigure.whichAxis,
  handbook: 'Handbook, steel columns',
);

const tableBrief3 = BriefSection(
  title: 'The table has done the hard part',
  body:
      'Two formulas give the critical stress, one for columns stocky enough '
      'to squash partly before they go and one for those that buckle while '
      'still elastic, and the exam does not want either worked out: the '
      'column table gives a DESIGN stress directly for any slenderness, with '
      'the resistance factor already inside it. So the whole calculation is '
      'that stress times the gross area, and applying 0.90 a second time '
      'takes another tenth off a column that has already paid. Two things are '
      'worth carrying beside it. The yield stress times the area is the '
      'squash load, the answer for a column of no length at all, and it is '
      'the wrong answer offered most often. And once a column is slender '
      'enough to buckle elastically, the stress it goes at depends on '
      'STIFFNESS rather than strength, so a higher grade of steel buys '
      'nothing: a stockier shape or another brace is what helps.',
  formulas: [
    ('The whole of it', r'\phi_c P_n = (\phi_c F_{cr}) A_g'),
    ('Zero length', r'F_y A_g'),
    ('Elastic branch', r'F_e = \frac{\pi^2 E}{(KL/r)^2}'),
  ],
  figure: BriefFigure.columnTable,
  handbook: 'Handbook, steel columns',
);

const twoLimitsBrief = BriefSection(
  title: 'Two ways to lose a tension member',
  body:
      'A member in tension has two limit states and both are always checked, '
      'with the smaller design strength deciding what the member is worth. '
      'YIELDING is the whole bar stretching, so it uses the GROSS area with '
      'nothing taken off for holes, the yield stress, and a factor of 0.90: a '
      'few inches of steel yielding beside a bolt hole does not lose anybody '
      'a building, so the check is made on the section that represents most '
      'of the length. RUPTURE is a tear across one cross-section, so it uses '
      'the EFFECTIVE NET area through the line of holes, the ultimate stress, '
      'and a factor of 0.75, the smaller factor because a fracture arrives '
      'without warning. The ultimate stress is well above the yield stress, '
      'which makes people assume yielding always wins; it does not, because '
      'the holes take area away and the factor is lower, and the two together '
      'usually swallow the difference.',
  formulas: [
    ('Yielding', r'\phi P_n = 0.90 F_y A_g'),
    ('Rupture', r'\phi P_n = 0.75 F_u A_e'),
    ('The member', r'\min \text{ of the two}'),
  ],
  figure: BriefFigure.twoLimits,
  handbook: 'Handbook, tension members',
);

const netAreaBrief = BriefSection(
  title: 'The hole is bigger than the bolt',
  body:
      'Three sentences cover the net area and each of them is a wrong answer '
      'somewhere. First, a hole costs the bolt diameter PLUS an eighth of an '
      'inch: a sixteenth so the bolt goes in and another sixteenth written '
      'off because punching tears the steel at the edge. A seven-eighths bolt '
      'therefore costs a full inch of width. Second, the allowance comes off '
      'the WIDTH, and the reduced width is multiplied by the thickness '
      'afterward, so the same bolt costs more area in a thicker plate; '
      'subtracting it from the area instead is wrong by a factor of the '
      'thickness. Third, only the holes lying on ONE cross-section come off '
      'that section, so bolts strung out along the line of pull do not add '
      'up, which is much of why connections are made long rather than wide. '
      'None of this touches the gross area that the yielding check uses.',
  formulas: [
    ('Each hole', r'd_b + \tfrac{1}{8}\text{ in}'),
    ('The net area', r'A_n = \left[b_g - \Sigma(d_b + \tfrac{1}{8})\right] t'),
    ('Where it applies', r'\text{the rupture check only}'),
  ],
  figure: BriefFigure.netArea,
  handbook: 'Handbook, tension members',
);

const shearLagBrief = BriefSection(
  title: 'Load needs room to spread',
  body:
      'When a member is connected through only part of its section, the load '
      'arrives in the connected part and has to work its way across into the '
      'rest, and that takes LENGTH. Right at the critical section the '
      'spreading has hardly begun, so the far-off parts are not yet pulling '
      'their share and the whole net area is not really working. The factor U '
      'is how much of it is, and the effective net area is U times the net '
      'area. Bolted right across the width, as a flat bar is, U is one and '
      'there is nothing to allow for. Through one leg of an angle, or through '
      'the flanges of a W with the web left out, U is less than one. The fix '
      'is a LONGER connection, since U is one less the distance out to the '
      'centroid divided by the connection length. Bigger bolts do not help: '
      'their holes take more area away. And the whole idea belongs to the '
      'rupture check, never to yielding, which happens far from the '
      'connection where the load has long since spread itself out.',
  formulas: [
    ('Effective', r'A_e = U A_n'),
    ('The factor', r'U = 1 - \bar{x}/L'),
    ('A flat bar', r'U = 1.0'),
  ],
  figure: BriefFigure.shearLag,
  handbook: 'Handbook, tension members',
);

const phaseBrief = BriefSection(
  title: 'Every property is one part over another',
  body:
      'A soil sample is solids, water and air, and the phase diagram draws it '
      'as three blocks with the VOLUMES down one side and the WEIGHTS down '
      'the other. Every index property in the lesson is one part of that '
      'picture divided by another, and the denominators are deliberately not '
      'all the same. Void ratio is the voids over the SOLIDS, which is why it '
      'can pass one: squeeze a soil and the voids shrink while the solids do '
      'not, so the bottom of that fraction never moves. Porosity is the same '
      'voids over the WHOLE sample, so it cannot reach one at all. Saturation '
      'is the water over the voids, asking how much of the available space is '
      'wet. And water content is the odd one out, the only one taken from the '
      'weight side, water over SOLIDS, which is why a soft clay can hold more '
      'than 100 per cent.',
  formulas: [
    ('Void ratio', r'e = \frac{V_v}{V_s}'),
    ('Porosity', r'n = \frac{V_v}{V} = \frac{e}{1+e}'),
    ('Water content', r'\omega = \frac{W_w}{W_s}'),
  ],
  figure: BriefFigure.phaseDiagram,
  handbook: 'Handbook, soil phase relationships',
);

const masterBrief = BriefSection(
  title: 'The line that crosses the diagram',
  body:
      'Water content lives on the weight side and void ratio and saturation '
      'live on the volume side, so something has to carry you between them. '
      'That something is the specific gravity, and the relationship it sits '
      'in is S times e equals w times Gs. At FULL saturation the S becomes '
      'one and the void ratio is simply w times Gs, which unlocks it from two '
      'numbers any lab reports as a matter of routine. Only then, though: '
      'with air still in the voids the void ratio is w times Gs divided by S, '
      'which is LARGER, so assuming saturation the stem never claimed makes '
      'the answer come out small. Two habits keep it safe. Put the water '
      'content in as a decimal, since the formula wants 0.20 and the lab '
      'reports 20. And sanity-check the result: real void ratios run from '
      'about 0.3 in dense sand to perhaps 3 in a very soft clay.',
  formulas: [
    ('The bridge', r'S e = \omega G_s'),
    ('Saturated', r'e = \omega G_s'),
    ('Backwards', r'\omega = \frac{e}{G_s} \text{ when } S = 1'),
  ],
  figure: BriefFigure.masterRelation,
  handbook: 'Handbook, soil phase relationships',
);

const gammaBrief = BriefSection(
  title: 'One soil, four weights',
  body:
      'A problem will name whichever unit weight it likes and they are not '
      'interchangeable. DRY is the solids alone over the volume the sample '
      'occupies in the ground, which is why compaction is always specified '
      'against it: it describes how tightly the grains are packed and does '
      'not move with the weather. TOTAL is the sample as it stands, with '
      'whatever water happened to be in it, and dividing it by one plus the '
      'water content lands you on the dry weight. SATURATED is the heaviest, '
      'every void full, the same skeleton with its empty spaces filled. '
      'SUBMERGED is the smallest by far, the saturated weight less the weight '
      'of water, because below the water table the grains float in their own '
      'pore water and pass on only what is left. Using the total weight below '
      'the water table overstates the stress, and the next lesson is built on '
      'getting this one right.',
  formulas: [
    ('From total', r'\gamma_d = \frac{\gamma}{1+\omega}'),
    ('Saturated', r'\gamma_{sat} = \frac{(G_s + e)\gamma_w}{1+e}'),
    ('Submerged', r"\gamma' = \gamma_{sat} - \gamma_w"),
  ],
  figure: BriefFigure.unitWeights,
  handbook: 'Handbook, soil phase relationships',
);

const forkBrief = BriefSection(
  title: 'The first sieve asks the first question',
  body:
      'Classification is a decision tree and the marks are lost at the top of '
      'it. The No. 200 sieve comes first, every time: more than half retained '
      'and the soil is COARSE, judged on the shape of its grain size curve, '
      'and otherwise it is FINE, judged on the plasticity chart with its '
      'coarse grains playing no part at all. The two halves of the tree share '
      'nothing, so taking the wrong branch makes every careful step after it '
      'answer a different question. A coarse soil then splits at the No. 4: '
      'most of the coarse fraction passing makes it a sand, most retained '
      'makes it a gravel, and that fork matters because a gravel needs a '
      'uniformity of only 4 where a sand needs 6. Note which side of the '
      'boundary belongs where: it takes MORE than half retained to be coarse, '
      'so an even split goes to the plasticity chart.',
  formulas: [
    ('First', r'\text{No. 200: coarse or fine}'),
    ('Then', r'\text{No. 4: gravel or sand}'),
    ('Fine soils', r'\text{the plasticity chart}'),
  ],
  figure: BriefFigure.uscsTree,
  handbook: 'Handbook, soil classification',
);

const chartBrief = BriefSection(
  title: 'Two lines, four quarters',
  body:
      'A fine-grained soil is classified by where its point lands on the '
      'plasticity chart, and the chart is only two lines. The A-LINE runs '
      'across it, clays above and silts below, and that split is a statement '
      'about behavior rather than a name: a silt drains and settles quickly '
      'while a clay holds its water and keeps moving for years. The LIQUID '
      'LIMIT of 50 runs down it, low plasticity to the left and high to the '
      'right. Four quarters, four symbols: CL, CH, ML, MH. The quarter people '
      'forget is MH, a soil that holds a great deal of water and is still not '
      'a clay, because a high liquid limit on its own does not put a point '
      'above the A-line. Near the line the plasticity index is worth reading '
      'carefully: seven points can be the difference between a clay and a '
      'silt at the same liquid limit.',
  formulas: [
    ('The A-line', r'PI = 0.73(LL - 20)'),
    ('Above it', r'\text{clay, C}'),
    ('Past LL 50', r'\text{high plasticity, H}'),
  ],
  figure: BriefFigure.plasticityChart,
  handbook: 'Handbook, soil classification',
);

const gradationBrief = BriefSection(
  title: 'Both coefficients, or it is poorly graded',
  body:
      'A coarse soil earns its W only if BOTH numbers pass, and the lesson '
      'says so twice because one of them passing is what tempts people. The '
      'UNIFORMITY, D60 over D10, asks whether the sample spans a wide range '
      'of sizes: a gravel needs 4 and a sand needs 6. The CONCAVITY, D30 '
      'squared over D10 times D60, asks whether the middle of that range is '
      'actually there, and it has to land between 1 and 3. A soil with a '
      'huge uniformity and a failing concavity is GAP graded: plenty of '
      'coarse, plenty of fine, and almost nothing between them, which packs '
      'like neither half. What both coefficients are really asking is whether '
      'the small grains can fill the spaces between the big ones, because '
      'that is what makes a fill compact to something dense and strong.',
  formulas: [
    ('Uniformity', r'C_u = \frac{D_{60}}{D_{10}}'),
    ('Concavity', r'C_c = \frac{D_{30}^2}{D_{10} D_{60}}'),
    ('Well graded', r'\text{both, or neither counts}'),
  ],
  figure: BriefFigure.gradation,
  handbook: 'Handbook, soil classification',
);

const threeStressBrief = BriefSection(
  title: 'Three stresses at every point',
  body:
      'TOTAL stress is the weight of everything above the point: the grains, '
      'the water in their pores, and anything stacked on the surface. It is '
      'the easiest of the three to work out and on its own it decides '
      'nothing. WATER pressure is the height of water above the point times '
      'the unit weight of water, and the height is measured from the WATER '
      'TABLE down, not from the ground surface. Above the water table it is '
      'zero. EFFECTIVE stress is what is left when the water pressure is '
      'taken off, and it is the one that matters: how strong the soil is and '
      'how much it settles both follow from it and from nothing else. A '
      'surcharge shows the difference neatly, since it adds its full weight '
      'to the total, leaves the water alone, and therefore lands entirely on '
      'the grains.',
  formulas: [
    ('The whole of it', r"\sigma' = \sigma - u"),
    ('Water pressure', r'u = h_w \gamma_w'),
    ('Above the table', r"u = 0, \; \sigma' = \sigma"),
  ],
  figure: BriefFigure.threeStresses,
  handbook: 'Handbook, effective stress',
);

const waterTableBrief = BriefSection(
  title: 'Move the water, move the stress',
  body:
      'Every interesting thing in this lesson is a direction rather than a '
      'number. Pump the water table DOWN and the water pressure falls while '
      'the total stress barely moves, so the grains take up the slack and the '
      'effective stress RISES: that is dewatering, and it is why the ground '
      'settles and why pumping on one site can crack a building on the next. '
      'Let the water table RISE and buoyancy takes its share back, the '
      'effective stress falls, and a slope that stood all summer can go after '
      'a week of rain. A SURCHARGE adds to the total and nothing to the '
      'water, so all of it lands on the grains, which is why fill is piled on '
      'a soft site deliberately and taken away again once the settlement has '
      'happened. And standing water over an already saturated site changes '
      'NOTHING, because it adds the same amount to both sides of the '
      'subtraction.',
  formulas: [
    ('Pump it down', r"u \downarrow \Rightarrow \sigma' \uparrow"),
    ('Surcharge', r"q \Rightarrow \sigma' \uparrow \text{ by } q"),
    ('Standing water', r"\sigma \uparrow, \; u \uparrow, \; \sigma' \text{ flat}"),
  ],
  figure: BriefFigure.waterTable,
  handbook: 'Handbook, effective stress',
);

const shortWayBrief = BriefSection(
  title: 'Walk it down, buoyant below',
  body:
      'Two routes reach the same answer. The long one adds up the total '
      'stress and subtracts the water pressure at the end. The short one '
      'walks down the profile adding each layer as it goes, using the layer '
      'own weight ABOVE the water table and the SUBMERGED weight below it, '
      'which for most soils is roughly half as much. They agree exactly, '
      'because taking the water pressure off at the end is the same as taking '
      'a foot of water off every foot of submerged soil on the way down. Two '
      'rules keep the short way honest. Never buoy a layer that sits above '
      'the water table: there is no water up there holding anything up, and '
      'doing it understates the effective stress by 62 pounds a square foot '
      'for every foot. And a surcharge is never buoyed either, since it '
      'presses on everything below it and the water pressure does not notice '
      'it at all.',
  formulas: [
    ('Above the table', r'\gamma H'),
    ('Below it', r"\gamma' H = (\gamma_{sat} - \gamma_w) H"),
    ('A surcharge', r'q, \text{ in full}'),
  ],
  figure: BriefFigure.buoyantWalk,
  handbook: 'Handbook, effective stress',
);

const caseBrief = BriefSection(
  title: 'Everything turns on what it remembers',
  body:
      'Three settlement formulas sit in the handbook and choosing between '
      'them is the whole of the hard part. What decides is the PRECONSOLIDATION '
      'pressure, the largest effective stress the clay has ever carried. If '
      'the load leaves the clay still under that memory, the whole move is '
      'recompression and uses the stiff index alone. If the clay is already '
      'at its memory, which is what NORMALLY CONSOLIDATED means, every pound '
      'is virgin ground on the soft index. And if the load CROSSES the '
      'memory, the move has to be split: stiff from where it starts up to the '
      'memory, soft from the memory to where it ends. Running a crossing move '
      'on one index alone is the wrong answer the exam offers most often, and '
      'it is offered in both flavors.',
  formulas: [
    ('Under the memory', r'\Delta H = \frac{H_0}{1+e_0} C_r \log\frac{p_1}{p_0}'),
    ('On the virgin line', r'\Delta H = \frac{H_0}{1+e_0} C_c \log\frac{p_1}{p_0}'),
    ('Crossing it', r'C_r \log\frac{p_c}{p_0} + C_c \log\frac{p_1}{p_c}'),
  ],
  figure: BriefFigure.settlementCase,
  handbook: 'Handbook, consolidation',
);

const memoryBrief = BriefSection(
  title: 'A shallow line, a corner, a steep one',
  body:
      'Plot the void ratio against the log of the stress and a clay draws two '
      'straight lines with a corner between them. The corner is the largest '
      'pressure the clay has ever carried. To the left of it the clay is '
      'being pushed back over ground it has covered before and it goes '
      'stiffly, on an index about a SIXTH of the other. To the right the clay '
      'is doing something new and the grains rearrange in earnest. So the '
      'same load on the same clay can settle six times as much depending only '
      'on which side of the corner it lands, which is why the '
      'preconsolidation pressure is worth paying a lab to find. A clay comes '
      'by its memory honestly: ground that has since been eroded away, ice '
      'that has melted, or simply drying, which shrinks a clay as fiercely as '
      'a load. And because the formula takes a log, equal RATIOS settle '
      'equally: the first few hundred pounds on a lightly loaded clay cost '
      'far more than the same few hundred added later.',
  formulas: [
    ('The two indexes', r'C_r \approx C_c / 6'),
    ('From the limits', r'C_c \approx 0.009(LL - 10)'),
    ('Equal ratios', r'\log\frac{2p}{p} = \log\frac{4p}{2p}'),
  ],
  figure: BriefFigure.clayMemory,
  handbook: 'Handbook, consolidation',
);

const drainageBrief = BriefSection(
  title: 'How far the water has to go',
  body:
      'How MUCH a clay settles and how LONG it takes are separate questions '
      'with separate inputs. The time turns on the drainage path, which is '
      'the longest journey any squeezed-out water has to make to escape: HALF '
      'the layer when sand lies above and below, since the unluckiest drop is '
      'in the middle and can go either way, and the WHOLE layer when one face '
      'is rock. And the time goes as the SQUARE of that path, so a single '
      'impermeable boundary makes the wait four times as long, and so does '
      'doubling the thickness. That square is also why vertical sand drains '
      'work so well: cut the journey to a tenth and the wait falls to a '
      'hundredth. What does NOT change the schedule is the size of the load: '
      'a bigger load settles further, not slower, and half of a large '
      'settlement arrives on the same day as half of a small one.',
  formulas: [
    ('The time', r't = \frac{T_v H_{dr}^2}{c_v}'),
    ('Both faces drain', r'H_{dr} = H/2'),
    ('One face only', r'H_{dr} = H, \text{ four times the wait}'),
  ],
  figure: BriefFigure.drainagePath,
  handbook: 'Handbook, consolidation',
);

const mohrCoulombBrief = BriefSection(
  title: 'A constant, plus what pressing buys',
  body:
      'Shear strength has two terms and which of them a soil has decides how '
      'it behaves. COHESION is there whatever happens, the part that holds a '
      'clay together on its own. FRICTION grows in proportion to how hard the '
      'grains are pressed, so it is worth nothing at the surface and a great '
      'deal at depth. A clean sand has friction only: its envelope starts at '
      'the origin, which is why dry sand cannot stand in a vertical face and '
      'why the same sand is far stronger thirty feet down. A saturated clay '
      'loaded faster than its water can escape has cohesion only, with the '
      'friction angle taken as zero, because squeezing it harder raises the '
      'pore pressure instead of pressing the grains: its envelope is flat and '
      'one number describes the whole layer. Most real soils have some of '
      'each, and the two are added.',
  formulas: [
    ('The criterion', r"\tau_f = c' + \sigma_N' \tan\phi'"),
    ('A clean sand', r"c' = 0"),
    ('A fast-loaded clay', r'\phi_u = 0, \; \tau_f = c_u'),
  ],
  figure: BriefFigure.mohrCoulomb,
  handbook: 'Handbook, shear strength',
);

const drainedBrief = BriefSection(
  title: 'It is a question about time',
  body:
      'Soil strength comes in two matched sets and they never mix. The '
      'EFFECTIVE set, c prime and phi prime, goes with effective stresses and '
      'describes the soil once the water has had time to move. The UNDRAINED '
      'set, a single strength with no friction angle, goes with TOTAL '
      'stresses and describes a saturated clay loaded faster than its water '
      'can escape. Which one a problem wants is a question about time rather '
      'than about the soil: a tank filled in a day is an undrained problem, '
      'the same tank twenty years later is an effective stress problem, and '
      'the clay is STRONGER in the second one, which is the opposite of how '
      'most materials behave. A sand drains as fast as it is loaded, so its '
      'undrained case never really exists. The trap the lesson names is '
      'taking a parameter from one set and a stress from the other: an '
      'effective friction angle on a total stress overstates the strength by '
      'the pore pressure times its tangent.',
  formulas: [
    ('Long term', r"c', \phi' \text{ with } \sigma'"),
    ('Short term', r'c_u, \phi_u = 0 \text{ with } \sigma'),
    ('Undrained strength', r'c_u = \frac{\sigma_1 - \sigma_3}{2}'),
  ],
  figure: BriefFigure.drainage,
  handbook: 'Handbook, shear strength',
);

const mohrCircleBrief = BriefSection(
  title: 'What the test circle tells you',
  body:
      'A triaxial test gives two stresses and the circle turns them into the '
      'two that matter: the MIDDLE, which is their average, and the RADIUS, '
      'which is half their difference. Every point on that circle is the '
      'normal stress and shear on some plane through the sample, and the '
      'point where it touches the envelope is the plane that gave way. Two '
      'readings follow. A flat undrained envelope touches the circle at its '
      'top, one radius up, so the undrained strength is HALF the deviator, '
      'and quoting the whole of it overstates the clay by a factor of two. '
      'And for a soil with no cohesion the envelope runs through the origin, '
      'which makes a right triangle whose hypotenuse is the distance to the '
      'center: the SINE of the friction angle is the radius over the middle. '
      'Reaching for the arctangent there is the wrong answer the lesson '
      'prints.',
  formulas: [
    ('Middle and radius', r's = \frac{\sigma_1+\sigma_3}{2}, \; t = \frac{\sigma_1-\sigma_3}{2}'),
    ('No cohesion', r'\sin\phi = t/s'),
    ('Undrained', r'c_u = t'),
  ],
  figure: BriefFigure.soilCircle,
  handbook: 'Handbook, shear strength',
);

const flowNetBrief = BriefSection(
  title: 'Two counts, the right way up',
  body:
      'A flow net turns a seepage problem into two counts. The CHANNELS are '
      'the lanes between flow lines, each carrying the same share of the '
      'water, so the count is one less than the number of lines drawn. The '
      'DROPS are equal steps of head: twelve of them across six meters means '
      'half a meter each, and counting drops is how the head at any point in '
      'the ground is read. The seepage is the conductivity times the head '
      'times CHANNELS OVER DROPS, and the fraction has to be that way up: '
      'more lanes means more water, more steps means the head is being spent '
      'more gradually. Turning it over is the wrong answer the lesson prints '
      'and it is out by a factor of nine. One more thing worth knowing: the '
      'net itself is geometry. Make the soil ten times more permeable and the '
      'drawing does not change at all, only the quantity it is multiplied '
      'by.',
  formulas: [
    ('The seepage', r'q = k H \frac{N_f}{N_d}'),
    ('Each step', r'\Delta h = H / N_d'),
    ('A deeper wall', r'N_d \uparrow \Rightarrow q \downarrow'),
  ],
  figure: BriefFigure.flowNet,
  handbook: 'Handbook, seepage',
);

const quickBrief = BriefSection(
  title: 'When the grains stop pressing',
  body:
      'Water climbing through a sand drags on every grain it passes, and when '
      'that drag matches what the grains weigh under water there is nothing '
      'left pressing them together: the effective stress reaches zero, and a '
      'sand whose strength was all friction has none at all. It behaves like '
      'a heavy liquid, which is what a quick condition means. The gradient at '
      'which this happens is the BUOYANT unit weight over the unit weight of '
      'water, which works out as the specific gravity less one over one plus '
      'the void ratio. For ordinary sands that lands near one, though rarely '
      'exactly one, and a loose sand boils at less because there is less '
      'solid in it to hold down. The factor of safety is the critical '
      'gradient over the actual exit gradient, and when it is uncomfortable '
      'the fix is to make the water travel further, or to put a filter and '
      'some weight where it comes out.',
  formulas: [
    ('The critical gradient', r"i_c = \frac{\gamma'}{\gamma_w} = \frac{G_s - 1}{1 + e}"),
    ('Safety', r'FS = i_c / i_{exit}'),
    ('At boiling', r"\sigma' = 0"),
  ],
  figure: BriefFigure.quickCondition,
  handbook: 'Handbook, seepage',
);

const infiniteSlopeBrief = BriefSection(
  title: 'Flatter than its friction angle',
  body:
      'A dry slope of cohesionless soil is the one case in the chapter with a '
      'one-line answer: it stands as long as it is FLATTER than the friction '
      'angle of the soil, and the factor of safety is the tangent of the '
      'friction angle over the tangent of the slope. Depth and unit weight '
      'cancel out of it completely, because a deeper slice weighs more, which '
      'drives it harder, and presses down harder, which holds it better, in '
      'exactly equal measure. So the answer is a pair of angles and nothing '
      'else. At the friction angle exactly the factor of safety is one and '
      'the slope is at its angle of repose, which is the slope a poured heap '
      'settles at on its own, and is not a design. Compacting a sand raises '
      'its friction angle, which is most of why fill is compacted at all.',
  formulas: [
    ('Dry and cohesionless', r'FS = \frac{\tan\phi}{\tan\beta}'),
    ('It stands when', r'\beta < \phi'),
    ('What cancels', r'\text{depth and unit weight}'),
  ],
  figure: BriefFigure.infiniteSlope,
  handbook: 'Handbook, slope stability',
);

const seepageSlopeBrief = BriefSection(
  title: 'Rain halves it',
  body:
      'Steady seepage running down a slope roughly HALVES the factor of '
      'safety, and the reason is worth carrying: the full weight of the soil '
      'still drives the slide, while buoyancy leaves only the submerged '
      'weight pressing the grains together to make friction. The factor it '
      'brings is the buoyant unit weight over the saturated one, which for '
      'ordinary soils is about a half. So a slope that stood at 1.85 dry is '
      'at 0.93 wet, which is past failing, and a slope that stood at 1.1 dry '
      'is nowhere at all. Nothing was added and nothing was dug out: it '
      'rained. That is why slopes that have stood for twenty summers go in a '
      'wet winter, why a cut should be designed for the state it will spend '
      'its worst week in, and why draining a slope is worth a doubling all on '
      'its own.',
  formulas: [
    ('With seepage', r"FS = \frac{\gamma'}{\gamma_{sat}}\cdot\frac{\tan\phi}{\tan\beta}"),
    ('The factor', r"\gamma'/\gamma_{sat} \approx 0.5"),
    ('The fix', r'\text{flatten it, or drain it}'),
  ],
  figure: BriefFigure.slopeSeepage,
  handbook: 'Handbook, slope stability',
);

const wedgeBrief = BriefSection(
  title: 'Everything holding, over everything driving',
  body:
      'A block of soil on a planar slip surface shows plainly what a factor '
      'of safety is. The weight does BOTH jobs: its component along the '
      'plane, the weight times the sine, drives the slide, and its component '
      'across the plane, the weight times the cosine, presses the block down '
      'and buys friction in proportion. The angle of the plane decides how '
      'the weight is split between those two, which is why a steeper slip '
      'surface is the dangerous one. Then the cohesion adds a third term, the '
      'cohesion times the LENGTH of the surface, which owes nothing to the '
      'weight: that is what saves shallow slips, where a thin wedge has '
      'little friction to call on but just as much surface. Drop the cohesion '
      'term by accident and a factor of safety of 1.5 becomes 0.8, which is '
      'the wrong answer the lesson prints.',
  formulas: [
    ('The general form', r'FS = \frac{\text{resisting}}{\text{driving}}'),
    ('A wedge', r'FS = \frac{cL_s + W\cos\alpha\tan\phi}{W\sin\alpha}'),
    ('Cohesion', r'\text{owes nothing to } W'),
  ],
  figure: BriefFigure.slipWedge,
  handbook: 'Handbook, slope stability',
);

const terzaghiBrief = BriefSection(
  title: 'Three terms, and what kills each',
  body:
      'The bearing capacity equation is a sum of three, and most problems '
      'kill one of them before any arithmetic starts. The COHESION term is '
      'the soil holding itself together, and a clean sand has none. The DEPTH '
      'term is the soil beside the footing, which has to be lifted and pushed '
      'out of the way before the footing can punch down, so a footing laid on '
      'the surface loses it entirely, and on a clean sand that is most of the '
      'capacity. The WIDTH term comes from the weight of soil under the '
      'footing shearing sideways, and for an undrained clay its factor is '
      'ZERO, so it contributes nothing however wide the footing is. When a '
      'soil has both cohesion and friction all three are there, and the '
      'cohesion term is usually the largest. The factors themselves are '
      'always given in the question: nothing about them needs remembering.',
  formulas: [
    ('The whole of it', r"q_{ult} = cN_c + \gamma' D_f N_q + \tfrac{1}{2}\gamma' B N_\gamma"),
    ('Undrained clay', r'q_{ult} = 5.14 c_u + \gamma D_f'),
    ('A clean sand', r'c = 0, \text{ so the first term goes}'),
  ],
  figure: BriefFigure.threeTerms,
  handbook: 'Handbook, bearing capacity',
);

const footingFixBrief = BriefSection(
  title: 'Widening and burying are not the same',
  body:
      'A footing short of capacity can be made wider or buried deeper, and '
      'which of those helps is decided by the soil. On a SAND both work and '
      'burying works better, because the depth factor is larger than the '
      'width factor and the width term is halved besides. On an UNDRAINED '
      'CLAY widening raises the pressure the soil can take by nothing at all, '
      'since the term the width would have grown has a factor of zero: '
      'widening still spreads the structural load over more area, which helps '
      'the structure, but the ground is not getting any stronger. Burying '
      'works on both, and the reason is physical: a bearing failure is soil '
      'squeezing sideways and up, so the deeper the footing sits the more '
      'soil is in the way. One more thing to watch: both of those terms are '
      'weights, so a water table rising above the footing halves them.',
  formulas: [
    ('On clay', r'N_\gamma = 0, \text{ width buys nothing}'),
    ('On sand', r'N_q > N_\gamma, \text{ depth buys more}'),
    ('Under water', r"\gamma \to \gamma', \text{ both terms halve}"),
  ],
  figure: BriefFigure.footingFix,
  handbook: 'Handbook, bearing capacity',
);

const allowableBrief = BriefSection(
  title: 'Divide the capacity, not the load',
  body:
      'The equation gives the pressure at which the soil FAILS, and nobody '
      'builds to that. A factor of safety, usually three for bearing, divides '
      'the ultimate capacity to give an allowable pressure, and it is that '
      'allowable pressure the real foundation pressure is compared with: '
      'pressure against pressure, so the column load has to be spread over '
      'the footing area first. Dividing the load instead, or forgetting to '
      'divide at all, are the two wrong answers the lesson prints side by '
      'side. Three is larger than the factors used on manufactured materials '
      'for good reasons: the soil is known from a handful of boreholes, it '
      'varies between them, and a bearing failure gives no warning and cannot '
      'be repaired from above. And passing this check says nothing about '
      'SETTLEMENT, which on a soft clay is usually the one that decides the '
      'footing.',
  formulas: [
    ('Allowable', r'q_{allow} = q_{ult} / FS'),
    ('The comparison', r'\frac{P}{A} \le q_{allow}'),
    ('The other check', r'\text{settlement, separately}'),
  ],
  figure: BriefFigure.allowablePressure,
  handbook: 'Handbook, bearing capacity',
);

const threeChecksBrief = BriefSection(
  title: 'Three checks, three quantities',
  body:
      'A retaining wall has to pass three separate tests and they compare '
      'three different kinds of thing. OVERTURNING is a contest of MOMENTS '
      'about the toe: the weight of the wall and the soil on its heel '
      'holding it down, against the earth pressure trying to turn it. '
      'SLIDING is a contest of FORCES along the base, the friction under the '
      'footing against the push. BEARING is a contest of PRESSURES, what the '
      'soil can carry against what the base puts on it. In all three what '
      'RESISTS goes on top, so a number above one is safe and upside down is '
      'the classic slip: a third where three belongs. The minimums differ, '
      'roughly one and a half for sliding, one and a half to two for '
      'overturning, and about three for bearing, and they do not trade '
      'against one another. A wall that will not tip but will slide is a '
      'wall that slides.',
  formulas: [
    ('Overturning', r'FS = \Sigma M_R / M_O'),
    ('Sliding', r'FS = \Sigma F_R / \Sigma F_D'),
    ('Bearing', r'FS = q_{ult} / q_{applied}'),
  ],
  figure: BriefFigure.threeChecks,
  handbook: 'Handbook, retaining wall stability',
);

const middleThirdBrief = BriefSection(
  title: 'From the toe, then from the middle',
  body:
      'Two distances come out of this calculation and only the second one is '
      'the eccentricity. First find where the resultant of the vertical '
      'forces crosses the base, measured from the TOE: the net moment, '
      'resisting minus overturning, divided by the vertical force. Then the '
      'eccentricity is how far THAT is from the middle of the base. '
      'Reporting the first as the second is the wrong answer the lesson '
      'prints, and it is easy to catch, because the distance from the toe is '
      'usually far too big to be an eccentricity. Keep the resultant within '
      'a sixth of the base either side of center and it stays in the middle '
      'third, which means the whole base stays pressed into the soil. Beyond '
      'that the arithmetic starts asking the heel to pull down on the ground, '
      'and soil does not pull.',
  formulas: [
    ('From the toe', r'\bar{x} = (\Sigma M_R - M_O)/\Sigma V'),
    ('Off center', r'e = B/2 - \bar{x}'),
    ('The middle third', r'e \leq B/6'),
  ],
  figure: BriefFigure.middleThird,
  handbook: 'Handbook, retaining wall stability',
);

const basePressureBrief = BriefSection(
  title: 'Uniform only when centered',
  body:
      'The pressure under a footing is the load over the base ONLY when the '
      'load lands dead center, and a retaining wall is the one footing that '
      'almost never does, because something is pushing it sideways by '
      'definition. Off center, the pressure tilts into a trapezoid with the '
      'most under the toe, the end everything is leaning toward. The 6e/B '
      'term is that tilt and nothing else: set the eccentricity to zero and '
      'the bracket becomes one and the formula falls back to the average. '
      'The two ends straddle that average, so if the toe is above it the '
      'heel is below it by the same amount, which is a free check on any '
      'answer. And the whole formula holds only while the resultant is '
      'inside the middle third.',
  formulas: [
    ('At the toe', r'q = \tfrac{\Sigma V}{B}\left(1 + \tfrac{6e}{B}\right)'),
    ('At the heel', r'q = \tfrac{\Sigma V}{B}\left(1 - \tfrac{6e}{B}\right)'),
    ('Centered', r'e = 0 \Rightarrow q = \Sigma V / B'),
  ],
  figure: BriefFigure.basePressure,
  handbook: 'Handbook, retaining wall stability',
);

const proctorBrief = BriefSection(
  title: 'A hump, not a slope',
  body:
      'Compaction squeezes AIR out, and water is only its helper. Dry of the '
      'optimum the grains grind and will not slide into place, so adding '
      'water makes the soil denser. Past the optimum the voids are nearly '
      'full and the water holds the grains apart, so adding more makes it '
      'LOOSER, and no number of roller passes will get it back. The peak of '
      'that hump is the laboratory maximum dry unit weight for one soil at '
      'one compaction effort, which is why a specification has to say which '
      'Proctor it means: the modified test uses more effort, produces a '
      'higher maximum, and so gives a lower percentage for the same fill. '
      'Relative compaction is the field value over the laboratory one, that '
      'way up. Upside down, a short fill reads as just over a hundred per '
      'cent and passes.',
  formulas: [
    ('Relative compaction', r'RC = \tfrac{\gamma_{d,field}}{\gamma_{d,max}} \times 100'),
    ('Typical specification', r'RC \geq 90\text{ to }95\%'),
    ('Upside down', r'\text{reads just over }100\%'),
  ],
  figure: BriefFigure.proctor,
  handbook: 'Handbook, compaction',
);

const relativeDensityBrief = BriefSection(
  title: 'Two ways to say how tight',
  body:
      'Relative COMPACTION compares a field dry unit weight against a '
      'laboratory Proctor maximum, and any soil with a Proctor test can be '
      'checked that way. Relative DENSITY is for clean sands and gravels, '
      'and it asks something different: how far the in-place void ratio sits '
      'between the loosest and the tightest packings that soil can be got '
      'into. The measurement runs from the LOOSE end, so a low void ratio, '
      'meaning tightly packed, gives a HIGH percentage. Start from the other '
      'end and the two answers always add to a hundred, which is what gives '
      'the mistake away. The two measures compare against different things, '
      'share no terms, and are not interchangeable.',
  formulas: [
    ('Relative density', r'D_r = \tfrac{e_{max} - e}{e_{max} - e_{min}} \times 100'),
    ('The wrong end', r'\tfrac{e - e_{min}}{e_{max} - e_{min}}'),
    ('Together', r'\text{the two add to }100\%'),
  ],
  figure: BriefFigure.relativeDensity,
  handbook: 'Handbook, relative density',
);

const stabilizerBrief = BriefSection(
  title: 'Match the help to the soil',
  body:
      'When rolling alone will not do, the soil gets help, and which help '
      'depends on what the soil is. LIME goes into plastic clays: it reacts '
      'with the clay minerals, brings the plasticity index down and stops '
      'the swelling. CEMENT goes into granular and low-plasticity soils, '
      'where it binds the grains into something stiff; in a fat clay it can '
      'hardly be mixed through. A GEOSYNTHETIC is not chemistry at all: it '
      'separates a stone base from the mud under it, reinforces, or drains. '
      'And where water is what keeps coming back, DRAINAGE comes before any '
      'of them, because water will undo every treatment you pay for.',
  formulas: [
    ('Plastic clay', r'\text{lime}'),
    ('Granular soil', r'\text{cement}'),
    ('Water first', r'\text{drainage}'),
  ],
  figure: BriefFigure.stabilizer,
  handbook: 'Handbook, soil stabilization',
);

const pileCapacityBrief = BriefSection(
  title: 'Two resistances, two areas',
  body:
      'A pile holds a load up in two places at once. The TIP works like a '
      'very small footing, and its resistance is a pressure times the area '
      'of the tip, which is a fraction of a square meter. The SHAFT grips '
      'the soil all the way down, and its resistance is a much smaller '
      'pressure times the surface area of the whole side of the pile, which '
      'runs into tens of square meters. Add the two. Reporting either one on '
      'its own is the wrong answer the lesson prints twice, and putting the '
      'shaft area with the tip resistance throws the answer out by a factor '
      'of fifty. Which one dominates depends on where the pile ends: driven '
      'onto rock it is nearly all tip, and long in uniform clay it is nearly '
      'all shaft. In a friction pile, length buys capacity and width buys '
      'very little.',
  formulas: [
    ('Together', r'Q_{ult} = Q_p + Q_s'),
    ('Each part', r'Q_{ult} = q_p A_p + f_s A_s'),
    ('The areas', r'A_p \text{ is small}, \; A_s \text{ is large}'),
  ],
  figure: BriefFigure.pileCapacity,
  handbook: 'Handbook, deep foundations',
);

const goingDeepBrief = BriefSection(
  title: 'Past the layer that settles',
  body:
      'Piles are chosen to carry a load THROUGH ground that would settle and '
      'hand it to something firm below. Not because they are cheap, since '
      'they usually are not, and never to press the weak layer harder. Note '
      'that the deciding question is often settlement rather than strength: '
      'a soft clay can be strong enough not to fail and still drop a '
      'building further than it can stand. Once piles come in a GROUP the '
      'arithmetic changes again. The piles are close enough to work the same '
      'soil as their neighbors, so in clay the group carries LESS than the '
      'sum of the singles, and the group efficiency is below one. And '
      'because the whole cap acts as one wide load, the stressed ground '
      'reaches much deeper than any single pile would reach, so the group '
      'settles more and is checked as a block.',
  formulas: [
    ('Why deep', r'\text{settlement, not price}'),
    ('Group in clay', r'\text{efficiency} < 1'),
    ('Group settlement', r'\text{deeper, so more}'),
  ],
  figure: BriefFigure.goingDeep,
  handbook: 'Handbook, deep foundations',
);

const downdragBrief = BriefSection(
  title: 'The friction that is a load',
  body:
      'Shaft friction points whichever way the RELATIVE movement tells it '
      'to, and that is the only thing deciding it. A pile pushed down '
      'through still soil rubs upward against it: the friction holds the '
      'pile up and counts toward capacity. Soil settling PAST a pile, as '
      'when new fill squeezes a compressible clay for years, rubs downward '
      'on the shaft and hangs on it. That is negative skin friction, or '
      'downdrag, and it costs twice: the drag goes onto the load side of the '
      'sum, and the stretch of shaft doing the dragging gives no resistance '
      'either. It is never capacity. Same surface, same grip, opposite sign.',
  formulas: [
    ('Normally', r'\text{soil resists: } +Q_s'),
    ('Settling ground', r'\text{soil drags: an added load}'),
    ('Decided by', r'\text{which one moves down}'),
  ],
  figure: BriefFigure.downdrag,
  handbook: 'Handbook, deep foundations',
);

const sightDistanceBrief = BriefSection(
  title: 'Thinking, then braking',
  body:
      'Stopping sight distance is two stretches of road laid end to end. The '
      'first is covered while the driver has not noticed anything yet, at '
      'full speed the whole way: speed times reaction time, with a 1.47 in '
      'front only to turn miles per hour into feet per second. The second is '
      'the braking distance. Add them. Reporting either one alone is the '
      'wrong answer the lesson prints, twice. They also grow differently: '
      'the thinking stretch grows straight with speed and straight with '
      'reaction time, while braking grows with the SQUARE of the speed. So '
      'at 30 mph most of the distance is spent not reacting, at 60 mph most '
      'of it is spent braking, and doubling a design speed more than doubles '
      'the sight distance it needs.',
  formulas: [
    ('Thinking', r'1.47\,V t'),
    ('Braking', r'\dfrac{V^2}{30\left(\frac{a}{32.2} \pm G\right)}'),
    ('The 1.47', r'5{,}280/3{,}600'),
  ],
  figure: BriefFigure.sightDistance,
  handbook: 'Handbook, stopping sight distance',
);

const gradeSignBrief = BriefSection(
  title: 'Uphill helps, downhill hurts',
  body:
      'The grade goes into the denominator of the braking term as a '
      'FRACTION, positive uphill and negative downhill. Climbing, the car\'s '
      'own weight pulls it back and helps the brakes, so the denominator is '
      'larger, the braking distance smaller and the sight distance SHORTER. '
      'Descending, the weight pushes the car along, the denominator shrinks '
      'and the distance is LONGER. Only the braking half moves: during the '
      'thinking stretch nothing has happened yet and the car covers the same '
      'ground on any hill. Reversing the sign on the lesson\'s own four per '
      'cent grade moves the answer about eighty feet, and always toward less '
      'sight distance than the road really needs.',
  formulas: [
    ('Uphill', r'+G \Rightarrow \text{shorter}'),
    ('Downhill', r'-G \Rightarrow \text{longer}'),
    ('As a fraction', r'4\% \Rightarrow 0.04'),
  ],
  figure: BriefFigure.gradeSign,
  handbook: 'Handbook, stopping sight distance',
);

const peakHourBrief = BriefSection(
  title: 'Designed for the surge',
  body:
      'An hour of traffic does not arrive evenly, and a road either works '
      'during its busiest fifteen minutes or it does not. So the design flow '
      'rate is what the hour WOULD come to at the rate of that worst '
      'quarter: four times the fifteen minute count. That number is always '
      'at least the hourly volume, and an answer below the volume is wrong '
      'before the arithmetic is checked. The peak hour factor is the volume '
      'divided by that rate. It runs from 0.25, the whole hour in one '
      'quarter, to 1.00, perfectly even, with real roads around 0.85 to '
      '0.95. Read the direction carefully: a LOW factor means a peaky hour '
      'and a HIGH design flow.',
  formulas: [
    ('Flow rate', r'4 \times V_{15}'),
    ('The factor', r'PHF = \dfrac{V}{4 V_{15}}'),
    ('Its range', r'0.25 \leq PHF \leq 1.00'),
  ],
  figure: BriefFigure.peakHour,
  handbook: 'Handbook, peak hour factor',
);

const crestSagBrief = BriefSection(
  title: 'Seeing over, or lighting into',
  body:
      'Both kinds of vertical curve are sized by sight distance, but by very '
      'different pictures of it. A CREST is limited by the hilltop itself '
      'blocking the view: eye at three and a half feet, object at two, and '
      'the flatter the curve the further ahead the driver sees. Its formula '
      'divides by 2,158, a constant. A SAG is fine by day and limited at '
      'NIGHT, because the headlight beam tips only about a degree up and the '
      'road curves away from it. Its formula divides by 400 plus three and a '
      'half times the sight distance, which moves as the sight distance '
      'does. That is the quickest way to tell them apart: if the bottom of '
      'the fraction has an S in it, it is a sag. Both come in two versions. '
      'Start by assuming the sight distance fits inside the curve, work the '
      'length, then check it: if the length comes out shorter than the sight '
      'distance, switch.',
  formulas: [
    ('Crest', r'L = \dfrac{A S^2}{2{,}158}'),
    ('Sag', r'L = \dfrac{A S^2}{400 + 3.5S}'),
    ('Then check', r'S \leq L ?'),
  ],
  figure: BriefFigure.crestSag,
  handbook: 'Handbook, vertical curves',
);

const gradeBreakBrief = BriefSection(
  title: 'How much the grade changes',
  body:
      'A is the algebraic difference between the two grades, taken as a size '
      'and quoted in per cent. Grades on OPPOSITE sides add: plus three into '
      'minus five is a break of eight, not two, and that is the mistake the '
      'lesson is built around. Grades on the SAME side subtract: minus two '
      'into minus five is a break of three. Which kind of curve it is does '
      'not depend on any sign either, only on whether the second grade is '
      'LESS than the first, which makes a crest, or more, which makes a sag. '
      'Everything else follows from A: twice the break in the same length is '
      'twice the offset and half the K, where K is the length over the '
      'break, feet of curve per per cent, and a bigger K is a flatter curve.',
  formulas: [
    ('The break', r'A = |g_2 - g_1|'),
    ('A crest', r'g_2 < g_1'),
    ('Rate of curvature', r'K = L / A'),
  ],
  figure: BriefFigure.gradeBreak,
  handbook: 'Handbook, vertical curves',
);

const superelevationBrief = BriefSection(
  title: 'The tires and the tilt',
  body:
      'A curve asks for the design speed SQUARED over fifteen times the '
      'radius, and two things supply it: the sideways grip of the tires, '
      'which is the side friction factor, and the tilt of the pavement '
      'toward the inside of the turn, which is the superelevation. The '
      'friction is help already in hand, so it comes OFF the demand and what '
      'is left is what the tilt has to provide. Forgetting it asks the '
      'pavement for the whole demand, which on the lesson\'s curve is 22.5 '
      'per cent, a tilt no road is built at: a stopped vehicle would slide '
      'into the ditch. The rate is quoted in per cent, which is what the '
      '0.01 in the formula is for, so an answer of 0.075 per cent is the '
      'right number with the wrong label on it. Of the three quantities the '
      'designer really chooses only two, the radius and the tilt: friction '
      'belongs to the tire and the pavement.',
  formulas: [
    ('What the curve asks', r'0.01e + f = \dfrac{V^2}{15R}'),
    ('What is left', r'0.01e = \dfrac{V^2}{15R} - f'),
    ('The levers', r'2V \Rightarrow 4\times, \; 2R \Rightarrow \tfrac{1}{2}'),
  ],
  figure: BriefFigure.superelevation,
  handbook: 'Handbook, superelevation',
);

const yellowBrief = BriefSection(
  title: 'A second, then the stop',
  body:
      'The yellow interval exists so that a driver approaching the light can '
      'either stop comfortably or carry on through, with no stretch of road '
      'where neither is possible. It is a moment to react, about a second, '
      'plus the time to shed the approach speed. That second part is the '
      'speed over TWICE the deceleration, because a car slowing steadily '
      'averages half its speed over the stop. Every quantity is in feet and '
      'seconds: the deceleration is feet per second squared, so the speed '
      'must be feet per second, and 1.467 makes the swap from miles per '
      'hour. On a 50 mph approach the right answer is about 4.7 seconds. '
      'Miles per hour straight in gives 3.5. No reaction time gives 3.7. No '
      'two in the denominator gives 8.3. The grade enters through the 64.4, '
      'which is twice gravity, plus for up and minus for down.',
  formulas: [
    ('The yellow', r'y = t + \dfrac{v}{2a \pm 64.4G}'),
    ('The units', r'1\text{ mph} = 1.467\text{ ft/s}'),
    ('Why the two', r'\text{it averages half the speed}'),
  ],
  figure: BriefFigure.yellowInterval,
  handbook: 'Handbook, signal timing',
);

const allRedBrief = BriefSection(
  title: 'Until the back bumper is out',
  body:
      'After the yellow, every direction holds a red for a moment. That '
      'moment belongs to one specific vehicle: the one that entered legally '
      'on the yellow and is still inside the intersection. It is clear when '
      'its BACK bumper passes the far curb, not when its nose does, so the '
      'distance to cover is the width curb to curb PLUS the length of the '
      'vehicle. Divide by the approach speed, in feet per second as always. '
      'Forgetting the vehicle length on the lesson\'s crossing gives 0.8 '
      'seconds where 1.1 belongs, a third of the protection gone. Dividing '
      'by miles per hour gives 1.6, which is not seconds at all and is '
      'LARGER than the right answer, so it does not even fail in a safe '
      'direction. A wide crossing on a slow street can want three or four '
      'seconds, and a long design vehicle pushes it further.',
  formulas: [
    ('The all-red', r'r = \dfrac{W + l}{v}'),
    ('Why the length', r'\text{the back bumper decides}'),
    ('The speed', r'\text{feet per second}'),
  ],
  figure: BriefFigure.allRed,
  handbook: 'Handbook, signal timing',
);

const pedestrianGreenBrief = BriefSection(
  title: 'Getting going, walking, and the crowd',
  body:
      'A pedestrian green is three separate things added together. A fixed '
      '3.2 seconds for people to notice the signal and step off the curb, '
      'which does not depend on the road at all. The walk itself, the '
      'crosswalk length over a walking pace of 3.5 feet a second. And about '
      'a quarter of a second for each person waiting, because a crowd takes '
      'time to leave the curb. The pace is deliberately slower than a brisk '
      'adult: the timing is set for the slowest people crossing, and using '
      '4.0 instead shortens the green for exactly the people who need it. '
      'On the lesson\'s crossing the three come to 3.2, 16.0 and 4.1 '
      'seconds, and every wrong answer it prints is one of them dropped or '
      'mis-set.',
  formulas: [
    ('The green', r'G_p = 3.2 + \dfrac{L}{S_p} + 0.27 N'),
    ('The pace', r'S_p = 3.5 \text{ ft/s}'),
    ('The pieces', r'\text{start-up, walk, crowd}'),
  ],
  figure: BriefFigure.pedestrianGreen,
  handbook: 'Handbook, signal timing',
);

const greenshieldsBrief = BriefSection(
  title: 'A quarter of the product',
  body:
      'Flow is speed times density: how fast they are going, times how many '
      'of them there are in a mile. Greenshields assumes the speed falls in '
      'a straight LINE as the lane fills, from the free flow speed on an '
      'empty road to nothing at a jam. A product of one term rising while '
      'another falls peaks in the middle, so maximum flow happens at half '
      'the free flow speed AND half the jam density, and the peak is '
      'therefore a QUARTER of their product. Forget the four and you report '
      'the product itself, which is the lesson\'s wrong answer. Two things '
      'are worth carrying away. Maximum flow is not a comfortable road: it '
      'is a crowded one at half speed, on the edge of breaking down. And '
      'every flow below the peak happens at TWO densities, one either side, '
      'which is why level of service is judged on density rather than '
      'volume.',
  formulas: [
    ('The fundamentals', r'V = S \times D'),
    ('The peak', r'V_m = \dfrac{D_j S_f}{4}'),
    ('Where it sits', r'D_o = D_j/2, \; S_o = S_f/2'),
  ],
  figure: BriefFigure.greenshields,
  handbook: 'Handbook, traffic flow',
);

const speedDensityBrief = BriefSection(
  title: 'Start full, subtract the traffic',
  body:
      'The speed line is the free flow speed LESS what the traffic already '
      'there has taken away, and the answer is the difference, never either '
      'piece on its own. The piece that is subtracted is the free flow speed '
      'over the jam density, times the density, and that first part is '
      'simply the slope of the line: how much speed each extra vehicle a '
      'mile costs. Two traps sit here. Reporting the reduction instead of '
      'what is left, and reaching for half the free flow speed when the '
      'density is not half the jam density, since those halves go together '
      'and apart from each other mean nothing. One free check: nothing on '
      'the road can be faster than the free flow speed, so any answer above '
      'it is wrong before it is examined.',
  formulas: [
    ('The line', r'S = S_f - \dfrac{S_f}{D_j} D'),
    ('The slope', r'\dfrac{S_f}{D_j} \text{ mph per veh/mi}'),
    ('The ceiling', r'S \leq S_f \text{ always}'),
  ],
  figure: BriefFigure.speedDensity,
  handbook: 'Handbook, traffic flow',
);

const crashRateBrief = BriefSection(
  title: 'Crashes over what was exposed',
  body:
      'A crash count on its own cannot rank anything: a busy junction has '
      'more crashes than a quiet one simply by having more vehicles. The '
      'rate divides the crashes by the traffic exposed to them, and building '
      'that denominator is the whole job. A daily count has to be '
      'ANNUALIZED, so a year of crashes sits over a year of traffic: the '
      'daily figure times 365. Dividing by the daily count instead gives an '
      'answer in the thousands, which cannot be right, since it claims more '
      'crashes than vehicles. The million is there to bring the answer into '
      'a range people can read. For a junction the exposure is entering '
      'VEHICLES, and for a stretch of road it is vehicle MILES, because a '
      'vehicle on three miles of highway is exposed three times as long.',
  formulas: [
    ('A junction', r'RMEV = \dfrac{A \times 10^6}{ADT \times 365}'),
    ('A segment', r'RMVM = \dfrac{A \times 10^6}{ADT \times 365 \times L}'),
    ('The point', r'\text{a count alone ranks nothing}'),
  ],
  figure: BriefFigure.crashRate,
  handbook: 'Handbook, crash rates',
);

const heavyVehicleBrief = BriefSection(
  title: 'A truck is two cars, or three',
  body:
      'Capacity is a question about ROOM, so everything is counted in '
      'passenger cars. A truck is longer, pulls away slowly and needs a '
      'bigger gap, so on level ground it takes the space of two cars and on '
      'rolling ground three. Only the EXTRA space counts, which is why the '
      'formula carries the equivalent less one. A tenth of trucks on the '
      'level means a hundred vehicles fill a hundred and ten car spaces, so '
      'the factor is one over 1.10, about 0.909. It is always between zero '
      'and one, and it is DIVIDED by, which pushes the flow rate up: the '
      'traffic is worse than the raw count suggests. Two things go wrong '
      'here. Reporting the denominator, which gives a factor above one and '
      'is impossible. And using the wrong terrain, which on the lesson\'s '
      'numbers moves the factor from 0.909 to 0.833.',
  formulas: [
    ('The factor', r'f_{HV} = \dfrac{1}{1 + P_T(E_T - 1)}'),
    ('The equivalents', r'E_T = 2 \text{ level}, \; 3 \text{ rolling}'),
    ('Its range', r'0 < f_{HV} \leq 1'),
  ],
  figure: BriefFigure.heavyVehicle,
  handbook: 'Handbook, freeway capacity',
);

const demandFlowBrief = BriefSection(
  title: 'One volume, three divisions',
  body:
      'The demand flow rate is not the traffic on the road: it is passenger '
      'cars an hour in ONE lane at the rate of the busiest quarter hour, and '
      'three divisions get it there. By the peak hour factor, which turns '
      'the hour into the rate its worst quarter implies, and which the sight '
      'distance lesson already covered. By the number of lanes, to get one '
      'lane. And by the heavy vehicle factor, to count in cars. The two '
      'factors are under one so dividing by them raises the answer, while '
      'dividing by the lanes lowers it: knowing which way each step should '
      'move the number catches most mistakes. On the lesson\'s freeway the '
      'answer is 1,793. Leave out the trucks and it is 1,630. Leave out the '
      'peak factor and it is 1,650. Two wrong answers of nearly the same '
      'size from two different omissions.',
  formulas: [
    ('The flow rate', r'v_p = \dfrac{V}{PHF \times N \times f_{HV}}'),
    ('It is per lane', r'\text{and in passenger cars}'),
    ('Direction', r'\text{factors raise it, lanes lower it}'),
  ],
  figure: BriefFigure.demandFlow,
  handbook: 'Handbook, freeway capacity',
);

const levelOfServiceBrief = BriefSection(
  title: 'The letter comes off the density',
  body:
      'Level of service is read against DENSITY, in vehicles to a mile of '
      'lane, not against volume and not against speed. Two roads can carry '
      'the same volume at quite different densities, and speed holds near '
      'its free flow value until a road is nearly full, so neither of those '
      'sorts the letters out. Work the flow per lane first, then divide by '
      'the mean speed, which follows from flow being speed times density and '
      'checks out in the units: cars an hour over miles an hour leaves cars '
      'a mile. Then read the band. The bands are narrow near capacity, so a '
      'single missing adjustment moves the letter: forgetting the trucks on '
      'the lesson\'s road gives 33 a mile instead of 37, which reads as D '
      'rather than E.',
  formulas: [
    ('The density', r'D = v_p / S'),
    ('The bands', r'A \leq 11, \; B \leq 18, \; C \leq 26'),
    ('And on', r'D \leq 35, \; E \leq 45, \; F \text{ above}'),
  ],
  figure: BriefFigure.levelOfService,
  handbook: 'Handbook, level of service',
);

const fourStepBrief = BriefSection(
  title: 'Four steps, in order',
  body:
      'A regional travel forecast is four models run one after another, each '
      'consuming what the one before it made. GENERATION counts how many '
      'trips each zone produces and attracts, from land use: a quantity and '
      'nothing else. DISTRIBUTION decides where those trips go, and this is '
      'where the gravity model works. MODE CHOICE splits them among car, '
      'transit and foot. ASSIGNMENT loads them onto particular routes, and '
      'produces the volumes a designer actually uses. The order is not a '
      'convention, it is a dependency: distribution has nothing to share out '
      'until generation has produced it. Worth remembering which step a '
      'change lands in. A new employer moves attractions, so distribution '
      'notices. A new fare moves mode choice. A new bridge moves '
      'assignment.',
  formulas: [
    ('First, how many', r'\text{generation}'),
    ('Then, where', r'\text{distribution}'),
    ('Then how, then which road', r'\text{mode, assignment}'),
  ],
  figure: BriefFigure.fourStep,
  handbook: 'Handbook, travel demand',
);

const gravityBrief = BriefSection(
  title: 'Shares that add to one',
  body:
      'The gravity model gives every destination a WEIGHT, its attractions '
      'times the friction factor for that trip, and then shares the '
      'origin\'s trips out in proportion to those weights. The step people '
      'drop is the last one: dividing by the SUM of all the weights. Without '
      'it the shares do not add to one and the model sends out more or fewer '
      'trips than the origin ever made. Using the attractions alone is the '
      'other wrong answer the lesson prints, and it fails in a particular '
      'way: it hands trips to a big destination that is too far away to '
      'earn them. Two checks come free. The shares add to one, and the trips '
      'add to the origin\'s productions exactly.',
  formulas: [
    ('The weight', r'A_j F_{ij} K_{ij}'),
    ('The share', r'T_{ij} = P_i \dfrac{A_j F_{ij} K_{ij}}{\sum_j A_j F_{ij} K_{ij}}'),
    ('The check', r'\textstyle\sum_j T_{ij} = P_i'),
  ],
  figure: BriefFigure.gravity,
  handbook: 'Handbook, gravity model',
);

const frictionBrief = BriefSection(
  title: 'Big attracts, far repels',
  body:
      'The friction factor is the part of the model that behaves like '
      'distance in gravity itself: it FALLS as the travel time between two '
      'zones rises, so distant destinations receive fewer trips. The name '
      'misleads a little, because a HIGH friction factor means an EASY trip. '
      'It is written that way so it can multiply the attractions directly. '
      'Distance does not always win, though. A destination five times the '
      'size can still take the majority of the trips despite being much '
      'harder to reach, which is why a regional mall draws from half a '
      'county. And when a new road cuts the travel time, the factor rises '
      'and trips move toward that zone, without the origin producing a '
      'single extra trip: distribution moves trips, it does not create '
      'them. The K factor is a correction for what the model cannot see, '
      'and it is one when there is nothing to correct.',
  formulas: [
    ('Longer trip', r'F_{ij} \text{ falls}'),
    ('The balance', r'A_j \text{ up against } F_{ij} \text{ down}'),
    ('No new trips', r'\textstyle\sum_j T_{ij} = P_i \text{ still}'),
  ],
  figure: BriefFigure.friction,
  handbook: 'Handbook, gravity model',
);

const signCategoryBrief = BriefSection(
  title: 'Shape first, then the words',
  body:
      'A sign carries its category in its shape and color, before a word of '
      'it is read. REGULATORY signs impose a legal requirement and are '
      'mostly white rectangles with black legends, with two shapes held '
      'back for the two messages that must be readable at any angle: the red '
      'octagon for STOP and the triangle for YIELD. WARNING signs are yellow '
      'diamonds and describe what is ahead without requiring anything, which '
      'is why a speed on a warning sign is advisory and sits on its own '
      'yellow plate. GUIDE signs are green and carry directions, distances '
      'and destinations, and ask nothing at all. The point of the manual is '
      'that this holds everywhere, so a driver recognizes a sign before '
      'reading it, and the recognition is what buys the reaction time.',
  formulas: [
    ('Regulatory', r'\text{white rectangle, red octagon}'),
    ('Warning', r'\text{yellow diamond}'),
    ('Guide', r'\text{green}'),
  ],
  figure: BriefFigure.signCategory,
  handbook: 'MUTCD, sign categories',
);

const warrantBrief = BriefSection(
  title: 'A signal has to earn its place',
  body:
      'A traffic signal is not automatically an improvement. It stops '
      'traffic that did not have to stop before, so it buys delay and '
      'rear-end crashes, and an unwarranted one teaches drivers to '
      'disregard a red. That is why the manual requires a WARRANT analysis '
      'first. The warrants are not all about vehicle counts: there is one '
      'for eight hours of heavy volume, one for a single very heavy peak '
      'hour, one for people waiting to cross on foot, one for a school '
      'crossing, and one for a crash history the signal would fix. An '
      'intersection can qualify on any single one. And meeting a warrant '
      'makes a signal JUSTIFIED rather than required: engineering judgment '
      'still decides, and sometimes decides on a roundabout instead. The '
      'trade a signal makes is the right-angle crash, which injures people, '
      'against the rear-end crash, which usually does not.',
  formulas: [
    ('Before installing', r'\text{a warrant must be met}'),
    ('Meeting one', r'\text{justified, not required}'),
    ('The trade', r'\text{fewer angle, more rear-end}'),
  ],
  figure: BriefFigure.signalWarrant,
  handbook: 'MUTCD, signal warrants',
);

const structuralNumberBrief = BriefSection(
  title: 'What each inch is worth',
  body:
      'The structural number is one index for the whole flexible section, '
      'and it is a plain sum: for every course, its layer coefficient times '
      'its thickness times its drainage coefficient. An inch of hot mix '
      'asphalt is worth about 0.44, an inch of crushed stone base about '
      '0.14, and an inch of granular subbase about 0.11, so one inch of '
      'asphalt does the structural work of roughly THREE inches of base. '
      'That ratio is the economics of a pavement: designers trade the '
      'courses against each other until the cost is lowest for the same '
      'number. The surface course takes a drainage coefficient of one by '
      'convention, since it is not granular and is not meant to hold water. '
      'The base and subbase take whatever the problem states, and assuming '
      'one when a lower value was given undersizes the pavement.',
  formulas: [
    ('The sum', r'SN = a_1 D_1 + a_2 D_2 m_2 + a_3 D_3 m_3'),
    ('Typical values', r'a \approx 0.44, \; 0.14, \; 0.11'),
    ('The surface', r'm_1 = 1.0 \text{ by convention}'),
  ],
  figure: BriefFigure.structuralNumber,
  handbook: 'Handbook, AASHTO flexible pavement',
);

const layerThicknessBrief = BriefSection(
  title: 'The same sum, read backwards',
  body:
      'With a required structural number and every course but one already '
      'fixed, the missing thickness falls out in two steps: take what the '
      'fixed courses contribute AWAY from the target, then divide what is '
      'left by what an inch of the missing course is worth, its coefficient '
      'times its drainage factor. The drainage factor is where this goes '
      'wrong. A subbase at 0.80 contributes a fifth less than the same '
      'subbase draining properly, and the base has to make that up, which on '
      'the lesson\'s section is nearly two extra inches. A negative answer '
      'is not a mistake either: it means the fixed courses already meet the '
      'target, and a minimum construction thickness will govern instead.',
  formulas: [
    ('Solve for one', r'D_2 = \dfrac{SN - a_1 D_1 - a_3 D_3 m_3}{a_2 m_2}'),
    ('Poor drainage', r'\text{less from that course, more from the rest}'),
    ('Negative', r'\text{already there}'),
  ],
  figure: BriefFigure.layerThickness,
  handbook: 'Handbook, AASHTO flexible pavement',
);

const esalBrief = BriefSection(
  title: 'Counted in standard axles',
  body:
      'Pavement traffic is not counted in vehicles, because the damage an '
      'axle does climbs far faster than its weight, roughly with the fourth '
      'power of the load. So every axle is converted into equivalent '
      'standard eighteen kip single axle loads by its LOAD EQUIVALENCY '
      'FACTOR, and the conversion is a multiplication: passes times factor. '
      'The numbers are worth a feel. A car axle is worth about two ten '
      'thousandths of a standard load, so it takes thousands of cars to '
      'match one loaded truck axle. A 24 kip axle weighs a third more than '
      'the standard and does three times the damage. A 12 kip axle weighs '
      'two thirds as much and does under a fifth. That steepness is why a '
      'road with no trucks lasts almost indefinitely, and why taking a '
      'little weight off an axle takes a great deal of damage off the road. '
      'The total over the design life is what sets the structural number the '
      'section has to reach.',
  formulas: [
    ('The conversion', r'\text{ESALs} = \text{passes} \times LEF'),
    ('The standard', r'18 \text{ kip single axle}'),
    ('Steeply', r'\text{damage} \sim \text{load}^4'),
  ],
  figure: BriefFigure.esal,
  handbook: 'Handbook, load equivalency',
);

const rigidVsFlexibleBrief = BriefSection(
  title: 'A beam, or a blanket',
  body:
      'A concrete slab is stiff enough to BEND across a wheel load, like a '
      'beam, and hand it to a patch of subgrade many times the size of the '
      'tire. An asphalt section does the opposite: each course passes the '
      'load down to the next, spreading it a little on the way, so every '
      'course has to be strong in its own right. Everything else follows '
      'from that. The slab bridges a soft spot the way a beam bridges a gap, '
      'so rigid pavement minds a weak or variable subgrade far less. It is '
      'designed on the bending strength of the concrete, its modulus of '
      'rupture, rather than on a structural number, because bending is how '
      'it works. And it costs more to build, which is why the choice usually '
      'turns on whole life cost: heavy traffic, a long service life and poor '
      'ground favor the slab.',
  formulas: [
    ('Rigid', r'\text{bends, spreads wide}'),
    ('Flexible', r'\text{passes it down, course by course}'),
    ('Designed on', r'\text{rupture strength vs } SN'),
  ],
  figure: BriefFigure.rigidVsFlexible,
  handbook: 'Handbook, rigid pavement',
);

const jointBrief = BriefSection(
  title: 'Smooth lets go, deformed holds on',
  body:
      'Concrete shrinks as it cures and moves with the temperature, so a '
      'slab will crack. Joints decide where. CONTRACTION joints are sawn in '
      'within hours and give the crack a tidy line to follow. EXPANSION '
      'joints leave room for growth, used sparingly and mostly at '
      'structures. CONSTRUCTION joints are simply where paving stopped. The '
      'steel across a joint comes in two kinds and they do opposite jobs. A '
      'DOWEL is smooth and greased: it carries the wheel load from one slab '
      'to the next while letting the two move, and it lives in transverse '
      'joints. A TIE BAR is deformed and bonded into both sides: it holds a '
      'longitudinal joint shut so lanes do not drift apart, and it is meant '
      'not to move at all. Where a joint has no steel, the rough crack faces '
      'below the saw cut interlock instead, which works while the joint '
      'stays tight.',
  formulas: [
    ('Dowel', r'\text{load transfer, movement allowed}'),
    ('Tie bar', r'\text{holds the joint closed}'),
    ('No steel', r'\text{aggregate interlock}'),
  ],
  figure: BriefFigure.pavementJoint,
  handbook: 'Handbook, rigid pavement joints',
);

const subgradeReactionBrief = BriefSection(
  title: 'A bed of springs',
  body:
      'The modulus of subgrade reaction, k, is a STIFFNESS and not a '
      'strength: the pressure it takes to push the ground down one inch, so '
      'its units are pounds per square inch per inch, which is pounds per '
      'cubic inch. The picture is a bed of springs under the slab, each '
      'pushing back as it is pressed. A higher k gives less under the same '
      'pressure, so the slab bends less and the tension at the bottom of the '
      'concrete is lower, which is what actually breaks a slab. What k is '
      'NOT is a bearing capacity: capacity asks when the ground fails, while '
      'k asks how far it moves long before that. And because the slab '
      'already spreads the load so widely, improving k buys less under '
      'concrete than the same improvement would buy under asphalt.',
  formulas: [
    ('What it is', r'k = \dfrac{\text{pressure}}{\text{deflection}}'),
    ('Units', r'\text{pounds per cubic inch}'),
    ('Higher k', r'\text{stiffer, less deflection}'),
  ],
  figure: BriefFigure.subgradeReaction,
  handbook: 'Handbook, rigid pavement',
);

const forwardPassBrief = BriefSection(
  title: 'Two rules and no more',
  body:
      'The forward pass through a network is two rules applied in order. An '
      'activity FINISHES its own duration after it starts, so early finish '
      'is early start plus duration. And it STARTS when the last of the '
      'things it waits on has finished, which is the only rule that matters '
      'at a merge: the latest predecessor governs, never the earliest and '
      'never an average. Two activities waiting on the same thing both begin '
      'the moment it ends, since nothing in the network says they take '
      'turns. Durations in series ADD and never multiply. And watch what the '
      'question asked for: the finish of the activity itself, not the finish '
      'of the one before it and not its own duration, both of which are '
      'numbers sitting right there in the problem.',
  formulas: [
    ('The finish', r'EF = ES + D'),
    ('At a merge', r'ES = \max(EF \text{ of predecessors})'),
    ('In series', r'\text{durations add}'),
  ],
  figure: BriefFigure.forwardPass,
  handbook: 'Handbook, CPM scheduling',
);

const projectDurationBrief = BriefSection(
  title: 'As long as its longest path',
  body:
      'A project takes as long as the LONGEST path through its network. Not '
      'the sum of every duration, which counts parallel work twice over, and '
      'not the longest single activity. Everything off that longest path has '
      'slack: it finishes and then waits, so shortening it changes nothing '
      'at all and money spent accelerating it is wasted. The special case '
      'worth noticing is a network with no branches, where the longest path '
      'IS the sum, which is where the habit of adding everything comes from. '
      'And the longest path is a property of the numbers rather than of the '
      'drawing: lengthen a branch that had slack and the critical route '
      'moves to it, which is why a schedule is re-run rather than drawn '
      'once.',
  formulas: [
    ('The duration', r'\text{the longest path}'),
    ('Not', r'\textstyle\sum \text{all durations}'),
    ('Off the path', r'\text{it has slack}'),
  ],
  figure: BriefFigure.projectDuration,
  handbook: 'Handbook, CPM scheduling',
);

const passesBrief = BriefSection(
  title: 'Forward, then backward',
  body:
      'Two sweeps, opposite ways, answering two different questions. The '
      'FORWARD pass runs from the start and finds the earliest each activity '
      'can happen: add the duration, and at a merge take the LATEST finish '
      'in front of you. The BACKWARD pass runs from the project finish, '
      'which the forward pass has just produced, and finds the latest each '
      'activity can happen without pushing that finish out: subtract the '
      'duration, and where an activity feeds several others take the '
      'EARLIEST of their late starts, since it has to be out of the way for '
      'all of them. That flip is the thing to hold on to. Forward takes the '
      'latest, backward takes the earliest. A late start is a limit and not '
      'a plan: starting earlier is normally wiser, and the gap between the '
      'two is float.',
  formulas: [
    ('Forward', r'EF = ES + D, \; ES = \max(EF_{pred})'),
    ('Backward', r'LS = LF - D, \; LF = \min(LS_{succ})'),
    ('Starts from', r'LF_{last} = \text{the duration}'),
  ],
  figure: BriefFigure.passes,
  handbook: 'Handbook, CPM scheduling',
);

const floatBrief = BriefSection(
  title: 'Room to slip',
  body:
      'TOTAL float is the latest start less the earliest, or equally the '
      'latest finish less the earliest finish: the two give the same number '
      'and checking one against the other is free. It says how far an '
      'activity can slip without the PROJECT finishing later. FREE float '
      'asks a smaller question: how far it can slip without pushing the very '
      'next activity, which is the earliest successor start less this '
      'activity\'s early finish. Free float is never the larger of the two. '
      'Between them lies the ground where a delay pushes the successor but '
      'not the finish date. And total float belongs to the PATH rather than '
      'to the activity: two activities in a row showing four days each are '
      'sharing the same four days, and whichever spends it first takes it '
      'from the other. Zero total float means critical.',
  formulas: [
    ('Total float', r'TF = LS - ES = LF - EF'),
    ('Free float', r'FF = \min(ES_{succ}) - EF'),
    ('Critical', r'TF = 0'),
  ],
  figure: BriefFigure.float,
  handbook: 'Handbook, CPM scheduling',
);

const criticalPathBrief = BriefSection(
  title: 'The chain that decides',
  body:
      'The critical path is the longest path through the network, and it is '
      'also the chain of activities with ZERO total float: the same '
      'activities described two ways, since any slack on the longest path '
      'would mean a longer path existed. Its length is the project duration. '
      'A day lost on it is a day lost to the project, straight through, '
      'because there is no cushion anywhere along it. A day lost OFF it only '
      'spends float, and when that float runs out, that path becomes '
      'critical too. A network can carry two critical paths at once, when '
      'two routes come out the same length, and then shortening only one of '
      'them buys nothing. The practical payoff is the whole reason for the '
      'method: it says exactly where acceleration buys time and where it '
      'buys none.',
  formulas: [
    ('Longest path', r'= \text{the project duration}'),
    ('And also', r'\text{the chain with } TF = 0'),
    ('A day lost there', r'\text{is a day lost to the project}'),
  ],
  figure: BriefFigure.criticalPath,
  handbook: 'Handbook, CPM scheduling',
);

const earnedValueBrief = BriefSection(
  title: 'Three numbers, two subtractions',
  body:
      'On any date a project has three numbers. What the plan said would be '
      'done by now, what the work actually finished is WORTH at budgeted '
      'rates, and what has actually been spent. The middle one, earned '
      'value, is the one that matters, because it is the only one that '
      'reflects progress rather than intentions or invoices. Both variances '
      'start from it. Earned less SPENT is the cost variance: negative means '
      'more money went out than the work was worth, which is over budget. '
      'Earned less PLANNED is the schedule variance: negative means less got '
      'done than the plan called for, which is behind. Two subtractions from '
      'the same starting point, and the commonest mistakes are doing the '
      'wrong one, or getting the sign right and then reading it backwards. '
      'The two are reported separately because a project is often behind and '
      'under budget at once: an efficient crew that is short handed.',
  formulas: [
    ('Cost', r'CV = BCWP - ACWP'),
    ('Schedule', r'SV = BCWP - BCWS'),
    ('Either one', r'\text{negative is bad}'),
  ],
  figure: BriefFigure.earnedValue,
  handbook: 'Handbook, earned value',
);

const forecastBrief = BriefSection(
  title: 'At this rate, what will it cost',
  body:
      'The cost performance index is earned value over actual cost, EARNED '
      'on top, and it says how much value each dollar is buying. Below one '
      'is trouble; turning the ratio over gives a number above one that '
      'looks healthy and is the wrong answer the lesson prints. Both '
      'forecasts assume the rate persists. The estimate to complete is the '
      'budgeted work still to do, the whole budget less what has been '
      'earned, DIVIDED by the index: at eighty cents on the dollar, 1.4 '
      'million of remaining work will cost 1.75 million. Reporting the 1.4 '
      'assumes the crew suddenly starts hitting budget. The estimate at '
      'completion is then what is already spent PLUS that, and each half of '
      'that sum on its own is one of the printed wrong answers. An index of '
      'exactly one makes the division do nothing and lands the forecast back '
      'on the original budget.',
  formulas: [
    ('The index', r'CPI = BCWP / ACWP'),
    ('The rest', r'ETC = (BAC - BCWP)/CPI'),
    ('The whole', r'EAC = ACWP + ETC'),
  ],
  figure: BriefFigure.forecast,
  handbook: 'Handbook, earned value forecasting',
);

const excavationBrief = BriefSection(
  title: 'Five feet, and twenty',
  body:
      'Two depths change what an excavation needs. Past FIVE feet a trench '
      'requires a protective system, and any of three will do: sloping or '
      'benching the sides back to a safe angle, shoring to hold them in '
      'place, or a trench box to protect the people rather than the hole. '
      'Which one gets used is a question of soil, room and cost, not of the '
      'rule, and the weakest soil, type C, needs the flattest slope at one '
      'and a half horizontal to one vertical, which is often what pushes a '
      'job toward a box instead. Past TWENTY feet the system has to be '
      'designed by a registered professional engineer, because the '
      'manufacturer tabulated data most systems rely on stops there. Below '
      'five feet the rule does not bite, which is not the same as the hole '
      'being safe: a cubic yard of soil weighs about as much as a car, and a '
      'trench gives no warning before it comes in.',
  formulas: [
    ('Over five feet', r'\text{sloping, shoring or a box}'),
    ('Over twenty', r'\text{designed by a PE}'),
    ('Type C soil', r'1.5\text{H}:1\text{V}'),
  ],
  figure: BriefFigure.excavation,
  handbook: 'OSHA 29 CFR 1926, excavations',
);

const fallProtectionBrief = BriefSection(
  title: 'Six feet in the air',
  body:
      'Fall protection is required at SIX feet in general construction, and '
      'three things satisfy it: guardrails, which stop the fall happening, '
      'safety nets, which catch the person, and a personal fall arrest '
      'system, a harness and lanyard that stops them short. As with '
      'excavations the rule names an outcome and leaves the method to the '
      'job. Steel erection connectors are the exception worth knowing, with '
      'a trigger of fifteen feet, on the argument that the equipment needed '
      'to protect them lower down creates hazards of its own. Five in the '
      'ground and six in the air are the two numbers that get swapped, and '
      'they are worth one deliberate moment. The engineer meets all of this '
      'in the design and the administration, by designing for '
      'constructability and specifying measures such as shoring where they '
      'are needed, and not by directing the crew: the means and methods '
      'belong to the contractor.',
  formulas: [
    ('General construction', r'6 \text{ ft}'),
    ('Steel connectors', r'15 \text{ ft}'),
    ('The pair', r'5 \text{ down}, \; 6 \text{ up}'),
  ],
  figure: BriefFigure.fallProtection,
  handbook: 'OSHA 29 CFR 1926, fall protection',
);

const yardsBrief = BriefSection(
  title: 'Cut and fill, in yards',
  body:
      'Both volume formulas take whatever units go into them, so sections in '
      'square feet and stations in feet give cubic FEET. Earthwork is bid, '
      'hauled and paid for in cubic YARDS, and a cubic yard is three feet '
      'each way, which is twenty seven cubic feet. Dividing by three instead '
      'leaves the answer nine times too big, and forgetting the conversion '
      'altogether leaves it twenty seven times too big: both are printed as '
      'choices. The average end area method gives the LARGER volume whenever '
      'the real middle section sags below the average of the two ends, which '
      'it usually does, and on a corridor carrying millions of yards a few '
      'per cent is real money. That is why the contract says which method '
      'measures the work. The quantities themselves are what price the cut '
      'and the fill and decide how far material has to be hauled, so a grade '
      'line that balances the two is cheaper than one that does not.',
  formulas: [
    ('End areas', r'V = \frac{L}{2}(A_1 + A_2)'),
    ('Prismoidal', r'V = \frac{L}{6}(A_1 + 4A_m + A_2)'),
    ('Then', r'\div 27 \text{ for cubic yards}'),
  ],
  figure: BriefFigure.yards,
  handbook: 'Handbook, earthwork volumes',
);

const deliveryFitBrief = BriefSection(
  title: 'Matching the method to the job',
  body:
      'Three shapes, and the job in front of you picks one. DESIGN, BID, '
      'BUILD when the drawings are finished and the price has to be '
      'competitive: everything happens in sequence, every bidder prices the '
      'same complete package, and nothing can be fast-tracked because there '
      'is nothing to bid until the design is done. DESIGN-BUILD when speed '
      'and single point responsibility matter more: one agreement covers '
      'both, so construction can start with the design part finished, and '
      'the owner accepts less certainty about what is being built in '
      'exchange. MANAGER AT RISK when the owner wants a builder\'s advice '
      'during design but keeps its own designer: the manager commits to a '
      'GUARANTEED MAXIMUM part way through the design and carries whatever '
      'goes over it, which is what at risk means.',
  formulas: [
    ('Complete drawings, must bid', r'\text{design, bid, build}'),
    ('Speed, one firm', r'\text{design-build}'),
    ('Advice plus a ceiling', r'\text{manager at risk}'),
  ],
  figure: BriefFigure.deliveryFit,
  handbook: 'Handbook, project delivery',
);

const curveConversionBrief = BriefSection(
  title: 'Radius, degree, and the tangent',
  body:
      'A curve is quoted two ways and they run in opposite directions. The '
      'RADIUS is a length and the DEGREE OF CURVE is the angle a hundred '
      'feet of arc turns through, so their product is fixed at 5,729.58 and '
      'a big degree means a sharp curve. Dividing the constant by the degree '
      'gives the radius; multiplying gives an answer in the tens of '
      'thousands of feet, which is not a highway curve but almost a straight '
      'line, and that is enough to catch the slip without redoing it. The '
      'distance from the start of the curve out to the corner is the radius '
      'times the tangent of HALF the turn angle, because the curve is '
      'symmetrical about that corner and each tangent sees half the total '
      'turn. Using the whole angle roughly doubles the answer and is the '
      'mistake the handbook page warns about in as many words.',
  formulas: [
    ('The two quotes', r'R = \dfrac{5{,}729.58}{D}'),
    ('Out to the corner', r'T = R\tan\dfrac{I}{2}'),
    ('Around the arc', r'L = \dfrac{\pi R I}{180}'),
  ],
  figure: BriefFigure.curveConversion,
  handbook: 'Handbook, horizontal curves',
);

const cornerOffsetBrief = BriefSection(
  title: 'How far the road misses the corner',
  body:
      'The two grades cross at a corner no vehicle could drive, and the road '
      'passes inside it: below on a crest, above in a sag. The distance is '
      'the break in grade as a DECIMAL, times the length, over EIGHT. The '
      'eight comes out of the parabola, since the offset grows with the '
      'square of the distance from the start and half way along is a quarter '
      'of the way to the full tangent offset. An L over 4 doubles the answer '
      'and per cent in place of a decimal multiplies it by a hundred, and '
      'both are printed as choices. The offset matters because it is a real '
      'elevation: the corner is known from the grades alone, so this is what '
      'every station elevation and every yard of cut is worked from. Twice '
      'the length is twice the offset, which is why a gentler curve costs '
      'excavation.',
  formulas: [
    ('At the middle', r'E = \dfrac{(g_2 - g_1)L}{8}'),
    ('Because', r'\text{the offset grows as } x^2'),
    ('As a decimal', r'8\% \Rightarrow 0.08'),
  ],
  figure: BriefFigure.cornerOffset,
  handbook: 'Handbook, vertical curves',
);

const stiffnessBrief = BriefSection(
  title: 'A slope, not a height',
  body:
      'Strain is a stretch over an original length, so it has no units at '
      'all. Stress divided by strain, anywhere on the straight part of the '
      'curve, is the ELASTIC MODULUS, and it is the SLOPE of that straight '
      'part. A slope is not a height. Stiffness says how far the thing '
      'stretches under load; STRENGTH is how high the curve goes before the '
      'material gives way; and ductility is how far along it goes before it '
      'breaks. Three questions, three different features of one drawing, and '
      'a material can have any combination: glass is stiff and breaks '
      'without warning, cast iron is stiffer than most steels and much '
      'weaker in tension. Two numbers are worth carrying: structural steel '
      'near 200 GPa and aluminum near 70, which is why an aluminum member of '
      'the same shape deflects about three times as much. A floor that '
      'bounces is a stiffness problem, and specifying a stronger steel '
      'changes almost nothing.',
  formulas: [
    ('Strain', r'\varepsilon = \Delta L / L_0'),
    ('The modulus', r'E = \sigma / \varepsilon'),
    ('Worth carrying', r'E_{steel} \approx 200\text{ GPa}, \; E_{al} \approx 70'),
  ],
  figure: BriefFigure.stiffness,
  handbook: 'Handbook, mechanical properties',
);

const filterRateBrief = BriefSection(
  title: 'Down through the bed',
  body:
      'A filter loading rate is the flow divided by the PLAN area of the '
      'bed, the surface looked at from above, because the water goes '
      'straight down through the sand. Divide by one dimension instead and '
      'the units give it away: a rate per foot is not a rate per square '
      'foot. Ranges matter as much as the arithmetic. Rapid sand filters run '
      'between about two and ten gallons a minute to the square foot, so a '
      'plant at four and a half is mid range, while SLOW sand runs nearer a '
      'tenth of a gallon and therefore needs tens of times the area for the '
      'same flow, buying a biological layer and paying for it in land. Twice '
      'the bed halves the rate, which is the design lever. And note the '
      'family resemblance: a clarifier overflow rate is the same arithmetic '
      'on a different box, quoted per DAY, with an acceptable range in the '
      'hundreds. The pattern carries across and the numbers do not.',
  formulas: [
    ('The rate', r'v = Q / A_{plan}'),
    ('Rapid sand', r'2 \text{ to } 10 \text{ gpm/ft}^2'),
    ('Slow sand', r'\approx 0.1 \text{ gpm/ft}^2'),
  ],
  figure: BriefFigure.filterRate,
  handbook: 'Handbook, filtration',
);

const rankineBrief = BriefSection(
  title: 'Three states of the same soil',
  body:
      'The same soil against the same wall presses with three quite different '
      'forces, and which one applies depends on what the WALL has done. Let '
      'it lean away by even a fraction of an inch and the soil stretches, '
      'takes up some of the load itself, and settles into its ACTIVE state, '
      'the smallest of the three. Hold it perfectly still, as a basement wall '
      'propped by its slab is held, and the soil stays AT REST, which is '
      'noticeably larger: a basement wall designed for active pressure is '
      'under-designed. Push the wall INTO the soil, as the toe of a sliding '
      'wall does, and it answers with PASSIVE pressure, which for a thirty '
      'degree soil is nine times the active value and takes a great deal of '
      'movement to develop. The order never changes, and the active and '
      'passive coefficients are reciprocals: if one is a third the other is '
      'three, which is the fastest check there is against swapping the two '
      'formulas.',
  formulas: [
    ('Active', r'K_a = \tan^2(45 - \phi/2)'),
    ('Passive', r'K_p = \tan^2(45 + \phi/2)'),
    ('At rest', r'K_0 \approx 1 - \sin\phi'),
  ],
  figure: BriefFigure.rankine,
  handbook: 'Handbook, lateral earth pressure',
);

const diagramShapeBrief = BriefSection(
  title: 'A triangle and a rectangle',
  body:
      'Two things press on a retaining wall and they press differently. The '
      'SOIL weighs more the deeper you go, so its pressure runs from nothing '
      'at the surface to its largest at the base: a triangle, whose resultant '
      'acts a THIRD of the height up. A SURCHARGE on the ground behind the '
      'wall presses down everywhere alike and the soil passes a share of it '
      'sideways at every depth, so it adds the same pressure all the way '
      'down: a rectangle, whose resultant acts at MID height. The two forces '
      'add, but their heights do not, so an overturning check has to take '
      'each about its own arm. And a modest surcharge is worth more than it '
      'looks, because its rectangle covers the whole wall while the soil '
      'triangle spends its first few feet near nothing.',
  formulas: [
    ('The soil', r'\tfrac{1}{2}K_a\gamma H^2 \text{ at } H/3'),
    ('A surcharge', r'K_a q H \text{ at } H/2'),
    ('Together', r'\text{they add}'),
  ],
  figure: BriefFigure.pressureShape,
  handbook: 'Handbook, lateral earth pressure',
);

const wallForceBrief = BriefSection(
  title: 'The half and the square',
  body:
      'Two things in the active force formula are worth feeling rather than '
      'memorizing. The HALF is the area of a triangle: the pressure averages '
      'half its value at the base, so the force is that average times the '
      'height. Dropping it doubles the answer, which is the wrong choice the '
      'lesson prints. The SQUARE on the height means a wall twice as tall '
      'carries FOUR times the force, since there is twice as much soil and '
      'twice the pressure at the base and the two multiply. Worse, the '
      'overturning moment grows EIGHT times, because the arm doubles as well. '
      'That cube is why tall walls get expensive out of all proportion to '
      'their height and why a bank is often terraced instead. The unit weight '
      'and the coefficient, by contrast, scale the answer straight. And the '
      'force is only an input: sliding, overturning and bearing are three '
      'separate checks after it.',
  formulas: [
    ('The force', r'P_a = \tfrac{1}{2}K_a\gamma H^2'),
    ('Twice as tall', r'4\times \text{ the force}'),
    ('The moment', r'8\times, \text{ arm and all}'),
  ],
  figure: BriefFigure.wallForce,
  handbook: 'Handbook, lateral earth pressure',
);

const trussRouteBrief = BriefSection(
  title: 'Which one is quicker, and what comes first',
  body:
      'Both methods work on any determinate truss and the choice is about '
      'time. ONE member, especially a chord deep in the truss, wants the '
      'method of SECTIONS: a single cut and a single moment equation against '
      'four or five joints worked in turn. SEVERAL members at one connection '
      'want the method of JOINTS, because that joint is exactly the free body '
      'the question is describing, and near a support it is quicker still '
      'since the reaction is already sitting there. Whichever is used, the '
      'support REACTIONS come first, from the whole truss taken as one free '
      'body: a cut leaves you holding a piece whose other external force is a '
      'reaction, and a joint at a support IS a reaction. Skipping that step '
      'is the commonest way to stall.',
  formulas: [
    ('One member, deep', r'\text{sections}'),
    ('A whole connection', r'\text{joints}'),
    ('Before either', r'\text{the reactions}'),
  ],
  figure: BriefFigure.trussRoute,
  handbook: 'Handbook p. 271',
);

const naturalBrief = BriefSection(
  title: 'Stiffness over mass, under a square root',
  body:
      'One expression carries this whole page: the natural frequency is the '
      'square root of the stiffness over the mass. Stiffer is quicker, heavier '
      'is slower, and the square root softens both, so FOUR times the '
      'stiffness is only twice the frequency. What it depends on is the RATIO '
      'of the two, so doubling both changes nothing at all. What it does not '
      'depend on is how far you pulled it: amplitude appears nowhere in the '
      'formula, and a big swing simply travels further at the same rate. Watch '
      'the two units: omega comes out in radians a second and a question '
      'usually wants hertz, which is omega over two pi. And watch for a WEIGHT '
      'given where the formula wants a mass. Torsion is the same expression '
      'with the torsional stiffness on top and the mass moment of inertia '
      'underneath.',
  formulas: [
    ('Natural frequency', r'\omega_n = \sqrt{\frac{k}{m}}'),
    ('In hertz', r'f_n = \frac{\omega_n}{2\pi}'),
    ('The period', r'T_n = \frac{1}{f_n}'),
    ('Twisting', r'\omega_n = \sqrt{\frac{k_t}{I}}'),
  ],
  figure: BriefFigure.natural,
  handbook: 'Handbook pp. 112 to 113',
);

const resonanceBrief = BriefSection(
  title: 'Resonance is a match, not a property',
  body:
      'A structure does not resonate on its own. Resonance is what happens '
      'when something pushes it AT its natural frequency, so that every push '
      'arrives in time with the last swing and adds to it, and the amplitude '
      'climbs until the damping or the structure gives way. That makes the '
      'design question a comparison: work out the natural frequency, find out '
      'what is going to be shaking it, and keep the two apart. Far above is '
      'safe and far below is safe; only the middle is dangerous. Machine '
      'mountings are deliberately made soft so that the running speed sits '
      'well above the natural frequency, which does mean the machine passes '
      'through resonance on its way up to speed. Before comparing anything, '
      'get both numbers into the same units.',
  formulas: [
    ('Resonance when', r'\omega = \omega_n'),
    ('Same thing in hertz', r'1\ \mathrm{Hz} = 2\pi\ \mathrm{rad/s}'),
    ('And from a machine plate', r'1\ \mathrm{Hz} = 60\ \mathrm{rpm}'),
  ],
  figure: BriefFigure.resonance,
  handbook: 'Handbook p. 112',
);

const dampingBrief = BriefSection(
  title: 'What the damping decides',
  body:
      'Pull a system aside, let it go, and the damping ratio decides what '
      'happens next. UNDER one it swings and dies away inside a shrinking '
      'envelope, which is almost every real structure: buildings and bridges '
      'run at a few percent and ring for a long time. AT one, critically '
      'damped, it returns in the shortest time possible without overshooting '
      'at all, which is what a door closer, a gun recoil and an instrument '
      'needle are tuned to. OVER one it still does not swing and it takes '
      'LONGER, which is the piece people expect to go the other way: past the '
      'critical point, more damping is slower, not quicker. At ZERO it swings '
      'forever at the same height, which nothing real does, and every free '
      'vibration formula on this page, the natural frequency included, is '
      'written for exactly that undamped ideal.',
  formulas: [
    ('Damping ratio', r'\zeta = \frac{c}{2\sqrt{km}} = \frac{c}{c_c}'),
    ('Swings and never shrinks', r'\zeta = 0'),
    ('Swings and decays', r'\zeta < 1'),
    ('Back fastest, no swing', r'\zeta = 1'),
    ('No swing, slower', r'\zeta > 1'),
  ],
  figure: BriefFigure.damping,
  handbook: 'Handbook p. 112',
);

const farFromAxisBrief = BriefSection(
  title: 'Distance does the work',
  body:
      'The moment of inertia is a sum of area times distance SQUARED, so where '
      'the material sits matters far more than how much of it there is. Metal '
      'near the axis is very nearly wasted, because its distance is nearly '
      'zero and squaring it makes it smaller still. For a rectangle the depth '
      'appears cubed and the width only once, which is why turning a joist on '
      'edge multiplies its stiffness many times over for exactly the same '
      'timber, and why an I-beam puts its steel out in the flanges and leaves '
      'the web as thin as shear will allow.',
  formulas: [
    ('What it is', r'I_x = \int y^2\, dA'),
    ('Rectangle', r'I_{xc} = \frac{bh^3}{12}'),
    ('Circle', r'I_{xc} = \frac{\pi r^4}{4}'),
  ],
  figure: BriefFigure.farFromAxis,
  handbook: 'Handbook pp. 98 to 100',
);

const transferBrief = BriefSection(
  title: 'Moving it to another axis',
  body:
      'A shape has its SMALLEST moment of inertia about its own centroidal '
      'axis. Move to any parallel axis and you add the transfer term, area '
      'times the distance between them squared. Come back and you take it off. '
      'The theorem only runs between the centroidal axis and some other one: '
      'it will not go straight from one non-centroidal axis to another, and '
      'the way through is always back via the centroid.',
  formulas: [
    ('Parallel axis theorem', r'I_x = \bar{I}_{xc} + Ad^2'),
    ('Leaving the centroidal axis', r'+\,Ad^2'),
    ('Arriving at it', r'-\,Ad^2'),
  ],
  figure: BriefFigure.transfer,
  handbook: 'Handbook p. 95',
);

const compositeIBrief = BriefSection(
  title: 'Where a built-up section gets its stiffness',
  body:
      'Add a composite section up piece by piece: each one brings its own '
      'centroidal value AND a transfer term, and the transfer is measured to '
      'the COMPOSITE centroid, not to the piece or to the base. On almost any '
      'real section those transfer terms are the bigger half of the answer, '
      'and that has a consequence worth carrying: because the distance is '
      'squared, a piece sitting on the axis contributes almost nothing however '
      'much material is in it, and a small piece a long way out can carry most '
      'of the section. It is why an I-beam has fat flanges and a thin web, and '
      'why a service hole goes through the middle of a beam depth.',
  formulas: [
    ('Piece by piece', r'I_x = \sum \left( \bar{I}_i + A_i d_i^2 \right)'),
    ('Measured to', r'\text{the composite centroid}'),
    ('Which is why', r'd^2 \text{, so material on the axis is wasted}'),
  ],
  figure: BriefFigure.compositeI,
  handbook: 'Handbook p. 95',
);

const polarBrief = BriefSection(
  title: 'Bending needs I, twisting needs J',
  body:
      'Two different jobs and two different properties, and reaching for the '
      'wrong one is on this chapter\'s own trap list. Bending needs I, and it '
      'is I about the axis SQUARE to the load: push a member down and it bends '
      'about its horizontal axis, push it sideways and it bends about its '
      'vertical one, whichever way round the section happens to be drawn and '
      'whichever axis is the stronger. Twisting about the member\'s own length '
      'needs the polar moment, which is simply the two I values added about '
      'the same point. For a round shaft J works out to exactly twice I, so '
      'using one for the other costs you a factor of two.',
  formulas: [
    ('Bending', r'\sigma = \frac{Mc}{I}'),
    ('Twisting', r'\tau = \frac{Tc}{J}'),
    ('And the polar moment is', r'J = I_x + I_y'),
  ],
  figure: BriefFigure.polar,
  handbook: 'Handbook p. 95',
);

const areaWeightedBrief = BriefSection(
  title: 'Where the area is, not where the height is',
  body:
      'A centroid is an area-weighted average, so it sits toward whichever '
      'end of the section carries the most material. The middle of the overall '
      'height is right only when the section is symmetric about that line, and '
      'it is the wrong answer named in every problem in this lesson. So is the '
      'plain average of the piece centroids, which throws away the very '
      'weighting that makes it an average of areas. A hole is an ordinary '
      'piece with a NEGATIVE area: it comes off the top of the fraction and '
      'off the bottom of it, and it drags the centroid away from itself.',
  formulas: [
    ('Composite centroid', r'\bar{y} = \frac{\sum A_i\, y_i}{\sum A_i}'),
    ('A hole', r'A_i < 0'),
    ('First moment of area', r'Q_x = \sum A_i\, y_i = \bar{y}A'),
  ],
  figure: BriefFigure.areaWeighted,
  handbook: 'Handbook p. 95',
);

const tableBrief = BriefSection(
  title: 'What the tables already give you',
  body:
      'You are never asked to integrate for a centroid on this exam. The '
      'handbook lists them for rectangles, triangles, circles, half discs, '
      'quarter discs and parabolic segments, and the work is knowing which '
      'shape is in front of you and which corner the table measures from. A '
      'triangle sits a third of the way up from its base and a third of the '
      'way in from its right angle, so mirroring the triangle moves the '
      'answer. A half disc is four r over three pi from its flat side, a shade '
      'over four tenths of the radius. The middle of the box a shape fits in '
      'is the centroid of the box, and of nothing else.',
  formulas: [
    ('Rectangle', r'\bar{y} = \frac{h}{2}'),
    ('Triangle, from the base', r'\bar{y} = \frac{h}{3}'),
    ('Half disc, from the flat side', r'\bar{y} = \frac{4r}{3\pi}'),
  ],
  figure: BriefFigure.table,
  handbook: 'Handbook pp. 98 to 100',
);

const referenceBrief = BriefSection(
  title: 'One axis, and every piece measured from it',
  body:
      'Choose a reference axis before anything else, usually the bottom edge '
      'or the left edge, and then measure every single piece from that one '
      'line. What you measure to is that piece\'s OWN centroid, not where the '
      'piece begins and not where it ends. The commonest mistake in the whole '
      'topic is changing reference partway through because one piece is easier '
      'to measure another way: the arithmetic still works, the units still '
      'look right, and the answer is wrong.',
  formulas: [
    ('Each term', r'A_i\,y_i'),
    ('Where y is measured from', r'\text{the one axis you chose}'),
    ('Where y is measured to', r"\text{to that piece's own centroid}"),
  ],
  figure: BriefFigure.reference,
  handbook: 'Handbook p. 95',
);

const twoForceBrief = BriefSection(
  title: 'Two forces, and only two',
  body:
      'Count the places something acts on a member. Exactly two, and '
      'equilibrium forces those two to be equal, opposite and in line with '
      'each other, which means along the line joining the two points. Three '
      'or more, and the member carries shear and bending and its pin forces '
      'point wherever they have to. A bend in the member changes nothing: the '
      'line runs between the ends, not along the metal. And a load hung at a '
      'PIN is carried by the joint, so it leaves every member there still '
      'touched at just its own two ends.',
  formulas: [
    ('Two-force member', r'\text{touched at exactly two points}'),
    ('Where its force acts', r'\text{along the line joining those points}'),
    ('Multi-force member', r'\text{touched three or more times}'),
  ],
  figure: BriefFigure.twoForce,
  handbook: 'Handbook p. 97',
);

const leverBrief = BriefSection(
  title: 'Moments about the pivot',
  body:
      'A lever is one moment equation and nothing more: the force out is the '
      'force in, scaled by YOUR arm over ITS arm. Long effort arm and the '
      'machine hands you more force than you put in. Short effort arm and it '
      'hands you less, and what it buys instead is reach and speed, which is '
      'what a fishing rod and your own forearm are for. Effort and load on the '
      'same side of the pivot works the same way, you just pull up instead of '
      'pushing down.',
  formulas: [
    ('Moments about the pivot', r'F_{out}\,a_{out} = F_{in}\,a_{in}'),
    ('So the force out is', r'F_{out} = F_{in}\,\frac{a_{in}}{a_{out}}'),
    ('Mechanical advantage', r'\frac{a_{in}}{a_{out}}'),
  ],
  figure: BriefFigure.lever,
  handbook: 'Handbook p. 97',
);

const whatItIsBrief = BriefSection(
  title: 'Truss, frame or machine',
  body:
      'Three names, and the one you choose decides what you may assume about '
      'every member. Does it move? Then it is a machine, however it is built. '
      'If it holds still, count the places something touches each member. All '
      'of them touched twice and it is a truss, so every force runs along its '
      'own member and the joints can be walked one at a time. Any member '
      'touched three times and it is a frame, and that member bends. Frames '
      'and machines are taken apart and solved the same way.',
  formulas: [
    ('Truss', r'\text{holds still, every member two-force}'),
    ('Frame', r'\text{holds still, at least one bends}'),
    ('Machine', r'\text{parts move against each other}'),
  ],
  figure: BriefFigure.whatItIs,
  handbook: 'Handbook p. 97',
);

const lawsBrief = BriefSection(
  title: 'Two questions before either rule',
  body:
      'Could both events happen at once? If not they are mutually exclusive, '
      'there is no overlap, and their probabilities simply add. If they can, '
      'the addition rule has to take the overlap back off, because adding them '
      'straight counts it twice. Then the second question: does the first '
      'happening change the odds of the second? If not they are independent '
      'and you may multiply them straight out, and if it does you need the '
      'conditional probability. Drawing without replacement is the commonest '
      'way a problem quietly makes two events dependent. And exclusive and '
      'independent are not two words for one idea: events that cannot both '
      'happen are as dependent as events get, because one of them drops the '
      'other to zero.',
  formulas: [
    ('Addition rule', r'P(A \cup B) = P(A) + P(B) - P(A \cap B)'),
    ('Multiplication rule', r'P(A \cap B) = P(A)\,P(B \mid A)'),
    ('If independent', r'P(B \mid A) = P(B)'),
  ],
  figure: BriefFigure.laws,
  handbook: 'Handbook p. 105',
);

const periodBrief = BriefSection(
  title: 'Which mark it lands on',
  body:
      'Unless a problem says otherwise, every payment lands at the END of its '
      'period. Today is period zero. The beginning of year n is the same '
      'instant as the end of year n minus one, so it sits on period n minus '
      'one, and the beginning of year one is today. An ordinary annuity starts '
      'at the end of the first period rather than now, which is what every '
      'uniform series factor in the handbook assumes. A gradient is zero in '
      'the first period by definition and its first step lands at the end of '
      'period two. Draw the diagram before choosing a factor: a cash flow one '
      'period out leaves no trace at all in the arithmetic that follows.',
  formulas: [
    ('End of year n', r'\text{period } n'),
    ('Beginning of year n', r'\text{period } n - 1'),
    ('Today', r'\text{period } 0'),
  ],
  figure: BriefFigure.period,
  handbook: 'Handbook p. 230',
);

const screwBrief = BriefSection(
  title: 'Whether a screw holds itself',
  body:
      'Unwrap one turn of a thread and it is a ramp, and its steepness is the '
      'pitch angle. The friction angle is the steepest ramp that surface could '
      'hold on. Compare the two and everything follows. Raising a load is '
      'always work and the friction angle is added on. Lowering is where it '
      'gets interesting: a thread shallower than the friction angle is '
      'SELF-LOCKING and has to be driven down, which is why a car jack holds a '
      'car and a bolt stays done up. A thread steeper than it runs away under '
      'the load and has to be held back. Self-locking is not a property of the '
      'thread alone: grease a jack and you can drop the friction angle under '
      'the pitch angle without changing a single dimension.',
  formulas: [
    ('Screw jack moment', r'M = Pr\tan(\alpha \pm \phi)'),
    ('Friction angle', r'\phi = \arctan\mu'),
    ('Self-locking when', r'\phi > \alpha'),
  ],
  figure: BriefFigure.screw,
  handbook: 'Handbook p. 97',
);

const ceilingBrief = BriefSection(
  title: 'Friction is a ceiling, not a value',
  body:
      'The formula gives you the MOST a surface can hold back, not what it is '
      'holding back. Friction sits at whatever keeps the thing still, anywhere '
      'from nothing at all up to that ceiling, and it only reaches the ceiling '
      'at the instant motion is impending. So read the problem before reaching '
      'for the formula. Words like about to slide, on the verge, or the '
      'maximum force before moving are what put you at the ceiling. Without '
      'them you are somewhere below it and the formula answers a question '
      'nobody asked.',
  formulas: [
    ('What is always true', r'F \le \mu_s N'),
    ('At impending motion, and only there', r'F = \mu_s N'),
    ('The angle it lets go at', r'\tan\theta = \mu_s'),
  ],
  figure: BriefFigure.ceiling,
  handbook: 'Handbook p. 96',
);

const beltBrief = BriefSection(
  title: 'The tight side, then the angle',
  body:
      'A belt round a drum holds far more on one side than the other, and '
      'which side is which is decided before any arithmetic: the tight side is '
      'the end the belt is being dragged toward, because friction has been '
      'adding to it the whole way round. Then the contact angle, in radians '
      'and never in degrees, and it is free to pass a full turn. The growth is '
      'exponential rather than proportional, which is why a couple of extra '
      'turns round a bollard let one person hold a ship.',
  formulas: [
    ('Belt friction', r'F_1 = F_2\, e^{\mu\theta}'),
    ('Tight side', r'F_1 \text{ is downstream of the slip}'),
    ('Half a turn', r'\theta = \pi \text{ radians}'),
  ],
  figure: BriefFigure.belt,
  handbook: 'Handbook p. 96',
);

const normalForceBrief = BriefSection(
  title: 'What the surface is pressed with',
  body:
      'Every friction answer is only as good as the normal force under it, and '
      'the normal force is the weight ONLY on level ground with nothing else '
      'acting. Tilt the surface and it drops to the part of the weight square '
      'to it. Slant the push and it moves again, up if the push presses in and '
      'down if it lifts. That last one is the whole of the ramp problem: a '
      'horizontal push on a slope helps you along and fights you at the same '
      'time. How much of the block is touching never enters into it.',
  formulas: [
    ('Level ground, nothing else', r'N = W'),
    ('On a slope', r'N = W\cos\theta'),
    ('With a push at an angle to the surface', r'N = W\cos\theta - P\sin\beta'),
  ],
  figure: BriefFigure.normalForce,
  handbook: 'Handbook p. 96',
);

const determinacyBrief = BriefSection(
  title: 'Three equations, and no more',
  body:
      'Two dimensions give you three equations, so three unknown reactions is '
      'the most equilibrium can find. Count them before starting: one for a '
      'roller, two for a pin, three for a fixed end. More than three and the '
      'beam is statically indeterminate, which says nothing against the beam. '
      'It is usually the stiffer structure, and it needs how much things '
      'stretch to finish. Loads never add unknowns, couples included: they are '
      'known, they only have to be carried.',
  formulas: [
    ('What you have', r'\sum F_x = 0, \; \sum F_y = 0, \; \sum M = 0'),
    ('Determinate', r'\text{unknowns} = 3'),
    ('Indeterminate', r'\text{unknowns} > 3'),
  ],
  figure: BriefFigure.determinacy,
  handbook: 'Handbook p. 94',
);

/// Opens one concept over whatever is on screen.
Future<void> showConcept(BuildContext context, BriefSection section) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: ConceptView(section: section),
    ),
  );
}

/// The concept behind the item you are on, and only that one.
class ConceptView extends StatelessWidget {
  const ConceptView({super.key, required this.section});

  final BriefSection section;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(section.title, style: AppTheme.heading(size: 25)),
          const SizedBox(height: 16),
          _SectionCard(section: section),
          const SizedBox(height: 14),
          const Text(
            'Knowing this is not the same as solving with it. The full '
            'problems belong at a desk, on paper.',
            style: TextStyle(fontSize: 13, height: 1.55, color: AppColors.ink3),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final BriefSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: AppColors.charcoal,
            ),
          ),
          if (section.formula != null) ...[
            const SizedBox(height: 14),
            Center(child: MathBlock(section.formula!, fontSize: 20)),
          ],
          for (final (label, latex) in section.formulas) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: AppTheme.overline()),
                  const SizedBox(height: 10),
                  Center(child: MathBlock(latex, fontSize: 19)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          BriefFigureView(figure: section.figure),
          if (section.handbook != null) ...[
            const SizedBox(height: 12),
            Text(section.handbook!.toUpperCase(), style: AppTheme.overline()),
          ],
        ],
      ),
    );
  }
}

class BriefFigureView extends StatelessWidget {
  const BriefFigureView({super.key, required this.figure});

  final BriefFigure figure;

  @override
  Widget build(BuildContext context) {
    switch (figure) {
      case BriefFigure.slopePair:
        return Row(
          children: [
            Expanded(
              child: _Panel(
                caption: 'Parallel: same slope',
                child: CustomPaint(painter: _SlopePairPainter(parallel: true)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Panel(
                caption: 'Perpendicular: flip and negate',
                child: CustomPaint(painter: _SlopePairPainter(parallel: false)),
              ),
            ),
          ],
        );
      case BriefFigure.discriminant:
        return Row(
          children: [
            for (final e in const [
              (1.1, 'positive: two roots'),
              (0.0, 'zero: one root'),
              (-0.7, 'negative: none'),
            ]) ...[
              Expanded(
                child: _Panel(
                  height: 92,
                  caption: e.$2,
                  child: CustomPaint(
                    painter: ParaPainter(
                      para: Para(opensUp: true, vertexY: -e.$1),
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ),
              if (e.$2 != 'negative: none') const SizedBox(width: 8),
            ],
          ],
        );
      case BriefFigure.grade:
        return _Panel(
          height: 150,
          caption: 'Station 3+00 is 300 feet from station 0+00',
          child: CustomPaint(painter: _GradePainter()),
        );
      case BriefFigure.ratios:
        return const _Panel(
          height: 190,
          caption: 'The marked angle decides which side is which',
          child: CustomPaint(
            painter: TrianglePainter(
              angleAtTop: false,
              mirror: false,
              showNames: true,
            ),
          ),
        );
      case BriefFigure.sideNames:
        return Row(
          children: [
            Expanded(
              child: _Panel(
                height: 150,
                caption: 'Angle at the bottom',
                child: CustomPaint(
                  painter: TrianglePainter(
                    angleAtTop: false,
                    mirror: false,
                    showNames: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Panel(
                height: 150,
                caption: 'Same triangle, angle at the top',
                child: CustomPaint(
                  painter: TrianglePainter(
                    angleAtTop: true,
                    mirror: false,
                    showNames: true,
                  ),
                ),
              ),
            ),
          ],
        );
      case BriefFigure.components:
        return Row(
          children: [
            Expanded(
              child: _Panel(
                height: 160,
                caption: 'From horizontal: across is cosine',
                child: CustomPaint(
                  painter: ForcePainter(
                    degrees: 40,
                    fromVertical: false,
                    highlightHorizontal: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Panel(
                height: 160,
                caption: 'From vertical: across is now sine',
                child: CustomPaint(
                  painter: ForcePainter(
                    degrees: 40,
                    fromVertical: true,
                    highlightHorizontal: true,
                  ),
                ),
              ),
            ),
          ],
        );
      case BriefFigure.correlation:
        return const _RuleList(
          rules: [
            (r"\text{leans up, tight} \;\Rightarrow\; r \approx +1", null),
            (r"\text{leans down, tight} \;\Rightarrow\; r \approx -1", null),
            (r"\text{no lean} \;\Rightarrow\; r \approx 0", null),
            (r"\text{an arch} \;\Rightarrow\; r \approx 0 \text{ as well}", null),
          ],
        );
      case BriefFigure.regressionLine:
        return const _RuleList(
          rules: [
            (r"\hat{y} = a + bx \text{ passes through } (\bar{x}, \bar{y})", true),
            (r"\bar{y} = 75,\ b = 4.2,\ \bar{x} = 15 \;\Rightarrow\; a = 12", true),
            (r"\hat{y}(20) = 12 + 4.2(20) = 96", true),
            (r"\hat{y}(20) = 4.2(20) = 84", false),
          ],
        );
      case BriefFigure.determination:
        return const _RuleList(
          rules: [
            (r"r = -0.92 \;\Rightarrow\; R^2 = 0.846", true),
            (r"r = -0.92 \;\Rightarrow\; R^2 = -0.846", false),
            (r"r = -0.92 \;\Rightarrow\; R^2 = 0.92", false),
            (r"1 - R^2 = \text{the share left unexplained}", true),
          ],
        );
      case BriefFigure.counting:
        return const _RuleList(
          rules: [
            (r"\text{a team of 3} \;\Rightarrow\; C(8,3) = 56", true),
            (r"\text{3 named jobs} \;\Rightarrow\; P(8,3) = 336", true),
            (r"\text{a team of 3} \;\Rightarrow\; P(8,3) = 336", false),
            (r"\text{a team of 3} \;\Rightarrow\; 8^3 = 512", false),
          ],
        );
      case BriefFigure.binomial:
        return const _RuleList(
          rules: [
            (r"P(X=x) = C(n,x)\,p^x q^{\,n-x}", true),
            (r"C(10,8)\,(0.90)^8(0.10)^2 = 0.194", true),
            (r"(0.90)^8(0.10)^2 \text{ alone}", false),
            (r"P(10,8)\,(0.90)^8(0.10)^2", false),
          ],
        );
      case BriefFigure.normalTable:
        return const _RuleList(
          rules: [
            (r"F(z) = \text{the area LEFT of } z", null),
            (r"R(z) = \text{the area RIGHT of } z", null),
            (r"W(z) = \text{the area between } -z \text{ and } z", null),
            (r"F(-1.67) = 1 - F(1.67) = 0.0475", null),
          ],
        );
      case BriefFigure.expectedValue:
        return const _RuleList(
          rules: [
            (r"E(X) = \text{the balance point}", true),
            (r"E(X) = \text{the most likely outcome}", false),
            (r"E(X) = \text{the middle of the range}", false),
            (r"E(X) \text{ need not be an outcome that can happen}", true),
          ],
        );
      case BriefFigure.varianceShortcut:
        return const _RuleList(
          rules: [
            (r"\text{Var}(X) = E(X^2) - [E(X)]^2 = 0.81", true),
            (r"\text{Var}(X) = [E(X)]^2 - E(X^2) = -0.81", false),
            (r"\text{Var}(X) = E(X) = 2.70", false),
            (r"\text{Var}(X) = E(X^2) = 8.10", false),
          ],
        );
      case BriefFigure.combining:
        return const _RuleList(
          rules: [
            (r"\sigma_T = \sqrt{3^2 + 8^2} = 8.54", true),
            (r"\sigma_T = 3 + 8 = 11", false),
            (r"\sigma_T = 3^2 + 8^2 = 73", false),
            (r"\text{Var}(2D + L) = 2^2\sigma_D^2 + \sigma_L^2", true),
          ],
        );
      case BriefFigure.marginOfError:
        return const _RuleList(
          rules: [
            (r"E = z_{\alpha/2}\frac{\sigma}{\sqrt{n}}", true),
            (r"E = z_{\alpha/2}\frac{\sigma}{n}", false),
            (r"E = z_{\alpha/2}\,\sigma", false),
            (r"4\times \text{the samples} \;\Rightarrow\; \tfrac{1}{2}\text{ the margin}", true),
          ],
        );
      case BriefFigure.zOrT:
        return const _RuleList(
          rules: [
            (r"\text{given } \sigma \;\Rightarrow\; z", true),
            (r"\text{given } s \;\Rightarrow\; t \text{ with } v = n-1", true),
            (r"t \text{ is WIDER than } z \text{ at the same confidence}", true),
            (r"\text{a higher } \bar{x} \;\Rightarrow\; \text{a wider interval}", false),
          ],
        );
      case BriefFigure.sampleSize:
        return const _RuleList(
          rules: [
            (r"n = \left(\tfrac{1.960 \times 800}{200}\right)^2 = 61.47 \to 62", true),
            (r"n = \tfrac{1.960 \times 800}{200} = 7.84 \to 8", false),
            (r"n = 61.47", false),
            (r"n = 61", false),
          ],
        );
      case BriefFigure.hypotheses:
        return const _RuleList(
          rules: [
            (r"\text{``exceeds''} \;\Rightarrow\; H_1: \mu > \mu_0", true),
            (r"\text{``falls short''} \;\Rightarrow\; H_1: \mu < \mu_0", true),
            (r"\text{``differs''} \;\Rightarrow\; H_1: \mu \neq \mu_0", true),
            (r"\text{``exceeds''} \;\Rightarrow\; H_1: \mu \neq \mu_0", false),
          ],
        );
      case BriefFigure.decisionRule:
        return const _RuleList(
          rules: [
            (r"t = 2.4 > 1.753 \;\Rightarrow\; \text{reject}", true),
            (r"|t| = 2.9 > 2.131 \;\Rightarrow\; \text{reject}", true),
            (r"\chi^2 = 5.0 < 7.815 \;\Rightarrow\; \text{fail to reject}", true),
            (r"\text{fail to reject} \;\Rightarrow\; \mu = \mu_0", false),
          ],
        );
      case BriefFigure.goodnessOfFit:
        return const _RuleList(
          rules: [
            (r"E = \tfrac{200}{4} = 50 \text{ under a level model}", null),
            (r"\tfrac{(60-50)^2}{50} = 2.0", null),
            (r"\tfrac{(28-20)^2}{20} = 3.2 \text{, a smaller gap}", null),
            (r"\text{bigger } \chi^2 \;\Rightarrow\; \text{a worse fit}", null),
          ],
        );
      case BriefFigure.publicFirst:
        return const _RuleList(
          rules: [
            (r"\text{public safety} > \text{employer} > \text{self}", true),
            (r"\text{a seal says it meets accepted standards}", true),
            (r"\text{noting a deviation in the file makes it acceptable}", false),
            (r"\text{every disagreement is a violation}", false),
          ],
        );
      case BriefFigure.escalation:
        return const _RuleList(
          rules: [
            (r"\text{colleague} \to \text{firm} \to \text{board}", true),
            (r"\text{imminent danger: stop the work first}", true),
            (r"\text{go to the client before the firm has been told}", false),
            (r"\text{say nothing, it was not your drawing}", false),
          ],
        );
      case BriefFigure.proportion:
        return const _RuleList(
          rules: [
            (r"\text{disclose, then recuse from that decision}", true),
            (r"\text{vote objectively and say nothing}", false),
            (r"\text{resign from the committee altogether}", false),
            (r"\text{the firm being qualified settles it}", false),
          ],
        );
      case BriefFigure.competence:
        return const _RuleList(
          rules: [
            (r"\text{your field, prepared under your direction}", true),
            (r"\text{coordinate the set, seal your own segment}", true),
            (r"\text{the field next door is close enough}", false),
            (r"\text{a colleague reviewed it, so it is fine}", false),
          ],
        );
      case BriefFigure.consent:
        return const _RuleList(
          rules: [
            (r"\text{disclose, and get all payers to agree in writing}", true),
            (r"\text{different scopes, so there is no conflict}", false),
            (r"\text{decline outright, a conflict is fatal}", false),
            (r"\text{a gratuity is fine once disclosed}", false),
          ],
        );
      case BriefFigure.claims:
        return const _RuleList(
          rules: [
            (r"\text{managed delivery; design by others}", true),
            (r"\text{our firm designed it}", false),
            (r"\text{we provided engineering services on it}", false),
            (r"\text{our portfolio includes it}", false),
          ],
        );
      case BriefFigure.standing:
        return const _RuleList(
          rules: [
            (r"\text{passed the FE} \;\Rightarrow\; \text{certified, not licensed}", true),
            (r"\text{only a licensed PE may seal}", true),
            (r"\text{an intern may seal if a PE reviews it}", false),
            (r"\text{writing ``Engineer Intern'' beside the seal fixes it}", false),
          ],
        );
      case BriefFigure.exemption:
        return const _RuleList(
          rules: [
            (r"\text{under a PE's charge, no final decisions}", true),
            (r"\text{comparing documents and flagging differences}", true),
            (r"\text{choosing the size because the PE is away}", false),
            (r"\text{a firm with nobody licensed in it}", false),
          ],
        );
      case BriefFigure.holdingOut:
        return const _RuleList(
          rules: [
            (r"\text{an app that sizes members for the public}", false),
            (r"\text{``PE'' on the card of somebody unlicensed}", false),
            (r"\text{tables prepared and sealed by a PE}", true),
            (r"\text{a unit converter that decides nothing}", true),
          ],
        );
      case BriefFigure.ladder:
        return const _RuleList(
          rules: [
            (r"\text{degree} \to \text{FE} \to \text{experience} \to \text{PE}", true),
            (r"\text{BS and 4 years} \;\Rightarrow\; \text{ready}", true),
            (r"\text{BS and 2 years} \;\Rightarrow\; \text{ready}", false),
            (r"\text{the same degree counted twice}", false),
          ],
        );
      case BriefFigure.discipline:
        return const _RuleList(
          rules: [
            (r"\text{a felony, of any kind}", true),
            (r"\text{a misdemeanour involving dishonesty}", true),
            (r"\text{a misdemeanour involving neither}", false),
            (r"\text{a clean record protects you from action}", false),
          ],
        );
      case BriefFigure.sections:
        return const _RuleList(
          rules: [
            (r"\text{licensed} \;\Rightarrow\; \text{the licensee list}", true),
            (r"\text{revoked} \;\Rightarrow\; \text{the unlicensed list}", true),
            (r"\text{expired} \;\Rightarrow\; \text{the licensee list}", false),
            (r"\text{rudeness} \;\Rightarrow\; \text{either list}", false),
          ],
        );
      case BriefFigure.formation:
        return const _RuleList(
          rules: [
            (r"\text{offer, taken as it stands, value both ways}", true),
            (r"\text{a promise to do it for nothing}", false),
            (r"\text{a counter-offer, then accepting the first price}", false),
            (r"\text{unsigned by a notary}", true),
          ],
        );
      case BriefFigure.risk:
        return const _RuleList(
          rules: [
            (r"\text{lump sum} \;\Rightarrow\; \text{the contractor}", true),
            (r"\text{cost plus} \;\Rightarrow\; \text{the owner}", true),
            (r"\text{cost plus} \;\Rightarrow\; \text{the contractor}", false),
            (r"\text{a scope change} \;\Rightarrow\; \text{the contractor}", false),
          ],
        );
      case BriefFigure.delivery:
        return const _RuleList(
          rules: [
            (r"\text{one contract} \;\Rightarrow\; \text{design-build}", true),
            (r"\text{two, design finished first} \;\Rightarrow\; \text{DBB}", true),
            (r"\text{two, with a guaranteed maximum} \;\Rightarrow\; \text{CMAR}", true),
            (r"\text{design-build} \;\Rightarrow\; \text{the owner holds the designer}", false),
          ],
        );
      case BriefFigure.standardOfCare:
        return const _RuleList(
          rules: [
            (r"\text{a required check nobody ran}", false),
            (r"\text{a peer would have done the same}", true),
            (r"\text{the result was imperfect, so it is negligence}", false),
            (r"\text{the client is unhappy, so it is negligence}", false),
          ],
        );
      case BriefFigure.negligence:
        return const _RuleList(
          rules: [
            (r"\text{duty} + \text{breach} + \text{causation} + \text{damages}", true),
            (r"\text{a breach with no measurable loss}", false),
            (r"\text{a breach that did not cause the loss}", false),
            (r"\text{intent is a fifth element}", false),
          ],
        );
      case BriefFigure.clocks:
        return const _RuleList(
          rules: [
            (r"\text{limitations: from discovery}", true),
            (r"\text{repose: from substantial completion}", true),
            (r"\text{repose can bar a claim before the harm appears}", true),
            (r"\text{repose gives the plaintiff longer}", false),
          ],
        );
      case BriefFigure.property:
        return const _RuleList(
          rules: [
            (r"\text{not disclosing it} \;\Rightarrow\; \text{a trade secret}", true),
            (r"\text{the brand on the box} \;\Rightarrow\; \text{a trademark}", true),
            (r"\text{the paper about it} \;\Rightarrow\; \text{a copyright}", true),
            (r"\text{a trademark stops others making the goods}", false),
          ],
        );
      case BriefFigure.portfolio:
        return const _RuleList(
          rules: [
            (r"\text{one project, four protections}", true),
            (r"\text{a patent covers the name as well}", false),
            (r"\text{a patent covers the paper as well}", false),
            (r"\text{a patent and a secret on the same thing}", false),
          ],
        );
      case BriefFigure.lifeCycle:
        return const _RuleList(
          rules: [
            (r"\text{cheapest to build} \;\Rightarrow\; \text{cheapest to own}", false),
            (r"\text{add every stage, including taking it away}", true),
            (r"\text{sometimes the cheap option wins outright}", true),
            (r"\text{always choose the costlier option}", false),
          ],
        );
      case BriefFigure.factors:
        return const _RuleList(
          rules: [
            (r"\text{known at the end} \;\Rightarrow\; (A/F)", true),
            (r"\text{known today} \;\Rightarrow\; (A/P)", true),
            (r"\text{a sinking fund uses } (A/P)", false),
            (r"\text{dividing by } n \text{ instead of discounting}", false),
          ],
        );
      case BriefFigure.rates:
        return const _RuleList(
          rules: [
            (r"n \text{ in months} \;\Rightarrow\; \text{the monthly rate}", true),
            (r"12\% \text{ monthly} \;\Rightarrow\; i_e = 12.68\%", true),
            (r"12\% \text{ monthly} \;\Rightarrow\; i_e = 12\%", false),
            (r"\text{comparing two quoted rates directly}", false),
          ],
        );
      case BriefFigure.pieces:
        return const _RuleList(
          rules: [
            (r"\text{a growing series} = (P/A) + (P/G)", true),
            (r"\text{a growing series} = (P/A) \text{ alone}", false),
            (r"\text{a flat series} = (P/A) \text{ alone}", true),
            (r"\text{adding the cash flows up undiscounted}", false),
          ],
        );
      case BriefFigure.annualCost:
        return const _RuleList(
          rules: [
            (r"\text{a cost inside the life} \;\Rightarrow\; \text{up}", true),
            (r"\text{salvage} \;\Rightarrow\; \text{down}", true),
            (r"\text{salvage} \;\Rightarrow\; \text{up}", false),
            (r"\text{a sunk cost} \;\Rightarrow\; \text{in both}", false),
          ],
        );
      case BriefFigure.studyPeriod:
        return const _RuleList(
          rules: [
            (r"6 \text{ and } 4 \text{ by PW} \;\Rightarrow\; 12 \text{ years}", true),
            (r"6 \text{ and } 4 \text{ by AW} \;\Rightarrow\; \text{as they are}", true),
            (r"6 \text{ and } 4 \text{ by PW} \;\Rightarrow\; \text{as they are}", false),
            (r"20 \text{ and } 20 \;\Rightarrow\; \text{a multiple is needed}", false),
          ],
        );
      case BriefFigure.methodsAgree:
        return const _RuleList(
          rules: [
            (r"\text{same period, same rate} \;\Rightarrow\; \text{same ranking}", true),
            (r"\text{unequal lives by PW} \;\Rightarrow\; \text{they can differ}", true),
            (r"\text{different MARRs} \;\Rightarrow\; \text{they can differ}", true),
            (r"PW \text{ and } AW \text{ often just disagree}", false),
          ],
        );
      case BriefFigure.costTypes:
        return const _RuleList(
          rules: [
            (r"\text{rent, insurance} \;\Rightarrow\; \text{fixed}", true),
            (r"\text{fuel per yard} \;\Rightarrow\; \text{variable}", true),
            (r"\text{a study already paid for} \;\Rightarrow\; \text{in}", false),
            (r"\text{land you already own} \;\Rightarrow\; \text{free}", false),
          ],
        );
      case BriefFigure.breakEven:
        return const _RuleList(
          rules: [
            (r"\text{below the crossing} \;\Rightarrow\; \text{the cheap start}", true),
            (r"\text{above it} \;\Rightarrow\; \text{the cheap rate}", true),
            (r"\text{compare the rates alone}", false),
            (r"\text{higher start AND steeper} \;\Rightarrow\; \text{a crossing}", false),
          ],
        );
      case BriefFigure.payback:
        return const _RuleList(
          rules: [
            (r"\tfrac{1{,}400}{280 - 80} = 7 \text{ years}", true),
            (r"\tfrac{1{,}400}{280} = 5 \text{ years}", false),
            (r"\text{a one-off grant, in the annual figure}", false),
            (r"\text{new cost} > \text{saving} \;\Rightarrow\; \text{no payback}", true),
          ],
        );
      case BriefFigure.bcRatio:
        return const _RuleList(
          rules: [
            (r"\text{operating cost} \;\Rightarrow\; \text{denominator}", true),
            (r"\text{harm to the public} \;\Rightarrow\; \text{off the top}", true),
            (r"\text{harm to the public} \;\Rightarrow\; \text{denominator}", false),
            (r"\text{only the construction cost underneath}", false),
          ],
        );
      case BriefFigure.incremental:
        return const _RuleList(
          rules: [
            (r"\text{the highest } B/C \;\Rightarrow\; \text{build that one}", false),
            (r"B/C < 1 \;\Rightarrow\; \text{out before you start}", true),
            (r"\Delta B/C \geq 1 \;\Rightarrow\; \text{step up}", true),
            (r"\text{compare against the last one that survived}", true),
          ],
        );
      case BriefFigure.rollback:
        return const _RuleList(
          rules: [
            (r"\text{a circle lands between its endings}", true),
            (r"\text{the cost today} \;\Rightarrow\; \text{the branch}", false),
            (r"\text{the worst ending} \;\Rightarrow\; \text{the branch}", false),
            (r"\text{an unlabeled branch carries the rest}", true),
          ],
        );
      case BriefFigure.internalRate:
        return const _RuleList(
          rules: [
            (r"\text{the rate where } PW_{\text{in}} = PW_{\text{out}}", true),
            (r"\tfrac{1{,}150 - 1{,}000}{1{,}000} = 15\%", true),
            (r"\tfrac{1{,}150 - 1{,}000}{1{,}150} = 13\%", false),
            (r"\text{the biggest undiscounted profit}", false),
          ],
        );
      case BriefFigure.hurdle:
        return const _RuleList(
          rules: [
            (r"IRR \geq MARR \;\Rightarrow\; \text{accept}", true),
            (r"IRR = MARR \;\Rightarrow\; \text{accept, it breaks even}", true),
            (r"IRR > 0 \;\Rightarrow\; \text{accept}", false),
            (r"11\% \text{ against } 12\% \;\Rightarrow\; \text{close enough}", false),
          ],
        );
      case BriefFigure.ratePerYear:
        return const _RuleList(
          rules: [
            (r"\text{sooner} \;\Rightarrow\; \text{a higher rate}", true),
            (r"\text{every cash flow doubled} \;\Rightarrow\; \text{same rate}", true),
            (r"\text{the bigger total} \;\Rightarrow\; \text{the higher rate}", false),
            (r"\text{the bigger project} \;\Rightarrow\; \text{the higher rate}", false),
          ],
        );
      case BriefFigure.macrs:
        return const _RuleList(
          rules: [
            (r"\text{5 year property} \;\Rightarrow\; 6 \text{ years of it}", true),
            (r"\text{MACRS} \;\Rightarrow\; \text{full cost, no salvage}", true),
            (r"\text{MACRS} \;\Rightarrow\; \tfrac{C - S_n}{n}", false),
            (r"\text{5 year property} \;\Rightarrow\; 5 \text{ years of it}", false),
          ],
        );
      case BriefFigure.bookValue:
        return const _RuleList(
          rules: [
            (r"BV_3 = C - (D_1 + D_2 + D_3)", true),
            (r"BV_3 = C - D_3", false),
            (r"BV_3 = D_1 + D_2 + D_3", false),
            (r"\text{book value} = \text{what it would fetch}", false),
          ],
        );
      case BriefFigure.dollarsMatch:
        return const _RuleList(
          rules: [
            (r"\text{actual dollars} \;\Rightarrow\; d = i + f + if", true),
            (r"\text{constant dollars} \;\Rightarrow\; i", true),
            (r"\text{actual dollars} \;\Rightarrow\; i + f", false),
            (r"\text{actual dollars} \;\Rightarrow\; i", false),
          ],
        );
      case BriefFigure.resolve:
        return const _RuleList(
          rules: [
            (r"\theta \text{ off the horizontal} \;\Rightarrow\; F_x = F\cos\theta", true),
            (r"\theta \text{ off the vertical} \;\Rightarrow\; F_y = F\cos\theta", true),
            (r"\text{the horizontal leg} \;\Rightarrow\; \text{the horizontal component}", true),
            (r"\text{a component larger than } F", false),
          ],
        );
      case BriefFigure.moment:
        return const _RuleList(
          rules: [
            (r"\text{a vertical force} \;\Rightarrow\; \text{a horizontal arm}", true),
            (r"\text{the line through the point} \;\Rightarrow\; M = 0", true),
            (r"\text{the length of the member}", false),
            (r"\text{the distance to where it is applied}", false),
          ],
        );
      case BriefFigure.sense:
        return const _RuleList(
          rules: [
            (r"\text{down, right of the pin} \;\Rightarrow\; \text{clockwise}", true),
            (r"\text{up, left of the pin} \;\Rightarrow\; \text{clockwise}", true),
            (r"\text{down} \;\Rightarrow\; \text{always clockwise}", false),
            (r"\text{a couple} \;\Rightarrow\; \text{the two cancel}", false),
          ],
        );
      case BriefFigure.supports:
        return const _RuleList(
          rules: [
            (r"\text{roller} \;\Rightarrow\; \text{1, square to the surface}", true),
            (r"\text{pin} \;\Rightarrow\; \text{2, and no moment}", true),
            (r"\text{fixed} \;\Rightarrow\; \text{2 and a moment}", true),
            (r"\text{a roller on a slope} \;\Rightarrow\; \text{vertical}", false),
          ],
        );
      case BriefFigure.resultant:
        return const _RuleList(
          rules: [
            (r"\text{uniform} \;\Rightarrow\; \text{middle of the loaded part}", true),
            (r"\text{triangle} \;\Rightarrow\; \tfrac{1}{3} \text{ from the heavy end}", true),
            (r"\text{uniform} \;\Rightarrow\; \text{middle of the member}", false),
            (r"\text{at the far end of the load}", false),
          ],
        );
      case BriefFigure.determinacy:
        return const _RuleList(
          rules: [
            (r"\text{pin} + \text{roller} = 3 \;\Rightarrow\; \text{solvable}", true),
            (r"\text{fixed alone} = 3 \;\Rightarrow\; \text{solvable}", true),
            (r"\text{a couple adds an unknown}", false),
            (r"\text{two rollers} \;\Rightarrow\; \text{it stands up}", false),
          ],
        );
      case BriefFigure.deformation:
        return const _RuleList(
          rules: [
            (r"\text{more load or more length} \;\Rightarrow\; \text{more stretch}", true),
            (r"\text{more area or a stiffer material} \;\Rightarrow\; \text{less}", true),
            (r"\text{a longer bar carries more stress}", false),
            (r"\text{doubling every dimension changes nothing}", false),
          ],
        );
      case BriefFigure.units:
        return const _RuleList(
          rules: [
            (r"\text{N, mm and N/mm}^2 \;\Rightarrow\; \text{answers in mm}", true),
            (r"\text{strain has no unit at all}", true),
            (r"\text{cancelling units means the answer is right}", false),
            (r"\text{meters beside millimeters is fine if they cancel}", false),
          ],
        );
      case BriefFigure.thermal:
        return const _RuleList(
          rules: [
            (r"\text{restrained and warmed} \;\Rightarrow\; \text{compression}", true),
            (r"\text{restrained and cooled} \;\Rightarrow\; \text{tension}", true),
            (r"\text{heating a bar makes stress}", false),
            (r"\sigma_t \text{ depends on the cross-section}", false),
          ],
        );
      case BriefFigure.compositeI:
        return const _RuleList(
          rules: [
            (r"\text{each piece brings } \bar{I}_i + A_i d_i^2", true),
            (r"\text{the } Ad^2 \text{ term is usually the bigger half}", true),
            (r"\text{a piece on the axis pulls its weight}", false),
            (r"\text{the biggest piece contributes most}", false),
          ],
        );
      case BriefFigure.natural:
        return const _RuleList(
          rules: [
            (r"4\times k \Rightarrow 2\times \omega_n", true),
            (r"\text{double both} \Rightarrow \text{no change}", true),
            (r"\text{a bigger pull raises } \omega_n", false),
            (r"\omega_n \text{ is already in hertz}", false),
          ],
        );
      case BriefFigure.resonance:
        return const _RuleList(
          rules: [
            (r"\text{trouble when } \omega = \omega_n", true),
            (r"\text{far above or far below is safe}", true),
            (r"\text{a structure resonates on its own}", false),
            (r"\mathrm{rpm} \text{ and } \mathrm{Hz} \text{ compare directly}", false),
          ],
        );
      case BriefFigure.underneath:
        return const _RuleList(
          rules: [
            (r"\varepsilon \text{ has no units at all}", true),
            (r"\text{engineering keeps } A_0 \text{ after necking}", true),
            (r"\text{the stretch itself is the strain}", false),
            (r"\sigma_T \text{ divides by } A_0", false),
          ],
        );
      case BriefFigure.trueStress:
        return const _RuleList(
          rules: [
            (r"\sigma_T > \sigma \text{ once it has stretched}", true),
            (r"\text{UTS is the peak ENGINEERING stress}", true),
            (r"\text{the drop at the end means it weakened}", false),
            (r"\sigma_T = \sigma/(1 + \varepsilon)", false),
          ],
        );
      case BriefFigure.crack:
        return const _RuleList(
          rules: [
            (r"\text{an edge crack goes in whole}", true),
            (r"\text{an internal crack is } 2a", true),
            (r"Y = 1.0 \text{ for an edge crack}", false),
            (r"\text{millimeters go straight in}", false),
          ],
        );
      case BriefFigure.toughness:
        return const _RuleList(
          rules: [
            (r"4a \Rightarrow 2 \times \text{the driving force}", true),
            (r"2\sigma \Rightarrow 2 \times \text{the driving force}", true),
            (r"\text{the longer crack is always worse}", false),
            (r"K_{IC} \text{ is a stress}", false),
          ],
        );
      case BriefFigure.expand:
        return const _RuleList(
          rules: [
            (r"\Delta T \text{ is a difference, not a sum}", true),
            (r"\text{twice the length, twice the movement}", true),
            (r"\text{a thicker member moves more}", false),
            (r"\text{steel and aluminum move alike}", false),
          ],
        );
      case BriefFigure.furnace:
        return const _RuleList(
          rules: [
            (r"\text{fast from austenite} \Rightarrow \text{martensite}", true),
            (r"\text{tempering keeps most of the hardness}", true),
            (r"\text{slow cooling} \Rightarrow \text{martensite}", false),
            (r"\text{any quench hardens any steel}", false),
          ],
        );
      case BriefFigure.tieLine:
        return const _RuleList(
          rules: [
            (r"f_L \text{ uses the arm to } x_\alpha", true),
            (r"f_L + f_\alpha = 1", true),
            (r"f_L \text{ uses the arm to } x_L", false),
            (r"\text{the denominator starts at zero}", false),
          ],
        );
      case BriefFigure.mix:
        return const _RuleList(
          rules: [
            (r"\text{more water} \Rightarrow \text{weaker}", true),
            (r"\text{more cement, same water} \Rightarrow \text{stronger}", true),
            (r"W/C = \frac{\text{water}}{\text{whole batch}}", false),
            (r"\text{aggregate changes } W/C", false),
          ],
        );
      case BriefFigure.exposure:
        return const _RuleList(
          rules: [
            (r"\text{it freezes wet} \Rightarrow \text{entrain air}", true),
            (r"\text{air costs strength}", true),
            (r"\text{air always improves concrete}", false),
            (r"\text{water fixes workability}", false),
          ],
        );
      case BriefFigure.curing:
        return const _RuleList(
          rules: [
            (r"f_{c,28} = f_{c,7} \div 0.70", true),
            (r"\text{toward the smaller number: multiply}", true),
            (r"f_{c,28} = f_{c,7} \times 0.70", false),
            (r"90\% \Rightarrow \text{multiply by } 0.10", false),
          ],
        );
      case BriefFigure.field:
        return const _RuleList(
          rules: [
            (r"\text{take the curing off, then compare}", true),
            (r"\text{dried out early} \Rightarrow \text{a third gone}", true),
            (r"\text{the lab break is what the slab has}", false),
            (r"\text{a richer mix beats better curing}", false),
          ],
        );
      case BriefFigure.weighing:
        return const _RuleList(
          rules: [
            (r"B - C \text{ is the whole particle}", true),
            (r"G_{sa} \text{ is the largest of the three}", true),
            (r"\text{absorption divides by } B", false),
            (r"A - C \text{ is the bulk volume}", false),
          ],
        );
      case BriefFigure.grading:
        return const _RuleList(
          rules: [
            (r"\text{a higher } FM \text{ is coarser}", true),
            (r"\text{cumulative \% RETAINED}", true),
            (r"\text{a higher } FM \text{ is finer}", false),
            (r"FM \text{ describes the whole curve}", false),
          ],
        );
      case BriefFigure.voids:
        return const _RuleList(
          rules: [
            (r"VMA = V_a + \text{binder voids}", true),
            (r"VFA \text{ is a share of } VMA", true),
            (r"VFA \text{ is a share of the whole mix}", false),
            (r"V_a \text{ is a share of } VMA", false),
          ],
        );
      case BriefFigure.check:
        return const _RuleList(
          rules: [
            (r"G_{mm} > G_{mb} \text{ always}", true),
            (r"VMA > V_a \text{ always}", true),
            (r"VFA \text{ may pass } 100\%", false),
            (r"VMA \approx 86\% \text{ is normal}", false),
          ],
        );
      case BriefFigure.moisture:
        return const _RuleList(
          rules: [
            (r"MC \text{ divides by the DRY weight}", true),
            (r"MC > 100\% \text{ is possible}", true),
            (r"\text{drying above } 30\% \text{ shrinks it}", false),
            (r"\text{wetter wood is stronger}", false),
          ],
        );
      case BriefFigure.mortar:
        return const _RuleList(
          rules: [
            (r"M > S > N > O", true),
            (r"\text{the weakest works the easiest}", true),
            (r"\text{the strongest is always the best}", false),
            (r"\text{the order runs } M < S < N < O", false),
          ],
        );
      case BriefFigure.factor:
        return const _RuleList(
          rules: [
            (r"\text{wind: } C_D = 1.6", true),
            (r"\text{wet service: } C_M < 1", true),
            (r"\text{permanent load: } C_D > 1", false),
            (r"C_D = 1 \text{ for every load}", false),
          ],
        );
      case BriefFigure.blend:
        return const _RuleList(
          rules: [
            (r"\text{along} \Rightarrow f_1E_1 + f_2E_2", true),
            (r"\text{across gives the smaller } E_c", true),
            (r"\text{across} \Rightarrow f_1E_1 + f_2E_2", false),
            (r"\rho_c \text{ depends on direction}", false),
          ],
        );
      case BriefFigure.isostrain:
        return const _RuleList(
          rules: [
            (r"\text{along: } \varepsilon_1 = \varepsilon_2", true),
            (r"\text{the stiffer phase takes the stress}", true),
            (r"\text{along: } \sigma_1 = \sigma_2", false),
            (r"\text{stress splits by volume}", false),
          ],
        );
      case BriefFigure.galvanic:
        return const _RuleList(
          rules: [
            (r"\text{the more active metal corrodes}", true),
            (r"\text{no water} \Rightarrow \text{no cell}", true),
            (r"\text{the exposed metal corrodes}", false),
            (r"\text{a metal is safe on its own terms}", false),
          ],
        );
      case BriefFigure.picking:
        return const _RuleList(
          rules: [
            (r"\text{cross off column by column}", true),
            (r"\text{nothing passing is an answer}", true),
            (r"\text{the best conductor wins}", false),
            (r"\text{one column decides it}", false),
          ],
        );
      case BriefFigure.threeNumbers:
        return const _RuleList(
          rules: [
            (r"SG \text{ has no units}", true),
            (r"\gamma = \rho g", true),
            (r"\gamma \text{ is in kg/m}^3", false),
            (r"p = \rho h", false),
          ],
        );
      case BriefFigure.viscosity:
        return const _RuleList(
          rules: [
            (r"\text{thinner film} \Rightarrow \text{more shear}", true),
            (r"\tau = \mu\, v / \delta", true),
            (r"\text{thicker film} \Rightarrow \text{more shear}", false),
            (r"\tau = \nu\, v / \delta", false),
          ],
        );
      case BriefFigure.capillary:
        return const _RuleList(
          rules: [
            (r"\text{half the bore} \Rightarrow \text{twice the rise}", true),
            (r"\beta > 90^\circ \Rightarrow \text{it goes down}", true),
            (r"\text{the radius goes underneath}", false),
            (r"\text{a wider tube climbs higher}", false),
          ],
        );
      case BriefFigure.depth:
        return const _RuleList(
          rules: [
            (r"p = \gamma h", true),
            (r"\text{same depth} \Rightarrow \text{same pressure}", true),
            (r"\text{a wider vessel presses harder}", false),
            (r"p = \rho h", false),
          ],
        );
      case BriefFigure.manometer:
        return const _RuleList(
          rules: [
            (r"\text{down a column} \Rightarrow +\gamma h", true),
            (r"\text{sideways} \Rightarrow \text{no change}", true),
            (r"\text{up a column} \Rightarrow +\gamma h", false),
            (r"\text{one } \gamma \text{ for the whole tube}", false),
          ],
        );
      case BriefFigure.gauge:
        return const _RuleList(
          rules: [
            (r"P_{abs} = P_{atm} + P_{gauge}", true),
            (r"\text{open to the air} \Rightarrow P_{gauge} = 0", true),
            (r"\gamma h \text{ gives an absolute pressure}", false),
            (r"P_{gauge} \text{ cannot be negative}", false),
          ],
        );
      case BriefFigure.gate:
        return const _RuleList(
          rules: [
            (r"F_R \text{ uses the centroid depth}", true),
            (r"y_{CP} \text{ is always deeper than } y_C", true),
            (r"F_R \text{ acts at the centroid}", false),
            (r"F_R \text{ uses the bottom depth}", false),
          ],
        );
      case BriefFigure.buoyancy:
        return const _RuleList(
          rules: [
            (r"F_B = \gamma V_{displaced}", true),
            (r"\text{floating} \Rightarrow F_B = W", true),
            (r"F_B \text{ uses the body's own } \gamma", false),
            (r"\text{hollow bodies displace less}", false),
          ],
        );
      case BriefFigure.continuity:
        return const _RuleList(
          rules: [
            (r"\text{half the bore} \Rightarrow 4v", true),
            (r"\text{half the AREA} \Rightarrow 2v", true),
            (r"\text{half the bore} \Rightarrow 2v", false),
            (r"\text{a longer pipe runs slower}", false),
          ],
        );
      case BriefFigure.bernoulli:
        return const _RuleList(
          rules: [
            (r"\text{faster} \Rightarrow \text{lower pressure}", true),
            (r"\text{continuity first, then Bernoulli}", true),
            (r"\text{narrower} \Rightarrow \text{higher pressure}", false),
            (r"\text{Bernoulli covers friction}", false),
          ],
        );
      case BriefFigure.torricelli:
        return const _RuleList(
          rules: [
            (r"v = \sqrt{2gh}", true),
            (r"4h \Rightarrow 2v", true),
            (r"\text{a bigger hole is a faster jet}", false),
            (r"\text{a wider tank is a faster jet}", false),
          ],
        );
      case BriefFigure.reynolds:
        return const _RuleList(
          rules: [
            (r"Re < 2{,}100 \Rightarrow f = 64/Re", true),
            (r"Re > 10{,}000 \Rightarrow \text{Moody}", true),
            (r"\text{water mains are usually laminar}", false),
            (r"Re \text{ has units of m/s}", false),
          ],
        );
      case BriefFigure.darcy:
        return const _RuleList(
          rules: [
            (r"2v \Rightarrow 4 h_f", true),
            (r"2L \Rightarrow 2 h_f", true),
            (r"2v \Rightarrow 2 h_f", false),
            (r"f_{Fanning} \text{ goes in as is}", false),
          ],
        );
      case BriefFigure.degreeOfCurve:
        return const _RuleList(
          rules: [
            (r"D \times R \approx 5{,}730", true),
            (r"\text{bigger } D \Rightarrow \text{sharper}", true),
            (r"\text{bigger } D \Rightarrow \text{gentler}", false),
            (r"D = 1° \Rightarrow R = 100 \text{ ft}", false),
          ],
        );
      case BriefFigure.roadCurve:
        return const _RuleList(
          rules: [
            (r"T = R\tan\tfrac{I}{2}", true),
            (r"\text{the stationing runs round the arc}", true),
            (r"T = R\tan I", false),
            (r"\text{the arc is shorter than the chord}", false),
          ],
        );
      case BriefFigure.tangentOffset:
        return const _RuleList(
          rules: [
            (r"\text{the gap grows as } x^2", true),
            (r"g_2 < g_1 \Rightarrow \text{road below the line}", true),
            (r"\text{the PVI is on the road}", false),
            (r"\text{the gap is the same all along}", false),
          ],
        );
      case BriefFigure.highPoint:
        return const _RuleList(
          rules: [
            (r"|g_1| = |g_2| \Rightarrow x_m = \tfrac{L}{2}", true),
            (r"x_m \text{ outside } 0..L \Rightarrow \text{none on the curve}", true),
            (r"x_m \text{ is under the PVI}", false),
            (r"x_m = K", false),
          ],
        );
      case BriefFigure.wetted:
        return const _RuleList(
          rules: [
            (r"P_{rect} = b + 2y", true),
            (r"\text{a full pipe: } R_H = \tfrac{D}{4}", true),
            (r"\text{the water surface counts}", false),
            (r"\text{a full pipe: } R_H = \tfrac{D}{2}", false),
          ],
        );
      case BriefFigure.manning:
        return const _RuleList(
          rules: [
            (r"\text{half } n \Rightarrow \text{double } v", true),
            (r"4S \Rightarrow 2v", true),
            (r"\text{a full pipe beats a half full one}", false),
            (r"4S \Rightarrow 4v", false),
          ],
        );
      case BriefFigure.unitFactor:
        return const _RuleList(
          rules: [
            (r"\text{feet} \Rightarrow K = 1.486", true),
            (r"n \text{ is the same in both systems}", true),
            (r"\text{the answer's units pick } K", false),
            (r"\text{inches go straight in}", false),
          ],
        );
      case BriefFigure.froude:
        return const _RuleList(
          rules: [
            (r"Fr < 1 \Rightarrow \text{news gets upstream}", true),
            (r"\text{ripple speed} = \sqrt{gy}", true),
            (r"Fr > 1 \Rightarrow \text{subcritical}", false),
            (r"\text{shallow always means } Fr > 1", false),
          ],
        );
      case BriefFigure.criticalDepth:
        return const _RuleList(
          rules: [
            (r"2q \Rightarrow 1.6\,y_c", true),
            (r"E_{min} = 1.5\,y_c", true),
            (r"\text{a steeper channel lowers } y_c", false),
            (r"\text{a smoother lining lowers } y_c", false),
          ],
        );
      case BriefFigure.hydraulicJump:
        return const _RuleList(
          rules: [
            (r"y_2 > y_1 \text{ always}", true),
            (r"\text{momentum across, energy lost}", true),
            (r"\text{energy is conserved across a jump}", false),
            (r"\text{a jump can run deep to shallow}", false),
          ],
        );
      case BriefFigure.weirShape:
        return const _RuleList(
          rules: [
            (r"\text{V-notch: } Q = C H^{5/2}", true),
            (r"\text{contracted: } L - 0.2H", true),
            (r"\text{a V-notch has a crest length}", false),
            (r"\text{one } C \text{ fits every weir}", false),
          ],
        );
      case BriefFigure.weirExponent:
        return const _RuleList(
          rules: [
            (r"2H \Rightarrow 5.7Q \text{ on a V}", true),
            (r"\text{only the ratio of heads counts}", true),
            (r"2H \Rightarrow 2Q", false),
            (r"\text{a longer crest responds faster}", false),
          ],
        );
      case BriefFigure.hazen:
        return const _RuleList(
          rules: [
            (r"\text{bigger } C \Rightarrow \text{smoother}", true),
            (r"\frac{Q_A}{Q_B} = \frac{C_A}{C_B}", true),
            (r"\text{bigger } C \Rightarrow \text{rougher}", false),
            (r"\frac{Q_A}{Q_B} = \left(\frac{C_A}{C_B}\right)^{0.63}", false),
          ],
        );
      case BriefFigure.pumpPower:
        return const _RuleList(
          rules: [
            (r"\dot W_{brake} > \dot W_{fluid}", true),
            (r"2Q \Rightarrow 2\dot W", true),
            (r"\dot W_{brake} = \eta\,\gamma Q H", false),
            (r"\text{a bigger motor draws more}", false),
          ],
        );
      case BriefFigure.npsh:
        return const _RuleList(
          rules: [
            (r"\text{a lift}: H_s < 0", true),
            (r"\text{warm water lowers the margin}", true),
            (r"\text{discharge losses lower the margin}", false),
            (r"\text{a lift}: H_s > 0", false),
          ],
        );
      case BriefFigure.rational:
        return const _RuleList(
          rules: [
            (r"1 \text{ acre-in/hr} \approx 1 \text{ cfs}", true),
            (r"C \text{ is dimensionless}", true),
            (r"\text{convert the acres to square feet}", false),
            (r"\text{good for a 2,000 acre basin}", false),
          ],
        );
      case BriefFigure.runoffBlend:
        return const _RuleList(
          rules: [
            (r"C = \frac{\sum C_i A_i}{\sum A_i}", true),
            (r"\text{equal areas} \Rightarrow \text{halfway}", true),
            (r"C = \frac{C_1 + C_2}{2}", false),
            (r"\text{the bigger } C \text{ always wins}", false),
          ],
        );
      case BriefFigure.curveNumber:
        return const _RuleList(
          rules: [
            (r"P \le 0.2S \Rightarrow Q = 0", true),
            (r"Q \text{ is a depth in inches}", true),
            (r"Q \text{ is a discharge in cfs}", false),
            (r"S = CN", false),
          ],
        );
      case BriefFigure.unitHydrograph:
        return const _RuleList(
          rules: [
            (r"3P \Rightarrow 3Q \text{ at the same } t", true),
            (r"\text{another duration needs another UH}", true),
            (r"3P \Rightarrow 3t", false),
            (r"\text{one UH fits every storm}", false),
          ],
        );
      case BriefFigure.concentration:
        return const _RuleList(
          rules: [
            (r"D = t_c \Rightarrow \text{the largest peak}", true),
            (r"D < t_c \Rightarrow \text{part of } A", true),
            (r"\text{shorter is always worse for } I", false),
            (r"D > t_c \Rightarrow \text{a bigger peak}", false),
          ],
        );
      case BriefFigure.routing:
        return const _RuleList(
          rules: [
            (r"I > O \Rightarrow \text{filling}", true),
            (r"I = O \Rightarrow \text{fullest}", true),
            (r"O - I = \frac{\Delta S}{\Delta t}", false),
            (r"\text{the pond is fullest at the inflow peak}", false),
          ],
        );
      case BriefFigure.seepage:
        return const _RuleList(
          rules: [
            (r"v = \frac{q}{n} > q", true),
            (r"qA \text{ is a volume a second}", true),
            (r"v = q n", false),
            (r"\text{a tracer moves at } q", false),
          ],
        );
      case BriefFigure.wells:
        return const _RuleList(
          rules: [
            (r"\text{confined} \Rightarrow \text{heads as they are}", true),
            (r"\text{unconfined} \Rightarrow \text{heads squared}", true),
            (r"\log_{10} \text{ in the denominator}", false),
            (r"T = Kb \text{ for an unconfined aquifer}", false),
          ],
        );
      case BriefFigure.bod:
        return const _RuleList(
          rules: [
            (r"BOD_5 < L_0 \text{ always}", true),
            (r"\text{exerted} + \text{remaining} = L_0", true),
            (r"BOD_5 = 0.68 L_0 \text{ for any } k", false),
            (r"BOD_5 = L_0", false),
          ],
        );
      case BriefFigure.rateTemperature:
        return const _RuleList(
          rules: [
            (r"T > 20 \Rightarrow \text{bigger } k", true),
            (r"L_0 \text{ does not move}", true),
            (r"\theta^{(20-T)}", false),
            (r"\text{warm water raises } L_0", false),
          ],
        );
      case BriefFigure.overflow:
        return const _RuleList(
          rules: [
            (r"v_s > v_o \Rightarrow \text{captured}", true),
            (r"\text{deeper changes } \theta, \text{ not } v_o", true),
            (r"\text{a deeper tank captures more}", false),
            (r"v_o = \frac{Q}{V}", false),
          ],
        );
      case BriefFigure.residence:
        return const _RuleList(
          rules: [
            (r"\theta \text{ in hours}, \theta_c \text{ in days}", true),
            (r"\text{more wasting} \Rightarrow \text{shorter } \theta_c", true),
            (r"\theta_c = \frac{V}{Q}", false),
            (r"\text{the effluent solids do not count}", false),
          ],
        );
      case BriefFigure.foodRatio:
        return const _RuleList(
          rules: [
            (r"2Q \text{ and } \tfrac{S_0}{2} \Rightarrow \text{no change}",
                true),
            (r"\text{more MLSS} \Rightarrow \text{lower } F{:}M", true),
            (r"\text{a bigger basin raises } F{:}M", false),
            (r"F{:}M = \frac{Q S_0}{V}", false),
          ],
        );
      case BriefFigure.chlorineDose:
        return const _RuleList(
          rules: [
            (r"\text{dose} = \text{demand} + \text{residual}", true),
            (r"1 \text{ mg/L} = 1 \text{ g/m}^3", true),
            (r"\text{dose} = \text{residual}", false),
            (r"\text{the demand is set by the plant}", false),
          ],
        );
      case BriefFigure.contactTime:
        return const _RuleList(
          rules: [
            (r"CT = C \times t_{10}", true),
            (r"t_{10} < \frac{V}{Q}", true),
            (r"CT = \text{dose} \times \frac{V}{Q}", false),
            (r"\text{baffles do not change } t_{10}", false),
          ],
        );
      case BriefFigure.tiers:
        return const _RuleList(
          rules: [
            (r"\text{arsenic: primary}", true),
            (r"\text{iron: secondary}", true),
            (r"\text{a small limit means primary}", false),
            (r"\text{secondary limits are enforceable}", false),
          ],
        );
      case BriefFigure.hardness:
        return const _RuleList(
          rules: [
            (r"Ca \times 2.5, \; Mg \times 4.12", true),
            (r"\text{convert, then add}", true),
            (r"\text{add, then convert}", false),
            (r"\text{one multiplier fits both}", false),
          ],
        );
      case BriefFigure.efficiency:
        return const _RuleList(
          rules: [
            (r"E = \frac{S_0 - S}{S_0}", true),
            (r"\text{the flow cancels}", true),
            (r"E = \frac{S}{S_0}", false),
            (r"\text{more flow raises the required } E", false),
          ],
        );
      case BriefFigure.determinacyCount:
        return const _RuleList(
          rules: [
            (r"\text{a fixed support is } r = 3", true),
            (r"\text{each hinge adds one to } c", true),
            (r"\text{a triangle is always a truss}", false),
            (r"\text{a fixed support is } r = 2", false),
          ],
        );
      case BriefFigure.stability:
        return const _RuleList(
          rules: [
            (r"\text{parallel reactions} \Rightarrow \text{unstable}", true),
            (r"\text{indeterminate can still be unstable}", true),
            (r"m + r = 2j \Rightarrow \text{stable}", false),
            (r"\text{more reactions always help}", false),
          ],
        );
      case BriefFigure.momentCenter:
        return const _RuleList(
          rules: [
            (r"\text{pivot where the unwanted two cross}", true),
            (r"\text{parallel chords: use } \sum F_y", true),
            (r"\text{one pivot suits every member}", false),
            (r"\text{the pivot must be a joint you kept}", false),
          ],
        );
      case BriefFigure.jointForce:
        return const _RuleList(
          rules: [
            (r"F = \frac{P}{\sin\theta} > P", true),
            (r"3\text{-}4\text{-}5: \; \sin = 0.6", true),
            (r"F < P \text{ for a steep member}", false),
            (r"F = P\sin\theta", false),
          ],
        );
      case BriefFigure.trussRoute:
        return const _RuleList(
          rules: [
            (r"\text{one deep member} \Rightarrow \text{sections}", true),
            (r"\text{reactions before either}", true),
            (r"\text{sections for a whole joint}", false),
            (r"\text{joints is always quicker}", false),
          ],
        );
      case BriefFigure.unitLoad:
        return const _RuleList(
          rules: [
            (r"\text{a rotation wants a unit MOMENT}", true),
            (r"\text{the unit load acts alone}", true),
            (r"\text{put it where the real load is}", false),
            (r"\text{one unit load suits every question}", false),
          ],
        );
      case BriefFigure.termSign:
        return const _RuleList(
          rules: [
            (r"n = 0 \Rightarrow \text{the term is gone}", true),
            (r"\text{two compressions} \Rightarrow nN > 0", true),
            (r"\text{a big } N \text{ always counts}", false),
            (r"\delta < 0 \Rightarrow \text{a sign error}", false),
          ],
        );
      case BriefFigure.redundant:
        return const _RuleList(
          rules: [
            (r"\text{a released force} \Rightarrow \delta = 0", true),
            (r"\text{a released moment} \Rightarrow \theta = 0", true),
            (r"\text{only one release will do}", false),
            (r"\text{releasing makes it a mechanism}", false),
          ],
        );
      case BriefFigure.fixity:
        return const _RuleList(
          rules: [
            (r"R_{prop} = \frac{3wL}{8} < \frac{wL}{2}", true),
            (r"\text{symmetric: still } \frac{wL}{2} \text{ each end}", true),
            (r"M_{end} = \frac{wL^2}{8}", false),
            (r"\text{fixity raises the midspan moment}", false),
          ],
        );
      case BriefFigure.lrfd:
        return const _RuleList(
          rules: [
            (r"\text{LRFD: } 1.2D + 1.6L \le \phi R_n", true),
            (r"\text{ASD: } D + L \le R_n/\Omega", true),
            (r"\text{ASD: } 1.6L \le R_n/\Omega", false),
            (r"\text{ASD is no longer allowed}", false),
          ],
        );
      case BriefFigure.controls:
        return const _RuleList(
          rules: [
            (r"\text{floor live biggest} \Rightarrow \text{combo 2}", true),
            (r"\text{roof load biggest} \Rightarrow \text{combo 3}", true),
            (r"\text{combo 2 always controls}", false),
            (r"\text{combo 2 drops the snow}", false),
          ],
        );
      case BriefFigure.reduction:
        return const _RuleList(
          rules: [
            (r"\text{bigger } A_T \Rightarrow \text{bigger reduction}", true),
            (r"K_{LL} = 4 \text{ for a column}", true),
            (r"\text{dead load reduces too}", false),
            (r"L \text{ may fall below } 0.5 L_o \text{ on one floor}", false),
          ],
        );
      case BriefFigure.influenceRead:
        return const _RuleList(
          rules: [
            (r"\text{across: where the load stands}", true),
            (r"R = \sum P_i \eta_i", true),
            (r"\text{it is the moment diagram}", false),
            (r"\text{the height is the moment under the load}", false),
          ],
        );
      case BriefFigure.influenceShapes:
        return const _RuleList(
          rules: [
            (r"\text{a step of } 1 \Rightarrow \text{shear}", true),
            (r"\eta_{peak} = \frac{a(L-a)}{L}", true),
            (r"\text{the moment peak is at midspan}", false),
            (r"\text{a reaction line is a triangle}", false),
          ],
        );
      case BriefFigure.influencePlace:
        return const _RuleList(
          rules: [
            (r"\text{the heaviest load on the peak}", true),
            (r"\text{shear: just right of the section}", true),
            (r"\text{straddle the peak evenly}", false),
            (r"\text{a spread load covers the whole span}", false),
          ],
        );
      case BriefFigure.effectiveDepth:
        return const _RuleList(
          rules: [
            (r"d = h - \text{cover} - \text{stirrup} - d_b/2", true),
            (r"\text{the arm is } d - a/2", true),
            (r"d = h", false),
            (r"\text{the arm is } d", false),
          ],
        );
      case BriefFigure.stirrupLadder:
        return const _RuleList(
          rules: [
            (r"V_u \le \phi V_c / 2 \Rightarrow \text{none}", true),
            (r"V_s > 4V_c \Rightarrow \text{enlarge}", true),
            (r"V_s = V_u - V_c", false),
            (r"\text{tighter spacing always works}", false),
          ],
        );
      case BriefFigure.phiFactors:
        return const _RuleList(
          rules: [
            (r"\text{bending } 0.90, \text{ shear } 0.75", true),
            (r"M_n \text{ carries no } \phi", true),
            (r"\phi = 0.90 \text{ for shear}", false),
            (r"\text{loads and capacity both go up}", false),
          ],
        );
      case BriefFigure.columnFactors:
        return const _RuleList(
          rules: [
            (r"\text{tied: } 0.80 \text{ and } \phi = 0.65", true),
            (r"\text{spiral: } 0.85 \text{ and } \phi = 0.75", true),
            (r"\text{beams get the } 0.80 \text{ too}", false),
            (r"0.80 \text{ is the resistance factor}", false),
          ],
        );
      case BriefFigure.steelWindow:
        return const _RuleList(
          rules: [
            (r"0.01 \le \rho_g \le 0.08", true),
            (r"\rho_g = 0.01 \text{ is allowed}", true),
            (r"\rho_g = 0.009 \text{ is close enough}", false),
            (r"\text{more steel is always safer}", false),
          ],
        );
      case BriefFigure.bracing:
        return const _RuleList(
          rules: [
            (r"L_b \le L_p \Rightarrow M_n = M_p", true),
            (r"\text{a slab on top} \Rightarrow L_b = 0", true),
            (r"\text{closer braces always add capacity}", false),
            (r"L_p \text{ is the same for every shape}", false),
          ],
        );
      case BriefFigure.moduli:
        return const _RuleList(
          rules: [
            (r"M_p = F_y Z_x \text{ in both methods}", true),
            (r"Z_x > S_x", true),
            (r"S_x \text{ is the one for ASD}", false),
            (r"Z_x \text{ appears in the buckling term}", false),
          ],
        );
      case BriefFigure.flanges:
        return const _RuleList(
          rules: [
            (r"\text{hogging: the BOTTOM flange buckles}", true),
            (r"V_n = 0.6 F_y A_w", true),
            (r"\text{the top flange is always the one}", false),
            (r"\text{the flanges carry the shear}", false),
          ],
        );
      case BriefFigure.whichAxis:
        return const _RuleList(
          rules: [
            (r"\text{the larger } KL/r \text{ wins}", true),
            (r"\text{a brace shortens one axis only}", true),
            (r"\text{the weak axis always controls}", false),
            (r"\text{more bracing always helps}", false),
          ],
        );
      case BriefFigure.columnTable:
        return const _RuleList(
          rules: [
            (r"\phi_c P_n = (\phi_c F_{cr}) A_g", true),
            (r"\text{elastic buckling ignores } F_y", true),
            (r"\text{multiply the table value by } 0.90", false),
            (r"F_y A_g \text{ is the design strength}", false),
          ],
        );
      case BriefFigure.twoLimits:
        return const _RuleList(
          rules: [
            (r"\text{yielding: } 0.90 F_y A_g", true),
            (r"\text{rupture: } 0.75 F_u A_e", true),
            (r"F_u > F_y \Rightarrow \text{yielding controls}", false),
            (r"\text{holes reduce } A_g", false),
          ],
        );
      case BriefFigure.netArea:
        return const _RuleList(
          rules: [
            (r"\text{each hole costs } d_b + \tfrac{1}{8}", true),
            (r"\text{it comes off the width}", true),
            (r"\text{bolts in a row all come off one cut}", false),
            (r"\text{the bolt fills the hole}", false),
          ],
        );
      case BriefFigure.shearLag:
        return const _RuleList(
          rules: [
            (r"A_e = U A_n", true),
            (r"\text{a longer connection raises } U", true),
            (r"U \text{ applies to yielding too}", false),
            (r"\text{an angle on one leg has } U = 1", false),
          ],
        );
      case BriefFigure.phaseDiagram:
        return const _RuleList(
          rules: [
            (r"e = \frac{V_v}{V_s} \text{ can pass } 1", true),
            (r"\omega \text{ is a ratio of WEIGHTS}", true),
            (r"n \text{ and } e \text{ are the same thing}", false),
            (r"S = \frac{V_w}{V}", false),
          ],
        );
      case BriefFigure.masterRelation:
        return const _RuleList(
          rules: [
            (r"S e = \omega G_s", true),
            (r"S = 1 \Rightarrow e = \omega G_s", true),
            (r"e = \omega G_s \text{ always}", false),
            (r"\omega = 20 \text{ goes straight in}", false),
          ],
        );
      case BriefFigure.unitWeights:
        return const _RuleList(
          rules: [
            (r"\gamma_{sat} > \gamma > \gamma_d", true),
            (r"\gamma' = \gamma_{sat} - \gamma_w", true),
            (r"\gamma_d \text{ uses a shrunken volume}", false),
            (r"\text{use } \gamma \text{ below the water table}", false),
          ],
        );
      case BriefFigure.uscsTree:
        return const _RuleList(
          rules: [
            (r"\text{No. 200 decides coarse or fine}", true),
            (r"\text{a gravel needs only } C_u \ge 4", true),
            (r"\text{fines go on the grain size curve}", false),
            (r"\text{half retained is coarse}", false),
          ],
        );
      case BriefFigure.plasticityChart:
        return const _RuleList(
          rules: [
            (r"\text{above the A-line} \Rightarrow \text{clay}", true),
            (r"LL \ge 50 \Rightarrow H", true),
            (r"\text{high } LL \Rightarrow \text{clay}", false),
            (r"\text{below the A-line} \Rightarrow CL", false),
          ],
        );
      case BriefFigure.gradation:
        return const _RuleList(
          rules: [
            (r"\text{both } C_u \text{ and } C_c \text{ must pass}", true),
            (r"1 \le C_c \le 3", true),
            (r"\text{a big } C_u \text{ is enough}", false),
            (r"C_u \ge 6 \text{ for every soil}", false),
          ],
        );
      case BriefFigure.threeStresses:
        return const _RuleList(
          rules: [
            (r"\sigma' = \sigma - u", true),
            (r"u = 0 \text{ above the water table}", true),
            (r"u \text{ is measured from the surface}", false),
            (r"\text{a surcharge raises } u", false),
          ],
        );
      case BriefFigure.waterTable:
        return const _RuleList(
          rules: [
            (r"\text{pump it down} \Rightarrow \sigma' \uparrow", true),
            (r"\text{standing water changes nothing}", true),
            (r"\text{a rising table raises } \sigma'", false),
            (r"\text{a surcharge raises } u \text{ for good}", false),
          ],
        );
      case BriefFigure.buoyantWalk:
        return const _RuleList(
          rules: [
            (r"\text{below the table use } \gamma'", true),
            (r"\text{both routes agree exactly}", true),
            (r"\text{buoy the layer above the table}", false),
            (r"\text{a surcharge is buoyed too}", false),
          ],
        );
      case BriefFigure.settlementCase:
        return const _RuleList(
          rules: [
            (r"p_1 < p_c \Rightarrow C_r \text{ alone}", true),
            (r"p_0 < p_c < p_1 \Rightarrow \text{both, in two}", true),
            (r"\text{one index always does}", false),
            (r"p_c \text{ is the current stress}", false),
          ],
        );
      case BriefFigure.clayMemory:
        return const _RuleList(
          rules: [
            (r"C_r \approx C_c/6", true),
            (r"\text{the corner is } p_c", true),
            (r"\text{the curve has one slope}", false),
            (r"\text{a load alone gives the settlement}", false),
          ],
        );
      case BriefFigure.drainagePath:
        return const _RuleList(
          rules: [
            (r"t \propto H_{dr}^2", true),
            (r"\text{one rock face} \Rightarrow 4\times \text{ the wait}", true),
            (r"\text{a bigger load settles slower}", false),
            (r"H_{dr} = H \text{ when both faces drain}", false),
          ],
        );
      case BriefFigure.mohrCoulomb:
        return const _RuleList(
          rules: [
            (r"\text{a sand: } c' = 0", true),
            (r"\text{a fast-loaded clay: } \phi_u = 0", true),
            (r"\text{a sand is strong at the surface}", false),
            (r"\text{pressing a fast clay harder helps}", false),
          ],
        );
      case BriefFigure.drainage:
        return const _RuleList(
          rules: [
            (r"c_u, \phi_u \text{ go with } \sigma", true),
            (r"\text{long term} \Rightarrow \text{effective}", true),
            (r"\phi' \text{ with a total stress}", false),
            (r"\text{a clay is weakest in the long run}", false),
          ],
        );
      case BriefFigure.soilCircle:
        return const _RuleList(
          rules: [
            (r"c_u = \frac{\sigma_1-\sigma_3}{2}", true),
            (r"\sin\phi = t/s \text{ when } c = 0", true),
            (r"c_u = \sigma_1 - \sigma_3", false),
            (r"\tan\phi = t/s", false),
          ],
        );
      case BriefFigure.flowNet:
        return const _RuleList(
          rules: [
            (r"q = k H \frac{N_f}{N_d}", true),
            (r"\text{a channel is a lane, not a line}", true),
            (r"q = k H \frac{N_d}{N_f}", false),
            (r"\text{a more permeable soil changes the net}", false),
          ],
        );
      case BriefFigure.quickCondition:
        return const _RuleList(
          rules: [
            (r"i_c = \frac{G_s - 1}{1 + e}", true),
            (r"\text{looser sand boils sooner}", true),
            (r"i_c = 1 \text{ exactly}", false),
            (r"\text{raise the upstream water to help}", false),
          ],
        );
      case BriefFigure.infiniteSlope:
        return const _RuleList(
          rules: [
            (r"FS = \tan\phi / \tan\beta", true),
            (r"\text{depth cancels out}", true),
            (r"\text{a deeper slope is less safe}", false),
            (r"FS = \tan\beta / \tan\phi", false),
          ],
        );
      case BriefFigure.slopeSeepage:
        return const _RuleList(
          rules: [
            (r"\text{seepage} \Rightarrow FS \text{ about halved}", true),
            (r"\gamma'/\gamma_{sat} \approx 0.5", true),
            (r"\text{rain weakens the grains}", false),
            (r"\text{a dry } FS = 1.1 \text{ is enough}", false),
          ],
        );
      case BriefFigure.slipWedge:
        return const _RuleList(
          rules: [
            (r"W\sin\alpha \text{ drives}, \; W\cos\alpha \text{ holds}", true),
            (r"cL_s \text{ owes nothing to } W", true),
            (r"\text{cohesion is a small term}", false),
            (r"FS = \text{driving}/\text{resisting}", false),
          ],
        );
      case BriefFigure.threeTerms:
        return const _RuleList(
          rules: [
            (r"\text{on the surface: no depth term}", true),
            (r"\phi = 0 \Rightarrow N_\gamma = 0", true),
            (r"\text{a clean sand has a cohesion term}", false),
            (r"\text{the factors must be memorized}", false),
          ],
        );
      case BriefFigure.footingFix:
        return const _RuleList(
          rules: [
            (r"\text{on sand, deeper beats wider}", true),
            (r"\text{on clay, wider buys no pressure}", true),
            (r"\text{widening always helps the soil}", false),
            (r"\text{the water table does not matter}", false),
          ],
        );
      case BriefFigure.allowablePressure:
        return const _RuleList(
          rules: [
            (r"q_{allow} = q_{ult}/FS", true),
            (r"\text{compare pressure with pressure}", true),
            (r"\text{divide the load by } FS", false),
            (r"\text{bearing covers settlement}", false),
          ],
        );
      case BriefFigure.threeChecks:
        return const _RuleList(
          rules: [
            (r"\text{overturning: moments about the toe}", true),
            (r"\text{sliding: forces along the base}", true),
            (r"\text{one good check covers another}", false),
            (r"FS = M_O / \Sigma M_R", false),
          ],
        );
      case BriefFigure.middleThird:
        return const _RuleList(
          rules: [
            (r"\bar{x} = (\Sigma M_R - M_O)/\Sigma V", true),
            (r"e = B/2 - \bar{x}", true),
            (r"e = \bar{x}", false),
            (r"\text{the middle third means } e \leq B/3", false),
          ],
        );
      case BriefFigure.basePressure:
        return const _RuleList(
          rules: [
            (r"e = 0 \Rightarrow q = \Sigma V / B", true),
            (r"q_{toe} > \Sigma V/B > q_{heel}", true),
            (r"q = \Sigma V / B \text{ always}", false),
            (r"\text{the heel takes the most}", false),
          ],
        );
      case BriefFigure.proctor:
        return const _RuleList(
          rules: [
            (r"RC = \gamma_{d,field} / \gamma_{d,max}", true),
            (r"\text{past the optimum, water loosens it}", true),
            (r"\text{wetter is always denser}", false),
            (r"RC = \gamma_{d,max} / \gamma_{d,field}", false),
          ],
        );
      case BriefFigure.relativeDensity:
        return const _RuleList(
          rules: [
            (r"D_r = (e_{max} - e)/(e_{max} - e_{min})", true),
            (r"\text{low } e \Rightarrow \text{high } D_r", true),
            (r"D_r = (e - e_{min})/(e_{max} - e_{min})", false),
            (r"\text{clays get a relative density}", false),
          ],
        );
      case BriefFigure.stabilizer:
        return const _RuleList(
          rules: [
            (r"\text{plastic clay: lime}", true),
            (r"\text{granular soil: cement}", true),
            (r"\text{cement suits every soil}", false),
            (r"\text{water improves a swelling clay}", false),
          ],
        );
      case BriefFigure.pileCapacity:
        return const _RuleList(
          rules: [
            (r"Q_{ult} = q_p A_p + f_s A_s", true),
            (r"\text{on rock: mostly the tip}", true),
            (r"Q_{ult} = q_p A_s", false),
            (r"\text{the tip is always the larger part}", false),
          ],
        );
      case BriefFigure.goingDeep:
        return const _RuleList(
          rules: [
            (r"\text{deep to get past a settling layer}", true),
            (r"\text{a group in clay: efficiency} < 1", true),
            (r"\text{piles are chosen to save money}", false),
            (r"\text{a group settles like one pile}", false),
          ],
        );
      case BriefFigure.downdrag:
        return const _RuleList(
          rules: [
            (r"\text{soil settling past it: a load}", true),
            (r"\text{direction follows relative movement}", true),
            (r"\text{downdrag adds capacity}", false),
            (r"\text{friction is always a resistance}", false),
          ],
        );
      case BriefFigure.sightDistance:
        return const _RuleList(
          rules: [
            (r"SSD = 1.47Vt + \text{braking}", true),
            (r"\text{braking grows as } V^2", true),
            (r"SSD = \text{braking alone}", false),
            (r"\text{both halves grow alike}", false),
          ],
        );
      case BriefFigure.gradeSign:
        return const _RuleList(
          rules: [
            (r"\text{uphill } +G: \text{ shorter}", true),
            (r"\text{downhill } -G: \text{ longer}", true),
            (r"\text{downhill is easier to stop on}", false),
            (r"\text{the grade changes the thinking part}", false),
          ],
        );
      case BriefFigure.peakHour:
        return const _RuleList(
          rules: [
            (r"\text{flow rate} = 4V_{15} \geq V", true),
            (r"0.25 \leq PHF \leq 1.00", true),
            (r"\text{flow rate} = V \times PHF", false),
            (r"\text{a low } PHF \text{ needs less capacity}", false),
          ],
        );
      case BriefFigure.crestSag:
        return const _RuleList(
          rules: [
            (r"\text{crest: divide by } 2{,}158", true),
            (r"\text{sag: divide by } 400 + 3.5S", true),
            (r"\text{a sag is set by daylight sight}", false),
            (r"\text{the two denominators swap freely}", false),
          ],
        );
      case BriefFigure.gradeBreak:
        return const _RuleList(
          rules: [
            (r"+3 \text{ into } -5 \Rightarrow A = 8", true),
            (r"g_2 < g_1 \Rightarrow \text{a crest}", true),
            (r"+3 \text{ into } -5 \Rightarrow A = 2", false),
            (r"\text{a negative } g_2 \text{ means a sag}", false),
          ],
        );
      case BriefFigure.superelevation:
        return const _RuleList(
          rules: [
            (r"0.01e = V^2/(15R) - f", true),
            (r"2V \Rightarrow 4\times \text{ the demand}", true),
            (r"0.01e = V^2/(15R) + f", false),
            (r"e \text{ is quoted as a decimal}", false),
          ],
        );
      case BriefFigure.yellowInterval:
        return const _RuleList(
          rules: [
            (r"y = t + v/(2a)", true),
            (r"v \text{ in feet per second}", true),
            (r"y = t + v/a", false),
            (r"v \text{ in miles per hour}", false),
          ],
        );
      case BriefFigure.allRed:
        return const _RuleList(
          rules: [
            (r"r = (W + l)/v", true),
            (r"\text{the back bumper clears it}", true),
            (r"r = W/v", false),
            (r"r = v/(W + l)", false),
          ],
        );
      case BriefFigure.pedestrianGreen:
        return const _RuleList(
          rules: [
            (r"G_p = 3.2 + L/S_p + 0.27N", true),
            (r"S_p = 3.5 \text{ ft/s}", true),
            (r"G_p = 3.2 + L/S_p", false),
            (r"S_p = 4.0 \text{ ft/s}", false),
          ],
        );
      case BriefFigure.greenshields:
        return const _RuleList(
          rules: [
            (r"V_m = D_j S_f / 4", true),
            (r"D_o = D_j/2, \; S_o = S_f/2", true),
            (r"V_m = D_j S_f", false),
            (r"\text{max flow is a comfortable road}", false),
          ],
        );
      case BriefFigure.speedDensity:
        return const _RuleList(
          rules: [
            (r"S = S_f - (S_f/D_j)D", true),
            (r"S \leq S_f \text{ always}", true),
            (r"S = (S_f/D_j)D", false),
            (r"S = S_f/2 \text{ at any density}", false),
          ],
        );
      case BriefFigure.crashRate:
        return const _RuleList(
          rules: [
            (r"RMEV = A \times 10^6 / (ADT \times 365)", true),
            (r"\text{a segment carries its length}", true),
            (r"RMEV = A \times 10^6 / ADT", false),
            (r"\text{more crashes means more dangerous}", false),
          ],
        );
      case BriefFigure.heavyVehicle:
        return const _RuleList(
          rules: [
            (r"f_{HV} = 1/(1 + P_T(E_T - 1))", true),
            (r"0 < f_{HV} \leq 1", true),
            (r"f_{HV} > 1 \text{ with few trucks}", false),
            (r"\text{multiply the volume by } f_{HV}", false),
          ],
        );
      case BriefFigure.demandFlow:
        return const _RuleList(
          rules: [
            (r"v_p = V/(PHF \cdot N \cdot f_{HV})", true),
            (r"\text{per lane, in passenger cars}", true),
            (r"v_p = V/(N \cdot f_{HV})", false),
            (r"v_p = V \cdot PHF / N", false),
          ],
        );
      case BriefFigure.levelOfService:
        return const _RuleList(
          rules: [
            (r"D = v_p / S", true),
            (r"\text{the letter follows the density}", true),
            (r"\text{the letter follows the volume}", false),
            (r"D = v_p \times S", false),
          ],
        );
      case BriefFigure.fourStep:
        return const _RuleList(
          rules: [
            (r"\text{generation, then distribution}", true),
            (r"\text{the gravity model is step two}", true),
            (r"\text{assignment comes first}", false),
            (r"\text{mode choice sets the trip count}", false),
          ],
        );
      case BriefFigure.gravity:
        return const _RuleList(
          rules: [
            (r"T_{ij} = P_i \cdot \tfrac{A_j F_{ij}}{\sum_j A_j F_{ij}}", true),
            (r"\textstyle\sum_j T_{ij} = P_i", true),
            (r"T_{ij} = P_i A_j F_{ij}", false),
            (r"\text{split by attractions alone}", false),
          ],
        );
      case BriefFigure.friction:
        return const _RuleList(
          rules: [
            (r"\text{longer trip} \Rightarrow F \text{ falls}", true),
            (r"\text{a big zone can beat a far one}", true),
            (r"\text{longer trip} \Rightarrow F \text{ rises}", false),
            (r"\text{a faster road makes new trips}", false),
          ],
        );
      case BriefFigure.signCategory:
        return const _RuleList(
          rules: [
            (r"\text{yellow diamond: warning}", true),
            (r"\text{red octagon: regulatory}", true),
            (r"\text{green: regulatory}", false),
            (r"\text{a warning sign sets a legal speed}", false),
          ],
        );
      case BriefFigure.signalWarrant:
        return const _RuleList(
          rules: [
            (r"\text{a warrant comes before a signal}", true),
            (r"\text{a met warrant justifies, not requires}", true),
            (r"\text{a signal is always an improvement}", false),
            (r"\text{only volumes can meet a warrant}", false),
          ],
        );
      case BriefFigure.structuralNumber:
        return const _RuleList(
          rules: [
            (r"SN = \textstyle\sum a_i D_i m_i", true),
            (r"1 \text{ in asphalt} \approx 3 \text{ in base}", true),
            (r"m = 1 \text{ for every course}", false),
            (r"SN \text{ is a thickness}", false),
          ],
        );
      case BriefFigure.layerThickness:
        return const _RuleList(
          rules: [
            (r"D_2 = (SN - \text{the rest})/(a_2 m_2)", true),
            (r"\text{poor drainage} \Rightarrow \text{thicker base}", true),
            (r"D_2 = SN/(a_2 m_2)", false),
            (r"\text{a negative } D_2 \text{ is an error}", false),
          ],
        );
      case BriefFigure.esal:
        return const _RuleList(
          rules: [
            (r"\text{ESALs} = \text{passes} \times LEF", true),
            (r"\text{damage climbs faster than load}", true),
            (r"\text{every axle counts alike}", false),
            (r"LEF \text{ is the weight ratio}", false),
          ],
        );
      case BriefFigure.rigidVsFlexible:
        return const _RuleList(
          rules: [
            (r"\text{a slab bends and spreads the load}", true),
            (r"\text{rigid minds the subgrade less}", true),
            (r"\text{rigid is designed on } SN", false),
            (r"\text{flexible bridges a soft spot}", false),
          ],
        );
      case BriefFigure.pavementJoint:
        return const _RuleList(
          rules: [
            (r"\text{dowel: transfers load, lets it move}", true),
            (r"\text{tie bar: holds the joint shut}", true),
            (r"\text{a dowel ties the slabs together}", false),
            (r"\text{joints are cut to save concrete}", false),
          ],
        );
      case BriefFigure.subgradeReaction:
        return const _RuleList(
          rules: [
            (r"k = \text{pressure} / \text{deflection}", true),
            (r"\text{higher } k \Rightarrow \text{less movement}", true),
            (r"k \text{ is a bearing capacity}", false),
            (r"\text{higher } k \Rightarrow \text{more movement}", false),
          ],
        );
      case BriefFigure.forwardPass:
        return const _RuleList(
          rules: [
            (r"EF = ES + D", true),
            (r"ES = \max(EF \text{ of predecessors})", true),
            (r"ES = \min(EF \text{ of predecessors})", false),
            (r"\text{durations in series multiply}", false),
          ],
        );
      case BriefFigure.projectDuration:
        return const _RuleList(
          rules: [
            (r"\text{duration} = \text{the longest path}", true),
            (r"\text{off the path there is slack}", true),
            (r"\text{duration} = \textstyle\sum D", false),
            (r"\text{shortening any activity helps}", false),
          ],
        );
      case BriefFigure.passes:
        return const _RuleList(
          rules: [
            (r"\text{forward: } \max, \text{ backward: } \min", true),
            (r"LS = LF - D", true),
            (r"\text{backward runs first}", false),
            (r"\text{a late start is the plan}", false),
          ],
        );
      case BriefFigure.float:
        return const _RuleList(
          rules: [
            (r"TF = LS - ES = LF - EF", true),
            (r"FF \leq TF", true),
            (r"TF = EF - ES", false),
            (r"\text{each activity owns its total float}", false),
          ],
        );
      case BriefFigure.criticalPath:
        return const _RuleList(
          rules: [
            (r"\text{the longest path, } TF = 0", true),
            (r"\text{two paths can be critical}", true),
            (r"\text{the critical path is the shortest}", false),
            (r"\text{a day lost off it delays the job}", false),
          ],
        );
      case BriefFigure.earnedValue:
        return const _RuleList(
          rules: [
            (r"CV = BCWP - ACWP", true),
            (r"SV = BCWP - BCWS", true),
            (r"CV = ACWP - BCWP", false),
            (r"\text{a negative variance is good news}", false),
          ],
        );
      case BriefFigure.forecast:
        return const _RuleList(
          rules: [
            (r"CPI = BCWP / ACWP", true),
            (r"EAC = ACWP + ETC", true),
            (r"CPI = ACWP / BCWP", false),
            (r"ETC = BAC - BCWP", false),
          ],
        );
      case BriefFigure.excavation:
        return const _RuleList(
          rules: [
            (r"\text{over } 5 \text{ ft: a protective system}", true),
            (r"\text{over } 20 \text{ ft: designed by a PE}", true),
            (r"\text{firm looking soil needs nothing}", false),
            (r"\text{only shoring is acceptable}", false),
          ],
        );
      case BriefFigure.fallProtection:
        return const _RuleList(
          rules: [
            (r"6 \text{ ft in general construction}", true),
            (r"15 \text{ ft for steel connectors}", true),
            (r"10 \text{ ft in general construction}", false),
            (r"\text{only a harness counts}", false),
          ],
        );
      case BriefFigure.yards:
        return const _RuleList(
          rules: [
            (r"1 \text{ yd}^3 = 27 \text{ ft}^3", true),
            (r"\text{end areas} \geq \text{prismoidal, usually}", true),
            (r"1 \text{ yd}^3 = 3 \text{ ft}^3", false),
            (r"\text{the two methods always agree}", false),
          ],
        );
      case BriefFigure.deliveryFit:
        return const _RuleList(
          rules: [
            (r"\text{complete drawings: design, bid, build}", true),
            (r"\text{a guaranteed maximum: manager at risk}", true),
            (r"\text{design, bid, build can be fast-tracked}", false),
            (r"\text{design-build keeps your own designer}", false),
          ],
        );
      case BriefFigure.curveConversion:
        return const _RuleList(
          rules: [
            (r"R = 5{,}729.58 / D", true),
            (r"T = R\tan(I/2)", true),
            (r"R = 5{,}729.58 \times D", false),
            (r"T = R\tan I", false),
          ],
        );
      case BriefFigure.cornerOffset:
        return const _RuleList(
          rules: [
            (r"E = (g_2 - g_1)L/8", true),
            (r"2L \Rightarrow 2E", true),
            (r"E = (g_2 - g_1)L/4", false),
            (r"\text{the break goes in as per cent}", false),
          ],
        );
      case BriefFigure.stiffness:
        return const _RuleList(
          rules: [
            (r"E = \sigma / \varepsilon", true),
            (r"\text{stiffness is a slope}", true),
            (r"\text{a stiff material is a strong one}", false),
            (r"\varepsilon \text{ has units of mm}", false),
          ],
        );
      case BriefFigure.filterRate:
        return const _RuleList(
          rules: [
            (r"v = Q / A_{plan}", true),
            (r"\text{rapid sand: } 2\text{ to }10 \text{ gpm/ft}^2", true),
            (r"v = Q / L", false),
            (r"\text{a clarifier range fits a filter}", false),
          ],
        );
      case BriefFigure.rankine:
        return const _RuleList(
          rules: [
            (r"K_a < K_0 < K_p", true),
            (r"K_a K_p = 1", true),
            (r"\text{a propped wall gets } K_a", false),
            (r"\text{passive needs no movement}", false),
          ],
        );
      case BriefFigure.pressureShape:
        return const _RuleList(
          rules: [
            (r"\text{soil: a triangle, at } H/3", true),
            (r"\text{surcharge: a rectangle, at } H/2", true),
            (r"\text{a surcharge is triangular too}", false),
            (r"\text{both act at the same height}", false),
          ],
        );
      case BriefFigure.wallForce:
        return const _RuleList(
          rules: [
            (r"P_a = \tfrac{1}{2}K_a\gamma H^2", true),
            (r"2H \Rightarrow 4P, \; 8M", true),
            (r"P_a = K_a \gamma H^2", false),
            (r"2H \Rightarrow 2P", false),
          ],
        );
      case BriefFigure.cogo:
        return const _RuleList(
          rules: [
            (r"\text{one point and a course} \Rightarrow \text{forward}", true),
            (r"\text{two points} \Rightarrow \text{inverse}", true),
            (r"\text{forward needs two known points}", false),
            (r"\text{an inverse is a field measurement}", false),
          ],
        );
      case BriefFigure.pair:
        return const _RuleList(
          rules: [
            (r"(E, N): \text{ across, then up}", true),
            (r"\text{a swapped pair still computes}", true),
            (r"(N, E) \text{ is the surveying order}", false),
            (r"\text{a swapped pair will not close}", false),
          ],
        );
      case BriefFigure.arctan:
        return const _RuleList(
          rules: [
            (r"\Delta N < 0 \Rightarrow +180°", true),
            (r"\Delta N > 0, \Delta E < 0 \Rightarrow +360°", true),
            (r"\text{a negative answer is an azimuth}", false),
            (r"\text{the arctangent knows the quadrant}", false),
          ],
        );
      case BriefFigure.endArea:
        return const _RuleList(
          rules: [
            (r"A_m = \tfrac{A_1+A_2}{2} \Rightarrow \text{they agree}", true),
            (r"\text{a taper} \Rightarrow \text{end areas give more}", true),
            (r"\text{the prismoid always gives more}", false),
            (r"\text{end areas need a middle section}", false),
          ],
        );
      case BriefFigure.stations:
        return const _RuleList(
          rules: [
            (r"V = \Sigma \tfrac{L_i}{2}(A_i + A_{i+1})", true),
            (r"1{+}00 = 100 \text{ ft}", true),
            (r"\text{one sum end to end is the same}", false),
            (r"\text{skipping always books too little}", false),
          ],
        );
      case BriefFigure.solidShare:
        return const _RuleList(
          rules: [
            (r"\text{to an edge} \Rightarrow \tfrac{1}{2}", true),
            (r"\text{to a point} \Rightarrow \tfrac{1}{3}", true),
            (r"\text{to a point} \Rightarrow \tfrac{1}{2}", false),
            (r"\text{a cone differs from a pyramid}", false),
          ],
        );
      case BriefFigure.method:
        return const _RuleList(
          rules: [
            (r"\text{straight sides, corners known} \Rightarrow \text{exact}",
                true),
            (r"\text{odd offsets} \Rightarrow \text{Simpson fits}", true),
            (r"\text{even offsets} \Rightarrow \text{Simpson fits}", false),
            (r"\text{a curved boundary} \Rightarrow \text{coordinates}", false),
          ],
        );
      case BriefFigure.weights:
        return const _RuleList(
          rules: [
            (r"\text{trapezoidal: the two ends halved}", true),
            (r"\text{Simpson: } 1, 4, 2, 4, 1", true),
            (r"\text{trapezoidal: every offset halved}", false),
            (r"\text{Simpson: the ends halved}", false),
          ],
        );
      case BriefFigure.shoelace:
        return const _RuleList(
          rules: [
            (r"\text{backwards is fine}", true),
            (r"\text{the last corner pairs back to the first}", true),
            (r"\text{a crossed listing gives the area}", false),
            (r"\text{a corner left out will not close}", false),
          ],
        );
      case BriefFigure.latDep:
        return const _RuleList(
          rules: [
            (r"\text{Lat} = L\cos\theta", true),
            (r"\text{south-west} \Rightarrow \text{both minus}", true),
            (r"\text{Lat} = L\sin\theta", false),
            (r"\text{every latitude is positive}", false),
          ],
        );
      case BriefFigure.compass:
        return const _RuleList(
          rules: [
            (r"\text{longest course, biggest share}", true),
            (r"\text{the correction opposes the drift}", true),
            (r"\text{an equal share for each course}", false),
            (r"\text{all of it on the course that felt wrong}", false),
          ],
        );
      case BriefFigure.precision:
        return const _RuleList(
          rules: [
            (r"E = \sqrt{E_L^2 + E_D^2}", true),
            (r"2E \text{ over } 2\Sigma L \Rightarrow \text{no change}", true),
            (r"E = E_L + E_D", false),
            (r"\text{the smaller gap is the better traverse}", false),
          ],
        );
      case BriefFigure.sightLine:
        return const _RuleList(
          rules: [
            (r"\text{the bigger reading is the lower point}", true),
            (r"HI = \text{Elev} + BS", true),
            (r"\text{the bigger reading is the higher point}", false),
            (r"\text{the instrument must be above both}", false),
          ],
        );
      case BriefFigure.runRoles:
        return const _RuleList(
          rules: [
            (r"\text{a turning point is read twice}", true),
            (r"\text{one backsight point, at the start}", true),
            (r"\text{one } HI \text{ serves the whole run}", false),
            (r"\text{a turning point is a foresight only}", false),
          ],
        );
      case BriefFigure.closure:
        return const _RuleList(
          rules: [
            (r"4M \Rightarrow 2 \times \text{ allowance}", true),
            (r"\text{tighter work} \Rightarrow \text{smaller } C", true),
            (r"4M \Rightarrow 4 \times \text{ allowance}", false),
            (r"\text{longer always means more room}", false),
          ],
        );
      case BriefFigure.bearing:
        return const _RuleList(
          rules: [
            (r"\text{a bearing is never over } 90°", true),
            (r"\text{the two letters pick the quadrant}", true),
            (r"\text{the angle alone fixes the line}", false),
            (r"\text{bearings run clockwise from north}", false),
          ],
        );
      case BriefFigure.azimuth:
        return const _RuleList(
          rules: [
            (r"\text{S } 45° \text{ W} \Rightarrow Az = 225°", true),
            (r"\text{N } 68° \text{ W} \Rightarrow Az = 292°", true),
            (r"\text{S } 45° \text{ W} \Rightarrow Az = 315°", false),
            (r"\text{every quadrant subtracts}", false),
          ],
        );
      case BriefFigure.shot:
        return const _RuleList(
          rules: [
            (r"HD = SD\cos\alpha", true),
            (r"SD \text{ is the longest of the three}", true),
            (r"HD = SD/\cos\alpha", false),
            (r"\text{the plan takes the slope length}", false),
          ],
        );
      case BriefFigure.similitude:
        return const _RuleList(
          rules: [
            (r"\text{free surface} \Rightarrow \text{Froude}", true),
            (r"\text{no surface} \Rightarrow \text{Reynolds}", true),
            (r"\text{match both at one scale}", false),
            (r"\text{a wind tunnel needs Froude}", false),
          ],
        );
      case BriefFigure.scaling:
        return const _RuleList(
          rules: [
            (r"\text{Froude}, \tfrac{1}{25} \Rightarrow \tfrac{1}{5}v", true),
            (r"\text{Reynolds}, \tfrac{1}{10} \Rightarrow 10v", true),
            (r"\text{Reynolds always means faster}", false),
            (r"\text{Froude}, \tfrac{1}{25} \Rightarrow \tfrac{1}{25}v", false),
          ],
        );
      case BriefFigure.metering:
        return const _RuleList(
          rules: [
            (r"\text{the area is the throat or the hole}", true),
            (r"\text{the tappings say where the meter is}", true),
            (r"\text{the area is the narrowest pipe drawn}", false),
            (r"\text{meter on the squeezed jet, then apply } C", false),
          ],
        );
      case BriefFigure.coefficient:
        return const _RuleList(
          rules: [
            (r"\text{no } C \Rightarrow \text{the answer is too big}", true),
            (r"\text{level meter} \Rightarrow z_1 - z_2 \text{ changes nothing}",
                true),
            (r"C > 1 \text{ for a good venturi}", false),
            (r"\text{kPa left as kPa} \Rightarrow \text{too big}", false),
          ],
        );
      case BriefFigure.deflection:
        return const _RuleList(
          rules: [
            (r"\text{flat plate} \Rightarrow F = \rho A v^2", true),
            (r"\text{turned right back} \Rightarrow 2\rho A v^2", true),
            (r"\text{straight through} \Rightarrow \text{a push}", false),
            (r"2v \Rightarrow 2F", false),
          ],
        );
      case BriefFigure.thrust:
        return const _RuleList(
          rules: [
            (r"\text{a bend needs holding}", true),
            (r"\text{a dead end needs holding}", true),
            (r"\text{high pressure alone needs holding}", false),
            (r"\text{a longer straight needs holding}", false),
          ],
        );
      case BriefFigure.block:
        return const _RuleList(
          rules: [
            (r"F \propto \hat{u}_{in} - \hat{u}_{out}", true),
            (r"F_R = F_x\sqrt{2} \text{ at a square bend}", true),
            (r"\text{the push runs along the outlet leg}", false),
            (r"F_R = 2F_x \text{ at a square bend}", false),
          ],
        );
      case BriefFigure.minor:
        return const _RuleList(
          rules: [
            (r"h_{total} = h_f + \Sigma C \frac{v^2}{2g}", true),
            (r"\text{one } v^2/2g \text{ for every fitting}", true),
            (r"\text{minor losses are always small}", false),
            (r"\text{each fitting gets its own } v", false),
          ],
        );
      case BriefFigure.damping:
        return const _RuleList(
          rules: [
            (r"\zeta = 1 \text{ is back fastest, no swing}", true),
            (r"\zeta = 0 \text{ swings and never shrinks}", true),
            (r"\zeta > 1 \text{ is quicker still}", false),
            (r"\text{real structures are near } \zeta = 1", false),
          ],
        );
      case BriefFigure.impact:
        return const _RuleList(
          rules: [
            (r"\text{stuck together} \Rightarrow e = 0", true),
            (r"e \text{ between} \Rightarrow \text{two equations}", true),
            (r"\text{stuck together} \Rightarrow e = 1", false),
            (r"\text{momentum alone is always enough}", false),
          ],
        );
      case BriefFigure.survives:
        return const _RuleList(
          rules: [
            (r"\text{momentum survives every collision}", true),
            (r"\text{energy survives only } e = 1", true),
            (r"\text{energy survives a plastic crash}", false),
            (r"\text{one body keeps its own momentum}", false),
          ],
        );
      case BriefFigure.impulse:
        return const _RuleList(
          rules: [
            (r"F\,\Delta t = m\,\Delta v \text{, the area}", true),
            (r"\text{twice as long} \Rightarrow \text{half as hard}", true),
            (r"\text{a longer stop is a harder one}", false),
            (r"F\,\Delta t \text{ is a force}", false),
          ],
        );
      case BriefFigure.ledger:
        return const _RuleList(
          rules: [
            (r"\text{a spring stores and gives back}", true),
            (r"\text{friction takes and never returns}", true),
            (r"\text{energy is always conserved}", false),
            (r"\text{a spring is a loss}", false),
          ],
        );
      case BriefFigure.cancel:
        return const _RuleList(
          rules: [
            (r"v = \sqrt{2gh} \text{, whatever the mass}", true),
            (r"\text{a light block leaves a spring faster}", true),
            (r"\text{mass always cancels}", false),
            (r"\text{the heavy one always wins}", false),
          ],
        );
      case BriefFigure.power:
        return const _RuleList(
          rules: [
            (r"P_{in} = \frac{P_{out}}{\eta} > P_{out}", true),
            (r"P = Fv \text{ at a steady speed}", true),
            (r"P_{in} = P_{out}\,\eta", false),
            (r"\text{the useful power is the bigger one}", false),
          ],
        );
      case BriefFigure.weight:
        return const _RuleList(
          rules: [
            (r"\text{newtons and pounds are FORCE}", true),
            (r"m = \frac{W}{g} \text{, when given a weight}", true),
            (r"\text{kilograms can go straight in as a force}", false),
            (r"\text{convert every number you are given}", false),
          ],
        );
      case BriefFigure.slope:
        return const _RuleList(
          rules: [
            (r"\text{down the slope: } W\sin\theta", true),
            (r"a = g\sin\theta \text{, whatever the mass}", true),
            (r"\text{the driving piece is } W\cos\theta", false),
            (r"\text{gravity pulls along the slope}", false),
          ],
        );
      case BriefFigure.twoEquations:
        return const _RuleList(
          rules: [
            (r"\text{an axle} \Rightarrow \text{moments only}", true),
            (r"\text{through the center} \Rightarrow \text{no spin}", true),
            (r"\text{a force can go straight into } \sum M", false),
            (r"\text{one equation is always enough}", false),
          ],
        );
      case BriefFigure.spin:
        return const _RuleList(
          rules: [
            (r"\text{one } \omega \text{ for the whole body}", true),
            (r"v = r\omega \text{, so the rim is fastest}", true),
            (r"\text{every point has the same speed}", false),
            (r"\text{rpm can go straight into } v = r\omega", false),
          ],
        );
      case BriefFigure.spinInertia:
        return const _RuleList(
          rules: [
            (r"\text{mass at the rim counts most}", true),
            (r"\text{rod about its end} = 4\times \text{about its middle}", true),
            (r"I \text{ belongs to the body alone}", false),
            (r"\text{transfer between any two axes}", false),
          ],
        );
      case BriefFigure.missing:
        return const _RuleList(
          rules: [
            (r"\text{no time given} \Rightarrow v^2 = v_0^2 + 2as", true),
            (r"\text{slowing down} \Rightarrow a < 0", true),
            (r"\text{they work for any acceleration}", false),
            (r"\text{you always need all five}", false),
          ],
        );
      case BriefFigure.flight:
        return const _RuleList(
          rules: [
            (r"v_x \text{ never changes}", true),
            (r"\text{at the top } v_y = 0", true),
            (r"\text{the ball stops at the top}", false),
            (r"\text{use } v_0 \text{, not } v_0\sin\theta", false),
          ],
        );
      case BriefFigure.bend:
        return const _RuleList(
          rules: [
            (r"\text{steady speed still accelerates}", true),
            (r"a_n = \tfrac{v^2}{\rho} \text{, toward the middle}", true),
            (r"a = a_t + a_n", false),
            (r"\text{constant speed} \Rightarrow \text{no acceleration}", false),
          ],
        );
      case BriefFigure.ends:
        return const _RuleList(
          rules: [
            (r"\text{a free end} \Rightarrow K = 2", true),
            (r"\text{both fixed} \Rightarrow K = 0.5 \Rightarrow 4\times \text{the load}", true),
            (r"\text{the length in the formula is the real length}", false),
            (r"\text{fixing an end makes it weaker}", false),
          ],
        );
      case BriefFigure.weakAxis:
        return const _RuleList(
          rules: [
            (r"\text{use } I_{min} \text{, the smaller one}", true),
            (r"\text{square or round} \Rightarrow \text{no weak axis}", true),
            (r"\text{use } I \text{ about the stronger axis}", false),
            (r"\text{it waits for the axis you loaded it about}", false),
          ],
        );
      case BriefFigure.slender:
        return const _RuleList(
          rules: [
            (r"\text{Euler holds while } \sigma_{cr} < \sigma_y", true),
            (r"\text{stocky columns yield instead}", true),
            (r"\text{a stronger steel helps a slender column}", false),
            (r"\sigma_y \text{ appears in Euler's formula}", false),
          ],
        );
      case BriefFigure.circle:
        return const _RuleList(
          rules: [
            (r"\text{the ends are } \sigma_1 \text{ and } \sigma_2", true),
            (r"\text{the radius is the worst in-plane shear}", true),
            (r"\sigma_1 \text{ is the biggest in SIZE}", false),
            (r"\text{the center moves as you rotate}", false),
          ],
        );
      case BriefFigure.build:
        return const _RuleList(
          rules: [
            (r"\text{pure shear sits on the origin}", true),
            (r"\text{equal both ways is a point}", true),
            (r"\text{the circle is centered on } \sigma_x", false),
            (r"\sigma_1 = \sigma_x + \tau_{xy}", false),
          ],
        );
      case BriefFigure.worst:
        return const _RuleList(
          rules: [
            (r"\text{circle crosses zero} \Rightarrow \tau_{abs} = R", true),
            (r"\text{circle clear of zero} \Rightarrow \tau_{abs} > R", true),
            (r"\tau_{abs} = R \text{ always}", false),
            (r"\sigma_3 \text{ can be ignored}", false),
          ],
        );
      case BriefFigure.transform:
        return const _RuleList(
          rules: [
            (r"\text{widen the STIFFER material by } n", true),
            (r"\text{every depth stays exactly where it was}", true),
            (r"\text{widen the softer one instead}", false),
            (r"\text{divide the stiff width by } n", false),
          ],
        );
      case BriefFigure.join:
        return const _RuleList(
          rules: [
            (r"\varepsilon \text{ is equal across the join}", true),
            (r"\sigma_{stiff} = n\,\sigma_{soft}", true),
            (r"\sigma \text{ is equal across the join}", false),
            (r"\text{the softer material takes more}", false),
          ],
        );
      case BriefFigure.plastic:
        return const _RuleList(
          rules: [
            (r"M_p = F_y Z \text{, the square block}", true),
            (r"Z > S \text{, so } M_p > M_y", true),
            (r"M_p = F_y S", false),
            (r"\text{the section is finished at first yield}", false),
          ],
        );
      case BriefFigure.tableLine:
        return const _RuleList(
          rules: [
            (r"\text{point load} \;\Rightarrow\; L^3", true),
            (r"\text{spread load} \;\Rightarrow\; L^4", true),
            (r"\text{the supports hardly matter}", false),
            (r"\text{a cantilever uses } \tfrac{PL^3}{48EI}", false),
          ],
        );
      case BriefFigure.bounce:
        return const _RuleList(
          rules: [
            (r"\text{depth is cubed inside } I", true),
            (r"\text{span is cubed or to the fourth}", true),
            (r"\text{a stronger steel sags less}", false),
            (r"\text{width helps as much as depth}", false),
          ],
        );
      case BriefFigure.addUp:
        return const _RuleList(
          rules: [
            (r"\delta_{total} = \delta_1 + \delta_2", true),
            (r"\text{the same line may be used twice}", true),
            (r"\text{split the supports as well as the load}", false),
            (r"\text{every beam needs splitting}", false),
          ],
        );
      case BriefFigure.fiber:
        return const _RuleList(
          rules: [
            (r"\text{bending: nothing at the axis, worst at the faces}", true),
            (r"\text{shear: nothing at the faces, worst at the axis}", true),
            (r"\text{the neutral axis is halfway up}", false),
            (r"\text{both stresses peak in the same fiber}", false),
          ],
        );
      case BriefFigure.cut:
        return const _RuleList(
          rules: [
            (r"b = \text{the width AT the cut}", true),
            (r"Q = \text{the material BEYOND the cut}", true),
            (r"b = \text{the widest part of the section}", false),
            (r"Q = \text{the first moment of the whole section}", false),
          ],
        );
      case BriefFigure.governs:
        return const _RuleList(
          rules: [
            (r"\text{twice the span} \;\Rightarrow\; \text{twice } \sigma", true),
            (r"\text{twice the depth} \;\Rightarrow\; \sigma/4,\; \tau/2", true),
            (r"\text{twice the span} \;\Rightarrow\; \text{twice } \tau", false),
            (r"\text{a stronger material lowers the stress}", false),
          ],
        );
      case BriefFigure.slopeRules:
        return const _RuleList(
          rules: [
            (r"\text{no spread load} \;\Rightarrow\; V \text{ flat}, M \text{ straight}", true),
            (r"\text{uniform load} \;\Rightarrow\; V \text{ slopes}, M \text{ curves}", true),
            (r"\text{a uniform load gives a straight } M", false),
            (r"\text{a point load slopes } V", false),
          ],
        );
      case BriefFigure.peak:
        return const _RuleList(
          rules: [
            (r"M \text{ peaks where } V = 0", true),
            (r"\text{one load} \;\Rightarrow\; \text{peak under it}", true),
            (r"\text{the peak is at midspan}", false),
            (r"\text{the worst moment is always sagging}", false),
          ],
        );
      case BriefFigure.jump:
        return const _RuleList(
          rules: [
            (r"\text{a force steps } V \text{ by its own size}", true),
            (r"\text{a couple steps } M \text{, not } V", true),
            (r"\text{a point load steps } M", false),
            (r"\text{a spread load steps } V \text{ where it starts}", false),
          ],
        );
      case BriefFigure.curve:
        return const _RuleList(
          rules: [
            (r"\text{the top of the curve is } \sigma_u", true),
            (r"\text{fracture sits BELOW the top}", true),
            (r"\text{the curve ends at its highest stress}", false),
            (r"E \text{ can be read anywhere on the curve}", false),
          ],
        );
      case BriefFigure.stiffStrong:
        return const _RuleList(
          rules: [
            (r"\text{steeper} \;\Rightarrow\; \text{stiffer}", true),
            (r"\text{longer} \;\Rightarrow\; \text{more ductile}", true),
            (r"\text{stronger} \;\Rightarrow\; \text{stiffer}", false),
            (r"\text{stronger} \;\Rightarrow\; \text{more ductile}", false),
          ],
        );
      case BriefFigure.linked:
        return const _RuleList(
          rules: [
            (r"E \text{ and } \nu \;\Rightarrow\; G", true),
            (r"\sigma \text{ and } \varepsilon \;\Rightarrow\; E", true),
            (r"G = \tfrac{E}{2} \text{ or } \tfrac{E}{1+\nu}", false),
            (r"\text{every given number is needed}", false),
          ],
        );
      case BriefFigure.polarJ:
        return const _RuleList(
          rules: [
            (r"J = \tfrac{\pi d^4}{32} \text{, and } c = \tfrac{d}{2}", true),
            (r"\text{a bore subtracts } d_i^4 \text{, not } d_i^2", true),
            (r"\text{use } I = \tfrac{\pi d^4}{64} \text{ for torsion}", false),
            (r"\text{on a hollow shaft } c = \tfrac{d_i}{2}", false),
          ],
        );
      case BriefFigure.twist:
        return const _RuleList(
          rules: [
            (r"\text{longer or softer} \;\Rightarrow\; \text{more twist}", true),
            (r"\text{longer or softer} \;\Rightarrow\; \text{same stress}", true),
            (r"\text{torsion uses } E", false),
            (r"\text{whatever moves } \phi \text{ moves } \tau", false),
          ],
        );
      case BriefFigure.thinWall:
        return const _RuleList(
          rules: [
            (r"A_m = \text{enclosed by the middle of the wall}", true),
            (r"\text{any thin shape, not just round}", true),
            (r"A_m = \text{the area of the metal}", false),
            (r"A_m = \text{the area of the bore}", false),
          ],
        );
      case BriefFigure.polar:
        return const _RuleList(
          rules: [
            (r"\text{bending} \;\Rightarrow\; I \text{, square to the load}", true),
            (r"\text{twisting} \;\Rightarrow\; J = I_x + I_y", true),
            (r"\text{bending is about the stronger axis}", false),
            (r"\text{torsion uses } I", false),
          ],
        );
      case BriefFigure.farFromAxis:
        return const _RuleList(
          rules: [
            (r"\text{far from the axis} \;\Rightarrow\; \text{stiffer}", true),
            (r"\text{depth is cubed, width is not}", true),
            (r"\text{twice the area} \;\Rightarrow\; \text{twice the stiffness}", false),
            (r"\text{metal on the axis works as hard as any}", false),
          ],
        );
      case BriefFigure.transfer:
        return const _RuleList(
          rules: [
            (r"\text{leaving the centroidal axis} \;\Rightarrow\; +Ad^2", true),
            (r"\text{arriving at it} \;\Rightarrow\; -Ad^2", true),
            (r"\text{between two non-centroidal axes in one step}", false),
            (r"\text{the } Ad^2 \text{ term is usually the small one}", false),
          ],
        );
      case BriefFigure.areaWeighted:
        return const _RuleList(
          rules: [
            (r"\text{the centroid follows the area}", true),
            (r"\text{a hole counts as a negative area}", true),
            (r"\bar{y} = \tfrac{1}{2}\,\text{height}", false),
            (r"\bar{y} = \text{the average of the piece centroids}", false),
          ],
        );
      case BriefFigure.table:
        return const _RuleList(
          rules: [
            (r"\text{triangle: } \tfrac{h}{3} \text{ from the wide end}", true),
            (r"\text{half disc: } \tfrac{4r}{3\pi} \text{ from the flat side}", true),
            (r"\text{triangle: } \tfrac{h}{2}", false),
            (r"\text{the middle of the box it fits in}", false),
          ],
        );
      case BriefFigure.reference:
        return const _RuleList(
          rules: [
            (r"\text{every piece measured from ONE axis}", true),
            (r"\text{to that piece's own centroid}", true),
            (r"\text{to where the piece begins}", false),
            (r"\text{a new axis for an awkward piece}", false),
          ],
        );
      case BriefFigure.twoForce:
        return const _RuleList(
          rules: [
            (r"\text{2 points} \;\Rightarrow\; \text{along the line joining them}", true),
            (r"\text{a bend in it does not move that line}", true),
            (r"\text{a straight member is always two-force}", false),
            (r"\text{a load at a pin makes its members bend}", false),
          ],
        );
      case BriefFigure.lever:
        return const _RuleList(
          rules: [
            (r"a_{in} > a_{out} \;\Rightarrow\; \text{more force out}", true),
            (r"\text{effort and load on one side still works}", true),
            (r"\text{a lever always multiplies force}", false),
            (r"\text{a heavier bar gives more advantage}", false),
          ],
        );
      case BriefFigure.whatItIs:
        return const _RuleList(
          rules: [
            (r"\text{all members two-force, and still} \;\Rightarrow\; \text{truss}", true),
            (r"\text{still, one member bends} \;\Rightarrow\; \text{frame}", true),
            (r"\text{a frame may have a part that moves}", false),
            (r"\text{a machine is solved a different way}", false),
          ],
        );
      case BriefFigure.laws:
        return const _RuleList(
          rules: [
            (r"\text{exclusive} \;\Rightarrow\; P(A \cup B) = P(A) + P(B)", true),
            (r"\text{independent} \;\Rightarrow\; P(A \cap B) = P(A)P(B)", true),
            (r"\text{exclusive events are independent}", false),
            (r"\text{two events always overlap by } P(A)P(B)", false),
          ],
        );
      case BriefFigure.period:
        return const _RuleList(
          rules: [
            (r"\text{end of year } n \;\Rightarrow\; \text{period } n", true),
            (r"\text{beginning of year } n \;\Rightarrow\; \text{period } n-1", true),
            (r"\text{a series starts at period 0}", false),
            (r"\text{a gradient has a step in period 1}", false),
          ],
        );
      case BriefFigure.screw:
        return const _RuleList(
          rules: [
            (r"\text{raising} \;\Rightarrow\; M = Pr\tan(\alpha + \phi)", true),
            (r"\phi > \alpha \;\Rightarrow\; \text{self-locking}", true),
            (r"\text{a fine thread is always self-locking}", false),
            (r"\text{greasing it cannot make it unsafe}", false),
          ],
        );
      case BriefFigure.ceiling:
        return const _RuleList(
          rules: [
            (r"F \le \mu_s N \;\text{ always}", true),
            (r"F = \mu_s N \;\text{ only when motion is impending}", true),
            (r"F = \mu_s N \;\text{ whenever it is sitting still}", false),
            (r"\text{a bigger } N \Rightarrow \text{ a bigger friction force}", false),
          ],
        );
      case BriefFigure.belt:
        return const _RuleList(
          rules: [
            (r"F_1 \text{ is the end the belt is dragged toward}", true),
            (r"\theta \text{ in radians}", true),
            (r"F_1 = F_2 + \mu F_2", false),
            (r"\theta \text{ can never pass } 2\pi", false),
          ],
        );
      case BriefFigure.normalForce:
        return const _RuleList(
          rules: [
            (r"\text{a push aimed into the surface raises } N", true),
            (r"N = W \text{ on level ground, and nothing else on it}", true),
            (r"N \text{ is the weight, wherever it is}", false),
            (r"\text{a wider block grips better}", false),
          ],
        );
      case BriefFigure.zeroForce:
        return const _RuleList(
          rules: [
            (r"\text{2 members, unloaded joint} \;\Rightarrow\; \text{both zero}", true),
            (r"\text{3 members, 2 in line, unloaded} \;\Rightarrow\; \text{odd one zero}", true),
            (r"\text{2 members, load on the joint}", false),
            (r"\text{a zero-force member can be removed}", false),
          ],
        );
      case BriefFigure.senseOfForce:
        return const _RuleList(
          rules: [
            (r"\text{assume tension, always}", true),
            (r"T > 0 \;\Rightarrow\; \text{tension, the member is stretched}", true),
            (r"T < 0 \;\Rightarrow\; \text{compression, the member is squashed}", true),
            (r"\text{a magnitude on its own is the answer}", false),
          ],
        );
      case BriefFigure.section:
        return const _RuleList(
          rules: [
            (r"\text{the cut crosses the member you want}", true),
            (r"\text{no more than 3 members cut}", true),
            (r"\text{it gives you every member it severs}", true),
            (r"\text{the cut must be vertical}", false),
          ],
        );
      case BriefFigure.lawChoice:
        return Row(
          children: [
            Expanded(
              child: _Panel(
                height: 160,
                caption: 'A side with its own angle: Sines',
                child: CustomPaint(
                  painter: ObliqueTrianglePainter(
                    knownSides: {'a'},
                    knownAngles: {'A', 'B'},
                    wanted: 'b',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Panel(
                height: 160,
                caption: 'Two sides and the angle between: Cosines',
                child: CustomPaint(
                  painter: ObliqueTrianglePainter(
                    knownSides: {'a', 'b'},
                    knownAngles: {'C'},
                    wanted: 'c',
                  ),
                ),
              ),
            ),
          ],
        );
      case BriefFigure.lawForms:
        return const _RuleList(
          rules: [
            (r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C}', true),
            (r'c^2 = a^2 + b^2 - 2ab\cos C', true),
            (r'c^2 = a^2 + b^2 + 2ab\cos C', false),
          ],
        );
      case BriefFigure.cosineSign:
        return const _RuleList(
          rules: [
            (
              r'c^2 < a^2 + b^2 \;\Rightarrow\; \cos C > 0 \;\Rightarrow\; \text{acute}',
              true,
            ),
            (
              r'c^2 = a^2 + b^2 \;\Rightarrow\; \cos C = 0 \;\Rightarrow\; 90^\circ',
              true,
            ),
            (
              r'c^2 > a^2 + b^2 \;\Rightarrow\; \cos C < 0 \;\Rightarrow\; \text{obtuse}',
              true,
            ),
          ],
        );
      case BriefFigure.unitCircle:
        return const _Panel(
          height: 230,
          caption: 'Cosine is the across, sine is the up',
          child: CustomPaint(
            painter: UnitCirclePainter(
              choices: [0, 30, 45, 60, 90, 120, 135, 150, 180, 225, 270, 315],
              showRayTo: 60,
            ),
          ),
        );
      case BriefFigure.quadrants:
        return const _Panel(
          height: 230,
          caption: 'Across positive to the right, up positive above',
          child: CustomPaint(painter: UnitCirclePainter(quadrantLabels: true)),
        );
      case BriefFigure.identities:
        return const _RuleList(
          rules: [
            (r'\sin^2\theta + \cos^2\theta = 1', true),
            (r'\sin 2\theta = 2\sin\theta\cos\theta', true),
            (r'\sin 2\theta = 2\sin\theta', false),
            (r'\cos 2\theta = \cos^2\theta - \sin^2\theta', true),
          ],
        );
      case BriefFigure.circleForm:
        return const _RuleList(
          rules: [
            (r'(y+3)^2 \;\Rightarrow\; k = -3', true),
            (r'(y+3)^2 \;\Rightarrow\; k = +3', false),
            (r'= 64 \;\Rightarrow\; r = 8', true),
            (r'= 64 \;\Rightarrow\; r = 64', false),
          ],
        );
      case BriefFigure.conicForms:
        return const _RuleList(
          rules: [
            (r'\text{two squares, same sign: circle}', null),
            (r'\text{one square: parabola}', null),
            (r'\text{two squares, different denominators: ellipse}', null),
          ],
        );
      case BriefFigure.completingSquare:
        return const _RuleList(
          rules: [
            (r'x^2 - 10x + 25 = -18 + 25', true),
            (r'x^2 - 10x + 25 = -18', false),
          ],
        );
      case BriefFigure.whichRule:
        return const _RuleList(
          rules: [
            (r'\text{multiplied} \Rightarrow \text{product}', null),
            (r'\text{divided} \Rightarrow \text{quotient}', null),
            (r'\text{argument is not plain } x \Rightarrow \text{chain}', null),
          ],
        );
      case BriefFigure.chainRule:
        return const _RuleList(
          rules: [
            (r'\frac{d}{dx}(3x+5)^4 = 12(3x+5)^3', true),
            (r'\frac{d}{dx}(3x+5)^4 = 4(3x+5)^3', false),
            (r'\frac{d}{dx}e^{3x} = 3e^{3x}', true),
            (r'\frac{d}{dx}\sin(3x^2) = 6x\cos(3x^2)', true),
          ],
        );
      case BriefFigure.quotientOrder:
        return const _RuleList(
          rules: [
            (r'\frac{v\,du - u\,dv}{v^2}', true),
            (r'\frac{u\,dv - v\,du}{v^2}', false),
            (r'\frac{v\,du - u\,dv}{v}', false),
          ],
        );
      case BriefFigure.maxMin:
        return const _RuleList(
          rules: [
            (r"f'(a) = 0 \;\text{and}\; f''(a) < 0 \Rightarrow \text{maximum}", true),
            (r"f'(a) = 0 \;\text{and}\; f''(a) > 0 \Rightarrow \text{minimum}", true),
            (r"f'(a) = 0 \Rightarrow \text{maximum}", false),
          ],
        );
      case BriefFigure.bendFlip:
        return const _RuleList(
          rules: [
            (r"f''(x) > 0 \Rightarrow \text{concave up, a smile}", null),
            (r"f''(x) < 0 \Rightarrow \text{concave down, a frown}", null),
            (r"f''(a) = 0 \text{ and the sign flips} \Rightarrow \text{inflection}", true),
            (r"f'(a) = 0 \Rightarrow \text{inflection}", false),
          ],
        );
      case BriefFigure.whereOrHowMuch:
        return const _RuleList(
          rules: [
            (r"f'(x) = -4x + 16 = 0 \;\Rightarrow\; x = 4", null),
            (r"\text{where the maximum is} \;\Rightarrow\; x = 4", null),
            (r"\text{how big it is} \;\Rightarrow\; f(4) = 27", null),
          ],
        );
      case BriefFigure.substitution:
        return const _RuleList(
          rules: [
            (r"\int \sin^3 x\,\cos x\,dx \;\Rightarrow\; u = \sin x", true),
            (r"\int (x^2+1)^5\,2x\,dx \;\Rightarrow\; u = x^2+1", true),
            (r"\int x\,e^{2x}\,dx \;\Rightarrow\; u = e^{2x}", false),
          ],
        );
      case BriefFigure.liate:
        return const _RuleList(
          rules: [
            (r"\text{L} \;\; \text{logs, differentiate them}", null),
            (r"\text{I} \;\; \text{inverse trig}", null),
            (r"\text{A} \;\; \text{algebraic, the power drops}", null),
            (r"\text{T} \;\; \text{trig}", null),
            (r"\text{E} \;\; \text{exponential, integrate it}", null),
          ],
        );
      case BriefFigure.finishing:
        return const _RuleList(
          rules: [
            (r"\int 3x^2\,dx = x^3 + C", true),
            (r"\int 3x^2\,dx = x^3", false),
            (r"\int_1^2 3x^2\,dx = 8 - 1 = 7", true),
            (r"\int_1^2 3x^2\,dx = 8 + C", false),
          ],
        );
      case BriefFigure.formCheck:
        return const _RuleList(
          rules: [
            (r"\frac{0}{0} \;\Rightarrow\; \text{the rule applies}", null),
            (r"\frac{\infty}{\infty} \;\Rightarrow\; \text{the rule applies}", null),
            (r"\frac{1}{1} \;\Rightarrow\; \text{you already have it}", null),
            (r"\frac{1}{0} \;\Rightarrow\; \text{a blow up, not a form}", null),
          ],
        );
      case BriefFigure.separately:
        return const _RuleList(
          rules: [
            (r"\lim\frac{\sin x}{x} \;\Rightarrow\; \lim\frac{\cos x}{1}", true),
            (
              r"\lim\frac{\sin x}{x} \;\Rightarrow\; \lim\frac{x\cos x - \sin x}{x^2}",
              false,
            ),
            (r"\lim\frac{\sin x}{x} \;\Rightarrow\; \lim\frac{\cos x}{x}", false),
          ],
        );
      case BriefFigure.bothSides:
        return const _RuleList(
          rules: [
            (r"\text{both sides run up} \;\Rightarrow\; +\infty", null),
            (r"\text{both sides run down} \;\Rightarrow\; -\infty", null),
            (r"\text{sides disagree} \;\Rightarrow\; \text{does not exist}", null),
          ],
        );
      case BriefFigure.vectorAdd:
        return const _RuleList(
          rules: [
            (r"(3\hat{i}) + (0\hat{i} + 4\hat{j}) = 3\hat{i} + 4\hat{j}", true),
            (r"|3\hat{i}| + |4\hat{j}| = 7 \;\Rightarrow\; \text{the resultant}", false),
            (r"(4\hat{i} + 4\hat{j}) + (-4\hat{i} - 4\hat{j}) = 0", true),
          ],
        );
      case BriefFigure.unitVector:
        return const _RuleList(
          rules: [
            (r"\vec{d} = 3\hat{i} + 4\hat{j} \;\Rightarrow\; |\vec{d}| = 5", null),
            (r"\hat{u} = 0.6\hat{i} + 0.8\hat{j}", null),
            (r"25\,\hat{u} = 15\hat{i} + 20\hat{j}", null),
            (r"-2\,\hat{u} \;\Rightarrow\; \text{same line, other way}", null),
          ],
        );
      case BriefFigure.magnitude:
        return const _RuleList(
          rules: [
            (r"|30\hat{i} + 40\hat{j}| = 50", true),
            (r"|30\hat{i} + 40\hat{j}| = 70", false),
            (r"|3\hat{i} + 4\hat{j}| = |5\hat{i}|", true),
            (r"|-3\hat{i} + 4\hat{j}| = 5", true),
          ],
        );
      case BriefFigure.dotProduct:
        return const _RuleList(
          rules: [
            (r"(3)(-2) + (4)(5) = 14", true),
            (r"(3)(5) + (4)(-2) = 7", false),
            (r"(3)(-2) = -6 \;\Rightarrow\; \text{the whole answer}", false),
          ],
        );
      case BriefFigure.dotAngle:
        return const _RuleList(
          rules: [
            (r"\theta < 90^\circ \;\Rightarrow\; \vec{A} \cdot \vec{B} > 0", null),
            (r"\theta = 90^\circ \;\Rightarrow\; \vec{A} \cdot \vec{B} = 0", null),
            (r"\theta > 90^\circ \;\Rightarrow\; \vec{A} \cdot \vec{B} < 0", null),
            (r"\cos\theta = \tfrac{1}{\sqrt{2}} \;\Rightarrow\; \theta = 45^\circ", true),
          ],
        );
      case BriefFigure.projection:
        return const _RuleList(
          rules: [
            (r"\frac{\vec{F} \cdot \vec{d}}{|\vec{d}|} = \frac{1500}{3} = 500", true),
            (r"\vec{F} \cdot \vec{d} = 1500 \;\Rightarrow\; \text{the component}", false),
            (r"\frac{\vec{F} \cdot \vec{d}}{|\vec{F}|} \;\Rightarrow\; \text{the component}", false),
          ],
        );
      case BriefFigure.rightHand:
        return const _RuleList(
          rules: [
            (r"\hat{i} \times \hat{j} = \hat{k}", true),
            (r"\hat{j} \times \hat{i} = \hat{k}", false),
            (r"\vec{M}_O = \vec{r} \times \vec{F}", true),
            (r"\vec{M}_O = \vec{F} \times \vec{r}", false),
          ],
        );
      case BriefFigure.crossArea:
        return const _RuleList(
          rules: [
            (r"|\vec{u} \times \vec{v}| \;\Rightarrow\; \text{parallelogram}", null),
            (r"\tfrac{1}{2}|\vec{u} \times \vec{v}| \;\Rightarrow\; \text{triangle}", null),
            (r"|\vec{u}||\vec{v}| \;\Rightarrow\; \text{the box round it}", null),
          ],
        );
      case BriefFigure.cofactor:
        return const _RuleList(
          rules: [
            (r"+\big[A_yB_z - A_zB_y\big]\hat{i}", true),
            (r"-\big[A_xB_z - A_zB_x\big]\hat{j}", true),
            (r"+\big[A_xB_z - A_zB_x\big]\hat{j}", false),
            (r"+\big[A_xB_y - A_yB_x\big]\hat{k}", true),
          ],
        );
      case BriefFigure.references:
        return const _RuleList(
          rules: [
            (r"\text{C1: =A1*\$B\$1} \;\Rightarrow\; \text{C2: =A2*\$B\$1}", true),
            (r"\text{C1: =A1*\$B\$1} \;\Rightarrow\; \text{C2: =A1*\$B\$2}", false),
            (r"\text{C1: =A1*B1} \;\Rightarrow\; \text{C2: =A2*B2}", true),
          ],
        );
      case BriefFigure.precedence:
        return const _RuleList(
          rules: [
            (r"\text{brackets}", null),
            (r"\text{powers, } \wedge", null),
            (r"\text{times and divide, left to right}", null),
            (r"\text{plus and minus, left to right}", null),
          ],
        );
      case BriefFigure.functions:
        return const _RuleList(
          rules: [
            (r"\text{=SUM(B1:B3)} \;\Rightarrow\; \text{adds all three}", null),
            (r"\text{=COUNT(A1:A4)} \;\Rightarrow\; \text{numbers only}", null),
            (r"\text{=IF(test, yes, no)} \;\Rightarrow\; \text{one of the two}", null),
            (r"\text{=IF(...)} \;\Rightarrow\; 1 \text{ for true}", false),
          ],
        );
      case BriefFigure.tracing:
        return const _RuleList(
          rules: [
            (r"\text{FOR i = 1 TO 4} \;\Rightarrow\; \text{4 passes}", true),
            (r"\text{FOR i = 1 TO 4} \;\Rightarrow\; \text{3 passes}", false),
            (r"\text{total} = 0+1+2+3+4 = 10", true),
            (r"\text{total} = 4 \;\text{(the pass count)}", false),
          ],
        );
      case BriefFigure.selection:
        return const _RuleList(
          rules: [
            (r"x = 7 \;\Rightarrow\; y = 2", true),
            (r"x = 7 \;\Rightarrow\; y = 3 \;\text{(the closing ELSE)}", false),
            (r"x = 10 \;\Rightarrow\; x > 10 \text{ is false}", true),
          ],
        );
      case BriefFigure.iteration:
        return const _RuleList(
          rules: [
            (r"\text{stops with } x = 128", true),
            (r"\text{stops with } x = 64", false),
            (r"\text{stops with } x = 100", false),
          ],
        );
      case BriefFigure.newton:
        return const _RuleList(
          rules: [
            (r"x_1 = x_0 - \frac{f(x_0)}{f'(x_0)}", true),
            (r"x_1 = x_0 + \frac{f(x_0)}{f'(x_0)}", false),
            (r"x_1 = x_0 - f(x_0)", false),
          ],
        );
      case BriefFigure.bisection:
        return const _RuleList(
          rules: [
            (r"f(a)\cdot f(b) < 0 \;\Rightarrow\; \text{it can start}", true),
            (r"f(a) > 0 \text{ and } f(b) > 0 \;\Rightarrow\; \text{it can start}", false),
            (r"\text{two roots inside} \;\Rightarrow\; \text{it can start}", false),
          ],
        );
      case BriefFigure.methodChoice:
        return const _RuleList(
          rules: [
            (r"\text{close guess, has } f' \;\Rightarrow\; \text{Newton}", null),
            (r"\text{only a sign change} \;\Rightarrow\; \text{bisection}", null),
            (r"f' \text{ near zero} \;\Rightarrow\; \text{Newton may run away}", null),
            (r"\text{far guess} \;\Rightarrow\; \text{Newton may run away}", null),
          ],
        );
      case BriefFigure.center:
        return const _RuleList(
          rules: [
            (r"11,\ 12,\ 13,\ 14,\ 16 \;\Rightarrow\; \text{median } 13", true),
            (r"10,\ 11,\ 12,\ 13,\ 14,\ 15,\ 24 \;\Rightarrow\; \text{median } 13", true),
            (r"\text{the same set} \;\Rightarrow\; \text{mean } 14.1", true),
            (r"\text{one stray reading moves the median}", false),
          ],
        );
      case BriefFigure.spread:
        return const _RuleList(
          rules: [
            (r"\text{a sample} \;\Rightarrow\; \text{divide by } n-1", true),
            (r"\text{a sample} \;\Rightarrow\; \text{divide by } n", false),
            (r"s = \sqrt{s^2}", true),
            (r"s = s^2", false),
          ],
        );
      case BriefFigure.weighted:
        return const _RuleList(
          rules: [
            (r"\bar{x}_w = \frac{\sum w_i x_i}{\sum w_i}", null),
            (r"\text{equal weights} \;\Rightarrow\; \text{the plain mean}", null),
            (r"\text{roles swapped} \;\Rightarrow\; \text{a tidy wrong answer}", null),
          ],
        );
      case BriefFigure.logRules:
        return const _RuleList(
          rules: [
            (r'\log(xy) = \log x + \log y', true),
            (r'\log\!\left(\frac{x}{y}\right) = \log x - \log y', true),
            (r'\log(x^{c}) = c\,\log x', true),
            (r'\log(x + y) = \log x + \log y', false),
          ],
        );
      case BriefFigure.undoExponent:
        return const _RuleList(
          rules: [
            (r'0.25 = e^{-0.03t}', null),
            (r'\ln(0.25) = -0.03t', null),
            (r't = \frac{\ln(0.25)}{-0.03}', null),
          ],
        );
      case BriefFigure.combineLogs:
        return const _RuleList(
          rules: [
            (r'\log a + \log b = \log(ab)', true),
            (r'\log a - \log b = \log\!\left(\frac{a}{b}\right)', true),
            (r'c\,\log a = \log(a^{c})', true),
            (r'\log a \cdot \log b = \log(ab)', false),
          ],
        );
    }
  }
}

/// Rules, one per line, marked legal or not. A lesson with nothing to draw
/// shows the moves themselves; a check or a cross is the picture.
class _RuleList extends StatelessWidget {
  const _RuleList({required this.rules});

  /// Each entry is an expression and whether it is legal. Null means it is a
  /// step in a worked line rather than a claim to judge.
  final List<(String, bool?)> rules;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final (latex, legal) in rules)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: [
                  if (legal != null)
                    Icon(
                      legal ? Icons.check_rounded : Icons.close_rounded,
                      size: 18,
                      color: legal ? AppColors.forest : AppColors.error,
                    )
                  else
                    const Icon(
                      Icons.arrow_right_rounded,
                      size: 18,
                      color: AppColors.ink3,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MathBlock(
                      latex,
                      fontSize: 15,
                      align: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, required this.caption, this.height = 118});

  final Widget child;
  final String caption;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: EngineeringGrid(minor: 14, major: 70, child: child),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          style: const TextStyle(fontSize: 11.5, color: AppColors.ink2),
        ),
      ],
    );
  }
}

class _SlopePairPainter extends CustomPainter {
  _SlopePairPainter({required this.parallel});

  final bool parallel;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final second = Paint()
      ..color = parallel ? AppColors.info : AppColors.forest
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const m = 0.55; // the reference slope, drawn the same in both panels
    final c = Offset(size.width / 2, size.height / 2);

    void line(double slope, Offset through, Paint p) {
      final d = Offset(1, -slope) / math.sqrt(1 + slope * slope);
      final reach = size.width + size.height;
      canvas.drawLine(through - d * reach, through + d * reach, p);
    }

    canvas.clipRect(Offset.zero & size);
    if (parallel) {
      line(m, c + const Offset(0, 22), base);
      line(m, c - const Offset(0, 22), second);
    } else {
      line(m, c, base);
      line(-1 / m, c, second);
      // The right-angle mark that makes it unmistakable.
      Offset u(double s) => Offset(1, -s) / math.sqrt(1 + s * s);
      final a = u(m) * 14, b = u(-1 / m) * 14;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx + a.dx, c.dy + a.dy)
          ..lineTo(c.dx + a.dx + b.dx, c.dy + a.dy + b.dy)
          ..lineTo(c.dx + b.dx, c.dy + b.dy),
        Paint()
          ..color = AppColors.forest
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(c, 4, Paint()..color = AppColors.charcoal);
    }
  }

  @override
  bool shouldRepaint(_SlopePairPainter old) => old.parallel != parallel;
}

class _GradePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.14, right = size.width * 0.86;
    final base = size.height * 0.74, top = size.height * 0.3;

    final ground = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.35)
      ..strokeWidth = 2;
    final road = Paint()
      ..color = AppColors.ember
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, base), Offset(right, base), ground);
    canvas.drawLine(Offset(left, base), Offset(right, top), road);
    canvas.drawLine(Offset(right, base), Offset(right, top), ground);

    void label(String text, Offset at, {bool mono = true}) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: mono
              ? AppTheme.mono(size: 11, color: AppColors.ink2)
              : const TextStyle(fontSize: 11, color: AppColors.ink2),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at);
    }

    label('rise', Offset(right + 6, (base + top) / 2 - 8));
    label('run', Offset((left + right) / 2 - 12, base + 6));
    label('0+00', Offset(left - 12, base + 22));
    label('3+00', Offset(right - 20, base + 22));
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
