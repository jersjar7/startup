import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Can Statics Solve It — the third item for
/// `equilibrium-free-body-diagrams`.
///
/// Three equations, three unknowns, and the lesson says outright what happens
/// past that: the beam is statically indeterminate and no amount of equilibrium
/// will finish it. That is worth knowing before the arithmetic rather than
/// after, because it is the difference between an exam question you can do and
/// one that was never going to come out.
///
/// So no reactions are worked out. The supports are drawn and the question is
/// whether the three equations are enough, too few, or more than the beam
/// deserves. One round has too FEW unknowns, which is the case nobody warns
/// about: a beam on two rollers has nothing holding it sideways and is not a
/// structure at all.
class CanStaticsSolveItGame extends StatefulWidget {
  const CanStaticsSolveItGame({super.key});

  @override
  State<CanStaticsSolveItGame> createState() => _CanStaticsSolveItGameState();
}

enum Enough { solvable, tooMany, tooFew }

@immutable
class SolveRound {
  const SolveRound({
    required this.subject,
    required this.setting,
    required this.span,
    required this.supports,
    required this.loads,
    this.couples = const [],
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final double span;
  final List<Support> supports;
  final List<(double, String)> loads;
  final List<(double, bool, String)> couples;
  final String why;
  final String source;

  /// Every unknown the supports put into the equations.
  int get unknowns =>
      supports.fold(0, (sum, s) => sum + unknownsIn(s.kind));

  /// Whether anything is holding the beam along its own length.
  ///
  /// Three equations need three unknowns, but they also need the right ones:
  /// two rollers give two unknowns and nothing at all to satisfy the
  /// horizontal equation with.
  bool get heldSideways => supports.any(
        (s) => switch (s.kind) {
          Prop.pin || Prop.fixed => true,
          Prop.slopedRoller => s.slope != 0,
          Prop.roller || Prop.cable => false,
        },
      );

  /// Worked out from the supports rather than declared beside them.
  Enough get answer {
    if (!heldSideways || unknowns < 3) return Enough.tooFew;
    return unknowns > 3 ? Enough.tooMany : Enough.solvable;
  }
}

const solveRounds = <SolveRound>[
  SolveRound(
    subject: 'a beam with a load and a couple on it',
    setting:
        'Ten meters, pinned at the left and on a roller at the right, carrying '
        'a point load and a couple applied partway along.',
    span: 10,
    supports: [
      Support(Offset(0, 0), Prop.pin, label: 'A'),
      Support(Offset(10, 0), Prop.roller, label: 'B'),
    ],
    loads: [(4, '20 kN')],
    couples: [(7, true, '10 kN·m')],
    why:
        'Two from the pin and one from the roller is three, and three equations '
        'will finish it. The couple looks like it should cost something and it '
        'costs nothing: it is a load, not a support, so it goes into the moment '
        'equation and adds no unknown to count.',
    source: 'stat-efb-q3',
  ),
  SolveRound(
    subject: 'a beam pinned at both ends',
    setting:
        'The same span, but the right-hand end is pinned as well rather than '
        'sitting on a roller.',
    span: 10,
    supports: [
      Support(Offset(0, 0), Prop.pin, label: 'A'),
      Support(Offset(10, 0), Prop.pin, label: 'B'),
    ],
    loads: [(5, '20 kN')],
    why:
        'Four unknowns against three equations, so equilibrium alone cannot '
        'finish it. Nothing is wrong with the beam. It is a perfectly good '
        'beam, and a stiffer one for the extra restraint, but you would need '
        'how much it stretches to get the last number and that is not statics.',
    source: 'stat-efb-q1',
  ),
  SolveRound(
    subject: 'a beam built into a wall at one end',
    setting:
        'Four meters, cast into the wall at the left and free at the right, '
        'carrying a load near the tip.',
    span: 4,
    supports: [Support(Offset(0, 0), Prop.fixed, label: 'A')],
    loads: [(3.4, '8 kN')],
    why:
        'Three, all at one end. A fixed support spends the whole budget by '
        'itself, which is exactly why a cantilever needs nothing else holding '
        'it up and why adding a prop under the far end makes it unsolvable by '
        'statics rather than more secure.',
    source: 'stat-efb-q2',
  ),
  SolveRound(
    subject: 'the cantilever with a prop under the end',
    setting:
        'The same built-in beam, with a roller added under the free end to help '
        'carry the load.',
    span: 4,
    supports: [
      Support(Offset(0, 0), Prop.fixed, label: 'A'),
      Support(Offset(4, 0), Prop.roller, label: 'B'),
    ],
    loads: [(2.4, '8 kN')],
    why:
        'Four. The prop is a real improvement to the beam and it puts the '
        'problem out of reach of these three equations, which is the point the '
        'lesson is making: indeterminate is a statement about the method, not a '
        'complaint about the structure.',
    source: 'stat-efb-q2',
  ),
  SolveRound(
    subject: 'a beam on two rollers',
    setting:
        'Eight meters sitting on a roller at each end, with a load in the '
        'middle.',
    span: 8,
    supports: [
      Support(Offset(0, 0), Prop.roller, label: 'A'),
      Support(Offset(8, 0), Prop.roller, label: 'B'),
    ],
    loads: [(4, '15 kN')],
    why:
        'Two unknowns, and worse than that, both of them vertical. There is '
        'nothing at all to satisfy the horizontal equation with, so the '
        'slightest sideways push sends the beam off its supports. Counting to '
        'three is not enough on its own: the three have to point in useful '
        'directions.',
    source: 'stat-efb-q1',
  ),
  SolveRound(
    subject: 'a beam with a middle support added',
    setting:
        'Twelve meters, pinned at the left, on rollers in the middle and at the '
        'right, carrying one load.',
    span: 12,
    supports: [
      Support(Offset(0, 0), Prop.pin, label: 'A'),
      Support(Offset(6, 0), Prop.roller, label: 'B'),
      Support(Offset(12, 0), Prop.roller, label: 'C'),
    ],
    loads: [(9, '18 kN')],
    why:
        'Four again, from a third support rather than from a stronger one. Any '
        'extra support past what holds the beam still costs the same thing: it '
        'buys stiffness and it costs you the method. Continuous beams over '
        'several supports are all like this.',
    source: 'stat-efb-q1',
  ),
];

class _CanStaticsSolveItGameState extends State<CanStaticsSolveItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'can-statics-solve-it',
    chapterId: 'statics',
    total: solveRounds.length,
    sourceProblemIdOf: (round) => solveRounds[round].source,
  )..addListener(_onSession);

