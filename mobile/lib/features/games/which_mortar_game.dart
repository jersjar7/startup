import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'wood_figures.dart';

/// Which Mortar — the second item for `wood-masonry`.
///
/// Four letters in an order that is not alphabetical, not obvious, and worth
/// a mark on the exam: M, S, N, O, strongest to weakest. There is nothing to
/// reason out here and no arithmetic to do, which is exactly what a phone is
/// for. The rounds ask it from both ends and from the trade-off that comes
/// with it, because the strongest mortar is not the best mortar.
class WhichMortarGame extends StatefulWidget {
  const WhichMortarGame({super.key});

  @override
  State<WhichMortarGame> createState() => _WhichMortarGameState();
}

@immutable
class MortarRound {
  const MortarRound({
    required this.subject,
    required this.asked,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Mortar answer;
  final String why;
  final String source;
}

const mortarRounds = <MortarRound>[
  MortarRound(
    subject: 'the strongest of the four',
    asked: 'Which mortar type has the highest compressive strength?',
    answer: Mortar.m,
    why:
        'Type M. The four run M, S, N, O from strongest to weakest, which is '
        'the every-other letter of the phrase MaSoN wOrK. Nothing about the '
        'letters themselves tells you the order, so the phrase is worth two '
        'minutes of memorizing before the exam.',
    source: 'mat-wm-q2',
  ),
  MortarRound(
    subject: 'the weakest of the four',
    asked: 'Which mortar type has the lowest compressive strength?',
    answer: Mortar.o,
    why:
        'Type O, the last letter of the four. It is the one for interior '
        'work and repointing old soft brick, where a hard mortar would do '
        'harm: a joint stronger than the units it joins puts the cracking '
        'into the brick instead of the joint, and brick is far more expensive '
        'to replace than mortar.',
    source: 'mat-wm-q2',
  ),
  MortarRound(
    subject: 'the middle pair',
    asked: 'Of Types S and N, which is the stronger?',
    answer: Mortar.s,
    why:
        'Type S, because S comes before N in the order. This is the pair that '
        'gets mixed up most, since neither letter suggests anything. S is the '
        'usual choice where a wall is in contact with the ground or takes '
        'lateral load, and N is the general purpose mortar above grade.',
    source: 'mat-wm-q2',
  ),
  MortarRound(
    subject: 'the easiest to work with',
    asked:
        'Which of them gives the most workability and the most forgiving '
        'bond?',
    answer: Mortar.o,
    why:
        'Type O again, the weakest. Strength and workability trade against '
        'each other in mortar: the high strength mixes are stiffer under the '
        'trowel and less forgiving of movement. That trade is the reason all '
        'four types exist rather than everybody specifying the strongest.',
    source: 'mat-wm-q2',
  ),
  MortarRound(
    subject: 'a wall below grade',
    asked:
        'A foundation wall below grade needs the strongest mortar of the '
        'four. Which is it?',
    answer: Mortar.m,
    why:
        'Type M, where the strength is actually wanted: below grade, against '
        'earth pressure and wet. Note that the strength order is the only '
        'thing being asked here. The letters never line up with anything '
        'else, so read the order off the phrase and nothing else.',
    source: 'mat-wm-q2',
  ),
  MortarRound(
    subject: 'the second weakest',
    asked: 'Which type sits one place above the weakest?',
    answer: Mortar.n,
    why:
        'Type N, which is the common general purpose mortar for walls above '
        'grade. Counting from the weak end is worth practicing: O is weakest, '
        'then N, then S, then M. Being able to run the order in both '
        'directions is what stops the middle two from swapping in your head.',
    source: 'mat-wm-q2',
  ),
];

class _WhichMortarGameState extends State<WhichMortarGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-mortar',
    chapterId: 'materials',
    total: mortarRounds.length,
    sourceProblemIdOf: (round) => mortarRounds[round].source,
  )..addListener(_onSession);

  Mortar? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MortarRound get _round => mortarRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Mortar',
        closing:
            'M, S, N, O: strongest to weakest, and the every-other letter of '
            'MaSoN wOrK. Strength trades against workability and against '
            'forgiveness, so the strongest is not the best: a joint harder '
            'than the brick it joins moves the cracking into the brick. M '
            'below grade, S where there is lateral load, N for general work, '
            'O for soft old masonry indoors.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: mortarBrief,
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
            'PICK THE TYPE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          for (final option in Mortar.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.mono(size: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
