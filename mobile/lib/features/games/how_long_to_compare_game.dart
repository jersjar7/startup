import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cash_flow_figures.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// How Long to Compare Over — the second item for `pw-fw-aw-analysis`.
///
/// The lesson's hard problem is a six year pump against a four year one, and
/// its named trap is comparing them by present worth over their own lives.
/// Nothing about that looks wrong on paper. It is only wrong because the two
/// numbers cover different amounts of time, which is invisible in algebra and
/// unmissable once the lives are drawn as blocks on one line.
///
/// Two ways out. Repeat each alternative until they end together, which is
/// the least common multiple, or use annual worth, which handles it for free.
/// The second is why anybody bothers with annual worth at all.
class HowLongToCompareGame extends StatefulWidget {
  const HowLongToCompareGame({super.key});

  @override
  State<HowLongToCompareGame> createState() => _HowLongToCompareGameState();
}

enum Study { shorter, multiple, annualWorth }

@immutable
class StudyRound {
  const StudyRound({
    required this.subject,
    required this.setting,
    required this.lifeA,
    required this.lifeB,
    required this.nameA,
    required this.nameB,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final int lifeA;
  final int lifeB;
  final String nameA;
  final String nameB;
  final Study answer;
  final String why;
  final String source;

  /// Where the two lives finally end together.
  int get multiple {
    var a = lifeA;
    while (a % lifeB != 0) {
      a += lifeA;
    }
    return a;
  }

  /// How far the picture runs. To the point where the two lives end together,
  /// unless that is so far out that the blocks become slivers.
  int get span =>
      multiple <= 26 ? multiple : (lifeA > lifeB ? lifeA : lifeB) * 2;
}

const studyRounds = <StudyRound>[
  StudyRound(
    subject: 'two pumps, by present worth',
    setting:
        'Pump X lasts 6 years and Pump Y lasts 4. The utility wants to compare '
        'them on PRESENT WORTH. Over how long?',
    lifeA: 6,
    lifeB: 4,
    nameA: 'Pump X',
    nameB: 'Pump Y',
    answer: Study.multiple,
    why:
        'Twelve years, which is two of X against three of Y. Present worth '
        'prices a period, so the two periods have to be the same one, and six '
        'against four is comparing a longer service to a shorter one and '
        'calling the shorter one cheap.',
    source: 'econ-pfa-q3',
  ),
  StudyRound(
    subject: 'the same two pumps, differently',
    setting:
        'Pump X lasts 6 years and Pump Y lasts 4. The utility decides to '
        'compare them on ANNUAL WORTH instead.',
    lifeA: 6,
    lifeB: 4,
    nameA: 'Pump X',
    nameB: 'Pump Y',
    answer: Study.annualWorth,
    why:
        'Annual worth is already a rate, dollars per year, and two rates '
        'compare directly however long each thing lasts. This is the reason '
        'the method exists and the reason it is worth reaching for first.',
    source: 'econ-pfa-q3',
  ),
  StudyRound(
    subject: 'two culverts of the same age',
    setting:
        'Both culvert options last 20 years. The county wants to compare them '
        'on present worth.',
    lifeA: 20,
    lifeB: 20,
    nameA: 'Option A',
    nameB: 'Option B',
    answer: Study.shorter,
    why:
        'Equal lives, so there is nothing to reconcile and the common period '
        'is the life itself. Reaching for a least common multiple here is '
        'answering a question nobody asked.',
    source: 'econ-pfa-q1',
  ),
  StudyRound(
    subject: 'a liner against a rebuild',
    setting:
        'A liner lasts 5 years and a full rebuild lasts 15. The comparison is '
        'to be made on PRESENT WORTH.',
    lifeA: 5,
    lifeB: 15,
    nameA: 'Liner',
    nameB: 'Rebuild',
    answer: Study.multiple,
    why:
        'Fifteen years, which is three liners against one rebuild. When one '
        'life divides the other the multiple is just the longer one, and the '
        'short option simply repeats inside it.',
    source: 'econ-pfa-q3',
  ),
  StudyRound(
    subject: 'a fleet decision on a rate',
    setting:
        'A truck lasts 7 years and a leased alternative runs on 3 year terms. '
        'The comparison is on ANNUAL WORTH.',
    lifeA: 7,
    lifeB: 3,
    nameA: 'Own it',
    nameB: 'Lease it',
    answer: Study.annualWorth,
    why:
        'Twenty one years is a study period nobody would sit through, and '
        'annual worth removes the need for it entirely. Awkward lives are '
        'exactly when the method earns its keep.',
    source: 'econ-pfa-q3',
  ),
  StudyRound(
    subject: 'two roofs on one building',
    setting:
        'Both roofing systems are guaranteed for 25 years and the building '
        'itself is being assessed over 25. The comparison is on present worth.',
    lifeA: 25,
    lifeB: 25,
    nameA: 'System A',
    nameB: 'System B',
    answer: Study.shorter,
    why:
        'The lives match each other and match the study period the owner '
        'actually cares about. Present worth is perfectly comfortable here, '
        'and there is nothing clever to do.',
    source: 'econ-pfa-q1',
  ),
];

class _HowLongToCompareGameState extends State<HowLongToCompareGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-long-to-compare',
    chapterId: 'economics',
    total: studyRounds.length,
    sourceProblemIdOf: (round) => studyRounds[round].source,
  )..addListener(_onSession);

  Study? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StudyRound get _round => studyRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Long to Compare Over',
        closing:
            'Present worth prices a period, so the period has to be the same '
            'one for both. Equal lives need nothing; unequal lives need '
            'repeating until they end together. Annual worth is a rate and '
            'sidesteps the whole business.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: studyPeriodBrief,
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
            'OVER WHAT PERIOD',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: LivesPainter(
                    lifeA: r.lifeA,
                    lifeB: r.lifeB,
                    span: r.span,
                    nameA: r.nameA,
                    nameB: r.nameB,
                    // The mark only appears once it is answered, and only when
                    // repeating them is what the answer turned out to be.
                    bracket: answered && r.answer == Study.multiple
                        ? r.multiple
                        : null,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final s in Study.values) ...[
            if (s != Study.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('study-${s.name}'),
              title: switch (s) {
                Study.shorter => 'Their own life',
                Study.multiple => 'Repeat until they end together',
                Study.annualWorth => 'It does not matter. Use annual worth.',
              },
              note: switch (s) {
                Study.shorter => 'they already cover the same period',
                Study.multiple => 'the least common multiple of the two lives',
                Study.annualWorth => 'a rate compares to a rate',
              },
              selected: _picked == s,
              locked: answered,
              isTruth: s == r.answer,
              onTap: answered ? null : () => setState(() => _picked = s),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT PERIOD' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
