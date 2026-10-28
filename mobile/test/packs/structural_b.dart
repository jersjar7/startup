import 'package:mobile/features/games/both_factors_or_one_game.dart'
    show columnFactorRounds;
import 'package:mobile/features/games/gross_or_net_game.dart' show limitRounds;
import 'package:mobile/features/games/how_big_is_the_hole_game.dart'
    show holeRounds;
import 'package:mobile/features/games/how_far_between_braces_game.dart'
    show BraceRound, braceRounds;
import 'package:mobile/features/games/influence_figures.dart'
    show InfluencePainter;
import 'package:mobile/features/games/is_all_of_it_connected_game.dart'
    show lagRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/nominal_or_design_game.dart'
    show phiRounds;
import 'package:mobile/features/games/rc_figures.dart'
    show CagePainter, Depth, SectionMarkPainter, ShearLadderPainter, Stirrups;
import 'package:mobile/features/games/steel_figures.dart'
    show AxisPainter, BracePainter, Gets, ShapePainter, Axis2;
import 'package:mobile/features/games/stirrups_or_not_game.dart'
    show ShearRound, shearRounds;
import 'package:mobile/features/games/tension_figures.dart'
    show GripPainter, TiePainter;
import 'package:mobile/features/games/too_little_or_too_much_game.dart'
    show RatioRound, Window, windowRounds;
import 'package:mobile/features/games/what_the_table_gives_you_game.dart'
    show columnTableRounds;
import 'package:mobile/features/games/where_do_you_park_it_game.dart'
    show parkRounds;
import 'package:mobile/features/games/which_axis_wins_now_game.dart'
    show AxisRound, bothAxisRounds;
import 'package:mobile/features/games/which_flange_needs_holding_game.dart'
    show flangeRounds;
import 'package:mobile/features/games/which_one_is_d_game.dart'
    show DepthRound, rcDepthRounds;
import 'package:mobile/features/games/z_or_s_game.dart' show modulusRounds;

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Structural games, second half: where to park a moving load,
/// reinforced concrete beams and columns, steel beams, steel columns and
/// steel tension members. Every one has the same screen: the problem, then
/// either a drawing in a bordered panel with a formula under it, or (once
/// answered) a cream box holding the two formulas, then the answers as the
/// app's plain white rows and the feedback.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'where-do-you-park-it': whereDoYouParkIt,
  'which-one-is-d': whichOneIsD,
  'stirrups-or-not': stirrupsOrNot,
  'nominal-or-design': nominalOrDesign,
  'both-factors-or-one': bothFactorsOrOne,
  'too-little-or-too-much': tooLittleOrTooMuch,
  'how-far-between-braces': howFarBetweenBraces,
  'z-or-s': zOrS,
  'which-flange-needs-holding': whichFlangeNeedsHolding,
  'which-axis-wins-now': whichAxisWinsNow,
  'what-the-table-gives-you': whatTheTableGivesYou,
  'gross-or-net': grossOrNet,
  'how-big-is-the-hole': howBigIsTheHole,
  'is-all-of-it-connected': isAllOfItConnected,
};

const _chapter = 'structural';

/// A round over a drawing: the problem, the drawing in a bordered panel
/// [h] high, a formula centred under it, then the answers and feedback.
List<Map<String, Object?>> _drawn({
  required String overline,
  required String subject,
  required String asked,
  required Draw Function(bool answered) paint,
  required double h,
  required String formula,
  required num size,
  String color = 'charcoal',
  required String what,
}) => [
  ...heading(overline, subject, asked),
  gap(12),
  figure(paint, h, frame: 'panel', what: what),
  gap(10),
  if (color == 'charcoal')
    {'math': formula, 'size': size}
  else
    center(math(formula, size, color: color)),
  gap(12),
  {'choices': true, 'space': 8},
  ...feedbackAfter(14),
];

