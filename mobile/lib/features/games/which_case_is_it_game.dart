import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'consolidation_figures.dart';

/// Which Case Is It — the first item for `consolidation`.
///
/// Three settlement formulas sit in the handbook and picking between them is
/// the whole of the hard part: everything turns on where the load leaves the
/// clay against the largest pressure it has ever carried. Under that memory
/// the clay is stiff, past it the clay is soft, and a load that crosses the
/// line has to be worked out in two pieces.
class WhichCaseIsItGame extends StatefulWidget {
  const WhichCaseIsItGame({super.key});

  @override
  State<WhichCaseIsItGame> createState() => _WhichCaseIsItGameState();
}

@immutable
class CaseRound {
  const CaseRound({
    required this.subject,
    required this.asked,
    required this.squeeze,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Squeeze squeeze;
  final String why;
  final String source;

  /// The pressures decide it.
  Case get answer => squeeze.which;

  static String label(Case which) => switch (which) {
        Case.recompression =>
          'All of it in recompression: the stiff index alone',
        Case.normally => 'Normally consolidated: the soft index alone',
        Case.crossing => 'It crosses: both indexes, in two pieces',
      };
}

const caseRounds = <CaseRound>[
  CaseRound(
    subject: 'the lesson\'s own clay',
    asked:
        'A normally consolidated clay carries 1,000 pounds a square foot and '
        '500 more are added. Which case?',
    squeeze: Squeeze(now: 1000, remembered: 1000, added: 500),
    why:
        'Normally consolidated, which means the clay has never carried more '
        'than it carries right now: its memory and its present are the same '
        'number. Every pound added is therefore new ground, worked out with '
        'the compression index alone, and this is the case that settles the '
        'most for a given load.',
    source: 'geo-co-q1',
  ),
  CaseRound(
    subject: 'a clay with room to spare',
    asked:
        'This clay carries 800 and remembers 1,500. Four hundred are added. '
        'Which case?',
    squeeze: Squeeze(
        now: 800, remembered: 1500, added: 400, cc: 0.40, cr: 0.06),
    why:
        'All of it in recompression. The load lands at 1,200, still under the '
        '1,500 the clay has carried before, so the whole move is over ground '
        'the clay has already been squeezed across. It settles a little, on '
        'the stiff index, and that little is often small enough to ignore.',
    source: 'geo-co-q3',
  ),
  CaseRound(
    subject: 'the lesson\'s hard one',
    asked:
        'Carries 800, remembers 1,200, and 600 are added. Which case?',
    squeeze: Squeeze(
        now: 800, remembered: 1200, added: 600, cc: 0.40, cr: 0.06,
        thickness: 12, voidRatio: 1.10),
    why:
        'It crosses. The load ends at 1,400, past the 1,200 the clay '
        'remembers, so the move has to be split: the stiff index from 800 up '
        'to 1,200, then the soft one from 1,200 up to 1,400. Running the '
        'whole move on either index alone is the wrong answer, and the lesson '
        'offers both versions as choices.',
    source: 'geo-co-q3',
  ),
  CaseRound(
    subject: 'right on the memory',
    asked:
        'Carries 900, remembers 1,400, and exactly 500 are added, taking it '
        'to 1,400. Which case?',
    squeeze: Squeeze(
        now: 900, remembered: 1400, added: 500, cc: 0.35, cr: 0.05),
    why:
        'Still all recompression. The load stops exactly on the memory '
        'without passing it, so the virgin line is never reached and the '
        'stiff index does the whole job. One more pound and the answer would '
        'change to the crossing case, which is worth seeing once: the '
        'settlement is about to start growing much faster per pound.',
    source: 'geo-co-q3',
  ),
  CaseRound(
    subject: 'a deep clay under new fill',
    asked:
        'A clay that has never been loaded beyond what it carries now, at '
        '2,000, with 800 added by new fill. Which case?',
    squeeze: Squeeze(now: 2000, remembered: 2000, added: 800, cc: 0.25),
    why:
        'Normally consolidated again. A clay that has never carried more than '
        'it does now is on its virgin line already, so it has no stiff '
        'stretch left to spend and every pound goes on the soft index. Young '
        'deposits and recent fills behave this way, and they are the ones '
        'that settle for years.',
    source: 'geo-co-q1',
  ),
  CaseRound(
    subject: 'a heavily overconsolidated crust',
    asked:
        'A crust that carries 600 but remembers 4,000, with 500 added. Which '
        'case?',
    squeeze: Squeeze(
        now: 600, remembered: 4000, added: 500, cc: 0.35, cr: 0.05),
    why:
        'Recompression, and with plenty of room left: the load barely dents '
        'the memory. A clay like this has been dried out or had ground '
        'removed from over it in the past, and it behaves like a much '
        'stiffer soil until something loads it past what it once carried.',
    source: 'geo-co-q3',
  ),
];

class _WhichCaseIsItGameState extends State<WhichCaseIsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-case-is-it',
    chapterId: 'geotechnical',
    total: caseRounds.length,
    sourceProblemIdOf: (round) => caseRounds[round].source,
  )..addListener(_onSession);

  Case? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CaseRound get _round => caseRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Case Is It',
        closing:
            'Everything turns on the largest pressure the clay has ever '
            'carried. Land under it and the move is all recompression, on the '
            'stiff index, and the settlement is small. Start on it and every '
            'pound is virgin ground on the soft index. Cross it and the move '
            'has to be split in two, stiff up to the memory and soft beyond '
            'it. Running a crossing move on one index alone is the wrong '
            'answer the exam offers most often.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: caseBrief,
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
            'WHICH FORMULA DOES IT WANT',
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
            height: 168,
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
                  painter: StressLinePainter(
                    squeeze: r.squeeze,
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
              r'$\Delta H = \frac{H_0}{1+e_0}\,C\,\log\frac{p_1}{p_0}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Case.values) ...[
            _Choice(
              label: CaseRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Case.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE CASE' : 'NOT THAT ONE',
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