  Enough? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SolveRound get _round => solveRounds[_session.round];

  static String _label(Enough v) => switch (v) {
        Enough.solvable => 'Yes, three will do it',
        Enough.tooMany => 'No, too many unknowns',
        Enough.tooFew => 'No, it will not stand up',
      };

  static String _note(Enough v) => switch (v) {
        Enough.solvable => 'determinate',
        Enough.tooMany => 'statically indeterminate',
        Enough.tooFew => 'a mechanism, not a structure',
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Can Statics Solve It',
        closing:
            'Count the unknowns before you write anything: one for a roller, '
            'two for a pin, three for a fixed end. More than three and '
            'equilibrium runs out, which says nothing against the beam. And '
            'check they point in useful directions, because three vertical '
            'unknowns still leave nothing to hold the beam sideways.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: determinacyBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THREE EQUATIONS. ENOUGH?',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 190,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: BeamPainter(
                    span: r.span,
                    supports: r.supports,
                    loads: r.loads,
                    couples: r.couples,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final v in Enough.values) ...[
            if (v != Enough.values.first) const SizedBox(height: 8),
            _EnoughRow(
              key: ValueKey('verdict-${v.name}'),
              label: _label(v),
              note: _note(v),
              selected: _picked == v,
              locked: answered,
              isTruth: v == r.answer,
              onTap: answered ? null : () => setState(() => _picked = v),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'THE COUNT',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              [
                for (final s in r.supports)
                  '${s.label.isEmpty ? 'support' : s.label}   '
                      '${_propName(s.kind)}   ${unknownsIn(s.kind)}',
                'total   ${r.unknowns}   against 3 equations',
              ].join('\n'),
              style: AppTheme.code(size: 12),
            ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT QUITE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }

  static String _propName(Prop kind) => switch (kind) {
        Prop.roller => 'roller',
        Prop.slopedRoller => 'roller on a slope',
        Prop.pin => 'pin',
        Prop.fixed => 'fixed',
        Prop.cable => 'cable',
      };
}

class _EnoughRow extends StatelessWidget {
  const _EnoughRow({
    super.key,
    required this.label,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final String note;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(note, style: AppTheme.mono(size: 11, color: AppColors.ink3)),
            ],
          ),
        ),
      ),
    );
  }
}