/// A round with no drawing: the problem, then once answered a cream box
/// titled [title] holding two formulas, then the answers and feedback.
List<Map<String, Object?>> _boxed({
  required String overline,
  required String subject,
  required String asked,
  required String title,
  required String first,
  required String second,
  required num size,
}) => [
  ...heading(overline, subject, asked),
  gap(14),
  box(
    w: 'max',
    pad: [14, 12, 14, 12],
    fill: 'cream',
    radius: 10,
    border: 'line',
    cross: 'start',
    c: [
      t(title, font: 'overline', color: 'ink3'),
      gapH(8),
      math(first, size),
      gapH(6),
      math(second, size),
    ],
    when: 'done',
  ),
  gap(14, when: 'done'),
  {'choices': true, 'space': 8},
  ...feedbackAfter(14),
];

/// A pick-one game of this chapter.
Map<String, Object?> _game({
  required String id,
  required String title,
  required String closing,
  required String right,
  required String wrong,
  required BriefSection brief,
  required String briefName,
  bool closerSheet = false,
  required List<ScreenRound> rounds,
}) => pickScreen(
  id: id,
  chapter: _chapter,
  title: title,
  closing: closing,
  right: right,
  wrong: wrong,
  // The cage sheets hatch a section whose corner sits on a float32
  // bound: at the plain tolerance three of the hatch lines drew a couple
  // of shades off across a pair's whole width.
  brief: closerSheet
      ? closer(1e-7, () => briefJson(brief, briefName))
      : briefJson(brief, briefName),
  rounds: rounds,
);

Map<String, Object?> whereDoYouParkIt() => _game(
  id: 'where-do-you-park-it',
  title: 'Where Do You Park It',
  closing:
      'The load goes where the line is tallest, and when several travel '
      'together the heaviest one gets the tallest spot. For shear that '
      'means just to the right of the section, for a moment it means on '
      'the section itself, and for a reaction it means over the '
      'support. A spread load covers only the ground where the line is '
      'on the side you want, because the rest of it would cancel.',
  right: 'THAT IS THE SPOT',
  wrong: 'NOT THERE',
  brief: placeBrief,
  briefName: 'placeBrief',
  rounds: [
    for (final (i, r) in parkRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHERE DOES THE LOAD GO',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) => InfluencePainter(
            line: r.line,
            loads: answered ? r.parked : const [],
            showOrdinates: answered,
          ).paint,
          h: 212,
          formula: r'$\text{the load goes where the line is tallest}$',
          size: 13,
          color: 'ink3',
          what: 'where-do-you-park-it round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichOneIsD() => _game(
  id: 'which-one-is-d',
  title: 'Which One Is d',
  closing:
      'd is the top of the beam down to the CENTROID of the tension '
      'steel, which is the height less the cover, less the stirrup, '
      'less half a bar. It is never the height of the beam. The lever '
      'arm is shorter still, d less half the block depth, because the '
      'moment is carried by a couple and what matters is the distance '
      'between its two forces.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: whichDepthBrief,
  briefName: 'whichDepthBrief',
  rounds: [
    for (final (i, r) in rcDepthRounds.indexed)
      (
        options: [for (final o in Depth.values) DepthRound.label(o)],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHAT IS THE MARKED DIMENSION',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) => SectionMarkPainter(
            section: r.section,
            marked: r.marked,
            answered: answered,
          ).paint,
          h: 236,
          formula: r'$M_n = A_s f_y \left(d - \frac{a}{2}\right)$',
          size: 16,
          what: 'which-one-is-d round $i',
        ),
      ),
  ],
);

