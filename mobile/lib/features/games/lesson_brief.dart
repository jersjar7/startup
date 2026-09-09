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
