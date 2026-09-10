import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'curve_figures.dart';
import 'lesson_brief.dart';

/// Stiff, Strong or Stretchy — the second item for `stress-strain-diagrams`.
///
/// The lesson's second, third and fourth headings are three properties read
/// off three different features of the same curve: the slope, the height and
/// the length. The problem in this lesson turns on a student assuming they
/// travel together, and its own note says it plainly: strong does not mean
/// ductile. Two curves on one set of axes is the shortest way to see that,
/// and the answer is read off the drawing rather than computed.
class StiffStrongOrStretchyGame extends StatefulWidget {
  const StiffStrongOrStretchyGame({super.key});

  @override
  State<StiffStrongOrStretchyGame> createState() =>
      _StiffStrongOrStretchyGameState();
}

/// Which of the two, or neither.
enum Which { first, second, alike }

/// What a round asks about the pair.
enum Ask { stiffer, stronger, stretchier, warns }

extension AskWords on Ask {
  String get question => switch (this) {
        Ask.stiffer => 'Which one is stiffer?',
        Ask.stronger => 'Which one is stronger?',
        Ask.stretchier => 'Which one stretches further before it breaks?',
        Ask.warns => 'Which one gives you warning before it fails?',
      };

  String get reads => switch (this) {
        Ask.stiffer => 'stiffness is the SLOPE of the straight run',
        Ask.stronger => 'strength is the HEIGHT of the curve',
        Ask.stretchier => 'ductility is the LENGTH of the curve',
        Ask.warns => 'warning is ductility: does it stretch first, or just go',
      };
}

@immutable
class PairRound {
  const PairRound({
    required this.setting,
    required this.ask,
    required this.first,
    required this.second,
    required this.why,
    required this.source,
  });

  final String setting;
  final Ask ask;
  final Specimen first;
  final Specimen second;
  final String why;
  final String source;

  /// Worked out from the two specimens, never written down beside the round.
  Which get answer {
    double a;
    double b;
    switch (ask) {
      case Ask.stiffer:
        a = first.e;
        b = second.e;
      case Ask.stronger:
        a = first.ultimate;
        b = second.ultimate;
      case Ask.stretchier:
        a = first.fractureStrain;
        b = second.fractureStrain;
      case Ask.warns:
        if (first.brittle == second.brittle) return Which.alike;
        return first.brittle ? Which.second : Which.first;
    }
    final gap = (a - b).abs() / math.max(a, b);
    if (gap < 0.03) return Which.alike;
    return a > b ? Which.first : Which.second;
  }
}