Map<String, Object?> stirrupsOrNot() => _game(
  id: 'stirrups-or-not',
  title: 'Stirrups or Not',
  closing:
      'Four answers on one ladder. Under half of what the concrete may '
      'be leaned on, nothing. Up to all of it, a minimum cage to hold '
      'the crack and give some warning. Past it, stirrups sized for the '
      'difference. And past four times the concrete\'s own share, no '
      'spacing will do and the section has to grow. The resistance '
      'factor comes off the concrete before any of those comparisons, '
      'never after.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: stirrupBrief,
  briefName: 'stirrupBrief',
  rounds: [
    for (final (i, r) in shearRounds.indexed)
      (
        options: [for (final o in Stirrups.values) ShearRound.label(o)],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHAT DOES THE SECTION NEED',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              ShearLadderPainter(check: r.check, answered: answered).paint,
          h: 168,
          formula:
              r'$V_c = 2\lambda\sqrt{f_c^{\prime}}\,b_w d \qquad \phi = 0.75$',
          size: 15,
          what: 'stirrups-or-not round $i',
        ),
      ),
  ],
);

Map<String, Object?> nominalOrDesign() => _game(
  id: 'nominal-or-design',
  title: 'Nominal or Design',
  closing:
      'Nominal is what the section can reach; design is what you are '
      'allowed to count on, which is nominal times phi. Bending gets '
      '0.90 and shear gets 0.75, because bending gives warning and '
      'shear does not. In the check, loads go up and capacity comes '
      'down. And when the stirrups are being sized, the demand is '
      'divided by phi BEFORE the concrete is taken off.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: phiBrief,
  briefName: 'phiBrief',
  rounds: [
    for (final r in phiRounds)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _boxed(
          overline: 'WHICH NUMBER IS WANTED',
          subject: r.subject,
          asked: r.asked,
          title: 'THE TWO CHECKS',
          first: r'$\phi M_n \ge M_u, \quad \phi = 0.90$',
          second: r'$\phi V_n \ge V_u, \quad \phi = 0.75$',
          size: 15,
        ),
      ),
  ],
);

Map<String, Object?> bothFactorsOrOne() => _game(
  id: 'both-factors-or-one',
  title: 'Both Factors or One',
  closing:
      'A tied column carries two multipliers and both are needed: 0.80 '
      'for the eccentricity no real column escapes, then 0.65 because '
      'crushing gives no warning. A spiral earns 0.85 and 0.75 by '
      'confining the concrete. The 0.80 is for columns only, so seeing '
      'it in a problem tells you what you are looking at, and the '
      'number to compare the factored load against is the one with both '
      'multipliers already in it.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: columnFactorBrief,
  briefName: 'columnFactorBrief',
  closerSheet: true,
  rounds: [
    for (final (i, r) in columnFactorRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHAT MULTIPLIES THE CAPACITY',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              CagePainter(cage: r.cage, answered: answered).paint,
          h: 192,
          formula:
              r'$\phi P_n = 0.80\phi\left[0.85 f_c^{\prime}(A_g - A_{st}) + '
              r'A_{st} f_y\right]$',
          size: 13,
          what: 'both-factors-or-one round $i',
        ),
      ),
  ],
);

Map<String, Object?> tooLittleOrTooMuch() => _game(
  id: 'too-little-or-too-much',
  title: 'Too Little or Too Much',
  closing:
      'One per cent to eight, and both limits are inclusive. Under the '
      'bottom the column behaves like plain concrete as soon as any '
      'bending arrives, which means failing without warning. Over the '
      'top there is no room to place the bars, lap them, or get '
      'concrete down between them. Check the window first: a capacity '
      'worked out for a column outside it is not a capacity anybody may '
      'use.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: steelWindowBrief,
  briefName: 'steelWindowBrief',
  closerSheet: true,
  rounds: [
    for (final (i, r) in windowRounds.indexed)
      (
        options: [for (final o in Window.values) RatioRound.label(o)],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'AGAINST THE WINDOW',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              CagePainter(cage: r.cage, answered: answered).paint,
          h: 192,
          formula: r'$0.01 \le \rho_g = \frac{A_{st}}{A_g} \le 0.08$',
          size: 15,
          what: 'too-little-or-too-much round $i',
        ),
      ),
  ],
);

