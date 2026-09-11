import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pipe_figures.dart';

/// How Fast the Jet — the third item for `continuity-bernoulli`.
///
/// Torricelli falls straight out of Bernoulli once the two pressures cancel
/// and the surface is treated as still, and what it leaves is startling: the
/// jet speed depends on the HEAD and on nothing else. Not the size of the
/// hole, not how wide the tank is, not how much water is in it. Two tanks
/// side by side make that arguable in a way a formula does not.
class HowFastTheJetGame extends StatefulWidget {
  const HowFastTheJetGame({super.key});

  @override
  State<HowFastTheJetGame> createState() => _HowFastTheJetGameState();
}

/// Which jet comes out faster, or neither.
enum Quicker2 { left, right, tie }

extension QuickerWords2 on Quicker2 {
  String get plain => switch (this) {
        Quicker2.left => 'The left one',
        Quicker2.right => 'The right one',
        Quicker2.tie => 'Neither: the same speed',
      };
}

@immutable
class JetRound {
  const JetRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Squirt left;
  final Squirt right;
  final String why;
  final String source;

  /// Worked out from the two heads, never declared.
  Quicker2 get answer {
    final gap = (left.speed - right.speed).abs() /
        (left.speed > right.speed ? left.speed : right.speed);
    if (gap < 0.01) return Quicker2.tie;
    return left.speed > right.speed ? Quicker2.left : Quicker2.right;
  }

  double get tallest => left.head > right.head ? left.head : right.head;
}

const jetRounds = <JetRound>[
  JetRound(
    subject: 'two heads',
    setting:
        'Two tanks with holes at the bottom. The left one is filled to ten '
        'meters and the right one to two and a half.',
    left: Squirt(head: 10),
    right: Squirt(head: 2.5),
    why:
        'The left one, at 14 meters a second against 7. The head is the only '
        'thing in Torricelli, and it sits under a square root: four times the '
        'head is twice the jet. Ten meters of head is the lesson\'s own '
        'problem, and its answer is that 14.',
    source: 'fm-cb-q3',
  ),
  JetRound(
    subject: 'a big hole and a small one',
    setting:
        'Both tanks are filled to six meters. The left hole is a 100 '
        'millimeter port and the right one a 10 millimeter drilling.',
    left: Squirt(head: 6, holeMillimeters: 100),
    right: Squirt(head: 6, holeMillimeters: 10),
    why:
        'Neither: the same speed, and this is the one that surprises people. '
        'The size of the hole decides how MUCH comes out, not how fast it '
        'leaves. Every drop leaving the hole has fallen the same six meters '
        'of head, so every drop leaves at the same speed. The big hole simply '
        'lets more of them out at once.',
    source: 'fm-cb-q3',
  ),
  JetRound(
    subject: 'a reservoir and a standpipe',
    setting:
        'Both are filled to four meters above the hole. The left is a wide '
        'reservoir and the right a narrow standpipe holding a fraction as '
        'much water.',
    left: Squirt(head: 4, tankWide: 6),
    right: Squirt(head: 4, tankWide: 0.8),
    why:
        'Neither. How much water is behind the hole does not come into it '
        'either: only the height of the surface above it. A narrow pipe four '
        'meters tall squirts exactly as hard as a lake four meters deep, and '
        'it empties a great deal sooner.',
    source: 'fm-cb-q3',
  ),
  JetRound(
    subject: 'four times the head',
    setting:
        'The left tank is filled to twelve meters and the right to three.',
    left: Squirt(head: 12),
    right: Squirt(head: 3),
    why:
        'The left one, and by two rather than four. The square root softens '
        'it: four times the head gives twice the speed, 15.3 against 7.7. '
        'This is the same square root that turns up in the lesson\'s named '
        'trap, where dropping the 2 under it gives 9.9 instead of 14.',
    source: 'fm-cb-q3',
  ),
  JetRound(
    subject: 'the same tank, two holes',
    setting:
        'One tank, ten meters of water. The left jet comes from a hole at the '
        'very bottom and the right from one halfway up.',
    left: Squirt(head: 10),
    right: Squirt(head: 5),
    why:
        'The bottom one, at 14 against 9.9. Each hole answers to the head '
        'above IT, not to the depth of the tank, so a row of holes down a '
        'wall gives a row of jets that get faster the lower you go. That is '
        'the same triangle of pressure as on a dam.',
    source: 'fm-cb-q3',
  ),
  JetRound(
    subject: 'a wide shallow pan and a tall thin tube',
    setting:
        'The left is a broad shallow pan holding half a meter over its hole. '
        'The right is a thin tube standing eight meters tall.',
    left: Squirt(head: 0.5, tankWide: 8, holeMillimeters: 60),
    right: Squirt(head: 8, tankWide: 0.5, holeMillimeters: 8),
    why:
        'The tall thin one, four times as fast, though the pan may hold more '
        'water and has the bigger hole. Neither of those is in the formula. '
        'Only the height of the surface above the hole is, which is why a '
        'header tank high up does more for pressure than a big tank low '
        'down.',
    source: 'fm-cb-q3',
  ),
];

class _HowFastTheJetGameState extends State<HowFastTheJetGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-fast-the-jet',
    chapterId: 'fluid-mechanics',
    total: jetRounds.length,
    sourceProblemIdOf: (round) => jetRounds[round].source,
  )..addListener(_onSession);

  Quicker2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  JetRound get _round => jetRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Fast the Jet',
        closing:
            'The jet leaves at the root of twice g times the HEAD, and '
            'nothing else is in it: not the size of the hole, not the width '
            'of the tank, not how much water is behind it. The hole decides '
            'how much comes out, not how fast. And the square root softens '
            'the head, so four times the depth is only twice the speed.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: torricelliBrief,
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
            'WHICH JET IS FASTER',
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
                    squirt: i == 0 ? r.left : r.right,
                    tallest: r.tallest,
                    selected:
                        _picked == (i == 0 ? Quicker2.left : Quicker2.right),
                    locked: answered,
                    isTruth:
                        r.answer == (i == 0 ? Quicker2.left : Quicker2.right),
                    onTap: answered
                        ? null
                        : () => setState(() => _picked =
                            i == 0 ? Quicker2.left : Quicker2.right),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$v = \sqrt{2gh}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Quicker2.tie.plain,
            selected: _picked == Quicker2.tie,
            locked: answered,
            isTruth: r.answer == Quicker2.tie,
            onTap:
                answered ? null : () => setState(() => _picked = Quicker2.tie),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
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

class _Panel extends StatelessWidget {
  const _Panel({
    required this.squirt,
    required this.tallest,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Squirt squirt;
  final double tallest;
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
          height: 210,
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
                painter: SquirtPainter(
                  squirt: squirt,
                  tallest: tallest,
                  showJet: locked,
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