const pairRounds = <PairRound>[
  PairRound(
    setting:
        'A structural steel and an aluminum alloy, tested side by side. They '
        'reach almost the same stress before they yield.',
    ask: Ask.stiffer,
    first: Specimen(
      label: 'steel',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    second: Specimen(
      label: 'aluminum',
      e: 70000,
      yieldStress: 240,
      ultimate: 310,
      fractureStrain: 0.12,
      necksTo: 0.88,
    ),
    why:
        'The steel, by about three to one, and you can see it in the first '
        'centimeter of the drawing: its straight run climbs far more sharply. '
        'The two yield at nearly the same stress, so on strength they are '
        'close. Stiffness and strength are answering different questions, and '
        'this pair is the cleanest case of it.',
    source: 'mm-ssd-q1',
  ),
  PairRound(
    setting:
        'Two steels: an ordinary structural grade and a high strength one.',
    ask: Ask.stiffer,
    first: Specimen(
      label: 'mild steel',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    second: Specimen(
      label: 'high strength steel',
      e: 200000,
      yieldStress: 450,
      ultimate: 620,
      fractureStrain: 0.14,
      necksTo: 0.9,
    ),
    why:
        'Neither. Their straight runs lie exactly on top of each other, '
        'because every steel has essentially the same E, near 200 GPa. Paying '
        'for a stronger steel buys you a higher curve, not a steeper one, so '
        'it does not make a beam deflect one millimeter less. That is worth '
        'carrying into the deflection lesson.',
    source: 'mm-ssd-q1',
  ),
  PairRound(
    setting:
        'The two materials from this lesson\'s own problem. The first yields '
        'at 250 and breaks at 400 with 25 percent elongation. The second '
        'yields at 830, breaks at 830, and elongates half a percent.',
    ask: Ask.stronger,
    first: Specimen(
      label: 'material one',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    second: Specimen(
      label: 'material two',
      e: 200000,
      yieldStress: 830,
      ultimate: 830,
      fractureStrain: 0.005,
    ),
    why:
        'The second, and it is not close: twice the height. Which is exactly '
        'why the question is a trap when it is asked the other way round. '
        'Strong is the height of the curve and it says nothing at all about '
        'what happens on the way there.',
    source: 'mm-ssd-q2',
  ),
  PairRound(
    setting: 'The same two materials.',
    ask: Ask.warns,
    first: Specimen(
      label: 'material one',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    second: Specimen(
      label: 'material two',
      e: 200000,
      yieldStress: 830,
      ultimate: 830,
      fractureStrain: 0.005,
    ),
    why:
        'The first one, the weaker one. It yields at 250 and goes on '
        'stretching to 400, so it sags visibly long before it parts. The '
        'second breaks the instant it yields, at full strength, with no '
        'notice. Two tells for that on any report: yield and ultimate the same '
        'number, and an elongation of a percent or less.',
    source: 'mm-ssd-q2',
  ),
  PairRound(
    setting: 'Gray cast iron against annealed copper.',
    ask: Ask.stronger,
    first: Specimen(
      label: 'cast iron',
      e: 100000,
      yieldStress: 250,
      ultimate: 250,
      fractureStrain: 0.006,
    ),
    second: Specimen(
      label: 'copper',
      e: 117000,
      yieldStress: 70,
      ultimate: 220,
      fractureStrain: 0.45,
      necksTo: 0.78,
    ),
    why:
        'The cast iron, though only just, and the copper stretches something '
        'like seventy times further before it parts. Being the stronger of the '
        'two here buys nothing you would want in a structure: the iron goes '
        'without a sound. This is the pair that shows the two properties '
        'running in opposite directions.',
    source: 'mm-ssd-q2',
  ),
  PairRound(
    setting:
        'A titanium alloy against a mild steel. The titanium reaches a higher '
        'stress; the steel is the stiffer of the two.',
    ask: Ask.stretchier,
    first: Specimen(
      label: 'titanium alloy',
      e: 114000,
      yieldStress: 830,
      ultimate: 900,
      fractureStrain: 0.1,
      necksTo: 0.94,
    ),
    second: Specimen(
      label: 'mild steel',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    why:
        'The steel, by two and a half times, while being the weaker and the '
        'stiffer of the two. Three properties, three different answers, one '
        'pair of curves. Read the slope for stiff, the height for strong and '
        'the length for stretchy, and never read one of them off another.',
    source: 'mm-ssd-q2',
  ),
];

class _StiffStrongOrStretchyGameState extends State<StiffStrongOrStretchyGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stiff-strong-or-stretchy',
    chapterId: 'mechanics-materials',
    total: pairRounds.length,
    sourceProblemIdOf: (round) => pairRounds[round].source,
  )..addListener(_onSession);

  Which? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PairRound get _round => pairRounds[_session.round];

  String _label(Which v) => switch (v) {
        Which.first => _round.first.label,
        Which.second => _round.second.label,
        Which.alike => 'no real difference',
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stiff, Strong or Stretchy',
        closing:
            'Slope for stiff, height for strong, length for stretchy. All '
            'steels share the same slope whatever they cost. The strongest '
            'material on a page can be the one that gives you no warning at '
            'all. Read the feature the question actually asks about.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final frame = Frame.comparing([r.first, r.second]);

    return BoardShell(
      session: _session,
      brief: stiffStrongBrief,
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
            'READ IT OFF THE TWO CURVES',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.ask.reads,
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
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 200,
              child: CustomPaint(
                painter: PairPainter(
                  left: r.first,
                  right: r.second,
                  frame: frame,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Key(color: AppColors.info, label: r.first.label),
              const SizedBox(width: 14),
              _Key(color: AppColors.ember, label: r.second.label),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'one set of axes. the elastic part is drawn wider than scale',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          Text(
            r.ask.question,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          for (final v in Which.values) ...[
            _Choice(
              label: _label(v),
              selected: _picked == v,
              locked: answered,
              isTruth: v == r.answer,
              onTap: answered ? null : () => setState(() => _picked = v),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'READ RIGHT' : 'A DIFFERENT FEATURE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.mono(size: 11, color: AppColors.ink3)),
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