Map<String, Object?> howFarBetweenBraces() => _game(
  id: 'how-far-between-braces',
  title: 'How Far Between Braces',
  closing:
      'The same section is worth different amounts depending on how '
      'often its compression flange is held. Inside the first limit it '
      'reaches everything the steel has. Between the two limits the '
      'capacity slides down a straight line. Past the second it buckles '
      'while still elastic and the bracing, not the steel, is deciding '
      'the beam. Both limits belong to the shape and are looked up, not '
      'remembered.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: bracingBrief,
  briefName: 'bracingBrief',
  rounds: [
    for (final (i, r) in braceRounds.indexed)
      (
        options: [for (final o in Gets.values) BraceRound.label(o)],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHAT CAN THIS BEAM REACH',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              BracePainter(beam: r.beam, answered: answered).paint,
          h: 214,
          formula: r'$M_n = M_p = F_y Z_x \text{ when } L_b \le L_p$',
          size: 14,
          what: 'how-far-between-braces round $i',
        ),
      ),
  ],
);

Map<String, Object?> zOrS() => _game(
  id: 'z-or-s',
  title: 'Z or S',
  closing:
      'Z is the section yielded right through and S is the section at '
      'first yield, which makes Z the larger by a tenth or more. The '
      'plastic moment uses Z in BOTH design methods, since the nominal '
      'strength belongs to the member and not to the method. S turns up '
      'where the steel is still elastic, which on this lesson means '
      'inside the buckling equation.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: modulusBrief,
  briefName: 'modulusBrief',
  rounds: [
    for (final r in modulusRounds)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _boxed(
          overline: 'WHICH MODULUS',
          subject: r.subject,
          asked: r.asked,
          title: 'THE TWO OF THEM',
          first: r'$M_p = F_y Z_x \quad \text{(yielded right through)}$',
          second: r'$M_y = F_y S_x \quad \text{(the outer fiber only)}$',
          size: 14,
        ),
      ),
  ],
);

Map<String, Object?> whichFlangeNeedsHolding() => _game(
  id: 'which-flange-needs-holding',
  title: 'Which Flange Needs Holding',
  closing:
      'Buckling is a compression flange going sideways, so a brace only '
      'counts if it holds THAT flange and stops the section twisting. '
      'Sagging, it is the top one, and a slab braces it for nothing. '
      'Hogging over a support, it is the bottom one, and the slab '
      'overhead is no use at all. Shear is a separate story and belongs '
      'entirely to the web.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: flangeBrief,
  briefName: 'flangeBrief',
  rounds: [
    for (final (i, r) in flangeRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHAT IS IN COMPRESSION',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) => ShapePainter(
            part: r.part,
            sagging: r.sagging,
            answered: answered,
          ).paint,
          h: 176,
          formula: r'$V_n = 0.6 F_y A_w, \quad A_w = d\,t_w$',
          size: 15,
          what: 'which-flange-needs-holding round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichAxisWinsNow() => _game(
  id: 'which-axis-wins-now',
  title: 'Which Axis Wins Now',
  closing:
      'A brace shortens the free length for the axis it is fitted to '
      'and for no other, so the two directions have to be looked at '
      'separately: each with its own radius and its own length, and the '
      'larger slenderness decides the column. Halving the shallow '
      'length divides its slenderness by two, so the deep way takes '
      'over only when its radius is less than twice the shallow one: '
      'true of the stocky shapes chosen as columns, and not of the deep '
      'ones chosen as beams.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: axisBrief,
  briefName: 'axisBrief',
  rounds: [
    for (final (i, r) in bothAxisRounds.indexed)
      (
        options: [for (final o in Axis2.values) AxisRound.label(o)],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHICH WAY DOES IT GO',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              AxisPainter(post: r.post, answered: answered).paint,
          h: 224,
          formula: r'$\text{the larger } KL/r \text{ decides it}$',
          size: 14,
          what: 'which-axis-wins-now round $i',
        ),
      ),
  ],
);

