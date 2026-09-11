import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vibration_figures.dart';

/// Faster or Slower — the first item for `vibrations-natural-frequency`.
///
/// Everything on this exam's vibration page comes out of one expression, the
/// square root of stiffness over mass, and what is worth knowing about it is
/// not the arithmetic but its shape: stiffer is quicker, heavier is slower,
/// the square root softens both, and nothing else in the situation gets a say
/// at all. How far you pull it does not change it, which is the fact that
/// surprises people.
class FasterOrSlowerGame extends StatefulWidget {
  const FasterOrSlowerGame({super.key});

  @override
  State<FasterOrSlowerGame> createState() => _FasterOrSlowerGameState();
}

/// Which of the two shakes quicker.
enum Quicker { left, right, same }

extension QuickerWords on Quicker {
  String get plain => switch (this) {
        Quicker.left => 'The left one',
        Quicker.right => 'The right one',
        Quicker.same => 'Neither: the same frequency',
      };
}

@immutable
class PairRound3 {
  const PairRound3({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
    this.pulls,
  });

  final String subject;
  final String setting;
  final Bouncer left;
  final Bouncer right;
  final String why;
  final String source;

  /// How far each one was pulled aside before release, when that is what the
  /// round is about. Null on every other round, and nothing is drawn.
  final (double, double)? pulls;

  /// Worked out from the two systems, never declared.
  Quicker get answer {
    final gap = (left.omega - right.omega).abs() /
        math.max(left.omega, right.omega);
    if (gap < 0.01) return Quicker.same;
    return left.omega > right.omega ? Quicker.left : Quicker.right;
  }

  double get ratio => left.omega > right.omega
      ? left.omega / right.omega
      : right.omega / left.omega;

  (double, double) get frame => (
        math.max(left.mass, right.mass),
        math.max(left.stiffness, right.stiffness),
      );
}

const pairRounds3 = <PairRound3>[
  PairRound3(
    subject: 'the same mass, a stiffer spring',
    setting:
        'Two identical blocks, one on a spring four times as stiff as the '
        'other.',
    left: Bouncer(mass: 50, stiffness: 800),
    right: Bouncer(mass: 50, stiffness: 3200),
    why:
        'The stiffer one, and by TWO rather than four. Stiffness is under a '
        'square root, so four times the spring is only twice the frequency. '
        'That softening is why stiffening a floor to cure a bounce takes so '
        'much more stiffness than people expect.',
    source: 'dyn-vib-q1',
  ),
  PairRound3(
    subject: 'the same spring, a heavier block',
    setting: 'The same spring under two blocks, one four times the mass.',
    left: Bouncer(mass: 50, stiffness: 800),
    right: Bouncer(mass: 200, stiffness: 800),
    why:
        'The lighter one, again by two. Mass is underneath, so more of it '
        'slows the system down, and the square root softens this side too. '
        'Hanging weight on a springy floor lowers its natural frequency, which '
        'is sometimes exactly what you want and sometimes the opposite.',
    source: 'dyn-vib-q1',
  ),
  PairRound3(
    subject: 'both doubled',
    setting:
        'One system has twice the mass AND twice the stiffness of the other.',
    left: Bouncer(mass: 100, stiffness: 1600),
    right: Bouncer(mass: 50, stiffness: 800),
    why:
        'Neither: exactly the same. The ratio of stiffness to mass is what the '
        'formula cares about, and doubling both leaves that ratio alone. Two '
        'systems that look nothing alike can shake at the same rate, and two '
        'that look identical can be far apart.',
    source: 'dyn-vib-q1',
  ),
  PairRound3(
    subject: 'the same system, pulled further',
    setting:
        'The same block on the same spring, twice. The left one is pulled '
        'aside twice as far before being let go.',
    left: Bouncer(mass: 50, stiffness: 800),
    right: Bouncer(mass: 50, stiffness: 800),
    pulls: (2, 1),
    why:
        'Neither, and this is the one worth remembering. How far you pull it '
        'does not appear in the formula anywhere: the natural frequency '
        'belongs to the SYSTEM, not to how hard you set it going. The big '
        'swing travels further and it travels faster, and the two effects '
        'cancel exactly.',
    source: 'dyn-vib-q1',
  ),
  PairRound3(
    subject: 'a machine mounting',
    setting:
        'The lesson\'s two thousand newton machine on a fifty thousand newton '
        'per meter mounting, against a lighter machine on the same mounting.',
    left: Bouncer(mass: 203.9, stiffness: 50000),
    right: Bouncer(mass: 100, stiffness: 50000),
    why:
        'The lighter machine. Note what had to happen before this could be '
        'compared at all: the two thousand newtons is a WEIGHT, and it is '
        'about two hundred and four kilograms of mass. Putting the newtons '
        'straight into the formula makes the machine five times lighter than '
        'it is and its frequency more than twice too fast.',
    source: 'dyn-vib-q2',
  ),
  PairRound3(
    subject: 'a soft mounting under a heavy machine',
    setting:
        'A heavy machine on a soft mounting against a light one on a stiff '
        'mounting. Both ratios are worth reading before answering.',
    left: Bouncer(mass: 400, stiffness: 10000),
    right: Bouncer(mass: 100, stiffness: 40000),
    why:
        'The right hand one, and by four: a quarter of the mass and four times '
        'the stiffness, which is sixteen times the ratio and four times the '
        'frequency once the square root has had its say. Reading the ratio '
        'rather than either number on its own is the whole trick, and it is '
        'how machine mountings are designed: make the mounting soft enough '
        'that the machine\'s running speed sits well ABOVE the natural '
        'frequency.',
    source: 'dyn-vib-q2',
  ),
];

class _FasterOrSlowerGameState extends State<FasterOrSlowerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'faster-or-slower',
    chapterId: 'dynamics',
    total: pairRounds3.length,
    sourceProblemIdOf: (round) => pairRounds3[round].source,
  )..addListener(_onSession);

  Quicker? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PairRound3 get _round => pairRounds3[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Faster or Slower',
        closing:
            'Stiffer is quicker, heavier is slower, and the square root '
            'softens both: four times the stiffness is only twice the '
            'frequency. What matters is the RATIO of the two, so doubling both '
            'changes nothing. And how far you pull it does not appear in the '
            'formula at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: naturalBrief,
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
            'WHICH ONE SHAKES QUICKER',
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
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Panel(
                    bouncer: i == 0 ? r.left : r.right,
                    frame: r.frame,
                    pull: i == 0 ? r.pulls?.$1 : r.pulls?.$2,
                    selected: _picked ==
                        (i == 0 ? Quicker.left : Quicker.right),
                    locked: answered,
                    isTruth: r.answer ==
                        (i == 0 ? Quicker.left : Quicker.right),
                    onTap: answered
                        ? null
                        : () => setState(() =>
                            _picked = i == 0 ? Quicker.left : Quicker.right),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: MathText(
              r'$\omega_n = \sqrt{\dfrac{k}{m}}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Quicker.same.plain,
            selected: _picked == Quicker.same,
            locked: answered,
            isTruth: r.answer == Quicker.same,
            onTap: answered ? null : () => setState(() => _picked = Quicker.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE QUICKER ONE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.bouncer,
    required this.frame,
    required this.pull,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Bouncer bouncer;
  final (double, double) frame;
  final double? pull;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 190,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: SpringPainter(
                  bouncer: bouncer,
                  frame: frame,
                  pull: pull,
                  label: '${bouncer.mass.round()} kg on '
                      '${bouncer.stiffness.round()} N/m',
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
