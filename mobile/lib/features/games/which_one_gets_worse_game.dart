import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'diagram_figures.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';
import 'stress_figures.dart';

/// Which One Gets Worse — the third item for `bending-shear-stresses`.
///
/// The two formulas in this lesson answer to different things, and which one
/// answers to what is the difference between a beam that fails in bending and
/// one that fails in shear. The span is in the moment and not in the shear.
/// The depth is squared in the bending strength and only counted once in the
/// area. Neither formula has the material in it at all.
///
/// So nothing is computed on the screen. One thing about the beam or its
/// section changes, and the answer is which stress goes UP.
class WhichOneGetsWorseGame extends StatefulWidget {
  const WhichOneGetsWorseGame({super.key});

  @override
  State<WhichOneGetsWorseGame> createState() => _WhichOneGetsWorseGameState();
}

/// Which stress the change makes worse.
enum Worse { bending, shear, both, neither }

extension WorseWords on Worse {
  String get plain => switch (this) {
        Worse.bending => 'The bending stress',
        Worse.shear => 'The shear stress',
        Worse.both => 'Both of them',
        Worse.neither => 'Neither of them',
      };
}

@immutable
class SwapRound {
  const SwapRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.section,
    required this.sectionAfter,
    required this.why,
    required this.source,
    this.loadLabel = '',
  });

  final String subject;
  final String change;
  final Loading before;
  final Loading after;
  final Profile section;
  final Profile sectionAfter;
  final String loadLabel;
  final String why;
  final String source;

  double _bending(Loading beam, Profile s) =>
      beam.peakMoment * 1e6 * s.cMax / s.ownIx;

  double _shear(Loading beam, Profile s) {
    var peak = 0.0;
    for (final x in beam.breaks) {
      for (final side in [true, false]) {
        final v = beam.shearAt(x, after: side).abs();
        if (v > peak) peak = v;
      }
    }
    return s.shearStressAt(s.centroid.dy, peak * 1000);
  }

  /// Worked out by putting both beams through both formulas.
  Worse get answer {
    final bendingUp =
        _bending(after, sectionAfter) > _bending(before, section) * 1.01;
    final shearUp = _shear(after, sectionAfter) > _shear(before, section) * 1.01;
    if (bendingUp && shearUp) return Worse.both;
    if (bendingUp) return Worse.bending;
    if (shearUp) return Worse.shear;
    return Worse.neither;
  }
}

final _joist = boxSection(100, 200);