Map<String, Object?> whatTheTableGivesYou() => _game(
  id: 'what-the-table-gives-you',
  title: 'What the Table Gives You',
  closing:
      'The column table hands over a stress that already has its '
      'resistance factor in it, so the whole calculation is that stress '
      'times the gross area. The yield stress times the area is the '
      'answer for a column of no length at all. Design stress falls '
      'away as slenderness rises, and once a column is slender enough '
      'to buckle elastically, stronger steel buys nothing: only a '
      'stockier shape or another brace does.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: tableBrief3,
  briefName: 'tableBrief3',
  rounds: [
    for (final r in columnTableRounds)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _boxed(
          overline: 'WHAT DO YOU DO WITH IT',
          subject: r.subject,
          asked: r.asked,
          title: 'THE WHOLE CALCULATION',
          first: r'$\phi_c P_n = (\phi_c F_{cr}) \times A_g$',
          second: r'$\text{slenderness} = KL/r, \; \text{both in inches}$',
          size: 15,
        ),
      ),
  ],
);

Map<String, Object?> grossOrNet() => _game(
  id: 'gross-or-net',
  title: 'Gross or Net',
  closing:
      'Two checks, always both. Yielding stretches the whole bar, so it '
      'uses the gross area with the yield stress and a factor of 0.90. '
      'Rupture tears one cross-section, so it uses the effective net '
      'area with the ultimate stress and a factor of 0.75. The member '
      'is worth the smaller of the two answers, and rupture wins more '
      'often than the stresses alone would suggest.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: twoLimitsBrief,
  briefName: 'twoLimitsBrief',
  rounds: [
    for (final (i, r) in limitRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHICH CHECK IS THIS',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              TiePainter(tie: r.tie, answered: answered).paint,
          h: 190,
          formula: r'$0.90 F_y A_g \quad \text{and} \quad 0.75 F_u A_e$',
          size: 15,
          what: 'gross-or-net round $i',
        ),
      ),
  ],
);

Map<String, Object?> howBigIsTheHole() => _game(
  id: 'how-big-is-the-hole',
  title: 'How Big Is the Hole',
  closing:
      'A hole costs the bolt diameter plus an eighth: a sixteenth of '
      'clearance and a sixteenth of damage. The allowance comes off the '
      'WIDTH and the answer is multiplied by the thickness afterward. '
      'Only the holes on one cross-section come off that section, so '
      'bolts strung out along the pull do not add up. And none of it '
      'touches the gross area the yielding check uses.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: netAreaBrief,
  briefName: 'netAreaBrief',
  rounds: [
    for (final (i, r) in holeRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'WHAT COMES OFF THE WIDTH',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) => TiePainter(
            tie: r.tie,
            showSections: false,
            answered: answered,
          ).paint,
          h: 178,
          formula:
              r'$A_n = \left[b_g - \Sigma\left(d_b + \tfrac{1}{8}\right)\right] t$',
          size: 15,
          what: 'how-big-is-the-hole round $i',
        ),
      ),
  ],
);

Map<String, Object?> isAllOfItConnected() => _game(
  id: 'is-all-of-it-connected',
  title: 'Is All of It Connected',
  closing:
      'Load entering through part of a section needs length to spread '
      'into the rest, so at the connection the unattached parts are not '
      'yet pulling their share. Connected right across and the factor '
      'is one; through one leg or through the flanges alone and it is '
      'less. A longer connection raises it, bigger bolts do not, and '
      'the whole idea belongs to the rupture check and nowhere else.',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: shearLagBrief,
  briefName: 'shearLagBrief',
  rounds: [
    for (final (i, r) in lagRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: _drawn(
          overline: 'HOW MUCH IS REALLY WORKING',
          subject: r.subject,
          asked: r.asked,
          paint: (answered) =>
              GripPainter(grip: r.grip, answered: answered).paint,
          h: 186,
          formula: r'$A_e = U A_n, \quad U = 1 - \bar{x}/L$',
          size: 15,
          what: 'is-all-of-it-connected round $i',
        ),
      ),
  ],
);
