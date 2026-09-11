import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Add Up the Losses — the third item for `pipe-flow-head-loss`.
///
/// The last problem in this lesson is an addition, and every one of its wrong
/// answers is a piece left out or put in twice: the friction alone, the
/// fittings alone, the friction counted again. So the rounds never ask for a
/// number. They show the line somebody has written down and ask whether it is
/// the total the question wanted.
class AddUpTheLossesGame extends StatefulWidget {
  const AddUpTheLossesGame({super.key});

  @override
  State<AddUpTheLossesGame> createState() => _AddUpTheLossesGameState();
}

/// What is wrong with a line of working, if anything.
enum Wrote { right, missingFriction, missingFittings, doubled, wrongCount }

extension WroteWords on Wrote {
  String get plain => switch (this) {
        Wrote.right => 'Nothing wrong: that is the total',
        Wrote.missingFriction => 'The pipe friction has been left out',
        Wrote.missingFittings => 'The fittings have been left out',
        Wrote.doubled => 'A number that was already a total is added again',
        Wrote.wrongCount => 'A fitting has been counted the wrong number of '
            'times',
      };
}

@immutable
class TallyRound {
  const TallyRound({
    required this.subject,
    required this.setting,
    required this.written,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The line of working, as it was written down.
  final String written;
  final List<Wrote> options;
  final Wrote answer;
  final String why;
  final String source;
}

/// The lesson's own system, quoted in every round: 3.2 m of friction, two
/// elbows at 0.9 and a globe valve at 10, with a velocity head of 0.32 m.
const _system =
    'friction 3.2 m, two elbows at C = 0.9, one globe valve at C = 10.0, '
    'velocity head 0.32 m';

const tallyRounds = <TallyRound>[
  TallyRound(
    subject: 'the fittings on their own',
    setting: _system,
    written: r'$h = 11.8 \times 0.32 = 3.76$ m',
    options: [
      Wrote.missingFriction,
      Wrote.right,
      Wrote.doubled,
      Wrote.missingFittings
    ],
    answer: Wrote.missingFriction,
    why:
        'The coefficients are added correctly, 0.9 twice plus 10, and '
        'multiplied by the velocity head correctly. What is missing is the '
        '3.2 meters the pipe itself costs. Total loss is the friction PLUS '
        'the fittings, and this is the fittings alone: it is the lesson '
        'problem\'s own named wrong answer.',
    source: 'fm-pfh-q3',
  ),
  TallyRound(
    subject: 'the pipe on its own',
    setting: _system,
    written: r'$h = 3.2$ m',
    options: [
      Wrote.right,
      Wrote.missingFittings,
      Wrote.wrongCount,
      Wrote.doubled
    ],
    answer: Wrote.missingFittings,
    why:
        'Only the friction. A globe valve at C = 10 is an enormous loss, '
        'worth more on its own than the whole hundred meters of pipe in that '
        'problem, so leaving the fittings out is not a small simplification '
        'here. Valves and bends are called MINOR losses and frequently are '
        'not.',
    source: 'fm-pfh-q3',
  ),
  TallyRound(
    subject: 'both pieces, added',
    setting: _system,
    written: r'$h = 3.2 + 11.8 \times 0.32 = 6.96$ m',
    options: [
      Wrote.doubled,
      Wrote.right,
      Wrote.missingFriction,
      Wrote.wrongCount
    ],
    answer: Wrote.right,
    why:
        'That is the total: the pipe friction plus every fitting, each at its '
        'own coefficient times the same velocity head. Note that one velocity '
        'head serves all of them, because the water is going the same speed '
        'through the lot.',
    source: 'fm-pfh-q3',
  ),
  TallyRound(
    subject: 'one elbow',
    setting: _system,
    written: r'$h = 3.2 + (0.9 + 10.0) \times 0.32 = 6.69$ m',
    options: [
      Wrote.right,
      Wrote.wrongCount,
      Wrote.doubled,
      Wrote.missingFriction
    ],
    answer: Wrote.wrongCount,
    why:
        'There are TWO elbows and only one has been counted. It is a small '
        'error here, about a quarter of a meter, and it is the one that hides '
        'best: the working looks complete and the answer looks sensible. '
        'Count the fittings off the drawing before adding anything up.',
    source: 'fm-pfh-q3',
  ),
  TallyRound(
    subject: 'the friction, twice',
    setting: _system,
    written: r'$h = 3.2 + 6.96 = 10.16$ m',
    options: [
      Wrote.doubled,
      Wrote.right,
      Wrote.missingFittings,
      Wrote.wrongCount
    ],
    answer: Wrote.doubled,
    why:
        'The 6.96 was already the total, friction and fittings together, and '
        'the 3.2 has been added to it again. This is what happens when a '
        'number gets carried down a page without a label. Writing the units '
        'and the name beside each figure is not fussiness, it is how this '
        'mistake gets caught.',
    source: 'fm-pfh-q3',
  ),
  TallyRound(
    subject: 'every coefficient doubled',
    setting: _system,
    written: r'$h = 3.2 + 2(0.9 + 10.0) \times 0.32 = 10.2$ m',
    options: [
      Wrote.wrongCount,
      Wrote.missingFriction,
      Wrote.right,
      Wrote.doubled
    ],
    answer: Wrote.wrongCount,
    why:
        'The two has been applied to the whole bracket, so the globe valve '
        'has been counted twice along with the elbows. There is one valve. '
        'The fastest guard against this is to write the sum out fitting by '
        'fitting, 0.9 plus 0.9 plus 10, rather than reaching for a '
        'multiplier.',
    source: 'fm-pfh-q3',
  ),
];

class _AddUpTheLossesGameState extends State<AddUpTheLossesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'add-up-the-losses',
    chapterId: 'fluid-mechanics',
    total: tallyRounds.length,
    sourceProblemIdOf: (round) => tallyRounds[round].source,
  )..addListener(_onSession);

  Wrote? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TallyRound get _round => tallyRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Add Up the Losses',
        closing:
            'The total is the pipe friction PLUS every fitting, with each '
            'fitting at its own coefficient times the same velocity head. '
            'Count the fittings off the drawing rather than reaching for a '
            'multiplier, label every number you write down so a total does '
            'not get added twice, and remember that a globe valve can cost '
            'more than the pipe it sits in.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: minorBrief,
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
            'WHAT IS WRONG WITH THIS LINE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'The system: ${r.setting}.',
            style: AppTheme.mono(size: 12, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(
              child: MathText(
                r.written,
                style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in r.options) ...[
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
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT',
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
