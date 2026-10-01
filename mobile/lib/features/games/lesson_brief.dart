import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/math_text.dart';
import 'mechanics_pictures.dart';
import 'mathematics_pictures.dart';
import 'statistics_pictures.dart';
import 'ethics_pictures.dart';
import 'economics_pictures.dart';
import 'statics_pictures.dart';
import 'dynamics_pictures.dart';
import 'materials_pictures.dart';
import 'fluid_mechanics_pictures.dart';
import 'surveying_pictures.dart';
import 'water_resources_pictures.dart';
import 'structural_pictures.dart';
import 'geotechnical_pictures.dart';
import 'transportation_pictures.dart';
import 'construction_pictures.dart';

/// The idea behind a lesson, in a few lines and a picture, reachable both from
/// the lesson node and from inside a sitting. It is a reference, not a
/// question: nothing here is graded, and every word traces to the lesson's own
/// content blocks.
@immutable
class BriefSection {
  const BriefSection({
    required this.title,
    this.body = '',
    this.formula,
    this.formulas = const [],
    this.handbook,
    this.picture,
    this.steps = const [],
    this.spoken = const [],
  });

  final String title;
  final String body;

  /// The picture-first sheet (owner's call, 2026-09-30): a drawing the
  /// student can look at before a word is read, built from the game's own
  /// painters. A tear-off of a top-level function, so the section stays
  /// const.
  final Widget Function()? picture;

  /// The idea in short steps, each an eyebrow and a few plain sentences that
  /// assume the reader has never heard the words. When these are present the
  /// [body] paragraph is not shown.
  final List<(String, String)> steps;

  /// The rules, each with its name, the expression, and the expression read
  /// out in words. When these are present [formulas] is not shown.
  final List<(String, String, String)> spoken;

  /// A single expression, shown big under the body.
  final String? formula;

  /// Named expressions, for a concept that IS a formula rather than one that
  /// merely uses one. Without these a card can explain when to reach for a law
  /// and never show the law, which reads as arbitrary.
  final List<(String, String)> formulas;
  final String? handbook;
}

/// One concept per item. Each is the reference for the item it sits behind and
/// nothing else: opening it mid-round should answer the question in front of
/// you, not make you hunt through the rest of the lesson.
const perpendicularBrief = BriefSection(
  title: 'Parallel and perpendicular',
  picture: perpendicularPicture,
  steps: [
    (
      'Slope is how steep a line is',
      'It is how far the line climbs for every step you take across. A big '
          'slope is a steep line. A small one is nearly flat.',
    ),
    (
      'Same slope means they never meet',
      'Two lines with the same steepness run alongside each other forever. '
          'That is what parallel means, and it is the whole test: compare the '
          'two slopes.',
    ),
    (
      'Square corners need two changes',
      'To turn a line a quarter turn you flip its slope upside down AND '
          'change its sign. A slope of 2 becomes minus a half. Doing only one of '
          'the two gives a line that looks about right and is wrong.',
    ),
  ],
  spoken: [
    ('Parallel', r'm_1 = m_2', 'the two slopes are the same number'),
    (
      'Perpendicular',
      r'm_{\perp} = -\frac{1}{m}',
      'flip the slope over, then change its sign',
    ),
  ],
  handbook: 'Handbook p. 36',
);

const discriminantBrief = BriefSection(
  title: 'The part under the square root',
  picture: discriminantPicture,
  steps: [
    (
      'A curve and a line',
      'A quadratic draws a U shape. Solving it means asking where that U '
          'cuts the flat line at zero. Look at the picture: it can cut twice, '
          'touch once, or miss completely.',
    ),
    (
      'One number decides which',
      'Inside the quadratic formula there is a square root. The stuff under '
          'that root is called the discriminant, and its SIGN alone tells you '
          'which of the three pictures you have.',
    ),
    (
      'Reading the sign',
      'Positive means the root is a real number you can add and subtract: '
          'two answers. Zero means adding and subtracting nothing: one answer. '
          'Negative means no real root at all: the curve misses.',
    ),
    (
      'Why it is worth a look first',
      'You can throw out wrong answer choices before doing any arithmetic, '
          'just from that one sign.',
    ),
  ],
  spoken: [
    (
      'The quadratic formula',
      r'x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}',
      'minus b, plus or minus the root, all over two a',
    ),
    (
      'The discriminant is what is under the root',
      r'b^2 - 4ac',
      'b squared, take away four times a times c',
    ),
  ],
  handbook: 'Handbook p. 36',
);

const gradeBrief = BriefSection(
  title: 'Grade, rise and run',
  picture: gradePicture,
  steps: [
    (
      'A road going uphill',
      'Grade is just steepness written as a percent. Go along the road and '
          'see how much it climbs. A grade of 5 percent means it climbs 5 feet '
          'for every 100 feet you travel along.',
    ),
    (
      'Stations are not plain numbers',
      'Surveyors mark distance in hundreds of feet and write it with a '
          'plus. So 3+00 means 300 feet from the start, not 3 feet.',
    ),
    (
      'Convert first, always',
      'Take the stations apart before you compare anything. Use 3 instead of '
          '300 and a gentle road comes out looking like a cliff, a hundred times '
          'too steep.',
    ),
  ],
  spoken: [
    (
      'Grade',
      r'\text{grade} = \frac{\text{rise}}{\text{run}} \times 100\%',
      'how much it climbs, over how far it runs, as a percent',
    ),
    (
      'A station is hundreds of feet',
      r'3{+}00 = 300\ \text{ft}',
      'three plus zero zero means three hundred feet',
    ),
  ],
  handbook: 'Handbook p. 36',
);

// ── Logarithms ──────────────────────────────────────────────────────────────
// This lesson has no figure of its own anywhere in the web content, so its
// references show the rules themselves rather than a picture of something.

const logRulesBrief = BriefSection(
  title: 'What a log is, and the rule that does not exist',
  picture: logRulesPicture,
  steps: [
    (
      'A log asks how many times',
      'Three 2s multiplied together make 8. So the log of 8, in base 2, is '
          '3. That is all a logarithm is: how many copies of the base you had to '
          'multiply.',
    ),
    (
      'Multiplying inside adds outside',
      'Four 2s times three more 2s is seven 2s. Since the log just counts '
          'the copies, a product inside a log becomes a SUM outside it. A '
          'divide becomes a subtract, for the same reason.',
    ),
    (
      'A power drops to the front',
      'A number raised to a power is that many copies of the copies, so the '
          'power simply comes down and multiplies.',
    ),
    (
      'There is no rule for a plus inside',
      'Adding two numbers inside a log tells you nothing about the copies. '
          'Splitting one is the cheapest way to lose a mark on this topic.',
    ),
  ],
  spoken: [
    (
      'What a log means',
      r'\log_b x = c \iff b^c = x',
      'the log of x is c exactly when b to the c gives x',
    ),
    (
      'Product',
      r'\log_b(xy) = \log_b x + \log_b y',
      'times inside becomes plus outside',
    ),
    ('Power', r'\log_b(x^n) = n\log_b x', 'the power comes down in front'),
  ],
  handbook: 'Handbook p. 36',
);

const undoExponentBrief = BriefSection(
  title: 'Getting the unknown down from the exponent',
  picture: undoExponentPicture,
  steps: [
    (
      'The unknown is out of reach',
      'When x sits up in the exponent, nothing you do with plus, minus, '
          'times or divide will bring it down. You need the tool that is built '
          'to undo an exponent.',
    ),
    (
      'A log undoes its own base',
      'ln and e cancel each other exactly. So do log and 10. Take the log of '
          'both sides and whatever was up in the exponent lands on the ground '
          'as an ordinary multiplier.',
    ),
    (
      'Clear the front first',
      'If something is multiplying the exponential, divide it away BEFORE '
          'you take the log. Take the log too early and you have the log of a '
          'product instead of a clean exponent.',
    ),
    (
      'What is left is easy',
      'After the log, the equation is a straight line in x. Divide and you '
          'are done.',
    ),
  ],
  spoken: [
    (
      'A log undoes its own base',
      r'\ln(e^{x}) = x \qquad \log_{10}(10^{x}) = x',
      'ln cancels e, and log cancels ten',
    ),
    (
      'Which is the definition read backwards',
      r'\log_b x = c \iff b^c = x',
      'the log is just the power, named the other way round',
    ),
  ],
  handbook: 'Handbook p. 36',
);

const combineLogsBrief = BriefSection(
  title: 'Squeeze the logs into one first',
  picture: combineLogsPicture,
  steps: [
    (
      'Several logs, one answer wanted',
      'A question hands you two or three log terms added and subtracted. '
          'Work each one out separately and you have three ugly decimals to '
          'juggle.',
    ),
    (
      'Fold them together instead',
      'Added terms multiply inside. Subtracted terms divide inside. A number '
          'in front becomes a power inside. Do that and three terms become one.',
    ),
    (
      'Only within one base',
      'This folding only works when every log has the same base. Logs of '
          'different bases will not combine.',
    ),
    (
      'The mistake it avoids',
      'People multiply the separate log VALUES together. The rule multiplies '
          'what is inside, never the answers.',
    ),
  ],
  spoken: [
    (
      'Added terms multiply inside',
      r'\log_b x + \log_b y = \log_b(xy)',
      'plus outside becomes times inside',
    ),
    (
      'Subtracted terms divide inside',
      r'\log_b x - \log_b y = \log_b\!\left(\frac{x}{y}\right)',
      'minus outside becomes divide inside',
    ),
    (
      'A coefficient becomes a power',
      r'n\log_b x = \log_b(x^n)',
      'a number in front moves up as a power',
    ),
  ],
  handbook: 'Handbook pp. 36-37',
);

// ── Right Triangle Trigonometry ─────────────────────────────────────────────

const ratiosBrief = BriefSection(
  title: 'The three ratios, and picking one',
  picture: ratiosPicture,
  steps: [
    (
      'Same shape, same ratios',
      'Every right triangle with the same angle has sides in the same '
          'proportions, however big it is drawn. Those fixed proportions are '
          'what sine, cosine and tangent are.',
    ),
    (
      'Three pairings, three names',
      'Opposite over hypotenuse is sine. Adjacent over hypotenuse is cosine. '
          'Opposite over adjacent is tangent. SOH CAH TOA is just those three '
          'read out.',
    ),
    (
      'Pick by what you have',
      'Do not pick a ratio and hope. List the side you know and the side you '
          'want, then take the ratio that has both of them in it. Only one will.',
    ),
    (
      'The one people mix up',
      'Cos is cozy with the adjacent side, the one leaning against the '
          'angle.',
    ),
  ],
  spoken: [
    (
      'SOH',
      r'\sin\theta = \frac{\text{opp}}{\text{hyp}}',
      'sine is opposite over hypotenuse',
    ),
    (
      'CAH',
      r'\cos\theta = \frac{\text{adj}}{\text{hyp}}',
      'cosine is adjacent over hypotenuse',
    ),
    (
      'TOA',
      r'\tan\theta = \frac{\text{opp}}{\text{adj}}',
      'tangent is opposite over adjacent',
    ),
  ],
  handbook: 'Handbook p. 23',
);

const sideNamesBrief = BriefSection(
  title: 'Opposite, adjacent, hypotenuse',
  picture: sideNamesPicture,
  steps: [
    (
      'One side never moves',
      'The hypotenuse is the side across from the square corner. It is '
          'always the longest, and its name never changes no matter which angle '
          'you are working with.',
    ),
    (
      'The other two are named from YOUR angle',
      'Mark an angle. The side that does not touch it at all is the '
          'opposite. The side that does touch it, and is not the hypotenuse, is '
          'the adjacent.',
    ),
    (
      'Mark the other corner and they swap',
      'Look at the two pictures: same triangle, nothing moved. Only the '
          'marked angle changed, and opposite and adjacent traded places.',
    ),
  ],
  spoken: [
    (
      'Always across from the square corner',
      r'\text{hyp}',
      'the hypotenuse, the long side',
    ),
    (
      'Named against the marked angle',
      r'\text{opp} \;/\; \text{adj}',
      'the side that misses it, and the side that touches it',
    ),
  ],
  handbook: 'Handbook p. 23',
);

const componentsBrief = BriefSection(
  title: 'Splitting a slanted push into two',
  picture: componentsPicture,
  steps: [
    (
      'A slanted push does two jobs',
      'Pull a sled with a rope at an angle and part of your pull drags it '
          'along and part lifts it. Those two parts are the sides of a right '
          'triangle with your pull as the long side.',
    ),
    (
      'The side the angle leans on takes cosine',
      'Cosine goes with the adjacent side, the one the angle is measured '
          'from. So if the angle is measured up from the ground, the along-the-'
          'ground piece is the cosine one.',
    ),
    (
      'Measure from upright and they swap',
      'Look at the second picture. Nothing about the push changed, only '
          'where the angle was measured from. Now the across piece takes sine.',
    ),
    (
      'So read the drawing, not the habit',
      'Assuming cosine is always across is the single biggest trap here.',
    ),
  ],
  spoken: [
    (
      'Angle measured from across',
      r'F_x = F\cos\theta \qquad F_y = F\sin\theta',
      'across takes cosine, up takes sine',
    ),
    (
      'Angle measured from upright, the two swap',
      r'F_x = F\sin\theta \qquad F_y = F\cos\theta',
      'now across takes sine and up takes cosine',
    ),
  ],
  handbook: 'Handbook p. 23',
);

// ── Law of Sines & Law of Cosines ───────────────────────────────────────────

const whichLawBrief = BriefSection(
  title: 'Which law, and when',
  picture: whichLawPicture,
  steps: [
    (
      'No square corner, no SOH CAH TOA',
      'A triangle with no right angle has no hypotenuse, so the three ratios '
          'have nothing to hang on. Two other relations hold in EVERY triangle '
          'instead.',
    ),
    (
      'Sines: a side paired with its own angle',
      'Each side sits over the sine of the angle facing it, and all three '
          'of those fractions are equal. So one matched pair sets the scale for '
          'the whole triangle.',
    ),
    (
      'Cosines: nothing is paired',
      'It is the Pythagorean theorem with a correction subtracted. Use it '
          'when you have two sides and the angle squeezed between them, or all '
          'three sides and no angle.',
    ),
    (
      'The one question to ask',
      'Do I have a side together with the angle opposite it? Yes means '
          'sines. No means cosines.',
    ),
  ],
  spoken: [
    (
      'Law of Sines',
      r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C}',
      'each side over the sine of its own angle, all equal',
    ),
    (
      'Law of Cosines',
      r'c^2 = a^2 + b^2 - 2ab\cos C',
      'Pythagoras, with a correction taken off for the angle',
    ),
  ],
  handbook: 'Handbook p. 23',
);

const setupBrief = BriefSection(
  title: 'Writing the two laws down without flipping them',
  picture: setupPicture,
  steps: [
    (
      'Small letters face capital letters',
      'Side a is across from angle A, side b from angle B, side c from C. '
          'Look at the picture: every side is labeled with the small version of '
          'the angle staring at it.',
    ),
    (
      'Each side over its OWN angle',
      'The Law of Sines pairs a with A, never with B. Flipping one of those '
          'fractions upside down is the usual slip, and it gives an answer that '
          'looks reasonable.',
    ),
    (
      'The correction is always subtracted',
      'In the Law of Cosines the last term comes off, never on. And the '
          'angle in it is the one facing the side you are solving for.',
    ),
  ],
  spoken: [
    (
      'Law of Sines',
      r'\frac{a}{\sin A} = \frac{b}{\sin B} = \frac{c}{\sin C}',
      'each side over the sine of the angle facing it',
    ),
    (
      'Law of Cosines',
      r'c^2 = a^2 + b^2 - 2ab\cos C',
      'the two known sides squared, minus the correction',
    ),
    (
      'Rearranged for an angle',
      r'\cos C = \frac{a^2 + b^2 - c^2}{2ab}',
      'the side facing the angle comes off the top',
    ),
  ],
  handbook: 'Handbook p. 23',
);

const obtuseBrief = BriefSection(
  title: 'What a negative cosine is telling you',
  picture: obtusePicture,
  steps: [
    (
      'Cosine slides from plus one to minus one',
      'At a tiny angle cosine is nearly 1. At a square corner it is exactly '
          '0. Past that it goes negative and keeps falling. The sign is a '
          'message about how open the angle is.',
    ),
    (
      'When the top goes negative',
      'Rearranged for an angle, the formula puts the side facing that angle '
          'on top with a minus in front. If that side squared beats the other '
          'two put together, the top is negative.',
    ),
    (
      'So the angle is past square',
      'A negative cosine means an obtuse angle. It is not a mistake and it '
          'is not a sign error to fix.',
    ),
    (
      'Nothing needs subtracting from 180',
      'The inverse cosine button already hands back the obtuse angle. '
          '"Correcting" it is how people turn a right answer into a wrong one.',
    ),
  ],
  spoken: [
    (
      'Rearranged for the angle',
      r'\cos C = \frac{a^2 + b^2 - c^2}{2ab}',
      'the two known sides squared, minus the facing side squared, over two a b',
    ),
    (
      'And the test that follows',
      r'c^2 > a^2 + b^2 \iff C > 90^\circ',
      'if the facing side squared wins, the angle is past square',
    ),
  ],
  handbook: 'Handbook p. 23',
);

// ── Unit Circle & Trig Identities ───────────────────────────────────────────

const unitCircleBrief = BriefSection(
  title: 'Across is cosine, up is sine',
  picture: unitCirclePicture,
  steps: [
    (
      'Walk round a circle of radius one',
      'Start at the right-hand edge and sweep round anticlockwise. Wherever '
          'you stop, you are some distance across and some distance up.',
    ),
    (
      'Those two distances have names',
      'How far ACROSS is the cosine of the angle. How far UP is the sine. '
          'That is the whole definition, and every other fact follows from it.',
    ),
    (
      'Which is why they are easy to swap',
      'At 30 degrees you are far across and only a little up. At 60 it is '
          'the other way. Swapping the two swaps the angle.',
    ),
    (
      'Learn one quarter only',
      'The other three quarters are mirrors of the first. Get the first '
          'quarter cold and you have the whole circle.',
    ),
  ],
  spoken: [
    (
      'The point at any angle',
      r'(\cos\theta,\; \sin\theta)',
      'how far across, then how far up',
    ),
    (
      'The three worth knowing cold',
      r'30^\circ:\left(\tfrac{\sqrt{3}}{2},\tfrac{1}{2}\right)\quad '
          r'45^\circ:\left(\tfrac{\sqrt{2}}{2},\tfrac{\sqrt{2}}{2}\right)\quad '
          r'60^\circ:\left(\tfrac{1}{2},\tfrac{\sqrt{3}}{2}\right)',
      'at 45 the two match; at 30 across wins; at 60 up wins',
    ),
  ],
  handbook: 'Handbook p. 23',
);

const quadrantBrief = BriefSection(
  title: 'The quarter you are in puts the sign back',
  picture: quadrantPicture,
  steps: [
    (
      'Squaring throws the sign away',
      'Minus three squared and plus three squared are both nine. So any '
          'formula that goes through a square can only ever hand you back the '
          'SIZE of an answer, never whether it is plus or minus.',
    ),
    (
      'The circle remembers it',
      'Across is positive to the right and negative to the left. Up is '
          'positive above the middle and negative below. Look at which quarter '
          'the angle lands in and both signs are decided.',
    ),
    (
      'So cosine and sine each have two good quarters',
      'Cosine is positive on the right half, quarters one and four. Sine is '
          'positive on the top half, quarters one and two.',
    ),
    (
      'Stopping too early is the mistake',
      'Getting the size from the identity and never checking the quarter '
          'gets you the right number with the wrong sign.',
    ),
  ],
  spoken: [
    (
      'It gives the size',
      r'\cos\theta = \pm\sqrt{1 - \sin^2\theta}',
      'the root gives how big, and leaves the sign open',
    ),
    (
      'The quadrant gives the sign',
      r'\text{Q1}: ++ \quad \text{Q2}: -+ \quad \text{Q3}: -- \quad \text{Q4}: +-',
      'first is across then up, quarter by quarter',
    ),
  ],
  handbook: 'Handbook p. 23',
);

const identitiesBrief = BriefSection(
  title: 'The identities worth knowing',
  picture: identitiesPicture,
  steps: [
    (
      'There is a triangle inside the circle',
      'Drop a line straight down from the point on the circle. You get a '
          'right triangle whose short sides are cosine and sine, and whose long '
          'side is the radius, which is 1.',
    ),
    (
      'So Pythagoras gives it to you free',
      'Short side squared plus short side squared equals long side squared. '
          'That is sine squared plus cosine squared equals one. It is not a new '
          'fact, it is the triangle.',
    ),
    (
      'Doubling an angle is not doubling its sine',
      'Turn twice as far and you do not get twice as high. sin of 2 theta '
          'needs BOTH functions and a 2 in front.',
    ),
    (
      'And the cosine one is a difference',
      'cos of 2 theta is cosine squared MINUS sine squared, in that order. '
          'Flipping the order flips the sign of your answer.',
    ),
  ],
  spoken: [
    (
      'Pythagorean',
      r'\sin^2\theta + \cos^2\theta = 1',
      'the two short sides squared add to one',
    ),
    (
      'Double angle, sine',
      r'\sin 2\theta = 2\sin\theta\cos\theta',
      'two, times sine, times cosine',
    ),
    (
      'Double angle, cosine',
      r'\cos 2\theta = \cos^2\theta - \sin^2\theta',
      'cosine squared take away sine squared, that way round',
    ),
  ],
  handbook: 'Handbook p. 23',
);

// ── Circles & Conic Sections ────────────────────────────────────────────────

const circleFormBrief = BriefSection(
  title: 'Reading a circle off its equation',
  picture: circleFormPicture,
  steps: [
    (
      'A circle is a place and a reach',
      'Every circle is fixed by two things: where its middle sits, and how '
          'far it reaches out. Standard form hands you both with no work at all.',
    ),
    (
      'The sign flips',
      'Whatever is inside a bracket, the center is the OPPOSITE. So x minus '
          '2 means the center is 2 to the right, and y plus 3 means 3 BELOW the '
          'middle. It catches people every time.',
    ),
    (
      'The number on the right is squared',
      'It is the radius times itself, not the radius. A 64 on the right '
          'means a reach of 8. Take the square root before you draw anything.',
    ),
  ],
  spoken: [
    (
      'Standard form',
      r'(x-h)^2 + (y-k)^2 = r^2',
      'x minus the across number, y minus the up number, equals the reach squared',
    ),
    (
      'Which reads as',
      r'\text{center } (h,k), \quad \text{radius } r',
      'the center is h across and k up, and the reach is r',
    ),
  ],
  handbook: 'Handbook p. 24',
);

const readingConicsBrief = BriefSection(
  title: 'Telling the three shapes apart',
  picture: readingConicsPicture,
  steps: [
    (
      'Count the squared terms',
      'Look at the equation and ask a single question first: is x squared '
          'there, is y squared there, or only one of them?',
    ),
    (
      'Only one square is a parabola',
      'One squared term and one plain one draws a U. The sign in front of '
          'the square decides whether the U opens up or down.',
    ),
    (
      'Both squares, same number, is a circle',
      'If x squared and y squared carry exactly the same coefficient, every '
          'direction reaches the same distance. That is a circle.',
    ),
    (
      'Both squares, different numbers, is an ellipse',
      'Different denominators stretch it one way. The BIGGER denominator '
          'sits under the long direction.',
    ),
  ],
  spoken: [
    (
      'Circle',
      r'(x-h)^2 + (y-k)^2 = r^2',
      'both squares, matching, equal to the reach squared',
    ),
    (
      'Parabola',
      r'y = a(x-h)^2 + k',
      'one square only, opening up when a is positive',
    ),
    (
      'Ellipse',
      r'\frac{(x-h)^2}{a^2} + \frac{(y-k)^2}{b^2} = 1',
      'both squares over different bottoms, adding to one',
    ),
    (
      "And a parabola's peak",
      r'x = -\frac{b}{2a}',
      'minus b over two a gives where the turning point sits',
    ),
  ],
  handbook: 'Handbook p. 24',
);

const completeSquareBrief = BriefSection(
  title: 'Completing the square',
  picture: completeSquarePicture,
  steps: [
    (
      'A square with a strip stuck on',
      'Picture x squared as a real square, and the plain x term as a strip '
          'laid along its edge. Together they are ALMOST a bigger square, but a '
          'little corner is missing.',
    ),
    (
      'Cut the strip in half',
      'Split the strip and lay half along the top and half down the side. '
          'Now the only thing stopping it from being a perfect square is one '
          'small corner block.',
    ),
    (
      'That corner is what you add',
      'Its size is half the x number, squared. Add it and the left side '
          'folds neatly into one bracket squared.',
    ),
    (
      'Add it to BOTH sides',
      'Adding it only on the left quietly changes the equation, and the '
          'radius you read off at the end comes out wrong.',
    ),
  ],
  spoken: [
    (
      'General form',
      r'x^2 + y^2 + Dx + Ey + F = 0',
      'squares and plain terms all mixed together',
    ),
    (
      'Halve, square, add to both sides',
      r'x^2 - 10x \;\to\; (x-5)^2 - 25',
      'half of ten is five, five squared is twenty-five',
    ),
  ],
  handbook: 'Handbook p. 24',
);

// ── Derivatives & Derivative Rules ──────────────────────────────────────────

const whichRuleBrief = BriefSection(
  title: 'Which rule, and how many',
  picture: whichRulePicture,
  steps: [
    (
      'Read the shape, not the letters',
      'The handbook has every rule in a table. What it cannot do is tell you '
          'which one YOUR function needs. That comes from looking at how the '
          'function is put together.',
    ),
    (
      'Question one: is anything multiplied or divided',
      'Two separate things stuck together with a times or a divide. The '
          'product rule then works in turns: change one and leave the other, '
          'then swap, and the two go together. The lower picture shows it.',
    ),
    (
      'Question two: is anything wrapped inside anything',
      'If what sits inside a sine, a root or a bracket is anything other '
          'than plain x, there is a chain rule to pay.',
    ),
    (
      'Both answers can be yes',
      'On this exam they usually are. Answer both questions before you start '
          'writing.',
    ),
  ],
  spoken: [
    (
      'Product',
      r'\frac{d}{dx}(uv) = u\frac{dv}{dx} + v\frac{du}{dx}',
      'first times the slope of the second, plus second times the slope of the first',
    ),
    (
      'Quotient',
      r'\frac{d}{dx}\!\left(\frac{u}{v}\right) = \frac{v\frac{du}{dx} - u\frac{dv}{dx}}{v^2}',
      'bottom times the slope of the top, minus top times the slope of the bottom, over bottom squared',
    ),
    (
      'Chain',
      r"\frac{d}{dx}f(g(x)) = f'(g(x)) \cdot g'(x)",
      'the slope of the outside, times the slope of the inside',
    ),
  ],
  handbook: 'Handbook p. 49',
);

const chainRuleBrief = BriefSection(
  title: 'The chain rule, and the factor people drop',
  picture: chainRulePicture,
  steps: [
    (
      'A function inside a function',
      'Look at the picture: a bracket raised to a power, with 3x plus 5 '
          'living inside it. Two layers, like a box in a box.',
    ),
    (
      'Peel the outside first',
      'Treat the whole inside as one lump and differentiate the outer layer '
          'normally. Power 4 becomes 4 times power 3, with the lump untouched.',
    ),
    (
      'Then pay for the inside',
      'The inside is changing too, three times as fast as x. So multiply by '
          'that 3. It goes OUTSIDE as a factor and never moves into the bracket.',
    ),
    (
      'It is nearly always there',
      'Almost every derivative on this exam has an inside. The missing inner '
          'factor is the most common wrong answer there is.',
    ),
  ],
  spoken: [
    (
      'The rule',
      r"\frac{d}{dx}f(g(x)) = f'(g(x)) \cdot g'(x)",
      'the slope of the outside, times the slope of the inside',
    ),
    (
      'So',
      r'\frac{d}{dx}(3x+5)^4 = 4(3x+5)^3 \cdot 3',
      'four brackets cubed, and then times three for the inside',
    ),
  ],
  handbook: 'Handbook p. 49',
);

const quotientOrderBrief = BriefSection(
  title: 'Lo d-hi minus hi d-lo',
  picture: quotientOrderPicture,
  steps: [
    (
      'The order is the whole rule',
      'The BOTTOM function comes first, multiplying the slope of the top. '
          'Then you take away the top times the slope of the bottom.',
    ),
    (
      'Swap them and every sign flips',
      'A minus b is not b minus a. Write the two terms the other way round '
          'and the answer is exactly the negative of the right one, which still '
          'looks like a real answer.',
    ),
    (
      'The bottom gets squared',
      'The denominator is the bottom function times itself. Leaving it as '
          'just the bottom is the other half people drop.',
    ),
    (
      'Say it out loud while you write',
      'Lo d-hi, minus hi d-lo, over lo-lo. The rhythm keeps the order.',
    ),
  ],
  spoken: [
    (
      'Quotient rule',
      r'\frac{d}{dx}\!\left(\frac{u}{v}\right) = \frac{v\frac{du}{dx} - u\frac{dv}{dx}}{v^2}',
      'bottom times slope of top, minus top times slope of bottom, over bottom squared',
    ),
    (
      'Said out loud',
      r'\text{lo d-hi} - \text{hi d-lo, over lo-lo}',
      'the bottom always goes first',
    ),
  ],
  handbook: 'Handbook p. 49',
);

// ── Applications of Derivatives ─────────────────────────────────────────────

const criticalPointBrief = BriefSection(
  title: 'Flat first, then which way it bends',
  picture: criticalPointPicture,
  steps: [
    (
      'Tops and bottoms are flat',
      'Walk along a hill. At the very top you are, for an instant, going '
          'neither up nor down. Same at the bottom of a valley. So the slope is '
          'zero at both.',
    ),
    (
      'So the first move is always the same',
      'Differentiate and set that equal to zero. Solving it gives you every '
          'place the curve levels off.',
    ),
    (
      'Flat alone does not say which',
      'Zero slope happens at hilltops AND valley bottoms. You have found the '
          'places, not the kind.',
    ),
    (
      'The second derivative tells you the kind',
      'Negative means the curve frowns, so you are on a hilltop. Positive '
          'means it smiles, so you are in a valley. A curve often has both.',
    ),
  ],
  spoken: [
    (
      'Maximum',
      r"f'(a) = 0 \;\text{and}\; f''(a) < 0",
      'flat, and bending downward: a hilltop',
    ),
    (
      'Minimum',
      r"f'(a) = 0 \;\text{and}\; f''(a) > 0",
      'flat, and bending upward: a valley',
    ),
  ],
  handbook: 'Handbook p. 46',
);

const concavityBrief = BriefSection(
  title: 'Smiles, frowns, and the flip',
  picture: concavityPicture,
  steps: [
    (
      'Bend is not slope',
      'A road can be going uphill and still be flattening out. Slope is '
          'which way you are heading. Bend is whether the road is curving toward '
          'the sky or toward the ground.',
    ),
    (
      'Smile up, frown down',
      'The second derivative measures bend. Positive draws a smile, which '
          'would hold water. Negative draws a frown, which would spill it.',
    ),
    (
      'An inflection point is where it flips',
      'It is the spot where a frown becomes a smile. Look at the picture: '
          'the curve is still climbing right through it, so nothing about the '
          'slope marks it.',
    ),
    (
      'Reaching zero is not enough',
      'The second derivative must hit zero AND come out the other side with '
          'the OPPOSITE sign. A flat moment that goes back the way it came is '
          'not an inflection point.',
    ),
  ],
  spoken: [
    ('Concave up, a smile', r"f''(x) > 0", 'bending toward the sky'),
    ('Concave down, a frown', r"f''(x) < 0", 'bending toward the ground'),
    (
      'Inflection point',
      r"f''(a) = 0 \;\text{and}\; f'' \text{ changes sign}",
      'zero, and coming out the other side the other way',
    ),
  ],
  handbook: 'Handbook p. 46',
);

const askedForBrief = BriefSection(
  title: 'Where it happens, or how much it is',
  picture: askedForPicture,
  steps: [
    (
      'A hilltop has two numbers',
      'How far along it sits, and how high it is. They are different '
          'numbers and they answer different questions.',
    ),
    (
      'Setting the slope to zero gives the first one',
      'It hands you the LOCATION and nothing else. That is the along number, '
          'the x.',
    ),
    (
      'The height needs one more step',
      'Put that location back into the original function. Only then do you '
          'have how high, the y.',
    ),
    (
      'The exam offers you both',
      'Almost half the time the question wants the height, and the location '
          'is sitting there in the answer choices to catch you. Read the '
          'sentence again before you pick.',
    ),
  ],
  spoken: [
    (
      'Where it happens',
      r"f'(a) = 0 \Rightarrow a",
      'the slope being zero gives the place',
    ),
    (
      'How much it is there',
      r'f(a)',
      'put the place back in to get the height',
    ),
  ],
  handbook: 'Handbook p. 46',
);

// ── Integral Calculus ───────────────────────────────────────────────────────

const substitutionBrief = BriefSection(
  title: 'Substitution needs a matched pair',
  picture: substitutionPicture,
  steps: [
    (
      'It only works on one shape',
      'Something wrapped inside something else, AND the slope of that inside '
          'sitting there too, multiplying it. Both halves, or it does not work.',
    ),
    (
      'Name the inside u',
      'Whatever is wrapped up becomes u. Then du is the slope of that inside '
          'times dx, which is exactly the leftover you were hoping for.',
    ),
    (
      'A constant off is still fine',
      'If the leftover is twice du, or half of it, pull the number out front '
          'and carry on. Only the shape has to match.',
    ),
    (
      'No match, no substitution',
      'If the slope of your inside is nowhere in the integral, rearranging '
          'will not conjure it. Pick a different method.',
    ),
  ],
  spoken: [
    (
      'The shape it needs',
      r"\int f(g(x))\,g'(x)\,dx",
      'a function of something, times the slope of that something',
    ),
    (
      'Let u be the inside',
      r"u = g(x) \;\Rightarrow\; du = g'(x)\,dx",
      'name the inside u, and its slope times dx is du',
    ),
    (
      'And it becomes',
      r'\int f(u)\,du',
      'a plain integral in u, with nothing wrapped',
    ),
  ],
  handbook: 'Handbook p. 50',
);

const byPartsBrief = BriefSection(
  title: 'By parts, and which one is u',
  picture: byPartsPicture,
  steps: [
    (
      'It is a trade, not a solution',
      'By parts swaps the integral you have for a different one. It is only '
          'worth doing if the new one is easier than the old one.',
    ),
    (
      'What decides that is your choice of u',
      'Whatever you call u gets DIFFERENTIATED. Whatever is left gets '
          'integrated. So put the thing that gets simpler when you '
          'differentiate it in the u slot.',
    ),
    (
      'LIATE is that list, in order',
      'Logs, Inverse trig, Algebra, Trig, Exponential. Whichever of your two '
          'pieces sits higher up the list becomes u.',
    ),
    (
      'Why that order',
      'A log or a plain x collapses when you differentiate it. A sine or an '
          'e to the x never gets any simpler, so it goes in the other slot.',
    ),
  ],
  spoken: [
    (
      'The rule',
      r'\int u\,dv = uv - \int v\,du',
      'u times v, minus the integral of v times du',
    ),
    (
      'LIATE, best first',
      r'\text{L} \;\;\text{I} \;\;\text{A} \;\;\text{T} \;\;\text{E}',
      'logs, inverse trig, algebra, trig, exponential',
    ),
  ],
  handbook: 'Handbook p. 50',
);

const finishingBrief = BriefSection(
  title: 'Finishing an integral',
  picture: finishingPicture,
  steps: [
    (
      'Without limits you get a family',
      'Lots of different curves have exactly the same slope everywhere; they '
          'just sit at different heights. Look at the picture. You cannot tell '
          'which one, so you write plus C and mean all of them.',
    ),
    (
      'With limits you get one number',
      'Put in the top limit, then take away the bottom limit. That is an '
          'area, and it is a single number.',
    ),
    (
      'So plus C has no business there',
      'Whatever C is, it appears twice and cancels itself in the '
          'subtraction. Writing it on a definite integral says you have not '
          'understood what the limits did.',
    ),
    (
      'If you substituted, the limits change too',
      'The limits belonged to x. After a substitution they belong to u, so '
          'convert them or change back before you put them in.',
    ),
  ],
  spoken: [
    (
      'Indefinite, a family',
      r'\int f(x)\,dx = F(x) + C',
      'every curve with that slope, at any height',
    ),
    (
      'Definite, a number',
      r'\int_a^b f(x)\,dx = F(b) - F(a)',
      'the value at the top limit, take away the value at the bottom',
    ),
  ],
  handbook: 'Handbook p. 50',
);

// ── L'Hopital's Rule ────────────────────────────────────────────────────────

const formCheckBrief = BriefSection(
  title: 'Check the form before you differentiate',
  picture: formCheckPicture,
  steps: [
    (
      'Put the number in first',
      'Before anything else, substitute the value the limit is heading to '
          'and see what comes out. What you see decides everything.',
    ),
    (
      'Zero over zero, or big over big',
      'These are the two readings that tell you nothing yet. Both pieces are '
          'racing to the same place and you cannot see who wins. Now the rule '
          'is allowed.',
    ),
    (
      'A plain number means you are done',
      'If it comes out as 7 over 2, that IS the limit. Using the rule from '
          'there changes a right answer into a wrong one.',
    ),
    (
      'A number over zero is a blow up',
      'That is not undecided, it is unbounded. The rule has nothing to say '
          'about it.',
    ),
  ],
  spoken: [
    (
      'The rule, when the form allows it',
      r"\lim_{x \to a}\frac{f(x)}{g(x)} = \lim_{x \to a}\frac{f'(x)}{g'(x)}",
      'replace top and bottom by their slopes and look again',
    ),
    (
      'The two forms that allow it',
      r'\frac{0}{0} \quad \frac{\infty}{\infty}',
      'zero over zero, or endless over endless',
    ),
  ],
  handbook: 'Handbook p. 48',
);

const separatelyBrief = BriefSection(
  title: 'Top and bottom, separately',
  picture: separatelyPicture,
  steps: [
    (
      'Two different jobs, two different rules',
      'The quotient rule finds the slope OF a fraction. This rule finds the '
          'limit of one. They look alike on the page and they give different '
          'answers.',
    ),
    (
      'Differentiate each one on its own',
      'Slope of the top, written on top. Slope of the bottom, written '
          'underneath. Look at the picture: two separate arrows straight across.',
    ),
    (
      'Nothing multiplies, nothing is squared',
      'There is no product term and no squared denominator. If either '
          'appears in your working you have reached for the wrong rule.',
    ),
  ],
  spoken: [
    (
      'What the rule does',
      r"\frac{f}{g} \;\Rightarrow\; \frac{f'}{g'}",
      'slope of the top over slope of the bottom',
    ),
    (
      'What the quotient rule does, which is not this',
      r"\frac{f'g - fg'}{g^2}",
      'the one with a product and a squared bottom',
    ),
  ],
  handbook: 'Handbook p. 48',
);

const bothSidesBrief = BriefSection(
  title: 'Both sides have to agree',
  picture: bothSidesPicture,
  steps: [
    (
      'When the bottom goes to zero',
      'A number divided by something tiny is enormous. So if the top settles '
          'on anything other than zero and the bottom vanishes, the fraction '
          'blows up.',
    ),
    (
      'Which way it blows up depends on the sign',
      'A tiny positive bottom sends it up. A tiny negative bottom sends it '
          'down. And the sign can be different on the two sides of the point.',
    ),
    (
      'Both sides up: that is the limit',
      'Left branch and right branch both shoot to the sky, so the answer is '
          'plus infinity.',
    ),
    (
      'One up and one down: no limit',
      'The two sides disagree, so there is no single value to approach. The '
          'answer is that the limit does not exist, NOT that it is infinite.',
    ),
  ],
  spoken: [
    (
      'Sides agree',
      r'\lim_{x \to 0}\frac{1}{x^2} = +\infty',
      'both branches go up, so plus infinity',
    ),
    (
      'Sides disagree',
      r'\lim_{x \to 0}\frac{1}{x} \;\Rightarrow\; \text{does not exist}',
      'one branch up and one down, so there is no limit',
    ),
  ],
  handbook: 'Handbook p. 48',
);

// ── Vector Basics & Unit Vectors ────────────────────────────────────────────

const vectorAddBrief = BriefSection(
  title: 'Adding arrows, one direction at a time',
  picture: vectorAddPicture,
  steps: [
    (
      'Lay them head to tail',
      'Put the start of the second arrow on the tip of the first. The answer '
          'is the arrow from where you began to where you ended up.',
    ),
    (
      'In numbers, add the parts separately',
      'All the across parts together, all the up parts together, signs kept. '
          'Never add the lengths.',
    ),
    (
      'Why lengths do not add',
      'Two pulls of 500 only make 1000 if they point the same way. Point them '
          'at each other and they make nothing at all. The direction is doing '
          'half the work.',
    ),
  ],
  spoken: [
    (
      'Component form',
      r'\vec{A} = A_x\hat{i} + A_y\hat{j} + A_z\hat{k}',
      'so much across, so much up, so much out',
    ),
    (
      'Added component by component',
      r'\vec{A} + \vec{B} = (A_x + B_x)\hat{i} + (A_y + B_y)\hat{j}',
      'across with across, up with up',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const unitVectorBrief = BriefSection(
  title: 'Direction without size',
  picture: unitVectorPicture,
  steps: [
    (
      'An arrow exactly one long',
      'A unit vector points where you want and has a length of exactly 1. '
          'It carries a direction and nothing else.',
    ),
    (
      'Make one by dividing',
      'Take any arrow and divide it by its own length. Everything about the '
          'direction survives; only the size is scaled away.',
    ),
    (
      'Then size it to whatever you need',
      'A force of 200 along that line is just 200 times the unit vector, and '
          'every component falls straight out.',
    ),
    (
      'A negative turns it around',
      'Multiplying by a negative number keeps the same line and points the '
          'arrow the other way.',
    ),
  ],
  spoken: [
    (
      'Divide by its own length',
      r'\hat{u}_A = \frac{\vec{A}}{|\vec{A}|}',
      'the arrow, over how long it is',
    ),
    ('Then size it', r'\vec{F} = F\,\hat{u}', 'how big, times which way'),
    (
      'From one point to another',
      r'\vec{AB} = B - A',
      'the far end take away the near end',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const magnitudeBrief = BriefSection(
  title: 'A length is not a component',
  picture: magnitudePicture,
  steps: [
    (
      'The arrow is the long side of a triangle',
      'Go 3 across and 4 up. The arrow joining start to finish is the '
          'hypotenuse of that right triangle, so its length is 5, not 7.',
    ),
    (
      'Square, add, then root',
      'That is Pythagoras, and it works the same way with a third direction '
          'added on.',
    ),
    (
      'A component is only a shadow',
      'It is how far the arrow got along ONE axis. It is allowed to be '
          'negative, because you can go backwards along an axis.',
    ),
    (
      'A length never is',
      'How far something reached cannot be a negative number. If a length '
          'comes out negative, something upstream is wrong.',
    ),
  ],
  spoken: [
    (
      'Length',
      r'|\vec{A}| = \sqrt{A_x^2 + A_y^2 + A_z^2}',
      'square each part, add them, take the root',
    ),
    (
      'Worth knowing on sight',
      r'3, 4, 5 \quad 6, 8, 10',
      'two triangles that come up again and again',
    ),
  ],
  handbook: 'Handbook p. 94',
);

// ── Dot Product & Angle Between Vectors ─────────────────────────────────────

const dotProductBrief = BriefSection(
  title: 'Matching components, and a number at the end',
  picture: dotProductPicture,
  steps: [
    (
      'Pair each part with its own partner',
      'Across with across, up with up, signs kept. Never across with up: '
          'that is the other product wearing the wrong name.',
    ),
    (
      'Multiply the pairs, then add',
      'Two multiplications and one addition in two dimensions, three and two '
          'in three. That is the whole calculation.',
    ),
    (
      'What comes out is a plain number',
      'No direction, no arrow, no letters. If your answer still has an i or '
          'a j in it, you did the cross product instead.',
    ),
  ],
  spoken: [
    (
      'Component form',
      r'\vec{A} \cdot \vec{B} = A_xB_x + A_yB_y + A_zB_z',
      'multiply the matching parts and add them up',
    ),
    (
      'And it is a scalar',
      r'\vec{A} \cdot \vec{B} \in \mathbb{R}',
      'the answer is a plain number, with no direction',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const dotAngleBrief = BriefSection(
  title: 'The sign is the angle',
  picture: dotAnglePicture,
  steps: [
    (
      'The same number, told another way',
      'The dot product also equals the two lengths multiplied together, '
          'times the cosine of the angle between the arrows.',
    ),
    (
      'Lengths are always positive',
      'So the only thing in that product that can be negative is the cosine. '
          'The sign of a dot product IS the sign of the cosine.',
    ),
    (
      'Which reads the angle straight off',
      'Positive means the arrows are closing, under a square corner. '
          'Negative means they are opening, past it. Zero means exactly square.',
    ),
    (
      'That zero is the quickest test there is',
      'For the angle itself, rearrange and take the inverse cosine. And '
          'remember the cosine is not the angle.',
    ),
  ],
  spoken: [
    (
      'Angle form',
      r'\vec{A} \cdot \vec{B} = |\vec{A}||\vec{B}|\cos\theta',
      'the two lengths, times the cosine of the angle between',
    ),
    (
      'Rearranged for the angle',
      r'\theta = \cos^{-1}\!\left(\frac{\vec{A} \cdot \vec{B}}{|\vec{A}||\vec{B}|}\right)',
      'divide by both lengths, then undo the cosine',
    ),
    (
      'Square on',
      r'\vec{A} \cdot \vec{B} = 0',
      'zero means the two are at a square corner',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const projectionBrief = BriefSection(
  title: 'How much of a force lands on a member',
  picture: projectionPicture,
  steps: [
    (
      'Think of a shadow',
      'Shine a light straight down onto the member. The shadow the force '
          'casts along it is how much of that force the member actually feels.',
    ),
    (
      'Dot product, then divide by the MEMBER',
      'The dot product gives the shadow multiplied by the member length. '
          'Divide by the member length to get the shadow on its own.',
    ),
    (
      'Dividing by the wrong one breaks it',
      'Not dividing leaves you something that is not a force. Dividing by '
          'the force gives a number that has forgotten what it measured.',
    ),
    (
      'The sign still means something',
      'Negative means the force runs back along the member instead of out '
          'along it.',
    ),
  ],
  spoken: [
    (
      'Scalar projection',
      r'\text{proj}_{\vec{B}}\vec{A} = \frac{\vec{A} \cdot \vec{B}}{|\vec{B}|}',
      'the dot product, over the length of the direction',
    ),
    (
      'Which is just',
      r'\vec{A} \cdot \hat{u}_B',
      'the force dotted with the unit arrow along the member',
    ),
  ],
  handbook: 'Handbook p. 94',
);

// ── Cross Product & Applications ────────────────────────────────────────────

const rightHandBrief = BriefSection(
  title: 'Which way it turns, and why order matters',
  picture: rightHandPicture,
  steps: [
    (
      'This one gives back an arrow',
      'Unlike the dot product, a cross product IS a vector. It points square '
          'to both of the arrows that made it.',
    ),
    (
      'Your right hand picks which way',
      'Fingers along the first arrow, curl them toward the second, and your '
          'thumb points the answer. Sweeping anticlockwise brings it out of the '
          'page; clockwise sends it in.',
    ),
    (
      'So the order is not a detail',
      'Swap the two arrows and the answer flips over completely. That is why '
          'a moment is r cross F, in that order, and never the other way.',
    ),
    (
      'Two arrows on one line give nothing',
      'There is no turn to measure, so the answer is zero.',
    ),
  ],
  spoken: [
    (
      'The moment of a force',
      r'\vec{M}_O = \vec{r} \times \vec{F}',
      'the arm crossed into the force, that way round',
    ),
    (
      'Order flips it',
      r'\vec{A} \times \vec{B} = -(\vec{B} \times \vec{A})',
      'swapping them turns the answer round',
    ),
    (
      'And a vector with itself',
      r'\vec{A} \times \vec{A} = \vec{0}',
      'no turn at all, so nothing',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const areaBrief = BriefSection(
  title: 'The parallelogram, and half of it',
  picture: areaPicture,
  steps: [
    (
      'The size of a cross product is an area',
      'Take the two arrows as two edges and slide them into a leaning box. '
          'The cross product gives exactly that area.',
    ),
    (
      'A triangle is half of it',
      'A plot of land bounded by those same two edges is the other half cut '
          'off. So it takes a divide by two the formula will not remind you '
          'about.',
    ),
    (
      'The sine accounts for the lean',
      'Just multiplying the two lengths would give the upright box round the '
          'whole thing. That is only right when the edges meet at a square '
          'corner.',
    ),
  ],
  spoken: [
    (
      'Parallelogram',
      r'|\vec{A} \times \vec{B}| = |\vec{A}||\vec{B}|\sin\theta',
      'the two lengths, times the sine of the angle between',
    ),
    ('Triangle', r'\tfrac{1}{2}|\vec{A} \times \vec{B}|', 'half of that area'),
  ],
  handbook: 'Handbook p. 94',
);

const cofactorBrief = BriefSection(
  title: 'Plus, minus, plus',
  picture: cofactorPicture,
  steps: [
    (
      'Cover one column at a time',
      'Write the grid: i, j and k across the top, then each arrow on its own '
          'row. Cover the i column and two columns are left over. Those two '
          'make the i term. Do the same for j and for k.',
    ),
    (
      'The middle one had to jump a gap',
      'Look at what survives each time. Covering i leaves columns 2 and 3, '
          'side by side. Covering k leaves 1 and 2, side by side. Covering j '
          'leaves 1 and 3, with a column jumped between them.',
    ),
    (
      'That jump is what the minus pays for',
      'The j term is the only one out of step, so it is the only one taken '
          'away. Plus, minus, plus. Get it backwards and the moment points the '
          'wrong way.',
    ),
    (
      'The answer is still a vector',
      'If the question asked for a size, take the magnitude afterwards.',
    ),
  ],
  spoken: [
    (
      'Cover a column, keep the rest',
      r'\hat{i}: (A_yB_z - A_zB_y)',
      'cover the i column and the two that are left make this piece',
    ),
    (
      'Expanded',
      r'(A_yB_z - A_zB_y)\hat{i} - (A_xB_z - A_zB_x)\hat{j} + (A_xB_y - A_yB_x)\hat{k}',
      'plus, then minus, then plus',
    ),
  ],
  handbook: 'Handbook p. 94',
);

// ── Spreadsheet Computations ────────────────────────────────────────────────

const referencesBrief = BriefSection(
  title: 'What moves when you copy',
  picture: referencesPicture,
  steps: [
    (
      'A plain reference slides',
      'Write B1 in a cell and copy the formula one row down. It quietly '
          'becomes B2. Copy it across and it becomes C1. It shifts by however '
          'far you moved it.',
    ),
    (
      'A dollar sign nails it down',
      'Whatever comes straight after a dollar sign cannot move. So B\$1 '
          'always points at row 1, and \$B1 always points at column B.',
    ),
    (
      'Two dollar signs pin it completely',
      'A fixed number, like an interest rate in one cell, wants both.',
    ),
    (
      'The mistake it causes',
      'A missing dollar sign lets the rate drift down the column. The first '
          'row is right and every row under it is quietly wrong.',
    ),
  ],
  spoken: [
    ('Moves with the copy', r'\text{A1}', 'slides in both directions'),
    ('Pinned completely', r'\text{\$A\$1}', 'never moves at all'),
    ('Row pinned, column free', r'\text{A\$1}', 'slides across, never down'),
    ('Column pinned, row free', r'\text{\$A1}', 'slides down, never across'),
  ],
  handbook: 'FE Handbook, spreadsheet section',
);

const precedenceBrief = BriefSection(
  title: 'A sheet does not read left to right',
  picture: precedencePicture,
  steps: [
    (
      'There is an order, and it is not reading order',
      'Brackets first. Then powers. Then multiply and divide. Then add and '
          'subtract. Anything of equal rank runs left to right.',
    ),
    (
      'So the times jumps the queue',
      'Two plus three times four is 14, not 20, however it reads on the '
          'page. The multiply happens before the add.',
    ),
    (
      'Brackets are the only override',
      'Put the add in brackets and it goes first. Nothing else changes the '
          'order.',
    ),
  ],
  spoken: [
    (
      'Times before plus',
      r'\text{=2+3*4} \;\Rightarrow\; 14',
      'three fours are twelve, then add two',
    ),
    (
      'Brackets force it',
      r'\text{=(2+3)*4} \;\Rightarrow\; 20',
      'five, then four fives',
    ),
  ],
  handbook: 'FE Handbook, spreadsheet section',
);

const functionsBrief = BriefSection(
  title: 'What the common functions hand back',
  picture: functionsPicture,
  steps: [
    (
      'The simple ones do what they say',
      'SUM adds a range up. AVERAGE takes its mean. MAX and MIN pull the '
          'biggest and the smallest out of it.',
    ),
    (
      'COUNT only counts numbers',
      'Look at the picture: five cells, but two of them hold words. COUNT '
          'sees three. Text inside the range is skipped in silence.',
    ),
    (
      'A colon means everything between',
      'B1 colon B3 is B1, B2 and B3, not just the two ends.',
    ),
    (
      'IF hands back a value, not a true',
      'It checks the test, then gives you the second thing when the test '
          'passes and the third when it fails. It never returns a 1.',
    ),
  ],
  spoken: [
    ('A range', r'\text{=SUM(B1:B3)}', 'add up every cell from B1 to B3'),
    (
      'Test, then true, then false',
      r'\text{=IF(A1>=10, A1*2, A1+5)}',
      'if the test passes give the middle one, otherwise the last one',
    ),
  ],
  handbook: 'FE Handbook, spreadsheet section',
);

// ── Structured Programming ──────────────────────────────────────────────────

const tracingBrief = BriefSection(
  title: 'Trace it, one row per pass',
  picture: tracingPicture,
  steps: [
    (
      'Only three things ever happen',
      'Steps in order, a choice between paths, and a repeat. Every routine '
          'on this exam is built out of those three.',
    ),
    (
      'Write a table, not a guess',
      'Put the variables in columns and fill in one row for every pass. '
          'Trying to hold the whole loop in your head is where it goes wrong.',
    ),
    (
      'A counted loop includes both ends',
      'FOR i = 1 TO 4 runs FOUR times, not three. Both ends are in.',
    ),
    (
      'The answer is the last row',
      'It is almost never the number of rows. Look at what the variable '
          'holds at the end, not at how many times you went round.',
    ),
  ],
  spoken: [
    (
      'Runs four times',
      r'\text{FOR i = 1 TO 4}',
      'one, two, three, four: both ends counted',
    ),
    (
      'The rows it makes',
      r'1,\; 3,\; 6,\; 10',
      'the running total after each pass',
    ),
  ],
  handbook: 'FE Handbook, computational tools',
);

const selectionBrief = BriefSection(
  title: 'The first true condition wins',
  picture: selectionPicture,
  steps: [
    (
      'Checked from the top down',
      'The machine tries each test in order and stops dead at the first one '
          'that holds. Everything below is skipped.',
    ),
    (
      'Even a later test that is also true',
      'A chain is not a search for the best match. Look at the picture: x '
          'is 7, which passes two of the tests, and only the first one runs.',
    ),
    (
      'ELSE is the catch-all',
      'It only runs when every test above it has failed. Reading the whole '
          'chain first and picking the best fit is how people land here by '
          'mistake.',
    ),
    (
      'Watch the boundary',
      'Greater than leaves the number itself out. Greater than or equal to '
          'takes it in.',
    ),
  ],
  spoken: [
    (
      'Checked in this order',
      r'\text{IF} \to \text{ELSE IF} \to \text{ELSE}',
      'top to bottom, stopping at the first one that holds',
    ),
    (
      'x = 7 lands here',
      r'\text{ELSE IF x > 5} \;\Rightarrow\; \text{y = 2}',
      'the first test it passes, and no other',
    ),
  ],
  handbook: 'FE Handbook, computational tools',
);

const iterationBrief = BriefSection(
  title: 'A WHILE checks before it acts',
  picture: iterationPicture,
  steps: [
    (
      'The test comes first, every time',
      'Including the very first pass. If the condition is already false when '
          'the loop is reached, the body never runs at all.',
    ),
    (
      'So the value left behind broke the test',
      'Doubling while under 100 does not stop at 64. It doubles to 128, the '
          'test fails, and 128 is what is left in the variable.',
    ),
    (
      'Nothing is capped at the limit',
      'The number in the condition is a gate to pass through, not a ceiling '
          'to stop at.',
    ),
  ],
  spoken: [
    (
      'Doubling from 1 while under 100',
      r'1,\;2,\;4,\;8,\;16,\;32,\;64,\;128',
      'each pass doubles, and the last one goes over',
    ),
    (
      'What is left',
      r'x = 128',
      'the value that failed the test, not the last one that passed',
    ),
  ],
  handbook: 'FE Handbook, computational tools',
);

// ── Numerical Methods: Root-Finding ─────────────────────────────────────────

const newtonBrief = BriefSection(
  title: 'Slide down the tangent',
  picture: newtonPicture,
  steps: [
    (
      'It is a picture before it is a formula',
      'Stand on the curve at your guess. Follow the straight line that just '
          'touches it there, all the way down to the axis. Stand at that new '
          'spot and do it again.',
    ),
    (
      'That slide is what the formula does',
      'Dividing the function by its slope is exactly how far along the '
          'tangent takes you.',
    ),
    (
      'Why it closes in so fast',
      'Zoom in near a root and any smooth curve looks almost straight, so '
          'the tangent lands very close to the truth.',
    ),
    (
      'And why a flat slope ruins it',
      'A nearly flat tangent runs a very long way before it meets the axis, '
          'and you land somewhere useless.',
    ),
  ],
  spoken: [
    (
      'One iteration',
      r"x_{j+1} = x_j - \frac{f(x_j)}{f'(x_j)}",
      'your guess, minus the height divided by the slope',
    ),
    (
      'From 4 on x squared minus 4',
      r'4 - \frac{12}{8} = 2.5',
      'height twelve, slope eight, so slide back one and a half',
    ),
  ],
  handbook: 'Handbook p. 61',
);

const bisectionBrief = BriefSection(
  title: 'Opposite sides, then halve it',
  picture: bisectionPicture,
  steps: [
    (
      'It asks for one thing only',
      'The curve below the axis at one end of your interval and above it at '
          'the other. Then it has to cross somewhere in between.',
    ),
    (
      'The test is a multiplication',
      'Multiply the two end values. A negative answer means one was positive '
          'and one negative, which is exactly the sign change you need.',
    ),
    (
      'Then cut it in half, over and over',
      'Check the middle, keep whichever half still has the sign change, '
          'repeat. The gap halves every time.',
    ),
    (
      'Same signs does not mean no root',
      'It means this method cannot be STARTED there, which is a different '
          'thing. An interval holding two roots fails the test for that reason.',
    ),
  ],
  spoken: [
    (
      'The whole requirement',
      r'f(a)\cdot f(b) < 0',
      'the two end values multiply to something negative',
    ),
    (
      'Then keep the half that still has it',
      r'[a, m] \text{ or } [m, b]',
      'whichever side of the middle still changes sign',
    ),
  ],
  handbook: 'Handbook p. 61',
);

const methodChoiceBrief = BriefSection(
  title: 'Fast, or guaranteed',
  picture: methodChoicePicture,
  steps: [
    (
      'Newton is fast and fussy',
      'It wants the slope AND a guess that is already near the root. Give it '
          'a poor guess or a nearly flat slope and it can wander off or swing '
          'back and forth without ever settling.',
    ),
    (
      'Bisection is slow and reliable',
      'No slope needed and no good guess needed. Just two ends with opposite '
          'signs. Once it has that, it cannot fail.',
    ),
    (
      'So the question is what you have',
      'Not which method is cleverer. Read what the problem hands you and '
          'pick the one whose requirements are met.',
    ),
  ],
  spoken: [
    (
      'Newton wants',
      r"f'(x) \text{ and a close } x_0",
      'the slope, and a starting guess near the answer',
    ),
    (
      'Bisection wants',
      r'f(a)\cdot f(b) < 0',
      'only two ends on opposite sides of the axis',
    ),
  ],
  handbook: 'Handbook p. 61',
);

// ── Measures of Central Tendency & Dispersion ───────────────────────────────

const centerBrief = BriefSection(
  title: 'Three ways to say where the middle is',
  picture: centerPicture,
  steps: [
    (
      'Line them up',
      'Take some readings and stack them over their values, smallest on '
          'the left. Most of the picture is right there.',
    ),
    (
      'The median is a position',
      'Count in from both ends until you meet in the middle. That reading is '
          'the median. With an even count, average the middle two. One far-off '
          'reading cannot move it, because it is still just the middle one.',
    ),
    (
      'The mean is a total',
      'Add every reading and divide by how many there are. A reading far out '
          'to one side drags the mean toward it, because it is in the total.',
    ),
    (
      'The mode is the tallest stack',
      'Whatever value shows up most often. A set can have no mode, or more '
          'than one. On tidy data all three agree; one wild reading splits them.',
    ),
  ],
  spoken: [
    (
      'Mean',
      r'\bar{x} = \frac{1}{n}\sum x_i',
      'add them all up, divide by the count',
    ),
    (
      'Median',
      r'\text{the middle value, once sorted}',
      'the one in the middle of the line',
    ),
  ],
  handbook: 'Handbook p. 63',
);

const spreadBrief = BriefSection(
  title: 'Sample or population, and the square root',
  picture: spreadPicture,
  steps: [
    (
      'How spread out are they',
      'Two sets can have the same middle and look nothing alike, one bunched '
          'tight and one scattered wide. The variance measures that: the average '
          'squared distance from the mean.',
    ),
    (
      'Back to real units',
      'Squaring turns meters into square meters. The standard deviation is '
          'the square root of the variance, so it is back in the units of the '
          'data. That is the number people quote.',
    ),
    (
      'Divide by n minus one',
      'If your readings are a sample of something bigger, which on this exam '
          'they almost always are, divide by one less than the count. That is '
          'Sx on the calculator. Sigma x, two lines down, divides by n and is '
          'for a whole population.',
    ),
    (
      'Comparing spreads in different units',
      'Divide the standard deviation by the mean. That ratio has no units, '
          'so a spread in psi can be compared with a spread in days.',
    ),
  ],
  spoken: [
    (
      'Sample variance',
      r's^2 = \frac{\sum (x_i - \bar{x})^2}{n-1}',
      'the squared gaps from the mean, added, over n minus one',
    ),
    (
      'Population variance',
      r'\sigma^2 = \frac{\sum (x_i - \mu)^2}{N}',
      'the same, over the whole count',
    ),
    (
      'Coefficient of variation',
      r'CV = \frac{s}{\bar{x}}',
      'the spread as a share of the mean',
    ),
  ],
  handbook: 'Handbook p. 63',
);

const weightedBrief = BriefSection(
  title: 'Some readings count for more',
  picture: weightedPicture,
  steps: [
    (
      'Not every row is equal',
      'Three batches of concrete were tested. One batch had two cylinders, '
          'one had four, one had ten. Averaging the three batch strengths as if '
          'they were equal lets two cylinders speak as loudly as ten.',
    ),
    (
      'Give each reading a weight',
      'Multiply each strength by how many cylinders stood behind it, add '
          'those up, and divide by the total number of cylinders. The big batch '
          'now pulls the answer toward itself, as it should.',
    ),
    (
      'Name the two roles first',
      'What is being averaged goes in as x. How much each row gets to say '
          'goes in as the weight: how long a count ran, how many were tested, '
          'how thick a layer is. Swap them and the arithmetic runs perfectly to '
          'the wrong answer.',
    ),
  ],
  spoken: [
    (
      'Weighted mean',
      r'\bar{x}_w = \frac{\sum w_i x_i}{\sum w_i}',
      'each value times its weight, added, over the weights added',
    ),
  ],
  handbook: 'Handbook p. 63',
);

const correlationBrief = BriefSection(
  title: 'What r is telling you',
  picture: correlationPicture,
  steps: [
    (
      'Look at the cloud',
      'Plot pairs of readings as dots. If the dots rise together they lean '
          'one way; if one goes up while the other goes down they lean the '
          'other. If they hug a straight line, the cloud is tight.',
    ),
    (
      'r is that lean and that tightness',
      'r runs from minus one to plus one. Its sign is the direction of the '
          'lean. Its size is how tightly the dots hug a line: near one is tight, '
          'near zero is a shapeless cloud.',
    ),
    (
      'Only straight lines',
      'r only measures agreement with a STRAIGHT line. A cloud that rises '
          'and then falls has an obvious shape and an r of about nothing. So r '
          'near zero does not mean no relationship. It means no straight one.',
    ),
  ],
  spoken: [
    (
      'The range it lives in',
      r'-1 \le r \le +1',
      'from minus one, a perfect fall, to plus one, a perfect rise',
    ),
    (
      'A perfect rise, and a perfect fall',
      r'r = +1 \;\text{or}\; r = -1',
      'every dot exactly on one straight line',
    ),
    (
      'No straight line at all',
      r'r \approx 0',
      'either a shapeless cloud, or a shape that is not straight',
    ),
  ],
  handbook: 'Handbook p. 69',
);

const regressionLineBrief = BriefSection(
  title: 'The best line goes through the means',
  picture: regressionLinePicture,
  steps: [
    (
      'Draw the best straight line',
      'Through a cloud of dots you can draw one straight line that misses '
          'them all by the least. That is the regression line, and it lets you '
          'predict y from an x you never measured.',
    ),
    (
      'It always passes through one point',
      'Take the mean of all the x values and the mean of all the y values. '
          'Put a dot there. The best line goes through that dot, every time.',
    ),
    (
      'That is where the intercept comes from',
      'A line is a slope plus a starting height. Knowing the slope and one '
          'point on the line gives you the starting height: the mean of y, less '
          'the slope times the mean of x.',
    ),
    (
      'Slope alone is not a prediction',
      'Slope times x with nothing added is a line through the origin. It '
          'leans the right way in the wrong place. A prediction needs both '
          'parts.',
    ),
  ],
  spoken: [
    (
      'The line',
      r'\hat{y} = a + bx',
      'a starting height, plus the slope times x',
    ),
    (
      'The intercept',
      r'a = \bar{y} - b\bar{x}',
      'the mean of y, less the slope times the mean of x',
    ),
    (
      'Slope',
      r'b = \frac{n\sum x_i y_i - \sum x_i \sum y_i}{n\sum x_i^2 - (\sum x_i)^2}',
      'sums from the data. The calculator does this one',
    ),
  ],
  handbook: 'Handbook p. 69',
);

const determinationBrief = BriefSection(
  title: 'Correlation, or determination',
  picture: determinationPicture,
  steps: [
    (
      'Two numbers from one cloud',
      'r is the correlation: which way the cloud leans and how tightly. r '
          'squared is the coefficient of determination: the share of the ups '
          'and downs in y that x accounts for.',
    ),
    (
      'Squaring drops the sign',
      'r can be negative; r squared never is. An r of minus 0.92 means a '
          'tight downward lean, and an r squared of 0.85 means x explains 85 '
          'percent of what y does. The other 15 percent is something else.',
    ),
    (
      'Hear which one was asked',
      'The exam asks in English. "Correlation" wants r, with its sign. '
          '"Coefficient of determination" or "share explained" wants r squared. '
          'A negative coefficient of determination is not wrong, it is '
          'impossible.',
    ),
  ],
  spoken: [
    ('Determination', r'R^2 = r^2', 'the correlation, squared'),
    (
      'So',
      r'r = -0.92 \;\Rightarrow\; R^2 = 0.846',
      'minus 0.92 squared is 0.85, and the minus is gone',
    ),
    ('What is left unexplained', r'1 - R^2', 'one minus the share explained'),
  ],
  handbook: 'Handbook p. 69',
);

const countingBrief = BriefSection(
  title: 'Does the order count, or just the group',
  picture: countingPicture,
  steps: [
    (
      'Pick three from a pool',
      'Say three letters from A, B and C. You could pick them as ABC, or '
          'ACB, or BAC, and so on. Six ways. But every one of those is the same '
          'three letters.',
    ),
    (
      'When order matters',
      'If the first pick gets a different job from the second, a rank, a '
          'position, a place in a sequence, then ABC and BAC are different '
          'results. That count is a permutation, and it is the bigger number.',
    ),
    (
      'When it does not',
      'If all three picks get treated the same, the six orderings are one '
          'group. That count is a combination. It is the permutation count '
          'divided by the number of ways to order the picks, which is r '
          'factorial.',
    ),
  ],
  spoken: [
    (
      'Order matters',
      r'P(n, r) = \frac{n!}{(n-r)!}',
      'n factorial over the factorial of what is left',
    ),
    (
      'Order does not',
      r'C(n, r) = \frac{n!}{r!\,(n-r)!}',
      'the same, divided once more by r factorial',
    ),
    (
      'So',
      r'P(8,3) = 336 \;\Rightarrow\; C(8,3) = \frac{336}{3!} = 56',
      'three picks can be ordered six ways, so divide by six',
    ),
  ],
  handbook: 'Handbook p. 64',
);

const binomialBrief = BriefSection(
  title: 'Three factors, every time',
  picture: binomialPicture,
  steps: [
    (
      'A fixed number of yes-or-no tries',
      'Ten pours, each one either passes or fails, and none of them affects '
          'the others. Ask how likely it is that exactly three fail. That is a '
          'binomial question.',
    ),
    (
      'Multiply three things',
      'How many ways the three failures could be spread across the ten '
          'tries. Times the chance of a failure, three times over. Times the '
          'chance of a pass, seven times over. Three factors, always.',
    ),
    (
      'The count in front is a combination',
      'Three failures out of ten is three failures whichever three they '
          'were, so order does not matter. Use C, not P.',
    ),
    (
      'Two cheap checks',
      'The two exponents must add up to the number of tries. And whichever '
          'outcome you call the success has to be the one x is counting.',
    ),
  ],
  spoken: [
    (
      'The distribution',
      r'P(X = x) = C(n, x)\,p^x(1-p)^{n-x}',
      'ways to arrange, times p for each success, times one minus p for each failure',
    ),
    (
      'Variance',
      r'\sigma^2 = npq',
      'tries, times the chance of a success, times the chance of a failure',
    ),
  ],
  handbook: 'Handbook p. 66',
);

const normalTableBrief = BriefSection(
  title: 'Which piece of the curve was asked for',
  picture: normalTablePicture,
  steps: [
    (
      'Turn the number into a z',
      'A normal curve is a bell. Any bell can be turned into the one the '
          'handbook has a table for: subtract the mean and divide by the '
          'standard deviation. That is the z-score, how many spreads from the '
          'middle you are.',
    ),
    (
      'The table has three columns',
      'F is everything to the left of your cut. R is everything to the '
          'right. W is the band between minus z and plus z. Pick the column '
          'that matches the piece you shaded.',
    ),
    (
      'Negative z: flip it',
      'The table only runs on positive z. The area left of a negative cut '
          'is one minus the area left of the same positive cut, because the '
          'bell is symmetric.',
    ),
    (
      'Fail rate and pass rate are the same line',
      'How many fall below 4,000 psi and how many pass are the two halves '
          'of one picture. Decide which piece the sentence asked for before '
          'you open the table.',
    ),
  ],
  spoken: [
    (
      'Z-score',
      r'z = \frac{x - \mu}{\sigma}',
      'the value less the mean, over the standard deviation',
    ),
    (
      'The flip',
      r'F(-z) = 1 - F(z)',
      'the area left of minus z is one minus the area left of z',
    ),
    (
      'The other tail',
      r'R(z) = 1 - F(z)',
      'right of the cut is one minus left of it',
    ),
  ],
  handbook: 'Handbook p. 67',
);

const expectedValueBrief = BriefSection(
  title: 'A balance point, not a favorite',
  picture: expectedValuePicture,
  steps: [
    (
      'Load the outcomes onto a beam',
      'Each possible outcome is a block placed at its value. How likely it '
          'is sets how heavy the block is. Now find where a fulcrum would hold '
          'the beam level.',
    ),
    (
      'That point is the expected value',
      'It is an average where the weights are the probabilities. Multiply '
          'each outcome by its chance and add. Over many repeats, that is what '
          'you get per go.',
    ),
    (
      'The two usual mistakes tip the beam',
      'The most likely outcome is the tallest block, not the balance point: '
          'a heavy block further out still wins. And the plain middle of the '
          'range throws the weights away entirely.',
    ),
    (
      'It may be a value that never happens',
      'A balance point can sit between blocks. An expected 8.4 trucks is a '
          'fine answer even though no day ever has 8.4 trucks.',
    ),
  ],
  spoken: [
    (
      'Expected value',
      r'E(X) = \sum x_k \cdot P(x_k)',
      'each outcome times its chance, all added up',
    ),
    (
      'So',
      r'120(0.25) + 80(0.50) + 20(0.25) = 75',
      'three outcomes, three chances, one balance point',
    ),
  ],
  handbook: 'Handbook p. 65',
);

const varianceShortcutBrief = BriefSection(
  title: 'The mean of the squares, less the square of the mean',
  picture: varianceShortcutPicture,
  steps: [
    (
      'Two columns of scratch work',
      'For each outcome, write its value times its chance in one column, '
          'and its value squared times its chance in the other. Total both '
          'columns.',
    ),
    (
      'One subtraction',
      'The first total is the mean. Square it. Take that away from the '
          'second total. What is left is the variance.',
    ),
    (
      'The order is the whole trap',
      'The mean of the squares and the square of the mean are written '
          'almost the same and are different numbers. Subtract them the wrong '
          'way round and you get a negative variance, which cannot happen. '
          'That sign is your alarm.',
    ),
  ],
  spoken: [
    (
      'Variance',
      r'\text{Var}(X) = E(X^2) - [E(X)]^2',
      'the mean of the squares, less the square of the mean',
    ),
    (
      'The two columns',
      r'E(X) = \sum x P(x), \quad E(X^2) = \sum x^2 P(x)',
      'value times chance, and value squared times chance',
    ),
    (
      'So',
      r'8.10 - (2.70)^2 = 8.10 - 7.29 = 0.81',
      'second total, less the first total squared',
    ),
  ],
  handbook: 'Handbook p. 65',
);

const combiningBrief = BriefSection(
  title: 'Variances add, spreads do not',
  picture: combiningPicture,
  steps: [
    (
      'Two uncertain loads on one beam',
      'One load wobbles by about 3 kN, the other by about 8 kN. How much '
          'does their total wobble? Not 11. The two rarely wobble the same way '
          'at the same moment.',
    ),
    (
      'Draw them as a right triangle',
      'Put 3 along one leg and 8 up the other. The total spread is the '
          'slanted side, and a slanted side is always shorter than walking '
          'round the two legs. Here it is 8.54.',
    ),
    (
      'So square, add, then root',
      'Variances add: 9 plus 64 is 73. The spread is the square root, 8.54. '
          'Standard deviations never add on their own. Any number multiplying a '
          'variable gets squared on the way in.',
    ),
    (
      'Means just add',
      'The average of a total is the totals of the averages, always, even '
          'when the two are not independent. Only the variances need '
          'independence to add.',
    ),
  ],
  spoken: [
    (
      'Means',
      r'E(a_1X_1 + a_2X_2) = a_1E(X_1) + a_2E(X_2)',
      'means add straight, with their multipliers',
    ),
    (
      'Variances',
      r'\text{Var}(a_1X_1 + a_2X_2) = a_1^2\sigma_1^2 + a_2^2\sigma_2^2',
      'variances add, and each multiplier is squared',
    ),
    (
      'So',
      r'\sigma_T = \sqrt{3^2 + 8^2} = \sqrt{73} = 8.54',
      'square each spread, add, take the root',
    ),
  ],
  handbook: 'Handbook p. 65',
);

const marginOfErrorBrief = BriefSection(
  title: 'What sets the width of the interval',
  picture: marginOfErrorPicture,
  steps: [
    (
      'A guess with a margin',
      'You measured 25 samples and got a mean of 42. The true mean is '
          'probably near 42, but not exactly. A confidence interval is 42 plus '
          'or minus a margin, wide enough to catch the truth most of the time.',
    ),
    (
      'The margin has three parts',
      'A multiplier for how sure you want to be. The spread of the '
          'readings, sigma. And the ROOT of how many you took. More samples '
          'narrow it, but slowly: four times the samples for half the width.',
    ),
    (
      'The root is the part people drop',
      'Divide by n instead of the root of n and the interval collapses to a '
          'sliver. It claims a precision 25 samples cannot buy. If your margin '
          'looks tiny, check the root.',
    ),
  ],
  spoken: [
    (
      'Sigma known',
      r'\bar{x} \pm z_{\alpha/2}\frac{\sigma}{\sqrt{n}}',
      'the sample mean, plus or minus the multiplier times sigma over root n',
    ),
    (
      'The three multipliers',
      r'90\% : 1.645 \quad 95\% : 1.960 \quad 99\% : 2.576',
      'surer means a bigger multiplier and a wider interval',
    ),
    (
      'So',
      r'42 \pm 1.960\frac{5}{\sqrt{25}} = 42 \pm 1.96',
      '25 samples, root 5, a margin of about 2',
    ),
  ],
  handbook: 'Handbook p. 74',
);

const zOrTBrief = BriefSection(
  title: 'Sigma or s, and which way the width moves',
  picture: zOrTPicture,
  steps: [
    (
      'Where did the spread come from',
      'If the problem hands you sigma, the spread of the whole population, '
          'use the z multiplier. If it hands you s, a spread you worked out '
          'from your own few samples, use t.',
    ),
    (
      't is always wider',
      'With s, the spread itself is a guess, and the interval has to pay '
          'for that. So t at the same confidence is a bigger multiplier than z, '
          'and the difference shrinks as you take more samples. t uses n minus '
          'one degrees of freedom.',
    ),
    (
      'What moves the width',
      'Three things: the confidence you ask for, the spread, and how many '
          'samples. The sample mean is not one of them. It slides the interval '
          'along; it does not stretch it.',
    ),
  ],
  spoken: [
    (
      'Sigma unknown',
      r'\bar{x} \pm t_{\alpha/2,\,n-1}\frac{s}{\sqrt{n}}',
      'the same shape, with t for z and s for sigma, on n minus one degrees of freedom',
    ),
    (
      'Ten samples, 95%',
      r'z = 1.960 \;\Rightarrow\; t_{0.025,\,9} = 2.262',
      'the t multiplier is bigger, so the interval is wider',
    ),
  ],
  handbook: 'Handbook p. 74',
);

const sampleSizeBrief = BriefSection(
  title: 'Working backwards to how many samples',
  picture: sampleSizePicture,
  steps: [
    (
      'Fix the margin first',
      'Sometimes the margin is decided before any data: the count has to be '
          'good to within 200 vehicles. The question becomes how many days to '
          'count.',
    ),
    (
      'Turn the margin formula around',
      'The margin is the multiplier times sigma over root n. Solve for n: '
          'multiplier times sigma over the margin, and then SQUARE the whole '
          'thing. Stop before the square and you get about 8 when the answer '
          'is 62.',
    ),
    (
      'The square is why halving costs four times',
      'Cut the margin in half and n goes up by four. The curve of margin '
          'against samples drops fast at first and then flattens out.',
    ),
    (
      'Round up, always',
      'The arithmetic gives 61.47. Sixty-one days misses the target, and '
          'there is no such thing as most of a day. Take 62.',
    ),
  ],
  spoken: [
    (
      'Required n',
      r'n = \left(\frac{z_{\alpha/2} \cdot \sigma}{e}\right)^2',
      'multiplier times sigma, over the margin, then squared',
    ),
    (
      'So',
      r'\left(\frac{1.960 \times 800}{200}\right)^2 = 7.84^2 = 61.47',
      'the ratio is 7.84, and squared it is 61.47',
    ),
    ('Which means', r'n = 62', 'rounded up, never down'),
  ],
  handbook: 'Handbook p. 75',
);

const hypothesesBrief = BriefSection(
  title: 'Which way the claim points',
  picture: hypothesesPicture,
  steps: [
    (
      'Two rival statements',
      'The null is the boring one: nothing has changed, the mean is what it '
          'always was. The alternative is what somebody is trying to show. The '
          'test assumes the null until the data makes it uncomfortable.',
    ),
    (
      'Read the claim for a direction',
      'Words like exceeds, reduces or falls short point one way. Then the '
          'whole of alpha, the risk you accept of a false alarm, sits in ONE '
          'tail of the curve.',
    ),
    (
      'No direction, two tails',
      'A claim like "is different from" could be wrong either way. Alpha '
          'gets split in half, one piece in each tail. That is a different row '
          'of the table and a bigger critical value.',
    ),
    (
      'The two ways to be wrong',
      'Rejecting a null that was true is a Type I error, and alpha is its '
          'chance. Keeping a null that was false is a Type II error.',
    ),
  ],
  spoken: [
    (
      'One-tailed',
      r'H_1: \mu > \mu_0 \quad \text{or} \quad H_1: \mu < \mu_0',
      'the claim points one way, so alpha sits in one tail',
    ),
    (
      'Two-tailed',
      r'H_1: \mu \neq \mu_0 \;\Rightarrow\; \tfrac{\alpha}{2}\text{ in each tail}',
      'the claim could go either way, so alpha is split',
    ),
  ],
  handbook: 'Handbook p. 72',
);

const decisionRuleBrief = BriefSection(
  title: 'Bigger means reject',
  picture: decisionRulePicture,
  steps: [
    (
      'One number against one line',
      'Work one number out of your data. Look one number up in a table. Put '
          'both on the same scale. If your number lands past the line, the '
          'boring claim is rejected. That is the whole test.',
    ),
    (
      'What the two numbers are',
      'Yours says how far the sample strayed from the claim. The table one '
          'is the line drawn where straying that far stops being believable. '
          'It is called the critical value, and it is chosen before you look.',
    ),
    (
      'With no direction, size is all that counts',
      'When the claim did not say which way, only the distance from zero '
          'matters. Minus 2.9 against a line at 2.131 is past it, because 2.9 '
          'is further from zero. It rejects.',
    ),
    (
      'Staying short of the line proves nothing',
      'It means the data did not catch the boring claim out. That is all. '
          'An answer saying the mean really does equal the claimed value is '
          'wrong, however right the decision beside it looks.',
    ),
  ],
  spoken: [
    (
      'Z-test',
      r'z = \frac{\bar{x} - \mu_0}{\sigma / \sqrt{n}}',
      'how far the sample mean sits from the claim, in standard errors',
    ),
    (
      't-test',
      r't = \frac{\bar{x} - \mu_0}{s / \sqrt{n}}',
      'the same, with s from the sample, on n minus one degrees of freedom',
    ),
    (
      'The rule',
      r'|\text{statistic}| > \text{critical} \;\Rightarrow\; \text{reject } H_0',
      'past the line, reject',
    ),
  ],
  handbook: 'Handbook p. 73',
);

const goodnessOfFitBrief = BriefSection(
  title: 'Every cell pays its own way',
  picture: goodnessOfFitPicture,
  steps: [
    (
      'Do the counts match the model',
      'A model says each of four patterns should show up 50 times. You '
          'counted 62, 45, 53 and 40. Chi-square asks whether those gaps are '
          'bigger than chance would give.',
    ),
    (
      'Each cell adds its own piece',
      'For every category: the gap between counted and expected, squared, '
          'then divided by what was expected. Add the pieces up. Bigger means '
          'a worse fit.',
    ),
    (
      'The division is the point',
      'A gap of ten where a hundred was expected is a small surprise. A gap '
          'of eight where twenty was expected is a big one. Dividing by the '
          'expectation is what tells them apart, and it is the step the exam '
          'watches for.',
    ),
    (
      'Degrees of freedom',
      'One less than the number of categories. Look the critical value up '
          'on that row and apply the same rule as always: bigger means reject.',
    ),
  ],
  spoken: [
    (
      'Chi-square',
      r'\chi^2 = \sum \frac{(O_i - E_i)^2}{E_i}',
      'for each cell, the gap squared over what was expected, all added',
    ),
    ('Degrees of freedom', r'v = k - 1', 'the number of categories, less one'),
    (
      'So',
      r'\frac{(60-50)^2}{50} = 2.0 \quad \text{but} \quad \frac{(28-20)^2}{20} = 3.2',
      'the smaller gap hurts more, because less was expected',
    ),
  ],
  handbook: 'Handbook p. 75',
);

const publicFirstBrief = BriefSection(
  title: 'The public comes first',
  picture: publicFirstPicture,
  steps: [
    (
      'One rule beats the rest',
      'Engineers have a short rulebook. One rule sits above every other: '
          'keep the public safe and well. If the client, your boss or the '
          'deadline pulls the other way, the public still wins.',
    ),
    (
      'Three things it makes you do',
      'Asked to put your seal on something that does not meet the code? '
          'Refuse. Overruled, with people at risk? Tell your employer, then the '
          'authority. Another engineer breaking the rules and nobody fixing it? '
          'Tell the board.',
    ),
    (
      'Everything else is just a disagreement',
      'If nobody is in danger and no rule is broken, two engineers who '
          'disagree are only two engineers who disagree. The rule does not fire.',
    ),
  ],
  spoken: [
    (
      'A.1',
      r'\text{the public first: health, safety, welfare}',
      'your first duty is to the people who will use what you build',
    ),
    (
      'A.2',
      r'\text{seal only what meets the standards}',
      'never put your stamp on work that falls short of the code',
    ),
    (
      'A.3 and A.8',
      r'\text{overruled and unsafe} \to \text{notify};\ \text{a rule breaker} \to \text{the board}',
      'when you are overruled and people are at risk, tell the employer then the authority; report a licensee who breaks the rules',
    ),
  ],
  handbook: 'Handbook pp. 4-5, Model Rules 240.15',
);

const escalationBrief = BriefSection(
  title: 'Up the ladder, one rung at a time',
  picture: escalationPicture,
  steps: [
    (
      'Start with the person',
      'You spot a problem in someone\'s work. First tell that person. They '
          'may simply not have seen it, and most problems end right here.',
    ),
    (
      'Then the firm',
      'If nothing changes, go to the firm. It has the standing and the duty '
          'to fix its own work.',
    ),
    (
      'Then the board',
      'Only when the rungs below have been tried and nothing moved do you go '
          'to the authority or the board. Skipping a rung turns a fixable error '
          'into an argument about you.',
    ),
    (
      'The one exception',
      'When people are about to be hurt, you stop the work first and explain '
          'afterwards. Danger right now does not wait for the ladder.',
    ),
  ],
  spoken: [
    (
      'The ladder',
      r'\text{the person} \to \text{the firm} \to \text{the board}',
      'the person, then the firm, then the board, in that order',
    ),
    (
      'Overruled',
      r'\text{in writing} \to \text{employer} \to \text{authority}',
      'object in writing, tell your employer, then the authority',
    ),
    (
      'Imminent danger',
      r'\text{stop the work, then climb}',
      'if someone is about to be hurt, stop first and go up the ladder after',
    ),
  ],
  handbook: 'Handbook pp. 4-5, Model Rules A.3, A.8',
);

const proportionBrief = BriefSection(
  title: 'The right amount, not the most',
  picture: proportionPicture,
  steps: [
    (
      'The rule asks for one exact size',
      'Most ethics questions are not "should you act" but "how much". The '
          'rules name a specific amount, and you can miss it on either side.',
    ),
    (
      'Too little looks like meaning well',
      'Judging the bids fairly but telling nobody about your conflict. '
          'Sealing the drawing and writing the problem in a file nobody reads. '
          'Good intentions, wrong size.',
    ),
    (
      'Too much looks like conviction',
      'Quitting the committee. Calling the client before your own firm has '
          'heard. Dramatic, and more than the rule asked for.',
    ),
    (
      'The usual right size',
      'For a conflict of interest it is almost always the same: say it out '
          'loud, then step out of that one decision. Nothing bigger.',
    ),
  ],
  spoken: [
    (
      'The rule',
      r'\text{disclose, then step out of that decision}',
      'tell everyone about the conflict, then do not take part in that one decision',
    ),
    (
      'Too little',
      r'\text{meaning well and saying nothing}',
      'staying quiet, however fairly you behave',
    ),
    (
      'Too much',
      r'\text{resigning from the whole body}',
      'leaving altogether, which nobody asked for',
    ),
  ],
  handbook: 'Handbook p. 5, Model Rules B.6, B.8',
);

const competenceBrief = BriefSection(
  title: 'Your field, and your own charge',
  picture: competencePicture,
  steps: [
    (
      'Gate one: your field',
      'Take on only work you are trained or experienced in. Your SPECIFIC '
          'field, not the one next door. A bridge engineer is not a water '
          'treatment engineer because both are civil.',
    ),
    (
      'Gate two: your charge',
      'To seal a drawing it must have been made under your direct control '
          'and personal supervision. Reading someone else\'s numbers carefully '
          'afterwards is not that.',
    ),
    (
      'Both gates, or no seal',
      'A colleague checking your work does not make you competent. Your '
          'competence does not cover work you did not direct. The seal needs '
          'both at once.',
    ),
    (
      'You may still run the whole project',
      'Coordinating a big job is fine, as long as each technical part '
          'carries the seal of whoever actually prepared it.',
    ),
  ],
  spoken: [
    (
      'B.1',
      r'\text{only work you are qualified for}',
      'accept only jobs in your own field, by education or experience',
    ),
    (
      'B.2',
      r'\text{seal} = \text{your field} + \text{your responsible charge}',
      'a seal needs your field and your own direct control, both',
    ),
    (
      'B.3',
      r'\text{coordinate, with each part sealed by its own engineer}',
      'you can lead the whole project if every segment is sealed by the one who prepared it',
    ),
  ],
  handbook: 'Handbook p. 5, Model Rules B.1 to B.3',
);

const consentBrief = BriefSection(
  title: 'Everyone with a stake says yes, in writing',
  picture: consentPicture,
  steps: [
    (
      'A conflict is not fatal',
      'Being paid by two people about the same job is allowed. It is not '
          'free either. You have to say so, and each of them has to agree in '
          'writing.',
    ),
    (
      'Silence is not an option',
      'Even if the two scopes look different, you disclose. Refusing the '
          'work outright is more than the rule asks. Say it, get the written '
          'yes, carry on.',
    ),
    (
      'What no consent can fix',
      'A gift from someone bidding on your work. Taking work from a public '
          'body you sit on. Those are out, whoever agrees.',
    ),
    (
      'Whose secrets',
      'Facts your client paid to find belong to that client. Only they can '
          'let you share them.',
    ),
  ],
  spoken: [
    (
      'B.6 and B.7',
      r'\text{two payers, one subject} \Rightarrow \text{written consent from all}',
      'when more than one party pays you about the same matter, every one of them agrees in writing',
    ),
    (
      'B.4',
      r'\text{client facts stay with the client}',
      'do not reveal what a client paid to learn without their consent',
    ),
    (
      'B.5 and B.8',
      r'\text{no gifts from bidders, no work from your own board}',
      'no gratuities from anyone bidding on your work, and no jobs from a public body you sit on',
    ),
  ],
  handbook: 'Handbook p. 5, Model Rules B.4 to B.8',
);

const claimsBrief = BriefSection(
  title: 'Say what you did, not what it sounds like',
  picture: claimsPicture,
  steps: [
    (
      'The whole job and your piece',
      'A bridge has many hands on it. Your resume may only claim the piece '
          'that was yours. Claiming the whole thing is exaggerating, even if you '
          'were on the project.',
    ),
    (
      'The trap is the true-if-read-slowly sentence',
      'The rule is not about outright lies. It is about lines that flatter '
          'when read quickly: managing a bridge is not designing it, one system '
          'is not the whole plant, reviewing is not designing.',
    ),
    (
      'The test',
      'Say what you did and who did the rest. A claim that survives the '
          'follow-up question is the right size.',
    ),
    (
      'And about other engineers',
      'Do not damage another licensee\'s name. If you find a real error in '
          'their work, tell them directly.',
    ),
  ],
  spoken: [
    (
      'C.1',
      r'\text{do not exaggerate your role}',
      'claim only the part of past work that was actually yours',
    ),
    (
      'C.3',
      r'\text{do not harm another licensee\textquotesingle s reputation}',
      'never run down another engineer to win work',
    ),
    (
      'C.4',
      r'\text{a material error} \to \text{tell that licensee directly}',
      'if you find a serious mistake in another engineer\'s work, tell them first',
    ),
  ],
  handbook: 'Handbook p. 5, Model Rules C.1 to C.4',
);

const standingBrief = BriefSection(
  title: 'Certified is not licensed',
  picture: standingPicture,
  steps: [
    (
      'The first badge',
      'Pass the FE and the board CERTIFIES you as an Engineer Intern. You '
          'may use the title, and you may sit the second exam once the years of '
          'experience are done.',
    ),
    (
      'The second badge',
      'Pass the PE exam too, with the years behind you, and the board '
          'LICENSES you as a Professional Engineer. The seal is an act of that '
          'license and nothing else.',
    ),
    (
      'Nothing lends a seal',
      'Not being good at the work. Not a licensed colleague reading your '
          'drawing afterwards. Not writing "intern" beside your name. Either you '
          'hold the license or the seal is not yours to use.',
    ),
    (
      'Most engineering needs no license',
      'A great deal of real work is done by people with no license at all, '
          'under a licensed engineer. The license is about the seal.',
    ),
  ],
  spoken: [
    (
      'Engineer Intern',
      r'\text{FE passed} \Rightarrow \text{certified}',
      'passed the FE exam, certified by the board, no seal',
    ),
    (
      'Professional Engineer',
      r'\text{FE + PE + the years} \Rightarrow \text{licensed}',
      'passed both exams with the experience, licensed by the board',
    ),
    (
      'The seal',
      r'\text{only a licensed PE signs and seals}',
      'a seal is an act of a license; nobody else can use one',
    ),
  ],
  handbook: 'Handbook p. 6, Model Law 110.20',
);

const exemptionBrief = BriefSection(
  title: 'When unlicensed work is allowed',
  picture: exemptionPicture,
  steps: [
    (
      'A firm has to be able to hire people',
      'The exemption clause lets an unlicensed employee do real engineering '
          'work: calculations, drawings, checking one document against another.',
    ),
    (
      'On two conditions, both at once',
      'A licensed engineer is in responsible charge of the work. And the '
          'final engineering decisions are the engineer\'s, not the employee\'s.',
    ),
    (
      'What responsible charge means',
      'Direct control and personal supervision, while the work happens. '
          'Being told about it afterwards is not it. Working in the same firm as '
          'a licensed engineer who is not directing you is not it either.',
    ),
  ],
  spoken: [
    (
      '170.20 C',
      r'\text{a subordinate under the responsible charge of a PE}',
      'an unlicensed employee may work under a licensed engineer who directs it',
    ),
    (
      'And',
      r'\text{no final engineering decisions}',
      'the final calls are the licensed engineer\'s, never the employee\'s',
    ),
    (
      'Responsible charge',
      r'\text{direct control and personal supervision}',
      'the engineer is directing the work as it is done, not hearing about it later',
    ),
  ],
  handbook: 'Handbook p. 11, Model Law 170.20 C',
);

const holdingOutBrief = BriefSection(
  title: 'Doing the work, or wearing the title',
  picture: holdingOutPicture,
  steps: [
    (
      'Offense one: doing the work',
      'Any service that takes engineering training and judgment and '
          'reaches the public\'s safety is the practice of engineering. Doing it '
          'without a license is a violation.',
    ),
    (
      'The medium does not matter',
      'Drawings, a spreadsheet, a book of tables, an app. The law has never '
          'cared what the judgment is delivered on. Making the user press the '
          'last button does not move the judgment out of the software.',
    ),
    (
      'Offense two: wearing the title',
      'Calling yourself a Professional Engineer when you are not, on a sign, '
          'a card, a letterhead or a website, is a violation even if you never '
          'do a day of engineering.',
    ),
  ],
  spoken: [
    (
      '110.20 A.3',
      r'\text{engineering judgment that reaches the public}',
      'work needing engineering education and judgment, touching public safety, is the practice',
    ),
    (
      'A.3(a)',
      r'\text{practices, or offers to practice}',
      'doing the work, or advertising that you can',
    ),
    (
      'A.3(b)',
      r'\text{represents themselves as a PE by any means}',
      'claiming the title in any form, even without doing the work',
    ),
  ],
  handbook: 'Handbook p. 6, Model Law 110.20 A.3',
);

const ladderBrief = BriefSection(
  title: 'The ladder, and the years on each rung',
  picture: ladderPicture,
  steps: [
    (
      'Five things for anybody',
      'Good character, the education, the experience, the exams, and five '
          'references the board accepts. Everyone climbs the same ladder.',
    ),
    (
      'In order',
      'An accredited degree plus the FE makes you an Engineer Intern. Then '
          'the years of experience, then the PE exam, and you are a Professional '
          'Engineer.',
    ),
    (
      'The years depend on the degree',
      'Four years after a bachelor\'s. Three after a master\'s. Two after a '
          'doctorate, if you also passed the FE. More schooling, fewer years.',
    ),
    (
      'A degree is spent once',
      'The degree that paid for the education requirement cannot be spent '
          'again as experience. The years are real years at work.',
    ),
  ],
  spoken: [
    (
      "Bachelor's",
      r'\text{4 years of progressive experience}',
      'four years of real, growing responsibility',
    ),
    ("Master's", r'\text{3 years}', 'three years'),
    ('Doctorate, with the FE', r'\text{2 years}', 'two years'),
    (
      'Comity',
      r'\text{licensed elsewhere} \to \text{licensed here, if it matches}',
      'a license from another state carries over when its requirements meet ours',
    ),
  ],
  handbook: 'Handbook pp. 8-9, Model Law 130.10',
);

const disciplineBrief = BriefSection(
  title: 'What the board can act on',
  picture: disciplinePicture,
  steps: [
    (
      'The list',
      'Lying to get the license. Negligence or incompetence. Working outside '
          'your field. Breaking a board rule. And being convicted of a felony.',
    ),
    (
      'Any felony',
      'A felony counts whether or not it has anything to do with '
          'engineering. The board may act on it.',
    ),
    (
      'Misdemeanours are the other way round',
      'A small offense counts only if it involves dishonesty or the '
          'practice itself. A faked timesheet is grounds. A speeding ticket is '
          'not.',
    ),
    (
      'A clean record changes the punishment, not the question',
      'A good history affects what the board does. It never decides whether '
          'the board may act at all.',
    ),
  ],
  spoken: [
    (
      'Any felony',
      r'\text{grounds, related to engineering or not}',
      'a felony conviction is always grounds for discipline',
    ),
    (
      'A misdemeanor',
      r'\text{grounds only if dishonesty, or the practice}',
      'a lesser offense counts only when it involves a lie or the engineering work',
    ),
    (
      'Also',
      r'\text{fraud, negligence, incompetence, a board rule}',
      'lying for the license, careless or incompetent work, or breaking a board rule',
    ),
  ],
  handbook: 'Handbook p. 9, Model Law 150.10',
);

const sectionsBrief = BriefSection(
  title: 'Ask first: do they hold a license',
  picture: sectionsPicture,
  steps: [
    (
      'Two roads',
      'The penalties come in two lists, and which list applies depends on '
          'one thing: does this person hold a license right now.',
    ),
    (
      'A licensee',
      'The board can suspend the license, revoke it, fine them, or '
          'reprimand them.',
    ),
    (
      'Not licensed',
      'They are fined instead: for practising, for using the title, for '
          'showing a seal that is not theirs, for putting "engineering" in a '
          'business name without permission. Every day it continues is a new '
          'offense.',
    ),
    (
      'Expired means not licensed',
      'Revoked, suspended and expired all land on the second road. There is '
          'no license to act against, so the fines apply.',
    ),
  ],
  spoken: [
    (
      '150.10, a licensee',
      r'\text{suspend, revoke, fine, reprimand}',
      'the board acts on the license itself',
    ),
    (
      '150.30, not licensed',
      r'\text{a fine, each day counted again}',
      'no license to touch, so a fine, repeated for every day it goes on',
    ),
    (
      'And',
      r'\text{revoked or expired} \Rightarrow \text{not licensed}',
      'a license that is gone puts you on the second road',
    ),
  ],
  handbook: 'Handbook pp. 9-10, Model Law 150.10 and 150.30',
);

const formationBrief = BriefSection(
  title: 'When a deal becomes a contract',
  picture: formationPicture,
  steps: [
    (
      'Five ticks',
      'Someone makes an OFFER. The other side ACCEPTS it as it stands. '
          'Something of value moves both ways, the CONSIDERATION. Both have the '
          'CAPACITY to agree. The purpose is LAWFUL. All five, and it is a '
          'contract.',
    ),
    (
      'Not on the list',
      'A notary. A witness. A signature in ink. None of these is needed for '
          'a contract to exist.',
    ),
    (
      'A counter-offer kills the offer',
      'Say "I will do it for less" and the original number is gone. You '
          'cannot go back and take it later.',
    ),
    (
      'An invitation to bid is not an offer',
      'The owner asking for bids is not offering anything. The bidder makes '
          'the offer; the award accepts it. That is why the firms that lost have '
          'nothing to enforce.',
    ),
  ],
  spoken: [
    (
      'The five',
      r'\text{offer, acceptance, consideration, capacity, legality}',
      'an offer, a yes to it as it stands, value both ways, the ability to agree, and a lawful purpose',
    ),
    (
      'Not required',
      r'\text{a notary or a witness}',
      'formalities are not what makes a contract',
    ),
    (
      'A counter-offer',
      r'\text{ends the offer it answered}',
      'once you counter, the original offer is off the table',
    ),
  ],
  handbook: 'Model Rules, contracts',
);

const riskBrief = BriefSection(
  title: 'Who pays for the piece past the line',
  picture: riskPicture,
  steps: [
    (
      'The job cost more than planned',
      'Every pricing question is this picture. The bar ran past the price. '
          'Someone has to absorb that piece, and the contract they signed '
          'decides who.',
    ),
    (
      'A fixed price: the contractor',
      'Lump sum locks the number. Anything above it is the contractor\'s '
          'problem. The owner bought certainty.',
    ),
    (
      'Cost plus, or time and materials: the owner',
      'These pay back whatever the work actually cost, plus a fee. The '
          'estimate was never a promise, so the owner carries the overrun.',
    ),
    (
      'The two odd ones',
      'Unit price is not an overrun at all: the owner pays a fixed rate for '
          'every unit that goes in. A guaranteed maximum draws a line and swaps '
          'who pays at it. And changing the scope hands the risk back, whatever '
          'was signed.',
    ),
  ],
  spoken: [
    (
      'Lump sum',
      r'\text{the contractor}',
      'a fixed price, so the contractor eats the overrun',
    ),
    (
      'Cost plus, time and materials',
      r'\text{the owner}',
      'paid back what it cost, so the owner carries it',
    ),
    (
      'Unit price',
      r'\text{the owner, per unit placed}',
      'a fixed rate per unit, the owner pays for every one',
    ),
    (
      'Above a guaranteed maximum',
      r'\text{the manager at risk}',
      'past the guaranteed line, the construction manager pays',
    ),
  ],
  handbook: 'Model Rules, contract types',
);

const deliveryBrief = BriefSection(
  title: 'Count the lines coming out of the owner',
  picture: deliveryPicture,
  steps: [
    (
      'Forget the acronyms',
      'A delivery method is just the shape of the contracts. Draw the owner '
          'as a box and count the lines running out of it.',
    ),
    (
      'Two lines: design, bid, build',
      'One contract with the designer, one with the builder, nothing between '
          'them. The design is finished before anyone prices it.',
    ),
    (
      'One line: design-build',
      'The owner signs with one firm. The designer works for that firm as a '
          'subcontractor, and the owner cannot write to them directly.',
    ),
    (
      'Two lines again: a manager at risk',
      'The builder is hired early to advise during design, then commits to '
          'a guaranteed maximum price. Two contracts, and a line the builder '
          'promises not to cross.',
    ),
  ],
  spoken: [
    (
      'Design, bid, build',
      r'\text{two contracts, design finished first}',
      'the owner holds two contracts and the design is done before bidding',
    ),
    (
      'Design-build',
      r'\text{one contract, everyone else beneath it}',
      'one contract; the designer is under the builder',
    ),
    (
      'CM at risk',
      r'\text{two contracts, and a guaranteed maximum}',
      'two contracts, with the builder promising a top price',
    ),
  ],
  handbook: 'Model Rules, project delivery',
);

const standardOfCareBrief = BriefSection(
  title: 'Not perfection, and not intent',
  picture: standardOfCarePicture,
  steps: [
    (
      'The measuring stick',
      'An engineer is judged against what a reasonably competent engineer '
          'would have done in the same situation. That is a band, not a point.',
    ),
    (
      'Inside the band is fine',
      'A design that later turns out imperfect is not a breach if a '
          'competent peer would have produced it. Where good engineers could '
          'reasonably differ, picking one of the options is not negligence.',
    ),
    (
      'Below the band is negligence',
      'Forgetting a required check is negligence. You did not mean to, and '
          'it does not matter. Intent is not part of the word.',
    ),
    (
      'Above the band is not required',
      'Nobody owes a perfect result. And knowing the truth and writing the '
          'opposite is something worse than negligence, with a different name.',
    ),
  ],
  spoken: [
    (
      'The measure',
      r'\text{what a reasonably competent peer would do}',
      'the ordinary skill and care of a competent engineer in the same spot',
    ),
    (
      'Not',
      r'\text{a guarantee of a perfect result}',
      'an imperfect outcome by itself is not a breach',
    ),
    ('Not', r'\text{intent}', 'negligence does not need you to have meant it'),
  ],
  handbook: 'Model Rules, liability',
);

const negligenceBrief = BriefSection(
  title: 'Four links, and all four have to hold',
  picture: negligencePicture,
  steps: [
    (
      'A claim is a chain',
      'You owed this person a DUTY. You BROKE it. The break CAUSED the harm. '
          'The harm has DAMAGES you can measure. Four links.',
    ),
    (
      'One missing link and nothing pulls through',
      'A real mistake next to a real loss that had nothing to do with each '
          'other is not negligence. The causation link is missing, and that is '
          'where most claims against engineers fail.',
    ),
    (
      'Intent is not a link',
      'People add it to the list. It is not there. A careless slip with no '
          'bad intention can still be negligence.',
    ),
  ],
  spoken: [
    (
      'The four',
      r'\text{duty, breach, causation, damages}',
      'a duty owed, a breach of it, a link from the breach to the harm, and measurable harm',
    ),
    ('Not one of them', r'\text{intent}', 'meaning to is not required'),
    (
      'No damages',
      r'\text{no claim, however plain the breach}',
      'a mistake that hurt nobody is not a claim',
    ),
  ],
  handbook: 'Model Rules, negligence',
);

const clocksBrief = BriefSection(
  title: 'Two clocks, two starting guns',
  picture: clocksPicture,
  steps: [
    (
      'The first clock waits for the harm',
      'A statute of LIMITATIONS starts when the harm happens or is found. '
          'From that day you have a few years to file.',
    ),
    (
      'The second clock starts when the job ends',
      'A statute of REPOSE starts at a fixed event, usually the day the '
          'project was substantially complete. Nothing that happens later can '
          'stretch it.',
    ),
    (
      'A claim must land inside both windows',
      'Miss either one and the claim is out. That is the whole difference '
          'between the two words.',
    ),
    (
      'The sharp edge',
      'Repose can close before the harm even shows up, because it counts '
          'from the day the job finished, not from the day something went '
          'wrong.',
    ),
  ],
  spoken: [
    (
      'Limitations',
      r'\text{from the harm, or from finding it}',
      'the clock starts when the injury happens or is discovered',
    ),
    (
      'Repose',
      r'\text{from substantial completion, no extensions}',
      'the clock starts when the job is done and never moves',
    ),
    (
      'So',
      r'\text{repose can shut before the injury exists}',
      'a claim can be dead before anyone knew there was a problem',
    ),
  ],
  handbook: 'Model Rules, time limits',
);

const propertyBrief = BriefSection(
  title: 'Four protections, and the one question that sorts them',
  picture: propertyPicture,
  steps: [
    (
      'Do you tell the world, or keep it quiet',
      'A PATENT is a trade: publish how the invention works and get twenty '
          'years from the filing date. A TRADE SECRET is the opposite trade: '
          'keep it quiet and it is protected for as long as nobody knows.',
    ),
    (
      'Three kinds of patent',
      'For an invention. For the ornamental look of a made thing. For a '
          'plant variety grown without seed.',
    ),
    (
      'The name, and the words',
      'A TRADEMARK protects the name, not the product: anyone may make the '
          'same thing under a different name. A COPYRIGHT protects the writing, '
          'not the idea inside it.',
    ),
  ],
  spoken: [
    (
      'Patent',
      r'\text{published, 20 years from filing}',
      'you disclose the invention and get twenty years from the day you filed',
    ),
    (
      'Trade secret',
      r'\text{unpublished, lasts while it holds}',
      'you keep it quiet and it lasts as long as it stays secret',
    ),
    (
      'Trademark',
      r'\text{the name, not the goods}',
      'protects what the product is called',
    ),
    (
      'Copyright',
      r'\text{the expression, not the idea}',
      'protects the words and drawings, not the thought behind them',
    ),
  ],
  handbook: 'Handbook pp. 12-13',
);

const portfolioBrief = BriefSection(
  title: 'One product, four things to protect',
  picture: portfolioPicture,
  steps: [
    (
      'They do not compete',
      'A product is not one asset. The invention, the name it is sold '
          'under, the manual that describes it, and the process left out of the '
          'manual are four different things.',
    ),
    (
      'Four things, four protections',
      'The invention gets a patent. The name gets a trademark. The manual '
          'gets a copyright. The process nobody wrote down stays a trade secret.',
    ),
    (
      'Patenting and stopping covers one of four',
      'A firm that patents the invention and does nothing else has left the '
          'name, the manual and the process unprotected.',
    ),
    (
      'The one pairing that cannot happen',
      'A patent and a trade secret on the SAME thing. Filing publishes it, '
          'and a secret only exists while it is not published.',
    ),
  ],
  spoken: [
    (
      'The invention',
      r'\text{a patent}',
      'how it works, published, for twenty years',
    ),
    ('The name', r'\text{a trademark}', 'what it is called'),
    (
      'The manual',
      r'\text{a copyright}',
      'the words and drawings that describe it',
    ),
    (
      'What was left out',
      r'\text{a trade secret}',
      'the process nobody published',
    ),
  ],
  handbook: 'Handbook pp. 12-13',
);

const lifeCycleBrief = BriefSection(
  title: 'Add up the whole bar',
  picture: lifeCyclePicture,
  steps: [
    (
      'A thing costs money its whole life',
      'Building it is only the first piece. Then running it, keeping it '
          'fixed, and finally taking it away. A life-cycle assessment adds all '
          'four.',
    ),
    (
      'Cheapest to build is often not cheapest to own',
      'Look at the picture: the option with the shorter first piece has the '
          'longer bar. The piece that decides it is usually the one nobody '
          'priced, maintenance years later or demolition after everyone has '
          'retired.',
    ),
    (
      'It is a method, not a verdict',
      'Sometimes the cheap option really is the cheap option. The assessment '
          'is how you find out which case you are in.',
    ),
  ],
  spoken: [
    (
      'The whole life',
      r'\text{build} + \text{operate} + \text{maintain} + \text{take away}',
      'add what it costs to build, to run, to keep, and to remove',
    ),
    (
      'Not',
      r'\text{the first piece on its own}',
      'the build cost alone tells you nothing about the total',
    ),
    (
      'The triple bottom line',
      r'\text{economic, environmental, social}',
      'money, the planet, and people, all three counted',
    ),
  ],
  handbook: 'Handbook pp. 12-13',
);

const factorsBrief = BriefSection(
  title: 'Six factors, one question',
  picture: factorsPicture,
  steps: [
    (
      'Money changes shape',
      'Money comes in three shapes: one amount today, one amount later, or '
          'the same amount every year. A hundred dollars today and a hundred '
          'dollars in five years are not worth the same, because money can earn '
          'interest while it waits.',
    ),
    (
      'A factor swaps one shape for another',
      'Every factor answers the same question: what have you got, and what '
          'do you want instead? It is named for the pair it moves between. P to '
          'F carries one amount forward. A to P turns a yearly series into '
          'today\'s amount.',
    ),
    (
      'The two that get mixed up',
      'Sinking fund and capital recovery both turn a single amount into a '
          'yearly series. The difference is WHERE the known amount sits. In your '
          'hand today: capital recovery. Waiting at the end: sinking fund.',
    ),
  ],
  spoken: [
    (
      'Carried forward',
      r'F = P(1+i)^n',
      'today\'s amount, grown by the rate, once per year',
    ),
    (
      'Brought back',
      r'P = F(1+i)^{-n}',
      'a later amount, shrunk back to today',
    ),
    (
      'Sinking fund',
      r'A = F\,\frac{i}{(1+i)^n - 1}',
      'the yearly deposit that builds up to F at the end',
    ),
    (
      'Capital recovery',
      r'A = P\,\frac{i(1+i)^n}{(1+i)^n - 1}',
      'the yearly payment that pays off P from today',
    ),
  ],
  handbook: 'Handbook p. 229, tables pp. 232-236',
);

const ratesBrief = BriefSection(
  title: 'Twelve percent a year is three different numbers',
  picture: ratesPicture,
  steps: [
    (
      'Charged a little at a time',
      'A loan at 12 percent a year, compounded monthly, does not charge 12 '
          'percent once. It charges one percent every month, twelve times. That '
          'one percent is the PERIODIC rate, the quoted rate split into its '
          'periods.',
    ),
    (
      'Interest on the interest',
      'After the first month you owe one percent more, and the next month\'s '
          'one percent is charged on that too. Twelve small steps climb a little '
          'past the straight line: 12.68 percent, not 12. That is the EFFECTIVE '
          'rate, what a year really costs.',
    ),
    (
      'The number on the paperwork',
      'The 12 is the NOMINAL rate. It is the label, and on its own it tells '
          'you almost nothing. To compare two offers that compound differently, '
          'compare their effective rates.',
    ),
    (
      'Match the rate to the count',
      'Use the periodic rate with a number of periods counted the same way: '
          'one percent with months, 12.68 percent with years. Compounded once a '
          'year, all three numbers are the same.',
    ),
  ],
  spoken: [
    (
      'Periodic',
      r'i = \frac{r}{m}',
      'the yearly rate, divided by how many times a year it is charged',
    ),
    (
      'Effective',
      r'i_e = \left(1 + \frac{r}{m}\right)^m - 1',
      'one plus the periodic rate, multiplied by itself m times, minus one',
    ),
    (
      'So',
      r'12\% \text{ monthly} \Rightarrow 1\%,\ 12\%,\ 12.68\%',
      'periodic one, nominal twelve, effective 12.68',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const piecesBrief = BriefSection(
  title: 'Count the pieces before you pick a factor',
  picture: piecesPicture,
  steps: [
    (
      'A picture can be two pictures',
      'A cost that grows by the same step every year looks like one thing. '
          'It is two: a flat series, the same every year, with a triangle '
          'stacked on top that grows by one step each year.',
    ),
    (
      'Each piece gets its own factor',
      'The flat part uses the A factor. The triangle uses the G factor, the '
          'gradient. Doing the flat part and stopping is the commonest way to '
          'lose this question.',
    ),
    (
      'Anything on one date is a third piece',
      'A single amount landing on one year takes a plain single-amount '
          'factor. Bring each piece to the same date, then add them up. Never '
          'hunt for one factor that covers the whole picture.',
    ),
  ],
  spoken: [
    (
      'A single amount',
      r'P = F(1+i)^{-n}',
      'one later amount, brought back to today',
    ),
    (
      'The flat part',
      r'P = A\,(P/A, i, n)',
      'the same amount every year, brought back to today',
    ),
    (
      'The growing part',
      r'P = G\,(P/G, i, n)',
      'the triangle, brought back to today',
    ),
    ('Together', r'P = A(P/A) + G(P/G)', 'add the pieces at the end'),
  ],
  handbook: 'Handbook p. 229',
);

const annualCostBrief = BriefSection(
  title: 'What owning it costs you each year',
  picture: annualCostPicture,
  steps: [
    (
      'Spread the purchase out',
      'A machine bought for a lump sum is used for years. Spread the price '
          'across those years with the capital recovery factor, not by plain '
          'division, because the money tied up in it could have earned '
          'interest.',
    ),
    (
      'Add what it costs to run',
      'Fuel, repairs, staff: the yearly running costs go in as they are. A '
          'one-off cost in the middle of its life is brought back to today and '
          'spread out too.',
    ),
    (
      'Subtract what it sells for',
      'Money coming back at the end makes the thing cheaper to own, so the '
          'salvage comes OFF. It sits at the bottom of the problem next to a '
          'column of costs, waiting to be added by mistake.',
    ),
    (
      'Money already spent stays out',
      'Anything paid before the decision is gone whatever you choose now. It '
          'belongs to neither option.',
    ),
  ],
  spoken: [
    (
      'Annual worth',
      r'AW = -P(A/P) - A_{\text{op}} + S(A/F)',
      'the purchase spread out, minus running costs, plus the salvage spread out',
    ),
    ('Not', r'\frac{P}{n}', 'never the purchase divided by the years'),
    (
      'A sunk cost',
      r'\text{is in neither alternative}',
      'already spent, so it cannot change the choice',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const studyPeriodBrief = BriefSection(
  title: 'Compare over the same amount of time',
  picture: studyPeriodPicture,
  steps: [
    (
      'A total is only fair over the same stretch',
      'A present worth is the total cost of a stretch of time. Comparing a '
          'six year pump with a four year pump by total cost is unfair: the four '
          'year one looks cheap because it buys less service.',
    ),
    (
      'Repeat them until they end together',
      'Buy the four year pump three times and the six year pump twice: both '
          'run twelve years, and now the totals compare. That is the least '
          'common multiple of the two lives.',
    ),
    (
      'Or compare per year',
      'Annual worth is dollars per year, a rate. Two rates compare directly '
          'however long each option lasts, so there is nothing to repeat. Equal '
          'lives need nothing either way.',
    ),
  ],
  spoken: [
    (
      'Equal lives',
      r'\text{compare over the life}',
      'same stretch, fair as it is',
    ),
    (
      'Unequal lives, by PW',
      r'\text{repeat to the least common multiple}',
      'run both until they end on the same year',
    ),
    (
      'Unequal lives, by AW',
      r'\text{nothing to do}',
      'dollars per year compare as they stand',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const methodsAgreeBrief = BriefSection(
  title: 'Three views of one comparison',
  picture: methodsAgreePicture,
  steps: [
    (
      'Same money, three clocks',
      'Present worth piles every cash flow onto today. Future worth piles '
          'them onto the last year. Annual worth spreads them evenly, one slice '
          'per year. It is the same money read three ways.',
    ),
    (
      'So they cannot disagree',
      'For the same options, over the same stretch of time, at the same '
          'rate, all three rank the options the same way. Whichever is bigger '
          'today is bigger at the end and bigger per year.',
    ),
    (
      'If they seem to disagree',
      'One of those three things was not the same. Usually the stretch of '
          'time, because unequal lives were compared as they stand. Sometimes '
          'the rate. If all three really match, it is a slip in the working.',
    ),
  ],
  spoken: [
    (
      'Same ranking',
      r'PW,\ FW,\ AW \text{ agree}',
      'present, future and annual worth pick the same winner',
    ),
    (
      'Unless',
      r'\text{the periods differ}',
      'the two options were compared over different stretches',
    ),
    (
      'Or',
      r'\text{the rate differs}',
      'a different interest rate was used somewhere',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const costTypesBrief = BriefSection(
  title: 'Sort the costs before you add them',
  picture: costTypesPicture,
  steps: [
    (
      'Fixed and variable',
      'Rent is the same whether you make one thing or a thousand: FIXED. '
          'Materials cost more the more you make: VARIABLE. On a cost line the '
          'fixed part is where the line starts and the variable part is how '
          'steeply it climbs.',
    ),
    (
      'Sunk means gone',
      'Money already spent that you cannot get back is SUNK. It does not '
          'change with what you decide next, so it stays out of the comparison. '
          'Owning the thing does not put it back in, and neither does '
          'depreciating it.',
    ),
    (
      'Two costs with no invoice',
      'An OPPORTUNITY cost is what you give up by choosing this, like the '
          'rent an empty shed could have earned. It counts. A MARGINAL cost is '
          'what the NEXT one costs to make, not the average of them all.',
    ),
  ],
  spoken: [
    (
      'Total cost',
      r'TC = FC + VC \cdot Q',
      'the fixed cost, plus the variable cost times how many you make',
    ),
    (
      'A sunk cost',
      r'\text{is in neither alternative}',
      'spent already, so it cannot tip the choice',
    ),
    (
      'An opportunity cost',
      r'\text{is in, invoice or not}',
      'what you gave up counts, even with no bill',
    ),
  ],
  handbook: 'Handbook pp. 230-231',
);

const breakEvenBrief = BriefSection(
  title: 'Two cost lines and where they cross',
  picture: breakEvenPicture,
  steps: [
    (
      'Each option is a line',
      'Owning a machine starts expensive and climbs slowly. Renting one '
          'starts cheap and climbs fast. Draw both against how many you make and '
          'they cross once.',
    ),
    (
      'The crossing is the break-even',
      'Below that volume the option with the cheaper START wins. Above it the '
          'option with the cheaper RATE wins. To find it, set the two total costs '
          'equal and solve for the volume.',
    ),
    (
      'Two ways to get it wrong',
      'Comparing only the per-unit rates ignores where each line begins. '
          'Subtracting the variable costs the wrong way round gives a negative '
          'volume, which is a sign, not an answer.',
    ),
    (
      'Sometimes they never cross',
      'If one option starts higher AND climbs faster, it loses at every '
          'volume. There is no break-even to find.',
    ),
  ],
  spoken: [
    (
      'Break even',
      r'FC_1 + VC_1 Q = FC_2 + VC_2 Q',
      'the two total costs are equal',
    ),
    (
      'So',
      r'Q = \frac{FC_1 - FC_2}{VC_2 - VC_1}',
      'the gap in starts, divided by the gap in rates',
    ),
    (
      'Below it',
      r'\text{the cheaper start wins}',
      'at small volumes the low starting cost matters most',
    ),
  ],
  handbook: 'Handbook pp. 230-231',
);

const paybackBrief = BriefSection(
  title: 'Only what is left over pays it back',
  picture: paybackPicture,
  steps: [
    (
      'Paying back a big bar',
      'The investment is one big amount. Each year, the change saves some '
          'money, and that saving pays the bar down. The payback period is how '
          'many years until the bar is paid.',
    ),
    (
      'Use the net saving',
      'The new machine also costs something to run. Only what is LEFT after '
          'those new costs pays the bar down. The exam prints the bigger, gross '
          'number first, and using it makes a seven year payback look like five.',
    ),
    (
      'What goes where',
      'Only amounts that repeat every year belong underneath. A one-off grant '
          'comes off the investment instead. If the new yearly costs are bigger '
          'than the saving, there is no payback at all.',
    ),
  ],
  spoken: [
    (
      'Simple payback',
      r'n = \frac{\text{investment}}{\text{net annual saving}}',
      'the investment, divided by what each year really saves',
    ),
    (
      'Net saving',
      r'\text{savings} - \text{new annual costs}',
      'what comes in, minus what the change costs to run',
    ),
    (
      'So',
      r'\frac{1{,}400{,}000}{280{,}000 - 80{,}000} = 7 \text{ years}',
      'one point four million, over two hundred thousand a year',
    ),
  ],
  handbook: 'Handbook pp. 230-231',
);

const ratioBrief = BriefSection(
  title: 'Three places a number can land',
  picture: ratioPicture,
  steps: [
    (
      'What it does over what it costs',
      'A public project is judged by a fraction: the good it does for people '
          'on top, what it costs the government underneath. A ratio of one or '
          'more means it pays its way.',
    ),
    (
      'Harm comes off the top',
      'Some projects also hurt people, like noise or lost land. That harm is '
          'a DISBENEFIT: it belongs on top, subtracted from the benefits. Moving '
          'it underneath is a different division and gives a different answer.',
    ),
    (
      'Every cost goes underneath',
      'Not just building it. Every year of running and maintaining it counts '
          'as cost too. Bring everything to the same date before you divide.',
    ),
  ],
  spoken: [
    ('Plain', r'B/C = \frac{B}{C}', 'benefits over costs'),
    (
      'With disbenefits',
      r'B/C = \frac{B - D}{C}',
      'benefits minus harm, over costs',
    ),
    ('Justified when', r'B/C \geq 1', 'the ratio reaches one'),
  ],
  handbook: 'Handbook p. 231',
);

const incrementalBrief = BriefSection(
  title: 'Is the step up worth it',
  picture: incrementalPicture,
  steps: [
    (
      'The best ratio is the wrong pick',
      'When you can only build ONE of several options, the highest '
          'benefit-cost ratio is not the answer. A ratio says how much each '
          'dollar returns; it is blind to how many dollars are on offer.',
    ),
    (
      'Line them up by cost',
      'First throw out anything whose own ratio is under one. Put the '
          'survivors in order, cheapest first. Then walk up the line one step '
          'at a time.',
    ),
    (
      'Ask about each step',
      'Does the EXTRA benefit of this step cover its EXTRA cost? If yes, '
          'take the step and keep going. If no, stay where you are. The '
          'comparison is always against the last option that survived, not the '
          'one printed above it.',
    ),
  ],
  spoken: [
    ('Each on its own', r'B/C \geq 1', 'every option must pay its way first'),
    (
      'Then each step',
      r'\Delta B/C = \frac{B_2 - B_1}{C_2 - C_1}',
      'the extra benefit, over the extra cost',
    ),
    (
      'Step up when',
      r'\Delta B/C \geq 1',
      'the extra benefit covers the extra cost',
    ),
  ],
  handbook: 'Handbook p. 231',
);

const rollbackBrief = BriefSection(
  title: 'Work a decision tree backwards',
  picture: rollbackPicture,
  steps: [
    (
      'Squares choose, circles do not',
      'A square is a decision you make. A circle is chance, where the world '
          'decides. Each branch out of a circle has a probability, and at any '
          'one circle they add up to one.',
    ),
    (
      'Start at the ends',
      'A circle is worth its endings weighted by how likely each is: four '
          'tenths of ten plus six tenths of five is seven. That always lands '
          'between the cheapest and dearest ending, leaning toward the likely '
          'one.',
    ),
    (
      'Then choose at the square',
      'Once every circle has one number, stand at the square and take the '
          'best branch: the lowest for costs, the highest for returns.',
    ),
    (
      'An unlabeled branch still counts',
      'If one branch has no probability written on it, it carries whatever '
          'is left over to make one. It is not zero.',
    ),
  ],
  spoken: [
    (
      'At a circle',
      r'EV = p_1 C_1 + p_2 C_2 + \cdots',
      'each ending times how likely it is, added up',
    ),
    (
      'Which sums to',
      r'\sum p_i = 1',
      'the probabilities at one circle add up to one',
    ),
    (
      'So',
      r'0.4(10) + 0.6(5) = 7',
      'four tenths of ten plus six tenths of five is seven',
    ),
  ],
  handbook: 'Handbook p. 231',
);

const irrBrief = BriefSection(
  title: 'The rate that makes the two sides balance',
  picture: irrPicture,
  steps: [
    (
      'Money out, money back',
      'Put a thousand dollars in today and get 1,150 back in a year. The '
          'return is the gain over what you PUT IN: 150 over 1,000, which is 15 '
          'percent. Not 150 over 1,150.',
    ),
    (
      'Over more years, find the balance',
      'With several cash flows, the internal rate of return is the interest '
          'rate at which everything coming in is worth exactly what went out. '
          'Try a rate: if the incoming side is heavier, try higher; if lighter, '
          'try lower.',
    ),
    (
      'It is a rate, not a number of dollars',
      'Things it gets confused with are not rates at all. Plain profit '
          'ignores time. A payback period is years. A salvage value is money.',
    ),
  ],
  spoken: [
    (
      'At the rate',
      r'PW_{\text{in}} - PW_{\text{out}} = 0',
      'what comes in and what goes out weigh the same today',
    ),
    (
      'One period',
      r'i = \frac{F - P}{P}',
      'the gain, divided by what you put in',
    ),
    (
      'So',
      r'\frac{1{,}150 - 1{,}000}{1{,}000} = 15\%',
      '150 over the thousand you put in',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const marrBrief = BriefSection(
  title: 'Over the bar or not',
  picture: marrPicture,
  steps: [
    (
      'The money has a minimum',
      'A company will not put money into a project unless it earns at least '
          'some rate, because the money could earn that elsewhere. That minimum '
          'is the hurdle, the MARR.',
    ),
    (
      'Compare the return to the bar',
      'If the project\'s rate of return reaches the hurdle, accept it. If '
          'not, reject it. Exactly on the bar is a pass: the project breaks even '
          'and nothing is lost.',
    ),
    (
      'What the test is not',
      'A positive return is not the test. A near miss is not a pass. The '
          'same project can pass one year and fail the next, because the hurdle '
          'belongs to the money, not the project.',
    ),
    (
      'Choosing between two projects',
      'The hurdle does not pick between two options that both clear it. For '
          'that, take the rate of return on the DIFFERENCE between them and put '
          'that against the bar.',
    ),
  ],
  spoken: [
    ('Accept', r'IRR \geq MARR', 'the return reaches the hurdle'),
    ('Reject', r'IRR < MARR', 'the return falls short'),
    (
      'Choosing between two',
      r'IRR_{\Delta} \geq MARR',
      'the return on the extra money reaches the hurdle',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const timingBrief = BriefSection(
  title: 'A rate is not a total',
  picture: timingPicture,
  steps: [
    (
      'Sooner earns a higher rate',
      'The same 1,200 back on a thousand is 20 percent if it arrives in one '
          'year. If it takes two years, the money earned about 9.5 percent each '
          'year. Same dollars, half the rate.',
    ),
    (
      'A smaller stake earns a higher rate',
      'Earning 150 on a thousand is 15 percent. Earning the same 150 on two '
          'thousand is 7.5 percent. The rate is money per year on the money at '
          'risk.',
    ),
    (
      'Doubling everything changes nothing',
      'Multiply every cash flow in a project by the same number and the rate '
          'stays exactly where it was. That is why the biggest total on the page '
          'is so often the lower return.',
    ),
  ],
  spoken: [
    (
      'Sooner',
      r'\frac{1{,}200}{1{,}000} - 1 = 20\%',
      'a fifth more, in one year',
    ),
    (
      'Later',
      r'\sqrt{\frac{1{,}200}{1{,}000}} - 1 = 9.5\%',
      'the same gain spread over two years of compounding',
    ),
    (
      'Scaled',
      r'\frac{2{,}300}{2{,}000} = \frac{1{,}150}{1{,}000}',
      'twice the dollars, the same 15 percent',
    ),
  ],
  handbook: 'Handbook p. 229',
);

const macrsBrief = BriefSection(
  title: 'Read the table, not the name',
  picture: macrsPicture,
  steps: [
    (
      'Writing a cost off over the years',
      'A machine loses value as it ages, and the tax rules let a business '
          'deduct that loss a slice at a time. Straight line takes the salvage '
          'off first and cuts the rest into equal slices.',
    ),
    (
      'MACRS is front-loaded',
      'MACRS uses percentages the handbook prints for you: big slices early, '
          'small ones late. It deducts the FULL cost with no salvage taken off, '
          'and it runs the value all the way to zero.',
    ),
    (
      'The name is not the number of years',
      'Five year property is written off over SIX years, because the first '
          'and last years each get half a year. Three year property takes four; '
          'seven year takes eight.',
    ),
    (
      'Column first, then row',
      'Find the column for the property class, then count down the rows to '
          'the year. Multiply that percentage by the full cost.',
    ),
  ],
  spoken: [
    (
      'Straight line',
      r'D_j = \frac{C - S_n}{n}',
      'cost minus salvage, cut into n equal slices',
    ),
    (
      'MACRS',
      r'D_j = d_j \times C',
      'the year\'s percentage from the table, times the full cost',
    ),
    (
      'So',
      r'0.32 \times 60{,}000 = 19{,}200',
      'year two of five year property, on a sixty thousand machine',
    ),
  ],
  handbook: 'Handbook p. 231, MACRS factors',
);

const bookValueBrief = BriefSection(
  title: 'What has not been written off yet',
  picture: bookValuePicture,
  steps: [
    (
      'The cost is one bar',
      'Picture what the machine cost as one long bar. Every year of '
          'depreciation bites a slice off the left end. The book value is the '
          'part still standing.',
    ),
    (
      'All the years so far, not just this one',
      'Book value is the cost minus EVERY slice taken so far. The slices '
          'already gone add up to the accumulated depreciation. What is gone and '
          'what is left always add back up to the cost.',
    ),
    (
      'Not what it would sell for',
      'Book value is a number in the accounts. Under MACRS it walks to zero '
          'on a schedule while the machine may still be worth real money.',
    ),
  ],
  spoken: [
    (
      'Book value',
      r'BV_j = C - \sum_{k=1}^{j} D_k',
      'the cost, minus every year\'s depreciation up to now',
    ),
    (
      'Which means',
      r'BV_j + \textstyle\sum D = C',
      'what is left plus what is gone is the cost',
    ),
    (
      'So',
      r'500{,}000 - 281{,}350 = 218{,}650',
      'half a million, minus what has gone, is what is left',
    ),
  ],
  handbook: 'Handbook p. 231',
);

const inflationBrief = BriefSection(
  title: 'Match the rate to the kind of dollars',
  picture: inflationPicture,
  steps: [
    (
      'Two kinds of dollars',
      'Prices creep up over time. ACTUAL dollars are the money that will '
          'really change hands each year, creeping up with them. CONSTANT '
          'dollars are priced in today\'s money, with that creep stripped out.',
    ),
    (
      'Each kind has its own rate',
      'Actual dollars already have inflation inside them, so discount them '
          'at the combined rate d. Constant dollars do not, so discount them at '
          'the real rate i. Cross them and you charge for inflation twice, or '
          'not at all.',
    ),
    (
      'The combined rate has three parts',
      'Adding the real rate and the inflation rate is close when both are '
          'small. The third term, their product, is what is missing, and at '
          'large rates it is most of a point.',
    ),
  ],
  spoken: [
    (
      'Combined',
      r'd = i + f + i f',
      'the real rate, plus inflation, plus the two multiplied',
    ),
    (
      'Actual dollars',
      r'\text{discount at } d',
      'money with inflation in it uses the combined rate',
    ),
    (
      'Constant dollars',
      r'\text{discount at } i',
      'today\'s money uses the real rate',
    ),
  ],
  handbook: 'Handbook p. 230',
);

const resolveBrief = BriefSection(
  title: 'Which part gets the cosine',
  picture: resolvePicture,
  steps: [
    (
      'A slanted pull does two jobs',
      'Pull a sled with a rope that slants upward and you drag it forward AND '
          'lift it a little. Splitting the pull into those two jobs is resolving '
          'it. Draw it as a right triangle: the pull is the long slanted side, '
          'the two jobs are the flat side and the upright one.',
    ),
    (
      'The cosine belongs to the axis the angle opens from',
      'If the angle is measured up from the flat, the flat part gets the '
          'cosine. If it is measured across from the upright, the upright part '
          'gets it. Nothing else decides which.',
    ),
    (
      'Given a slope instead, there is no trig at all',
      'Sometimes you are handed a shape, like 5 across and 12 up. Then the '
          'flat part is 5 over 13 of the pull and the upright part is 12 over 13. '
          'Just the sides of the triangle.',
    ),
    (
      'A check that costs nothing',
      'Each part is always SHORTER than the whole pull, because it is a short '
          'side of the triangle. A part that comes out equal to the pull means '
          'something was divided by the wrong number.',
    ),
  ],
  spoken: [
    (
      'Angle up from the flat',
      r'F_x = F\cos\theta, \; F_y = F\sin\theta',
      'the flat part is the pull times cosine, the upright part times sine',
    ),
    (
      'Given a slope',
      r'F_x = \frac{x}{R} F, \; R = \sqrt{x^2 + y^2}',
      'the flat run over the slanted length, times the pull',
    ),
    (
      'So',
      r'\frac{5}{13}(1{,}300) = 500',
      'five thirteenths of thirteen hundred is five hundred',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const momentBrief = BriefSection(
  title: 'The arm is the shortest distance to the line',
  picture: momentPicture,
  steps: [
    (
      'A push that turns something',
      'Push on a door near the hinge and it barely moves. Push at the handle '
          'and it swings. Same push, different turning effect, because the '
          'distance changed. That turning effect is a moment: the push times a '
          'distance.',
    ),
    (
      'Which distance, exactly',
      'Draw the line the push runs along, stretched out both ways. The arm is '
          'the SHORTEST distance from the pin to that line, the one that meets it '
          'square on. Not the distance to where you are pushing.',
    ),
    (
      'So a slanted bar is almost never the answer',
      'A load hanging off a slanted boom pulls straight down, so its line is '
          'vertical, and the shortest distance to a vertical line is a FLAT one. '
          'The boom length is the distance to where the force sits, which is a '
          'different thing.',
    ),
    (
      'Straight through the pin means nothing happens',
      'If the line passes through the pin, the arm is zero and the push '
          'cannot turn it at all, however hard you shove.',
    ),
  ],
  spoken: [
    (
      'In general',
      r'M = F d_{\perp}',
      'the force, times the shortest distance to its line',
    ),
    (
      'In two dimensions',
      r'M_z = x F_y - y F_x',
      'each part of the force times its own distance, one taken from the other',
    ),
    (
      'A couple',
      r'M = F d',
      'two equal opposite pushes: the same turn about any point',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const senseBrief = BriefSection(
  title: 'Pick a turning direction and keep it',
  picture: sensePicture,
  steps: [
    (
      'Which side you push on matters',
      'Sit on a seesaw. Push down on the right end and it turns one way. Push '
          'down on the LEFT end and it turns the other. Same downward push, '
          'opposite turns, because they are on opposite sides of the pin.',
    ),
    (
      'Two things decide the turn',
      'Which way the push points, and which side of the pin it sits on. Flip '
          'either one and the turn flips. Flip both and it is back where it '
          'started.',
    ),
    (
      'Choose your positive at the start',
      'Say clockwise is positive, or say it is negative. Either works. What '
          'ruins an answer is changing your mind halfway through, because then '
          'the numbers still add up and the result is wrong.',
    ),
    (
      'Two opposite pushes can add up',
      'Equal pushes in opposite directions on opposite sides of the pin do '
          'not cancel. They both turn it the same way, and their turns add.',
    ),
  ],
  spoken: [
    (
      'Which way it turns',
      r'M_z = x F_y - y F_x',
      'positive is one way round, negative the other',
    ),
    (
      'Positive',
      r'\text{counterclockwise, if you choose it so}',
      'your choice, kept for the whole problem',
    ),
    (
      'Through the point',
      r'd_{\perp} = 0 \;\Rightarrow\; M = 0',
      'no arm means no turn',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const supportsBrief = BriefSection(
  title: 'Whatever a support stops, it supplies',
  picture: supportsPicture,
  steps: [
    (
      'Take the beam off its supports',
      'To work out the forces, you lift the beam away and draw in what each '
          'support was doing for it. The rule is simple: whatever movement the '
          'support was preventing, it must have been pushing to prevent.',
    ),
    (
      'A roller stops one thing, so gives one arrow',
      'It can roll sideways but not sink, so it pushes square to whatever it '
          'rolls on. On a slope that push is not vertical, and on a wall it is '
          'sideways. A cable is the same, except it can only pull.',
    ),
    (
      'A pin stops the end going anywhere, so gives two',
      'It holds the end in place both ways. But the beam can still swivel on '
          'it, like a door on a hinge, so there is no turn.',
    ),
    (
      'A fixed end stops the swivel too, so gives three',
      'Two pushes and a turn. Think of a beam cemented into a wall: the wall '
          'stops it moving and stops it rotating.',
    ),
  ],
  spoken: [
    ('Roller or cable', r'\text{1 unknown}', 'one push, square to the surface'),
    ('Pin', r'\text{2 unknowns}', 'two pushes, no turn'),
    ('Fixed', r'\text{3 unknowns}', 'two pushes and a turn'),
  ],
  handbook: 'Handbook p. 94',
);

const resultantBrief = BriefSection(
  title: 'A spread load acts at its balance point',
  picture: resultantPicture,
  steps: [
    (
      'Snow on a roof, not a brick on a roof',
      'Some loads sit at one spot. Others are spread along, like snow or '
          'water or the weight of the beam itself. To work with a spread load you '
          'swap it for one single push that does the same job.',
    ),
    (
      'How big, and where',
      'How big: the AREA of the load shape drawn on the beam. Where: at the '
          'balance point of that shape.',
    ),
    (
      'Even load: the middle of the part it covers',
      'Careful, that is the middle of the LOADED stretch, not the middle of '
          'the beam, unless the load covers all of it.',
    ),
    (
      'Triangle load: a third in from the heavy end',
      'More load sits at the thick end, so the single push sits closer to '
          'that end. Using the far tip instead is what doubles a cantilever '
          'answer.',
    ),
  ],
  spoken: [
    (
      'Even',
      r'W = wL \text{ at } L/2',
      'load per length times length, acting at the middle',
    ),
    (
      'Triangle',
      r'W = \tfrac{1}{2} w L',
      'half the peak load times the length, acting a third in from the heavy end',
    ),
    (
      'So',
      r'3(4) = 12',
      'three per meter over four meters is twelve, acting at two meters',
    ),
  ],
  handbook: 'Handbook p. 94',
);

const zeroForceBrief = BriefSection(
  title: 'Some bars carry nothing at all',
  picture: zeroForcePicture,
  steps: [
    (
      'A truss is bars pinned at their ends',
      'Every bar can only pull or push along its own length, like a rope or a '
          'stick. At each pin, all the pulls and pushes have to cancel out, or '
          'the pin would fly off.',
    ),
    (
      'Two bars meeting with nothing else there',
      'They point different ways. The only way two forces in different '
          'directions cancel is if both are zero. So both bars carry nothing.',
    ),
    (
      'Three bars, two of them in a straight line',
      'The two in line push straight against each other. That leaves the odd '
          'one out with nothing to balance against, so it carries nothing.',
    ),
    (
      'Hang anything on that pin and the rule is off',
      'Both rules need the pin EMPTY: no load, no support. A weight hung '
          'there gives the odd bar something to balance, and it goes to work.',
    ),
  ],
  spoken: [
    ('Two at an empty pin', r'F_1 = F_2 = 0', 'both carry nothing'),
    (
      'Three, two in a line',
      r'F_{\text{odd}} = 0',
      'the one out of line carries nothing',
    ),
    (
      'What switches it off',
      r'\text{any load or support at that pin}',
      'the pin has to be empty',
    ),
  ],
  handbook: 'Handbook p. 95',
);

const senseOfForceBrief = BriefSection(
  title: 'Stretched or squashed, and how the sign tells you',
  picture: senseOfForcePicture,
  steps: [
    (
      'A bar is being pulled or squeezed',
      'Push down on the middle of a truss and it sags a little. The bars '
          'along the bottom get stretched longer. The bars along the top get '
          'squeezed shorter. Stretched is tension, squeezed is compression.',
    ),
    (
      'Guess tension every time',
      'When you draw an unknown bar force, always draw it PULLING away from '
          'the pin, as if the bar were stretched. Do it for every bar, without '
          'thinking about it.',
    ),
    (
      'Then the sign corrects you for free',
      'Work the numbers out. A positive answer means the bar really is '
          'stretched. A negative answer means it is squashed. You never have to '
          'guess right.',
    ),
    (
      'Say which one in the answer',
      '"4.2 kilonewtons" is not a finished answer on this exam. "4.2 '
          'kilonewtons compression" is. A cantilever flips it: its top is '
          'stretched and its bottom squeezed.',
    ),
  ],
  spoken: [
    (
      'The guess',
      r'\text{draw every bar in tension}',
      'every unknown drawn pulling away from the pin',
    ),
    ('Positive', r'T > 0', 'stretched, so tension'),
    ('Negative', r'T < 0', 'squashed, so compression'),
  ],
  handbook: 'Handbook p. 95',
);

const sectionBrief = BriefSection(
  title: 'Cut straight through to the bar you want',
  picture: sectionPicture,
  steps: [
    (
      'Walking pin by pin is slow',
      'You can solve a truss one pin at a time, but if the bar you want is in '
          'the middle you have to walk half the truss to reach it.',
    ),
    (
      'So cut the truss in half instead',
      'Slice an imaginary line right through it, throw one half away, and put '
          'the three equilibrium equations on the half you kept. The bars you cut '
          'become forces on that half.',
    ),
    (
      'Two rules for where to cut',
      'It has to go through the bar you were asked about. And it must cross '
          'no more than three bars in total, because three equations cannot find '
          'four unknowns. The cut does not have to be vertical.',
    ),
    (
      'The trick that isolates one bar',
      'Take moments about the point where the other two cut bars meet. Those '
          'two pass through your pivot, so they have no arm and drop out, and the '
          'bar you want falls out on its own.',
    ),
  ],
  spoken: [
    (
      'On the half you keep',
      r'\sum F_x = 0, \; \sum F_y = 0, \; \sum M = 0',
      'the same three equations, on the piece that is left',
    ),
    ('The limit', r'\text{bars cut} \le 3', 'no more than three bars crossed'),
    (
      'The shortcut',
      r'\sum M \text{ about where the other two meet}',
      'the other two drop out, leaving the one you want',
    ),
  ],
  handbook: 'Handbook p. 95',
);

const deformationBrief = BriefSection(
  title: 'What makes a bar stretch',
  picture: deformationPicture,
  steps: [
    (
      'Pull on it',
      'Hang a weight from a metal bar and the bar gets a tiny bit longer. '
          'Pull twice as hard and it stretches twice as far.',
    ),
    (
      'Long and thin stretch more',
      'A longer bar has more metal to stretch, so it moves further. A '
          'thicker bar shares the pull across more metal, so it moves less. A '
          'stiffer material, steel instead of aluminum, moves less too.',
    ),
    (
      'Stress is a different question',
      'Stress is the pull divided by how thick the bar is. Length is not '
          'in it. Two bars of the same thickness under the same pull carry the '
          'same stress, even if one is longer and stretches further.',
    ),
  ],
  spoken: [
    (
      'Stress',
      r'\sigma = \frac{P}{A}',
      'the pull, divided by the area it is spread over',
    ),
    (
      'Stretch',
      r'\delta = \frac{PL}{AE}',
      'pull times length on top, area times stiffness underneath',
    ),
    (
      'Strain',
      r'\varepsilon = \frac{\delta}{L}',
      'the stretch, as a share of the original length',
    ),
  ],
  handbook: 'Handbook p. 130',
);

const unitsBrief = BriefSection(
  title: 'Pick one set of units and stay in it',
  picture: unitsPicture,
  steps: [
    (
      'Same bar, two names',
      'A bar two meters long is also two thousand millimeters long. Same '
          'bar. If you put 2 into one part of a formula and 2000 into another, '
          'the answer comes out a thousand times wrong.',
    ),
    (
      'Why the mistake hides',
      'The formula does not complain. The units still cancel the way they '
          'should, so nothing looks off. Only the size of the number is wrong, '
          'and by then you have moved on.',
    ),
    (
      'The safe set',
      'Convert everything before you start. Newtons, millimeters and '
          'newtons per square millimeter go together and never need converting '
          'again, because a megapascal IS a newton per square millimeter.',
    ),
    (
      'Strain has no unit',
      'Strain is a length divided by a length, so the units cancel to '
          'nothing. A strain quoted in millimeters or percent per meter is a '
          'strain someone has misread.',
    ),
  ],
  spoken: [
    (
      'The set that never needs converting',
      r'\mathrm{N},\; \mathrm{mm},\; \mathrm{N/mm^2}',
      'newtons, millimeters, and newtons per square millimeter',
    ),
    (
      'And that last one is',
      r'1\ \mathrm{MPa} = 1\ \mathrm{N/mm^2}',
      'one megapascal is one newton per square millimeter',
    ),
    (
      'Strain',
      r'\varepsilon = \frac{\Delta L}{L}',
      'a length over a length, so no unit at all',
    ),
  ],
  handbook: 'Handbook p. 130',
);

const thermalBrief = BriefSection(
  title: 'Heat only builds stress when the bar cannot move',
  picture: thermalPicture,
  steps: [
    (
      'Warm it and it grows',
      'Every metal gets a little longer when it warms and a little shorter '
          'when it cools. A bar free at one end just grows. Nothing pushes on '
          'it, so it carries no stress at all.',
    ),
    (
      'Hold it and it pushes back',
      'Now hold both ends so the bar cannot grow. It still wants to. The '
          'growth it was not allowed to make turns into a squeeze: the bar is '
          'in compression. Cool a held bar and it is pulled instead: tension.',
    ),
    (
      'A gap changes the story',
      'Leave a small gap at one end and the bar grows into the gap for '
          'free. If it never reaches the wall, no stress. If it closes the gap '
          'and keeps trying to grow, only the leftover growth becomes stress.',
    ),
    (
      'Length drops out',
      'A longer bar wants to grow more, but a longer bar is also easier to '
          'squeeze by the same amount. The two cancel, so a fully held bar\'s '
          'stress depends only on the metal and how much it warmed.',
    ),
  ],
  spoken: [
    (
      'Free movement',
      r'\delta_t = \alpha L \Delta T',
      'how much it wants to grow: a material number, times the length, times the temperature change',
    ),
    (
      'Held at both ends',
      r'\sigma_t = E \alpha \Delta T',
      'the stress: stiffness times that material number times the temperature change',
    ),
    (
      'With a gap to close first',
      r'\sigma_t = \frac{E(\delta_t - \text{gap})}{L}',
      'only the growth left over after the gap closes becomes stress',
    ),
  ],
  handbook: 'Handbook p. 130',
);

const polarJBrief = BriefSection(
  title: 'Twisting a shaft: the outside works hardest',
  picture: polarJPicture,
  steps: [
    (
      'Twist a shaft',
      'Grab a round bar at both ends and twist. The metal near the outside '
          'has to turn the furthest, so it is stressed the most. The metal in '
          'the middle barely turns and barely works.',
    ),
    (
      'That is why shafts are hollow',
      'Since the middle does so little, you can take it out and lose very '
          'little strength while saving a lot of weight. The stress is still '
          'highest at the outside, so c is always the OUTER radius.',
    ),
    (
      'J measures how the metal is spread out',
      'J adds up how far every bit of metal sits from the center. It '
          'grows with the fourth power of the diameter: twice the diameter, '
          'sixteen times the J. To remove a bore you subtract fourth powers, '
          'never diameters or areas.',
    ),
    (
      'Two easy slips',
      'J is pi d to the fourth over THIRTY-TWO. The bending version, I, is '
          'over sixty-four and is half as big, so using it doubles your answer. '
          'And c is the radius, not the diameter, or you double it again.',
    ),
  ],
  spoken: [
    (
      'Round shaft',
      r'\tau = \frac{Tc}{J}',
      'the twist stress: torque times outer radius, over J',
    ),
    (
      'Solid',
      r'J = \frac{\pi d^4}{32}',
      'pi times the diameter to the fourth, over thirty-two',
    ),
    (
      'Hollow',
      r'J = \frac{\pi (d_o^4 - d_i^4)}{32}',
      'the same, with the bore\'s fourth power taken away',
    ),
    (
      'And',
      r'c = \frac{d_o}{2},\quad J = 2I',
      'c is half the outer diameter, and J is twice the bending I',
    ),
  ],
  handbook: 'Handbook p. 133',
);

const twistBrief = BriefSection(
  title: 'One shaft, two questions',
  picture: twistPicture,
  steps: [
    (
      'How hard is the metal working',
      'That is the stress. It depends on how much torque you apply and on '
          'the shape of the shaft, and nothing else. Make the shaft longer and '
          'the stress does not change. Switch to a softer metal and it does '
          'not change either.',
    ),
    (
      'How far does the end turn',
      'That is the twist. It cares about everything: more torque, a longer '
          'shaft, a thinner shaft or a softer metal all turn the end further. '
          'A long shaft and a short one at the same stress twist by very '
          'different amounts.',
    ),
    (
      'Which stiffness',
      'Twisting is a shearing kind of stretch, so it uses G, the shear '
          'stiffness, never E. For steel G is about 80 GPa while E is 200.',
    ),
  ],
  spoken: [
    (
      'Stress',
      r'\tau = \frac{Tc}{J}',
      'torque times outer radius, over J. No length, no material',
    ),
    (
      'Twist, in radians',
      r'\phi = \frac{TL}{GJ}',
      'torque times length on top, shear stiffness times J underneath',
    ),
    (
      'Stiffness',
      r'k = \frac{T}{\phi} = \frac{GJ}{L}',
      'the torque it takes to turn the end one radian',
    ),
    (
      'The two moduli',
      r'G = \frac{E}{2(1+\nu)}',
      'G comes from E and Poisson\'s ratio',
    ),
  ],
  handbook: 'Handbook p. 134',
);

const thinWallBrief = BriefSection(
  title: 'A thin tube uses the area its wall wraps around',
  picture: thinWallPicture,
  steps: [
    (
      'A thin tube',
      'A tube with a thin wall, round or square or any shape, twists in a '
          'simple way: the shear runs round the wall like water in a ring '
          'pipe, the same everywhere along it.',
    ),
    (
      'The area is the one inside the wall',
      'The formula wants an area, and it is NOT the area of the metal. '
          'Draw a line halfway through the wall, all the way round, and take '
          'everything inside that line, metal or not. That is the area.',
    ),
    (
      'Why not the metal',
      'On a thin wall the metal is a sliver, a small fraction of the space '
          'the tube encloses. Use it and the stress comes out many times too '
          'big. The bore and the outside face sit close to the right answer, '
          'on either side of it.',
    ),
    (
      'When the shortcut stops working',
      'Thin means the wall is under about a tenth of the radius. Thicker '
          'than that and the stress is no longer even through the wall, so '
          'go back to the round-shaft formula.',
    ),
  ],
  spoken: [
    (
      'Thin-walled tube',
      r'\tau = \frac{T}{2\,t\,A_m}',
      'torque, over twice the wall thickness times the enclosed area',
    ),
    (
      'Where A is',
      r'A_m = \text{inside the middle of the wall}',
      'the space the wall\'s centerline wraps around',
    ),
    ('Good while', r't < 0.1\,r', 'the wall is under a tenth of the radius'),
  ],
  handbook: 'Handbook p. 133',
);

const curveBrief = BriefSection(
  title: 'Pull a bar until it breaks and draw what happened',
  picture: curvePicture,
  steps: [
    (
      'The straight part',
      'At first the bar stretches in step with the pull: double the pull, '
          'double the stretch. The line is straight and its slope is E, how '
          'stiff the metal is. Let go anywhere here and the bar springs back '
          'to its old length.',
    ),
    (
      'Where the straight part ends',
      'The PROPORTIONAL LIMIT is where the line stops being straight. The '
          'ELASTIC LIMIT is a hair past it, the last point the bar still '
          'springs back from. On a real curve they sit so close that nobody '
          'separates them.',
    ),
    (
      'It gives way',
      'At the YIELD POINT the bar keeps stretching without you pulling any '
          'harder. Mild steel has a flat run here; aluminum does not. Past '
          'this the bar is permanently longer.',
    ),
    (
      'The top, and the end',
      'The ULTIMATE STRENGTH is the highest the curve gets. Right there '
          'the bar starts to neck, thinning in one spot. It BREAKS at a lower '
          'stress than the top, because the chart keeps dividing by the '
          'original thickness while the bar has grown thinner.',
    ),
  ],
  spoken: [
    (
      'Slope of the straight run',
      r'E = \frac{\Delta\sigma}{\Delta\varepsilon}',
      'stiffness: how much stress it takes for each bit of strain',
    ),
    (
      'Top of the curve',
      r'\sigma_u',
      'the ultimate strength, where necking starts',
    ),
    (
      'Engineering stress uses',
      r'A_0',
      'the original area, all the way to the break',
    ),
  ],
  handbook: 'Handbook p. 129',
);

const stiffStrongBrief = BriefSection(
  title: 'Stiff, strong and stretchy are three different things',
  picture: stiffStrongPicture,
  steps: [
    (
      'Stiff: how hard it is to move at all',
      'Read the slope of the straight part. A steep line means a lot of '
          'pull for a little stretch. That is E. Steel is stiff; rubber is not.',
    ),
    (
      'Strong: how high the curve gets',
      'Read the height. The yield stress is where the metal stops being '
          'usable; the ultimate is the most it can ever carry. A high curve is '
          'a strong material, whatever its slope.',
    ),
    (
      'Stretchy: how far it goes before it breaks',
      'Read how far the curve runs to the right. That is ductility, quoted '
          'as percent elongation. Mild steel runs a long way; cast iron stops '
          'almost at once.',
    ),
    (
      'They do not travel together',
      'A material can be strong and brittle, like cast iron or a hardened '
          'bolt. It can be weak and very stretchy, like soft copper. Two tells '
          'for brittle: yield and ultimate almost equal, and an elongation of '
          'a percent or two.',
    ),
  ],
  spoken: [
    (
      'Stiff',
      r'E = \frac{\sigma}{\varepsilon}',
      'the slope of the straight run',
    ),
    (
      'Strong',
      r'\sigma_y,\ \sigma_u',
      'the yield and ultimate stresses, the height of the curve',
    ),
    (
      'Stretchy',
      r'\%\,El = \frac{L_f - L_0}{L_0}\times 100',
      'how much longer it got before breaking, as a percent',
    ),
  ],
  handbook: 'Handbook p. 129',
);

const linkedBrief = BriefSection(
  title: 'Three material numbers, tied together',
  picture: linkedPicture,
  steps: [
    (
      'Pull it and it gets thinner',
      'Stretch a bar and it also gets a little thinner across, like a '
          'rubber band. Poisson\'s ratio, nu, says how much thinner for each '
          'bit of stretch. For most metals it is about 0.3.',
    ),
    (
      'Three numbers, one link',
      'E is stiffness in a pull, G is stiffness in a twist, and nu ties '
          'them. Know any two and one equation hands you the third. They are '
          'not three separate facts about a material.',
    ),
    (
      'Watch the 2',
      'The 2 sits underneath, so G comes out well under half of E: about '
          '0.38 of it at a nu of 0.3. If your G comes out bigger than E, the '
          'fraction is upside down.',
    ),
    (
      'Skip the arithmetic you do not need',
      'A question may hand you lengths and diameters before and after. If '
          'E and nu are already given, that page of arithmetic changes nothing. '
          'Read what is asked and take the shortest road to it.',
    ),
  ],
  spoken: [
    ('The link', r'G = \frac{E}{2(1+\nu)}', 'E, over two times one plus nu'),
    (
      'E from a test',
      r'E = \frac{\sigma}{\varepsilon}',
      'a stress divided by the strain it caused',
    ),
    (
      "Poisson's ratio",
      r'\nu = -\frac{\varepsilon_{lat}}{\varepsilon_{axial}}',
      'the sideways shrink, divided by the lengthwise stretch',
    ),
    (
      'For steel',
      r'\nu \approx 0.3,\quad G \approx 0.38E',
      'nu about 0.3, so G is a bit over a third of E',
    ),
  ],
  handbook: 'Handbook p. 130',
);

const slopeRulesBrief = BriefSection(
  title: 'Two rules draw both diagrams',
  picture: slopeRulesPicture,
  steps: [
    (
      'Push on a beam',
      'Rest a plank on two supports and press down on it. Inside the plank '
          'two things happen at every point: it is being sliced across, which '
          'is SHEAR, and it is being bent, which is MOMENT. The two diagrams '
          'just plot each one along the length.',
    ),
    (
      'The shear picture',
      'Where nothing is pushing on a stretch of beam, the shear stays FLAT. '
          'Where a load is spread along it, the shear SLOPES down, steadily, '
          'because each bit of load takes a bit away.',
    ),
    (
      'The moment picture',
      'The moment climbs as fast as the shear is tall. A flat shear gives a '
          'STRAIGHT moment line. A sloping shear gives a CURVED moment. Drawing '
          'that curve as two straight lines to a peak is the commonest wrong '
          'diagram there is.',
    ),
    (
      'Read it backwards too',
      'The change in moment between two points is the area under the shear '
          'between them. That is the same rule read the other way, and it is '
          'how you get the numbers.',
    ),
  ],
  spoken: [
    (
      'Load to shear',
      r'\frac{dV}{dx} = -w(x)',
      'the slope of the shear is minus the load at that point',
    ),
    (
      'Shear to moment',
      r'\frac{dM}{dx} = V(x)',
      'the slope of the moment is the shear at that point',
    ),
    (
      'Which is to say',
      r'M_B - M_A = \int_A^B V\,dx',
      'moment changes by the area under the shear',
    ),
  ],
  handbook: 'Handbook p. 140',
);

const peakBrief = BriefSection(
  title: 'The moment is biggest where the shear crosses zero',
  picture: peakPicture,
  steps: [
    (
      'Why you want the peak',
      'A beam is sized for its worst bending. So before working out how big '
          'the moment is, you find WHERE it is biggest.',
    ),
    (
      'Watch the shear',
      'While the shear is above zero the moment is still climbing. The '
          'instant the shear drops below zero the moment starts coming back '
          'down. So the top of the moment is exactly where the shear crosses '
          'zero.',
    ),
    (
      'Where that usually is',
      'Under one load, it is under the load, wherever the load sits. Under '
          'an even spread on a beam held at both ends, it is the middle. On a '
          'cantilever it is at the wall. Over a support on an overhang it is '
          'the support, bending the other way.',
    ),
    (
      'Midspan is a habit, not a rule',
      'Midspan is right often enough to become a reflex. Move the load off '
          'center and the peak moves with it.',
    ),
  ],
  spoken: [
    ('Peak where', r'V = 0', 'the shear passes through zero'),
    (
      'Load at midspan',
      r'M_{max} = \frac{PL}{4}',
      'the load times the span, over four',
    ),
    (
      'Load anywhere',
      r'M_{max} = \frac{Pab}{L}',
      'load times the two distances to the supports, over the span',
    ),
    (
      'Even spread',
      r'M_{max} = \frac{wL^2}{8}',
      'load per length times span squared, over eight',
    ),
  ],
  handbook: 'Handbook p. 140',
);

const jumpBrief = BriefSection(
  title: 'What each thing does at the point it acts',
  picture: jumpPicture,
  steps: [
    (
      'A force steps the shear',
      'A push straight down makes the shear diagram drop by exactly that '
          'much, right there. A push up, like a support holding the beam, '
          'makes it jump up. The moment does not jump: it only changes the '
          'angle it is climbing at, so the moment line bends without a break.',
    ),
    (
      'A couple steps the moment',
      'A couple is a twist applied at one spot with no push up or down. It '
          'makes the moment diagram jump by its own size and leaves the shear '
          'exactly as it was.',
    ),
    (
      'A spread load steps nothing',
      'Where a spread load starts or stops, nothing jumps. The shear just '
          'changes from flat to sloping, or back.',
    ),
    (
      'The ends',
      'A pin or a roller cannot hold a moment, so at those ends the moment '
          'is zero. A simply supported beam starts and finishes at zero.',
    ),
  ],
  spoken: [
    (
      'A force',
      r'\Delta V = \pm P',
      'the shear steps by the force; the moment only bends',
    ),
    (
      'A couple',
      r'\Delta M = \pm C',
      'the moment steps by the couple; the shear is untouched',
    ),
    ('A pin or roller end', r'M = 0', 'no moment at a pinned or rolling end'),
  ],
  handbook: 'Handbook p. 140',
);

const fiberBrief = BriefSection(
  title: 'Bending and shear live in opposite places',
  picture: fiberPicture,
  steps: [
    (
      'Bend a beam',
      'Bend a plank downward and the top gets squeezed while the bottom '
          'gets stretched. Right in the middle of the depth nothing is '
          'squeezed or stretched at all. That middle line is the neutral axis.',
    ),
    (
      'Bending is worst at the faces',
      'The further a fiber sits from the neutral axis, the more it is '
          'stretched or squeezed. So bending stress is zero in the middle and '
          'biggest at the top and bottom faces. The c in the formula is that '
          'distance, and the face decides the beam.',
    ),
    (
      'Shear is worst in the middle',
      'Shear does the opposite. It is zero at the faces and biggest at the '
          'neutral axis, in a smooth hump. On a rectangle the peak is one and a '
          'half times the plain average.',
    ),
    (
      'Which face, and where the middle is',
      'Sagging stretches the bottom; over a support it is the top that '
          'stretches, which is why reinforcement moves there. And the neutral '
          'axis is the centroid, which is halfway up only for a symmetric '
          'section.',
    ),
  ],
  spoken: [
    (
      'Bending, at distance c',
      r'\sigma = \frac{Mc}{I}',
      'moment times distance from the middle, over I',
    ),
    (
      'Worst shear in a rectangle',
      r'\tau_{max} = \frac{3V}{2A}',
      'one and a half times the shear spread over the area',
    ),
    (
      'The neutral axis is',
      r'\text{the centroid}',
      'the balance point of the section',
    ),
  ],
  handbook: 'Handbook p. 135',
);

const cutBrief = BriefSection(
  title: 'Q and b both belong to the cut',
  picture: cutPicture,
  steps: [
    (
      'Pick a place',
      'The shear formula answers for ONE height in the section, the cut. '
          'Move the cut and its two awkward ingredients, b and Q, both change.',
    ),
    (
      'b is the width at the cut',
      'Not the widest part of the section. On an I-beam just under the '
          'flange, b is the thin web. Use the flange width instead and the '
          'answer is out by a factor of fifteen.',
    ),
    (
      'Q is the material beyond the cut',
      'Take everything on one side of the cut. Q is that area times the '
          'distance from ITS OWN middle to the neutral axis. Either side gives '
          'the same number, because the two sides balance. Take the whole '
          'section and Q is zero.',
    ),
    (
      'Why the rectangle has a shortcut',
      'On a rectangle the width never changes with height, so b is always '
          'the same and the formula collapses to three V over two A.',
    ),
  ],
  spoken: [
    (
      'Shear at a cut',
      r'\tau = \frac{VQ}{Ib}',
      'shear times Q, over I times the width at the cut',
    ),
    (
      'Q is',
      r'Q = A_{beyond}\,\bar{y}_{beyond}',
      'the area beyond the cut, times its distance to the middle',
    ),
    (
      'b is',
      r'\text{the width AT the cut}',
      'how wide the material is right there',
    ),
    (
      'Shear flow, for the fixings',
      r'q = \frac{VQ}{I}',
      'the same without b: force per length along the cut',
    ),
  ],
  handbook: 'Handbook p. 135',
);

const governsBrief = BriefSection(
  title: 'What each stress answers to',
  picture: governsPicture,
  steps: [
    (
      'Depth matters most',
      'Stand a plank on edge and it hardly bends. Lay it flat and it sags. '
          'Same wood, same load. Depth is in the bending formula squared, so '
          'twice the depth is a quarter of the bending stress. Shear only '
          'sees the area, so it halves.',
    ),
    (
      'Span moves bending, not shear',
      'Make a beam twice as long under the same load and the bending stress '
          'doubles, while each support carries exactly what it did. That is '
          'why a long beam is a bending problem and a short stubby one is a '
          'shear problem.',
    ),
    (
      'The material is in neither',
      'A steel beam and a timber beam of the same size under the same load '
          'carry the SAME stresses. What steel has is more strength to meet '
          'them with.',
    ),
  ],
  spoken: [
    (
      'Section modulus',
      r'S = \frac{I}{c},\quad \sigma = \frac{M}{S}',
      'bending stress is the moment over S',
    ),
    (
      'For a rectangle',
      r'S = \frac{bh^2}{6}',
      'width times depth squared, over six',
    ),
    ('Span moves', r'M \text{, not } V', 'the moment, not the shear'),
  ],
  handbook: 'Handbook p. 135',
);

const tableBrief2 = BriefSection(
  title: 'Read the supports, then the load',
  picture: tableLinePicture,
  steps: [
    (
      'Nothing here is worked out',
      'The handbook has a table of beams with the sag already solved. Your '
          'job is to match the beam in front of you to the right line.',
    ),
    (
      'Question one: how is it held',
      'Held at BOTH ENDS, or BUILT IN at one end with the other hanging '
          'free? A cantilever sags sixteen times more than the same beam held '
          'at both ends.',
    ),
    (
      'Question two: where is the load',
      'GATHERED at one point, or SPREAD along the beam? A point load brings '
          'L cubed; a spread load brings L to the fourth, because a longer '
          'beam also has more load on it.',
    ),
  ],
  spoken: [
    (
      'Held both ends, load in the middle',
      r'\delta = \frac{PL^3}{48EI}',
      'load times span cubed, over forty-eight EI',
    ),
    (
      'Held both ends, load spread',
      r'\delta = \frac{5wL^4}{384EI}',
      'five w L to the fourth, over three-eighty-four EI',
    ),
    (
      'Built in, load at the tip',
      r'\delta = \frac{PL^3}{3EI}',
      'load times span cubed, over three EI',
    ),
    (
      'Built in, load spread',
      r'\delta = \frac{wL^4}{8EI}',
      'w L to the fourth, over eight EI',
    ),
  ],
  handbook: 'Handbook pp. 140 to 141',
);

const bounceBrief = BriefSection(
  title: 'What actually stiffens a beam',
  picture: bouncePicture,
  steps: [
    (
      'Bouncy is a real failure',
      'A floor can be perfectly safe and still feel like a trampoline. So '
          'codes limit the sag, usually to the span divided by 360.',
    ),
    (
      'Depth is the big lever',
      'Depth is cubed inside I. Make a joist a quarter deeper and it is '
          'nearly twice as stiff. Width and load only count once.',
    ),
    (
      'Span is bigger still',
      'Span is cubed under a point load and to the fourth under a spread '
          'one. It is the strongest lever of all, and usually the one you '
          'cannot change.',
    ),
    (
      'A stronger steel does nothing',
      'Every grade of steel has the same E, so a stronger grade sags exactly '
          'as much. Changing from timber to steel changes everything; changing '
          'grades of steel changes nothing.',
    ),
  ],
  spoken: [
    (
      'Everything sits on',
      r'EI',
      'stiffness of the material times the shape\'s I',
    ),
    (
      'For a rectangle',
      r'I = \frac{bh^3}{12}',
      'width times depth CUBED, over twelve',
    ),
    (
      'Serviceability, typically',
      r'\delta \le \frac{L}{360}',
      'sag no more than the span over 360',
    ),
  ],
  handbook: 'Handbook pp. 140 to 141',
);

const addBrief = BriefSection(
  title: 'Two loads, two lookups, one sum',
  picture: addUpPicture,
  steps: [
    (
      'The table has one load at a time',
      'A real beam often carries two things at once, and that beam is not '
          'in the table. It does not need to be.',
    ),
    (
      'Split the load, add the sags',
      'Work out the sag from each load as if the other were not there. Then '
          'add the two answers. Done.',
    ),
    (
      'Why adding is allowed',
      'While the beam stays elastic, sag is proportional to load: double the '
          'load, double the sag. Loads that behave that way cannot interfere '
          'with each other, so their sags simply add.',
    ),
    (
      'Split the load, never the supports',
      'Every piece must be the SAME beam, held the same way, carrying part '
          'of the load. The same table line can be used twice with different '
          'numbers.',
    ),
  ],
  spoken: [
    (
      'Superposition',
      r'\delta_{total} = \delta_1 + \delta_2 + \dots',
      'the total sag is the sags added up',
    ),
    (
      'Because',
      r'\delta \propto \text{load}',
      'sag is proportional to load while the beam is elastic',
    ),
  ],
  handbook: 'Handbook pp. 140 to 141',
);

const transformBrief = BriefSection(
  title: 'Two materials, written as one',
  picture: transformPicture,
  steps: [
    (
      'Glued together, they bend together',
      'An aluminum beam with a steel strip glued to it bends as one thing. '
          'But the formulas want one material. So you pretend the whole beam '
          'is made of the softer one.',
    ),
    (
      'Make the stiff part wider',
      'Steel is about three times stiffer than aluminum, and n is that '
          'ratio. So draw the steel strip n times WIDER, as if it were '
          'aluminum. That much aluminum would do the same job.',
    ),
    (
      'Three things that must not happen',
      'Never widen the soft material. Never divide instead of multiply. And '
          'never change the DEPTH: depth is how far material sits from the '
          'middle, and that is what bending is about.',
    ),
    (
      'Then it is an ordinary beam',
      'Find the centroid of the new shape, find its I, and use M y over I '
          'exactly as before.',
    ),
  ],
  spoken: [
    (
      'Modular ratio',
      r'n = \frac{E_{stiff}}{E_{soft}}',
      'how many times stiffer the stiff material is',
    ),
    (
      'Transform by',
      r'b_{new} = n\,b_{stiff}',
      'the stiff part gets n times wider',
    ),
  ],
  handbook: 'Handbook p. 136',
);

const joinBrief = BriefSection(
  title: 'Strain is shared, stress is not',
  picture: joinPicture,
  steps: [
    (
      'Glued means stretched together',
      'Two materials glued along a line cannot stretch by different amounts '
          'right at that line. So the STRAIN is the same on both sides of the '
          'glue.',
    ),
    (
      'Same stretch, different effort',
      'Stress is stiffness times strain. Steel is n times stiffer than '
          'aluminum, so at the same strain it carries n times the stress. '
          'The stress JUMPS at the glue line by exactly n.',
    ),
    (
      'What the transformed section gives you',
      'It hands you the stress the soft material feels. For the stiff '
          'material at the same height, multiply by n.',
    ),
    (
      'Worth remembering in design',
      'The stiffer material attracts load whether you meant it to or not.',
    ),
  ],
  spoken: [
    (
      'Across the glue',
      r'\varepsilon_1 = \varepsilon_2',
      'the same strain on both sides',
    ),
    (
      'So',
      r'\sigma_1 = n\,\sigma_2',
      'the stiff side carries n times the stress',
    ),
    (
      'In the transformed section',
      r'\sigma_{stiff} = \frac{nMy}{I_T},\quad \sigma_{soft} = \frac{My}{I_T}',
      'the soft stress from the transformed I, times n for the stiff one',
    ),
  ],
  handbook: 'Handbook p. 136',
);

const plasticBrief = BriefSection(
  title: 'First yield is not the end of the beam',
  picture: plasticPicture,
  steps: [
    (
      'Four pictures as the load grows',
      'Elastic: a straight line of stress, small at the middle, biggest at '
          'the faces. Then the faces just reach yield: that is the YIELD '
          'moment. Then yield eats inward from both faces while an elastic core '
          'holds on. Finally the whole depth has yielded: the PLASTIC moment.',
    ),
    (
      'The beam keeps carrying more',
      'Between the yield moment and the plastic moment the beam is still '
          'taking more load. First yield is a warning, not the end.',
    ),
    (
      'S and Z',
      'The yield moment uses S, the elastic section modulus. The plastic '
          'moment uses Z, which is bigger. Using S for the plastic moment is '
          'the trap in this lesson.',
    ),
    (
      'How much bigger',
      'Z over S is the shape factor. About 1.5 for a rectangle, which has '
          'lots of material near the middle doing little. About 1.1 for a wide '
          'flange, whose material is already at the faces.',
    ),
  ],
  spoken: [
    ('First yield', r'M_y = F_y S', 'yield stress times the elastic modulus S'),
    (
      'Fully plastic',
      r'M_p = F_y Z',
      'yield stress times the plastic modulus Z',
    ),
    (
      'Shape factor',
      r'\frac{Z}{S} \approx 1.5 \text{ rectangle},\ 1.1 \text{ wide flange}',
      'how much more the beam carries after first yield',
    ),
  ],
  handbook: 'Handbook pp. 136 and 281',
);

const circleBrief = BriefSection(
  title: 'Every answer is a place on the circle',
  picture: circlePicture,
  steps: [
    (
      'One point, many planes',
      'Zoom into one point in a loaded part. Cut through it at any angle '
          'and the cut face feels some push and some slide. Turn the cut and '
          'the numbers change. Mohr\'s circle is a map of every angle at once.',
    ),
    (
      'The center and the radius',
      'The center sits on the push axis at the average of the two pushes '
          'you were given. Turning the cut never moves it. The radius is the '
          'biggest slide any cut in the page can feel.',
    ),
    (
      'The two ends',
      'At the far right and far left the slide has run out to nothing. '
          'Those are the principal stresses: the biggest push and the smallest. '
          'Sigma one is always the right-hand end, whatever the signs.',
    ),
    (
      'Angles double',
      'Turn the cut by an angle in the metal and you move TWICE that angle '
          'round the circle. That is why the worst slide sits forty-five '
          'degrees from the principal planes.',
    ),
  ],
  spoken: [
    (
      'Center',
      r'C = \frac{\sigma_x + \sigma_y}{2}',
      'the average of the two normal stresses',
    ),
    (
      'Radius',
      r'R = \sqrt{\left(\frac{\sigma_x-\sigma_y}{2}\right)^2 + \tau_{xy}^2}',
      'half the difference of the pushes, and the shear, combined like the sides of a triangle',
    ),
    ('Ends', r'\sigma_{1,2} = C \pm R', 'center plus and minus the radius'),
    (
      'Angles',
      r'2\theta \text{ on the circle}',
      'twice the angle turned in the material',
    ),
  ],
  handbook: 'Handbook p. 131',
);

const buildBrief = BriefSection(
  title: 'Three circles worth knowing on sight',
  picture: buildPicture,
  steps: [
    (
      'Pure shear: centered on zero',
      'Only a slide, no push on either face. The circle sits centered on '
          'zero, so the principal stresses are plus and minus the shear: a pull '
          'one way and an equal squeeze at forty-five degrees. That is why a '
          'brittle shaft in torsion cracks on a spiral.',
    ),
    (
      'One pull: from zero out',
      'A push on one face only. The circle runs from zero out to that '
          'push, and its worst slide is half of it, on a forty-five degree '
          'plane. That is why a ductile bar necks on the slant.',
    ),
    (
      'Equal both ways: a dot',
      'The same push on both faces and no slide. The radius is zero, the '
          'circle is a single point, and turning the element changes nothing.',
    ),
    (
      'Any shear pushes sigma one out',
      'In every other case, adding shear makes the circle bigger, so the '
          'largest principal stress is always further out than the push you '
          'started with.',
    ),
  ],
  spoken: [
    (
      'Pure shear',
      r'\sigma_{1,2} = \pm\tau',
      'plus and minus the shear, centered on zero',
    ),
    (
      'One pull',
      r'\sigma_1 = \sigma,\ \sigma_2 = 0,\ R = \frac{\sigma}{2}',
      'from zero to the pull; worst shear is half of it',
    ),
    ('Equal both ways', r'R = 0', 'a point, no shear on any plane'),
  ],
  handbook: 'Handbook p. 131',
);

const worstBrief = BriefSection(
  title: 'The third principal stress is zero, and it counts',
  picture: worstPicture,
  steps: [
    (
      'There is a third direction',
      'The circle shows the cuts you can draw in the page. But the metal '
          'has a third direction, out of the page, and at a free surface the '
          'stress there is zero. That zero is a principal stress too.',
    ),
    (
      'The worst slide uses the biggest spread',
      'The worst shear at the point is half the spread between the largest '
          'and the smallest of all THREE principal stresses. The radius only '
          'covers the two in the page.',
    ),
    (
      'One look decides it',
      'If the circle crosses the zero mark, zero is already inside the '
          'spread and the radius is the answer. If the whole circle sits on one '
          'side of zero, the real spread runs from zero to the far end, and '
          'the worst shear is half of THAT, always bigger than the radius.',
    ),
    (
      'The case that punishes a habit',
      'Two similar pulls: a tiny circle far out from zero, almost no shear '
          'in the page, and a serious shear on a plane out of the page.',
    ),
  ],
  spoken: [
    (
      'Worst at the point',
      r'\tau_{abs} = \frac{\sigma_{max} - \sigma_{min}}{2}',
      'half the spread between the biggest and smallest of the three',
    ),
    (
      'Out of plane',
      r'\sigma_3 = 0',
      'the third principal stress is zero at a free surface',
    ),
    ('Circle crosses zero', r'\tau_{abs} = R', 'the radius is the answer'),
    (
      'Circle clear of zero',
      r'\tau_{abs} = \frac{|\sigma_{far}|}{2}',
      'half the far end, bigger than the radius',
    ),
  ],
  handbook: 'Handbook p. 132',
);

const endsBrief = BriefSection(
  title: 'The ends decide almost everything',
  picture: endsPicture,
  steps: [
    (
      'Push down on a tall thin post',
      'Press on a ruler stood on end and it does not crush. It bows out '
          'sideways and gives way. That is buckling, and it happens long before '
          'the material is anywhere near breaking.',
    ),
    (
      'How the ends are held changes the shape',
      'Pin both ends and the post bows in one long curve. Clamp both ends so '
          'they cannot turn and it bends into an S, with straight points a lot '
          'closer together. Leave the top free and it leans like the top half '
          'of a post twice as long.',
    ),
    (
      'The formula uses the distance between straight points',
      'That distance is the EFFECTIVE length, K times L. Pinned both ends is '
          'K of 1. Clamped both ends is 0.5. One of each is 0.7. A free end is '
          '2, the case people forget.',
    ),
    (
      'It is squared, so it never goes a little wrong',
      'Halve the effective length and the post carries four times the load. '
          'A free-ended post is sixteen times weaker than a clamped pair of the '
          'same length.',
    ),
  ],
  spoken: [
    (
      'Euler',
      r'P_{cr} = \frac{\pi^2 EI}{(KL)^2}',
      'the buckling load: pi squared times stiffness times I, over the effective length squared',
    ),
    ('Pinned both ends', r'K = 1.0', 'the whole length'),
    ('Clamped both ends', r'K = 0.5', 'half the length'),
    (
      'One of each, and a free end',
      r'K = 0.7,\quad K = 2.0',
      'a bit under the length, and twice it',
    ),
  ],
  handbook: 'Handbook p. 136',
);

const weakAxisBrief = BriefSection(
  title: 'It folds about the axis it is weakest around',
  picture: weakAxisPicture,
  steps: [
    (
      'A post picks its own way to fold',
      'Push on a post and it does not ask which way is strong. It bows the '
          'easiest way there is. For a wide flange that is sideways, about the '
          'axis with the smaller I.',
    ),
    (
      'So use the smaller I, always',
      'Euler wants the MINIMUM I. Using the bigger one does not fail safely: '
          'it says the post is stronger than it really is.',
    ),
    (
      'Why building columns are braced sideways',
      'Bracing stops the sideways bow, which is the weak direction. Front to '
          'back the column can already look after itself.',
    ),
    (
      'A square or round tube has no weak way',
      'Same I in every direction, so no material is wasted propping up a '
          'strong axis that never gets tested. That is what makes it a good '
          'column shape.',
    ),
  ],
  spoken: [
    ('Use', r'I_{min}', 'the smaller of the two I values, always'),
    (
      'Or in stress form',
      r'r = \sqrt{\frac{I}{A}}',
      'the radius of gyration, the smaller one',
    ),
    ('Square or round', r'I_x = I_y', 'the same both ways, so no weak axis'),
  ],
  handbook: 'Handbook p. 136',
);

const slenderBrief = BriefSection(
  title: 'Long columns buckle, short ones squash',
  picture: slenderPicture,
  steps: [
    (
      'Two ways to fail',
      'A short stubby post is crushed: the stress reaches yield and it '
          'squashes. A long thin post never gets there: it bows sideways first, '
          'while the material is still fine.',
    ),
    (
      'One picture holds both',
      'Plot the failing stress against slenderness, how long and thin the '
          'post is. Euler\'s curve falls away as the post gets slenderer. The '
          'yield stress is a flat cap across the short end. The post fails at '
          'whichever is lower.',
    ),
    (
      'Where they cross',
      'They meet at a slenderness of pi times the square root of E over the '
          'yield stress, about 89 for ordinary steel. Euler is only allowed when '
          'the stress it gives comes out below yield.',
    ),
    (
      'Strength is not in Euler',
      'A stronger steel raises the flat cap and does nothing to the curve. '
          'It helps a stocky post and does nothing at all for a slender one.',
    ),
  ],
  spoken: [
    (
      'Critical stress',
      r'\sigma_{cr} = \frac{\pi^2 E}{(KL/r)^2}',
      'pi squared times E, over the slenderness squared',
    ),
    ('Only when', r'\sigma_{cr} < \sigma_y', 'the Euler stress is below yield'),
    (
      'They cross at',
      r'\frac{KL}{r} = \pi\sqrt{\frac{E}{\sigma_y}}',
      'pi times the square root of E over the yield stress, about 89 for mild steel',
    ),
  ],
  handbook: 'Handbook p. 136',
);

const missingBrief = BriefSection(
  title: 'The equation is picked by what is missing',
  picture: missingPicture,
  steps: [
    (
      'Five things describe a trip',
      'A car speeding up steadily has five numbers to its name: the speed it '
          'started at, the speed it ended at, how far it went, how long it took, '
          'and how hard it was speeding up.',
    ),
    (
      'Any three give you the rest',
      'That is what the four equations are for. Each one uses four of the '
          'five numbers and ignores the fifth completely.',
    ),
    (
      'So find the one nobody mentions',
      'Read the problem and ask which of the five is never given and never '
          'asked for. Then use the equation that leaves that one out. No seconds '
          'anywhere is the commonest, and it points at the one without time.',
    ),
    (
      'Two warnings',
      'Slowing down means the speeding up number is negative. And none of '
          'these equations is allowed unless the speeding up stays the same the '
          'whole way.',
    ),
  ],
  spoken: [
    (
      'No distance',
      r'v = v_0 + at',
      'end speed is start speed plus how hard, times how long',
    ),
    (
      'No time',
      r'v^2 = v_0^2 + 2a(s - s_0)',
      'end speed squared is start speed squared plus twice how hard, times the distance',
    ),
    (
      'No end speed',
      r's = s_0 + v_0t + \tfrac{1}{2}at^2',
      'distance from the start speed, the time, and how hard',
    ),
    (
      'No acceleration',
      r's = s_0 + \tfrac{1}{2}(v_0 + v)t',
      'distance is the average of the two speeds, times the time',
    ),
  ],
  handbook: 'Handbook p. 104',
);

const flightBrief = BriefSection(
  title: 'Across and up and down never mix',
  picture: flightPicture,
  steps: [
    (
      'Throw a ball',
      'Once it has left your hand nothing pushes it sideways. Gravity is the '
          'only thing acting, and gravity only pulls down. So what happens across '
          'and what happens up and down have nothing to do with each other.',
    ),
    (
      'Across never changes',
      'The sideways speed at the launch is the sideways speed at the top and '
          'the sideways speed at the landing. It is the same number for the whole '
          'flight.',
    ),
    (
      'Up and down runs downhill',
      'The upward speed shrinks steadily, passes through zero, and comes out '
          'the other side as a downward speed. The instant it is zero is the top '
          'of the arc, and that is what makes the top solvable.',
    ),
    (
      'Two things people say that are wrong',
      'The ball does not stop at the top: it is still traveling across. And '
          'gravity is not weaker up there: it pulls just as hard as it did at the '
          'start.',
    ),
  ],
  spoken: [
    (
      'Across',
      r'v_x = v_0\cos\theta',
      'the sideways piece of the launch speed, and it never changes',
    ),
    (
      'Up and down',
      r'v_y = v_0\sin\theta - gt',
      'the upward piece, shrinking by gravity as the seconds pass',
    ),
    ('At the top', r'v_y = 0', 'the upward speed is nothing'),
    (
      'Everywhere',
      r'a = g',
      'gravity pulls down the whole time, by the same amount',
    ),
  ],
  handbook: 'Handbook p. 104',
);

const bendBrief = BriefSection(
  title: 'Two accelerations at right angles',
  picture: bendPicture,
  steps: [
    (
      'Drive round a bend',
      'Two things about you can change: how fast you are going, and which way '
          'you are pointing. Each gets its own arrow, and the two sit square to '
          'each other.',
    ),
    (
      'The arrow along the road',
      'This one changes your speed, and it is the only one the speedometer '
          'knows about. Hold a steady speed and it is nothing at all.',
    ),
    (
      'The arrow toward the middle of the bend',
      'This one changes your direction. It is the speed times itself, divided '
          'by how wide the bend is. So twice the speed needs four times as much, '
          'and a tighter bend is worse.',
    ),
    (
      'Steady speed is still accelerating',
      'Round a bend at a constant speed the first arrow is gone and the '
          'second is still there. That is what the tires have to push against, '
          'and it is why you feel pulled sideways.',
    ),
  ],
  spoken: [
    (
      'Along the road',
      r'a_t = \dot{v}',
      'how fast the speed itself is changing',
    ),
    (
      'Toward the middle',
      r'a_n = \frac{v^2}{\rho}',
      'speed times speed, over how wide the bend is',
    ),
    (
      'Together',
      r'a = \sqrt{a_t^2 + a_n^2}',
      'the two combined like the sides of a right triangle, never added up',
    ),
  ],
  handbook: 'Handbook p. 103',
);

const spinBrief = BriefSection(
  title: 'One spin rate, a different speed at every radius',
  picture: spinPicture,
  steps: [
    (
      'Everything turns together',
      'A wheel is rigid, so every dot on it sweeps through the same angle in '
          'the same time. The whole wheel has ONE spin rate.',
    ),
    (
      'But not one speed',
      'A dot near the rim has a much bigger circle to get round in that same '
          'time, so it is traveling faster. A dot near the middle strolls.',
    ),
    (
      'Twice as far out, twice as fast',
      'Speed is the spin rate times how far out the dot sits, so it grows '
          'straight with the distance. Where the dot sits AROUND the circle makes '
          'no difference at all.',
    ),
    (
      'Turns per minute is not the spin rate',
      'Change it first: times two pi, divided by sixty, and you have radians '
          'per second. Putting turns per minute straight into the formula is out '
          'by about ten.',
    ),
  ],
  spoken: [
    (
      'Speed of a dot',
      r'v = r\omega',
      'how far out it sits, times the spin rate',
    ),
    (
      'Toward the middle',
      r'a_n = r\omega^2 = \frac{v^2}{r}',
      'the pull inward, which also grows with the radius',
    ),
    (
      'From turns per minute',
      r'\omega = \text{rpm}\times\frac{2\pi}{60}',
      'turns a minute, times two pi, over sixty',
    ),
  ],
  handbook: 'Handbook p. 103',
);

const spinInertiaBrief = BriefSection(
  title: 'How hard it is to get something spinning',
  picture: spinInertiaPicture,
  steps: [
    (
      'The spinning twin of weight',
      'Weight tells you how hard something is to get moving in a straight '
          'line. Mass moment of inertia tells you how hard it is to get spinning. '
          'Same idea, different motion.',
    ),
    (
      'Where the material sits is everything',
      'Two things of exactly the same weight can be very different to spin '
          'up. Material far from the middle fights back hard. Material near the '
          'middle barely fights at all.',
    ),
    (
      'Read the table as a story',
      'A hoop keeps all of its metal at the rim, so it is the worst. A solid '
          'disc has most of it closer in, and comes out at half. A sphere is '
          'closer still, at two fifths.',
    ),
    (
      'It belongs to the axis too',
      'Spin a rod about its middle and it is a twelfth of its weight times '
          'its length squared. Spin the same rod about its END and it is a third, '
          'four times more, with nothing about the rod changed.',
    ),
  ],
  spoken: [
    (
      'Hoop, disc, sphere',
      r'mr^2,\quad \tfrac{1}{2}mr^2,\quad \tfrac{2}{5}mr^2',
      'all at the rim, then half of that, then two fifths',
    ),
    (
      'Rod, middle and end',
      r'\tfrac{1}{12}mL^2,\quad \tfrac{1}{3}mL^2',
      'four times harder about the end than about the middle',
    ),
    (
      'Moving the axis',
      r'I = I_c + md^2',
      'add the weight times how far the axis moved, squared, always starting from the middle',
    ),
  ],
  handbook: 'Handbook pp. 110 and 114 to 115',
);

const weightBrief = BriefSection(
  title: 'Kilograms are not newtons',
  picture: weightPicture,
  steps: [
    (
      'Two different questions about one block',
      'How much stuff is it made of? That is its mass, in kilograms. How hard '
          'does gravity pull it down? That is its weight, a force, in newtons. '
          'They are different numbers.',
    ),
    (
      'The equation wants one of each',
      'Force equals mass times acceleration needs a FORCE on one side and a '
          'MASS on the other. So the first job in any problem is reading which of '
          'the two you were handed.',
    ),
    (
      'How to tell which you got',
      'Kilograms and slugs are mass. Newtons and pounds are force. A block '
          'described as 500 newtons has a mass of about 51 kilograms, and using '
          '500 as the mass makes it ten times heavier than it is.',
    ),
    (
      'One multiply, or one divide',
      'Mass to weight, times gravity. Weight to mass, divide by gravity. The '
          'commonest mistake after using the wrong one is converting something '
          'that never needed converting.',
    ),
  ],
  spoken: [
    (
      'Weight from mass',
      r'W = mg',
      'how much stuff, times how hard gravity pulls',
    ),
    ('Mass from weight', r'm = \frac{W}{g}', 'the weight, divided by gravity'),
    (
      'And gravity is',
      r'g = 9.81\ \mathrm{m/s^2} = 32.2\ \mathrm{ft/s^2}',
      'about ten in metric units, about thirty two in US ones',
    ),
  ],
  handbook: 'Handbook p. 105',
);

const slopeBrief = BriefSection(
  title: 'Gravity pulls straight down, and the ramp splits it',
  picture: slopePicture,
  steps: [
    (
      'Put a block on a ramp',
      'Gravity still pulls it straight down, the same as always. But the '
          'block cannot go straight down, because the ramp is in the way. So '
          'split that downward pull into two pieces the ramp cares about.',
    ),
    (
      'The piece down the slope',
      'This is the only one that gets the block moving. It is the weight '
          'times the SINE of the slope angle. Steeper ramp, bigger piece, faster '
          'slide.',
    ),
    (
      'The piece into the slope',
      'This one presses the block against the surface, and the surface pushes '
          'back exactly as hard, so it moves nothing. It is the weight times the '
          'COSINE, and it is what decides how much friction you get.',
    ),
    (
      'The trap, and a fact worth keeping',
      'Swapping sine and cosine is the named mistake here. And on a smooth '
          'ramp the acceleration is gravity times the sine of the angle, whatever '
          'the block weighs.',
    ),
  ],
  spoken: [
    (
      'Down the slope',
      r'W\sin\theta = ma',
      'the weight times the sine of the angle is what accelerates it',
    ),
    (
      'Into the slope',
      r'N = W\cos\theta',
      'the weight times the cosine is what the surface pushes back with',
    ),
    (
      'So',
      r'a = g\sin\theta',
      'on a smooth ramp, gravity times the sine, whatever the weight',
    ),
  ],
  handbook: 'Handbook p. 105',
);

const twoEquationsBrief = BriefSection(
  title: 'A rigid body has two equations',
  picture: twoEquationsPicture,
  steps: [
    (
      'A push can do two things',
      'It can shove the whole body along, and it can spin the body round. '
          'Which of the two you get is decided by what is HOLDING the body and '
          'where the push LANDS.',
    ),
    (
      'Pinned on an axle: it only spins',
      'The axle stops the body going anywhere, so all that is left is '
          'turning. Use the moment equation and nothing else.',
    ),
    (
      'Pushed through the middle: it only slides',
      'A push whose line goes straight through the middle has no arm to turn '
          'the body with, so it spins nothing. Use the force equation and nothing '
          'else. Pushed off center and free, it does both at once.',
    ),
    (
      'A force is not a moment yet',
      'To turn a force into a moment you multiply it by its distance from the '
          'middle. Forgetting that step is the named trap in this lesson.',
    ),
  ],
  spoken: [
    (
      'Forces move the middle',
      r'\sum F = ma_c',
      'add the forces up and the middle of the body accelerates',
    ),
    (
      'Moments spin it',
      r'\sum M_c = I_c\alpha',
      'add the moments and the body spins up, against how hard it is to spin',
    ),
    (
      'A force becomes a moment by',
      r'M = F d',
      'the force, times how far its line misses the middle by',
    ),
  ],
  handbook: 'Handbook pp. 105 and 109',
);

const ledgerBrief = BriefSection(
  title: 'Energy is an account, and it balances',
  picture: ledgerPicture,
  steps: [
    (
      'What it had, plus what you add, minus what is rubbed away',
      'That is what it ends with. The whole skill is reading which of those '
          'buckets a situation actually has, then stacking them up on each side.',
    ),
    (
      'Height and movement trade freely',
      'Being up high and going fast are the same currency. A block sliding '
          'down a smooth ramp just moves it from one pile to the other, and '
          'nothing is lost.',
    ),
    (
      'A spring stores, friction takes',
      'What gets squeezed into a spring comes back out later. What friction '
          'and drag take never comes back, and that is the only term that makes '
          'the after side shorter than the before side. A motor adds from outside.',
    ),
    (
      'When to reach for it',
      'When nothing is taken and nothing added, the two sides are simply '
          'equal. Energy is the fast road whenever you know two positions and a '
          'speed and do not care how long it took.',
    ),
  ],
  spoken: [
    (
      'The full account',
      r'T_1 + V_1 + U^{nc}_{1\to2} = T_2 + V_2',
      'what it had, plus what was added or taken, equals what it ends with',
    ),
    (
      'Moving',
      r'T = \tfrac{1}{2}mv^2',
      'half the mass times the speed squared',
    ),
    (
      'Height and spring',
      r'V_g = mgh, \quad V_e = \tfrac{1}{2}ks^2',
      'weight times height, and half the stiffness times the squeeze squared',
    ),
  ],
  handbook: 'Handbook p. 106',
);

const cancelBrief = BriefSection(
  title: 'When the weight cancels, and when it does not',
  picture: cancelPicture,
  steps: [
    (
      'Race a heavy block against a light one',
      'Down the same smooth ramp they arrive at the bottom at exactly the '
          'same speed. The heavy one started with more energy AND needs more of '
          'it to reach any given speed, so the two cancel out.',
    ),
    (
      'Weight drops out when it sits on both sides',
      'The speed at the bottom of a ramp, the height of a throw, even how far '
          'a skid takes to stop, since friction grows with weight too. None of '
          'them care what the thing weighs.',
    ),
    (
      'It stays when it only sits on one side',
      'How much energy a thing carries, and how much power it takes to lift '
          'it, both depend on the weight directly. There is nothing on the other '
          'side to cancel with.',
    ),
    (
      'The one that catches people',
      'A spring squeezed the same amount gives a LIGHT block more speed than '
          'a heavy one. The spring has a fixed amount to hand over, and less mass '
          'turns it into more speed.',
    ),
  ],
  spoken: [
    (
      'Cancels',
      r'v = \sqrt{2gh}, \quad d = \frac{v^2}{2\mu g}',
      'the speed off a drop and the length of a skid, with no mass in either',
    ),
    (
      'Does not cancel',
      r'T = \tfrac{1}{2}mv^2, \quad P = \frac{mgh}{t}',
      'the energy carried, and the power to lift, both grow with the mass',
    ),
    (
      'And a spring gives',
      r'v = \sqrt{\frac{ks^2}{m}}',
      'more speed to a lighter block, since the mass sits underneath',
    ),
  ],
  handbook: 'Handbook p. 106',
);

const powerBrief = BriefSection(
  title: 'Power, and which way efficiency runs',
  picture: powerPicture,
  steps: [
    (
      'Power is work divided by time',
      'Lifting a crate ten floors takes the same energy whether it takes a '
          'minute or an hour. Doing it in a minute takes more POWER.',
    ),
    (
      'Or force times speed',
      'The same thing said another way, and it is the one line answer '
          'whenever something moves steadily against a resistance: a truck at a '
          'constant speed, a hoist lifting at a constant rate.',
    ),
    (
      'A machine always leaks',
      'It takes in more than it gives out, and the difference goes to heat '
          'and noise. Efficiency is the fraction that survives, and it is always '
          'less than one.',
    ),
    (
      'So which way do you divide',
      'Output is input times efficiency. Input is output DIVIDED by it. If '
          'the question asks what the motor must supply and your answer is '
          'smaller than the work being done, you multiplied where you should have '
          'divided.',
    ),
  ],
  spoken: [
    (
      'Power',
      r'P = \frac{dU}{dt} = F v',
      'work per second, which is also the force times the speed',
    ),
    (
      'Efficiency',
      r'\eta = \frac{P_{out}}{P_{in}} < 1',
      'what comes out over what went in, always under one',
    ),
    (
      'So the motor needs',
      r'P_{in} = \frac{P_{out}}{\eta}',
      'the useful power, divided by the efficiency',
    ),
  ],
  handbook: 'Handbook p. 107',
);

const impactBrief = BriefSection(
  title: 'Stuck, bounced, or somewhere between',
  picture: impactPicture,
  steps: [
    (
      'Read the word that tells you which kind',
      'Stuck, locked, coupled, embedded, buried: all of them mean the two '
          'travel on as one lump. Bounced clean off means the opposite. Most '
          'crashes sit somewhere between the two.',
    ),
    (
      'Stuck together is the easy one',
      'There is only ONE speed afterwards, so one equation does the whole '
          'job. Add both masses together on the after side. The bounciness number '
          'is zero.',
    ),
    (
      'A perfect bounce is the other end',
      'Bounciness of one, and nothing in the real world quite manages it. '
          'Anything in between needs TWO equations, because there are two unknown '
          'speeds to find.',
    ),
    (
      'What the bounciness number compares',
      'How fast they separate afterwards, against how fast they closed '
          'before. And it uses only the speeds square to the surface they hit on, '
          'never the ones sliding along it.',
    ),
  ],
  spoken: [
    (
      'Momentum of the pair',
      r"m_1v_1 + m_2v_2 = m_1v_1' + m_2v_2'",
      'mass times speed, added up, is the same before and after',
    ),
    (
      'Bounciness',
      r"e = \frac{v_2' - v_1'}{v_1 - v_2}",
      'how fast they part, over how fast they came together',
    ),
    (
      'Stuck together',
      r"e = 0,\quad v_1' = v_2'",
      'no bounce at all, and one speed for the pair',
    ),
    ('Perfect bounce', r'e = 1', 'they part exactly as fast as they closed'),
  ],
  handbook: 'Handbook p. 108',
);

const survivesBrief = BriefSection(
  title: 'Momentum always, energy almost never',
  picture: survivesPicture,
  steps: [
    (
      'Momentum comes through every crash',
      'While the bang is happening nothing outside is pushing on the pair, so '
          'the total of mass times speed is exactly the same afterwards as it was '
          'before. Every time, whatever kind of crash it was.',
    ),
    (
      'Energy does not',
      'Crashing bends metal, makes heat and makes noise, and all of that is '
          'energy that has left. It only survives a perfect bounce, which almost '
          'nothing really is.',
    ),
    (
      'Sticking together spends the most',
      'A bullet burying itself in a block loses over ninety nine percent of '
          'the energy. Assuming energy is conserved in a crash like that is the '
          'named trap in this lesson.',
    ),
    (
      'So a swing problem is two problems',
      'Use momentum for the instant of the crash. Then, and only then, use '
          'energy for the smooth swing that follows, where nothing is being lost.',
    ),
  ],
  spoken: [
    (
      'Always true',
      r'\sum p_{\text{before}} = \sum p_{\text{after}}',
      'the total momentum of the pair is unchanged',
    ),
    (
      'Only in a perfect bounce',
      r'\sum T_{\text{before}} = \sum T_{\text{after}}',
      'the total energy is unchanged only when the bounciness is one',
    ),
    (
      'And momentum belongs to',
      r'\text{the pair, never one body}',
      'add both bodies up, before and after',
    ),
  ],
  handbook: 'Handbook p. 108',
);

const impulseBrief = BriefSection(
  title: 'Force times time is the whole of it',
  picture: impulsePicture,
  steps: [
    (
      'A force acting for a while changes momentum',
      'Multiply how hard by how long and you get exactly the change in mass '
          'times speed. Drawn as force against time, it is the shaded AREA under '
          'the line.',
    ),
    (
      'A crash fixes the area',
      'Stopping a car means a fixed amount of momentum has to disappear. You '
          'cannot change that. The only thing a designer can change is how LONG '
          'the stopping takes.',
    ),
    (
      'Twice as long is half as hard',
      'That is a crumple zone, an airbag, a run off area, and a catcher '
          'drawing their hands back. Same area, spread over more time, so the '
          'force is smaller.',
    ),
    (
      'Turn it over and you get a hammer',
      'The same momentum in the shortest possible time is the biggest '
          'possible force. And if a question hands you a force and a time, the '
          'answer is a momentum, not a force.',
    ),
  ],
  spoken: [
    (
      'Impulse',
      r'\int F\,dt = F_{avg}\,\Delta t',
      'how hard, times how long, which is the area under the line',
    ),
    (
      'Which equals',
      r'F\,\Delta t = m v_2 - m v_1',
      'that area is exactly the change in mass times speed',
    ),
    (
      'So a longer stop',
      r'F = \frac{m\,\Delta v}{\Delta t}',
      'the same change in momentum over more time is a smaller force',
    ),
  ],
  handbook: 'Handbook p. 107',
);

const underneathBrief = BriefSection(
  title: 'Which measurement goes underneath',
  picture: underneathPicture,
  steps: [
    (
      'Pull a bar and watch it change',
      'A test bar is measured before anything happens: how thick it is and '
          'how long. Then the machine pulls. It gets longer, and a little '
          'thinner. Now there are two sets of measurements, the old and the new.',
    ),
    (
      'Engineering numbers use the old ones',
      'Engineering stress and strain keep dividing by the bar you started '
          'with, all the way to the break. Those are the numbers you actually '
          'measured in the shop, so they are the honest ones to report.',
    ),
    (
      'True numbers use the new ones',
      'True stress divides by the bar you have at that moment, waist and '
          'all. That area is shrinking, so true stress is always the bigger '
          'number once the bar starts to thin.',
    ),
    (
      'A strain never has a unit',
      'Strain is a length divided by a length, so the units cancel to '
          'nothing. If your number still has millimeters after it, that is a '
          'stretch, not a strain.',
    ),
  ],
  spoken: [
    (
      'Engineering stress',
      r'\sigma = \frac{F}{A_0}',
      'the pull, over the area the bar started with',
    ),
    (
      'Engineering strain',
      r'\varepsilon = \frac{\Delta L}{L_0}',
      'how much it grew, over the length it started with',
    ),
    (
      'True stress',
      r'\sigma_T = \frac{F}{A}',
      'the pull, over the area it has right now',
    ),
    (
      'True strain',
      r'\varepsilon_T = \ln(1 + \varepsilon)',
      'the natural log of one plus the engineering strain',
    ),
  ],
  handbook: 'Handbook p. 121',
);

const trueStressBrief = BriefSection(
  title: 'One test, plotted two ways',
  picture: trueStressPicture,
  steps: [
    (
      'The same test, two lines',
      'One pull of one bar gives two curves, depending on which area you '
          'divide by. At the start the bar has barely changed, so the two lines '
          'sit on top of each other and nobody can tell them apart.',
    ),
    (
      'They split once the bar thins',
      'Stretch it seriously and the bar narrows. The true curve is dividing '
          'by that smaller area, so it climbs above the engineering one and '
          'stays above it for the rest of the test.',
    ),
    (
      'Only one of them turns over',
      'A waist forms and the engineering curve peaks and comes back down. '
          'That peak is the ultimate tensile strength, the number a mill '
          'certificate quotes. The true curve never peaks; it climbs until the '
          'bar parts.',
    ),
    (
      'Check the direction before you trust it',
      'Going from engineering to true means multiplying by one plus the '
          'strain, and one plus something is bigger than one. So the answer has '
          'to come out LARGER. If it came out smaller, the formula went in '
          'upside down.',
    ),
  ],
  spoken: [
    (
      'True from engineering',
      r'\sigma_T = \sigma(1 + \varepsilon)',
      'engineering stress times one plus the strain, so always bigger',
    ),
    (
      'True strain',
      r'\varepsilon_T = \ln(1 + \varepsilon)',
      'the natural log of one plus the engineering strain',
    ),
    (
      'Why it works',
      r'A \approx \frac{A_0}{1 + \varepsilon}',
      'the bar keeps its volume, so its area shrinks by that same factor',
    ),
  ],
  handbook: 'Handbook p. 121',
);

const crackBrief = BriefSection(
  title: 'Where the crack sits decides both numbers',
  picture: crackPicture,
  steps: [
    (
      'A crack makes a plate weak',
      'Pull on a plate with a crack in it and the pull crowds into the tip '
          'of the crack. One formula says how hard that tip is being worked, and '
          'it needs two things: how big the crack is, and where it sits.',
    ),
    (
      'From the edge: use the whole thing',
      'A crack running in from the side has nothing behind it holding it '
          'shut. Its a is the full depth you can see, and it takes the slightly '
          'bigger factor of 1.1, because an edge is the worse place to have one.',
    ),
    (
      'Inside: use half of it',
      'A crack buried in the middle has plate on both sides. It is described '
          'as being 2a long, so the a in the formula is HALF of what you see. '
          'That halving is the most missed step on the page.',
    ),
    (
      'Then put it in meters',
      'Toughness is quoted in units that want meters. Leave the crack in '
          'millimeters and the answer is out by more than thirty times, which '
          'looks like the answer to a different question.',
    ),
  ],
  spoken: [
    (
      'The formula',
      r'K = Y\sigma\sqrt{\pi a}',
      'a shape factor, times the stress, times the root of pi times a',
    ),
    (
      'From an edge',
      r'Y = 1.1,\quad a = \text{the whole depth}',
      'factor one point one, and a is everything you can see',
    ),
    (
      'Inside',
      r'Y = 1.0,\quad a = \tfrac{1}{2}\,\text{of the length}',
      'factor one, and a is half of what you can see',
    ),
  ],
  handbook: 'Handbook p. 122',
);

const toughnessBrief = BriefSection(
  title: 'The crack and the pull, together',
  picture: toughnessPicture,
  steps: [
    (
      'Neither number means anything alone',
      'A big crack in a plate nobody is pulling is fine. A hard pull on a '
          'plate with no crack is fine. Trouble is the two at once, which is why '
          'the formula multiplies them together.',
    ),
    (
      'Toughness is what you compare against',
      'Fracture toughness is a property of the material, like a strength. '
          'Work out how hard the crack tip is being driven, and if that passes '
          'the toughness, the crack runs.',
    ),
    (
      'The pull counts more than the crack',
      'The crack sits under a square root and the pull does not. So four '
          'times the crack only doubles the driving force, while twice the load '
          'doubles it straight off.',
    ),
    (
      'Which is why cracked parts stay in service',
      'You cannot make the crack smaller, but you can lower the load. That '
          'is what de-rating a cracked member means, and it works because the '
          'pull is the term with the bigger say.',
    ),
  ],
  spoken: [
    (
      'Driving the crack',
      r'K = Y\sigma\sqrt{\pi a}',
      'how hard the crack tip is being worked',
    ),
    (
      'The most stress it can take',
      r'\sigma_{max} = \frac{K_{IC}}{Y\sqrt{\pi a}}',
      'the toughness, over the shape factor times the root of pi a',
    ),
    (
      'The biggest crack it can carry',
      r'a_{max} = \frac{1}{\pi}\left(\frac{K_{IC}}{Y\sigma}\right)^2',
      'square the toughness over the stress term, then divide by pi',
    ),
  ],
  handbook: 'Handbook p. 122',
);

const expandBrief = BriefSection(
  title: 'Three things multiply, and thickness is not one',
  picture: expandPicture,
  steps: [
    (
      'Warm things get bigger',
      'Heat a metal bar and it grows a little. How far it grows is three '
          'things multiplied together, and nothing else.',
    ),
    (
      'What it is made of',
      'Each material has its own number. Aluminum moves about twice as '
          'readily as steel. Steel and concrete are close enough to each other '
          'that reinforced concrete survives a hot summer without tearing '
          'itself apart.',
    ),
    (
      'How long it is',
      'Straight proportion: five times the length is five times the '
          'movement. That is why a long bridge gets expansion joints and a short '
          'footbridge usually does not.',
    ),
    (
      'How much the temperature changed',
      'A change, never a reading. Forty degrees minus five is thirty five, '
          'not forty five. And notice what is missing: thickness. A heavy column '
          'and a thin rod of the same length move exactly the same amount.',
    ),
  ],
  spoken: [
    (
      'How far it moves',
      r'\Delta L = \alpha L \Delta T',
      'the material number, times the length, times the temperature change',
    ),
    (
      'Which is a strain',
      r'\alpha = \frac{\varepsilon}{\Delta T}',
      'the material number is just strain per degree',
    ),
    (
      'Steel, concrete, aluminum',
      r'11.7,\; 10,\; 23 \times 10^{-6}\,/^{\circ}C',
      'aluminum moves about twice as much as steel for the same warming',
    ),
  ],
  handbook: 'Handbook p. 126',
);

const furnaceBrief = BriefSection(
  title: 'How fast it came down',
  picture: furnacePicture,
  steps: [
    (
      'Two questions read any heat treatment',
      'Did the steel get hot enough, above about 727 degrees, to change into '
          'the form called austenite? And then how fast did it come back down '
          'through that change?',
    ),
    (
      'Fast down: the atoms get stuck',
      'Drop a hot part into water and the temperature falls off a cliff. The '
          'atoms have no time to move where they want to go, so the structure is '
          'trapped part way. That is martensite: very hard, and very brittle.',
    ),
    (
      'Slow down: the atoms sort themselves out',
      'Leave it in the furnace and the line strolls down. Now the atoms do '
          'move, giving the soft, bendable mixture the phase diagram calls for.',
    ),
    (
      'Tempering, and the case where nothing happens',
      'Reheating a quenched part to a few hundred degrees keeps most of the '
          'hardness and takes away most of the brittleness. And if the part '
          'never got hot enough to start with, quenching does nothing at all.',
    ),
  ],
  spoken: [
    (
      'Fast from austenite',
      r'\gamma \rightarrow \text{martensite}',
      'quench it and you get the hard, brittle structure',
    ),
    (
      'Slow from austenite',
      r'\gamma \rightarrow \alpha + Fe_3C',
      'cool it slowly and you get the soft, bendable mixture',
    ),
    (
      'Then reheated',
      r'\text{martensite} \rightarrow \text{tempered}',
      'warming a quenched part trades a little hardness for toughness',
    ),
  ],
  handbook: 'Handbook p. 116',
);

const tieLineBrief = BriefSection(
  title: 'The arm on the far side',
  picture: tieLinePicture,
  steps: [
    (
      'Half melted, and you want to know how much',
      'An alloy warmed part way is partly solid and partly liquid. Draw a '
          'flat line across at your temperature: it runs from the solid boundary '
          'on the left to the liquid boundary on the right, and your alloy sits '
          'somewhere along it.',
    ),
    (
      'It behaves like a seesaw',
      'The alloy is the pivot and the two boundaries are the ends. Sit close '
          'to the solid end and the mixture is mostly solid. That is why this is '
          'called the lever rule.',
    ),
    (
      'So each share uses the FAR arm',
      'The liquid share is the arm running back toward the SOLID boundary, '
          'over the whole line. That feels backwards, and it is the step people '
          'miss. Check it at the ends: right against the solid boundary that far '
          'arm is nearly zero, so there is almost no liquid. Correct.',
    ),
    (
      'Two free checks',
      'The two shares must add up to one. And the bottom of the fraction is '
          'measured between the two boundaries, never from zero.',
    ),
  ],
  spoken: [
    (
      'Fraction liquid',
      r'f_L = \frac{x_0 - x_\alpha}{x_L - x_\alpha}',
      'the arm back to the solid boundary, over the whole line',
    ),
    (
      'Fraction solid',
      r'f_\alpha = \frac{x_L - x_0}{x_L - x_\alpha}',
      'the arm out to the liquid boundary, over the whole line',
    ),
    (
      'Always',
      r'f_L + f_\alpha = 1',
      'the two shares add up to the whole thing',
    ),
  ],
  handbook: 'Handbook p. 127',
);

const mixBrief = BriefSection(
  title: 'Water over cement, and lower is stronger',
  picture: mixPicture,
  steps: [
    (
      'One ratio runs the whole page',
      'Weigh the water. Weigh the CEMENT. Divide the first by the second. '
          'Not the whole batch, not the sand and stone, and not the other way '
          'up.',
    ),
    (
      'More water is weaker, which surprises people',
      'Extra water makes the mix easier to pour, so it feels helpful. It is '
          'not. It leaves tiny channels behind when it dries. Around 0.40 the '
          'concrete reaches about 6,500 psi; by 0.80 only about 2,000 is left.',
    ),
    (
      'Two ways to get the ratio down',
      'Add cement, or take water out. Both make the bottom bigger or the top '
          'smaller, and both land you further up the curve.',
    ),
    (
      'When the only problem is pouring',
      'If the mix is strong enough but will not flow, the answer is a water '
          'reducer, not a hose. It buys the workability without moving you down '
          'the slope.',
    ),
  ],
  spoken: [
    (
      'The ratio',
      r'W/C = \frac{\text{water}}{\text{cement}}',
      'the weight of water, over the weight of cement',
    ),
    (
      'Low ratio',
      r'0.40 \approx 6{,}500\ \text{psi}',
      'a dry, stiff mix reaches a high strength',
    ),
    (
      'High ratio',
      r'0.80 \approx 2{,}000\ \text{psi}',
      'a sloppy mix is worth about a third as much',
    ),
  ],
  handbook: 'Handbook p. 125',
);

const exposureBrief = BriefSection(
  title: 'Strength and exposure are two separate questions',
  picture: exposurePicture,
  steps: [
    (
      'Question one: how strong',
      'How much load will this concrete carry? That sets the water to cement '
          'ratio straight off the curve, and nothing else.',
    ),
    (
      'Question two: will it freeze while wet',
      'Water trapped in concrete expands when it freezes and breaks the '
          'concrete apart from inside. Tiny bubbles of air deliberately mixed in '
          'give that water somewhere to go. Four to seven percent is usual.',
    ),
    (
      'Air is not free',
      'Those bubbles are holes, and holes are not concrete. Entrained air '
          'costs roughly a fifth of the strength. A job needing both has to '
          'start from a LOWER ratio to pay for it.',
    ),
    (
      'It is this concrete, not this city',
      'The question is whether this particular piece freezes while wet. A '
          'garage deck out in the weather and the footing buried warm beneath it '
          'get different mixes in the same town.',
    ),
  ],
  spoken: [
    (
      'Strength sets',
      r'W/C',
      'how strong it must be decides the water to cement ratio',
    ),
    (
      'Exposure sets',
      r'\text{air, } 4\text{ to }7\%',
      'whether it freezes while wet decides how much air goes in',
    ),
    (
      'Air costs',
      r'\approx 20\%\ \text{of the strength}',
      'about a fifth of the strength, paid for with a lower ratio',
    ),
  ],
  handbook: 'Handbook p. 125',
);

const curingBrief = BriefSection(
  title: 'Which way the percentage goes',
  picture: curingPicture,
  steps: [
    (
      'Concrete keeps getting stronger',
      'It does not set and stop. It carries on hardening for weeks, as long '
          'as it stays damp. Seven day strength runs near seventy percent of the '
          'twenty eight day figure.',
    ),
    (
      'Decide the direction before you touch the number',
      'Ask yourself first: should my answer come out BIGGER or smaller? '
          'Going toward the smaller figure you multiply. Coming back to the '
          'bigger one you divide. Every wrong answer on this page is that '
          'choice made backwards.',
    ),
    (
      'Use the share you were given',
      'Ninety percent means multiply by 0.90, never by 0.10. The leftover is '
          'not the answer to anything here.',
    ),
    (
      'And drying early is expensive',
      'Concrete let dry too soon simply stops gaining. It may keep only '
          'fifty five to sixty five percent of what it could have had, and it '
          'never catches up.',
    ),
  ],
  spoken: [
    (
      'Seven days',
      r'f_{c,7} \approx 0.70\, f_{c,28}',
      'the seven day strength is about seventy percent of the later one',
    ),
    (
      'So the later one',
      r'f_{c,28} = \frac{f_{c,7}}{0.70}',
      'going back up to the bigger figure, you divide',
    ),
    (
      'Dried out early',
      r'0.55 \text{ to } 0.65 \text{ of the best}',
      'barely more than half of what proper curing would have given',
    ),
  ],
  handbook: 'Handbook p. 125',
);

const fieldBrief = BriefSection(
  title: 'The cylinder is not the slab',
  picture: fieldPicture,
  steps: [
    (
      'Two pieces of the same concrete',
      'A test cylinder goes to a laboratory and sits under water at a steady '
          'temperature. The slab it came from is left to whoever is on site that '
          'week, in whatever weather turns up.',
    ),
    (
      'So the lab number is not the slab number',
      'The break test tells you what the mix COULD do. Take the curing off '
          'first, then compare what is left against the specification. Holding '
          'the raw lab figure against the spec quietly skips the hardest part '
          'of the job.',
    ),
    (
      'The gap is bigger than you would guess',
      'A pour kept wet for a fortnight might keep ninety five percent of its '
          'cylinder strength. One stripped at three days into hot wind keeps '
          'around sixty.',
    ),
    (
      'Which is why curing is the cheapest strength there is',
      'That gap is wider than the gap between a good mix and a mediocre one, '
          'and it costs almost nothing. It is also the first thing a tight '
          'schedule gives away.',
    ),
  ],
  spoken: [
    (
      'What the slab gets',
      r'f_{c,\text{field}} = k \, f_{c,\text{lab}}',
      'the lab strength, times whatever the curing left',
    ),
    (
      'Cured properly',
      r'k \approx 0.92 \text{ to } 0.95',
      'kept wet for a fortnight, it keeps almost all of it',
    ),
    (
      'Dried out early',
      r'k \approx 0.60',
      'stripped early into hot wind, it keeps about three fifths',
    ),
  ],
  handbook: 'Handbook p. 125',
);

const weighingBrief = BriefSection(
  title: 'Three weighings, and what each one leaves out',
  picture: weighingPicture,
  steps: [
    (
      'A stone has holes in it',
      'Aggregate is not solid through. It has pores, and they can be empty '
          'or full of water. That is why one stone gets weighed three different '
          'ways.',
    ),
    (
      'The three weighings',
      'Oven dry, with the pores empty: A. Soaked and then wiped, so the '
          'pores are full but the outside is dry: B. And hanging in water: C. '
          'Every number on the page is built from those three.',
    ),
    (
      'Subtracting picks which volume you mean',
      'B minus C is the water the WHOLE stone pushed aside, pores included, '
          'which is the bulk volume. A minus C leaves the water-filled pores out '
          'of the volume, which is the apparent one. A smaller volume means a '
          'bigger answer, so apparent is always the largest of the three.',
    ),
    (
      'Absorption divides by the dry weight',
      'It is the water the pores hold as a share of the DRY stone. Dividing '
          'by the soaked weight instead is the slip this lesson names.',
    ),
  ],
  spoken: [
    (
      'Bulk, oven dry',
      r'G_{sb} = \frac{A}{B - C}',
      'the dry weight, over the whole stone volume',
    ),
    (
      'Bulk, saturated',
      r'G_{ssd} = \frac{B}{B - C}',
      'the soaked weight, over the same whole volume',
    ),
    (
      'Apparent',
      r'G_{sa} = \frac{A}{A - C}',
      'the dry weight, over the volume with the water-filled pores left out',
    ),
    (
      'Absorption',
      r'\frac{B - A}{A} \times 100',
      'the water the pores hold, as a percent of the dry weight',
    ),
  ],
  handbook: 'Handbook p. 123',
);

const gradingBrief = BriefSection(
  title: 'One number for a whole curve',
  picture: gradingPicture,
  steps: [
    (
      'Sand is sorted by shaking it',
      'Stack sieves coarsest on top, pour the sand in, shake. Each sieve '
          'keeps the grains too big to pass. Now you know how much of the sand '
          'is each size.',
    ),
    (
      'The fineness modulus squeezes that into one number',
      'Add up the cumulative percent RETAINED on the standard sieves and '
          'divide by a hundred. Retained, not passing. Cumulative, not sieve by '
          'sieve.',
    ),
    (
      'Higher means coarser, which reads backwards',
      'The name says fineness but the number goes UP for a coarser sand, '
          'because more is being held back. A concrete sand is normally asked to '
          'land between 2.3 and 3.1.',
    ),
    (
      'What one number cannot tell you',
      'Two sands with the same modulus can have completely different curves. '
          'A sand missing one size in the middle leaves gaps that have to be '
          'filled with expensive paste, and the modulus will not show it.',
    ),
  ],
  spoken: [
    (
      'The modulus',
      r'FM = \frac{\sum \text{cumulative \% retained}}{100}',
      'add the cumulative retained percentages and divide by a hundred',
    ),
    (
      'A concrete sand',
      r'2.3 \le FM \le 3.1',
      'the usual range for sand going into concrete',
    ),
    (
      'Higher means',
      r'\text{coarser}',
      'a bigger number is a coarser sand, not a finer one',
    ),
  ],
  handbook: 'Handbook p. 123',
);

const voidsBrief = BriefSection(
  title: 'Three things in the mix, and what each share is of',
  picture: voidsPicture,
  steps: [
    (
      'A road surface is three things',
      'Compacted asphalt is stone, the black binder that glues it, and air. '
          'Every number on this page is one of those three as a share of '
          'something else. Getting the something else right is the whole skill.',
    ),
    (
      'Air voids: air against the WHOLE specimen',
      'How far the compacted mix is from the same mix with no air left in '
          'it. That is what the two gravities give you, one measured with air '
          'and one without.',
    ),
    (
      'VMA: all the space between the stones',
      'The air and the binder together, however that space happens to be '
          'filled. It is what is left once you take the stone volume away from '
          'a hundred.',
    ),
    (
      'VFA: the binder as a share of THAT space',
      'Not of the whole mix. Design sits near four percent air, with enough '
          'room between the stones to carry a proper film of binder around '
          'every one.',
    ),
  ],
  spoken: [
    (
      'Air voids',
      r'V_a = 100\,\frac{G_{mm} - G_{mb}}{G_{mm}}',
      'how far the compacted mix falls short of the airless one',
    ),
    (
      'Space between stones',
      r'VMA = 100 - \frac{G_{mb} P_s}{G_{sb}}',
      'a hundred, less the share that is stone',
    ),
    (
      'Filled with asphalt',
      r'VFA = 100\,\frac{VMA - V_a}{VMA}',
      'the binder as a percent of the space between the stones',
    ),
  ],
  handbook: 'Handbook p. 124',
);

const checkBrief = BriefSection(
  title: 'Four checks that need no calculator',
  picture: checkPicture,
  steps: [
    (
      'These numbers have to agree with each other',
      'Air, binder and stone are shares of the same specimen, so some things '
          'can never happen. Four quick looks catch nearly every slip before the '
          'arithmetic does.',
    ),
    (
      'The airless gravity is always the bigger one',
      'It is the same materials with the air taken out, so it must be '
          'denser. A negative air void means the two were swapped.',
    ),
    (
      'VMA is always bigger than the air voids',
      'The air is only part of the space between the stones; the binder is '
          'the rest. And VFA is a share of VMA, so it can never pass a hundred.',
    ),
    (
      'A VMA near eighty is the stone',
      'Space between stones is normally around fifteen percent. If yours is '
          'up near eighty, you have calculated the stone volume, which is the '
          'term the formula was supposed to subtract.',
    ),
  ],
  spoken: [
    (
      'Always',
      r'G_{mm} > G_{mb}',
      'the airless gravity is bigger than the compacted one',
    ),
    (
      'Always',
      r'VMA > V_a',
      'the space between the stones is bigger than the air in it',
    ),
    (
      'And',
      r'VFA \le 100\%',
      'a share of that space cannot be more than all of it',
    ),
  ],
  handbook: 'Handbook p. 124',
);

const moistureBrief = BriefSection(
  title: 'One threshold in wood',
  picture: moisturePicture,
  steps: [
    (
      'Wood carries water in two places',
      'Some water soaks into the cell walls themselves. The rest just sits '
          'loose in the hollow spaces inside. Those two behave completely '
          'differently, and one line separates them.',
    ),
    (
      'Above thirty percent, nothing changes',
      'The walls are already full, so any extra water is loose in the '
          'cavities. It can come and go and the timber is no stronger, no '
          'weaker and no smaller for it.',
    ),
    (
      'Below it, everything changes',
      'Now the water is leaving the walls themselves. Drying shrinks the '
          'wood and makes it stiffer and stronger. Wetting swells it and softens '
          'it again.',
    ),
    (
      'And it divides by the DRY weight',
      'Moisture content is the water over the oven dry wood, never over the '
          'wet weight. Green timber can therefore read well over a hundred '
          'percent: there really can be more water than wood.',
    ),
  ],
  spoken: [
    (
      'Moisture content',
      r'MC = \frac{W_{wet} - W_{OD}}{W_{OD}} \times 100',
      'the water, over the oven dry weight of the wood',
    ),
    (
      'The threshold',
      r'FSP \approx 30\%',
      'the fiber saturation point, where the cell walls are just full',
    ),
    (
      'Below it',
      r'\text{drier} \Rightarrow \text{smaller and stronger}',
      'drying below the threshold shrinks it and stiffens it',
    ),
  ],
  handbook: 'Handbook p. 129',
);

const mortarBrief = BriefSection(
  title: 'M, S, N, O, and why the strongest is not the best',
  picture: mortarPicture,
  steps: [
    (
      'Four mortars in an order you cannot work out',
      'Strongest to weakest, they go M, S, N, O. There is no logic in it. '
          'They are the every-other letters of MaSoN wOrK, and that is the only '
          'reason anybody remembers them.',
    ),
    (
      'Strong mortar can be the wrong mortar',
      'A joint harder than the brick around it does not bend when the wall '
          'moves. So the brick cracks instead of the joint, and replacing brick '
          'costs far more than repointing.',
    ),
    (
      'Weaker mortar is easier to work with',
      'It stays soft under the trowel longer and forgives small movements. '
          'That is a real advantage, not a compromise.',
    ),
    (
      'Where each one goes',
      'M below ground. S where there is soil pressure or sideways load. N is '
          'the general purpose one above grade. O is for soft old masonry '
          'indoors, where anything harder would do damage.',
    ),
  ],
  spoken: [
    (
      'Strongest to weakest',
      r'M > S > N > O',
      'the order of the four types by strength',
    ),
    (
      'The phrase',
      r'\text{MaSoN wOrK}',
      'take every other letter and you have the order',
    ),
    (
      'And',
      r'\text{strength} \downarrow \Rightarrow \text{workability} \uparrow',
      'the weaker ones are the easier ones to lay and the kinder to brick',
    ),
  ],
  handbook: 'Handbook p. 130',
);

const factorBrief = BriefSection(
  title: 'The factors, and which way each one pushes',
  picture: factorPicture,
  steps: [
    (
      'A wood value is a book number times a string of factors',
      'Look up the reference strength, then multiply by a factor for each '
          'thing about your situation that the book did not assume.',
    ),
    (
      'Nearly all of them are penalties',
      'Wet service, sustained heat, and being a big member all take capacity '
          'away. If you are unsure of a factor, betting on below one is usually '
          'right.',
    ),
    (
      'The duration factor is the exception',
      'Wood carries MORE the more briefly it is loaded. A permanent load '
          'gets 0.9. Normal occupancy gets 1.0, which is what the book values '
          'already assume. A week of snow gets 1.25, and wind or an earthquake '
          'gets 1.6.',
    ),
    (
      'Shorter is always higher',
      'That is the direction people get backwards. The shortest load on the '
          'list is the one allowed the biggest number.',
    ),
  ],
  spoken: [
    (
      'The chain',
      r'F\prime = F \times C_D \times C_M \times C_t \times \dots',
      'the book value, times a factor for each thing about your case',
    ),
    (
      'Wind or seismic',
      r'C_D = 1.6',
      'the briefest load gets the biggest allowance',
    ),
    (
      'Permanent load',
      r'C_D = 0.9',
      'a load that never comes off gets a penalty',
    ),
  ],
  handbook: 'Handbook p. 129',
);

const blendBrief = BriefSection(
  title: 'Two rules, and the direction picks between them',
  picture: blendPicture,
  steps: [
    (
      'A composite has a grain, like wood',
      'Stiff fibers set in soft glue. Which way you pull matters more than '
          'anything else about it, and that is the whole of this page.',
    ),
    (
      'Along the fibers: they share the stretch',
      'Both materials are forced to stretch by the same amount, so their '
          'stiffnesses add up, each counted by how much of the volume it takes. '
          'That gives a stiff composite, close to the fibers themselves.',
    ),
    (
      'Across them: they queue up',
      'Now the load passes through the fiber and the glue one after the '
          'other, and the soft glue gives way. The reciprocals add instead, and '
          'the answer is always smaller, usually not much more than the glue on '
          'its own.',
    ),
    (
      'Density has no direction',
      'Weight does not care which way you pull, so density is a plain '
          'weighted average by volume either way. The exam nearly always asks '
          'for the along case.',
    ),
  ],
  spoken: [
    (
      'Along the fibers',
      r'E_c = f_1 E_1 + f_2 E_2',
      'each stiffness counted by its share of the volume, added',
    ),
    (
      'Across them',
      r'\frac{1}{E_c} = \frac{f_1}{E_1} + \frac{f_2}{E_2}',
      'the upside down versions add, which always gives a smaller answer',
    ),
    (
      'Density, either way',
      r'\rho_c = f_1\rho_1 + f_2\rho_2',
      'a plain weighted average, whichever way the fibers run',
    ),
  ],
  handbook: 'Handbook p. 123',
);

const isostrainBrief = BriefSection(
  title: 'Whichever one is shared, the other is not',
  picture: isostrainPicture,
  steps: [
    (
      'Glued together means stretched together',
      'Pull along the fibers and the two materials cannot move independently. '
          'They stretch by the same amount. Equal strain.',
    ),
    (
      'So the stresses are wildly unequal',
      'Stress is stiffness times strain. At the same strain, a fiber sixty '
          'times stiffer than the glue carries sixty times the stress. That is '
          'why a composite at a hundred megapascals overall can have four '
          'hundred inside its fibers.',
    ),
    (
      'Which is the point of putting fibers in',
      'Fibers taking up a quarter of the volume can end up carrying almost '
          'all of the load. The glue is there mostly to hold them in place and '
          'pass load between them.',
    ),
    (
      'Turn the load and it flips',
      'Across the fibers, the same STRESS passes through both, and now the '
          'soft glue does nearly all the moving. Whichever quantity is shared, '
          'the other one is not.',
    ),
  ],
  spoken: [
    (
      'Along: shared strain',
      r'\varepsilon_1 = \varepsilon_2',
      'both stretch the same amount',
    ),
    (
      'So the stresses split',
      r'\sigma_1 = E_1\varepsilon,\; \sigma_2 = E_2\varepsilon',
      'the stiffer one carries proportionally more',
    ),
    (
      'Across: shared stress',
      r'\sigma_1 = \sigma_2',
      'the same stress passes through both, and the soft one moves most',
    ),
  ],
  handbook: 'Handbook p. 123',
);

const galvanicBrief = BriefSection(
  title: 'The more active one is eaten',
  picture: galvanicPicture,
  steps: [
    (
      'Corrosion in a couple needs four things at once',
      'Two DIFFERENT metals. Something wet between them, like rain or damp '
          'soil. And an electrical path joining them. Take any one away and '
          'nothing happens.',
    ),
    (
      'Then the more active one dissolves',
      'Metals sit in an order from active to noble. Of any pair, the more '
          'active one corrodes and the nobler one is protected. It is a bargain '
          'struck between the two, not a property of either.',
    ),
    (
      'No metal is safe on its own terms',
      'Steel is protected beside aluminum and eaten beside copper. Same '
          'steel. The company it keeps decides.',
    ),
    (
      'Which is how we use it deliberately',
      'Galvanizing coats steel in zinc, which is more active, so the zinc '
          'goes first and the steel survives even where the coating is '
          'scratched. A block bolted to a hull does the same job.',
    ),
  ],
  spoken: [
    (
      'At the anode',
      r'M^0 \rightarrow M^{n+} + ne^-',
      'the active metal gives up electrons and dissolves away',
    ),
    (
      'Active to noble',
      r'Mg,\; Zn,\; Al,\; \text{steel},\; Cu,\; Ti',
      'the order: whichever of your pair is further left is the one eaten',
    ),
    (
      'A cell needs',
      r'\text{two metals} + \text{water} + \text{a path}',
      'remove any one of them and the corrosion stops',
    ),
  ],
  handbook: 'Handbook p. 116',
);

const pickingBrief = BriefSection(
  title: 'Cross them off one column at a time',
  picture: pickingPicture,
  steps: [
    (
      'The best at one thing is rarely the answer',
      'A selection question gives you a table and a list of requirements. '
          'Copper conducts heat better than anything else there and is three '
          'times too heavy for a light part. Titanium shrugs off seawater and '
          'barely conducts at all.',
    ),
    (
      'So do not pick. Eliminate.',
      'Take the requirements one at a time, in whatever order is quickest to '
          'check, and cross off every metal that fails. Keep going until one is '
          'left.',
    ),
    (
      'A requirement that rules nothing out is doing no work',
      'If every candidate passes it, it is there to fill space. Notice it '
          'and move on to one that actually separates them.',
    ),
    (
      'And if nothing passes, the spec is wrong',
      'That is a real answer, not a dead end. When no material can meet '
          'every requirement, the requirements are what has to change.',
    ),
  ],
  spoken: [
    (
      'Copper',
      r'403\ \text{W/mK},\; 8{,}933\ \text{kg/m}^3',
      'the best conductor on the page, and much the heaviest',
    ),
    (
      'Aluminum',
      r'236\ \text{W/mK},\; 2{,}698\ \text{kg/m}^3',
      'conducts well and is light, which is why it wins so often',
    ),
    (
      'Steel, titanium',
      r'83.5\ \text{and}\ 22\ \text{W/mK}',
      'neither is here for conducting heat',
    ),
  ],
  handbook: 'Handbook p. 119',
);

const threeNumbersBrief = BriefSection(
  title: 'Three ways to say how heavy a liquid is',
  picture: threeNumbersPicture,
  steps: [
    (
      'Fill a box one meter each way',
      'With water, that box holds 1,000 kilograms. That is the DENSITY: how '
          'much stuff is packed into the space. Oil packs less in, mercury packs '
          'far more.',
    ),
    (
      'Now weigh it',
      'Those 1,000 kilograms push down with about 9,810 newtons. That is the '
          'SPECIFIC WEIGHT: the same box described as a push instead of an '
          'amount. It is just the density multiplied by gravity.',
    ),
    (
      'Or compare it to water',
      'Specific gravity is the liquid held up against water. Water is 1. '
          'Under 1 floats on water, over 1 sinks. It has no units at all, because '
          'it is one weight divided by another.',
    ),
    (
      'Pressure wants the pushing one',
      'A pressure is a push, so pressure formulas want the specific weight. '
          'Hand them a density and the answer comes out about ten times too '
          'small, because gravity got left out.',
    ),
  ],
  spoken: [
    (
      'Weight from mass',
      r'\gamma = \rho g',
      'specific weight is density times gravity',
    ),
    (
      'The ratio to water',
      r'SG = \frac{\rho}{\rho_w} = \frac{\gamma}{\gamma_w}',
      'the liquid divided by water, which cancels the units away',
    ),
    (
      'Water',
      r'1{,}000\ \text{kg/m}^3,\quad 9{,}810\ \text{N/m}^3',
      'a thousand kilograms in a cubic meter, weighing 9,810 newtons',
    ),
  ],
  handbook: 'Handbook p. 176',
);

const viscosityBrief = BriefSection(
  title: 'A thinner film of oil drags harder',
  picture: viscosityPicture,
  steps: [
    (
      'Slide a plate on a film of oil',
      'The oil touching the plate travels with it. The oil touching the fixed '
          'surface below does not move at all. So the oil in between is smeared, '
          'and it drags back on the plate.',
    ),
    (
      'What counts is the speed ACROSS the gap',
      'Not the plate speed on its own. Take the plate speed and divide it by '
          'the thickness of the film. A thin film has to make the same change of '
          'speed over a much shorter distance, so it is smeared harder.',
    ),
    (
      'Which is why bearings run on a hair of oil',
      'Thinner film, more drag. That reads backwards until you look at the '
          'gap in the picture. Thicker oil drags more too, and so does moving '
          'faster.',
    ),
    (
      'Two traps',
      'The gap is nearly always given in millimeters and the formula wants '
          'meters, a factor of a thousand. And use the thick-or-thin viscosity in '
          'pascal seconds, never the other one.',
    ),
  ],
  spoken: [
    (
      "Newton's law",
      r'\tau = \mu \frac{dv}{dy}',
      'the drag is the viscosity times how fast the speed changes across the gap',
    ),
    (
      'Across a thin film',
      r'\tau = \mu \frac{v}{\delta}',
      'viscosity times plate speed, divided by the film thickness',
    ),
    (
      'The other viscosity',
      r'\nu = \frac{\mu}{\rho}',
      'the kinematic one: viscosity divided by density',
    ),
  ],
  handbook: 'Handbook p. 176',
);

const capillaryBrief = BriefSection(
  title: 'A narrower straw climbs higher',
  picture: capillaryPicture,
  steps: [
    (
      'Water creeps up a thin tube by itself',
      'Stand a very thin tube in water and the water climbs inside it, above '
          'the level in the dish, with nobody pushing it. The glass is pulling the '
          'water up around the rim.',
    ),
    (
      'Why thin wins',
      'The pull happens round the RIM, so it grows with the width. The weight '
          'of water lifted grows with the AREA, which grows faster. Halve the '
          'bore and you double the climb.',
    ),
    (
      'So it only matters in tiny spaces',
      'A fraction of a millimeter across. That is soil and concrete, not '
          'pipework. In a water pipe the climb is nothing worth counting.',
    ),
    (
      'Some liquids get pushed down instead',
      'Water wets glass and climbs. Mercury does not wet glass, so the same '
          'pull works the other way and the mercury sits LOWER inside the tube '
          'than outside it.',
    ),
  ],
  spoken: [
    (
      'Capillary rise',
      r'h = \frac{4\sigma \cos\beta}{\gamma d}',
      'the surface pull over the liquid weight and the bore, so a smaller bore climbs more',
    ),
    (
      'Wets the glass',
      r'\beta < 90^\circ \Rightarrow h > 0',
      'the contact angle is small, so the liquid climbs',
    ),
    (
      'Does not',
      r'\beta > 90^\circ \Rightarrow h < 0',
      'past ninety degrees the climb goes negative and it is pushed down',
    ),
  ],
  handbook: 'Handbook p. 176',
);

const depthBrief = BriefSection(
  title: 'Only the depth, and what the liquid is',
  picture: depthPicture,
  steps: [
    (
      'Dive to the bottom of a pool',
      'Your ears hurt because of how DEEP you are, not because of how big the '
          'pool is. Swim to the same depth in a much wider pool and it feels '
          'exactly the same.',
    ),
    (
      'The shape of the vessel changes nothing',
      'Look at the two vessels. One flares out and holds far more water, the '
          'other tapers in. At the same depth the marked points press equally '
          'hard. How much water sits above and to the side does not come into it.',
    ),
    (
      'Which is why a roof tank pressurizes a building',
      'A narrow pipe of water high up gives the same pressure as a lake at '
          'that height. And pressure on a dam is a triangle: nothing at the top, '
          'most at the bottom.',
    ),
    (
      'Use the weight, not the density',
      'Multiply the specific weight by the depth. Use the density instead and '
          'you are short by a factor of gravity.',
    ),
  ],
  spoken: [
    (
      'Pressure at depth',
      r'p = \gamma h = \rho g h',
      'specific weight times depth, and nothing else',
    ),
    (
      'Water',
      r'\gamma_w = 9{,}810\ \text{N/m}^3',
      'water weighs 9,810 newtons a cubic meter',
    ),
    (
      'So five meters down',
      r'\approx 49\ \text{kPa}',
      'about 49 kilopascals, whatever the vessel looks like',
    ),
  ],
  handbook: 'Handbook p. 177',
);

const manometerBrief = BriefSection(
  title: 'Start where you know, then walk the tube',
  picture: manometerPicture,
  steps: [
    (
      'A bent tube that reads pressure',
      'Two legs joined at the bottom with a heavy liquid in the bend. Push '
          'harder on one side and that leg goes down while the other goes up. You '
          'read the pressure off the difference.',
    ),
    (
      'Do not hunt for a formula. Walk it.',
      'Start at the end where you already know the pressure, usually the open '
          'one at zero. Then step along the tube to where you want to be, adding '
          'and subtracting as you go.',
    ),
    (
      'Three rules for the walk',
      'Going DOWN a column adds that column\'s weight. Coming UP one '
          'subtracts it. Moving sideways in the same liquid changes nothing, '
          'because only depth counts. Air weighs too little to bother with.',
    ),
    (
      'Each liquid carries its own weight',
      'A meter of mercury is worth about thirteen meters of water. And the '
          'taller column always stands on the side with LESS pressure.',
    ),
  ],
  spoken: [
    ('Down a column', r'+\,\gamma h', 'add the specific weight times the drop'),
    (
      'Up a column',
      r'-\,\gamma h',
      'subtract the specific weight times the climb',
    ),
    (
      'A simple U-tube',
      r'P_0 = P_2 + \gamma_2 h_2 - \gamma_1 h_1',
      'one walk written out: start known, add what you went down, subtract what you came up',
    ),
  ],
  handbook: 'Handbook p. 178',
);

const gaugeBrief = BriefSection(
  title: 'Which zero you are counting from',
  picture: gaugePicture,
  steps: [
    (
      'The air is already pressing on you',
      'About 101 kilopascals of it, all the time, from every side. You never '
          'notice, because it has always been there.',
    ),
    (
      'Two places to start counting',
      'GAUGE pressure counts from the air around us, so a pond surface reads '
          'zero. ABSOLUTE counts from a perfect vacuum, where there is nothing at '
          'all. One pressure, two rulers, 101 apart.',
    ),
    (
      'Civil work quotes gauge almost always',
      'The air presses on both sides of nearly everything we build, so it '
          'cancels itself out. The depth formula and an open manometer both hand '
          'you a gauge pressure already.',
    ),
    (
      'Gauge can go negative, absolute cannot',
      'A gauge reading below zero just means less than the air outside, which '
          'is a vacuum. Below a perfect vacuum there is nothing left to have.',
    ),
  ],
  spoken: [
    (
      'The link',
      r'P_{abs} = P_{atm} + P_{gauge}',
      'absolute is the air pressure plus the gauge reading',
    ),
    (
      'The atmosphere',
      r'101.3\ \text{kPa} = 14.7\ \text{psi}',
      'about 101 kilopascals, or 14.7 pounds per square inch',
    ),
    (
      'Open to the air',
      r'P_{gauge} = 0',
      'any surface open to the sky reads zero gauge',
    ),
  ],
  handbook: 'Handbook p. 177',
);

const gateBrief = BriefSection(
  title: 'How hard it pushes, and where it pushes',
  picture: gatePicture,
  steps: [
    (
      'Water pushes harder the deeper it gets',
      'On a gate holding a reservoir back, the push at the top edge is almost '
          'nothing and the push at the bottom edge is the most there is. Drawn '
          'out, it is a triangle lying on its side.',
    ),
    (
      'How hard: use the middle of the gate',
      'The pressure halfway down is the average of all of it, so the total '
          'push is that middle pressure times the area of the gate. That gives '
          'you the size of the push.',
    ),
    (
      'Where: LOWER than the middle',
      'Because the bottom half is pushed harder than the top half, the one '
          'arrow that stands for all of it sits below the middle. For a gate '
          'reaching the surface it lands two thirds of the way down.',
    ),
    (
      'And it creeps back toward the middle as it sinks',
      'Sink the same gate deep enough and top and bottom are pushed almost '
          'equally, so the arrow moves back toward the middle. Size from the '
          'middle, position from the lower point, every time.',
    ),
  ],
  spoken: [
    (
      'The push',
      r'F_R = \gamma h_C A',
      'the pressure at the middle of the gate, times the area of the gate',
    ),
    (
      'Where it acts',
      r'y_{CP} = y_C + \frac{I_{xC}}{y_C A}',
      'the middle depth, plus a bit more that shrinks as the gate goes deeper',
    ),
    (
      'A rectangle',
      r'I_{xC} = \frac{bh^3}{12}',
      'the shape number for a rectangle: width times height cubed, over twelve',
    ),
  ],
  handbook: 'Handbook p. 179',
);

const buoyancyBrief = BriefSection(
  title: 'Weigh the water it shoves out of the way',
  picture: buoyancyPicture,
  steps: [
    (
      'Get in a bath and the water rises',
      'You pushed some water out of the way. Whatever that water weighs is '
          'exactly how hard the water now pushes UP on you. Nothing else is in '
          'it.',
    ),
    (
      'Then hold that against its own weight',
      'Push bigger and it rises. Weight bigger and it sinks. Equal and it '
          'hangs still. A floating thing has already settled at the depth where '
          'the two match.',
    ),
    (
      'What the object is made of does not matter',
      'A steel box floats and a solid steel block sinks. Same steel. The box '
          'shoves aside far more water, so it gets far more push.',
    ),
    (
      'Which is how buried tanks come out of the ground',
      'An empty tank in wet ground is shoved UP by the groundwater it '
          'displaces. If it weighs less than that water, it leaves the hole it '
          'was buried in.',
    ),
  ],
  spoken: [
    (
      'The push up',
      r'F_B = \gamma V_{displaced}',
      'the weight of the fluid the body shoved aside',
    ),
    (
      'What is left over',
      r'F_{net} = F_B - W',
      'the push up minus the weight down: positive rises, negative sinks',
    ),
    (
      'Floating',
      r'F_B = W',
      'a floating body has shoved aside exactly its own weight',
    ),
  ],
  handbook: 'Handbook p. 179',
);

const continuityBrief = BriefSection(
  title: 'The same water through a smaller hole',
  picture: continuityPicture,
  steps: [
    (
      'Put your thumb over a hose',
      'The same water is still coming, so it has to leave through less space. '
          'It leaves faster. That is the whole idea, and it has to be true: '
          'whatever goes in must come out.',
    ),
    (
      'The catch is that area squares',
      'Halve the diameter and the opening does not halve, it QUARTERS. So the '
          'speed goes up four times, not two. A third of the bore is nine times '
          'the speed.',
    ),
    (
      'Read carefully which one you were given',
      'If the question changes the AREA, the speed changes in step with it, '
          'no squaring. The squaring only comes in when you are handed a diameter '
          'or a side.',
    ),
    (
      'Length is not in it at all',
      'A longer pipe of the same bore carries the same water at the same '
          'speed. What length costs is pressure, through friction, and that is a '
          'different equation.',
    ),
  ],
  spoken: [
    (
      'Flow',
      r'Q = Av',
      'how much goes past each second is the opening times the speed',
    ),
    (
      'Continuity',
      r'A_1 v_1 = A_2 v_2',
      'opening times speed is the same everywhere along the pipe',
    ),
    (
      'For a round pipe',
      r'\frac{v_2}{v_1} = \left(\frac{D_1}{D_2}\right)^2',
      'the speed goes up by the diameter ratio SQUARED',
    ),
  ],
  handbook: 'Handbook p. 180',
);

const bernoulliBrief = BriefSection(
  title: 'Faster water presses less',
  picture: bernoulliPicture,
  steps: [
    (
      'Water carries its energy three ways',
      'As pressure, as speed, and as height. Bernoulli says those three add '
          'up to the same total everywhere along the pipe, as long as friction is '
          'not eating any of it.',
    ),
    (
      'So they trade against each other',
      'Squeeze the pipe and the water must speed up. The total cannot change, '
          'so something has to give, and what gives is the PRESSURE. It falls '
          'exactly where the water is quickest.',
    ),
    (
      'Open it out again and the pressure comes back',
      'The water slows down and hands the energy back to pressure. A venturi '
          'meter is that pressure drop sold as an instrument.',
    ),
    (
      'Two warnings',
      'Work out the speed with continuity BEFORE you use Bernoulli. And the '
          'moment a question mentions pipe length, roughness or head loss, you '
          'need the energy equation with its friction term instead.',
    ),
  ],
  spoken: [
    (
      'Bernoulli',
      r'\frac{P}{\gamma} + \frac{v^2}{2g} + z = \text{the same everywhere}',
      'pressure, speed and height, each written as meters, always adding to one total',
    ),
    (
      'Level pipe',
      r'P_2 = P_1 + \frac{\rho}{2}(v_1^2 - v_2^2)',
      'with no height change, whatever the speed gains the pressure loses',
    ),
    (
      'With friction',
      r'\dots + h_f',
      'a real pipe also loses head to rubbing, which never comes back',
    ),
  ],
  handbook: 'Handbook p. 180',
);

const torricelliBrief = BriefSection(
  title: 'A hole in a tank: only the depth decides the speed',
  picture: torricelliPicture,
  steps: [
    (
      'Punch a hole in a full tank',
      'The water squirts out. How fast depends on one thing: how far the hole '
          'sits below the surface. That distance is the head.',
    ),
    (
      'It is the same speed as falling',
      'The jet leaves at exactly the speed a stone would reach if you dropped '
          'it from the surface down to the hole. Same trade of height for speed, '
          'so the same answer.',
    ),
    (
      'What is NOT in it matters more',
      'Not the size of the hole, which decides how MUCH comes out, not how '
          'fast. Not how wide the tank is. Not how much water sits behind it. A '
          'thin tall tube beats a broad shallow pan.',
    ),
    (
      'The square root softens it',
      'Four times the depth is only twice the speed. Nine times the depth is '
          'three times the speed.',
    ),
  ],
  spoken: [
    (
      'Torricelli',
      r'v = \sqrt{2gh}',
      'the square root of twice gravity times the head',
    ),
    (
      'Which came from',
      r'z_1 = \frac{v_2^2}{2g}',
      'the height the water started at, turned entirely into speed',
    ),
    (
      'Four times the head',
      r'\Rightarrow 2 \times \text{the speed}',
      'because the head sits under a square root',
    ),
  ],
  handbook: 'Handbook p. 180',
);

const reynoldsBrief = BriefSection(
  title: 'One number says which kind of flow you have',
  picture: reynoldsPicture,
  steps: [
    (
      'Water can travel two very different ways',
      'Slowly, in neat layers that slide over each other, which is LAMINAR. '
          'Or fast and churning, mixing across itself, which is TURBULENT. Think '
          'honey pouring against a river in flood.',
    ),
    (
      'One number tells you which',
      'Take the speed times the pipe diameter and divide by how thick and '
          'sticky the fluid is. Fast, wide and thin pushes the number up; slow, '
          'narrow and thick pulls it down.',
    ),
    (
      'The number is a decision, not an answer',
      'Under 2,100 the flow is laminar, and the friction factor is just 64 '
          'divided by the number. Over 10,000 it is turbulent, and you read the '
          'factor off the Moody chart. In between is no place to design.',
    ),
    (
      'A sanity check on water mains',
      'Water is so thin that any real pipe at any sensible speed is deeply '
          'turbulent. If you get a few thousand for a water main, the diameter '
          'probably went in as millimeters.',
    ),
  ],
  spoken: [
    (
      'Reynolds',
      r'Re = \frac{\rho v D}{\mu} = \frac{vD}{\nu}',
      'speed times diameter, divided by how sticky the fluid is',
    ),
    (
      'Laminar',
      r'Re < 2{,}100 \Rightarrow f = \frac{64}{Re}',
      'under 2,100 the friction factor is 64 over the number, no chart needed',
    ),
    (
      'Turbulent',
      r'Re > 10{,}000 \Rightarrow \text{Moody}',
      'over 10,000 you read the factor off the Moody chart',
    ),
  ],
  handbook: 'Handbook p. 181',
);

const darcyBrief = BriefSection(
  title: 'What rubbing along the pipe costs',
  picture: darcyPicture,
  steps: [
    (
      'Water rubs against the pipe wall',
      'Over a long run that rubbing eats pressure. The pressure it eats is '
          'called head loss, and it is what a pump has to make up.',
    ),
    (
      'Two parts behave as you would guess',
      'Twice the length is twice the loss. A rougher pipe has a bigger '
          'friction factor and loses more. Nothing surprising there.',
    ),
    (
      'Speed is SQUARED',
      'Twice the speed is four times the loss. That is why pipes get sized by '
          'how fast the water runs through them, not just by whether it fits.',
    ),
    (
      'Which makes one size up the cheapest fix there is',
      'Double the bore at the same flow and the water slows to a quarter '
          'speed as well as having half the length-over-diameter. Put together, '
          'the loss drops about thirty times.',
    ),
  ],
  spoken: [
    (
      'Darcy-Weisbach',
      r'h_f = f \frac{L}{D} \frac{v^2}{2g}',
      'the friction factor, times length over diameter, times the speed head',
    ),
    (
      'Laminar factor',
      r'f = \frac{64}{Re}',
      'in laminar flow the factor is simply 64 over the Reynolds number',
    ),
    (
      'At a fixed flow',
      r'2D \Rightarrow \approx \frac{h_f}{32}',
      'double the bore and the loss falls to about a thirtieth',
    ),
  ],
  handbook: 'Handbook p. 182',
);

const minorBrief = BriefSection(
  title: 'Add the pipe and every fitting on it',
  picture: minorPicture,
  steps: [
    (
      'The pipe is not the only thing costing head',
      'Every bend, valve and tee the water has to get through costs some too. '
          'They are called minor losses, and the name is a lie: one globe valve '
          'can cost more than a hundred meters of the pipe it sits in.',
    ),
    (
      'Each fitting has its own number',
      'Look up the fitting, get a coefficient, multiply it by the speed head. '
          'Every fitting on the run uses the SAME speed head, because the water '
          'is going the same speed through all of them.',
    ),
    (
      'The total is the pipe plus all of them',
      'One friction loss for the pipe, one term for each fitting, added up '
          'once. That total is what the pump has to beat.',
    ),
    (
      'Three ways people get it wrong',
      'Quoting the fittings and forgetting the pipe. Quoting the pipe and '
          'forgetting the fittings. Or adding the pipe in twice. Count the '
          'fittings off the drawing one at a time and label every number.',
    ),
  ],
  spoken: [
    (
      'Each fitting',
      r'h = C \frac{v^2}{2g}',
      'the fitting\'s own number, times the speed head',
    ),
    (
      'The total',
      r'h_{total} = h_f + \Sigma C \frac{v^2}{2g}',
      'the pipe friction, plus every fitting added up',
    ),
    (
      'One speed head',
      r'\text{serves them all}',
      'the same water speed runs through every fitting on the line',
    ),
  ],
  handbook: 'Handbook p. 182',
);

const deflectionBrief = BriefSection(
  title: 'A jet pushes by being turned, not by arriving',
  picture: deflectionPicture,
  steps: [
    (
      'Running through a sleeve pushes nothing',
      'The water goes in one way and leaves the same way at the same speed. '
          'Nothing about its motion changed, so it delivered no push, however '
          'fast or fat the jet was.',
    ),
    (
      'A flat plate takes all of it',
      'The plate stops the water going the way it was going. All of that '
          'motion has to be taken away, so the plate feels the full push.',
    ),
    (
      'A cup takes it TWICE',
      'The cup does not just stop the water, it sends it back the way it '
          'came. Stopping it is one lot; throwing it back is another. So a cup '
          'gets double what a plate gets.',
    ),
    (
      'Speed counts twice over',
      'Faster water means more kilograms arriving each second AND each one '
          'carrying more. So twice the speed is four times the push. Twice the '
          'bore is four times too, for the same reason on the area side.',
    ),
  ],
  spoken: [
    (
      'A jet turned through an angle',
      r'F = \rho Q v (1 - \cos\alpha)',
      'how much motion was taken away depends on how far the water was turned',
    ),
    ('Flat plate', r'F = \rho A v^2', 'turned ninety degrees: the full push'),
    (
      'Turned right back',
      r'F = 2\rho A v^2',
      'turned a hundred and eighty degrees: double the push',
    ),
  ],
  handbook: 'Handbook p. 186',
);

const thrustBrief = BriefSection(
  title: 'A main only needs holding where it changes',
  picture: thrustPicture,
  steps: [
    (
      'Pressure alone pushes a straight pipe nowhere',
      'It presses outward everywhere at once. Along a straight length those '
          'pushes face each other off, so a plain joint in a straight run needs '
          'nothing holding it at any pressure at all.',
    ),
    (
      'A force shows up where the water is made to change',
      'Turn a corner, change bore, or stop dead. In each of those the water '
          'has to be pushed into doing something different, and it pushes back on '
          'the pipe.',
    ),
    (
      'Those three places get held down',
      'A bend, a reducer, and a dead end or shut valve. They get a block of '
          'concrete behind them or joints that can pull, so the main stays where '
          'it was laid.',
    ),
    (
      'The pressure part is usually the bigger part',
      'There are two pieces: one from the pressure on the face, one from the '
          'moving water. On a water main the pressure piece is far larger, which '
          'is why forgetting it is such an expensive mistake.',
    ),
  ],
  spoken: [
    (
      'Each direction',
      r'F = PA + \rho Q v',
      'the pressure on the face, plus the motion of the water',
    ),
    (
      'A straight length',
      r'\text{the two ends cancel}',
      'equal and opposite, so nothing is left over',
    ),
    (
      'What leaves a force',
      r'\text{a turn, a change of bore, a stop}',
      'the three places a main gets shoved',
    ),
  ],
  handbook: 'Handbook p. 186',
);

const blockBrief = BriefSection(
  title: 'A bend is shoved to the outside of the turn',
  picture: blockPicture,
  steps: [
    (
      'Think about running round a corner',
      'You have to lean in, and you push the ground outward. Water in a bend '
          'does the same: it wants to keep going the way it came, so it shoves '
          'the pipe toward the OUTSIDE of the corner.',
    ),
    (
      'Both halves of the force agree',
      'The water arriving still wants to carry on inward. The pressure on the '
          'inlet face pushes that way too. Neither of them points into the '
          'inside of the elbow.',
    ),
    (
      'So the block goes on the outside face',
      'It splits the angle the two legs make and heads away from the corner. '
          'Never along one leg, never into the inside of the bend.',
    ),
    (
      'On a square bend, do not just double it',
      'The two parts are equal but at right angles, so they combine like the '
          'sides of a square: the total is one of them times about 1.41, not '
          'twice one of them.',
    ),
  ],
  spoken: [
    (
      'Which way',
      r'F \propto \hat{u}_{in} - \hat{u}_{out}',
      'the way in minus the way out, which always lands on the outside of the turn',
    ),
    (
      'A square bend',
      r'F_x = F_y = PA + \rho Q v',
      'the two parts are equal on a ninety degree bend',
    ),
    (
      'Put together',
      r'F_R = F_x\sqrt{2}',
      'one part times the square root of two, about 1.41',
    ),
  ],
  handbook: 'Handbook p. 186',
);

const meteringBrief = BriefSection(
  title: 'A meter measures on its small opening',
  picture: meteringPicture,
  steps: [
    (
      'Squeeze the pipe and read the pressure drop',
      'That is all a venturi or an orifice plate is. The squeeze speeds the '
          'water up, the pressure falls, and how far it falls tells you how much '
          'water is going past.',
    ),
    (
      'Every area in the formula is the SMALL one',
      'The throat, or the hole in the plate. The big upstream pipe appears '
          'once, inside a correction underneath, and never on its own.',
    ),
    (
      'Metering on the pipe is the big mistake',
      'On a meter that halves the bore, using the pipe instead of the throat '
          'makes your answer four times too large.',
    ),
    (
      'Find it by the pressure taps, not by eye',
      'The two taps say what is being measured. A valve or a reducer '
          'somewhere else may be narrower and is measuring nothing, because '
          'nobody is reading a difference across it.',
    ),
  ],
  spoken: [
    (
      'Venturi',
      r'Q = C_v A_2 \sqrt{\frac{2gh}{1 - (A_2/A_1)^2}}',
      'the throat area, times the square root of the head, with a correction for the pipe',
    ),
    (
      'Orifice',
      r'Q = C A_0 \sqrt{\frac{2gh}{1 - (A_0/A_1)^2}}',
      'the same shape, with the hole area and its own coefficient',
    ),
    (
      'The head',
      r'h = \frac{P_1 - P_2}{\gamma} + z_1 - z_2',
      'the pressure difference written as meters, plus any height difference',
    ),
  ],
  handbook: 'Handbook p. 195',
);

const coefficientBrief = BriefSection(
  title: 'Know which way each slip moves the answer',
  picture: coefficientPicture,
  steps: [
    (
      'You never get to check a meter against the truth',
      'So the defense is knowing which direction each mistake pushes the '
          'number. Then a wrong answer looks wrong.',
    ),
    (
      'Every coefficient is less than one',
      'It is there to bring the perfect formula down to what a real meter '
          'actually passes. Leave it out, or use one too big, and the flow you '
          'report goes UP.',
    ),
    (
      'Shrinking the bit underneath also sends it up',
      'It sits under the line, so making it smaller makes the whole thing '
          'bigger.',
    ),
    (
      'The two that send it down',
      'Losing the 2 in front of gravity costs about three tenths, softened '
          'because it is under a square root. Leaving pressure in kilopascals '
          'costs about thirty times, which is far enough to spot.',
    ),
  ],
  spoken: [
    (
      'Every coefficient',
      r'C < 1',
      'always under one, because a real meter passes less than the ideal',
    ),
    (
      'Under the line',
      r'\text{smaller} \Rightarrow \text{bigger } Q',
      'shrink the bottom of a fraction and the answer grows',
    ),
    (
      'A level meter',
      r'z_1 - z_2 = 0',
      'with no height change the elevation terms drop out entirely',
    ),
  ],
  handbook: 'Handbook p. 194',
);

const similitudeBrief = BriefSection(
  title: 'Look for a water surface',
  picture: similitudePicture,
  steps: [
    (
      'A model only works if it behaves like the real thing',
      'You cannot just build it smaller and hope. One particular number has '
          'to come out the same on the model as on the real thing, and you have '
          'to pick which number.',
    ),
    (
      'A free water surface means gravity is in charge',
      'Water running over a spillway, down a river, past a hull. Gravity is '
          'shaping it, so match the FROUDE number, which compares speed against '
          'gravity.',
    ),
    (
      'No surface means gravity has nothing to pull against',
      'A pipe running full, a valve, a submerged pipeline, a wind tunnel. '
          'What is left is stickiness against motion, so match the REYNOLDS '
          'number.',
    ),
    (
      'You cannot usually have both',
      'At the same scale in the same fluid the two ask for different speeds. '
          'A river model is run on Froude and the Reynolds mismatch is simply '
          'accepted, with the model built big enough to stay turbulent.',
    ),
  ],
  spoken: [
    (
      'Gravity is shaping it',
      r'Fr = \frac{v}{\sqrt{gl}}',
      'Froude: speed against gravity and size',
    ),
    (
      'Stickiness is shaping it',
      r'Re = \frac{\rho v l}{\mu}',
      'Reynolds: motion against how sticky the fluid is',
    ),
    (
      'How many groups to match',
      r'k = n - r',
      'the count of variables less the count of basic dimensions',
    ),
  ],
  handbook: 'Handbook p. 196',
);

const scalingBrief = BriefSection(
  title: 'The law you picked decides the model speed',
  picture: scalingPicture,
  steps: [
    (
      'Once you choose the law, the speed is fixed',
      'You do not get to pick how fast to run the model. Matching the number '
          'decides it for you, and the two laws pull in opposite directions.',
    ),
    (
      'Froude: a smaller model runs SLOWER',
      'The speed sits over the square root of the size, so speed follows size '
          'by its square root. A model a twenty fifth the size runs at a fifth of '
          'the speed.',
    ),
    (
      'Reynolds: a smaller model runs FASTER',
      'Here speed multiplies size, so to keep the product the same the speed '
          'has to go the other way by the whole ratio. A model a tenth the size '
          'must run ten times as fast.',
    ),
    (
      'Which is often the end of the plan',
      'Ten times the speed through a small tank may simply be impossible. '
          'That is why Reynolds models get built oversized instead of shrunk.',
    ),
  ],
  spoken: [
    (
      'Froude',
      r'\frac{v_m}{v_p} = \sqrt{\frac{l_m}{l_p}}',
      'the speed ratio is the square root of the size ratio',
    ),
    (
      'Reynolds, same fluid',
      r'\frac{v_m}{v_p} = \frac{l_p}{l_m}',
      'the speed ratio is the size ratio turned upside down',
    ),
    (
      'At full size',
      r'l_m = l_p \Rightarrow v_m = v_p',
      'with no shrinking, both laws ask for the same speed',
    ),
  ],
  handbook: 'Handbook p. 196',
);

const bearingBrief = BriefSection(
  title: 'A bearing is an instruction, not just a number',
  picture: bearingPicture,
  steps: [
    (
      'Face, then turn',
      'N 52 E means stand facing north and swing 52 degrees toward the east. '
          'The first letter says which way to face, the number says how far to '
          'turn, the last letter says which way to turn.',
    ),
    (
      'Never more than a quarter turn',
      'The angle is always measured from the nearer end of the north and '
          'south line, so it never passes 90. That is why the same 52 degrees '
          'turns up in all four corners of the drawing.',
    ),
    (
      'So the number alone tells you nothing',
      'Read both letters before you do anything with the angle. A bearing '
          'near 90 runs almost due east or west. A bearing near zero runs almost '
          'along the north and south line.',
    ),
    (
      'Turning round',
      'Walk the line the other way and the angle is the same. Both letters '
          'flip: N 52 E backwards is S 52 W.',
    ),
  ],
  spoken: [
    (
      'A bearing',
      r'\text{N or S}, \text{ angle} \le 90^\circ, \text{ E or W}',
      'a letter, an angle no bigger than a quarter turn, then a letter',
    ),
    (
      'The meridian',
      r'\text{north is up the sheet}',
      'north points up the page, the way every plan is drawn',
    ),
    (
      'Back bearing',
      r'\text{same angle, both letters flipped}',
      'the same angle, with each letter swapped for its opposite',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const azimuthBrief = BriefSection(
  title: 'Bearing to azimuth, by the clock',
  picture: azimuthPicture,
  steps: [
    (
      'One number instead of two letters',
      'An azimuth is the whole turn clockwise from north, from 0 all the way '
          'to 360. Think of a clock face with north at twelve. No letters, just '
          'how far round you have gone.',
    ),
    (
      'North and east comes first',
      'A line into the north-east corner is reached before a quarter turn, '
          'so its azimuth IS the bearing angle. Nothing to do.',
    ),
    (
      'Past south, keep adding',
      'South-east stops short of due south, so it is 180 minus the angle. '
          'South-west has gone past due south, so it is 180 plus. Taking it off '
          '360 instead throws the line to the opposite corner.',
    ),
    (
      'North-west is nearly all the way round',
      'It is 360 minus the angle. Picture the clock and you never have to '
          'memorize the list.',
    ),
  ],
  spoken: [
    (
      'North and east',
      r'Az = \text{angle}',
      'the azimuth is the bearing angle itself',
    ),
    (
      'South-east and south-west',
      r'Az = 180^\circ \mp \text{angle}',
      '180 minus the angle going east, 180 plus it going west',
    ),
    (
      'North-west',
      r'Az = 360^\circ - \text{angle}',
      'a full turn minus the angle',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const shotBrief = BriefSection(
  title: 'Three lengths come out of one shot',
  picture: shotPicture,
  steps: [
    (
      'Sighting up a hill makes a triangle',
      'The instrument looks up the slope at a target. The line of sight, the '
          'flat ground under it, and the height between the two ends make a right '
          'triangle. Three sides, three different answers.',
    ),
    (
      'What the instrument measures',
      'It measures along its own line of sight, and so does a tape dragged '
          'over the ground. That is the slope distance, the sloping side, and it '
          'is the longest of the three every time.',
    ),
    (
      'What the plan wants',
      'A plan is drawn looking straight down, so it wants the flat distance '
          'underneath. Cosine gives it, and it is always shorter than the slope '
          'distance. Sine gives the height instead.',
    ),
    (
      'The check that catches it',
      'If your flat distance comes out LONGER than the slope distance, the '
          'cosine went in the wrong place. The flat one can never win.',
    ),
  ],
  spoken: [
    (
      'Flat, for the plan',
      r'HD = SD\cos\alpha',
      'the slope distance times the cosine of the slope angle',
    ),
    (
      'Upright, the elevation',
      r'VD = SD\sin\alpha',
      'the slope distance times the sine of the slope angle',
    ),
    (
      'Always',
      r'HD \le SD',
      'the flat distance is never longer than the sloping one',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const sightBrief = BriefSection(
  title: 'One level plane hangs over the whole setup',
  picture: sightPicture,
  steps: [
    (
      'The line of sight is dead flat',
      'A level looks out perfectly horizontally. Over one setup that line of '
          'sight is a single flat plane hanging above the ground, like a sheet of '
          'glass.',
    ),
    (
      'A rod reading is a drop',
      'Stand a rod on a point and read where the flat line crosses it. That '
          'reading is nothing more than how far the ground there sits BELOW the '
          'plane.',
    ),
    (
      'So the bigger reading is the lower point',
      'Further below the plane means a bigger number. This catches most sign '
          'errors before they happen, and two equal readings mean two points at '
          'the same height, with no arithmetic at all.',
    ),
    (
      'The height of instrument is just that plane',
      'Add the reading on a point you know to its elevation and you have the '
          'height of the plane. Take the next reading off it to get the point you '
          'want.',
    ),
  ],
  spoken: [
    (
      'Up to the plane',
      r'HI = \text{Elev} + BS',
      'the known elevation plus the reading on it',
    ),
    (
      'Back down from it',
      r'\text{Elev} = HI - FS',
      'the plane, minus the reading on the new point',
    ),
    (
      'The check',
      r'\text{bigger reading} \Rightarrow \text{lower ground}',
      'a bigger rod reading always means lower ground',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const runBrief = BriefSection(
  title: 'Three kinds of point in a level run',
  picture: runPicture,
  steps: [
    (
      'Count the setups that can see the rod',
      'The level cannot see round a hill, so it gets moved. Which kind of '
          'point you are looking at is decided by how many setups read it: one, '
          'one, or two.',
    ),
    (
      'The start and the end',
      'The first point is read from one setup only, and it is the one '
          'elevation you already know: that reading gets ADDED. The last point is '
          'read from one setup only too, and it is the one you want: that reading '
          'gets TAKEN OFF.',
    ),
    (
      'The point in the middle',
      'Where the level moves, one point is read twice: forward from the old '
          'setup to fix its elevation, then back from the new setup to fix the '
          'new plane. That is a turning point.',
    ),
    (
      'The reading people drop',
      'Forgetting the second reading means carrying the OLD plane forward '
          'into the new setup, and every elevation after it is wrong.',
    ),
  ],
  spoken: [
    (
      'Start',
      r'BS \text{ on a known point, added}',
      'a backsight on the point you already know, added on',
    ),
    (
      'End',
      r'FS \text{ on the wanted point, subtracted}',
      'a foresight on the point you want, taken off',
    ),
    (
      'Between',
      r'\text{turning point: FS then BS}',
      'a turning point, read forward from one setup and back from the next',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const closureBrief = BriefSection(
  title: 'What a loop is allowed to be out by',
  picture: closurePicture,
  steps: [
    (
      'Walk a loop and you miss',
      'Level all the way round and back to the mark you started from. The '
          'elevation you work out will not be the one you started with. The gap '
          'is the misclosure.',
    ),
    (
      'How much is allowed depends on two things',
      'The class of work sets a constant, and the length of the run goes '
          'under a SQUARE ROOT. Careful work gets a small constant, rough work a '
          'bigger one.',
    ),
    (
      'The square root is the point',
      'Four times the distance is only TWICE the allowance. Over a long run '
          'errors cancel as often as they pile up, so the slack grows slower than '
          'the distance does.',
    ),
    (
      'So work out both sides',
      'A tight constant on a long run can allow less than a loose one on a '
          'short run. If the gap is bigger than the allowance, the run is done '
          'again.',
    ),
  ],
  spoken: [
    (
      'The gap',
      r'\text{misclosure} = \text{computed} - \text{known}',
      'what you worked out, minus what you started with',
    ),
    (
      'What is allowed',
      r'C\sqrt{M}',
      'a constant for the class of work, times the square root of the miles',
    ),
    (
      'So',
      r'4M \Rightarrow 2\times \text{ the allowance}',
      'four times the distance buys only twice the slack',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const latDepBrief = BriefSection(
  title: 'How far north, how far east',
  picture: latDepPicture,
  steps: [
    (
      'Every leg becomes two numbers',
      'Walk 100 meters in some direction and you have gone a certain way '
          'north and a certain way east. Those two are the latitude and the '
          'departure. They are the sides of the right triangle the leg makes.',
    ),
    (
      'Which one takes the cosine',
      'The azimuth is measured from north, so the north side is the one '
          'beside the angle: cosine. The east side is the one opposite it: sine. '
          'Get them the wrong way round and the leg points somewhere else '
          'entirely.',
    ),
    (
      'The signs are where the damage is',
      'Going south makes the latitude negative. Going west makes the '
          'departure negative. A sign error still gives two believable numbers, '
          'and puts the next station in the wrong part of the county.',
    ),
    (
      'A closed loop must add to nothing',
      'Come back where you started and every step north is canceled by a '
          'step south. So a real traverse has to run through more than one corner '
          'of the compass.',
    ),
  ],
  spoken: [
    (
      'North and south',
      r'\text{Lat} = L\cos\theta',
      'the length times the cosine of the azimuth',
    ),
    (
      'East and west',
      r'\text{Dep} = L\sin\theta',
      'the length times the sine of the azimuth',
    ),
    (
      'Closed',
      r'\Sigma \text{Lat} = 0, \; \Sigma \text{Dep} = 0',
      'round a loop, both columns add up to nothing',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const compassBrief = BriefSection(
  title: 'Spread the miss along the legs, by length',
  picture: compassPicture,
  steps: [
    (
      'A loop never closes exactly',
      'Measure your way round a field and back to the start and you land a '
          'little off the corner you began at. Every traverse does this. The '
          'compass rule is the ordinary way of tidying it up.',
    ),
    (
      'Assume the error crept in evenly',
      'If small mistakes built up steadily as you walked, then the longest '
          'leg collected the most of them. So the longest leg gets the biggest '
          'share of the correction.',
    ),
    (
      'Share it by length, nothing else',
      'Not by how much north a leg covered. Not an equal share each. And '
          'never the whole miss dumped on the one leg that felt wrong in the '
          'field: if you know which leg is bad, measure it again.',
    ),
    (
      'The fix points the other way',
      'A traverse that drifted north gets pushed south. The correction always '
          'carries the opposite sign to the error.',
    ),
  ],
  spoken: [
    (
      'Each leg',
      r'\text{Corr}_i = -E \times \frac{L_i}{\Sigma L}',
      'the whole error, times this leg out of the total length, with the sign flipped',
    ),
    (
      'Longest leg',
      r'\text{biggest share}',
      'the longest leg takes the most correction',
    ),
    (
      'Sign',
      r'\text{opposite to the drift}',
      'the fix pushes back against the way the loop drifted',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const precisionBrief = BriefSection(
  title: 'Precision is a ratio, not a gap',
  picture: precisionPicture,
  steps: [
    (
      'First measure the miss',
      'You are some way off north and some way off east. Put the two together '
          'the way any two square-on lengths go together, under a square root, '
          'and that is the closing gap.',
    ),
    (
      'The gap alone says nothing',
      'A centimeter out round a small garden is worse work than thirty '
          'centimeters out round three kilometers. How far you walked has to come '
          'into it.',
    ),
    (
      'So divide by the distance walked',
      'Write the answer as one over something. Double the gap AND double the '
          'distance and the ratio has not moved, which is why a specification can '
          'ask for 1 in 10,000 and mean the same thing on every job.',
    ),
    (
      'Bigger bottom number is better',
      '1 in 10,000 beats 1 in 3,000. The shape of the figure never comes into '
          'it at all.',
    ),
  ],
  spoken: [
    (
      'The gap',
      r'E = \sqrt{E_L^2 + E_D^2}',
      'the north miss and the east miss, combined like the sides of a triangle',
    ),
    (
      'The ratio',
      r'\frac{E}{\Sigma L} = \frac{1}{N}',
      'the gap divided by the whole distance walked',
    ),
    (
      'Bigger N',
      r'\text{better work}',
      'a bigger bottom number means a tighter survey',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const methodBrief = BriefSection(
  title: 'The ground decides which method',
  picture: methodPicture,
  steps: [
    (
      'Straight sides and known corners',
      'A parcel with monuments at the corners and straight lines between them '
          'is worked from the coordinates. That answer is EXACT, however odd the '
          'shape and however many sides.',
    ),
    (
      'A boundary that wanders',
      'A creek or a wetland edge has no corners. Run a straight baseline '
          'beside it and measure across to the boundary at even spacings. Those '
          'measurements are the offsets.',
    ),
    (
      'Then count the offsets',
      'Simpson fits a curve across every PAIR of gaps, so it needs an even '
          'number of gaps, which is an ODD number of offsets. Odd count: use '
          'Simpson and get a better answer on a curved edge.',
    ),
    (
      'Even count, Simpson is out',
      'With an even number of offsets Simpson does not apply at all, and the '
          'trapezoidal rule is what is left.',
    ),
  ],
  spoken: [
    (
      'Corners',
      r'A = \tfrac{1}{2}\left|\sum (x_i y_{i+1} - x_{i+1} y_i)\right|',
      'round the corners, cross-multiplying each pair, halved',
    ),
    (
      'Odd offsets',
      r'\text{Simpson: } \tfrac{w}{3}(1,4,2,\dots,1)',
      'Simpson, with the spacing over three',
    ),
    (
      'Even offsets',
      r'\text{trapezoidal}',
      'the trapezoidal rule is the only one that fits',
    ),
  ],
  handbook: 'Handbook p. 310',
);

const weightsBrief = BriefSection(
  title: 'The weights are the whole of the rule',
  picture: weightsPicture,
  steps: [
    (
      'Both rules have the same shape',
      'Multiply every offset by something, add the results up, multiply by '
          'the spacing. The only difference between the two rules is the list of '
          'somethings.',
    ),
    (
      'Why the ends are special',
      'An offset in the middle is shared by the strip on each side of it. An '
          'offset at the end belongs to only one strip. So the trapezoidal rule '
          'halves the two ends and takes everything between them whole.',
    ),
    (
      'Simpson alternates four and two',
      'One, four, two, four, two, four, one. The middle of each little curve '
          'carries it, so it gets four. The offsets where one curve hands over to '
          'the next are counted for both, so they get two.',
    ),
    (
      'The pattern checks itself',
      'Simpson must start and end on a one, with a four next to each. If it '
          'does not, something has been miscounted.',
    ),
  ],
  spoken: [
    (
      'Trapezoidal',
      r'\tfrac{1}{2}, 1, 1, \dots, \tfrac{1}{2}',
      'half, then ones all the way, then half',
    ),
    (
      'Simpson',
      r'1, 4, 2, 4, \dots, 1',
      'one, then four and two alternating, ending on one',
    ),
    (
      'Then',
      r'\times w, \text{ and } \div 3 \text{ for Simpson}',
      'multiply by the spacing, and divide by three for Simpson',
    ),
  ],
  handbook: 'Handbook p. 310',
);

const shoelaceBrief = BriefSection(
  title: 'The formula does not check your listing',
  picture: shoelacePicture,
  steps: [
    (
      'Exact, and that is the danger',
      'Area from coordinates is exact for the shape you hand it. But it '
          'returns a tidy number for ANY list of corners, including lists that '
          'are not your parcel.',
    ),
    (
      'Corners out of order draw a bowtie',
      'Swap two corners in the list and the boundary crosses itself. The '
          'answer that comes back is the difference between two loops, not the '
          'area of anything.',
    ),
    (
      'A missing corner just shrinks it',
      'Leave one corner out and you get a smaller shape that closes perfectly '
          'well. The area is simply too small, and nothing in the arithmetic '
          'complains.',
    ),
    (
      'Going backwards is fine',
      'Walk the boundary the other way and the sum turns negative. The '
          'absolute value is there for exactly that. Plot the listing before you '
          'trust it.',
    ),
  ],
  spoken: [
    (
      'Round the boundary',
      r'A = \tfrac{1}{2}\left|\sum (x_i y_{i+1} - x_{i+1} y_i)\right|',
      'cross-multiply each corner with the next, add, halve, ignore the sign',
    ),
    (
      'Close it',
      r'\text{last corner pairs back to the first}',
      'the last corner pairs with the first to shut the loop',
    ),
    (
      'Either direction',
      r'\text{the absolute value covers it}',
      'clockwise or not, the size of the answer is the same',
    ),
  ],
  handbook: 'Handbook p. 310',
);

const endAreaBrief = BriefSection(
  title: 'What happens between two sections',
  picture: endAreaPicture,
  steps: [
    (
      'Dirt is measured by slicing',
      'Cut a road job across at intervals and measure the area of each cut. '
          'The volume between two slices is the areas and the distance between '
          'them, but the two formulas disagree about what happens in the gap.',
    ),
    (
      'End areas draws a straight line',
      'It assumes the section grows evenly from one slice to the next, which '
          'is the same as saying the middle is the average of the two ends.',
    ),
    (
      'The prismoidal formula asks',
      'It measures the middle section instead of assuming it, and gives it '
          'four times the weight. So compare the real middle against the average '
          'of the ends and you know which answer is bigger.',
    ),
    (
      'A fill closing to a point sags',
      'Its middle is well below the average of its ends, so end areas '
          'overestimates: the famous overpayment. A constant section or an even '
          'taper sits right on the line and the two agree exactly.',
    ),
  ],
  spoken: [
    (
      'End areas',
      r'V = \frac{L}{2}(A_1 + A_2)',
      'the two end areas averaged, times the length',
    ),
    (
      'Prismoidal',
      r'V = \frac{L}{6}(A_1 + 4A_m + A_2)',
      'the ends plus four times the middle, over six, times the length',
    ),
    (
      'They agree when',
      r'A_m = \frac{A_1 + A_2}{2}',
      'the middle section is exactly the average of the two ends',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const stationBrief = BriefSection(
  title: 'Work every pair of stations, then add',
  picture: stationsPicture,
  steps: [
    (
      'The formula only sees two slices',
      'Hand it two sections and a distance and it answers. Nothing in it '
          'objects if those two are a thousand feet apart with a whole hill in '
          'between.',
    ),
    (
      'So skipping loses the middle',
      'A hump between two slices goes unbooked. A dip gets paid for twice. '
          'And a run that starts at nothing and ends at nothing comes out as no '
          'dirt at all, however much is really there.',
    ),
    (
      'Work each pair, then add the pieces',
      'Take every pair of neighboring stations on its own and add the '
          'volumes up. The only safe skip is a section that climbs evenly the '
          'whole way, because then the ends really do carry the story.',
    ),
    (
      'A station is a hundred feet',
      '1+00 means 100 feet along, 2+00 means 200. The plus sign separates '
          'the hundreds from the rest.',
    ),
  ],
  spoken: [
    (
      'Each segment',
      r'V_i = \frac{L_i}{2}(A_i + A_{i+1})',
      'for each pair of slices, the two areas averaged times their spacing',
    ),
    ('Then', r'V = \Sigma V_i', 'add all the segments together'),
    (
      'A station',
      r'1{+}00 = 100 \text{ ft}',
      'station one plus zero zero is a hundred feet along',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const solidBrief = BriefSection(
  title: 'All of it, half of it, a third of it',
  picture: solidPicture,
  steps: [
    (
      'Start with the box',
      'Take the section at one end and carry it the whole length. That makes '
          'a box around the solid. Now ask what the far end actually does.',
    ),
    (
      'Nothing changes: the whole box',
      'A section that stays the same all the way IS the box. Area times '
          'length, and there is no approximating involved.',
    ),
    (
      'Closing to an edge: half',
      'The section shrinks evenly to a line, so on average it is half of what '
          'it started as. That is a wedge, and it is what the end area formula '
          'gives with one section set to zero.',
    ),
    (
      'Closing to a point: a third',
      'Now it is shrinking in two directions at once, so it falls away as a '
          'square and only a third of the box is left. That is the pyramid rule, '
          'and it holds whether the base is round or square.',
    ),
  ],
  spoken: [
    ('Constant', r'V = A L', 'the area times the length: the whole box'),
    ('To an edge', r'V = \tfrac{1}{2} A L', 'half the box'),
    (
      'To a point',
      r'V = \tfrac{1}{3} A h',
      'a third of the box: base times height over three',
    ),
  ],
  handbook: 'Handbook p. 309',
);

const cogoBrief = BriefSection(
  title: 'Forward one way, inverse the other',
  picture: cogoPicture,
  steps: [
    (
      'Count what you already hold',
      'Coordinate work runs in two directions on the same triangle. Which '
          'direction you are going is decided by how many points already have '
          'coordinates.',
    ),
    (
      'Forward: one point and a measured line',
      'You stand on a known point and measure a length and a direction to '
          'something new. Break that line into its east part and its north part, '
          'add both to where you started, and the new point has coordinates.',
    ),
    (
      'Inverse: two points, find the line',
      'You hold both ends and want the line between them. Subtract to get how '
          'far east and how far north, then the distance is the long side of that '
          'triangle and the direction is its arctangent.',
    ),
    (
      'Most real work is one of each',
      'Inverse first, to find out which way a line points. Then forward, to '
          'set something new along it.',
    ),
  ],
  spoken: [
    (
      'Forward',
      r'E_2 = E_1 + L\sin Az, \; N_2 = N_1 + L\cos Az',
      'add the east part and the north part to the point you held',
    ),
    (
      'Inverse',
      r'L = \sqrt{\Delta E^2 + \Delta N^2}',
      'the distance is the long side of the triangle the two gaps make',
    ),
    (
      'And',
      r'Az = \tan^{-1}(\Delta E / \Delta N)',
      'the direction is the arctangent of east over north',
    ),
  ],
  handbook: 'Handbook p. 310',
);

const pairBrief = BriefSection(
  title: 'Easting first, northing second',
  picture: pairPicture,
  steps: [
    (
      'Two numbers and an agreement',
      'A coordinate pair says how far across and how far up. Surveying writes '
          'the easting first and the northing second: across, then up, the same '
          'order as x then y.',
    ),
    (
      'Plenty of records do it backwards',
      'Field books, deeds and older files often write northing first. Nothing '
          'about the two numbers tells you which convention you are looking at.',
    ),
    (
      'A swapped pair still behaves',
      'Read backwards, the point lands on the far side of the diagonal and '
          'then works perfectly: every distance and direction computed from it is '
          'a believable number for the wrong place.',
    ),
    (
      'So label and plot',
      'When the two numbers are far apart the mistake is obvious. When they '
          'are close it survives a glance and puts a wall on the wrong side of a '
          'boundary. Write E and N over the columns and plot the point.',
    ),
  ],
  spoken: [
    ('The pair', r'(E, N)', 'easting first, northing second'),
    (
      'Easting',
      r'\text{across, the x of the grid}',
      'how far across, which is the x',
    ),
    ('Northing', r'\text{up, the y of the grid}', 'how far up, which is the y'),
  ],
  handbook: 'Handbook p. 310',
);

const arctanBrief = BriefSection(
  title: 'The calculator only knows half the compass',
  picture: arctanPicture,
  steps: [
    (
      'Arctangent answers within a half turn',
      'Feed it one number and it hands back something between minus 90 and '
          'plus 90 degrees. That covers half the compass. An azimuth needs all '
          'of it.',
    ),
    (
      'The missing half is in the signs',
      'Only the two differences, how far east and how far north, know which '
          'quarter the line really runs into. The division throws that away.',
    ),
    (
      'So put it back',
      'Northing difference negative means the line runs south, and every '
          'southbound line is between 90 and 270: add 180. North and west: add '
          '360. North and east is the one quarter the calculator gets right by '
          'itself.',
    ),
    (
      'Why south-west is the trap',
      'Both differences are negative, so the two minus signs cancel inside '
          'the division. The calculator hands back a small positive number that '
          'looks fine and is 180 degrees wrong.',
    ),
  ],
  spoken: [
    (
      'North and east',
      r'Az = \tan^{-1}(\Delta E/\Delta N)',
      'take the arctangent and stop',
    ),
    (
      'Anything running south',
      r'Az = 180^\circ + \tan^{-1}(\Delta E/\Delta N)',
      'add 180 whenever the northing difference is negative',
    ),
    (
      'North and west',
      r'Az = 360^\circ + \tan^{-1}(\Delta E/\Delta N)',
      'add 360 to the negative answer',
    ),
  ],
  handbook: 'Handbook p. 310',
);

const roadCurveBrief = BriefSection(
  title: 'Six lengths live on one curve',
  picture: roadCurvePicture,
  steps: [
    (
      'Two straight roads and a corner',
      'Where two straights meet, a circle is fitted into the corner so cars '
          'can get round. The whole curve is fixed by two things: the radius of '
          'that circle, and how far the road turns.',
    ),
    (
      'The tangent runs out to the corner',
      'From where the curve starts, out along the old straight to the point '
          'the two straights would have met. The other side is the same length.',
    ),
    (
      'The curve length is the road',
      'It is the arc itself, the way the car actually drives, and it is what '
          'the stationing runs along. Never out through the corner. Mistaking the '
          'arc for the tangent is the error this lesson names twice.',
    ),
    (
      'The three that measure the bulge',
      'The long chord cuts straight across from start to finish. The external '
          'is how far the road misses the corner by. The middle ordinate is from '
          'the middle of the chord out to the road.',
    ),
  ],
  spoken: [
    (
      'Out to the corner',
      r'T = R\tan\frac{I}{2}',
      'the radius times the tangent of half the turn',
    ),
    (
      'Round the arc',
      r'L = \frac{\pi R I}{180}',
      'the share of a whole circle that the turn takes up',
    ),
    (
      'Across, and the two bulges',
      r'LC = 2R\sin\frac{I}{2}, \; E, \; M',
      'the straight chord, plus how far the road misses the corner and the chord',
    ),
  ],
  handbook: 'Handbook p. 302',
);

const degreeBrief = BriefSection(
  title: 'Radius one way, degree the other',
  picture: degreePicture,
  steps: [
    (
      'Two ways to quote the same curve',
      'One is a length: the radius. The other is an angle: the degree of '
          'curve, which is how much the road turns in a hundred feet of driving.',
    ),
    (
      'They run in opposite directions',
      'A BIG radius is a gentle curve, because the circle is huge. A BIG '
          'degree is a SHARP curve, because you turned a lot in a short distance.',
    ),
    (
      'One number always joins them',
      'Multiply them together and you always get about 5,730. That is simply '
          'the radius whose hundred feet of arc turns through exactly one degree.',
    ),
    (
      'So comparing is one division',
      'Degree of curve suits laying a curve out in the field; the radius '
          'suits coordinate work. The same drawing often carries both.',
    ),
  ],
  spoken: [
    (
      'Either way',
      r'D = \frac{5{,}729.58}{R}',
      'the degree is 5,730 divided by the radius',
    ),
    (
      'So',
      r'D \times R \approx 5{,}730',
      'the two multiplied together are always about 5,730',
    ),
    (
      'Sharper means',
      r'\text{small } R, \text{ large } D',
      'a small radius and a large degree are the same sharp curve',
    ),
  ],
  handbook: 'Handbook p. 302',
);

const tangentOffsetBrief = BriefSection(
  title: 'Two elevations at the same station',
  picture: tangentOffsetPicture,
  steps: [
    (
      'A hill is smoothed with a curve',
      'Where one grade meets another, the road does not kink. A gentle curve '
          'is laid between them, and it pulls away from the straight grade it '
          'arrived on.',
    ),
    (
      'So there are two heights at any station',
      'The straight grade line carried on from the start gives one. The road '
          'itself gives the other. The question decides which one it wants, and '
          'reading the wrong one is what this lesson is built around.',
    ),
    (
      'The gap grows as a square',
      'It is nothing where the curve begins, and it grows by the SQUARE of '
          'how far along you are, so it is biggest under the corner where the two '
          'straight grades would have met.',
    ),
    (
      'Which way it pulls',
      'Heading to a lower grade, the road runs below the line. Heading to a '
          'higher one, it runs above. That is decided by the change in grade, not '
          'by whether the road crests or sags.',
    ),
  ],
  spoken: [
    (
      'On the grade line',
      r'Y = Y_{PVC} + g_1 x',
      'the start elevation plus the incoming grade times the distance',
    ),
    (
      'On the road',
      r'Y = Y_{PVC} + g_1 x + \frac{g_2 - g_1}{2L}x^2',
      'the same, plus a term that grows as the distance squared',
    ),
    (
      'The gap under the corner',
      r'E = \frac{A L}{8}',
      'the grade change times the curve length, over eight',
    ),
  ],
  handbook: 'Handbook p. 301',
);

const highPointBrief = BriefSection(
  title: 'Where the road stops climbing',
  picture: highPointPicture,
  steps: [
    (
      'The climb runs out',
      'Come into a crest at plus 4 percent and leave at minus 2. Somewhere '
          'between, the road stops going up and starts coming down. That is the '
          'high point, and it is where water on the road parts.',
    ),
    (
      'It leans toward the gentler grade',
      'From plus 4 to minus 2 it sits two thirds of the way along, not in the '
          'middle. The steeper you came in, the further you carry on before the '
          'climb is used up.',
    ),
    (
      'The middle is a special case',
      'It only sits under the corner when the two grades are equal and '
          'opposite. That happens often enough to become a habit, and the habit '
          'is wrong the rest of the time.',
    ),
    (
      'An answer outside the curve means something',
      'If both grades run the same way the formula returns a distance past '
          'the ends. That is it telling you the road simply climbs, or falls, the '
          'whole way: there is no turning point on the curve at all.',
    ),
  ],
  spoken: [
    (
      'From the start of the curve',
      r'x_m = \frac{-g_1 L}{g_2 - g_1}',
      'the incoming grade and the length, over the change in grade',
    ),
    (
      'The grade change',
      r'A = |g_1 - g_2|',
      'how much the grade changes in total, ignoring the sign',
    ),
    (
      'The rate, not a distance',
      r'K = \frac{L}{A}',
      'feet of curve bought per percent of grade change: bigger K is gentler',
    ),
  ],
  handbook: 'Handbook p. 301',
);

const wettedBrief = BriefSection(
  title: 'What the water is rubbing against',
  picture: wettedPicture,
  steps: [
    (
      'Water is slowed by what it touches',
      'Run water down a ditch and the sides and bottom drag on it. The more '
          'boundary it has to rub along, the slower it goes. So before anything '
          'else you count the rubbing.',
    ),
    (
      'The air does not count',
      'The top of the water is open to the sky. Air does not hold water back, '
          'so the surface is never part of the rubbing. Neither is any wall built '
          'above the water line: if the water is not touching it, it does nothing.',
    ),
    (
      'Count the wet edges',
      'For a rectangle that is the bed plus one wall on each side, so the bed '
          'plus twice the depth. For a sloped side, measure ALONG the slope, which '
          'is longer than the depth. For a pipe running full there is no surface '
          'at all, so the whole circle counts.',
    ),
    (
      'Then share the water out over the rubbing',
      'The hydraulic radius is the area of water divided by that wetted '
          'length. It is not the radius of anything. More water per unit of '
          'rubbing means faster water.',
    ),
  ],
  spoken: [
    (
      'Water per unit of rubbing',
      r'R_H = \frac{A}{P}',
      'the flow area, divided by the wetted length',
    ),
    ('A rectangle', r'P = b + 2y', 'the bed plus twice the depth'),
    (
      'A sloped side',
      r'P = b + 2y\sqrt{1 + z^2}',
      'the bed plus both slopes, each longer than the depth',
    ),
    ('A pipe running full', r'R_H = \frac{D}{4}', 'a quarter of the diameter'),
  ],
  handbook: 'Handbook p. 297',
);

const manningBrief = BriefSection(
  title: 'What actually sets the speed',
  picture: manningPicture,
  steps: [
    (
      'Three things, pulling unequally',
      'A channel can differ in how rough it is, how steeply it falls, and what '
          'shape the water sits in. All three change the speed, but not by the '
          'same amount.',
    ),
    (
      'Roughness counts in full',
      'It sits underneath, so it acts at full strength. Smooth concrete '
          'against bare earth is nearly twice the speed. The ratio of speeds is '
          'the roughnesses the other way up.',
    ),
    (
      'Slope counts half',
      'Slope is under a square root. Four times the grade buys only twice the '
          'speed, which is why steepening a sewer is an expensive way to buy '
          'capacity.',
    ),
    (
      'Shape rewards deep and narrow',
      'The hydraulic radius is raised to the two thirds. A deep narrow cut '
          'holds the same water against far less rubbing than a wide shallow one, '
          'so it runs faster. A pipe half full has the same hydraulic radius as '
          'the same pipe full, so it runs at the same speed carrying half as much.',
    ),
  ],
  spoken: [
    (
      'The speed',
      r'v = \frac{K}{n} R_H^{2/3} S^{1/2}',
      'the constant over the roughness, times the radius to the two thirds, times the square root of the slope',
    ),
    (
      'Roughness, in full',
      r'\frac{v_1}{v_2} = \frac{n_2}{n_1}',
      'the speeds go as the roughnesses upside down',
    ),
    (
      'Slope, under a root',
      r'4S \Rightarrow 2v',
      'four times the slope gives twice the speed',
    ),
    (
      'Full or half full',
      r'R_H = \frac{D}{4}',
      'a quarter of the diameter, either way',
    ),
  ],
  handbook: 'Handbook p. 297',
);

const unitFactorBrief = BriefSection(
  title: 'The only place the units show up',
  picture: kfactorPicture,
  steps: [
    (
      'One channel, two rulers',
      'Measure the same channel in feet and in meters and you write down two '
          'different numbers for the same thing. Manning\'s equation carries a '
          'constant in front that patches over exactly that.',
    ),
    (
      'Which number to use',
      'Measuring in meters, the constant is 1.0, which is to say there is '
          'nothing to fix. Measuring in feet it is 1.486. Leave it out and every '
          'answer comes out about a third too small.',
    ),
    (
      'Only the lengths decide it',
      'The roughness has no units and is the same number in both systems. The '
          'slope is a drop over a run, so it has none either. What units somebody '
          'wants the answer in does not matter while you are working.',
    ),
    (
      'Fix odd units before you start',
      'Inches and millimeters are not units this equation takes. Convert them '
          'first. A pipe diameter left in inches is the usual way this goes wrong.',
    ),
  ],
  spoken: [
    (
      'Measuring in feet',
      r'K = 1.486',
      'the constant is one point four eight six',
    ),
    (
      'Measuring in meters',
      r'K = 1.0',
      'the constant is one, so nothing changes',
    ),
    (
      'No units either way',
      r'n, \; S',
      'the roughness and the slope are the same numbers in both systems',
    ),
  ],
  handbook: 'Handbook p. 297',
);

const froudeBrief = BriefSection(
  title: 'Two speeds, and which one wins',
  picture: froudePicture,
  steps: [
    (
      'Drop a stone in a stream',
      'The splash makes a ring that spreads out. Meanwhile the stream is '
          'carrying that ring downstream. Whether any of it gets back upstream is '
          'a race between two speeds.',
    ),
    (
      'The two racers',
      'One is how fast the water is moving. The other is how fast a ripple '
          'travels over still water that deep, and depth is the only thing that '
          'sets it: deeper water carries ripples faster.',
    ),
    (
      'Ripple wins: news travels up',
      'Deep slow water lets the ring work its way upstream. That is '
          'subcritical, tranquil flow, and a gate far downstream is felt above it.',
    ),
    (
      'Water wins: nothing gets back',
      'Shallow fast water sweeps every ripple away. That is supercritical '
          'flow, what a spillway or a steep chute makes. When the two tie, the '
          'upstream edge of the ring stands still and the depth is the critical '
          'depth.',
    ),
  ],
  spoken: [
    (
      'The race',
      r'Fr = \frac{v}{\sqrt{g y}}',
      'the water speed divided by the ripple speed',
    ),
    ('News gets upstream', r'Fr < 1', 'under one: deep, slow, tranquil'),
    ('Nothing gets upstream', r'Fr > 1', 'over one: shallow, fast, rapid'),
  ],
  handbook: 'Handbook p. 296',
);

const criticalBrief = BriefSection(
  title: 'The depth that needs the least energy',
  picture: criticalPicture,
  steps: [
    (
      'Every flow has an energy',
      'Water in a channel carries energy two ways: it is piled up to some '
          'depth, and it is moving at some speed. Plot that total against the '
          'depth it is running at and you get a curve with a nose.',
    ),
    (
      'Two depths for one energy',
      'Every energy above the minimum can be carried at two depths: deep and '
          'slow on the upper arm, shallow and fast on the lower one. Same energy, '
          'same flow, two ways to do it.',
    ),
    (
      'The nose is the cheapest',
      'At the nose the flow gets by on the least energy it possibly can. That '
          'depth is the critical depth.',
    ),
    (
      'What moves it, and what does not',
      'For a rectangular channel it depends only on how much water crosses '
          'each unit of width. The slope, the lining, the length, and the depth '
          'the water happens to be at do not move it. Those decide where the flow '
          'sits on the curve, which is a different question.',
    ),
  ],
  spoken: [
    (
      'Rectangular channel',
      r'y_c = \left(\frac{q^2}{g}\right)^{1/3}',
      'the cube root of the flow per width squared over gravity',
    ),
    (
      'Flow per unit width',
      r'q = \frac{Q}{B}',
      'the total flow divided by the width',
    ),
    (
      'At the nose',
      r'E_{min} = 1.5\,y_c',
      'the least energy is one and a half critical depths',
    ),
  ],
  handbook: 'Handbook p. 296',
);

const hydraulicJumpBrief = BriefSection(
  title: 'What crosses the jump and what does not',
  picture: hydraulicJumpPicture,
  steps: [
    (
      'Fast shallow water piles up',
      'Water racing out from under a gate suddenly rears up into slow deep '
          'water, with a churning roller standing in between. That is a hydraulic '
          'jump, and it only ever runs that way: fast to slow, never back.',
    ),
    (
      'What comes through unchanged',
      'The amount of water. Nothing was added or taken away, so the same flow '
          'leaves as arrived. The push of the water, its momentum, balances across '
          'it too, and that is what the conjugate depth formula is built from.',
    ),
    (
      'What is thrown away',
      'The energy. All that churning turns into heat and noise. That is '
          'exactly why a jump is built at the foot of a spillway: the problem '
          'there is that the water has too much energy.',
    ),
    (
      'So do not solve one with energy',
      'Balancing energy across a jump is the classic way to get it wrong. '
          'Depth goes up, speed comes down, and the Froude number crosses one on '
          'the way through.',
    ),
  ],
  spoken: [
    (
      'Depth after the jump',
      r'y_2 = \frac{y_1}{2}\left(-1 + \sqrt{1 + 8Fr_1^2}\right)',
      'built from the momentum balance, not from energy',
    ),
    (
      'What balances',
      r'M = \frac{y^2}{2} + \frac{q^2}{gy}',
      'the momentum function is the same on both sides',
    ),
    (
      'What is lost',
      r'\Delta E = E_1 - E_2 > 0',
      'energy afterwards is always less than before',
    ),
  ],
  handbook: 'Handbook p. 297',
);

const weirBrief = BriefSection(
  title: 'The shape of the hole picks the formula',
  picture: weirPicture,
  steps: [
    (
      'A weir is a wall with a gap',
      'Put a plate across a stream and the water spills over it. Measure how '
          'deep the water stands above the crest and you can work out the flow. '
          'That depth is the head.',
    ),
    (
      'A crest running wall to wall',
      'The water pours straight over the full width. The flow is a coefficient '
          'times the length times the head to the three halves.',
    ),
    (
      'A crest that stops short',
      'Now the water has to curl in around each end, which costs a little '
          'width. A tenth of the head comes off each side, so the length used is '
          'L minus 0.2 times H.',
    ),
    (
      'A v-notch has no crest at all',
      'It is a triangle, so there is no length to put in. The flow is a '
          'coefficient times the head to the FIVE halves. Each shape also has its '
          'own coefficient, different again in feet and in meters.',
    ),
  ],
  spoken: [
    (
      'Wall to wall',
      r'Q = C\,L\,H^{3/2}',
      'coefficient times length times head to the three halves',
    ),
    (
      'Stopping short',
      r'Q = C\,(L - 0.2H)\,H^{3/2}',
      'the same, with a tenth of the head taken off each end',
    ),
    (
      'A 90 degree v',
      r'Q = C\,H^{5/2}',
      'coefficient times head to the five halves, no length',
    ),
  ],
  handbook: 'Handbook p. 297',
);

const exponentBrief = BriefSection(
  title: 'What an exponent is really telling you',
  picture: exponentPicture,
  steps: [
    (
      'The power says how touchy it is',
      'Raise the water an inch over two weirs and one of them notices far '
          'more than the other. The power on the head is what says which.',
    ),
    (
      'Three halves, and five halves',
      'Double the head over a flat crest and the flow goes up about 2.8 times. '
          'Double it over a v-notch and the flow goes up about 5.7 times. Halve '
          'the head and they drop by those same factors.',
    ),
    (
      'Only the ratio matters',
      'Where the head started never comes into it, only what it was multiplied '
          'by. And the crest length sits outside the power, so it scales the flow '
          'without changing how touchy the weir is.',
    ),
    (
      'Which is why a v-notch is used',
      'A small trickle still moves its head a good deal, so it can be measured '
          'well. The same steepness is why it runs out of range as soon as the '
          'flow comes up.',
    ),
  ],
  spoken: [
    (
      'A flat crest',
      r'2H \Rightarrow 2^{3/2} \approx 2.8\,Q',
      'twice the head is about two point eight times the flow',
    ),
    (
      'A v-notch',
      r'2H \Rightarrow 2^{5/2} \approx 5.7\,Q',
      'twice the head is about five point seven times the flow',
    ),
    (
      'Only the ratio counts',
      r'\frac{Q_2}{Q_1} = \left(\frac{H_2}{H_1}\right)^{n}',
      'the flows go as the head ratio raised to the power',
    ),
  ],
  handbook: 'Handbook p. 297',
);

const hazenBrief = BriefSection(
  title: 'A coefficient that runs the other way',
  picture: hazenPicture,
  steps: [
    (
      'One number for the pipe wall',
      'Water mains are sized with a single number, C, that stands for how '
          'smooth the inside of the pipe is. Plastic is about 150, new cast iron '
          'about 130, and the same iron after twenty years in the ground about 100.',
    ),
    (
      'Bigger C is smoother, and carries more',
      'That is the opposite of the roughness in Manning\'s equation two pages '
          'away, where bigger means rougher. Mixing the two up turns the answer '
          'upside down.',
    ),
    (
      'It counts in full',
      'C sits on the top in the first power. Two mains alike in everything but '
          'the wall carry flows in the plain ratio of their coefficients: half '
          'again the C is half again the water.',
    ),
    (
      'The odd powers are not for C',
      'The 0.63 belongs to the hydraulic radius and the 0.54 to the slope of '
          'the pressure line. Putting either on C is the other trap here.',
    ),
  ],
  spoken: [
    (
      'The equation',
      r'Q = k_1 C A R_H^{0.63} S_v^{0.54}',
      'the constant times C times area, times radius and slope to their own powers',
    ),
    (
      'Two like mains',
      r'\frac{Q_A}{Q_B} = \frac{C_A}{C_B}',
      'the flows go straight as the coefficients',
    ),
    (
      'The constant',
      r'k_1 = 1.318 \text{ (ft)}, \; 0.849 \text{ (m)}',
      'one point three one eight in feet, zero point eight four nine in meters',
    ),
  ],
  handbook: 'Handbook p. 297',
);

const pumpPowerBrief = BriefSection(
  title: 'Three powers, and they only get bigger',
  picture: pumpPowerPicture,
  steps: [
    (
      'Follow the energy through the pump',
      'Electricity goes into the motor. The motor turns the shaft. The shaft '
          'drives the impeller, which pushes the water. Something is lost at every '
          'handover, so each stage carries less than the one before it.',
    ),
    (
      'So count backwards from the water',
      'The power that ends up in the water is the smallest of the three. The '
          'shaft has to supply more than that, and the meter has to supply more '
          'again. The order never changes.',
    ),
    (
      'Efficiency is a divide, not a multiply',
      'Efficiency is a number below one. Dividing by it makes the answer '
          'bigger, which is what you want. Multiplying instead makes the shaft '
          'work less hard than the water, which cannot happen, and that is the '
          'usual slip here.',
    ),
    (
      'What plainly doubles it',
      'Flow, head, and the weight of what is being moved all sit on top, so '
          'doubling any of them doubles the power. A bigger motor does not: a '
          'nameplate is a ceiling, not a bill.',
    ),
  ],
  spoken: [
    (
      'Into the water',
      r'\dot W_{fluid} = \gamma Q H',
      'unit weight times flow times head',
    ),
    (
      'At the shaft',
      r'\dot W_{brake} = \frac{\dot W_{fluid}}{\eta_{pump}}',
      'the water power divided by the pump efficiency',
    ),
    (
      'Off the meter',
      r'\dot W_{in} = \frac{\dot W_{brake}}{\eta_{motor}}',
      'the shaft power divided by the motor efficiency',
    ),
  ],
  handbook: 'Handbook p. 191',
);

const npshBrief = BriefSection(
  title: 'The margin before the water boils',
  picture: npshPicture,
  steps: [
    (
      'Water boils when the pressure drops far enough',
      'Not just when it is hot. Drop the pressure and water boils cold. The '
          'lowest pressure anywhere in a pumping system is right at the pump '
          'inlet, so that is where it happens.',
    ),
    (
      'And boiling wrecks the pump',
      'Bubbles form and are carried a little further in, where the pressure '
          'comes back up and they collapse against the impeller. It sounds like '
          'pumping gravel and it eats the metal away. That is cavitation.',
    ),
    (
      'What adds to the margin',
      'The air pressing down on the supply, worth about 10.3 meters at sea '
          'level and less up a mountain. And any water standing ABOVE the pump, '
          'which pushes it in for free.',
    ),
    (
      'What eats the margin',
      'Having to lift water up to the pump, which makes that term negative '
          'and is the sign error this lesson is built on. Friction in the suction '
          'pipe. And hot water, whose boiling pressure climbs steeply. Nothing on '
          'the discharge side matters at all.',
    ),
  ],
  spoken: [
    (
      'The margin',
      r'NPSH_A = H_{pa} + H_s - \sum h_L - H_{vp}',
      'air pressure, plus or minus the static height, less friction, less the boiling pressure',
    ),
    ('Lifting the water up', r'H_s < 0', 'a lift counts against you'),
    ('Water above the pump', r'H_s > 0', 'a flooded suction counts for you'),
    (
      'Safe',
      r'NPSH_A > NPSH_R',
      'the margin you have beats the margin the pump needs',
    ),
  ],
  handbook: 'Handbook p. 191',
);

const rationalBrief = BriefSection(
  title: 'Three numbers multiplied, and the units look after themselves',
  picture: rationalPicture,
  steps: [
    (
      'How much rain, on how much ground, on what surface',
      'Rain falls at some intensity. It falls on some acreage. And some '
          'fraction of it runs off instead of soaking in. Multiply the three and '
          'you have the peak flow.',
    ),
    (
      'C is the fraction that runs off',
      'About 0.95 for paving, which sheds nearly everything. About 0.15 for '
          'woodland, which drinks nearly all of it. It is a plain fraction with no '
          'units.',
    ),
    (
      'The units already fit',
      'An acre under an inch of rain an hour is almost exactly one cubic foot '
          'a second. So in those units there is nothing to convert, and reaching '
          'for a conversion is itself the mistake.',
    ),
    (
      'Neither cover nor size wins alone',
      'Under the same storm the intensity cancels, so only C times A separates '
          'two catchments. A small hard site and a large soft one can come to the '
          'same peak. The method is for small catchments, under about 200 acres.',
    ),
  ],
  spoken: [
    (
      'The peak',
      r'Q = C I A',
      'the runoff fraction, times the rain intensity, times the area',
    ),
    (
      'Why no conversion',
      r'1 \text{ acre-in/hr} \approx 1.008 \text{ cfs}',
      'an acre under an inch an hour is about one cubic foot a second',
    ),
    (
      'Several covers',
      r'Q = I \sum C_i A_i',
      'add up C times area for each piece, then multiply by the rain',
    ),
  ],
  handbook: 'Handbook p. 290',
);

const catchmentBrief = BriefSection(
  title: 'One coefficient for a patchwork',
  picture: catchmentBlendPicture,
  steps: [
    (
      'One inlet needs one number',
      'Real ground is a patchwork: some roof, some road, some grass. They all '
          'drain to the same inlet, so they have to be boiled down to a single '
          'runoff coefficient.',
    ),
    (
      'Weight it by how much ground there is',
      'Multiply each cover\'s C by its own area, add those up, and divide by '
          'the total area. The cover with more ground under it has more say.',
    ),
    (
      'Averaging the two C values is wrong',
      'That pretends the patches are the same size. The further apart the '
          'areas are, the more wrong it gets.',
    ),
    (
      'Which way it leans is often enough',
      'The blend always leans toward whichever cover covers more ground, and '
          'lands halfway only when the areas are equal. Naming the direction '
          'throws out half the choices before any arithmetic.',
    ),
  ],
  spoken: [
    (
      'Weighted by area',
      r'C = \frac{\sum C_i A_i}{\sum A_i}',
      'each C times its area, added up, over the total area',
    ),
    (
      'Or straight to the flow',
      r'Q = I \sum C_i A_i',
      'the rain times the sum of C times area',
    ),
  ],
  handbook: 'Handbook p. 290',
);

const curveNumberBrief = BriefSection(
  title: 'The ground takes its share first',
  picture: curveNumberPicture,
  steps: [
    (
      'This one answers in inches, not flow',
      'The SCS method gives the DEPTH of water that runs off, in inches. It is '
          'not a discharge. Reporting it in cubic feet a second is the trap here.',
    ),
    (
      'One number for how thirsty the ground is',
      'The curve number: about 98 for paving, which drinks nothing, around 70 '
          'for ordinary mixed ground, down into the fifties for woods on good '
          'soil. From it comes the retention, the most the ground could hold.',
    ),
    (
      'The first slice is taken before anything runs',
      'The ground takes a fifth of that retention before a drop runs off. '
          'Under that threshold the runoff is a hard zero, not a small number.',
    ),
    (
      'Then it climbs toward all of it',
      'Past the threshold, the share that runs off grows with the storm: '
          'slowly at first, then approaching the whole of the rain as the ground '
          'gets saturated.',
    ),
  ],
  spoken: [
    (
      'Runoff depth',
      r'Q = \frac{(P - 0.2S)^2}{P + 0.8S}',
      'the rain less the first slice, squared, over the rain plus most of the retention',
    ),
    (
      'Retention',
      r'S = \frac{1{,}000}{CN} - 10',
      'a thousand over the curve number, less ten',
    ),
    (
      'Nothing below the threshold',
      r'P \le 0.2S \Rightarrow Q = 0',
      'if the rain does not clear the first slice, nothing runs off',
    ),
  ],
  handbook: 'Handbook p. 290',
);

const unitHydrographBrief = BriefSection(
  title: 'One inch, and everything else is a multiple',
  picture: unitHydrographPicture,
  steps: [
    (
      'A watershed has one handwriting',
      'Rain falls, and the river at the outlet rises, peaks, and falls away '
          'more slowly. That shape is the watershed\'s own. A unit hydrograph is '
          'that shape for one inch of runoff over a stated number of hours.',
    ),
    (
      'A deeper storm just scales the height',
      'Three inches instead of one gives three times the flow at every hour, '
          'peaking at the very same hour. The watershed still moves water at its '
          'own speed. Only the height changes, never the timing.',
    ),
    (
      'A longer storm does not scale at all',
      'The same total rain spread over three hours instead of one gives a '
          'lower, longer, flatter answer. No multiplying gets you there; you build '
          'it by lagging copies and adding them up.',
    ),
    (
      'So keep the two apart',
      'Depth sets the volume. Duration sets the shape. And the river you '
          'actually measure is this runoff added on top of the baseflow that was '
          'already there.',
    ),
  ],
  spoken: [
    (
      'Scaling for depth',
      r'Q(t) = P \times Q_{UH}(t)',
      'every flow multiplied by the inches of runoff',
    ),
    (
      'The hours',
      r'\text{unchanged}',
      'the peak stays at the same hour whatever the depth',
    ),
    (
      'What is under the curve',
      r'\text{one inch over the watershed}',
      'a unit hydrograph carries exactly one inch of runoff',
    ),
  ],
  handbook: 'Handbook p. 292',
);

const concentrationBrief = BriefSection(
  title: 'Why the design storm lasts exactly that long',
  picture: concentrationPicture,
  steps: [
    (
      'Water from far away arrives late',
      'A drop landing at the far corner of a catchment takes a while to reach '
          'the outlet. The time from the furthest corner is the time of '
          'concentration.',
    ),
    (
      'Too short a storm and half the ground is missing',
      'A short storm is more intense, because heavy rain never lasts long. But '
          'it stops before the far ground has reported in, so the heavy rain only '
          'counts over part of the catchment.',
    ),
    (
      'Too long a storm and the rain is weaker',
      'Now the whole catchment is contributing, but a storm that lasts longer '
          'is quoted at a lower intensity, so the peak comes out smaller again.',
    ),
    (
      'The biggest peak is in between',
      'It falls exactly where the storm lasts as long as the travel time: the '
          'first moment the whole catchment is in, at the strongest rain that '
          'lasts that long. That is why the design storm is set equal to it.',
    ),
  ],
  spoken: [
    (
      'The design storm',
      r'D = t_c',
      'the storm duration is set to the time of concentration',
    ),
    ('Then', r'Q = C I_{t_c} A', 'use the intensity quoted for that duration'),
    (
      'Shorter, or longer',
      r'\text{part of } A, \;\text{or smaller } I',
      'a short storm loses area, a long one loses intensity',
    ),
  ],
  handbook: 'Handbook p. 290',
);

const routingBrief = BriefSection(
  title: 'One subtraction, and the sign is the answer',
  picture: routingPicture,
  steps: [
    (
      'A pond is a bath with a small plug hole',
      'The storm pours in fast. The outlet only lets a trickle out. Take what '
          'leaves away from what arrives and you have the rate the pond is filling '
          'or emptying.',
    ),
    (
      'Positive means filling',
      'More in than out and the level rises. Fewer in than out and it falls. '
          'Doing the subtraction backwards gives the right number with the wrong '
          'story attached, which is the trap here.',
    ),
    (
      'That is the whole point of the pond',
      'While the storm is rising, far more arrives than the outlet can pass, '
          'so the pond swallows it and the town downstream never sees the peak '
          'that arrived.',
    ),
    (
      'The fullest moment is when the two are equal',
      'One instant the inflow has fallen back to match the outflow. That is '
          'the highest level and the biggest outflow, and it always lands on the '
          'falling side of the storm. Then it drains, and it must finish draining '
          'before the next storm.',
    ),
  ],
  spoken: [
    (
      'The rate',
      r'I - O = \frac{\Delta S}{\Delta t}',
      'in minus out is how fast the stored water changes',
    ),
    ('Filling', r'I > O', 'more arriving than leaving'),
    (
      'Fullest',
      r'I = O',
      'the peak of the pond, on the falling side of the storm',
    ),
  ],
  handbook: 'Handbook p. 290',
);

const seepageBrief = BriefSection(
  title: 'Three numbers that are easy to mix up',
  picture: seepagePicture,
  steps: [
    (
      'Soil is grains with gaps between them',
      'Water cannot go through the grains, only around them. So the face of a '
          'block of soil is mostly solid, and only the gaps are open.',
    ),
    (
      'The first number pretends the grains are not there',
      'Darcy\'s law gives how much water crosses a square meter of the whole '
          'face, grains included. It has the units of a speed, but it is the speed '
          'of nothing real.',
    ),
    (
      'The real water goes faster',
      'It is squeezed into the gaps, so it has to hurry. Divide the first '
          'number by the porosity, the fraction that is gap, and you get the speed '
          'a dye would actually travel at. It is always the larger of the two.',
    ),
    (
      'And the third is not a speed at all',
      'Multiply the first number by the area and you get a volume per second, '
          'a discharge. Read the units of what is asked before reaching for a '
          'formula.',
    ),
  ],
  spoken: [
    (
      'Through the whole face',
      r'q = K i',
      'conductivity times the slope of the water table',
    ),
    (
      'Through the gaps',
      r'v = \frac{q}{n}',
      'that, divided by the porosity, which makes it bigger',
    ),
    ('The volume', r'Q = q A', 'the first number times the area of the face'),
  ],
  handbook: 'Handbook p. 292',
);

const wellBrief = BriefSection(
  title: 'Clay on top decides everything',
  picture: wellsPicture,
  steps: [
    (
      'Pump a well and the water around it dips',
      'It sinks into a funnel shape, deepest at the well itself. How much '
          'water you get depends on how far you have pulled that funnel down.',
    ),
    (
      'No lid: the aquifer gets thinner',
      'With a free water table, drawing it down leaves less wet ground near '
          'the well to carry water through. Dupuit handles that by squaring the '
          'heads.',
    ),
    (
      'A clay lid: the thickness never changes',
      'Under clay, the aquifer is full to the roof however hard you pump. What '
          'drops is only the pressure. The heads go into Thiem plain, not squared, '
          'and the giveaway is water standing above the top of the aquifer.',
    ),
    (
      'Why squaring matters',
      'Because of the squares, pulling the well down twice as far buys LESS '
          'than twice the water, while a wet year that lifts the whole water table '
          'buys more. Both formulas use the natural log of the radius ratio, never '
          'the base ten log.',
    ),
  ],
  spoken: [
    (
      'No lid',
      r'Q = \frac{\pi K (h_2^2 - h_1^2)}{\ln(r_2/r_1)}',
      'Dupuit: the heads are squared',
    ),
    (
      'Under a lid',
      r'Q = \frac{2\pi T (h_2 - h_1)}{\ln(r_2/r_1)}',
      'Thiem: the heads go in plain',
    ),
    (
      'Transmissivity',
      r'T = K b',
      'conductivity times the thickness that cannot change',
    ),
  ],
  handbook: 'Handbook pp. 292 to 293',
);

const bodBrief = BriefSection(
  title: 'The five day test is not the whole of it',
  picture: bodPicture,
  steps: [
    (
      'Bacteria eat the muck, and breathe while they do it',
      'Put dirty water in a bottle and the bacteria in it start working '
          'through the organic matter, using up oxygen as they go. BOD is how '
          'much oxygen that takes.',
    ),
    (
      'It arrives slowly, not all at once',
      'The oxygen is used over days, fast at first and then tailing off '
          'toward a ceiling. The ceiling is the ultimate BOD: everything the muck '
          'will ever need.',
    ),
    (
      'The standard test reads at day five',
      'So it catches only part of the way up. About 68 percent at the usual '
          'decay rate, under 40 percent in slow cold water, nearly all of it in a '
          'fast warm one. The 68 percent is not a law.',
    ),
    (
      'Which way you are going decides multiply or divide',
      'From the ultimate to a five day reading you multiply by the fraction '
          'and the number gets smaller. From a reading back to the ultimate you '
          'divide and it gets bigger. The ultimate is always the larger of the '
          'two, which catches a division done upside down.',
    ),
  ],
  spoken: [
    (
      'Used up by day t',
      r'BOD_t = L_0\left(1 - e^{-kt}\right)',
      'the ultimate, times the share the bacteria have got through by then',
    ),
    (
      'Still to come',
      r'L_0 - BOD_t = L_0 e^{-kt}',
      'the ultimate less what has been used',
    ),
    (
      'Working backward',
      r'L_0 = \frac{BOD_t}{1 - e^{-kt}}',
      'the reading divided by the share, which makes it bigger',
    ),
  ],
  handbook: 'Handbook p. 321',
);

const temperatureBrief = BriefSection(
  title: 'Temperature moves the rate, not the total',
  picture: temperaturePicture,
  steps: [
    (
      'Warm bacteria work faster',
      'The same muck in warm water is eaten sooner than in cold water. So a '
          'decay rate quoted at twenty degrees has to be corrected for the '
          'temperature the water is really at.',
    ),
    (
      'The ceiling does not move',
      'The same organic matter needs the same oxygen in the end. Warm water '
          'only gets there sooner, so the warm curve climbs more steeply to '
          'exactly the same ceiling.',
    ),
    (
      'Watch which way the exponent runs',
      'It is the temperature MINUS twenty. Above twenty the factor is bigger '
          'than one and the decay speeds up. Writing twenty minus T makes a warm '
          'river slower, which cannot happen, and that is the trap here.',
    ),
    (
      'Which theta belongs to which job',
      'It depends on the process and the range: 1.135 for BOD from 4 to 20 '
          'degrees, 1.056 from 21 to 30, and 1.024 for oxygen going back in from '
          'the air.',
    ),
  ],
  spoken: [
    (
      'The correction',
      r'k_T = k_{20}\,\theta^{(T-20)}',
      'the rate at twenty, times theta to the temperature above twenty',
    ),
    ('BOD, warm water', r'\theta = 1.056', 'from 21 to 30 degrees'),
    ('BOD, cold water', r'\theta = 1.135', 'from 4 to 20 degrees'),
    ('Oxygen from the air', r'\theta = 1.024', 'reaeration'),
  ],
  handbook: 'Handbook p. 322',
);

const overflowBrief = BriefSection(
  title: 'A rate with the units of a speed',
  picture: overflowPicture,
  steps: [
    (
      'A settling tank is a race',
      'Water enters at the bottom and creeps up to the weir at the top. '
          'Meanwhile grains of dirt sink. Whether a grain is caught is simply '
          'whether it sinks faster than the water rises.',
    ),
    (
      'That rising speed is the overflow rate',
      'It is the flow divided by the SURFACE area. The units get quoted as '
          'gallons a day per square foot, but those cancel to a speed, and the '
          'speed is what the tank is really about.',
    ),
    (
      'So depth buys nothing at all here',
      'Depth is nowhere in it. A deeper tank holds the water longer, which '
          'matters for other things, and catches not one extra grain. Making the '
          'tank WIDER is what catches more.',
    ),
    (
      'And a storm can wash it out',
      'Double the flow and the water rises twice as fast, so grains that used '
          'to reach the floor now go over the weir. Primary tanks run at 800 to '
          '1,200; secondary ones at 400 to 800, because biological floc sinks far '
          'more slowly than grit.',
    ),
  ],
  spoken: [
    (
      'The rising speed',
      r'v_o = \frac{Q}{A_{surface}}',
      'the flow divided by the surface area, which is a speed',
    ),
    (
      'Caught when',
      r'v_s > v_o',
      'the grain sinks faster than the water rises',
    ),
    (
      'Detention time',
      r'\theta = \frac{V}{Q}',
      'the volume over the flow, which is what depth does buy',
    ),
  ],
  handbook: 'Handbook p. 339',
);

const residenceBrief = BriefSection(
  title: 'Two clocks in one plant',
  picture: residencePicture,
  steps: [
    (
      'The water passes through once',
      'It comes in, crosses the plant, and leaves. How long that takes is the '
          'volume over the flow, and it comes out in HOURS.',
    ),
    (
      'The solids go round and round',
      'Bugs settle out in the clarifier and get pumped back to the basin to '
          'work again. They stay for DAYS, typically four to fifteen, until '
          'somebody deliberately wastes them.',
    ),
    (
      'The units tell you which is which',
      'Hours means water. Days means solids. That alone answers most '
          'questions before any arithmetic.',
    ),
    (
      'Two ways solids leave, not one',
      'The waste pump, and the ones that escape over the weir. Leaving the '
          'second out of the bottom is a common slip. Wasting more sludge '
          'shortens the solids clock and does nothing at all to the water clock.',
    ),
  ],
  spoken: [
    (
      'The water',
      r'\theta = \frac{V}{Q}',
      'the basin volume over the flow, in hours',
    ),
    (
      'The solids',
      r'\theta_c = \frac{V X_A}{Q_w X_w + Q_e X_e}',
      'the solids held, over the solids leaving each day by both routes',
    ),
  ],
  handbook: 'Handbook p. 333',
);

const foodRatioBrief = BriefSection(
  title: 'Food over the mouths that eat it',
  picture: foodRatioPicture,
  steps: [
    (
      'Dinner, and the number of diners',
      'Organic matter arrives each day. A mass of bugs sits in the basin '
          'waiting for it. The ratio between the two says whether the bugs are '
          'underfed or swamped.',
    ),
    (
      'The food is flow times strength',
      'Only their product counts. A storm that doubles the flow and halves '
          'the strength brings exactly the same kilograms of food, so the ratio '
          'does not budge.',
    ),
    (
      'The bugs are volume times concentration',
      'Their product is the biomass being carried. A second basin at the same '
          'concentration halves the ratio just as surely as doubling the '
          'concentration would.',
    ),
    (
      'And the waste pump is the lever',
      'Conventional plants are held between about 0.2 and 0.4 per day. '
          'Wasting more sludge lowers the biomass and pushes the ratio up.',
    ),
  ],
  spoken: [
    (
      'The ratio',
      r'F{:}M = \frac{Q S_0}{V X_A}',
      'the food arriving each day, over the mass of bugs held',
    ),
    ('The food', r'Q S_0', 'flow times incoming strength, a load per day'),
    ('The bugs', r'V X_A', 'basin volume times solids concentration, a mass'),
  ],
  handbook: 'Handbook p. 333',
);

const doseBrief = BriefSection(
  title: 'Three numbers, and the pump is set to the sum',
  picture: dosePicture,
  steps: [
    (
      'The water eats the first chlorine you add',
      'Organic matter, ammonia and iron in the raw water consume it before '
          'any is left over. That appetite is the DEMAND, and a dirty water has a '
          'big one.',
    ),
    (
      'What is left over is the residual',
      'It has to still be measurable at the far end of the mains, which is '
          'the only place anybody can sample. That is why the rules are written '
          'on the residual.',
    ),
    (
      'The pump is set to both together',
      'Feed only the demand and nothing reaches the customer. Feed only the '
          'residual and the water eats it before it leaves the works. The dose is '
          'the sum.',
    ),
    (
      'Mass per day comes off the dose',
      'Not off the demand. And a milligram per liter is a gram per cubic '
          'meter, which makes the arithmetic easier than it looks.',
    ),
  ],
  spoken: [
    (
      'The balance',
      r'\text{dose} = \text{demand} + \text{residual}',
      'what you feed is what the water eats plus what must survive',
    ),
    (
      'Mass per day',
      r'\dot m = \text{dose} \times Q',
      'the dose times the flow',
    ),
    (
      'The handy identity',
      r'1 \text{ mg/L} = 1 \text{ g/m}^3',
      'one milligram per liter is one gram per cubic meter',
    ),
  ],
  handbook: 'Handbook p. 346',
);

const contactBrief = BriefSection(
  title: 'Credit is a product, and the time is the honest part',
  picture: contactPicture,
  steps: [
    (
      'Killing bugs takes strength and time',
      'A strong dose for a short while does about as much as a weak one for '
          'longer. So the credit is the residual multiplied by the contact time, '
          'and the two trade off exactly.',
    ),
    (
      'It runs on the residual, not the dose',
      'Chlorine the water already ate buys nothing. Only what is left over '
          'is doing any disinfecting.',
    ),
    (
      'The time is not volume over flow',
      'That would assume every drop takes the same path. Some water short '
          'circuits from the inlet straight to the outlet. The time that counts '
          'is what the fastest TENTH gets, which in an unbaffled tank can be a '
          'third of the theoretical figure.',
    ),
    (
      'Baffles are the cheap fix',
      'They make the water take the long way round and close most of the gap. '
          'Compliance is checked at peak flow, when the time is shortest.',
    ),
  ],
  spoken: [
    (
      'The credit',
      r'CT = C \times t_{10}',
      'the residual times the time the fastest tenth gets',
    ),
    (
      'The honest time',
      r't_{10} < \frac{V}{Q}',
      'always less than volume over flow',
    ),
    (
      'What it has to buy',
      r'3\text{-log Giardia}, \; 4\text{-log virus}',
      'the required kill for each organism',
    ),
  ],
  handbook: 'Handbook p. 346',
);

const standardsBrief = BriefSection(
  title: 'Two tiers, and only one is law',
  picture: tiersPicture,
  steps: [
    (
      'Some limits are about health',
      'Arsenic, nitrate, lead, turbidity, the pathogens. These are PRIMARY '
          'standards. Going over one is a violation, and the utility has to tell '
          'the public.',
    ),
    (
      'Some are about how the water seems',
      'Iron that stains the laundry, manganese, dissolved solids, chloride, '
          'pH. These are SECONDARY standards. They are advice, not law. Going '
          'over one brings complaints, not a notice.',
    ),
    (
      'The size of a limit tells you nothing',
      'A tiny number is not automatically a health limit. Arsenic is 0.010 '
          'and iron is 0.3, but what puts them in different tiers is harm, not '
          'magnitude.',
    ),
    (
      'Wastewater is a different law entirely',
      'Drinking water is the Safe Drinking Water Act. Discharges are the '
          'Clean Water Act, permitted through NPDES, with conventional secondary '
          'treatment around 30 mg/L of BOD and suspended solids.',
    ),
  ],
  spoken: [
    (
      'Primary',
      r'\text{health based, enforceable}',
      'breaking it is a violation with public notice',
    ),
    (
      'Secondary',
      r'\text{aesthetic, advisory}',
      'taste, color, staining and scale',
    ),
    (
      'Secondary treatment',
      r'\approx 30 \text{ mg/L BOD}_5',
      'the conventional discharge standard',
    ),
  ],
  handbook: 'Handbook, water quality standards',
);

const hardnessBrief = BriefSection(
  title: 'Everything on one basis',
  picture: hardnessPicture,
  steps: [
    (
      'Hardness comes from two main ions',
      'Calcium and magnesium. Both make scale and both fight soap. But a '
          'milligram of one is not chemically worth a milligram of the other, so '
          'they cannot simply be added up as they come.',
    ),
    (
      'Convert both to one common currency',
      'Everything gets rewritten as the equivalent amount of calcium '
          'carbonate. The multiplier is 50 divided by the ion\'s own equivalent '
          'weight.',
    ),
    (
      'The lighter ion counts for more',
      'Calcium multiplies by 2.5, magnesium by 4.12, because magnesium is the '
          'lighter of the two. Milligram for milligram, magnesium brings more '
          'hardness.',
    ),
    (
      'So convert before comparing, not just before adding',
      'The conversion can flip which ion dominates. Adding the raw numbers '
          'understates the hardness every single time. The bands: soft under 60, '
          'moderately hard to 120, hard to 180, very hard above.',
    ),
  ],
  spoken: [
    (
      'On one basis',
      r'\text{as CaCO}_3 = \sum C_i \frac{50}{EW_i}',
      'each concentration times fifty over its own equivalent weight',
    ),
    ('Calcium', r'\times 2.5', 'fifty over twenty'),
    ('Magnesium', r'\times 4.12', 'fifty over twelve point one five'),
  ],
  handbook: 'Handbook, hardness',
);

const efficiencyBrief = BriefSection(
  title: 'What came out, over what went in',
  picture: efficiencyPicture,
  steps: [
    (
      'Two numbers, and the gap between them',
      'Something strong goes in, something weaker comes out. The removal is '
          'the size of that gap, written as a share of what went in.',
    ),
    (
      'The trap is reporting the other piece',
      'What is left over, effluent over influent, is the fraction still '
          'there. The two add to one, so a plant at 87.5 percent leaves 12.5, and '
          'both numbers are usually among the choices.',
    ),
    (
      'The flow cancels out',
      'It is in neither term. Only the ratio of the two concentrations '
          'matters, so doubling the influent and the permit together changes '
          'nothing even though twice the mass is being removed.',
    ),
    (
      'Percentages flatter a good plant',
      'Near the top of the range, five points halves what is discharged: 90 '
          'to 95 takes a 20 mg/L effluent down to 10. That is why permits are '
          'written on concentrations, not percentages.',
    ),
  ],
  spoken: [
    ('Removed', r'E = \frac{S_0 - S}{S_0}', 'the gap, divided by what went in'),
    (
      'Left behind',
      r'\frac{S}{S_0} = 1 - E',
      'what came out over what went in, which is one less the removal',
    ),
  ],
  handbook: 'Handbook, treatment performance',
);

const countBrief = BriefSection(
  title: 'Count the parts, and count what the joints allow',
  picture: countPicture,
  steps: [
    (
      'Build it out of straws and pins',
      'Pin some straws together at their ends and you have a truss. Every '
          'straw can only pull or push along its own length, and every pin is '
          'free to swivel, so no corner can hold a bend.',
    ),
    (
      'Weld the corners and it is a different thing',
      'If the corners cannot swivel, a corner can hold a bend. That is a '
          'frame. A welded triangle is a frame however much it looks like a '
          'truss, and it gets counted a different way.',
    ),
    (
      'Count what you have against what you can solve',
      'Add up the bars and the reactions the supports give you: a roller 1, '
          'a pin 2, a fixed end 3. That is the supply. Each joint hands you a '
          'couple of equations, and that is what you can solve with.',
    ),
    (
      'Short, exact, or over',
      'Short of what you need and it is a mechanism, which means it moves. '
          'Exactly enough and statics alone finishes it. Over and it is '
          'indeterminate by the difference, so you need more than statics.',
    ),
  ],
  spoken: [
    (
      'A truss',
      r'm + r \text{ vs } 2j',
      'bars plus reactions, against two for every joint',
    ),
    (
      'A frame',
      r'3m + r \text{ vs } 3j + c',
      'three per member plus reactions, against three per joint plus one for each hinge',
    ),
    (
      'Reactions',
      r'\text{roller } 1, \; \text{pin } 2, \; \text{fixed } 3',
      'how many unknowns each kind of support puts in',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const stabilityBrief = BriefSection(
  title: 'The count can be right and the thing still falls over',
  picture: stabilityPicture,
  steps: [
    (
      'The count is blind',
      'Counting sees how many bars, joints and supports there are. It cannot '
          'see which way any of them POINT, and pointing is what decides whether '
          'the thing stands up.',
    ),
    (
      'All the supports pointing the same way',
      'Three rollers on flat ground all push straight up. Push the structure '
          'sideways and nothing is pushing back sideways, so it slides. The '
          'count says it is fine.',
    ),
    (
      'All the supports aimed at one spot',
      'If every support line passes through a single point, none of them can '
          'stop a turn about that point, so the whole thing spins. Again the '
          'count says nothing.',
    ),
    (
      'More of the same never fixes it',
      'Adding a fourth roller makes the count look even better and the thing '
          'is just as unstable. Do the count, then look at the picture and ask '
          'which way each support pushes.',
    ),
  ],
  spoken: [
    ('Needed', r'm + r \ge 2j', 'enough bars and reactions to go round'),
    (
      'Never enough on its own',
      r'\text{all parallel, or all through one point}',
      'either arrangement is unstable whatever the count says',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const momentCenterBrief = BriefSection(
  title: 'Put the pivot where the bars you do not want cross',
  picture: pivotPicture,
  steps: [
    (
      'Cut the truss in half',
      'Slice straight through it, throw one half away, and hold the other. '
          'The cut bars are now pulling on the piece you kept, and you have '
          'three unknown forces to find.',
    ),
    (
      'Pick your pivot on purpose',
      'A force that goes THROUGH a point cannot turn anything about that '
          'point, like pushing a door right at its hinge. It just drops out of '
          'the sum.',
    ),
    (
      'So aim at the crossing',
      'Take moments about the point where the two bars you are NOT after '
          'cross. Both go through it, both drop out, and the equation has your '
          'one bar left in it.',
    ),
    (
      'Unless they never cross',
      'Top and bottom chords that run parallel never meet, so no pivot '
          'works. Add up the up-and-down forces instead, which is why the '
          'diagonals are said to carry the shear.',
    ),
  ],
  spoken: [
    (
      'The pivot',
      r'\sum M_{point} = 0',
      'everything turning about your chosen point adds up to nothing',
    ),
    (
      'For a chord',
      r'\text{pivot where the other two meet}',
      'so those two drop out of the sum',
    ),
    (
      'For a diagonal',
      r'\sum F_y = 0',
      'the up and down forces add up to nothing',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const jointForceBrief = BriefSection(
  title: 'The slanted bar is always bigger than the load',
  picture: jointForcePicture,
  steps: [
    (
      'Only the slanted bar points upward',
      'At a joint with a weight hanging on it, the flat bars are horizontal '
          'and hold nothing up. The whole weight has to be carried by the '
          'slanted one.',
    ),
    (
      'A slanted bar only spends part of itself going up',
      'Pull a rope at an angle and only some of that pull is lifting; the '
          'rest is dragging sideways. So the bar has to pull HARDER than the '
          'weight to get enough lift out of it.',
    ),
    (
      'How much harder is the angle',
      'A steep bar is nearly all lift, so it barely notices. A flat bar is '
          'nearly all sideways, so it needs an enormous pull for the same lift. '
          'At 45 degrees it is about 1.4 times the load.',
    ),
    (
      'Which is why trusses are deep',
      'Flatten the bar toward horizontal and the force runs away toward '
          'enormous. Depth costs material and buys steep bars, and steep bars '
          'work far less hard.',
    ),
  ],
  spoken: [
    (
      'The slanted bar',
      r'F = \frac{P}{\sin\theta}',
      'the load, divided by how much of the bar points upward',
    ),
    ('The flat bar', r'F\cos\theta', 'what is left over, pulling sideways'),
    ('Always', r'F > P', 'the bar force beats the load, every time'),
  ],
  handbook: 'Handbook p. 271',
);

const unitLoadBrief = BriefSection(
  title: 'The pretend load that asks your question',
  picture: unitLoadPicture,
  steps: [
    (
      'You want to know how far one spot moves',
      'The structure is already carrying its real load and bending a little. '
          'The question is how far one particular point has moved.',
    ),
    (
      'Ask by putting a 1 there',
      'Put a pretend force of exactly 1 at that spot, pointing the way you '
          'are measuring. It is not a real load. It is the question, written so '
          'the equation can answer it.',
    ),
    (
      'Match what you are asking for',
      'Want a movement, use a unit FORCE. Want a turn, use a unit MOMENT. '
          'Want a sideways answer, point it sideways. A downward 1 will never '
          'tell you how far something moved sideways.',
    ),
    (
      'Run it on its own',
      'Take every real load OFF and work the structure again with just the 1 '
          'on it. Real loads give one set of bar forces, the 1 gives another, '
          'and the formula multiplies them together afterward.',
    ),
  ],
  spoken: [
    (
      'A truss',
      r'\delta = \sum \frac{n N L}{A E}',
      'for every bar: the pretend force times the real force times the length, over area times stiffness',
    ),
    (
      'A beam or frame',
      r'\delta = \int \frac{m M}{E I}\,dx',
      'the same idea, added up along the length instead of bar by bar',
    ),
    (
      'For a turn',
      r'\text{a unit moment, not a unit force}',
      'ask with a twist if you want a twist',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const termSignBrief = BriefSection(
  title: 'Most terms are zero, and the signs do the rest',
  picture: termSignPicture,
  steps: [
    (
      'One line per bar',
      'The sum has one term for every bar in the truss. That sounds like a '
          'lot of work, and most of it is not work at all.',
    ),
    (
      'Either zero kills the term',
      'A bar the pretend load never reaches contributes nothing, however '
          'hard it is really working. A bar doing nothing in the real structure '
          'contributes nothing either. Cross both kinds off first.',
    ),
    (
      'What is left is decided by agreement',
      'If both forces are pulls, or both are pushes, they agree and the term '
          'adds. One of each disagrees and the term takes away. Two pushes still '
          'agree, which is the one that catches people.',
    ),
    (
      'A negative total is an answer',
      'If everything adds up to a negative number, nothing is wrong. It '
          'means the point moved the OPPOSITE way to the direction you pointed '
          'your 1.',
    ),
  ],
  spoken: [
    (
      'One term',
      r'\frac{n N L}{A E}',
      'pretend force times real force times length, over area times stiffness',
    ),
    (
      'Drops out',
      r'n = 0 \;\text{ or }\; N = 0',
      'either force being zero makes the whole term zero',
    ),
    ('They agree', r'nN > 0', 'both pulling or both pushing, so the term adds'),
  ],
  handbook: 'Handbook p. 271',
);

const redundantBrief = BriefSection(
  title: 'Let one support go, then make it pay its way back',
  picture: redundantPicture,
  steps: [
    (
      'Too many supports for statics',
      'Statics gives you three equations. A structure with more unknown '
          'reactions than that cannot be finished by statics alone, however long '
          'you stare at it.',
    ),
    (
      'So take one away',
      'Pick a support and imagine removing it. What is left has to be '
          'something statics CAN finish, standing up on its own. Carry the '
          'removed force along as an unknown.',
    ),
    (
      'Then remember what that support was doing',
      'The real support held that point still. So once you add the unknown '
          'force back, the movement there has to come out to zero. That is your '
          'extra equation, and it is exactly the one you were short.',
    ),
    (
      'Any choice works',
      'You may release whichever support you like and the final answer comes '
          'out the same, so pick the one whose movement is easiest to work out. '
          'After that it is ordinary statics.',
    ),
  ],
  spoken: [
    (
      'How many short',
      r'DSI = (\text{unknowns}) - 3',
      'the unknowns beyond the three statics gives you',
    ),
    (
      'A released support',
      r'\delta = 0',
      'the point it held has to end up where it started',
    ),
    (
      'A released built-in end',
      r'\theta = 0',
      'the end it held has to end up with no turn in it',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const fixityBrief = BriefSection(
  title: 'Stiff ends take a share of everything',
  picture: fixityPicture,
  steps: [
    (
      'Two ways to hold a beam',
      'A simple support lets the beam tip freely at its end, like a plank on '
          'two bricks. A built-in end grips it, so the beam has to leave the '
          'wall dead level.',
    ),
    (
      'Load goes where the stiffness is',
      'Gripping an end makes it stiff, and load drifts toward whatever is '
          'stiff. A propped beam gives its prop three eighths of the load where '
          'a simple support would take a half.',
    ),
    (
      'Bending moves the same way',
      'A simple end carries no bending at all. A built-in end carries '
          'plenty, and every bit it takes comes out of the middle. Build both '
          'ends in and the middle drops to a third of what a simple span has.',
    ),
    (
      'And it sags far less',
      'Same load, same span, a fifth of the sag. What fixity does NOT change '
          'is the up and down split on a symmetric beam: still half at each end.',
    ),
  ],
  spoken: [
    (
      'The prop',
      r'R = \frac{3wL}{8}',
      'three eighths of the load, not the half a simple support would take',
    ),
    (
      'A built-in end',
      r'M = \frac{wL^2}{12}',
      'load times span squared, over twelve',
    ),
    (
      'A simple span middle',
      r'M = \frac{wL^2}{8}',
      'load times span squared, over eight',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const lrfdBrief = BriefSection(
  title: 'Two routes to the same safety margin',
  picture: lrfdPicture,
  steps: [
    (
      'You want a gap between load and strength',
      'The beam must be stronger than what it carries, with room to spare. '
          'There are two ways to buy that room, and the codes allow either.',
    ),
    (
      'Push the loads up',
      'LRFD multiplies the loads bigger before comparing. Dead weight gets '
          '1.2 because we know it well. Floor live load gets 1.6 because it is a '
          'guess about how people will use the place.',
    ),
    (
      'Or cut the strength down',
      'Allowable stress design takes the loads exactly as they come and '
          'divides the strength instead by a safety factor. Same idea, other '
          'end.',
    ),
    (
      'Never half of each',
      'Factor the loads AND divide the strength and the beam pays twice, '
          'coming out absurdly heavy. Use real loads against an undivided '
          'strength and it pays nothing. Read the question and pick one route.',
    ),
  ],
  spoken: [
    (
      'LRFD',
      r'1.2D + 1.6L \le \phi R_n',
      'loads pushed up, against the strength cut down',
    ),
    (
      'ASD',
      r'D + L \le R_n / \Omega',
      'loads as they come, against the strength divided',
    ),
    (
      'Why 1.2 and 1.6',
      r'\text{how well the load is known}',
      'the better we know a load, the smaller its factor',
    ),
  ],
  handbook: 'Handbook, design loads',
);

const controlsBrief = BriefSection(
  title: 'The big multiplier belongs on the big load',
  picture: controlsPicture,
  steps: [
    (
      'Several recipes, one winner',
      'The code lists a few combinations of loads and you design for '
          'whichever comes out biggest. You can usually see which that is '
          'without adding anything up.',
    ),
    (
      'Each recipe aims its 1.6 somewhere',
      'One combination puts the 1.6 on the FLOOR live load and takes the '
          'roof load along at half. Another puts the 1.6 on the ROOF load and '
          'takes the floor load at face value.',
    ),
    (
      'So look at which load is biggest',
      'Whichever combination points its 1.6 at the load that is actually the '
          'large one wins. A busy office floor picks the floor recipe; a snowy '
          'roof over an empty attic picks the roof one.',
    ),
    (
      'And the dead-only one',
      'A third recipe is just 1.4 times the dead weight. It only wins when '
          'there is barely any live load for the 1.6 to work on, like a heavy '
          'slab carrying almost nothing.',
    ),
  ],
  spoken: [
    (
      'Dead only',
      r'1.4D',
      'one and four tenths of the weight of the building itself',
    ),
    (
      'Floor load leading',
      r'1.2D + 1.6L + 0.5S',
      'the big multiplier on the floor live load',
    ),
    (
      'Roof load leading',
      r'1.2D + 1.6S + L',
      'the big multiplier on the snow or roof load instead',
    ),
  ],
  handbook: 'Handbook, design loads',
);

const reductionBrief = BriefSection(
  title: 'A big floor is never crowded everywhere at once',
  picture: reductionPicture,
  steps: [
    (
      'The design load is a crowded-room number',
      'The code load per square foot assumes that patch of floor is busy. '
          'One small room really can be that busy all over.',
    ),
    (
      'A whole floor cannot be',
      'The more floor a beam or column carries, the smaller the chance every '
          'square foot of it is packed at the same moment. So the code lets you '
          'take some of the load off.',
    ),
    (
      'A column gets the bigger cut',
      'The rule multiplies the floor area by 4 for a column and 2 for a '
          'beam, because that is roughly how much floor can reach each of them. '
          'Same bay, bigger reduction for the column.',
    ),
    (
      'Three things bound it',
      'It never becomes an increase. It stops at half the full load for one '
          'floor, four tenths for several. And it touches live load only: the '
          'slab still weighs what it weighs.',
    ),
  ],
  spoken: [
    (
      'The rule',
      r'L = L_o\left(0.25 + \frac{15}{\sqrt{K_{LL} A_T}}\right)',
      'the full load, cut down by a factor that shrinks as the area grows',
    ),
    (
      'The element factor',
      r'K_{LL} = 4 \text{ column}, \; 2 \text{ beam}',
      'four for a column, two for a beam',
    ),
    (
      'The floor under it',
      r'L \ge 0.50 L_o',
      'never below half the full load, for a member carrying one floor',
    ),
  ],
  handbook: 'Handbook, design loads',
);

const influenceBrief = BriefSection(
  title: 'One spot, watched while a wheel drives past',
  picture: influencePicture,
  steps: [
    (
      'A truck drives over a bridge',
      'As it rolls along, the bending at any one point on the bridge goes '
          'up, peaks, and comes back down. Nothing about the bridge changed. The '
          'truck just moved.',
    ),
    (
      'So pick one spot and watch it',
      'An influence line is the record of what THAT one spot feels, for '
          'every position the wheel could be in. Across the bottom is where the '
          'wheel is standing. The height is what your spot feels.',
    ),
    (
      'Which is backwards from every other diagram',
      'A shear or moment diagram fixes the loads and reads along the beam. '
          'An influence line fixes the SPOT and reads along all the load '
          'positions. The two look almost identical, which is the trap.',
    ),
    (
      'Reading a real load off it',
      'The line is drawn for a wheel weighing 1. A real wheel is just its '
          'own weight times the height under it, and several wheels add up.',
    ),
  ],
  spoken: [
    (
      'Using it',
      r'R = \sum P_i \, \eta_i',
      'each load times the height of the line beneath it, added up',
    ),
    (
      'A spread load',
      r'\text{the area under the line beneath it}',
      'not a height but an area, for a load covering a stretch',
    ),
    (
      'Across the bottom',
      r'\text{where the moving load stands}',
      'never where you are measuring',
    ),
  ],
  handbook: 'Handbook, influence lines',
);

const shapesBrief = BriefSection(
  title: 'Three shapes, and nothing else on a simple span',
  picture: shapesPicture,
  steps: [
    (
      'They are all made of straight pieces',
      'On a beam held at both ends every influence line in this lesson is '
          'straight lines. No curves to remember, and only three shapes in the '
          'whole lesson.',
    ),
    (
      'A reaction is a ramp',
      'Stand the wheel right on top of a support and that support carries '
          'all of it, so the line reads 1 there. Stand it on the far support and '
          'this one carries none. Straight line between.',
    ),
    (
      'A moment is a triangle',
      'It peaks over the spot you are watching and falls to nothing at both '
          'supports. When the spot is the middle, the peak is a quarter of the '
          'span.',
    ),
    (
      'A shear has a STEP in it',
      'Two sloping pieces with a sudden jump of exactly 1 where your spot '
          'is, because the wheel crossing your cut switches sides all at once. '
          'The step is how you tell a shear line from a moment line.',
    ),
  ],
  spoken: [
    (
      'A reaction',
      r'\eta = \frac{L - x}{L}',
      'one at its own support, sloping down to nothing at the other',
    ),
    (
      'A moment at a spot',
      r'\eta_{peak} = \frac{a(L-a)}{L}',
      'the two distances to the supports, multiplied, over the span',
    ),
    (
      'A shear at a spot',
      r'1 - \frac{a}{L} \;\text{ and }\; -\frac{a}{L}',
      'the two sides of the step, which always differ by exactly one',
    ),
  ],
  handbook: 'Handbook, influence lines',
);

const placeBrief = BriefSection(
  title: 'Park the load where the line is tallest',
  picture: placePicture,
  steps: [
    (
      'The real question is where to stand the truck',
      'You rarely have to draw the line for its own sake. You have to say '
          'where the moving load does the most damage, and the line tells you.',
    ),
    (
      'The effect is load times height',
      'So the worst place is wherever the line is tallest. For a moment that '
          'means over the spot itself, wherever the spot happens to be, and not '
          'at midspan out of habit.',
    ),
    (
      'For shear, mind the step',
      'The line has a jump at your spot. Just to one side the height is '
          'positive and just to the other it is negative, so a few feet of '
          'parking decides which way the load works.',
    ),
    (
      'Several loads cannot all have the peak',
      'Put the HEAVIEST one on the peak and let the rest fall where they '
          'fall. Sharing the peak fairly gives every load a middling height and '
          'is worth less than that.',
    ),
  ],
  spoken: [
    (
      'One load',
      r'\text{on the peak}',
      'right on the tallest point of the line',
    ),
    (
      'Several loads',
      r'\text{the heaviest on the peak}',
      'the big one gets the tall spot',
    ),
    (
      'A spread load',
      r'\text{cover the positive part only}',
      'stop where the line changes side',
    ),
  ],
  handbook: 'Handbook, influence lines',
);

const whichDepthBrief = BriefSection(
  title: 'd is not how tall the beam is',
  picture: whichDepthPicture,
  steps: [
    (
      'Concrete cannot be pulled',
      'Concrete is strong when squashed and nearly useless when pulled. So '
          'steel bars are buried near the bottom, where a sagging beam is being '
          'pulled, and they do the pulling instead.',
    ),
    (
      'What counts is how deep those bars sit',
      'd runs from the top of the beam down to the middle of the steel. It '
          'is the height LESS the cover, less the stirrup, less half a bar. Two '
          'layers of bars make it shorter again.',
    ),
    (
      'Using the height instead flatters everything',
      'Every capacity you work out comes from d, so reaching for the overall '
          'height makes the beam look stronger than it is. That is the mistake '
          'this lesson is about.',
    ),
    (
      'And the lever arm is shorter still',
      'The beam works like a pair of hands, steel pulling low and concrete '
          'pushing high. What counts is the gap BETWEEN them, which is d less '
          'half the squashed block. More steel deepens that block and quietly '
          'shortens the gap.',
    ),
  ],
  spoken: [
    (
      'The effective depth',
      r'd = h - \text{cover} - \text{stirrup} - d_b/2',
      'the height, less everything sitting above the middle of the bars',
    ),
    (
      'The squashed block',
      r'a = \frac{A_s f_y}{0.85 f_c^{\prime} b}',
      'how deep the concrete has to squash to match the pull in the steel',
    ),
    (
      'The pair of hands',
      r'M_n = A_s f_y\left(d - \frac{a}{2}\right)',
      'the pull in the steel, times the gap between the two forces',
    ),
  ],
  handbook: 'Handbook, reinforced concrete',
);

const stirrupBrief = BriefSection(
  title: 'One ladder with four rungs',
  picture: stirrupPicture,
  steps: [
    (
      'Stirrups are the loops round the bars',
      'They are there for shear, the slicing action near the supports, which '
          'cracks concrete on a slant. The loops hold the crack together.',
    ),
    (
      'Measure the demand against what concrete alone gives you',
      'Work out what the concrete can take by itself, then take three '
          'quarters of it, because that is all you are allowed to lean on. That '
          'number marks the rungs.',
    ),
    (
      'Four bands, four answers',
      'Under half of it: no stirrups needed. Between half and all of it: '
          'minimum stirrups, so the beam gives some warning. Above it: stirrups '
          'sized for whatever is left over.',
    ),
    (
      'And a ceiling',
      'Ask the stirrups for more than about four times the concrete share '
          'and the concrete between them crushes no matter how close you space '
          'them. At that point the beam has to get bigger.',
    ),
  ],
  spoken: [
    (
      'What the concrete gives',
      r'V_c = 2\lambda\sqrt{f_c^{\prime}}\, b_w d',
      'two times the root of the concrete strength, times the beam width and depth',
    ),
    (
      'What the stirrups carry',
      r'V_s = \frac{V_u}{\phi} - V_c',
      'the demand divided by the factor, less the concrete share',
    ),
    (
      'How close they go',
      r's = \frac{A_v f_y d}{V_s}',
      'more to carry means tighter spacing',
    ),
  ],
  handbook: 'Handbook, reinforced concrete',
);

const phiBrief = BriefSection(
  title: 'What it can do, and what you may count on',
  picture: phiPicture,
  steps: [
    (
      'Every capacity comes in two versions',
      'The nominal strength is what the section can really reach on a good '
          'day. The design strength is that number cut down, and it is the only '
          'one you are allowed to use.',
    ),
    (
      'How much gets cut depends on the warning',
      'Bending keeps 90 percent, because a properly built beam sags and '
          'cracks visibly long before it goes. Shear keeps only 75, because a '
          'shear failure arrives with no warning at all.',
    ),
    (
      'Margin is bought at both ends',
      'The loads are pushed UP by their factors and the capacity is pulled '
          'DOWN by this one. Together that is the gap between what arrives and '
          'what the beam can take.',
    ),
    (
      'Which is why the stirrup sum is ordered that way',
      'Both the concrete share and the stirrup share are nominal numbers, so '
          'divide the demand by the factor FIRST, then take the concrete off. '
          'Doing it the other way mixes the two scales.',
    ),
  ],
  spoken: [
    (
      'Bending',
      r'\phi M_n \ge M_u, \; \phi = 0.90',
      'ninety percent of what it can bend, against the factored demand',
    ),
    (
      'Shear',
      r'\phi V_n \ge V_u, \; \phi = 0.75',
      'seventy-five percent of what it can shear, because shear gives no warning',
    ),
    (
      'The stirrups',
      r'V_s = \frac{V_u}{\phi} - V_c',
      'divide first, then take the concrete share off',
    ),
  ],
  handbook: 'Handbook, reinforced concrete',
);

const columnFactorBrief = BriefSection(
  title: 'Two multipliers, doing two different jobs',
  picture: columnFactorPicture,
  steps: [
    (
      'Start with the squash load',
      'Add up what the concrete can take on its own area and what the steel '
          'bars can take on theirs. That is the most the column could ever '
          'carry, loaded perfectly down its middle.',
    ),
    (
      'Nothing is ever loaded down its middle',
      'Floors land slightly off center and columns are built slightly out of '
          'plumb. Rather than guess at a bending moment nobody can predict, the '
          'code takes a flat fifth off. That is the 0.80.',
    ),
    (
      'Then the usual cut for safety',
      'On top of that comes the resistance factor, 0.65 for a column with '
          'square ties. It is the smallest in the code, because a column that '
          'crushes takes the floors above it down too.',
    ),
    (
      'A spiral earns better numbers',
      'A spiral wound round the bars confines the core so it holds together '
          'after cracking, which buys warning. Both multipliers improve, to 0.85 '
          'and 0.75. Dropping either one is the wrong answer offered most often.',
    ),
  ],
  spoken: [
    (
      'A tied column',
      r'\phi P_n = 0.80\phi\left[0.85f_c^{\prime}(A_g - A_{st}) + A_{st}f_y\right]',
      'the squash load, times the off-center allowance, times the safety factor',
    ),
    (
      'Tied numbers',
      r'0.80 \text{ and } \phi = 0.65',
      'a fifth off for being off center, then another third off',
    ),
    (
      'Spiral numbers',
      r'0.85 \text{ and } \phi = 0.75',
      'both better, because a spiral holds the core together',
    ),
  ],
  handbook: 'Handbook, reinforced concrete',
);

const steelWindowBrief = BriefSection(
  title: 'Between one per cent and eight',
  picture: steelWindowPicture,
  steps: [
    (
      'A column needs some steel in it',
      'Below about one per cent of the concrete area, the column behaves '
          'like plain concrete the moment any bending arrives, and plain '
          'concrete fails suddenly with nothing to catch it.',
    ),
    (
      'There is also a reason for the minimum you cannot see',
      'Concrete slowly shrinks and creeps under long load, quietly handing '
          'its share over to whatever steel is in there. There has to be enough '
          'steel to take it.',
    ),
    (
      'And a column can hold too much steel',
      'Above eight per cent there is nowhere to put the bars. They cannot be '
          'lapped and wet concrete cannot get down between them, so the cage '
          'that was drawn is not the cage that gets built.',
    ),
    (
      'Check the window first',
      'Both ends count as inside, so exactly one per cent is fine. Most real '
          'columns sit near two. A capacity worked out for a column outside the '
          'window is not a capacity anybody may use.',
    ),
  ],
  spoken: [
    (
      'The ratio',
      r'\rho_g = \frac{A_{st}}{A_g}',
      'the steel area as a share of the whole column area',
    ),
    (
      'The window',
      r'0.01 \le \rho_g \le 0.08',
      'from one per cent up to eight, both ends allowed',
    ),
    (
      'Where most land',
      r'\rho_g \approx 0.02',
      'about two per cent in ordinary work',
    ),
  ],
  handbook: 'Handbook, reinforced concrete',
);

const bracingBrief = BriefSection(
  title: 'The same beam is worth more when it is held',
  picture: bracingPicture,
  steps: [
    (
      'A deep beam can flop sideways',
      'Bend a long ruler on edge and it does not just sag. At some point it '
          'twists and flips sideways. A steel beam does exactly that, and it '
          'happens long before the steel is anywhere near its limit.',
    ),
    (
      'Holding it stops that',
      'Anything that stops the squashed flange from swinging sideways is a '
          'brace. The closer the braces, the less room the beam has to flop, and '
          'the more of its strength it actually reaches.',
    ),
    (
      'Three bands',
      'Braced closer than the first limit, the beam reaches everything it '
          'has and there is no buckling check at all. Between the two limits the '
          'capacity slides down a straight line. Past the second, it flops while '
          'the steel is still springy.',
    ),
    (
      'So the fix is a brace, not a bigger beam',
      'A beam in that last band is being decided by its bracing rather than '
          'its steel. Another brace is cheaper and works better than a heavier '
          'section.',
    ),
  ],
  spoken: [
    (
      'Fully braced',
      r'L_b \le L_p \Rightarrow M_n = M_p = F_y Z_x',
      'braced tightly enough, so it reaches its full plastic strength',
    ),
    (
      'In between',
      r'L_p < L_b \le L_r',
      'the capacity slides down a straight line as the braces spread out',
    ),
    (
      'Past it',
      r'L_b > L_r',
      'it flops sideways while the steel is still springy',
    ),
  ],
  handbook: 'Handbook, steel beams',
);

const modulusBrief = BriefSection(
  title: 'Two moduli for one shape, and they are not swappable',
  picture: modulusPicture,
  steps: [
    (
      'Bend a beam gently and the stress is a wedge',
      'Nothing in the middle, most at the top and bottom faces, straight '
          'between. The moment where the outermost fiber just reaches its limit '
          'uses S, the elastic modulus.',
    ),
    (
      'Keep bending and the yielding spreads inward',
      'The outside cannot take more, so the inside catches up. Eventually '
          'the whole depth is at its limit: half pulling, half pushing, in two '
          'solid blocks instead of a wedge.',
    ),
    (
      'That fully yielded state uses Z',
      'Z is the plastic modulus and it is the bigger of the two, by ten to '
          'fifteen per cent on a rolled shape. The plastic moment is Z times the '
          'yield stress.',
    ),
    (
      'Reaching for the wrong one costs about a tenth',
      'The plastic moment uses Z in BOTH design methods. S belongs where the '
          'steel is still springy, which here means inside the buckling check. '
          'Swapping them looks entirely plausible and is wrong.',
    ),
  ],
  spoken: [
    (
      'Yielded right through',
      r'M_p = F_y Z_x',
      'the yield stress times the plastic modulus',
    ),
    (
      'First yield only',
      r'M_y = F_y S_x',
      'the yield stress times the elastic modulus',
    ),
    (
      'The gap between them',
      r'Z_x \approx 1.1 \text{ to } 1.15\, S_x',
      'Z is about a tenth bigger on a rolled shape',
    ),
  ],
  handbook: 'Handbook, steel beams',
);

const flangeBrief = BriefSection(
  title: 'Hold the flange that is being squashed',
  picture: flangePicture,
  steps: [
    (
      'Only the squashed flange can buckle',
      'The flange being pulled is fine: pulling straightens things. The one '
          'being squashed is the one that wants to swing out sideways and drag '
          'the beam into a twist.',
    ),
    (
      'Which flange that is depends on the bending',
      'Sagging in the middle of a span, the top is squashed. Over an '
          'interior support the beam bends the other way, so the BOTTOM is '
          'squashed.',
    ),
    (
      'So the slab is not always the answer',
      'A concrete slab cast on the top flange braces it continuously for '
          'free, which covers the sagging regions. Over a support it sits '
          'uselessly overhead while the bottom flange needs holding from '
          'underneath.',
    ),
    (
      'A prop is not a brace',
      'Something that merely stops the beam moving down does nothing about '
          'the twist. A brace has to catch the squashed flange sideways.',
    ),
  ],
  spoken: [
    (
      'Sagging',
      r'\text{top flange squashed}',
      'in the middle of a span, so the slab braces it',
    ),
    (
      'Hogging',
      r'\text{bottom flange squashed}',
      'over a support, so the bracing has to go underneath',
    ),
    (
      'Shear is the web',
      r'V_n = 0.6 F_y A_w',
      'six tenths of the yield stress, on the whole depth times the web thickness',
    ),
  ],
  handbook: 'Handbook, steel beams',
);

const axisBrief = BriefSection(
  title: 'Each direction brings its own free length',
  picture: axisPicture,
  steps: [
    (
      'A bare column folds the shallow way',
      'Stand a ruler on end and press. It bows the easy way, across its thin '
          'direction. That is true as long as nothing is holding it, and it is '
          'where most people stop.',
    ),
    (
      'Real buildings hold columns unevenly',
      'A wall or a beam catches a column partway up in ONE direction and '
          'does nothing in the other. A brace shortens the free length for its '
          'own direction and for no other.',
    ),
    (
      'So work out both, separately',
      'Each direction gets its own free length and its own thickness '
          'measure. Whichever comes out with the bigger ratio is the one that '
          'decides the column.',
    ),
    (
      'Which means bracing can stop helping',
      'Halving the shallow free length halves that ratio. Do it enough and '
          'the deep direction takes over, and further bracing the shallow way '
          'buys nothing at all.',
    ),
  ],
  spoken: [
    (
      'Each direction',
      r'\frac{K L}{r}',
      'its own free length, over its own thickness measure',
    ),
    (
      'Which one decides',
      r'\text{the larger ratio}',
      'the column folds whichever way is slenderest',
    ),
    (
      'One brace',
      r'\text{halves } L \text{ for that direction only}',
      'it does nothing for the other way',
    ),
  ],
  handbook: 'Handbook, steel columns',
);

const tableBrief3 = BriefSection(
  title: 'The table has already done the hard part',
  picture: columnTablePicture,
  steps: [
    (
      'There are two formulas, and you need neither',
      'One covers stocky columns that partly squash before they go, the '
          'other slender ones that bow while still springy. The exam does not '
          'want either worked out.',
    ),
    (
      'Look the slenderness up instead',
      'The column table takes how slender the column is and hands back a '
          'design stress directly. Multiply by the area of the column and you '
          'are finished.',
    ),
    (
      'The safety factor is already inside it',
      'That is the trap. Apply the 0.90 again and you take another tenth off '
          'a column that has already paid. The table stress is a design number, '
          'not a raw one.',
    ),
    (
      'Two answers worth recognizing',
      'The yield stress times the area is the squash load, which is the '
          'answer for a column of no length, and the wrong answer offered most '
          'often. And once a column is slender, a stronger grade of steel buys '
          'nothing: bowing depends on stiffness, not strength.',
    ),
  ],
  spoken: [
    (
      'The whole of it',
      r'\phi_c P_n = (\phi_c F_{cr}) A_g',
      'the design stress from the table, times the area of the column',
    ),
    (
      'A column of no length',
      r'F_y A_g',
      'the squash load, which no real column reaches',
    ),
    (
      'The slender branch',
      r'F_e = \frac{\pi^2 E}{(KL/r)^2}',
      'depends on stiffness, so a stronger steel does not help',
    ),
  ],
  handbook: 'Handbook, steel columns',
);

const twoLimitsBrief = BriefSection(
  title: 'Two ways to lose a bar in tension',
  picture: twoLimitsPicture,
  steps: [
    (
      'Pull hard on a bolted steel bar',
      'It can fail in two quite different ways, and both have to be checked. '
          'Whichever gives the smaller answer is what the bar is worth.',
    ),
    (
      'The whole bar stretches out',
      'This one uses the FULL width with nothing taken off for holes, '
          'because a few inches of steel yielding beside a bolt does not lose '
          'anybody a building. It keeps 90 percent.',
    ),
    (
      'Or it tears straight across the holes',
      'This one uses only the steel left between the holes, and the higher '
          'breaking stress. It keeps just 75 percent, because a tear arrives '
          'with no warning.',
    ),
    (
      'Do not assume the first one wins',
      'The breaking stress is well above the yield stress, so stretching '
          'looks like the obvious answer. But the holes take area away and the '
          'factor is lower, and those two together usually swallow the '
          'difference.',
    ),
  ],
  spoken: [
    (
      'Stretching',
      r'\phi P_n = 0.90 F_y A_g',
      'ninety percent, on the full area and the yield stress',
    ),
    (
      'Tearing',
      r'\phi P_n = 0.75 F_u A_e',
      'seventy-five percent, on the area left between the holes and the breaking stress',
    ),
    (
      'The bar is worth',
      r'\min \text{ of the two}',
      'whichever answer comes out smaller',
    ),
  ],
  handbook: 'Handbook, tension members',
);

const netAreaBrief = BriefSection(
  title: 'The hole costs more width than the bolt fills',
  picture: netAreaPicture,
  steps: [
    (
      'The hole is drilled bigger than the bolt',
      'A sixteenth of an inch of slack so the bolt actually goes in, and '
          'another sixteenth written off because punching tears the steel at the '
          'edge. So a hole costs the bolt size plus an eighth.',
    ),
    (
      'A seven-eighths bolt costs a full inch',
      'That is the arithmetic in one line, and it is the number most often '
          'got wrong by forgetting the extra eighth.',
    ),
    (
      'It comes off the WIDTH, not the area',
      'Subtract the holes from the width first, then multiply by the '
          'thickness. Take them off the area instead and you are wrong by a '
          'factor of the thickness.',
    ),
    (
      'Only holes on the same line across count',
      'Bolts strung out ALONG the pull are on different cross-sections, so '
          'they do not add up. That is much of why connections are made long '
          'rather than wide.',
    ),
  ],
  spoken: [
    (
      'Each hole costs',
      r'd_b + \tfrac{1}{8}\text{ in}',
      'the bolt diameter plus an eighth of an inch',
    ),
    (
      'The area left',
      r'A_n = \left[b_g - \Sigma(d_b + \tfrac{1}{8})\right] t',
      'the width less the holes, all times the thickness',
    ),
    (
      'Where it is used',
      r'\text{the tearing check only}',
      'the stretching check still uses the full area',
    ),
  ],
  handbook: 'Handbook, tension members',
);

const shearLagBrief = BriefSection(
  title: 'Load needs room to spread across',
  picture: shearLagPicture,
  steps: [
    (
      'Grab a towel by one corner and pull',
      'The corner you are holding takes nearly all of it. The far corner '
          'hangs there doing almost nothing, because the pull has not had room '
          'to spread across yet.',
    ),
    (
      'Steel does the same',
      'Bolt an angle through one leg only and the load arrives in that leg. '
          'Right at the connection the other leg has barely joined in, so the '
          'whole area is not really working.',
    ),
    (
      'That is what the factor U is for',
      'U says how much of the area is genuinely pulling. Bolted right across '
          'the width, like a flat bar, U is 1 and there is nothing to allow for. '
          'Through one leg it is less.',
    ),
    (
      'A longer connection fixes it, bigger bolts do not',
      'More length gives the load more room to spread, and U climbs toward '
          '1. Bigger bolts just take more area away. And this belongs to the '
          'tearing check only, never to stretching.',
    ),
  ],
  spoken: [
    (
      'What is really working',
      r'A_e = U A_n',
      'the area between the holes, times how much of it has joined in',
    ),
    (
      'The factor',
      r'U = 1 - \bar{x}/L',
      'one less the reach out to the middle, over the connection length',
    ),
    (
      'A flat bar bolted across',
      r'U = 1.0',
      'all of it pulling, nothing to allow for',
    ),
  ],
  handbook: 'Handbook, tension members',
);

const phaseBrief = BriefSection(
  title: 'Every soil number is one part over another',
  picture: phasePicture,
  steps: [
    (
      'Soil is three things',
      'Dig up a scoop of soil and it is grains of rock, water, and air in '
          'the gaps. Nothing else. The drawing stacks them as three blocks so '
          'you can point at the part you mean.',
    ),
    (
      'Measure it twice',
      'You can measure each block two ways: how much SPACE it takes up, and '
          'how much it WEIGHS. That is why the drawing has a left side and a '
          'right side. Air takes up space and weighs nothing.',
    ),
    (
      'Every property picks two blocks',
      'Void ratio is the empty space over the SOLID space. Porosity is the '
          'same empty space over the WHOLE scoop. Saturation is the water over '
          'the empty space: how full the gaps are.',
    ),
    (
      'Watch which bottom it uses',
      'Void ratio can pass 1, because the gaps can be bigger than the '
          'grains. Porosity never can, since a part cannot beat the whole. '
          'Water content is weighed, not measured, so a soft clay can hold '
          'more than 100 percent.',
    ),
  ],
  spoken: [
    (
      'Void ratio',
      r'e = \frac{V_v}{V_s}',
      'the space in the gaps, over the space the grains take up',
    ),
    (
      'Porosity',
      r'n = \frac{V_v}{V}',
      'the space in the gaps, over the whole scoop',
    ),
    (
      'Water content',
      r'\omega = \frac{W_w}{W_s}',
      'the weight of the water, over the weight of the grains',
    ),
  ],
  handbook: 'Handbook, soil phase relationships',
);

const masterBrief = BriefSection(
  title: 'One line crosses from weighing to measuring',
  picture: masterPicture,
  steps: [
    (
      'Two sides, two habits',
      'Water content comes off a scale: you weigh the wet soil, dry it in '
          'an oven, weigh it again. Void ratio is about space, not weight. A '
          'lab hands you one and a question asks for the other.',
    ),
    (
      'Specific gravity carries you across',
      'Gs says how much heavier a grain is than the same amount of water, '
          'about 2.7 for most soils. Knowing that, a weight of grains tells '
          'you the space they fill, and the two sides connect.',
    ),
    (
      'One line does the whole job',
      'S times e equals w times Gs. Saturation times void ratio, on one '
          'side; water content times specific gravity on the other. Know any '
          'three and the fourth falls out.',
    ),
    (
      'Only assume full when it says so',
      'If the soil is fully wet, S is 1 and the void ratio is just w times '
          'Gs. With air still in the gaps the answer is bigger than that, so '
          'assuming full when it is not makes your answer too small.',
    ),
  ],
  spoken: [
    (
      'The bridge',
      r'S e = \omega G_s',
      'saturation times void ratio equals water content times specific gravity',
    ),
    (
      'Fully wet',
      r'e = \omega G_s',
      'with no air left, the void ratio is just those two multiplied',
    ),
    (
      'Put it in as a decimal',
      r'\omega = 0.20 \text{, not } 20',
      'the formula wants twenty percent written as zero point two',
    ),
  ],
  handbook: 'Handbook, soil phase relationships',
);

const gammaBrief = BriefSection(
  title: 'One soil, four different weights',
  picture: gammaPicture,
  steps: [
    (
      'Weigh a bucket of soil',
      'How heavy is it? It depends what is in the gaps. Wet soil is heavier '
          'than the same soil dried out, because the water weighs something '
          'too. So one soil has several answers.',
    ),
    (
      'Dry is the honest one for packing',
      'Dry weight counts only the grains, spread over the space the scoop '
          'takes up in the ground. It tells you how tightly packed the grains '
          'are, and it does not change with the weather. That is why '
          'compaction is always specified against it.',
    ),
    (
      'Saturated is the heaviest',
      'Same grains, every gap filled with water. Nothing is heavier than '
          'that, because air weighs nothing and water weighs something.',
    ),
    (
      'Submerged is much the lightest',
      'Below the water table, the grains float a little in their own water, '
          'exactly the way you feel lighter in a swimming pool. What they '
          'press down with is the saturated weight less the weight of water, '
          'roughly half. Forget this and every stress below the water table '
          'comes out too big.',
    ),
  ],
  spoken: [
    (
      'Dry, from total',
      r'\gamma_d = \frac{\gamma}{1+\omega}',
      'the weight as it stands, divided by one plus the water content',
    ),
    (
      'Saturated',
      r'\gamma_{sat} = \frac{(G_s + e)\gamma_w}{1+e}',
      'grains plus full gaps, spread over the whole scoop',
    ),
    (
      'Submerged',
      r"\gamma' = \gamma_{sat} - \gamma_w",
      'the saturated weight, less the weight of water it floats in',
    ),
  ],
  handbook: 'Handbook, soil phase relationships',
);

const forkBrief = BriefSection(
  title: 'The first sieve asks the first question',
  picture: forkPicture,
  steps: [
    (
      'Shake it through a stack of sieves',
      'Pour dry soil into a stack of screens, coarse on top, fine at the '
          'bottom, and shake. Weighing what lands on each screen tells you '
          'what sizes the soil is made of.',
    ),
    (
      'One screen splits the whole world',
      'The No 200 screen has holes too small to see. If most of the soil '
          'stays on top of it, the soil is COARSE: sand and gravel. If most '
          'goes through, it is FINE: silt and clay.',
    ),
    (
      'The two halves are judged differently',
      'A coarse soil is judged on the shape of its size curve. A fine soil '
          'is judged by how it behaves when wet, on a chart of its own. Take '
          'the wrong branch and every careful step after it answers a '
          'different question.',
    ),
    (
      'Coarse then splits again',
      'The No 4 screen is about the size of a pencil lead. Most of the '
          'coarse part through it means sand; most held back means gravel. '
          'It matters: a gravel needs a spread of 4 where a sand needs 6.',
    ),
  ],
  spoken: [
    (
      'First',
      r'\text{No 200: coarse or fine}',
      'more than half held back and the soil is coarse',
    ),
    (
      'Then',
      r'\text{No 4: gravel or sand}',
      'most of the coarse part held back and it is gravel',
    ),
    (
      'Fine soils',
      r'\text{go to the plasticity chart}',
      'their grain sizes stop mattering from there on',
    ),
  ],
  handbook: 'Handbook, soil classification',
);

const chartBrief = BriefSection(
  title: 'Two lines, four corners',
  picture: chartPicture,
  steps: [
    (
      'Two numbers off a wet soil',
      'Add water to a fine soil and at some point it flows like a liquid: '
          'that water content is the LIQUID LIMIT. Take water away and at some '
          'point it stops being moldable. The gap between the two is the '
          'PLASTICITY INDEX, how wide a range of wetness it stays like putty '
          'over.',
    ),
    (
      'Plot the point',
      'Liquid limit across the bottom, plasticity index up the side. Every '
          'fine soil in the world is one dot on this chart.',
    ),
    (
      'The sloping line splits clay from silt',
      'Above it the soil is a CLAY: it grips its water and keeps moving for '
          'years. Below it the soil is a SILT: it drains and settles fast. '
          'That line is about behavior, not about names.',
    ),
    (
      'The upright line at 50 splits low from high',
      'Left of it is low plasticity, right is high. Four corners, four '
          'symbols: CL, CH, ML, MH. The forgotten one is MH, a soil that '
          'holds a lot of water and is still not a clay.',
    ),
  ],
  spoken: [
    (
      'The sloping line',
      r'PI = 0.73(LL - 20)',
      'the boundary between clay above and silt below',
    ),
    ('Above it', r'\text{C, a clay}', 'the first letter of the symbol'),
    (
      'Past a liquid limit of 50',
      r'\text{H, high plasticity}',
      'the second letter of the symbol',
    ),
  ],
  handbook: 'Handbook, soil classification',
);

const gradationBrief = BriefSection(
  title: 'Both checks pass, or the soil is poorly graded',
  picture: gradationPicture,
  steps: [
    (
      'Why a mix of sizes is better',
      'Fill a jar with marbles and it is mostly gaps. Pour sand in and the '
          'sand fills the gaps, then dust fills the gaps in the sand. A soil '
          'with every size in it packs tight and strong. That is what WELL '
          'GRADED means.',
    ),
    (
      'The first check: is the range wide',
      'Take the size that 60 percent of the soil is finer than, and divide '
          'by the size 10 percent is finer than. A big answer means a wide '
          'spread of sizes. A gravel needs 4, a sand needs 6.',
    ),
    (
      'The second check: is the middle there',
      'A soil can have big grains and dust and nothing in between. The '
          'second number catches that, and it has to land between 1 and 3. '
          'A soil that fails it is GAP graded and packs like neither half.',
    ),
    (
      'One failure is enough',
      'Both checks must pass. A huge first number is exactly what tempts '
          'people into calling a soil well graded when its middle is missing.',
    ),
  ],
  spoken: [
    (
      'Is the range wide',
      r'C_u = \frac{D_{60}}{D_{10}}',
      'the bigger size divided by the smaller: 4 for gravel, 6 for sand',
    ),
    (
      'Is the middle there',
      r'C_c = \frac{D_{30}^2}{D_{10} D_{60}}',
      'the middle size squared, over the other two multiplied: 1 to 3',
    ),
    (
      'Well graded means',
      r'\text{both, or it counts as neither}',
      'one pass and one failure is still poorly graded',
    ),
  ],
  handbook: 'Handbook, soil classification',
);

const threeStressBrief = BriefSection(
  title: 'Three stresses at every point',
  picture: threeStressPicture,
  steps: [
    (
      'Stand at the bottom of a hole',
      'Everything above you presses down: the grains, the water in their '
          'gaps, and anything piled on the surface. Add up all that weight '
          'over one square foot and you have the TOTAL stress.',
    ),
    (
      'Water pushes back on its own',
      'Below the water table the pore water has its own pressure, and it '
          'is just the depth of water above you times how much water weighs. '
          'Above the water table there is none.',
    ),
    (
      'What is left is what the grains feel',
      'Take the water pressure off the total and the rest is carried grain '
          'on grain. That is the EFFECTIVE stress, and it is the one that '
          'matters: how strong the soil is and how much it settles both '
          'follow from it and from nothing else.',
    ),
    (
      'A load on top shows the difference',
      'Pile fill on the surface and the total goes up by its full weight. '
          'The water pressure does not notice. So all of it lands on the '
          'grains.',
    ),
  ],
  spoken: [
    (
      'The whole of it',
      r"\sigma' = \sigma - u",
      'what the grains feel is the total, less the water pressure',
    ),
    (
      'Water pressure',
      r'u = h_w \gamma_w',
      'the depth below the water table, times the weight of water',
    ),
    (
      'Above the water table',
      r"u = 0, \; \sigma' = \sigma",
      'no water pressure, so the grains carry all of it',
    ),
  ],
  handbook: 'Handbook, effective stress',
);

const waterTableBrief = BriefSection(
  title: 'Move the water and the grains feel it',
  picture: waterTablePicture,
  steps: [
    (
      'Pump the water down',
      'The weight above hardly changes, but the water pressure drops. The '
          'grains have to take up the slack, so what they feel goes UP. The '
          'ground settles. That is why pumping on one site can crack a '
          'building on the next one.',
    ),
    (
      'Let the water rise',
      'Now the grains float a little more and what they feel goes DOWN. '
          'Soil is weaker when the grains press together less, which is why a '
          'slope that stood all summer can slide after a week of rain.',
    ),
    (
      'Pile something on top',
      'A surcharge adds its full weight to the total and nothing to the '
          'water, so every pound of it lands on the grains. Engineers do this '
          'on purpose: pile fill on soft ground, wait for it to settle, take '
          'the fill away.',
    ),
    (
      'Flood an already wet site',
      'Standing water adds the same amount to the total AND to the water '
          'pressure. The subtraction cancels it out, so the grains feel '
          'nothing at all.',
    ),
  ],
  spoken: [
    (
      'Pump it down',
      r"u \text{ falls, } \sigma' \text{ rises}",
      'less water pressure, so the grains carry more',
    ),
    (
      'A load on top',
      r"\Delta\sigma' = q",
      'all of a surcharge lands on the grains',
    ),
    (
      'Standing water over a wet site',
      r"\Delta\sigma' = 0",
      'it lifts both sides of the subtraction equally',
    ),
  ],
  handbook: 'Handbook, effective stress',
);

const shortWayBrief = BriefSection(
  title: 'Walk down the layers, float the wet ones',
  picture: shortWayPicture,
  steps: [
    (
      'The long way round',
      'Add up the weight of everything above to get the total, then work '
          'out the water pressure, then subtract. It works, and it is two '
          'sums where one would do.',
    ),
    (
      'The short way',
      'Walk down layer by layer and add each one straight onto the running '
          'total. Above the water table use the layer as it weighs. Below it '
          'use the floating weight, which is about half.',
    ),
    (
      'Why they agree',
      'Taking the water pressure off at the end is the same as taking one '
          'foot of water off every foot of drowned soil on the way down. Same '
          'subtraction, done earlier.',
    ),
    (
      'Two ways to get it wrong',
      'Never float a layer that sits ABOVE the water table: there is no '
          'water up there holding anything up. And never float a load piled '
          'on the surface, because the water does not notice it.',
    ),
  ],
  spoken: [
    (
      'Above the water table',
      r'\gamma H',
      'the layer as it weighs, times how thick it is',
    ),
    (
      'Below it',
      r"\gamma' H = (\gamma_{sat} - \gamma_w) H",
      'the floating weight, times how thick it is',
    ),
    (
      'A load on top',
      r'q \text{, in full}',
      'never floated, whatever is underneath',
    ),
  ],
  handbook: 'Handbook, effective stress',
);

const caseBrief = BriefSection(
  title: 'Everything turns on what the clay remembers',
  picture: casePicture,
  steps: [
    (
      'Clay remembers being squeezed',
      'Squeeze a clay hard once and it packs down. Take the load off and it '
          'barely springs back. Put the same load on again and it hardly '
          'moves, because it has been there before. The biggest squeeze it '
          'ever had is its memory.',
    ),
    (
      'Three things to line up',
      'Where the clay is now, what it remembers, and where the new load '
          'takes it. The drawing puts all three on one line. Everything else '
          'follows from which side of the memory the load lands on.',
    ),
    (
      'Under the memory, or past it',
      'Land short of the memory and the whole move is over old ground, so '
          'use the stiff number. Start at the memory and every pound is new '
          'ground, so use the soft number, about six times bigger.',
    ),
    (
      'Crossing needs two sums',
      'If the load starts below the memory and ends above it, split the '
          'move: stiff up to the memory, soft from there on. Running a '
          'crossing move on one number alone is the answer the exam offers '
          'most often.',
    ),
  ],
  spoken: [
    (
      'Under the memory',
      r'\Delta H = \frac{H_0}{1+e_0} C_r \log\frac{p_1}{p_0}',
      'the stiff index, over the ratio of the two pressures',
    ),
    (
      'Past the memory',
      r'\Delta H = \frac{H_0}{1+e_0} C_c \log\frac{p_1}{p_0}',
      'the same sum with the soft index instead',
    ),
    (
      'Crossing it',
      r'C_r \log\frac{p_c}{p_0} + C_c \log\frac{p_1}{p_c}',
      'stiff up to the memory, then soft the rest of the way',
    ),
  ],
  handbook: 'Handbook, consolidation',
);

const memoryBrief = BriefSection(
  title: 'A shallow line, a corner, a steep one',
  picture: memoryPicture,
  steps: [
    (
      'Squeeze a clay and watch the gaps close',
      'Plot how much empty space is left against how hard you are pressing. '
          'A clay draws two straight lines with a sharp corner between them.',
    ),
    (
      'The corner is the memory',
      'Left of the corner the clay is going back over ground it has covered '
          'before, and it goes stiffly. Right of it the clay is doing '
          'something new and the grains shuffle in earnest.',
    ),
    (
      'Six times is the difference',
      'The soft slope is about six times the stiff one. So the same load on '
          'the same clay can settle six times as much depending only on which '
          'side of the corner it lands. That is why a lab test to find the '
          'corner is worth paying for.',
    ),
    (
      'Equal ratios settle equally',
      'The sum uses a log, so going from 1 to 2 tons settles as much as '
          'going from 2 to 4. The first few hundred pounds on a lightly '
          'loaded clay cost far more than the same few hundred added later.',
    ),
  ],
  spoken: [
    (
      'The two slopes',
      r'C_r \approx C_c / 6',
      'the stiff one is about a sixth of the soft one',
    ),
    (
      'From the lab limits',
      r'C_c \approx 0.009(LL - 10)',
      'an estimate of the soft slope from the liquid limit',
    ),
    (
      'Equal ratios',
      r'\log\frac{2p}{p} = \log\frac{4p}{2p}',
      'doubling costs the same settlement wherever you start',
    ),
  ],
  handbook: 'Handbook, consolidation',
);

const drainageBrief = BriefSection(
  title: 'How far the water has to travel',
  picture: drainagePicture,
  steps: [
    (
      'Settling is water leaving',
      'A clay settles by squeezing water out of its gaps. Clay is nearly '
          'watertight, so the water leaves slowly. How LONG that takes is a '
          'different question from how MUCH it settles.',
    ),
    (
      'Find the longest journey',
      'With sand above and below, the unluckiest drop is in the middle and '
          'can go either way, so it travels half the layer. With rock '
          'underneath it can only go up, so it travels the whole layer.',
    ),
    (
      'The time goes as the SQUARE',
      'Double the journey and the wait is four times as long, not twice. So '
          'one sealed face makes it four times slower, and so does doubling '
          'the thickness.',
    ),
    (
      'That square is why sand drains work',
      'Punch vertical sand drains through the clay and the water only has '
          'to reach the nearest one. Cut the journey to a tenth and the wait '
          'falls to a hundredth. A bigger load does not change the schedule '
          'at all: it settles further, not slower.',
    ),
  ],
  spoken: [
    (
      'The time',
      r't = \frac{T_v H_{dr}^2}{c_v}',
      'the journey squared, over how fast that clay lets water through',
    ),
    (
      'Draining both ways',
      r'H_{dr} = H/2',
      'the longest journey is half the layer',
    ),
    (
      'One face sealed',
      r'H_{dr} = H',
      'the whole layer, so four times the wait',
    ),
  ],
  handbook: 'Handbook, consolidation',
);

const mohrCoulombBrief = BriefSection(
  title: 'A constant, plus whatever pressing buys',
  picture: mohrCoulombPicture,
  steps: [
    (
      'Two ways soil resists sliding',
      'Wet sand sticks together a little: that is COHESION, and it is there '
          'whether or not anything is pressing. Rub two hands together and '
          'press harder and they grip harder: that is FRICTION, and it grows '
          'with the press.',
    ),
    (
      'Clean sand is friction only',
      'Its line starts at nothing. At the surface a dry sand has no strength '
          'at all, which is why you cannot dig a vertical face in it. Thirty '
          'feet down the same sand is strong, because everything above is '
          'pressing.',
    ),
    (
      'A clay loaded fast is cohesion only',
      'Squeeze a wet clay quickly and the water cannot get out, so the '
          'squeeze goes into the water, not the grains. Pressing harder buys '
          'nothing. Its line is flat, and one number describes the layer.',
    ),
    (
      'Most soils have some of each',
      'A line that starts above zero AND slopes up. The two are simply '
          'added.',
    ),
  ],
  spoken: [
    (
      'The rule',
      r"\tau_f = c' + \sigma_N' \tan\phi'",
      'the constant part, plus what the grains feel times the slope',
    ),
    (
      'A clean sand',
      r"c' = 0",
      'no constant part, so the line starts at the corner',
    ),
    (
      'A clay loaded fast',
      r'\phi_u = 0, \; \tau_f = c_u',
      'no slope, so the strength is one number',
    ),
  ],
  handbook: 'Handbook, shear strength',
);

const drainedBrief = BriefSection(
  title: 'It is a question about time, not about soil',
  picture: drainedPicture,
  steps: [
    (
      'Water needs time to leave',
      'Load a wet clay and the squeeze lands on the pore water first. Given '
          'months the water seeps away and the grains take over. Given a day, '
          'it does not.',
    ),
    (
      'So there are two sets of numbers',
      'The SLOW set goes with what the grains feel, and describes the soil '
          'once the water has moved. The FAST set is a single strength with no '
          'slope, and describes a clay loaded quicker than its water can '
          'escape.',
    ),
    (
      'Which one depends on the calendar',
      'A tank filled in a day is a fast problem. The same tank twenty years '
          'later is a slow one. And the clay is STRONGER in the second, which '
          'is the opposite of how most materials age.',
    ),
    (
      'Never mix the sets',
      'Take a slope from one set and a stress from the other and you '
          'overstate the strength. Sand drains as fast as you can load it, so '
          'its fast case never really happens.',
    ),
  ],
  spoken: [
    (
      'Long term',
      r"c', \phi' \text{ with } \sigma'",
      'the slow numbers go with what the grains feel',
    ),
    (
      'Short term',
      r'c_u, \phi_u = 0 \text{ with } \sigma',
      'the fast number goes with the whole weight above',
    ),
    (
      'The fast strength',
      r'c_u = \frac{\sigma_1 - \sigma_3}{2}',
      'half the difference between the two test pressures',
    ),
  ],
  handbook: 'Handbook, shear strength',
);

const mohrCircleBrief = BriefSection(
  title: 'What the test circle tells you',
  picture: mohrCirclePicture,
  steps: [
    (
      'Squeeze a sample until it fails',
      'A triaxial test holds a soil sample at one pressure all round, then '
          'presses down harder on top until it gives way. That gives two '
          'numbers: the pressure round it and the extra on top.',
    ),
    (
      'Those two numbers make a circle',
      'The MIDDLE of the circle is their average. The RADIUS is half their '
          'difference. Every point on the rim is the push and the slide on '
          'some plane through the sample.',
    ),
    (
      'Where it touches is where it broke',
      'The circle grows until it touches the strength line. That touching '
          'point is the plane that actually failed.',
    ),
    (
      'Two readings that trip people',
      'A flat line touches the circle at the TOP, one radius up, so the fast '
          'strength is HALF the extra you pushed with, not all of it. And for '
          'a soil with no constant part the SINE of the slope angle is the '
          'radius over the middle, not the tangent.',
    ),
  ],
  spoken: [
    (
      'Middle and radius',
      r's = \frac{\sigma_1+\sigma_3}{2}, \; t = \frac{\sigma_1-\sigma_3}{2}',
      'the average of the two, and half their difference',
    ),
    (
      'No constant part',
      r'\sin\phi = t/s',
      'the radius over the middle gives the sine, not the tangent',
    ),
    (
      'Loaded fast',
      r'c_u = t',
      'the strength is the radius, which is half the extra push',
    ),
  ],
  handbook: 'Handbook, shear strength',
);

const flowNetBrief = BriefSection(
  title: 'Two counts, and the fraction the right way up',
  picture: flowNetPicture,
  steps: [
    (
      'Water finds a way under',
      'Stand water higher on one side of a wall and it seeps under, through '
          'the soil. A flow net is a map of that journey, drawn as curved '
          'lanes and the steps across them.',
    ),
    (
      'Count the lanes',
      'Each lane carries the same share of the water, so more lanes means '
          'more water getting through. Careful: the count is one fewer than '
          'the number of lines drawn.',
    ),
    (
      'Count the steps',
      'The water arrives with a certain head and spends it evenly, one step '
          'at a time. Twelve steps across six meters is half a meter each. '
          'More steps means the head is spent more gradually.',
    ),
    (
      'Lanes on top, steps underneath',
      'More lanes, more water. More steps, less water. Turn the fraction '
          'over and the answer is out by a lot. And the net is pure geometry: '
          'a soil ten times leakier gives the same drawing, times ten.',
    ),
  ],
  spoken: [
    (
      'The seepage',
      r'q = k H \frac{N_f}{N_d}',
      'leakiness times head, times lanes over steps',
    ),
    (
      'Each step',
      r'\Delta h = H / N_d',
      'the head, shared out evenly among the steps',
    ),
    (
      'A deeper wall',
      r'N_d \text{ up, } q \text{ down}',
      'a longer journey means more steps and less water',
    ),
  ],
  handbook: 'Handbook, seepage',
);

const quickBrief = BriefSection(
  title: 'When the grains stop pressing at all',
  picture: quickPicture,
  steps: [
    (
      'Water climbing drags on the grains',
      'Push water UP through sand and it tugs every grain it passes, trying '
          'to carry them with it. The harder it climbs, the harder it tugs.',
    ),
    (
      'At some point the tug wins',
      'When the drag matches what the grains weigh underwater, nothing is '
          'left pressing them together. A sand whose strength was all friction '
          'now has none. It behaves like a heavy liquid.',
    ),
    (
      'How steep a climb it takes',
      'The gradient that does it is the floating weight over the weight of '
          'water, which comes out near 1 for most sands. A loose sand boils '
          'sooner, because there is less solid in it to hold down.',
    ),
    (
      'What to do about it',
      'Compare the critical gradient with the real one to get a safety '
          'factor. If it is uncomfortable, make the water travel further, or '
          'put a filter and some weight where it comes out.',
    ),
  ],
  spoken: [
    (
      'The critical gradient',
      r"i_c = \frac{\gamma'}{\gamma_w} = \frac{G_s - 1}{1 + e}",
      'the floating weight over the weight of water',
    ),
    (
      'Safety',
      r'FS = i_c / i_{exit}',
      'the gradient it takes, over the one you have',
    ),
    (
      'At boiling',
      r"\sigma' = 0",
      'the grains are pressing on each other with nothing at all',
    ),
  ],
  handbook: 'Handbook, seepage',
);

const infiniteSlopeBrief = BriefSection(
  title: 'Flatter than its friction angle and it stands',
  picture: infiniteSlopePicture,
  steps: [
    (
      'Pour sand into a heap',
      'It builds up to a certain steepness and then refuses to get any '
          'steeper: fresh sand just runs down the side. That angle is the '
          'friction angle of the sand, and it is a property of the sand.',
    ),
    (
      'So the whole question is two angles',
      'Is the slope flatter than that angle? Then it stands. Steeper? Then '
          'it slides. Nothing else is needed for a dry sandy slope.',
    ),
    (
      'Depth and weight drop out',
      'Cut a deeper slice and it weighs more, which drives it harder. But it '
          'also presses down harder, which grips better. Exactly equally, so '
          'both cancel and the answer is a pair of angles.',
    ),
    (
      'At the angle exactly, it is on the edge',
      'Safety factor of 1 is the angle a poured heap settles at, not a '
          'design. Compacting a sand raises its friction angle, which is most '
          'of why fill gets compacted.',
    ),
  ],
  spoken: [
    (
      'Dry sandy slope',
      r'FS = \frac{\tan\phi}{\tan\beta}',
      'the angle the soil can hold, against the angle it is cut at',
    ),
    (
      'It stands when',
      r'\beta < \phi',
      'the slope is flatter than the friction angle',
    ),
    (
      'What cancels',
      r'\text{depth and unit weight}',
      'neither one appears in the answer',
    ),
  ],
  handbook: 'Handbook, slope stability',
);

const seepageSlopeBrief = BriefSection(
  title: 'Rain halves it',
  picture: seepageSlopePicture,
  steps: [
    (
      'Nothing was added and nothing dug out',
      'The same slope, the same soil, the same angle. It rained, and water is '
          'now running down through it. That alone can take the slope from '
          'safe to gone.',
    ),
    (
      'Why it is so brutal',
      'The full weight still drives the slide. But the grains are now '
          'floating a little, so only the floating weight presses them '
          'together to make friction. Driving unchanged, holding halved.',
    ),
    (
      'Roughly a factor of two',
      'Floating weight over saturated weight is about a half for ordinary '
          'soils. So 1.85 dry becomes about 0.93 wet, which is past failing. '
          'A slope at 1.1 dry has no room at all.',
    ),
    (
      'What to do',
      'Design a cut for the worst week it will ever see, not the day you dug '
          'it. And draining a slope is worth a doubling on its own, which is '
          'why drains go in before anything else.',
    ),
  ],
  spoken: [
    (
      'With water running through',
      r"FS = \frac{\gamma'}{\gamma_{sat}}\cdot\frac{\tan\phi}{\tan\beta}",
      'the dry answer, times the floating weight over the wet weight',
    ),
    (
      'That factor',
      r"\gamma'/\gamma_{sat} \approx 0.5",
      'about a half, for ordinary soils',
    ),
    ('The fix', r'\text{flatten it, or drain it}', 'there are only the two'),
  ],
  handbook: 'Handbook, slope stability',
);

const wedgeBrief = BriefSection(
  title: 'Everything holding, over everything driving',
  picture: wedgePicture,
  steps: [
    (
      'A block on a slope',
      'Put a block on a ramp. Its weight pulls straight down, but the ramp '
          'splits that pull in two: a part sliding it down the slope, and a '
          'part pressing it onto the surface.',
    ),
    (
      'The weight does both jobs',
      'The sliding part drives the failure. The pressing part buys friction, '
          'which resists it. How steep the surface is decides how the weight '
          'is shared out, which is why a steeper slip surface is the '
          'dangerous one.',
    ),
    (
      'Cohesion is a third thing',
      'Sticky soil grips along the whole surface, and that grip owes nothing '
          'to the weight. It depends on how LONG the surface is. That is what '
          'saves shallow slips, where a thin wedge has little friction but '
          'just as much surface.',
    ),
    (
      'Add up each side',
      'Everything resisting on top, everything driving underneath. Forget '
          'the cohesion term and a safety factor of 1.5 becomes 0.8.',
    ),
  ],
  spoken: [
    (
      'What a safety factor is',
      r'FS = \frac{\text{resisting}}{\text{driving}}',
      'everything holding it, over everything pushing it',
    ),
    (
      'For a wedge',
      r'FS = \frac{cL_s + W\cos\alpha\tan\phi}{W\sin\alpha}',
      'grip along the surface plus friction from the press, over the sliding part',
    ),
    (
      'Cohesion',
      r'\text{owes nothing to } W',
      'it comes from the length of the surface, not the weight',
    ),
  ],
  handbook: 'Handbook, slope stability',
);

const terzaghiBrief = BriefSection(
  title: 'Three terms, and what kills each one',
  picture: terzaghiPicture,
  steps: [
    (
      'How a footing fails',
      'Load a footing hard enough and the soil under it squeezes sideways '
          'and heaves up beside it. Three separate things resist that, and the '
          'formula is just those three added.',
    ),
    (
      'The soil sticking to itself',
      'A sticky clay holds together and resists being pushed aside. A clean '
          'sand has none of this, so the first term goes.',
    ),
    (
      'The soil beside the footing',
      'Before the ground can heave up, the soil next to the footing has to '
          'be lifted out of the way. Bury the footing deeper and there is more '
          'of it. Lay it on the surface and this term disappears, which on a '
          'sand is most of the capacity.',
    ),
    (
      'The soil under the footing',
      'The weight of the soil beneath, shearing sideways. For a clay loaded '
          'fast its factor is ZERO, so it contributes nothing however wide the '
          'footing is. The factors themselves are always given.',
    ),
  ],
  spoken: [
    (
      'The whole of it',
      r"q_{ult} = cN_c + \gamma' D_f N_q + \tfrac{1}{2}\gamma' B N_\gamma",
      'sticking, plus soil beside it, plus soil beneath it',
    ),
    (
      'A clay loaded fast',
      r'q_{ult} = 5.14 c_u + \gamma D_f',
      'only the sticking and the depth survive',
    ),
    ('A clean sand', r'c = 0', 'the first term goes entirely'),
  ],
  handbook: 'Handbook, bearing capacity',
);

const footingFixBrief = BriefSection(
  title: 'Widening and burying are not the same fix',
  picture: footingFixPicture,
  steps: [
    (
      'A footing that is not strong enough',
      'You can make it wider, or you can dig it in deeper. Which one helps '
          'depends entirely on what the soil is.',
    ),
    (
      'On sand, both work, burying more',
      'The depth factor is bigger than the width factor, and the width term '
          'gets halved besides. So a spade of depth is worth more than a foot '
          'of width.',
    ),
    (
      'On a clay loaded fast, widening buys nothing',
      'The term that width would have grown has a factor of zero. Widening '
          'still spreads the building load over more ground, which helps the '
          'building, but the ground itself is no stronger.',
    ),
    (
      'Watch the water',
      'Both of those terms are weights of soil. Let the water table rise '
          'above the footing and the soil floats, so both terms halve.',
    ),
  ],
  spoken: [
    (
      'On clay loaded fast',
      r'N_\gamma = 0',
      'the width term has a factor of zero, so width buys nothing',
    ),
    (
      'On sand',
      r'N_q > N_\gamma',
      'the depth factor is the bigger one, so depth buys more',
    ),
    (
      'Under water',
      r"\gamma \to \gamma'",
      'the soil floats, and both weight terms halve',
    ),
  ],
  handbook: 'Handbook, bearing capacity',
);

const allowableBrief = BriefSection(
  title: 'Divide the capacity, not the load',
  picture: allowablePicture,
  steps: [
    (
      'The formula gives a failure pressure',
      'What comes out of the bearing equation is the pressure at which the '
          'ground gives way. Nobody builds to that number.',
    ),
    (
      'Divide it by a safety factor',
      'Usually three for bearing. That gives the ALLOWABLE pressure, and '
          'that is the number you are allowed to use.',
    ),
    (
      'Compare pressure with pressure',
      'A column hands you a load in pounds, not a pressure. Spread it over '
          'the footing area first, then compare. Dividing the load instead, or '
          'not dividing at all, are the two wrong answers offered side by '
          'side.',
    ),
    (
      'Why three, and what it misses',
      'The soil is known from a handful of boreholes, it varies between '
          'them, and a bearing failure gives no warning. And passing this '
          'check says nothing about SETTLEMENT, which on a soft clay is '
          'usually what really decides the footing.',
    ),
  ],
  spoken: [
    (
      'Allowable',
      r'q_{allow} = q_{ult} / FS',
      'the failure pressure, divided by the safety factor',
    ),
    (
      'The comparison',
      r'\frac{P}{A} \le q_{allow}',
      'the load spread over the footing, against what is allowed',
    ),
    (
      'The other check',
      r'\text{settlement, separately}',
      'strength and settlement are two different questions',
    ),
  ],
  handbook: 'Handbook, bearing capacity',
);

const threeChecksBrief = BriefSection(
  title: 'Three checks, three different quantities',
  picture: threeChecksPicture,
  steps: [
    (
      'A wall can fail three ways',
      'It can tip over. It can slide along its base. Or it can press the '
          'ground so hard the ground gives way. Each has to be checked '
          'separately, and they compare different things.',
    ),
    (
      'Tipping is about MOMENTS',
      'Take moments about the front bottom corner, the toe. The weight of '
          'the wall and the soil on its heel hold it down; the earth pressure '
          'tries to turn it.',
    ),
    (
      'Sliding is about FORCES',
      'Friction under the base against the sideways push. No arms, no '
          'moments: just force against force.',
    ),
    (
      'Bearing is about PRESSURES',
      'What the ground can carry against what the base actually puts on it. '
          'In all three, what RESISTS goes on top, so above one is safe. And '
          'they do not trade: a wall that will not tip but will slide is a '
          'wall that slides.',
    ),
  ],
  spoken: [
    (
      'Overturning',
      r'FS = \Sigma M_R / M_O',
      'the moments holding it, over the moments turning it',
    ),
    (
      'Sliding',
      r'FS = \Sigma F_R / \Sigma F_D',
      'the friction holding it, over the push shoving it',
    ),
    (
      'Bearing',
      r'FS = q_{ult} / q_{applied}',
      'the pressure the ground can take, over the pressure it gets',
    ),
  ],
  handbook: 'Handbook, retaining wall stability',
);

const middleThirdBrief = BriefSection(
  title: 'First from the toe, then from the middle',
  picture: middleThirdPicture,
  steps: [
    (
      'Where does the weight land',
      'All the downward forces on a wall add up to one force, and it crosses '
          'the base somewhere. Find that spot first, measured from the front '
          'corner: net moment divided by the vertical force.',
    ),
    (
      'That is NOT the eccentricity',
      'The eccentricity is how far that spot is from the MIDDLE of the base. '
          'Two different distances. Reporting the first as the second is the '
          'usual slip, and it is easy to catch, because the distance from the '
          'toe is far too big to be an eccentricity.',
    ),
    (
      'Keep it in the middle third',
      'Stay within a sixth of the base either side of center and the whole '
          'base stays pressed into the ground.',
    ),
    (
      'Outside it, the sums stop meaning anything',
      'Beyond the middle third the arithmetic starts asking the heel to PULL '
          'down on the ground. Soil does not pull.',
    ),
  ],
  spoken: [
    (
      'From the toe',
      r'\bar{x} = (\Sigma M_R - M_O)/\Sigma V',
      'the net moment divided by the downward force',
    ),
    (
      'Off center',
      r'e = B/2 - \bar{x}',
      'how far that spot is from the middle of the base',
    ),
    (
      'The middle third',
      r'e \leq B/6',
      'within a sixth of the base, either side of center',
    ),
  ],
  handbook: 'Handbook, retaining wall stability',
);

const basePressureBrief = BriefSection(
  title: 'Even pressure only when the load is centered',
  picture: basePressurePicture,
  steps: [
    (
      'Stand on one foot, evenly',
      'Load over area gives the pressure underneath, but only if the load '
          'lands dead center. Lean forward and your toes take more than your '
          'heel.',
    ),
    (
      'A retaining wall always leans',
      'Something is pushing it sideways by definition, so the resultant '
          'never lands in the middle. The pressure tilts into a wedge shape, '
          'most under the TOE, the end everything leans toward.',
    ),
    (
      'The 6e over B term is that tilt',
      'Nothing more. Set the eccentricity to zero and the bracket becomes '
          'one and the formula falls back to plain load over area.',
    ),
    (
      'A free check on your answer',
      'The two ends straddle the average by the same amount. If the toe is '
          '20 above the average, the heel is 20 below it. And the formula only '
          'holds while the resultant is inside the middle third.',
    ),
  ],
  spoken: [
    (
      'At the toe',
      r'q = \tfrac{\Sigma V}{B}\left(1 + \tfrac{6e}{B}\right)',
      'the average pressure, tilted up by how far off center it is',
    ),
    (
      'At the heel',
      r'q = \tfrac{\Sigma V}{B}\left(1 - \tfrac{6e}{B}\right)',
      'the same average, tilted down by the same amount',
    ),
    (
      'Centered',
      r'e = 0 \Rightarrow q = \Sigma V / B',
      'no tilt, so just the load over the area',
    ),
  ],
  handbook: 'Handbook, retaining wall stability',
);

const proctorBrief = BriefSection(
  title: 'A hump, not a slope',
  picture: proctorPicture,
  steps: [
    (
      'Compacting squeezes AIR out',
      'Not water. Water is only the helper that lets grains slide past each '
          'other into tighter packing.',
    ),
    (
      'Too dry and the grains will not slide',
      'They grind and lock. Adding water here genuinely helps, and the soil '
          'gets denser.',
    ),
    (
      'Too wet and the water holds them apart',
      'Past the peak the gaps are nearly full, and more water makes the soil '
          'LOOSER. No number of roller passes will get it back. That is why '
          'the curve is a hump and not a slope.',
    ),
    (
      'The peak belongs to one test',
      'It is the maximum for one soil at one compaction effort, so a '
          'specification must say WHICH Proctor. The modified test hits harder '
          'and gives a higher peak, so the same fill scores a lower percentage '
          'against it. Field over laboratory, that way up: upside down a short '
          'fill reads just over 100 and passes.',
    ),
  ],
  spoken: [
    (
      'Relative compaction',
      r'RC = \tfrac{\gamma_{d,field}}{\gamma_{d,max}} \times 100',
      'what you got in the field, over what the lab got',
    ),
    (
      'A usual specification',
      r'RC \geq 90\text{ to }95\%',
      'most of the way to the laboratory peak',
    ),
    (
      'Upside down',
      r'\text{reads just over }100\%',
      'which is how you catch the mistake',
    ),
  ],
  handbook: 'Handbook, compaction',
);

const relativeDensityBrief = BriefSection(
  title: 'Two different ways to say how tight',
  picture: relativeDensityPicture,
  steps: [
    (
      'Shake a jar of sand',
      'Poured in gently it sits loose. Shaken hard it packs down. Every clean '
          'sand has a loosest it will sit at and a tightest it can be got to, '
          'and the real one is somewhere between.',
    ),
    (
      'Relative density asks where between',
      'Not against a laboratory hump, but against those two extremes for '
          'that sand. It is the measure for clean sands and gravels.',
    ),
    (
      'Measure from the LOOSE end',
      'So tightly packed, meaning a small void ratio, gives a HIGH '
          'percentage. Start from the other end and you get the complement.',
    ),
    (
      'Which is how you catch it',
      'The right answer and the upside-down one always add to 100. Relative '
          'compaction and relative density compare against different things '
          'and are not interchangeable.',
    ),
  ],
  spoken: [
    (
      'Relative density',
      r'D_r = \tfrac{e_{max} - e}{e_{max} - e_{min}} \times 100',
      'how far from the loosest, over the whole range',
    ),
    (
      'The wrong end',
      r'\tfrac{e - e_{min}}{e_{max} - e_{min}}',
      'measures from the tightest instead',
    ),
    (
      'Together',
      r'\text{the two add to }100\%',
      'which is the check that catches the mistake',
    ),
  ],
  handbook: 'Handbook, relative density',
);

const stabilizerBrief = BriefSection(
  title: 'Match the help to the soil',
  picture: stabilizerPicture,
  steps: [
    (
      'Sometimes rolling is not enough',
      'A subgrade can be too soft, or swell when it rains, whatever you do '
          'with a roller. Then it gets help, and the right help depends on '
          'what the soil actually is.',
    ),
    (
      'Lime for plastic clays',
      'Lime reacts with the clay minerals themselves, brings the plasticity '
          'down and stops the swelling. It needs a clay to react with.',
    ),
    (
      'Cement for granular and low-plasticity soils',
      'Cement binds grains into something stiff. In a fat clay you can '
          'hardly mix it through, so it does little.',
    ),
    (
      'And water beats both',
      'A geosynthetic is not chemistry: it separates stone from mud, '
          'reinforces, or drains. And where water keeps coming back, DRAINAGE '
          'comes first, because water will undo any treatment you pay for.',
    ),
  ],
  spoken: [
    (
      'A plastic clay',
      r'\text{lime}',
      'it reacts with the clay and brings the plasticity down',
    ),
    (
      'A granular soil',
      r'\text{cement}',
      'it binds the grains into something stiff',
    ),
    (
      'Water first',
      r'\text{drainage}',
      'before any treatment, or the water undoes it',
    ),
  ],
  handbook: 'Handbook, soil stabilization',
);

const pileCapacityBrief = BriefSection(
  title: 'Two resistances, and two very different areas',
  picture: pileCapacityPicture,
  steps: [
    (
      'A pile holds up in two places',
      'Push a straw into sand. It resists at the bottom end, where it has to '
          'punch through, and all along its side, where the sand grips it.',
    ),
    (
      'The tip is a tiny footing',
      'A big pressure, times a small area: the end of the pile is a fraction '
          'of a square meter.',
    ),
    (
      'The shaft is a huge surface',
      'A much smaller pressure, times the whole side of the pile, which runs '
          'into tens of square meters. Each has its OWN area, and swapping '
          'them throws the answer out by fifty times.',
    ),
    (
      'Which one dominates',
      'Driven onto rock, nearly all tip. Long in uniform clay, nearly all '
          'shaft. For a friction pile, length buys capacity and width buys '
          'very little. Add both, and never report one alone.',
    ),
  ],
  spoken: [
    (
      'Together',
      r'Q_{ult} = Q_p + Q_s',
      'the tip plus the shaft, never one of them',
    ),
    (
      'Each part',
      r'Q_{ult} = q_p A_p + f_s A_s',
      'each pressure with its own area',
    ),
    (
      'The areas',
      r'A_p \text{ small}, \; A_s \text{ large}',
      'the tip is tiny and the side is enormous',
    ),
  ],
  handbook: 'Handbook, deep foundations',
);

const goingDeepBrief = BriefSection(
  title: 'Carrying the load past the layer that settles',
  picture: goingDeepPicture,
  steps: [
    (
      'Why piles at all',
      'Not because they are cheap, because they usually are not. They are '
          'there to carry a load THROUGH ground that would settle and hand it '
          'to something firm further down.',
    ),
    (
      'Settlement decides it, more often than strength',
      'A soft clay can be plenty strong enough not to fail and still drop a '
          'building further than it can stand. That is usually the reason for '
          'going deep.',
    ),
    (
      'A group is not the sum of its piles',
      'Put piles close together and they all work the same soil. In clay the '
          'group carries LESS than the singles added up, so its efficiency is '
          'below one.',
    ),
    (
      'And a group reaches deeper',
      'The whole cap acts as one wide load, so the stressed ground goes far '
          'deeper than any single pile would reach. That means the group '
          'settles more, and it is checked as one block.',
    ),
  ],
  spoken: [
    (
      'Why deep',
      r'\text{settlement, not price}',
      'to get past the layer that would settle',
    ),
    (
      'A group in clay',
      r'\text{efficiency} < 1',
      'the group carries less than the piles added up',
    ),
    (
      'Group settlement',
      r'\text{deeper, so more}',
      'the cap stresses ground no single pile reaches',
    ),
  ],
  handbook: 'Handbook, deep foundations',
);

const downdragBrief = BriefSection(
  title: 'The same friction, working as a load',
  picture: downdragPicture,
  steps: [
    (
      'Friction points against the movement',
      'Rub your hand down a rope and the rope rubs your hand upward. '
          'Friction always opposes whatever is sliding, and it is the RELATIVE '
          'movement that decides which way.',
    ),
    (
      'Normally the pile is the one moving',
      'Load a pile and it tries to go down through still soil. The soil rubs '
          'UP on it, and that grip is holding the pile up. It counts toward '
          'capacity.',
    ),
    (
      'Sometimes the ground is the one moving',
      'Dump new fill on soft clay and the clay settles for years, sliding '
          'DOWN past the pile. Now the soil rubs downward and hangs on the '
          'pile.',
    ),
    (
      'And that costs twice',
      'The drag is added to the load the pile must carry, AND that stretch '
          'of shaft gives no help. Same surface, same grip, opposite sign. It '
          'is never capacity.',
    ),
  ],
  spoken: [
    (
      'Pile moving down',
      r'\text{soil resists: } +Q_s',
      'the grip holds the pile up',
    ),
    (
      'Ground settling past it',
      r'\text{soil drags: an added load}',
      'the same grip now hangs on the pile',
    ),
    (
      'Decided by',
      r'\text{which one moves down}',
      'the relative movement, and nothing else',
    ),
  ],
  handbook: 'Handbook, deep foundations',
);

const sightDistanceBrief = BriefSection(
  title: 'Thinking, then braking',
  picture: sightDistancePicture,
  steps: [
    (
      'Something appears in the road',
      'You do not stop at once. First you have to notice it, and while you '
          'are noticing, the car keeps going at full speed. Nothing has slowed '
          'down yet.',
    ),
    (
      'Then the brakes work',
      'Now the car slows, and that second stretch of road is the braking '
          'distance. Stopping sight distance is the two stretches added '
          'together. Giving only one of them is the mistake this lesson prints '
          'twice.',
    ),
    (
      'The two grow differently',
      'Thinking distance just doubles when the speed doubles. Braking '
          'distance goes up with the speed times itself, so it grows much '
          'faster. At 30 mph most of the road is thinking; at 60 mph most of '
          'it is braking.',
    ),
    (
      'Why 1.47 keeps appearing',
      'Speeds are given in miles per hour but distances come out in feet '
          'per second. Multiplying by 1.47 does that swap, and it is nothing '
          'more than that.',
    ),
  ],
  spoken: [
    (
      'Thinking',
      r'1.47\,V t',
      'speed turned into feet per second, times the seconds spent noticing',
    ),
    (
      'Braking',
      r'\dfrac{V^2}{30\left(\frac{a}{32.2} \pm G\right)}',
      'speed times itself on top, how hard it slows underneath',
    ),
    (
      'Add them',
      r'S = 1.47Vt + \text{braking}',
      'both stretches, never one alone',
    ),
  ],
  handbook: 'Handbook, stopping sight distance',
);

const gradeSignBrief = BriefSection(
  title: 'Uphill helps, downhill hurts',
  picture: gradeSignPicture,
  steps: [
    (
      'Roll a ball up a slope',
      'It stops quickly, because gravity is pulling it backward. Roll it '
          'down and it runs on and on. A braking car does the same thing.',
    ),
    (
      'So uphill needs less road',
      'Climbing, the car\'s own weight helps the brakes, so it stops '
          'sooner and needs LESS sight distance. Going down, its weight pushes '
          'it along and it needs MORE.',
    ),
    (
      'Only the braking half moves',
      'During the thinking stretch nothing has happened yet, so the car '
          'covers the same ground on any hill. The grade changes the second '
          'half only.',
    ),
    (
      'Put the grade in as a decimal',
      'Four per cent goes in as 0.04, plus for up and minus for down. Flip '
          'that sign on a four per cent hill and the answer moves about eighty '
          'feet, always toward less road than the driver really needs.',
    ),
  ],
  spoken: [
    ('Uphill', r'+G', 'the grade is added, so the car stops sooner'),
    ('Downhill', r'-G', 'the grade is subtracted, so the car needs more road'),
    ('As a decimal', r'4\% = 0.04', 'per cent divided by a hundred'),
  ],
  handbook: 'Handbook, stopping sight distance',
);

const peakHourBrief = BriefSection(
  title: 'Designed for the busiest fifteen minutes',
  picture: peakHourPicture,
  steps: [
    (
      'Traffic does not arrive evenly',
      'Count an hour in four quarters and one of them is always busier '
          'than the rest. The road either works during that worst quarter or '
          'it jams.',
    ),
    (
      'So pretend the whole hour ran that fast',
      'Take the busiest fifteen minute count and multiply by four. That is '
          'the flow rate the road is designed for, and it is always at least '
          'the real hourly total.',
    ),
    (
      'The factor compares the two',
      'The peak hour factor is the real hour divided by that pretend rate. '
          'It runs from 0.25, when everything came in one quarter, up to 1.00, '
          'when all four quarters matched. Real roads sit around 0.85 to 0.95.',
    ),
    (
      'Read the direction carefully',
      'A LOW factor means a spiky hour, which means a HIGH design flow. If '
          'your flow rate comes out below the hourly count, it is wrong before '
          'you check anything else.',
    ),
  ],
  spoken: [
    (
      'Flow rate',
      r'4 \times V_{15}',
      'four times the busiest quarter hour count',
    ),
    (
      'The factor',
      r'PHF = \dfrac{V}{4 V_{15}}',
      'the whole hour divided by that flow rate',
    ),
    ('Its range', r'0.25 \leq PHF \leq 1.00', 'never above one'),
  ],
  handbook: 'Handbook, peak hour factor',
);

const crestSagBrief = BriefSection(
  title: 'Seeing over a hill, or lighting into a dip',
  picture: crestSagPicture,
  steps: [
    (
      'Two shapes, two different problems',
      'A crest is a hump. A sag is a dip. Both are sized so a driver can '
          'see far enough ahead, but what blocks the view is different in each.',
    ),
    (
      'On a crest the road blocks you',
      'The hump itself hides what is beyond it. Your eye sits about three '
          'and a half feet up and the thing you must see is about two feet '
          'tall. Flatten the hump and you see further.',
    ),
    (
      'In a sag the headlights run out',
      'By day a dip is fine. At night your headlights point only about one '
          'degree up while the road curves away below the beam, so the beam is '
          'what limits you.',
    ),
    (
      'How to tell the formulas apart',
      'The crest divides by a fixed 2,158. The sag divides by 400 plus '
          '3.5 times the sight distance. If the bottom of the fraction has an '
          'S in it, it is a sag.',
    ),
  ],
  spoken: [
    (
      'Crest',
      r'L = \dfrac{A S^2}{2{,}158}',
      'the grade break times sight distance squared, over a fixed number',
    ),
    (
      'Sag',
      r'L = \dfrac{A S^2}{400 + 3.5S}',
      'the same on top, but the bottom moves with the sight distance',
    ),
    (
      'Then check',
      r'S \leq L',
      'if the curve came out shorter than the sight distance, switch formulas',
    ),
  ],
  handbook: 'Handbook, vertical curves',
);

const gradeBreakBrief = BriefSection(
  title: 'How much the grade changes',
  picture: gradeBreakPicture,
  steps: [
    (
      'A is how sharply the road bends',
      'The road arrives on one slope and leaves on another. A is the '
          'difference between them, written as a plain size in per cent. '
          'Everything about the curve follows from it.',
    ),
    (
      'Opposite slopes ADD',
      'Up three then down five is a break of eight, not two. Going up and '
          'then down is a big change of direction, and that is the mistake '
          'this whole lesson is built around.',
    ),
    (
      'Same-side slopes SUBTRACT',
      'Down two then down five is a break of only three. Both are '
          'downhill, so the road barely changes direction.',
    ),
    (
      'Crest or sag has nothing to do with signs',
      'It only depends on whether the second slope is LESS than the first, '
          'which makes a crest, or more, which makes a sag.',
    ),
  ],
  spoken: [
    (
      'The break',
      r'A = |g_2 - g_1|',
      'the difference between the two grades, as a size',
    ),
    ('A crest', r'g_2 < g_1', 'the road tips downward through the curve'),
    (
      'Rate of curvature',
      r'K = L / A',
      'feet of curve for each per cent of grade change; a bigger K is flatter',
    ),
  ],
  handbook: 'Handbook, vertical curves',
);

const superelevationBrief = BriefSection(
  title: 'The tires and the tilt share the job',
  picture: superelevationPicture,
  steps: [
    (
      'Going round a bend throws you outward',
      'Something has to hold the car in. How much holding the bend needs '
          'is the speed times itself, over fifteen times the radius. Faster or '
          'tighter needs more.',
    ),
    (
      'Two things supply it',
      'The grip of the tires sideways on the road, and the tilt of the '
          'pavement toward the inside of the bend. Between them they have to '
          'cover the whole demand.',
    ),
    (
      'The tires go first',
      'The grip is already there for free, so take it OFF the demand. What '
          'is left over is what the tilt has to provide. Forget this and you '
          'ask the road for everything, which on this bend means a 22.5 per '
          'cent tilt: a parked car would slide into the ditch.',
    ),
    (
      'The tilt is quoted in per cent',
      'That is what the 0.01 in the formula is for. An answer of 0.075 per '
          'cent is the right number wearing the wrong label.',
    ),
  ],
  spoken: [
    (
      'What the bend asks',
      r'0.01e + f = \dfrac{V^2}{15R}',
      'tilt plus grip equals speed squared over fifteen times the radius',
    ),
    (
      'What is left for the road',
      r'0.01e = \dfrac{V^2}{15R} - f',
      'the demand with the tire grip taken off',
    ),
    (
      'The levers',
      r'2V \Rightarrow 4\times',
      'double the speed and the demand is four times as big',
    ),
  ],
  handbook: 'Handbook, superelevation',
);

const yellowBrief = BriefSection(
  title: 'A moment to react, then the stop',
  picture: yellowPicture,
  steps: [
    (
      'Why yellow exists',
      'When the light changes, a driver must be able to either stop '
          'comfortably or carry on through. Yellow is the time that makes sure '
          'there is no spot on the road where neither is possible.',
    ),
    (
      'It is two pieces',
      'About a second to notice and lift off, then the time it takes to '
          'shed the speed. Add them.',
    ),
    (
      'Why the two in the bottom',
      'A car slowing steadily is doing full speed at the start and nothing '
          'at the end, so on average it is doing half. That halving is where '
          'the two comes from. Leave it out and a 50 mph approach gives 8.3 '
          'seconds instead of 4.7.',
    ),
    (
      'Everything in feet and seconds',
      'The slowing rate is feet per second squared, so the speed has to be '
          'feet per second too. Miles per hour straight in gives 3.5 seconds '
          'where 4.7 belongs.',
    ),
  ],
  spoken: [
    (
      'The yellow',
      r'y = t + \dfrac{v}{2a \pm 64.4G}',
      'reaction time, plus speed over twice the slowing rate',
    ),
    (
      'The units',
      r'1\text{ mph} = 1.467\text{ ft/s}',
      'miles per hour into feet per second',
    ),
    (
      'The grade',
      r'64.4 = 2g',
      'twice gravity: plus going up, minus going down',
    ),
  ],
  handbook: 'Handbook, signal timing',
);

const allRedBrief = BriefSection(
  title: 'Until the back bumper is out',
  picture: allRedPicture,
  steps: [
    (
      'A short moment when everyone has red',
      'After the yellow, every direction is held at red for a beat. That '
          'beat belongs to one particular car: the one that entered legally on '
          'the yellow and is still in the middle.',
    ),
    (
      'It is clear when its BACK end is out',
      'Not its nose. So the distance to cover is the width of the crossing '
          'PLUS the length of the car. Leave the car length out and you lose a '
          'third of the protection.',
    ),
    (
      'Then divide by the speed',
      'In feet per second, as always. Dividing by miles per hour gives a '
          'bigger number that looks safer and is not seconds at all, so it '
          'does not even fail in a safe direction.',
    ),
    (
      'What makes it long',
      'A wide crossing on a slow street can want three or four seconds. A '
          'long truck as the design vehicle pushes it further still.',
    ),
  ],
  spoken: [
    (
      'The all-red',
      r'r = \dfrac{W + l}{v}',
      'crossing width plus vehicle length, over the speed in feet per second',
    ),
    ('Why the length', r'W + l', 'the back bumper decides, not the nose'),
  ],
  handbook: 'Handbook, signal timing',
);

const pedestrianGreenBrief = BriefSection(
  title: 'Getting going, walking, and the crowd',
  picture: pedestrianGreenPicture,
  steps: [
    (
      'Three separate pieces of time',
      'A fixed 3.2 seconds for people to see the signal and step off the '
          'curb. Then the walk itself. Then a little extra because a crowd '
          'cannot all leave at once.',
    ),
    (
      'The walk is length over pace',
      'The crosswalk length divided by a walking pace of 3.5 feet a '
          'second. The start-up time does not depend on the road at all, so it '
          'is the same wherever you are.',
    ),
    (
      'About a quarter second per person',
      'Fifteen people waiting adds roughly four seconds. That is the piece '
          'people forget when a busy downtown corner is timed.',
    ),
    (
      'The pace is slow on purpose',
      'It is set for the slowest people crossing, not a brisk adult. Using '
          '4.0 shortens the green for exactly the people who need it most.',
    ),
  ],
  spoken: [
    (
      'The green',
      r'G_p = 3.2 + \dfrac{L}{S_p} + 0.27 N',
      'start-up, plus length over pace, plus a bit for each person waiting',
    ),
    ('The pace', r'S_p = 3.5 \text{ ft/s}', 'a slow walk, on purpose'),
  ],
  handbook: 'Handbook, signal timing',
);

const greenshieldsBrief = BriefSection(
  title: 'The most cars get through at half speed',
  picture: greenshieldsPicture,
  steps: [
    (
      'Flow is how many cars pass you',
      'It is how fast they are going times how many of them there are in a '
          'mile. An empty road has fast cars but almost none of them. A jam has '
          'plenty of cars going nowhere. Both move very little traffic.',
    ),
    (
      'Speed falls in a straight line',
      'Greenshields assumes the more crowded the lane gets, the slower '
          'everyone goes, evenly, from full speed on an empty road down to zero '
          'in a jam.',
    ),
    (
      'So the best is in the middle',
      'One thing rising while the other falls always peaks halfway. Maximum '
          'flow happens at half the free flow speed AND half the jam density, '
          'so the peak is a QUARTER of the two multiplied together. Forget the '
          'four and you report the product itself.',
    ),
    (
      'Two things worth keeping',
      'Maximum flow is not a nice road, it is a crowded one at half speed '
          'about to break down. And every flow below the peak happens at two '
          'different densities, one on each side, which is why quality is '
          'judged on density instead.',
    ),
  ],
  spoken: [
    ('The fundamentals', r'V = S \times D', 'flow is speed times density'),
    (
      'The peak',
      r'V_m = \dfrac{D_j S_f}{4}',
      'jam density times free flow speed, over four',
    ),
    (
      'Where it sits',
      r'D_o = D_j/2, \; S_o = S_f/2',
      'half the jam density and half the free speed, together',
    ),
  ],
  handbook: 'Handbook, traffic flow',
);

const speedDensityBrief = BriefSection(
  title: 'Start at full speed, subtract the traffic',
  picture: speedDensityPicture,
  steps: [
    (
      'Every extra car costs a little speed',
      'On an empty road you go the free flow speed. Each vehicle per mile '
          'added takes a fixed bite out of that. The line falls at a steady '
          'rate all the way to the jam.',
    ),
    (
      'The bite is the slope',
      'The free flow speed divided by the jam density is how much speed '
          'each extra car a mile costs. Multiply that by how many cars are '
          'there to get the total loss.',
    ),
    (
      'Then SUBTRACT it',
      'The answer is what is left, never the bite itself. Reporting the '
          'reduction instead of the remaining speed is the first trap.',
    ),
    (
      'The second trap, and a free check',
      'Half the free flow speed is only right when the density is half the '
          'jam density; those halves go together and mean nothing apart. And '
          'nothing can go faster than free flow, so any answer above it is '
          'wrong before you look.',
    ),
  ],
  spoken: [
    (
      'The line',
      r'S = S_f - \dfrac{S_f}{D_j} D',
      'free speed, less the slope times the density',
    ),
    (
      'The slope',
      r'\dfrac{S_f}{D_j}',
      'how much speed each extra vehicle per mile costs',
    ),
    ('The ceiling', r'S \leq S_f', 'nothing beats the free flow speed'),
  ],
  handbook: 'Handbook, traffic flow',
);

const crashRateBrief = BriefSection(
  title: 'Crashes over the traffic that was exposed',
  picture: crashRatePicture,
  steps: [
    (
      'A count alone ranks nothing',
      'A busy junction has more crashes than a quiet one simply because '
          'more cars go through it. To compare two places you have to divide by '
          'how much traffic was exposed.',
    ),
    (
      'Build the bottom of the fraction',
      'Traffic is usually given per DAY, so multiply by 365 to get a year, '
          'matching a year of crashes. Divide by the daily count instead and '
          'you get thousands, claiming more crashes than vehicles.',
    ),
    (
      'The million is just for reading',
      'Rates come out as tiny decimals, so the answer is quoted per million '
          'vehicles. That is all the ten to the sixth is doing.',
    ),
    (
      'Junction or stretch of road',
      'At a junction the exposure is vehicles ENTERING. Along a road it is '
          'vehicle MILES, because a car on three miles of highway is exposed '
          'three times as long.',
    ),
  ],
  spoken: [
    (
      'A junction',
      r'RMEV = \dfrac{A \times 10^6}{ADT \times 365}',
      'crashes per million vehicles entering',
    ),
    (
      'A segment',
      r'RMVM = \dfrac{A \times 10^6}{ADT \times 365 \times L}',
      'crashes per million vehicle miles',
    ),
  ],
  handbook: 'Handbook, crash rates',
);

const heavyVehicleBrief = BriefSection(
  title: 'A truck takes the room of two cars, or three',
  picture: heavyVehiclePicture,
  steps: [
    (
      'Capacity is a question about room',
      'So everything gets counted in car-sized spaces. A truck is longer, '
          'pulls away slowly and needs a bigger gap in front, so it fills the '
          'space of two cars on flat ground and three on hilly ground.',
    ),
    (
      'Only the EXTRA space counts',
      'A truck is already one vehicle, so it adds one more space, or two on '
          'hills. That is why the formula carries the equivalent less one.',
    ),
    (
      'Turn that into a factor',
      'One truck in ten on the level means a hundred vehicles fill a '
          'hundred and ten spaces, so the factor is one over 1.10, about 0.909. '
          'It is always between zero and one.',
    ),
    (
      'You DIVIDE by it',
      'Dividing by a number under one makes the answer bigger: the traffic '
          'is worse than the raw count suggested. A factor above one is '
          'impossible, and picking the wrong terrain moves this one from 0.909 '
          'to 0.833.',
    ),
  ],
  spoken: [
    (
      'The factor',
      r'f_{HV} = \dfrac{1}{1 + P_T(E_T - 1)}',
      'one over, one plus the truck share times the extra space each takes',
    ),
    (
      'The equivalents',
      r'E_T = 2 \text{ level}, \; 3 \text{ rolling}',
      'what one truck counts as in cars',
    ),
    ('Its range', r'0 < f_{HV} \leq 1', 'never above one'),
  ],
  handbook: 'Handbook, freeway capacity',
);

const demandFlowBrief = BriefSection(
  title: 'One count, three divisions',
  picture: demandFlowPicture,
  steps: [
    (
      'What the answer has to be',
      'Not the traffic on the road, but passenger cars an hour in ONE lane, '
          'at the rate of the busiest fifteen minutes. Three divisions get you '
          'there from the hourly count.',
    ),
    (
      'Divide by the peak hour factor',
      'That turns the whole hour into the rate its worst quarter implies. '
          'The factor is under one, so this step raises the number.',
    ),
    (
      'Divide by the lanes, then by the trucks',
      'Lanes gets you down to one lane, which lowers it. The truck factor '
          'is under one again, so it raises it, converting the mixture into '
          'plain car spaces.',
    ),
    (
      'Knowing the direction catches most mistakes',
      'On this freeway the answer is 1,793. Leave out the trucks and it is '
          '1,630; leave out the peak factor and it is 1,650. Two different '
          'omissions giving nearly the same wrong answer.',
    ),
  ],
  spoken: [
    (
      'The flow rate',
      r'v_p = \dfrac{V}{PHF \times N \times f_{HV}}',
      'the hourly count, divided by the peak factor, the lanes, and the truck factor',
    ),
    (
      'What it is',
      r'\text{cars per hour per lane}',
      'passenger cars, one lane, at the busiest quarter hour rate',
    ),
  ],
  handbook: 'Handbook, freeway capacity',
);

const levelOfServiceBrief = BriefSection(
  title: 'The letter comes off the density',
  picture: levelOfServicePicture,
  steps: [
    (
      'A to F, like a school grade',
      'A is an open road, F is a jam. The letter is read off DENSITY: how '
          'many vehicles are packed into a mile of one lane.',
    ),
    (
      'Not volume, and not speed',
      'Two roads can carry the same volume at very different densities. And '
          'speed stays near free flow until a road is nearly full, so it cannot '
          'sort the letters either.',
    ),
    (
      'Work the flow first, then divide by speed',
      'Flow is speed times density, so density is flow over speed. Check '
          'the units: cars an hour over miles an hour leaves cars per mile.',
    ),
    (
      'The bands are narrow near the top',
      'One missing adjustment changes the letter. Forgetting the trucks '
          'here gives 33 per mile instead of 37, which reads as D rather than '
          'E.',
    ),
  ],
  spoken: [
    (
      'The density',
      r'D = v_p / S',
      'the flow rate per lane, divided by the speed',
    ),
    (
      'The bands',
      r'A \leq 11, \; B \leq 18, \; C \leq 26',
      'vehicles per mile per lane',
    ),
    ('And on', r'D \leq 35, \; E \leq 45', 'anything above is F'),
  ],
  handbook: 'Handbook, level of service',
);

const fourStepBrief = BriefSection(
  title: 'Four steps, and the order is not optional',
  picture: fourStepPicture,
  steps: [
    (
      'How many trips, and from where',
      'GENERATION counts the trips each area produces and attracts, from '
          'what is built there. Houses make trips; shops and offices pull them '
          'in. It is a quantity and nothing more.',
    ),
    (
      'Where they go, and how',
      'DISTRIBUTION decides which trip goes to which destination, and this '
          'is where the gravity model works. MODE CHOICE then splits them '
          'between car, bus and walking.',
    ),
    (
      'Which road they use',
      'ASSIGNMENT puts them on particular routes, and produces the volumes '
          'a designer actually builds for.',
    ),
    (
      'Why the order is fixed',
      'Each step eats what the one before made: distribution has nothing to '
          'share out until generation has made it. Worth knowing where a change '
          'lands too. A new employer moves distribution, a new fare moves mode '
          'choice, a new bridge moves assignment.',
    ),
  ],
  spoken: [
    (
      'The order',
      r'\text{generation} \to \text{distribution}',
      'first how many, then where they go',
    ),
    (
      'Then',
      r'\text{mode} \to \text{assignment}',
      'then how they travel, then which road they take',
    ),
  ],
  handbook: 'Handbook, travel demand',
);

const gravityBrief = BriefSection(
  title: 'Shares that add up to one',
  picture: gravityPicture,
  steps: [
    (
      'Give every destination a weight',
      'The weight is how much it attracts, times how easy it is to reach. A '
          'big place that is hard to get to and a small place next door can '
          'come out even.',
    ),
    (
      'Then share the trips in proportion',
      'A place with a third of the total weight gets a third of the trips. '
          'That is the whole model.',
    ),
    (
      'The step people drop',
      'Dividing by the SUM of all the weights. Without it the shares do not '
          'add to one, and the model sends out more or fewer trips than the '
          'origin ever made.',
    ),
    (
      'Two free checks',
      'The shares add to one, and the trips add up exactly to what the '
          'origin produced. Using attractions alone is the other printed wrong '
          'answer, and it hands trips to a big place too far away to earn them.',
    ),
  ],
  spoken: [
    (
      'The weight',
      r'A_j F_{ij}',
      'what a place attracts, times how easy it is to reach',
    ),
    (
      'The share',
      r'T_{ij} = P_i \dfrac{A_j F_{ij}}{\sum_j A_j F_{ij}}',
      'its weight divided by all the weights added up',
    ),
    (
      'The check',
      r'\textstyle\sum_j T_{ij} = P_i',
      'the trips sent out equal the trips produced',
    ),
  ],
  handbook: 'Handbook, gravity model',
);

const frictionBrief = BriefSection(
  title: 'Big attracts, far repels',
  picture: frictionPicture,
  steps: [
    (
      'Distance pushes trips away',
      'The further apart two places are, the fewer trips run between them. '
          'The friction factor is the number that carries that, and it FALLS as '
          'the travel time rises.',
    ),
    (
      'The name is backwards',
      'A HIGH friction factor means an EASY trip. It is written that way so '
          'it can multiply the attractions directly, but the word suggests the '
          'opposite.',
    ),
    (
      'Size can beat distance',
      'A place five times bigger can still take most of the trips even '
          'though it is much harder to reach. That is why a regional mall pulls '
          'from half a county.',
    ),
    (
      'A new road moves trips, it does not make them',
      'Cut the travel time and the factor rises, so trips shift toward that '
          'place. The origin still produces exactly what it produced before.',
    ),
  ],
  spoken: [
    (
      'Longer trip',
      r'F_{ij} \text{ falls}',
      'the harder the trip, the smaller the factor',
    ),
    (
      'The balance',
      r'A_j \uparrow \text{ against } F_{ij} \downarrow',
      'size pulling one way, distance the other',
    ),
    (
      'No new trips',
      r'\textstyle\sum_j T_{ij} = P_i',
      'the total still equals what the origin made',
    ),
  ],
  handbook: 'Handbook, gravity model',
);

const signCategoryBrief = BriefSection(
  title: 'Shape and color first, then the words',
  picture: signCategoryPicture,
  steps: [
    (
      'You know a sign before you read it',
      'A red octagon is a stop sign even from behind, even in fog, even in '
          'a language you do not speak. That recognition is what buys a driver '
          'reaction time.',
    ),
    (
      'REGULATORY signs give an order',
      'Mostly white rectangles with black words. Two shapes are held back '
          'for the two messages that must read from any angle: the red octagon '
          'for stop and the triangle for yield.',
    ),
    (
      'WARNING signs are yellow diamonds',
      'They tell you what is ahead without ordering anything. That is why a '
          'speed on a yellow plate is only advice, not a limit.',
    ),
    (
      'GUIDE signs are green',
      'Directions, distances and destinations. They ask nothing at all. '
          'The manual holds this the same everywhere so the pattern can be '
          'trusted.',
    ),
  ],
  spoken: [
    (
      'Regulatory',
      r'\text{white rectangle, red octagon, triangle}',
      'a legal requirement',
    ),
    ('Warning', r'\text{yellow diamond}', 'what is ahead, no order given'),
    ('Guide', r'\text{green}', 'directions and distances'),
  ],
  handbook: 'MUTCD, sign categories',
);

const warrantBrief = BriefSection(
  title: 'A signal has to earn its place',
  picture: warrantPicture,
  steps: [
    (
      'A signal is not automatically better',
      'It stops traffic that never had to stop before. That buys delay and '
          'rear-end crashes, and an unnecessary red teaches drivers to ignore '
          'reds everywhere.',
    ),
    (
      'So there is a checklist first',
      'The manual calls them warrants. Eight hours of heavy traffic. One '
          'very heavy hour. People waiting to cross on foot. A school crossing. '
          'A crash history a signal would fix.',
    ),
    (
      'Any single one can qualify it',
      'A crossing does not have to meet them all. Meeting one is enough to '
          'consider a signal.',
    ),
    (
      'Justified is not the same as required',
      'Even when a warrant is met, judgment still decides, and sometimes '
          'decides on a roundabout instead. The trade a signal makes is fewer '
          'right-angle crashes, which hurt people, for more rear-end crashes, '
          'which usually do not.',
    ),
  ],
  spoken: [
    (
      'Before installing',
      r'\text{a warrant must be met}',
      'the checklist comes first',
    ),
    (
      'Meeting one',
      r'\text{justified, not required}',
      'judgment still decides',
    ),
    (
      'The trade',
      r'\text{fewer angle, more rear-end}',
      'the crashes that hurt people, traded for the ones that usually do not',
    ),
  ],
  handbook: 'MUTCD, signal warrants',
);

const structuralNumberBrief = BriefSection(
  title: 'What each inch of each layer is worth',
  picture: structuralNumberPicture,
  steps: [
    (
      'A road is built in layers',
      'Asphalt on top, crushed stone under it, cheaper gravel under that. '
          'Each layer helps carry the traffic, but they are not worth the same '
          'per inch.',
    ),
    (
      'Give every inch a score',
      'An inch of asphalt is worth about 0.44. An inch of stone base about '
          '0.14. An inch of gravel subbase about 0.11. So one inch of asphalt '
          'does the work of roughly THREE inches of base.',
    ),
    (
      'Add them all up',
      'Multiply each layer\'s score by how many inches thick it is, and add. '
          'That total is the structural number: one figure for the whole road.',
    ),
    (
      'Drainage can cut a layer\'s score',
      'A base or subbase that holds water is worth less, so it carries a '
          'drainage number under one. The surface course is always 1.0 by '
          'convention. Assume 1.0 when a lower value was given and you build '
          'the road too thin.',
    ),
  ],
  spoken: [
    (
      'The sum',
      r'SN = a_1 D_1 + a_2 D_2 m_2 + a_3 D_3 m_3',
      'each layer: its score, times its inches, times its drainage',
    ),
    (
      'Typical scores',
      r'a \approx 0.44, \; 0.14, \; 0.11',
      'asphalt, stone base, gravel subbase',
    ),
    ('The surface', r'm_1 = 1.0', 'the top layer is not given a drainage cut'),
  ],
  handbook: 'Handbook, AASHTO flexible pavement',
);

const layerThicknessBrief = BriefSection(
  title: 'The same sum, read backwards',
  picture: layerThicknessPicture,
  steps: [
    (
      'Now the total is given',
      'The design says the road must reach a certain structural number, and '
          'every layer but one is already fixed. You are solving for the '
          'missing thickness.',
    ),
    (
      'Two steps, and that is all',
      'Add up what the fixed layers give you, and take it away from the '
          'target. Then divide what is left by what ONE inch of the missing '
          'layer is worth.',
    ),
    (
      'Drainage is where this goes wrong',
      'A subbase at 0.80 gives a fifth less than the same subbase draining '
          'properly, and the base has to make it up: nearly two extra inches on '
          'this road.',
    ),
    (
      'A negative answer is not a mistake',
      'It means the fixed layers already beat the target. You still build '
          'the layer, but a minimum construction thickness decides how thick, '
          'not the arithmetic.',
    ),
  ],
  spoken: [
    (
      'Solve for one',
      r'D_2 = \dfrac{SN - a_1 D_1 - a_3 D_3 m_3}{a_2 m_2}',
      'the gap left over, divided by what an inch of that layer is worth',
    ),
    (
      'Poor drainage',
      r'm < 1',
      'less from that layer, so more is needed from the rest',
    ),
  ],
  handbook: 'Handbook, AASHTO flexible pavement',
);

const esalBrief = BriefSection(
  title: 'Traffic counted in standard axles, not vehicles',
  picture: esalPicture,
  steps: [
    (
      'Weight hurts far more than it looks',
      'The damage an axle does to a road goes up roughly with its load '
          'multiplied by itself four times. So a little more weight is a great '
          'deal more damage.',
    ),
    (
      'So pick one axle as the yardstick',
      'The standard is an eighteen thousand pound single axle. Every other '
          'axle is scored against it: how many standard passes it is worth. '
          'Multiply that score by how many times it comes past.',
    ),
    (
      'The numbers are startling',
      'A car axle is worth about two ten-thousandths of a standard pass, so '
          'thousands of cars equal one loaded truck axle. A 24 kip axle is a '
          'third heavier than standard and does three times the damage. A 12 '
          'kip axle does under a fifth.',
    ),
    (
      'What that means for a road',
      'A street with no trucks lasts almost indefinitely. And taking a '
          'little weight off an axle takes a great deal of damage off the '
          'pavement. The lifetime total is what sets the structural number.',
    ),
  ],
  spoken: [
    (
      'The conversion',
      r'\text{ESALs} = \text{passes} \times LEF',
      'how many times it passes, times what each pass is worth',
    ),
    ('The standard', r'18 \text{ kip single axle}', 'the yardstick axle'),
    (
      'Steeply',
      r'\text{damage} \sim \text{load}^4',
      'damage grows with the load multiplied by itself four times',
    ),
  ],
  handbook: 'Handbook, load equivalency',
);

const rigidVsFlexibleBrief = BriefSection(
  title: 'A beam, or a blanket',
  picture: rigidVsFlexiblePicture,
  steps: [
    (
      'Concrete bridges the load',
      'A slab is stiff enough to bend across the wheel, like a plank across '
          'a puddle, and hand the weight to a patch of ground many times bigger '
          'than the tire.',
    ),
    (
      'Asphalt passes it down',
      'Each layer hands the load to the one below, spreading it a little on '
          'the way. So every layer has to be strong in its own right, and the '
          'ground underneath still feels a lot.',
    ),
    (
      'That is why the slab minds soft ground less',
      'It bridges a weak spot the way a plank bridges a gap. A flexible '
          'road sitting on the same soft spot has nothing to bridge with.',
    ),
    (
      'And why they are designed differently',
      'The slab is designed on the bending strength of the concrete, since '
          'bending is how it works, rather than on a structural number. It '
          'costs more to build, so the choice usually turns on whole life cost: '
          'heavy trucks, a long life and poor ground favor concrete.',
    ),
  ],
  spoken: [
    (
      'Rigid',
      r'\text{bends, spreads the load wide}',
      'the slab works as a beam',
    ),
    (
      'Flexible',
      r'\text{passes it down, layer by layer}',
      'each course carries and spreads a little',
    ),
    (
      'Designed on',
      r'\text{rupture strength, not } SN',
      'the bending strength of the concrete',
    ),
  ],
  handbook: 'Handbook, rigid pavement',
);

const jointBrief = BriefSection(
  title: 'Smooth bars let go, ribbed bars hold on',
  picture: jointPicture,
  steps: [
    (
      'Concrete is going to crack',
      'It shrinks as it cures and moves with the weather. You cannot stop '
          'that, so joints are cut to decide WHERE it cracks instead of leaving '
          'it to chance.',
    ),
    (
      'Three kinds of joint',
      'Contraction joints are sawn in within hours and give the crack a '
          'tidy line to follow. Expansion joints leave room to grow, used '
          'sparingly. Construction joints are simply where paving stopped for '
          'the day.',
    ),
    (
      'A DOWEL is smooth and greased',
      'It hands the wheel load from one slab to the next while letting the '
          'two slide apart and together. It goes across the lane, in transverse '
          'joints.',
    ),
    (
      'A TIE BAR is ribbed and bonded',
      'It is meant not to move at all: it holds a joint between two lanes '
          'shut so they cannot drift apart. Where a joint has no steel, the '
          'rough crack faces below the saw cut grip each other instead.',
    ),
  ],
  spoken: [
    (
      'Dowel',
      r'\text{carries load, allows movement}',
      'smooth and greased, across the lane',
    ),
    (
      'Tie bar',
      r'\text{holds the joint closed}',
      'ribbed and bonded, between lanes',
    ),
    (
      'No steel',
      r'\text{aggregate interlock}',
      'the rough crack faces grip each other',
    ),
  ],
  handbook: 'Handbook, rigid pavement joints',
);

const subgradeReactionBrief = BriefSection(
  title: 'The ground as a bed of springs',
  picture: subgradeReactionPicture,
  steps: [
    (
      'Picture springs under the slab',
      'Press down and they squash. How hard you have to press to push the '
          'ground down one inch is k, the modulus of subgrade reaction.',
    ),
    (
      'So it is a stiffness, not a strength',
      'Its units are pounds per square inch for each inch of squash, which '
          'is pounds per cubic inch. Stiff ground gives less under the same '
          'push.',
    ),
    (
      'Why the slab cares',
      'Ground that gives less lets the slab bend less, so the concrete is '
          'pulled less at its underside. That pulling is what actually cracks a '
          'slab.',
    ),
    (
      'What k is NOT',
      'It is not a bearing capacity. Capacity asks when the ground gives '
          'way altogether; k asks how far it moves long before that. And '
          'because a slab already spreads the load so widely, improving k buys '
          'less under concrete than under asphalt.',
    ),
  ],
  spoken: [
    (
      'What it is',
      r'k = \dfrac{\text{pressure}}{\text{deflection}}',
      'the push needed for each inch the ground moves',
    ),
    ('Units', r'\text{pci}', 'pounds per cubic inch'),
    ('Higher k', r'\text{stiffer ground}', 'less movement under the same push'),
  ],
  handbook: 'Handbook, rigid pavement',
);

const forwardPassBrief = BriefSection(
  title: 'Two rules carry you forward',
  picture: forwardPassPicture,
  steps: [
    (
      'Jobs wait on other jobs',
      'You cannot paint a wall before it is built. A schedule is a list of '
          'jobs, how many days each takes, and which ones have to finish first. '
          'The drawing is that list with arrows.',
    ),
    (
      'Rule one: add the days',
      'A job finishes its own number of days after it starts. Start on day '
          'four, take six days, finish on day ten. Days in a row add up. They '
          'never multiply.',
    ),
    (
      'Rule two: at a meeting point, wait for the slowest',
      'When a job waits on two others, it starts when the LATER one '
          'finishes, not the earlier one and not the average. Two jobs waiting '
          'on the same thing both start the moment it ends. Nothing makes them '
          'take turns.',
    ),
    (
      'Answer the question that was asked',
      'The finish of the job itself, not the finish of the one before it and '
          'not its own length. Both of those numbers sit right there in the '
          'problem, waiting to be picked up by mistake.',
    ),
  ],
  spoken: [
    (
      'The finish',
      r'EF = ES + D',
      'early finish is early start plus how long the job takes',
    ),
    (
      'At a meeting point',
      r'ES = \max(EF \text{ of the jobs before})',
      'a job starts when the last thing it waits on has finished',
    ),
    (
      'In a row',
      r'\text{durations add}',
      'days one after another simply add up',
    ),
  ],
  handbook: 'Handbook, CPM scheduling',
);

const projectDurationBrief = BriefSection(
  title: 'A job takes as long as its longest route',
  picture: projectDurationPicture,
  steps: [
    (
      'Find the routes, then take the longest',
      'Trace every path from the start of the drawing to the end and add up '
          'the days along each. The job takes as long as the longest one. That '
          'is the whole answer.',
    ),
    (
      'Not everything added up',
      'Adding every job counts work that happens at the same time twice '
          'over. And it is not the single longest job either. It is the longest '
          'ROUTE.',
    ),
    (
      'Everything off that route has spare time',
      'A job on a shorter route finishes and then waits. Speeding it up '
          'changes nothing, so money spent rushing it is wasted.',
    ),
    (
      'The longest route can move',
      'Stretch a branch that had spare time and it becomes the longest one, '
          'as the second drawing shows. That is why a schedule gets worked out '
          'again instead of drawn once.',
    ),
  ],
  spoken: [
    (
      'How long the job takes',
      r'\text{the longest route through}',
      'add the days along each path and take the biggest total',
    ),
    (
      'Not',
      r'\textstyle\sum \text{every job}',
      'adding everything counts work that happens side by side twice',
    ),
    (
      'Off that route',
      r'\text{there is spare time}',
      'those jobs can slip without moving the finish',
    ),
  ],
  handbook: 'Handbook, CPM scheduling',
);

const passesBrief = BriefSection(
  title: 'Forward, then backward',
  picture: passesPicture,
  steps: [
    (
      'Two sweeps, two questions',
      'Go through the drawing left to right and you learn the earliest each '
          'job can happen. Come back right to left and you learn the latest it '
          'can happen without making the whole job late.',
    ),
    (
      'Going forward, add and take the later one',
      'Add each job length as you go. Where a job waits on two others, take '
          'the LATER finish, because it cannot start until both are done.',
    ),
    (
      'Coming back, subtract and take the earlier one',
      'Start from the finish date you just worked out. Subtract each job '
          'length. Where one job feeds several, take the EARLIEST of their late '
          'starts, because it has to be out of the way for all of them.',
    ),
    (
      'That flip is the thing to remember',
      'Forward takes the later. Backward takes the earlier. The gap between '
          'a job\'s earliest and latest is its spare time.',
    ),
  ],
  spoken: [
    (
      'Forward',
      r'EF = ES + D,\; ES = \max(EF_{\text{before}})',
      'add the days, and at a meeting point take the later finish',
    ),
    (
      'Backward',
      r'LS = LF - D,\; LF = \min(LS_{\text{after}})',
      'subtract the days, and where one job feeds several take the earlier start',
    ),
    (
      'Where backward starts',
      r'LF_{\text{last}} = \text{the finish date}',
      'the last job must finish on the date the forward sweep produced',
    ),
  ],
  handbook: 'Handbook, CPM scheduling',
);

const floatBrief = BriefSection(
  title: 'How much a job can slip',
  picture: floatPicture,
  steps: [
    (
      'Some jobs have room, some have none',
      'Both drawings are the same five jobs. In the first, C runs at its '
          'earliest, day three to day five. In the second it waits until day '
          'eight, and the job still finishes on time. Those five days are C\'s '
          'room to slip.',
    ),
    (
      'Total float: room before the JOB is late',
      'Latest start minus earliest start. Or latest finish minus earliest '
          'finish. Both give the same number, so working out one and checking '
          'the other is free.',
    ),
    (
      'Free float: room before the NEXT job is pushed',
      'A smaller question, and a smaller number. It is how long you can slip '
          'before the thing waiting on you has to move. Free float is never the '
          'bigger of the two.',
    ),
    (
      'The room belongs to the route, not the job',
      'Two jobs in a row each showing four days are sharing the same four '
          'days. Whoever uses it first takes it from the other. No room at all '
          'means the job is critical.',
    ),
  ],
  spoken: [
    (
      'Total float',
      r'TF = LS - ES = LF - EF',
      'latest minus earliest, either as starts or as finishes',
    ),
    (
      'Free float',
      r'FF = \min(ES_{\text{after}}) - EF',
      'the earliest start of what comes next, minus this job\'s early finish',
    ),
    ('Critical', r'TF = 0', 'no room to slip at all'),
  ],
  handbook: 'Handbook, CPM scheduling',
);

const criticalPathBrief = BriefSection(
  title: 'The chain that decides the finish date',
  picture: criticalPathPicture,
  steps: [
    (
      'The longest route, marked',
      'Three ways through this drawing. The marked one is the longest, and '
          'its length IS how long the job takes.',
    ),
    (
      'It is also the chain with no spare time',
      'Those are two descriptions of the same jobs. If the longest route had '
          'spare time in it, a longer route would have to exist somewhere, and '
          'it does not.',
    ),
    (
      'A day lost there is a day lost everywhere',
      'There is no cushion anywhere along the chain, so delay goes straight '
          'through to the finish date. Lose a day off the chain and you only '
          'spend spare time. Spend it all and that route turns critical too.',
    ),
    (
      'That is the whole point of the method',
      'It says exactly where hurrying buys time and where it buys nothing. '
          'Two routes can tie for longest, and then speeding up only one of them '
          'buys nothing either.',
    ),
  ],
  spoken: [
    (
      'The longest route',
      r'= \text{how long the job takes}',
      'its length is the finish date',
    ),
    (
      'And also',
      r'\text{the chain with } TF = 0',
      'the same jobs, described by having no spare time',
    ),
    (
      'A day lost on it',
      r'\text{is a day lost to the whole job}',
      'delay on the critical chain moves the finish date straight away',
    ),
  ],
  handbook: 'Handbook, CPM scheduling',
);

const earnedValueBrief = BriefSection(
  title: 'Three numbers, two subtractions',
  picture: earnedValuePicture,
  steps: [
    (
      'Three bars on one date',
      'What the plan said would be done by now. What the work actually '
          'finished is WORTH, priced at the budget. And what has actually been '
          'paid out.',
    ),
    (
      'The middle bar is the one that matters',
      'It is the only one that says what really got done. The first is a '
          'promise, the third is a stack of bills. Both gaps are measured from '
          'the middle bar.',
    ),
    (
      'Earned minus SPENT is the money answer',
      'Negative means more money went out than the work was worth. That is '
          'over budget.',
    ),
    (
      'Earned minus PLANNED is the calendar answer',
      'Negative means less got done than the plan asked for. That is behind. '
          'They are reported separately because a job is often behind AND under '
          'budget at once: a good crew that is short handed.',
    ),
  ],
  spoken: [
    (
      'Money',
      r'CV = BCWP - ACWP',
      'what the work was worth, minus what was spent',
    ),
    (
      'Calendar',
      r'SV = BCWP - BCWS',
      'what the work was worth, minus what was planned',
    ),
    (
      'Either one',
      r'\text{negative is bad}',
      'a minus sign means behind, or over budget',
    ),
  ],
  handbook: 'Handbook, earned value',
);

const forecastBrief = BriefSection(
  title: 'At this rate, what will the whole thing cost',
  picture: forecastPicture,
  steps: [
    (
      'What is each dollar buying',
      'Divide what the work was worth by what was spent on it. Earned goes '
          'on TOP. Here that is eighty cents of value for every dollar paid. '
          'Below one is trouble.',
    ),
    (
      'Do not turn the fraction over',
      'Upside down it comes out above one and looks healthy. That wrong '
          'answer is always printed as a choice.',
    ),
    (
      'The rest of the job costs more too',
      'Take the work still to do, priced at budget, and divide by that same '
          'rate. At eighty cents on the dollar, 1.4 million of remaining work '
          'will cost 1.75 million. Reporting the 1.4 assumes the crew suddenly '
          'starts hitting budget.',
    ),
    (
      'Then add what is already gone',
      'Spent so far, plus the rest. Each half of that sum on its own is one '
          'of the wrong answers. A rate of exactly one makes the dividing do '
          'nothing and lands you back on the original budget.',
    ),
  ],
  spoken: [
    ('The rate', r'CPI = BCWP / ACWP', 'value earned divided by money spent'),
    (
      'The rest',
      r'ETC = (BAC - BCWP)/CPI',
      'the work still to do at budget, divided by the rate you are managing',
    ),
    (
      'The whole thing',
      r'EAC = ACWP + ETC',
      'what is already spent, plus what the rest will cost',
    ),
  ],
  handbook: 'Handbook, earned value forecasting',
);

const excavationBrief = BriefSection(
  title: 'Five feet, and twenty',
  picture: excavationPicture,
  steps: [
    (
      'A hole in the ground can fall in',
      'A cubic yard of soil weighs about as much as a car, and a trench '
          'gives no warning before the sides come in. That is why there are '
          'depth rules at all.',
    ),
    (
      'Past five feet, the sides must be held',
      'Any of three will do: slope or step the sides back to a safe angle, '
          'shore them to hold them in place, or drop in a trench box, which '
          'protects the people rather than the hole. Which one is a question of '
          'soil, room and cost, not of the rule.',
    ),
    (
      'Past twenty feet, an engineer must design it',
      'The ready made tables most systems rely on stop at twenty. Deeper '
          'than that and a registered professional engineer has to design the '
          'protection.',
    ),
    (
      'Under five feet the rule does not bite',
      'Which is not the same as the hole being safe. The weakest soil, type '
          'C, needs the flattest slope, one and a half across for every one '
          'down, and that is often what pushes a job toward a box instead.',
    ),
  ],
  spoken: [
    (
      'Over five feet',
      r'\text{slope it, shore it, or box it}',
      'a protective system is required, and any of the three counts',
    ),
    (
      'Over twenty feet',
      r'\text{designed by a professional engineer}',
      'past twenty the tables run out and it has to be engineered',
    ),
    (
      'Type C soil',
      r'1.5\text{H}:1\text{V}',
      'one and a half feet across for every foot down',
    ),
  ],
  handbook: 'OSHA 29 CFR 1926, excavations',
);

const fallProtectionBrief = BriefSection(
  title: 'Six feet in the air',
  picture: fallProtectionPicture,
  steps: [
    (
      'Six feet up, something has to be in place',
      'In general construction work, that is the line. Below it the rule '
          'does not fire. At or above it, one of three things is required.',
    ),
    (
      'Stop it, catch it, or hold them short',
      'Guardrails stop the fall happening. Safety nets catch the person. A '
          'harness and lanyard lets them fall a little and then stops them. The '
          'rule names the outcome and leaves the method to the job.',
    ),
    (
      'One exception worth knowing',
      'Workers connecting steel have a higher line, fifteen feet, because '
          'the gear needed to protect them lower down would create hazards of '
          'its own.',
    ),
    (
      'Five down, six up',
      'Five feet is the trench rule, six feet is the fall rule, and these '
          'two get swapped more than anything else in the chapter. Worth one '
          'deliberate moment.',
    ),
  ],
  spoken: [
    (
      'General construction',
      r'6 \text{ ft}',
      'fall protection from six feet up',
    ),
    (
      'Steel connectors',
      r'15 \text{ ft}',
      'the higher line for workers connecting steel',
    ),
    (
      'The pair',
      r'5 \text{ down},\; 6 \text{ up}',
      'five feet in the ground, six feet in the air',
    ),
  ],
  handbook: 'OSHA 29 CFR 1926, fall protection',
);

const yardsBrief = BriefSection(
  title: 'Cut and fill, paid for in yards',
  picture: yardsPicture,
  steps: [
    (
      'Slice the road and measure each slice',
      'At stations along the job, someone measures the area of dirt to be '
          'cut away or filled in. The volume between two slices is the average '
          'of their areas, times the distance between them.',
    ),
    (
      'The formula gives cubic FEET',
      'Areas in square feet and distances in feet can only give cubic feet. '
          'But earthwork is bid, hauled and paid for in cubic YARDS.',
    ),
    (
      'A cubic yard is 27 cubic feet',
      'Three feet each way, so three times three times three. Dividing by '
          'three instead leaves the answer nine times too big; forgetting the '
          'conversion leaves it twenty seven times too big. Both are printed as '
          'choices.',
    ),
    (
      'Which method matters commercially',
      'Averaging the two ends overstates the volume whenever the real '
          'middle slice sags below that average, which it usually does. On a '
          'job moving millions of yards, a few per cent is real money, so the '
          'contract says which method measures the work.',
    ),
  ],
  spoken: [
    (
      'End areas',
      r'V = \frac{L}{2}(A_1 + A_2)',
      'the average of the two end areas, times the distance',
    ),
    (
      'Prismoidal',
      r'V = \frac{L}{6}(A_1 + 4A_m + A_2)',
      'a weighted average that counts the middle slice four times',
    ),
    ('Then', r'\div 27', 'cubic feet into cubic yards'),
  ],
  handbook: 'Handbook, earthwork volumes',
);

const deliveryFitBrief = BriefSection(
  title: 'Matching the way you build it to the job',
  picture: deliveryFitPicture,
  steps: [
    (
      'Design, bid, build: finish the drawings first',
      'Everything in order. The drawings get finished, builders price the '
          'same complete package, the lowest price wins. Nothing can start '
          'early, because there is nothing to bid on until the drawings are '
          'done. Pick it when the design is settled and the price has to '
          'compete.',
    ),
    (
      'Design-build: one firm does both',
      'A single agreement covers drawing and building, so building can '
          'start on a part drawn job and the whole thing finishes sooner. The '
          'owner has one firm to hold responsible, and accepts less certainty '
          'about what is being built.',
    ),
    (
      'Manager at risk: a builder in the room early',
      'The owner keeps its own designer but brings a builder in during '
          'design for advice. Part way through, that builder names a ceiling '
          'price and pays for anything over it. That is what at risk means.',
    ),
  ],
  spoken: [
    (
      'Drawings done, price must compete',
      r'\text{design, bid, build}',
      'in order, with every bidder pricing the same finished package',
    ),
    (
      'Speed, and one firm responsible',
      r'\text{design-build}',
      'one agreement for both, so building can overlap drawing',
    ),
    (
      'Advice during design, plus a ceiling',
      r'\text{manager at risk}',
      'the builder joins early and guarantees a maximum price',
    ),
  ],
  handbook: 'Handbook, project delivery',
);

const curveConversionBrief = BriefSection(
  title: 'Radius, degree, and the run out to the corner',
  picture: curveConversionPicture,
  steps: [
    (
      'A bend is quoted two ways',
      'The RADIUS is how far away the center of the circle is: a length. '
          'The DEGREE OF CURVE is how much the road turns in a hundred feet: '
          'an angle.',
    ),
    (
      'They run in opposite directions',
      'A tight bend has a small radius and a big degree. Their product is '
          'always 5,729.58, so you divide that number by one to get the other.',
    ),
    (
      'A free check on the arithmetic',
      'Multiply instead of divide and you get tens of thousands of feet, '
          'which is not a highway bend at all but nearly a straight line. That '
          'catches the slip without redoing the work.',
    ),
    (
      'Out to the corner, use HALF the turn',
      'The tangent runs from where the curve starts out to where the two '
          'straight roads would have crossed. The bend is even about that '
          'point, so each side only sees half the turn. Using the whole angle '
          'roughly doubles the answer.',
    ),
  ],
  spoken: [
    (
      'The two quotes',
      r'R = \dfrac{5{,}729.58}{D}',
      'the fixed number divided by the degree of curve gives the radius',
    ),
    (
      'Out to the corner',
      r'T = R\tan\dfrac{I}{2}',
      'the radius times the tangent of half the turn angle',
    ),
    (
      'Around the arc',
      r'L = \dfrac{\pi R I}{180}',
      'the length of road actually on the curve',
    ),
  ],
  handbook: 'Handbook, horizontal curves',
);

const cornerOffsetBrief = BriefSection(
  title: 'How far the road misses the corner',
  picture: cornerOffsetPicture,
  steps: [
    (
      'The two slopes meet at a sharp point',
      'No car could drive over that corner. So the road is curved, and it '
          'passes INSIDE the corner: below it on a hump, above it in a dip.',
    ),
    (
      'How far inside is the offset',
      'It is the grade break as a decimal, times the length of the curve, '
          'divided by eight. The eight comes from the shape of the curve, '
          'which pulls away from the corner faster and faster.',
    ),
    (
      'Two ways it goes wrong',
      'Dividing by four instead of eight doubles the answer. Putting the '
          'break in as a per cent instead of a decimal multiplies it by a '
          'hundred. Both are printed as choices.',
    ),
    (
      'It is a real height',
      'Every elevation along the curve and every yard of dirt to be moved '
          'is worked from this number. Make the curve twice as long and the '
          'offset doubles, which is why a gentler road costs more digging.',
    ),
  ],
  spoken: [
    (
      'At the middle',
      r'E = \dfrac{(g_2 - g_1)L}{8}',
      'the grade break times the curve length, over eight',
    ),
    ('As a decimal', r'8\% = 0.08', 'per cent divided by a hundred'),
    (
      'Why it is not straight',
      r'E \propto x^2',
      'the drop from the corner grows with the distance times itself',
    ),
  ],
  handbook: 'Handbook, vertical curves',
);

const stiffnessBrief = BriefSection(
  title: 'A slope is not a height',
  picture: stiffnessPicture,
  steps: [
    (
      'Three questions about one curve',
      'How hard is it to move at all? How much can it carry before it gives '
          'way? How far does it go before it breaks? Stiffness, strength and '
          'stretchiness. Three different features of the same drawing.',
    ),
    (
      'Stiffness is the slope',
      'Take any point on the straight first part and divide the stress by '
          'the strain. That is the elastic modulus, and it is just how steeply '
          'the line starts. Steep means hard to stretch.',
    ),
    (
      'Strength is the height',
      'How high the curve gets is a separate question. Cast iron starts '
          'steeply and stops low: stiff but weak. An aluminum alloy starts '
          'shallow and climbs far higher: springy but strong.',
    ),
    (
      'Which one is your problem',
      'A floor that bounces is too soft, not too weak, so a stronger steel '
          'changes nothing: every steel is about equally stiff. Aluminum is a '
          'third as stiff as steel, so the same beam in aluminum sags about '
          'three times as far.',
    ),
  ],
  spoken: [
    (
      'Strain',
      r'\varepsilon = \frac{\Delta L}{L_0}',
      'how much it grew, over the length it started with',
    ),
    (
      'The modulus',
      r'E = \frac{\sigma}{\varepsilon}',
      'stress over strain: the slope of the straight part',
    ),
    (
      'Worth carrying',
      r'E_{steel} \approx 200\text{ GPa},\; E_{al} \approx 70',
      'steel is about three times as stiff as aluminum',
    ),
  ],
  handbook: 'Handbook, mechanical properties',
);

const filterRateBrief = BriefSection(
  title: 'Down through the bed',
  picture: filterRatePicture,
  steps: [
    (
      'The water goes straight down',
      'A sand filter is a box of sand with water pouring onto the top of it. '
          'So what matters is the bed seen from above: its plan area, length '
          'times width.',
    ),
    (
      'Flow over that area is the loading rate',
      'Divide by one dimension instead and the units give you away. A rate '
          'per foot is not a rate per square foot.',
    ),
    (
      'The ranges are part of the answer',
      'Rapid sand runs between about two and ten gallons a minute per square '
          'foot. Slow sand runs near a tenth of that, so it needs tens of times '
          'the land for the same flow, and buys a living filter layer with it.',
    ),
    (
      'Twice the bed halves the rate',
      'That is the design lever. The same arithmetic on a settling tank is '
          'the overflow rate, quoted per day with ranges in the hundreds. The '
          'pattern carries across; the numbers do not.',
    ),
  ],
  spoken: [
    (
      'The rate',
      r'v = \frac{Q}{A_{plan}}',
      'the flow divided by the bed seen from above',
    ),
    (
      'Rapid sand',
      r'2 \text{ to } 10 \text{ gpm/ft}^2',
      'the usual working range',
    ),
    ('Slow sand', r'\approx 0.1 \text{ gpm/ft}^2', 'about a hundredth as fast'),
  ],
  handbook: 'Handbook, filtration',
);

const rankineBrief = BriefSection(
  title: 'Three states of the very same soil',
  picture: rankinePicture,
  steps: [
    (
      'The soil pushes on the wall',
      'Pile earth behind a wall and it presses sideways. How hard is not one '
          'number: it depends on whether the wall gives way at all.',
    ),
    (
      'Let it lean away a whisker',
      'Even a fraction of an inch and the soil stretches out behind, takes '
          'some of the load on itself, and pushes less. That is the ACTIVE '
          'state, the smallest of the three, and most walls are designed for '
          'it.',
    ),
    (
      'Hold it dead still',
      'A basement wall propped by its floor slab cannot move at all, so the '
          'soil never gets to relax. That is AT REST, and it is noticeably '
          'bigger. Design a basement wall for active pressure and it is '
          'under-designed.',
    ),
    (
      'Push the wall INTO the soil',
      'Now the soil has to be shoved out of the way and it fights hard: '
          'PASSIVE, about nine times the active value for a typical soil, and '
          'it takes a lot of movement to wake up. Active and passive are '
          'reciprocals: if one is a third the other is three.',
    ),
  ],
  spoken: [
    (
      'Active',
      r'K_a = \tan^2(45 - \phi/2)',
      'the wall leaned away, so the smallest push',
    ),
    (
      'Passive',
      r'K_p = \tan^2(45 + \phi/2)',
      'the wall shoved in, so the biggest push',
    ),
    (
      'At rest',
      r'K_0 \approx 1 - \sin\phi',
      'the wall did not move, so somewhere in between',
    ),
  ],
  handbook: 'Handbook, lateral earth pressure',
);

const diagramShapeBrief = BriefSection(
  title: 'A triangle, and a rectangle on top of it',
  picture: diagramShapePicture,
  steps: [
    (
      'Soil presses harder the deeper you go',
      'At the top of the wall there is almost nothing above, so almost no '
          'push. At the bottom there is the whole height of soil. Straight '
          'between the two: a TRIANGLE.',
    ),
    (
      'A triangle pushes a third of the way up',
      'Its fat end is at the bottom, so the one force standing for the whole '
          'triangle acts a third of the height up from the base.',
    ),
    (
      'A load on the ground behind is different',
      'A parking lot or a stockpile presses down everywhere alike, and the '
          'soil passes a share of that sideways at EVERY depth, top included. '
          'Same push all the way down: a RECTANGLE, acting at mid height.',
    ),
    (
      'Add the forces, not the heights',
      'Each one turns the wall about its own arm, so an overturning check '
          'takes them separately. A modest surcharge is worth more than it '
          'looks, because its rectangle covers the whole wall while the soil '
          'triangle spends its top few feet near nothing.',
    ),
  ],
  spoken: [
    (
      'The soil',
      r'\tfrac{1}{2}K_a\gamma H^2 \text{ at } H/3',
      'the triangle, acting a third of the way up',
    ),
    (
      'A load behind',
      r'K_a q H \text{ at } H/2',
      'the rectangle, acting halfway up',
    ),
    (
      'Together',
      r'\text{the forces add}',
      'but each keeps its own height above the base',
    ),
  ],
  handbook: 'Handbook, lateral earth pressure',
);

const wallForceBrief = BriefSection(
  title: 'The half, and the square',
  picture: wallForcePicture,
  steps: [
    (
      'The half is just a triangle',
      'The push runs from nothing at the top to its biggest at the base, so '
          'on average it is half the biggest. Force is that average times the '
          'height. Drop the half and you double your answer.',
    ),
    (
      'The square is two things at once',
      'Build the wall twice as tall and there is twice as much soil, AND the '
          'push at the base is twice as big. Two doublings multiply: FOUR '
          'times the force.',
    ),
    (
      'The moment is worse still',
      'That bigger force also acts twice as high up, so the turning effect '
          'goes up EIGHT times. That is why tall walls get expensive out of '
          'all proportion, and why a bank is often terraced instead.',
    ),
    (
      'The force is only the start',
      'Weight and the soil coefficient scale the answer straight, no powers. '
          'And getting the force is not the design: sliding, overturning and '
          'bearing are three separate checks after it.',
    ),
  ],
  spoken: [
    (
      'The force',
      r'P_a = \tfrac{1}{2}K_a\gamma H^2',
      'half the coefficient times the weight times the height squared',
    ),
    (
      'Twice as tall',
      r'4\times \text{ the force}',
      'twice the soil and twice the push at the base',
    ),
    (
      'The turning effect',
      r'8\times',
      'four times the force, acting twice as high',
    ),
  ],
  handbook: 'Handbook, lateral earth pressure',
);

const trussRouteBrief = BriefSection(
  title: 'Cut to one bar, or work round one joint',
  picture: trussRoutePicture,
  steps: [
    (
      'Both ways work, so pick the quick one',
      'Every determinate truss can be solved either way. The only question '
          'is how much arithmetic you sign up for.',
    ),
    (
      'One bar, deep in the middle: cut',
      'A single slice reaches it directly and one equation finishes it. '
          'Walking joint by joint to the same bar means four or five joints in a '
          'row, every one of them a chance to slip.',
    ),
    (
      'Several bars at one corner: joints',
      'If the question names a connection, that connection IS the free body. '
          'Near a support it is quicker still, because the reaction is already '
          'sitting there.',
    ),
    (
      'Reactions first, whichever you choose',
      'Take the whole truss as one object and find what the ground pushes '
          'back with. A cut leaves you holding a reaction, and a support joint '
          'IS one. Skip it and you stall.',
    ),
  ],
  spoken: [
    (
      'One bar, deep',
      r'\text{cut a section}',
      'slice through and take moments once',
    ),
    (
      'A whole connection',
      r'\text{work the joint}',
      'that joint is already the free body asked about',
    ),
    (
      'Before either',
      r'\text{the reactions}',
      'what the supports push back with',
    ),
  ],
  handbook: 'Handbook p. 271',
);

const naturalBrief = BriefSection(
  title: 'Stiffness over weight, under a square root',
  picture: naturalPicture,
  steps: [
    (
      'Everything springy has a rate it likes',
      'Pull a block on a spring aside and let go, and it bounces at one '
          'particular rate. That rate is its own, and it depends on only two '
          'things.',
    ),
    (
      'Stiffer is quicker, heavier is slower',
      'A stiff spring snaps back harder, so it bounces faster. A heavy block '
          'is more sluggish, so it bounces slower. It is the RATIO of the two, so '
          'doubling both changes nothing.',
    ),
    (
      'The square root softens both',
      'Four times the stiffness is only twice the rate. Four times the weight '
          'is half the rate. Nothing about it is proportional.',
    ),
    (
      'How far you pull it does not matter',
      'A big swing simply travels further at the same rate. And watch the '
          'units: the formula gives radians per second, while the question often '
          'wants cycles per second.',
    ),
  ],
  spoken: [
    (
      'Its own rate',
      r'\omega_n = \sqrt{\frac{k}{m}}',
      'the square root of the stiffness divided by the mass',
    ),
    (
      'In cycles per second',
      r'f_n = \frac{\omega_n}{2\pi}',
      'that rate divided by two pi',
    ),
    (
      'The time for one bounce',
      r'T_n = \frac{1}{f_n}',
      'one over the cycles per second',
    ),
    (
      'Twisting instead',
      r'\omega_n = \sqrt{\frac{k_t}{I}}',
      'the same shape, with twisting stiffness over how hard it is to spin',
    ),
  ],
  handbook: 'Handbook pp. 112 to 113',
);

const resonanceBrief = BriefSection(
  title: 'Resonance is a match, not a property',
  picture: resonancePicture,
  steps: [
    (
      'Push a swing at the right moments',
      'Time your pushes to the swing and every one adds to the last, and the '
          'swing goes higher and higher. Push at the wrong times and you fight it '
          'and nothing much happens.',
    ),
    (
      'A structure is the same',
      'Nothing resonates on its own. Resonance is what happens when something '
          'shakes it AT its own rate, and the swinging climbs until the damping '
          'or the structure gives way.',
    ),
    (
      'So the design question is a comparison',
      'Work out the structure\'s own rate, find out what is going to shake '
          'it, and keep the two apart. Far above is safe, far below is safe, only '
          'the middle is dangerous.',
    ),
    (
      'Which way engineers aim',
      'Machine mountings are made deliberately soft so the running speed sits '
          'well above the natural rate. That does mean the machine passes through '
          'resonance on its way up to speed.',
    ),
  ],
  spoken: [
    (
      'Resonance when',
      r'\omega = \omega_n',
      'the shaking rate matches the structure\'s own rate',
    ),
    (
      'Same thing in other units',
      r'1\ \mathrm{Hz} = 2\pi\ \mathrm{rad/s}',
      'one cycle per second is two pi radians per second',
    ),
    (
      'And from a machine plate',
      r'1\ \mathrm{Hz} = 60\ \mathrm{rpm}',
      'one cycle per second is sixty turns a minute',
    ),
  ],
  handbook: 'Handbook p. 112',
);

const dampingBrief = BriefSection(
  title: 'What the damping decides',
  picture: dampingPicture,
  steps: [
    (
      'Pull it aside and let go',
      'What happens next is decided by one number: how much the motion is '
          'being resisted. Four things can happen, and the pictures are worth '
          'more than the formula.',
    ),
    (
      'A little damping: it swings and fades',
      'It crosses back and forth inside a shrinking envelope. That is almost '
          'every real structure: buildings and bridges run at a few percent and '
          'ring for a long time.',
    ),
    (
      'Just enough: straight back, no overshoot',
      'The fastest possible return without crossing the line at all. A door '
          'closer, a gun recoil and an instrument needle are all tuned to sit '
          'right here.',
    ),
    (
      'Too much is slower, not quicker',
      'Past that point it still does not swing, but it takes LONGER to get '
          'back. That is the piece people expect to go the other way. And with '
          'none at all it swings for ever, which nothing real does.',
    ),
  ],
  spoken: [
    (
      'The damping number',
      r'\zeta = \frac{c}{2\sqrt{km}} = \frac{c}{c_c}',
      'how much resistance there is, against how much it would take to stop the swinging',
    ),
    (
      'Swings and never shrinks',
      r'\zeta = 0',
      'no resistance at all, the ideal every free vibration formula is written for',
    ),
    (
      'Swings and fades',
      r'\zeta < 1',
      'a little resistance, almost every real structure',
    ),
    (
      'Straight back, fastest',
      r'\zeta = 1',
      'exactly enough to stop it overshooting',
    ),
    ('No swing, but slower', r'\zeta > 1', 'more than enough, and it drags'),
  ],
  handbook: 'Handbook p. 112',
);

const farFromAxisBrief = BriefSection(
  title: 'Distance does the work, not amount',
  picture: farFromAxisPicture,
  steps: [
    (
      'Try to bend a ruler',
      'Flat side up, it bends easily. Turn it on edge and you can barely move '
          'it. Same ruler, same material, same amount of plastic. Only the '
          'direction changed.',
    ),
    (
      'Why: distance counts twice over',
      'Stiffness adds up area times distance from the middle SQUARED. '
          'Squared, so material twice as far out counts four times as much. '
          'Material sitting on the middle line counts almost nothing.',
    ),
    (
      'For a rectangle, depth is cubed',
      'Width counts once, depth counts three times over. Make a joist twice '
          'as deep and it is eight times stiffer. Make it twice as wide and it is '
          'only twice as stiff.',
    ),
    (
      'Which is why an I beam looks like that',
      'All the steel is pushed out to the top and bottom flanges, far from '
          'the middle, and the web in between is only as thick as it has to be.',
    ),
  ],
  spoken: [
    (
      'What it is',
      r'I_x = \int y^2\, dA',
      'every bit of area, times its distance from the middle squared',
    ),
    (
      'Rectangle',
      r'I_{xc} = \frac{bh^3}{12}',
      'width times depth cubed, over twelve',
    ),
    (
      'Circle',
      r'I_{xc} = \frac{\pi r^4}{4}',
      'pi times the radius to the fourth, over four',
    ),
  ],
  handbook: 'Handbook pp. 98 to 100',
);

const transferBrief = BriefSection(
  title: 'Moving the stiffness to another line',
  picture: transferPicture,
  steps: [
    (
      'A shape is least stiff about its own middle',
      'Measure stiffness about the shape\'s own balance line and you get the '
          'smallest number there is. Any other line gives a bigger one.',
    ),
    (
      'Moving away costs area times distance squared',
      'Shift to a line a distance d away and you ADD the area times d '
          'squared. That extra term is often bigger than the shape\'s own '
          'stiffness.',
    ),
    (
      'Coming back takes it off',
      'Going the other way, from some line back to the shape\'s own middle, '
          'you subtract the same term.',
    ),
    (
      'It only runs through the middle line',
      'The rule cannot jump straight between two lines that are both off '
          'center. Go back to the shape\'s own middle first, then out to the new '
          'line.',
    ),
  ],
  spoken: [
    (
      'Parallel axis theorem',
      r'I_x = \bar{I}_{xc} + Ad^2',
      'its own stiffness, plus area times the distance squared',
    ),
    ('Leaving its own middle', r'+\,Ad^2', 'add the transfer term'),
    ('Arriving at its own middle', r'-\,Ad^2', 'take the transfer term off'),
  ],
  handbook: 'Handbook p. 95',
);

const compositeIBrief = BriefSection(
  title: 'Where a built-up section gets its stiffness',
  picture: compositeIPicture,
  steps: [
    (
      'Add it up piece by piece',
      'Each piece brings two things: its own stiffness about its own middle, '
          'and the transfer term for how far it sits from the WHOLE section\'s '
          'balance line.',
    ),
    (
      'Measure to the whole section\'s middle, every time',
      'Not to the piece, not to the base. That one line, for every piece. '
          'Mixing them up is the usual way this goes wrong.',
    ),
    (
      'The transfer terms are usually the bigger half',
      'On almost any real section, how far the pieces sit out matters more '
          'than how stiff they are on their own.',
    ),
    (
      'So position beats size',
      'A small piece far out can carry most of the section. A big piece '
          'sitting on the middle line adds almost nothing. That is why an I beam '
          'has fat flanges and a thin web, and why service holes go through the '
          'middle of a beam.',
    ),
  ],
  spoken: [
    (
      'Piece by piece',
      r'I_x = \sum \left( \bar{I}_i + A_i d_i^2 \right)',
      'each piece\'s own stiffness plus its area times its distance squared',
    ),
    (
      'Measured to',
      r'\text{the balance line of the whole section}',
      'the same line for every piece',
    ),
    (
      'Which is why',
      r'd^2',
      'squared, so material on the middle line is wasted',
    ),
  ],
  handbook: 'Handbook p. 95',
);

const polarBrief = BriefSection(
  title: 'Bending needs I, twisting needs J',
  picture: polarPicture,
  steps: [
    (
      'Two different jobs',
      'Pushing a beam sideways bends it. Twisting a shaft along its own '
          'length wrings it. They use two different stiffness numbers and mixing '
          'them up is on this chapter\'s trap list.',
    ),
    (
      'Bending uses the axis SQUARE to the push',
      'Push down and the beam bends about its flat, horizontal axis. Push '
          'sideways and it bends about the upright one. It does not matter which '
          'axis is the stronger; the push decides.',
    ),
    (
      'Twisting uses the polar one',
      'Twist about the member\'s own length and every bit of material '
          'resists, in every direction. That is J, and it is simply the two I '
          'values added about the same point.',
    ),
    (
      'For a round shaft, J is exactly twice I',
      'Because the two I values are equal. So reaching for the wrong one '
          'costs you a clean factor of two.',
    ),
  ],
  spoken: [
    (
      'Bending',
      r'\sigma = \frac{Mc}{I}',
      'bending stress uses I, about the axis square to the push',
    ),
    ('Twisting', r'\tau = \frac{Tc}{J}', 'twisting stress uses the polar J'),
    ('And the polar one is', r'J = I_x + I_y', 'the two I values added'),
  ],
  handbook: 'Handbook p. 95',
);

const areaWeightedBrief = BriefSection(
  title: 'The balance point sits where the material is',
  picture: areaWeightedPicture,
  steps: [
    (
      'Cut the shape out of card and balance it',
      'The point it balances on is the centroid. It slides toward whichever '
          'end has more material, exactly the way a seesaw tips toward the '
          'heavier child.',
    ),
    (
      'So halfway up is usually wrong',
      'The middle of the height is only right when the shape is the same '
          'above and below that line. A tee has a big flange on top, so its '
          'balance point sits high.',
    ),
    (
      'Weight each piece by its area',
      'Break the shape into simple pieces. Multiply each piece\'s area by how '
          'far up its own middle sits, add those up, and divide by the total '
          'area.',
    ),
    (
      'A hole is a piece with negative area',
      'Subtract it, top and bottom of the fraction. A hole pushes the balance '
          'point AWAY from itself, because the material it removed was holding '
          'that side down.',
    ),
  ],
  spoken: [
    (
      'Composite centroid',
      r'\bar{y} = \frac{\sum A_i\, y_i}{\sum A_i}',
      'each area times its own height, added, over the total area',
    ),
    ('A hole', r'A_i < 0', 'counted as a negative area'),
    (
      'First moment of area',
      r'Q_x = \sum A_i\, y_i',
      'the top of that fraction on its own',
    ),
  ],
  handbook: 'Handbook p. 95',
);

const tableBrief = BriefSection(
  title: 'The handbook already has every shape',
  picture: tablePicture,
  steps: [
    (
      'You never integrate for this on the exam',
      'The handbook lists the balance point of rectangles, triangles, '
          'circles, half discs, quarter discs and parabolas. The work is '
          'recognizing the shape and reading from the right corner.',
    ),
    (
      'A triangle sits a third of the way up',
      'Measured from the base, not the point. And a third of the way in from '
          'the upright side. Mirror the triangle and the answer moves with it.',
    ),
    (
      'A half circle sits a little over four tenths of the radius',
      'Measured up from the flat side. Four r over three pi, which works out '
          'to about 0.42 r, noticeably lower than half the radius.',
    ),
    (
      'The middle of the box is a trap',
      'The center of the rectangle a shape fits inside is the centroid of '
          'that RECTANGLE, and of nothing else. It is the wrong answer offered in '
          'nearly every problem here.',
    ),
  ],
  spoken: [
    ('Rectangle', r'\bar{y} = \frac{h}{2}', 'halfway up'),
    (
      'Triangle, from the base',
      r'\bar{y} = \frac{h}{3}',
      'a third of the height up from the base',
    ),
    (
      'Half disc, from the flat side',
      r'\bar{y} = \frac{4r}{3\pi}',
      'four radii over three pi, about 0.42 of the radius',
    ),
  ],
  handbook: 'Handbook pp. 98 to 100',
);

const referenceBrief = BriefSection(
  title: 'One line, and every piece measured from it',
  picture: referencePicture,
  steps: [
    (
      'Pick your line before you start',
      'Usually the bottom edge or the left edge. Draw it. Everything from '
          'here on gets measured from that one line.',
    ),
    (
      'Measure to each piece\'s own middle',
      'Not to where the piece starts, and not to where it ends. To the middle '
          'of that piece, the balance point it would have on its own.',
    ),
    (
      'Never change lines partway',
      'It is tempting when one piece is easier to measure from the top. Do '
          'not. The arithmetic still works, the units still look right, and the '
          'answer is wrong. This is the commonest mistake in the whole topic.',
    ),
  ],
  spoken: [
    ('Each term', r'A_i\,y_i', 'that piece\'s area times its own height'),
    (
      'Measured from',
      r'\text{the one line you chose}',
      'the same line for every piece',
    ),
    (
      'Measured to',
      r"\text{that piece's own middle}",
      'not its edge, its middle',
    ),
  ],
  handbook: 'Handbook p. 95',
);

const twoForceBrief = BriefSection(
  title: 'Touched in exactly two places',
  picture: twoForcePicture,
  steps: [
    (
      'Count where things touch the member',
      'Go along one member and count every place something acts on it: a pin '
          'joining it to something else, a load hung on it, a support. Just count '
          'them.',
    ),
    (
      'Exactly two, and its force has nowhere else to point',
      'For it to stay still, the two forces must be equal, opposite, and in '
          'line with each other. The only line they can share is the one joining '
          'the two places. So the force runs straight along that line.',
    ),
    (
      'A bend in the member changes nothing',
      'The line runs between the two ends, not along the metal. A bent link '
          'touched only at its two ends still pushes straight from end to end.',
    ),
    (
      'Three or more places and all bets are off',
      'That member bends, and its pin forces point wherever they need to. Note '
          'a load hung on a PIN is carried by the joint, so every member there is '
          'still only touched at its own ends.',
    ),
  ],
  spoken: [
    (
      'Two-force member',
      r'\text{touched at exactly two points}',
      'count the places something acts on it',
    ),
    (
      'Where its force points',
      r'\text{along the line joining those points}',
      'straight from one end to the other',
    ),
    (
      'Multi-force member',
      r'\text{touched three or more times}',
      'it bends, and its forces point anywhere',
    ),
  ],
  handbook: 'Handbook p. 97',
);

const leverBrief = BriefSection(
  title: 'A lever is one moment equation',
  picture: leverPicture,
  steps: [
    (
      'Far from the pivot beats close to it',
      'On a seesaw, a small child far from the middle balances a big one '
          'close in. What matters is force times distance from the pivot, on each '
          'side.',
    ),
    (
      'So the force out is scaled by the arms',
      'Your force, times your distance, equals the load, times its distance. '
          'Rearranged: the force out is the force in, times YOUR arm over ITS '
          'arm.',
    ),
    (
      'Long effort arm: more force, less movement',
      'A crowbar. You push a long way and the load barely moves, but it moves '
          'with enormous force.',
    ),
    (
      'Short effort arm: less force, more speed',
      'A fishing rod, or your own forearm. You put in more force and what you '
          'buy is reach and speed at the far end.',
    ),
  ],
  spoken: [
    (
      'Moments about the pivot',
      r'F_{out}\,a_{out} = F_{in}\,a_{in}',
      'force times arm on one side equals force times arm on the other',
    ),
    (
      'So the force out is',
      r'F_{out} = F_{in}\,\frac{a_{in}}{a_{out}}',
      'your force, times your arm divided by the load arm',
    ),
    (
      'Mechanical advantage',
      r'\frac{a_{in}}{a_{out}}',
      'how many times your force is multiplied',
    ),
  ],
  handbook: 'Handbook p. 97',
);

const whatItIsBrief = BriefSection(
  title: 'Truss, frame or machine',
  picture: whatItIsPicture,
  steps: [
    (
      'Ask first: does it move',
      'If the parts move against each other, like pliers or a crane arm, it '
          'is a machine. That is decided before anything else, however it is '
          'built.',
    ),
    (
      'If it holds still, count the touches',
      'Go member by member and count where things act on each one, the way '
          'you did for two-force members.',
    ),
    (
      'Every member touched twice: a truss',
      'Then every force runs along its own member, and you can solve the '
          'joints one at a time. That is what makes a truss easy.',
    ),
    (
      'Any member touched three times: a frame',
      'That member bends, so the truss shortcuts are gone. Frames and '
          'machines are both taken apart member by member and solved the same '
          'way.',
    ),
  ],
  spoken: [
    (
      'Truss',
      r'\text{still, every member touched twice}',
      'every bar just pushes or pulls along itself',
    ),
    (
      'Frame',
      r'\text{still, at least one member bends}',
      'one or more members touched three times or more',
    ),
    ('Machine', r'\text{the parts move}', 'it is built to move'),
  ],
  handbook: 'Handbook p. 97',
);

const lawsBrief = BriefSection(
  title: 'Two questions before either rule',
  picture: lawsPicture,
  steps: [
    (
      'Can both happen at once',
      'If two things can never happen together, like a coin landing heads '
          'and tails, their circles do not overlap. The chance of one OR the '
          'other is just the two chances added.',
    ),
    (
      'If they can, take the overlap off',
      'If both can happen, like rain and wind, the circles overlap. Adding '
          'the two chances counts the overlap twice, so subtract it once.',
    ),
    (
      'Does the first change the second',
      'For the chance of one AND the other, ask whether the first happening '
          'changes the odds of the second. If not, they are independent: '
          'multiply the two chances. If it does, multiply by the chance of the '
          'second GIVEN the first.',
    ),
    (
      'Exclusive is not independent',
      'Drawing cards without putting them back quietly makes events '
          'dependent. And events that cannot both happen are as dependent as '
          'they come: one of them drops the other to zero.',
    ),
  ],
  spoken: [
    (
      'Addition rule',
      r'P(A \cup B) = P(A) + P(B) - P(A \cap B)',
      'A or B: add them, take the overlap off once',
    ),
    (
      'Multiplication rule',
      r'P(A \cap B) = P(A)\,P(B \mid A)',
      'A and B: the chance of A, times the chance of B given A',
    ),
    (
      'If independent',
      r'P(B \mid A) = P(B)',
      'A changes nothing, so just multiply',
    ),
  ],
  handbook: 'Handbook p. 105',
);

const periodBrief = BriefSection(
  title: 'Which mark a payment lands on',
  picture: periodPicture,
  steps: [
    (
      'A line of marks',
      'Draw time as a line with a mark at the end of every year. Today is '
          'mark 0. The end of year 1 is mark 1, the end of year 2 is mark 2, and '
          'so on.',
    ),
    (
      'Payments land at the end',
      'Unless a problem says otherwise, every payment lands at the END of '
          'its year. A yearly series starts at mark 1, not today. That is what '
          'every series factor in the handbook assumes.',
    ),
    (
      'The start of a year is the end of the last one',
      'The beginning of year 3 is the same instant as the end of year 2, so '
          'it is mark 2. The beginning of year 1 is today, mark 0. A growing '
          'series has nothing in its first year; its first step lands on mark 2.',
    ),
    (
      'Draw it before you pick a factor',
      'A payment one mark out of place leaves no trace in the arithmetic. '
          'The only place to catch it is on the drawing.',
    ),
  ],
  spoken: [
    ('End of year n', r'\text{mark } n', 'the payment sits on mark n'),
    (
      'Beginning of year n',
      r'\text{mark } n - 1',
      'the same instant as the end of the year before',
    ),
    ('Today', r'\text{mark } 0', 'where the line starts'),
  ],
  handbook: 'Handbook p. 230',
);

const screwBrief = BriefSection(
  title: 'Whether a screw holds itself up',
  picture: screwPicture,
  steps: [
    (
      'A thread is a ramp wrapped round a rod',
      'Unwrap one turn of a screw thread and flatten it out and you have a '
          'ramp. How steep that ramp is, is the pitch angle.',
    ),
    (
      'Every surface has a steepest ramp it can hold on',
      'That is the friction angle. On a rough surface it is large; on a '
          'slippery one it is small. It comes straight from the friction number.',
    ),
    (
      'Compare the two and you have the answer',
      'Thread shallower than the friction angle: it stays put on its own, and '
          'you have to drive it back DOWN. That is why a car jack holds a car and '
          'a bolt stays done up.',
    ),
    (
      'Steeper, and it runs away',
      'A thread steeper than the friction angle unwinds under the load and '
          'has to be held back. Note it is not the thread alone: grease the jack '
          'and the same thread can go from safe to running away.',
    ),
  ],
  spoken: [
    (
      'Screw jack turn',
      r'M = Pr\tan(\alpha \pm \phi)',
      'load times radius times the tangent of the two angles, added when raising',
    ),
    (
      'Friction angle',
      r'\phi = \arctan\mu',
      'the steepest ramp this surface can hold on',
    ),
    (
      'It holds itself when',
      r'\phi > \alpha',
      'the friction angle beats the thread angle',
    ),
  ],
  handbook: 'Handbook p. 97',
);

const ceilingBrief = BriefSection(
  title: 'Friction is a ceiling, not a fixed amount',
  picture: ceilingPicture,
  steps: [
    (
      'Push a heavy box, gently',
      'Nothing moves. Friction is pushing back exactly as hard as you are '
          'pushing, and no harder. Push a little harder and friction matches you '
          'again. It gives you exactly what is needed to keep still.',
    ),
    (
      'Until it cannot keep up',
      'Keep increasing and you reach a point where friction has nothing left. '
          'That most it could ever give is the ceiling, and the formula gives you '
          'THAT number, not what friction is doing right now.',
    ),
    (
      'So read the problem before reaching for the formula',
      'Words like "about to slide", "on the verge", or "the largest push '
          'before it moves" put you at the ceiling. Without them you are '
          'somewhere below it and the formula answers a question nobody asked.',
    ),
    (
      'The angle version of the same idea',
      'Tilt a ramp slowly. The block holds on until the slope reaches the '
          'angle whose tangent is the friction number, then it goes.',
    ),
  ],
  spoken: [
    (
      'Always true',
      r'F \le \mu_s N',
      'friction is at most the friction number times the press',
    ),
    (
      'At the point of sliding, and only there',
      r'F = \mu_s N',
      'friction is exactly at its ceiling',
    ),
    (
      'The angle it lets go at',
      r'\tan\theta = \mu_s',
      'the tangent of the slope angle equals the friction number',
    ),
  ],
  handbook: 'Handbook p. 96',
);

const beltBrief = BriefSection(
  title: 'A rope round a post: the tight side, then the angle',
  picture: beltPicture,
  steps: [
    (
      'One person can hold a ship',
      'Wrap a rope a few turns round a bollard and a small pull on your end '
          'holds an enormous pull on the other. Friction grips a little more at '
          'every point round the post, and it all adds up.',
    ),
    (
      'Which side is the tight one',
      'The tight side is the end the rope is being dragged TOWARD, because '
          'friction has been adding to it the whole way round. The end you hold '
          'against the slipping is the slack one.',
    ),
    (
      'Then the wrap angle, in radians',
      'How far round the post the rope lies. Half a turn is pi. A full turn '
          'is two pi. It can be more than one turn. Degrees will give a wildly '
          'wrong answer here.',
    ),
    (
      'The growth is not steady, it snowballs',
      'The pull does not just add up round the post, it multiplies. That is '
          'why two extra turns are worth so much more than one.',
    ),
  ],
  spoken: [
    (
      'Belt friction',
      r'F_1 = F_2\, e^{\mu\theta}',
      'the tight pull is the slack pull, multiplied by e to the friction times the wrap angle',
    ),
    (
      'Tight side',
      r'F_1 \text{ is the end it is dragged toward}',
      'downstream of the slipping',
    ),
    ('Half a turn', r'\theta = \pi', 'pi radians, never 180 in this formula'),
  ],
  handbook: 'Handbook p. 96',
);

const normalForceBrief = BriefSection(
  title: 'How hard the surface is pressed',
  picture: normalForcePicture,
  steps: [
    (
      'Friction depends on the press',
      'Every friction answer is the friction number times how hard the two '
          'surfaces are pressed together. Get the press wrong and everything '
          'after it is wrong.',
    ),
    (
      'Flat ground, nothing else: the press is the weight',
      'That is the easy case, and it is the only case where the press equals '
          'the weight.',
    ),
    (
      'On a slope it drops',
      'Tilt the surface and only part of the weight presses into it; the rest '
          'is trying to slide the block down. The steeper the slope, the smaller '
          'the press and the weaker the grip.',
    ),
    (
      'A slanted push changes it again',
      'Push downward into the surface and the press goes up. Push upward and '
          'it goes down. That is the whole ramp problem: a slanted push helps you '
          'along and changes the grip at the same time.',
    ),
  ],
  spoken: [
    ('Flat, nothing else', r'N = W', 'the press is the weight'),
    (
      'On a slope',
      r'N = W\cos\theta',
      'only the part of the weight square to the surface',
    ),
    (
      'With a slanted push',
      r'N = W\cos\theta - P\sin\beta',
      'the press, less the part of the push that lifts',
    ),
  ],
  handbook: 'Handbook p. 96',
);

const determinacyBrief = BriefSection(
  title: 'Three equations, and no more',
  picture: determinacyPicture,
  steps: [
    (
      'A flat problem gives you exactly three facts',
      'Nothing slides sideways. Nothing sinks. Nothing spins. That is three '
          'equations, and it is everything statics has.',
    ),
    (
      'So count the unknowns first',
      'One for a roller, two for a pin, three for a fixed end. Add them up. '
          'Three unknowns and three equations means you can solve it.',
    ),
    (
      'Four or more and statics runs out',
      'The structure is fine. It is usually the stiffer one. You just need '
          'extra information about how much things stretch before you can finish, '
          'which is a later chapter.',
    ),
    (
      'Loads are never unknowns',
      'A load is given to you. It does not need finding, it only needs '
          'carrying. That includes a twist applied somewhere along the beam.',
    ),
  ],
  spoken: [
    (
      'What you have',
      r'\sum F_x = 0, \; \sum F_y = 0, \; \sum M = 0',
      'nothing slides, nothing sinks, nothing spins',
    ),
    (
      'Solvable by statics',
      r'\text{unknowns} = 3',
      'three unknowns for three equations',
    ),
    (
      'Not solvable by statics alone',
      r'\text{unknowns} > 3',
      'more unknowns than equations',
    ),
  ],
  handbook: 'Handbook p. 94',
);

/// Opens one concept over whatever is on screen: a cream sheet (reference
/// 14) with the headline, the copy, the formulas as creamDark tiles, the
/// figure, the paper line and a pill back to where you came from.
Future<void> showConcept(
  BuildContext context,
  BriefSection section, {
  String back = 'Back to the round',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
    ),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 12), child: Grabber()),
          Expanded(
            child: ConceptView(
              section: section,
              back: back,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The concept behind the item you are on, and only that one.
class ConceptView extends StatelessWidget {
  const ConceptView({
    super.key,
    required this.section,
    this.back = 'Back to the round',
    this.onBack,
  });

  final BriefSection section;

  /// What the pill at the bottom says, and does. Without [onBack] the pill
  /// pops whatever route the view sits in.
  final String back;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final handbook = section.handbook;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
        children: [
          Text(
            handbook == null
                ? 'THE CONCEPT'
                : 'THE CONCEPT · ${handbook.toUpperCase()}',
            style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
          ),
          const SizedBox(height: 14),
          Text(section.title, style: AppTheme.display(size: 38, height: 1.0)),
          const SizedBox(height: 22),
          if (section.picture != null) ...[
            section.picture!(),
            const SizedBox(height: 22),
          ],
          if (section.steps.isEmpty)
            Text(section.body, style: AppTheme.body(size: 16, height: 1.5)),
          for (final (i, (eyebrow, text)) in section.steps.indexed) ...[
            if (i > 0) const SizedBox(height: 18),
            Text(
              eyebrow.toUpperCase(),
              style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 6),
            Text(text, style: AppTheme.body(size: 16, height: 1.5)),
          ],
          if (section.formula != null) ...[
            const SizedBox(height: 14),
            _FormulaTile(latex: section.formula!),
          ],
          if (section.spoken.isEmpty)
            for (final (label, latex) in section.formulas) ...[
              const SizedBox(height: 10),
              _FormulaTile(label: label, latex: latex),
            ],
          for (final (i, (label, latex, words)) in section.spoken.indexed) ...[
            SizedBox(height: i == 0 ? 22 : 10),
            _FormulaTile(label: label, latex: latex, words: words),
          ],
          const SizedBox(height: 26),
          Text(
            'Knowing this is not the same as solving with it. The full '
            'problems belong at a desk, on paper.',
            style: AppTheme.body(
              size: 14,
              height: 1.45,
              color: AppColors.mutedOnLight,
            ),
          ),
          const SizedBox(height: 18),
          PillButton(
            label: back,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

/// One expression on a creamDark tile, with its name as an eyebrow.
class _FormulaTile extends StatelessWidget {
  const _FormulaTile({this.label, required this.latex, this.words});

  final String? label;
  final String latex;

  /// The expression read out loud, for a reader who does not yet read the
  /// symbols.
  final String? words;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!.toUpperCase(),
              style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 8),
          ],
          MathBlock(latex, fontSize: 20),
          if (words != null) ...[
            const SizedBox(height: 8),
            Text(
              words!,
              style: AppTheme.body(
                size: 14,
                height: 1.4,
                color: AppColors.mutedOnLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