final swapRounds = <SwapRound>[
  SwapRound(
    subject: 'the same joist over a wider room',
    change:
        'A timber joist carrying one load in the middle is used over a span '
        'twice as long. Same joist, same load.',
    before: const Loading(span: 6, points: [(3, 18)]),
    after: const Loading(span: 12, points: [(6, 18)]),
    section: _joist,
    sectionAfter: _joist,
    loadLabel: '18 kN',
    why:
        'The bending stress, and it doubles. The span is in the moment, P L '
        'over four, and it is nowhere in the shear at all: each support still '
        'takes half the load however far apart they are. This is why long '
        'beams fail in bending and short deep ones fail in shear, and it is '
        'the most useful thing in the lesson.',
    source: 'mm-bss-q1',
  ),
  SwapRound(
    subject: 'twice the load',
    change: 'The same joist over the same span, carrying twice as much.',
    before: const Loading(span: 6, points: [(3, 18)]),
    after: const Loading(span: 6, points: [(3, 36)]),
    section: _joist,
    sectionAfter: _joist,
    loadLabel: '18 kN',
    why:
        'Both, and both double. The load is on the top of both formulas, once '
        'through the moment and once through the shear, so it scales the two '
        'together. Worth having in front of you before the rounds where only '
        'one of them moves.',
    source: 'mm-bss-q1',
  ),
  SwapRound(
    subject: 'the joist laid on its side',
    change:
        'The same hundred by two hundred joist, turned so it is two hundred '
        'wide and one hundred deep. Nothing else changes.',
    before: const Loading(span: 6, points: [(3, 18)]),
    after: const Loading(span: 6, points: [(3, 18)]),
    section: _joist,
    sectionAfter: boxSection(200, 100),
    loadLabel: '18 kN',
    why:
        'The bending stress, and it doubles. Bending strength goes as b h '
        'squared over six, so the depth counts twice over and the width only '
        'once: swapping them costs you the ratio of the two. The shear stress '
        'does not move at all, because three V over two A only knows the '
        'AREA, and the area is the same timber either way up.',
    source: 'mm-bss-q1',
  ),
  SwapRound(
    subject: 'the load moved up against the support',
    change:
        'The same beam and the same load, but the load now sits one meter '
        'from the left support instead of at midspan.',
    before: const Loading(span: 10, points: [(5, 30)]),
    after: const Loading(span: 10, points: [(1, 30)]),
    section: _joist,
    sectionAfter: _joist,
    loadLabel: '30 kN',
    why:
        'The shear stress, while the bending stress gets BETTER. A load near '
        'a support hardly bends the beam at all, P a b over L with a small a, '
        'but that support now takes nine tenths of it instead of half. This '
        'is the case the shear formula exists for, and it is why a short '
        'stubby bracket is checked for shear first.',
    source: 'mm-bss-q2',
  ),
  SwapRound(
    subject: 'the same beam in a different material',
    change:
        'The timber joist is replaced by a steel one of exactly the same size, '
        'carrying the same load over the same span.',
    before: const Loading(span: 6, points: [(3, 18)]),
    after: const Loading(span: 6, points: [(3, 18)]),
    section: _joist,
    sectionAfter: _joist,
    loadLabel: '18 kN',
    why:
        'Neither. Look at what is in the two formulas: a force, a length, and '
        'the shape of the section. No modulus of elasticity anywhere. The '
        'steel beam carries exactly the same stresses as the timber one did, '
        'it just has a great deal more strength to meet them with, and it '
        'deflects far less, which is a different lesson.',
    source: 'mm-bss-q1',
  ),
  SwapRound(
    subject: 'a deeper joist',
    change:
        'The joist is replaced by one twice as deep, a hundred by four '
        'hundred, over the same span with the same load.',
    before: const Loading(span: 6, points: [(3, 18)]),
    after: const Loading(span: 6, points: [(3, 18)]),
    section: _joist,
    sectionAfter: boxSection(100, 400),
    loadLabel: '18 kN',
    why:
        'Neither: both get better, and not by the same amount. The bending '
        'stress falls to a QUARTER, because the section modulus carries the '
        'depth squared. The shear stress only halves, because the area carries '
        'the depth once. Depth is the cheapest thing you can buy in a beam, '
        'and it buys bending faster than it buys shear.',
    source: 'mm-bss-q2',
  ),
];

class _WhichOneGetsWorseGameState extends State<WhichOneGetsWorseGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-gets-worse',
    chapterId: 'mechanics-materials',
    total: swapRounds.length,
    sourceProblemIdOf: (round) => swapRounds[round].source,
  )..addListener(_onSession);

  Worse? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SwapRound get _round => swapRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Gets Worse',
        closing:
            'The span is in the moment and not in the shear. The depth is '
            'squared in the bending and counted once in the area. The material '
            'is in neither. A long beam is a bending problem and a short one '
            'is a shear problem, and that follows from the formulas rather '
            'than from experience.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: governsBrief,
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
            'WHICH STRESS GOES UP',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: BeamPainter(
                  span: r.before.span,
                  supports: supportsOf(r.before),
                  spreads: r.before.spreads,
                  loads: [
                    for (final p in r.before.points) (p.$1, r.loadLabel),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'before the change',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _One(
                  title: 'bending',
                  tex: r'$\sigma = \dfrac{Mc}{I}$',
                ),
              ),
              Container(width: 1, height: 54, color: AppColors.line),
              Expanded(
                child: _One(
                  title: 'shear',
                  tex: r'$\tau = \dfrac{3V}{2A}$',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final w in Worse.values) ...[
            _Choice(
              label: w.plain,
              selected: _picked == w,
              locked: answered,
              isTruth: w == r.answer,
              onTap: answered ? null : () => setState(() => _picked = w),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _One extends StatelessWidget {
  const _One({required this.title, required this.tex});

  final String title;
  final String tex;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(title, style: AppTheme.mono(size: 11, color: AppColors.ink3)),
          const SizedBox(height: 6),
          MathText(
            tex,
            style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
          ),
        ],
      );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
