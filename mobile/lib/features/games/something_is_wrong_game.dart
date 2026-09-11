import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Something Is Wrong Here — the second item for `asphalt-mix-design`.
///
/// Asphalt volumetrics are four or five numbers that all have to agree with
/// each other, and the lesson's own warning is a sanity check rather than a
/// formula: a negative air void means the two gravities were swapped. That is
/// the skill worth having on a phone. Each round is a page from a mix report
/// with one line on it that cannot be true, and finding it needs no
/// arithmetic, only the relationships between the numbers.
class SomethingIsWrongGame extends StatefulWidget {
  const SomethingIsWrongGame({super.key});

  @override
  State<SomethingIsWrongGame> createState() => _SomethingIsWrongGameState();
}

@immutable
class ReportRound {
  const ReportRound({
    required this.subject,
    required this.lines,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The report, as label and value pairs, in the order they are printed.
  final List<(String, String)> lines;

  /// Which line cannot be right.
  final int answer;
  final String why;
  final String source;
}

const reportRounds = <ReportRound>[
  ReportRound(
    subject: 'a specimen that came out negative',
    lines: [
      ('bulk specific gravity, Gmb', '2.440'),
      ('theoretical maximum, Gmm', '2.480'),
      ('air voids', 'minus 1.6 percent'),
      ('VMA', '14.2 percent'),
    ],
    answer: 2,
    why:
        'There is no such thing as negative air. The two gravities on this '
        'report are the right way round, with the theoretical maximum the '
        'larger, as it always is: it is the same materials with the air '
        'squeezed out, so more mass in less volume. Whoever worked the air '
        'voids out put them into the formula the other way round, which is '
        'the lesson\'s own warning. Done properly these two give 1.6 percent, '
        'positive.',
    source: 'mat-asp-q1',
  ),
  ReportRound(
    subject: 'a report where the voids do not add up',
    lines: [
      ('air voids', '4.0 percent'),
      ('VMA', '3.2 percent'),
      ('VFA', '72 percent'),
      ('binder content', '5.1 percent'),
    ],
    answer: 1,
    why:
        'The VMA is smaller than the air voids, which is impossible: the VMA '
        'is the whole space between the stones and the air is only part of '
        'it. VMA is air plus the binder voids, so it has to be the larger of '
        'the two on every report ever written.',
    source: 'mat-asp-q3',
  ),
  ReportRound(
    subject: 'a mix that is somehow overfull',
    lines: [
      ('air voids', '4.0 percent'),
      ('VMA', '15.0 percent'),
      ('VFA', '104 percent'),
      ('bulk specific gravity, Gmb', '2.401'),
    ],
    answer: 2,
    why:
        'A VFA over a hundred says the binder fills more than all the space '
        'there is. It is a share of the VMA, so it cannot pass a hundred, and '
        'with four percent air in fifteen percent of voids it should be about '
        '73. Anything above a hundred means the air was not taken off, or the '
        'two were divided the wrong way round.',
    source: 'mat-asp-q2',
  ),
  ReportRound(
    subject: 'a VMA that would be mostly holes',
    lines: [
      ('aggregate share by mass, Ps', '95 percent'),
      ('aggregate bulk gravity, Gsb', '2.65'),
      ('VMA', '86.0 percent'),
      ('air voids', '4.1 percent'),
    ],
    answer: 2,
    why:
        'Eighty six percent void is not a road surface, it is a sponge. That '
        'number is the term the VMA formula SUBTRACTS, the volume the stone '
        'itself occupies, and the VMA is what is left: about fourteen '
        'percent. Reporting the subtracted term is the lesson problem\'s own '
        'named wrong answer, and its size gives it away.',
    source: 'mat-asp-q3',
  ),
  ReportRound(
    subject: 'three numbers that disagree',
    lines: [
      ('air voids', '4.0 percent'),
      ('VMA', '15.0 percent'),
      ('VFA', '27 percent'),
      ('theoretical maximum, Gmm', '2.500'),
    ],
    answer: 2,
    why:
        'The VFA is the air-filled share, not the binder-filled one: 4 over '
        '15 rather than 11 over 15. Filled with asphalt means the part the '
        'BINDER has taken, about 73 percent here. The two always add to a '
        'hundred, so a VFA of 27 with these voids is the right arithmetic '
        'answering the wrong question.',
    source: 'mat-asp-q2',
  ),
  ReportRound(
    subject: 'an air void that reads like a ratio',
    lines: [
      ('bulk specific gravity, Gmb', '2.400'),
      ('theoretical maximum, Gmm', '2.500'),
      ('air voids', '0.96 percent'),
      ('VMA', '14.8 percent'),
    ],
    answer: 2,
    why:
        'That is Gmb divided by Gmm, which is 0.96 and has nothing to do with '
        'the voids. With those two gravities the air comes to four percent: '
        'the DIFFERENCE over the maximum, not one over the other. A ratio of '
        'two numbers that are nearly equal lands near one, and an air void '
        'near one percent should make you look again.',
    source: 'mat-asp-q1',
  ),
];

class _SomethingIsWrongGameState extends State<SomethingIsWrongGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'something-is-wrong',
    chapterId: 'materials',
    total: reportRounds.length,
    sourceProblemIdOf: (round) => reportRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ReportRound get _round => reportRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Something Is Wrong Here',
        closing:
            'Four checks catch nearly everything. The theoretical maximum is '
            'always bigger than the bulk gravity. The VMA is always bigger '
            'than the air voids. The VFA is a share of the VMA, so it stops '
            'at a hundred. And a VMA near eighty is the stone volume, not the '
            'void space. None of that needs a calculator, and all of it '
            'catches a swapped pair.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: checkBrief,
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
            'TAP THE LINE THAT CANNOT BE RIGHT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'A page from a mix report. One number on it cannot be right.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.lines.length; i++) ...[
            _Line(
              label: r.lines[i].$1,
              value: r.lines[i].$2,
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'THAT ONE CANNOT BE RIGHT'
                  : 'THAT LINE IS FINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final String value;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.mono(size: 12.5, color: AppColors.ink3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: AppTheme.mono(size: 13.5, color: AppColors.charcoal)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
