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
  centre,
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
  lawChoice,
  lawForms,
  cosineSign,
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
      'Know the Pythagorean identity cold and recognise the double angles '
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
      'A circle in standard form hands you everything: the centre and the '
      'radius, with no work. Two things bite. The sign inside each bracket is '
      'the OPPOSITE of the coordinate, so (y + 3) puts the centre three below '
      'the axis. And the number on the right is the radius SQUARED, so 64 is a '
      'circle of radius eight.',
  formulas: [
    ('Standard form', r'(x-h)^2 + (y-k)^2 = r^2'),
    ('Which reads as', r'\text{centre } (h,k), \quad \text{radius } r'),
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
      'General form hides the centre, so you rewrite it. Take the coefficient '
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

const centreBrief = BriefSection(
  title: 'Three centres, and when they disagree',
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
  figure: BriefFigure.centre,
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
  title: 'A balance point, not a favourite',
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
      'Two separate offences. The first is doing the work: any service that '
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
    ('A.3(a)', r'\text{Practises, or holds out as able to practise.}'),
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
      'offence. Revoked, suspended and expired all mean the same thing here, '
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
      case BriefFigure.centre:
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
