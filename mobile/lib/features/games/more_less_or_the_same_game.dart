import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'redundant_figures.dart';

/// More, Less or the Same — the second item for `indeterminate-structures`.
///
/// Every number in the lesson's two standard results is a comparison in
/// disguise: the prop takes less than half because the stiff end takes more,
/// the midspan moment drops because moment appears at the ends instead, and
/// the sag drops because the ends are held. None of that needs arithmetic,
/// and knowing which way each one moves is what stops a student reaching for
/// the simple span formula on a beam that is built in.
class MoreLessOrTheSameGame extends StatefulWidget {
  const MoreLessOrTheSameGame({super.key});

  @override
  State<MoreLessOrTheSameGame> createState() => _MoreLessOrTheSameGameState();
}

/// How the quantity compares with the same beam simply supported.
enum Change { more, less, same }

@immutable
class CompareRound {
  const CompareRound({
    required this.subject,
    required this.asked,
    required this.ends,
    required this.marked,
    required this.topNote,
    required this.bottomNote,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Ends ends;
  final Marked marked;

  /// What the simply supported beam has, and what this one has. Both are
  /// written on the drawing once the round is over.
  final String topNote;
  final String bottomNote;
  final Change answer;
  final String why;
  final String source;

  static String label(Change which) => switch (which) {
        Change.more => 'More than the simple span has',
        Change.less => 'Less than the simple span has',
        Change.same => 'Exactly what the simple span has',
      };
}

const compareRounds = <CompareRound>[
  CompareRound(
    subject: 'the prop',
    asked:
        'A propped cantilever under a uniform load. How much of the load does '
        'the PROP carry, next to the end of a simply supported beam under the '
        'same load?',
    ends: Ends.fixedRoller,
    marked: Marked.rightEnd,
    topNote: 'wL/2',
    bottomNote: '3wL/8',
    answer: Change.less,
    why:
        'Less. The prop takes three eighths of the load where a simple '
        'support would take a half, because the built-in end is much the '
        'stiffer of the two and load goes where the stiffness is. This is the '
        'lesson\'s own standard result, and the commonest wrong answer to it '
        'is half the load, which is the number for the wrong beam.',
    source: 'str-ind-q2',
  ),
  CompareRound(
    subject: 'the built-in end',
    asked:
        'The same beam. How much does the BUILT-IN end carry, next to the end '
        'of the simply supported beam?',
    ends: Ends.fixedRoller,
    marked: Marked.leftEnd,
    topNote: 'wL/2',
    bottomNote: '5wL/8',
    answer: Change.more,
    why:
        'More: five eighths against a half. The two ends still have to add up '
        'to the whole load, so whatever the prop gives up the built-in end '
        'picks up. Stiffness attracts load, and being built in is as stiff as '
        'an end gets.',
    source: 'str-ind-q2',
  ),
  CompareRound(
    subject: 'the sag in the middle',
    asked:
        'A beam built in at BOTH ends under a uniform load. How far does its '
        'middle drop, next to the same beam simply supported?',
    ends: Ends.fixedFixed,
    marked: Marked.midSag,
    topNote: 'the reference sag',
    bottomNote: 'a fifth of it',
    answer: Change.less,
    why:
        'Less, and by a long way: a fifth of the simply supported sag under '
        'the same load. The walls hold the ends level instead of letting them '
        'rotate, and a beam that cannot rotate at its ends cannot drop as far '
        'in the middle. This is why continuity is worth having, and why '
        'deflection checks on continuous beams come out comfortable.',
    source: 'str-ind-q2',
  ),
  CompareRound(
    subject: 'the moment in the middle',
    asked:
        'The same beam built in at both ends. How big is the bending moment '
        'at MIDSPAN, next to the simply supported one?',
    ends: Ends.fixedFixed,
    marked: Marked.midMoment,
    topNote: 'wL squared over 8',
    bottomNote: 'wL squared over 24',
    answer: Change.less,
    why:
        'Less. The ends now hold moment of their own and that pulls the whole '
        'diagram down, leaving the middle with a third of what a simple span '
        'would carry. Nothing has been destroyed: the moment has moved to the '
        'supports, which is exactly what the next round is about.',
    source: 'str-ind-q3',
  ),
  CompareRound(
    subject: 'the moment at the end',
    asked:
        'The same beam again. How big is the bending moment AT a built-in '
        'end, next to the end of a simply supported beam?',
    ends: Ends.fixedFixed,
    marked: Marked.endMoment,
    topNote: 'zero',
    bottomNote: 'wL squared over 12',
    answer: Change.more,
    why:
        'More, because a simple support carries no moment at all and a wall '
        'carries plenty: wL squared over 12 for a uniform load. This is the '
        'lesson\'s named trap. Somebody reaching for wL squared over 8 has '
        'worked out the midspan moment of the WRONG beam and written it at '
        'the support, where the right answer is a smaller number.',
    source: 'str-ind-q3',
  ),
  CompareRound(
    subject: 'the load each end carries',
    asked:
        'That same beam built in at both ends, with the same uniform load. '
        'How much of the LOAD does each end carry, next to the simply '
        'supported beam?',
    ends: Ends.fixedFixed,
    marked: Marked.leftEnd,
    topNote: 'wL/2',
    bottomNote: 'wL/2',
    answer: Change.same,
    why:
        'Exactly the same: half each, because the beam and its load are '
        'symmetric and the two ends are identical, so there is nowhere for a '
        'difference to come from. Fixity changed the MOMENTS and it changed '
        'the sag, and it did not touch the vertical split at all. The propped '
        'cantilever was different only because its two ends were different.',
    source: 'str-ind-q3',
  ),
];

class _MoreLessOrTheSameGameState extends State<MoreLessOrTheSameGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'more-less-or-the-same',
    chapterId: 'structural',
    total: compareRounds.length,
    sourceProblemIdOf: (round) => compareRounds[round].source,
  )..addListener(_onSession);

  Change? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CompareRound get _round => compareRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'More, Less or the Same',
        closing:
            'Building an end in does three things and leaves one thing alone. '
            'It pulls load toward itself and away from the far end, it puts '
            'moment at the support and takes it out of the middle, and it '
            'cuts the sag. What it does not do is change the vertical split '
            'on a symmetric beam: half each, fixed or not. Every standard '
            'result in the lesson is one of those sentences with a number '
            'attached.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: fixityBrief,
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
            'AGAINST THE SIMPLE SPAN',
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
          const SizedBox(height: 12),
          Container(
            height: 236,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: SplitPainter(
                    ends: r.ends,
                    marked: r.marked,
                    topNote: r.topNote,
                    bottomNote: r.bottomNote,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{simple span: } R = \frac{wL}{2}, \; M = \frac{wL^2}{8}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Change.values) ...[
            _Choice(
              label: CompareRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Change.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
