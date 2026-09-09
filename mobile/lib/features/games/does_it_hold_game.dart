import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Does the Exemption Hold — the second item for
/// `definitions-practice-of-engineering`.
///
/// The lesson's medium problem is a boundary question and it is answered by
/// the exemption clause rather than by the definition. An unlicensed employee
/// may do a great deal of real engineering work, on two conditions: somebody
/// licensed is in responsible charge of it, and the final design decisions are
/// not theirs. Both conditions, every time.
///
/// So the question is not whether the exemption applies but WHICH condition a
/// scenario breaks, because the two failures look nothing alike and are fixed
/// in completely different ways.
class DoesItHoldGame extends StatefulWidget {
  const DoesItHoldGame({super.key});

  @override
  State<DoesItHoldGame> createState() => _DoesItHoldGameState();
}

enum Exemption { holds, noCharge, finalCall }

@immutable
class ExemptionRound {
  const ExemptionRound({
    required this.subject,
    required this.scene,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scene;
  final Exemption answer;
  final String why;
  final String source;
}

const exemptionRounds = <ExemptionRound>[
  ExemptionRound(
    subject: 'shop drawings on a steel job',
    scene:
        'A construction manager with no licence compares the fabricator\'s '
        'shop drawings against the engineer of record\'s design drawings and '
        'sends a list of discrepancies to the engineer to resolve.',
    answer: Exemption.holds,
    why:
        'Both conditions are met. The engineer of record is in responsible '
        'charge and decides what to do about every discrepancy on the list, '
        'which leaves the comparison itself as ordinary work.',
    source: 'eth-dpe-q2',
  ),
  ExemptionRound(
    subject: 'a pipe size chosen while the engineer is away',
    scene:
        'A technician needs a storm pipe size to finish the sheet. The '
        'engineer is on leave for a fortnight, so the technician reads the '
        'size off the sizing table and puts it on the drawing.',
    answer: Exemption.finalCall,
    why:
        'Reading a table is easy and choosing what to build is not. Nobody '
        'licensed made this decision, and the fact that the answer probably '
        'came out right is beside the point.',
    source: 'eth-dpe-q2',
  ),
  ExemptionRound(
    subject: 'grading plans from an office with no engineer',
    scene:
        'A drafting firm with no licensed engineer on staff prepares grading '
        'and drainage plans and submits them to the county for permit under '
        'the firm\'s own name.',
    answer: Exemption.noCharge,
    why:
        'There is nobody for the exemption to hang from. It covers a '
        'subordinate working under somebody\'s responsible charge, and a firm '
        'with no licensed engineer has no such somebody.',
    source: 'eth-dpe-q2',
  ),
  ExemptionRound(
    subject: 'sheets produced from the engineer\'s markups',
    scene:
        'A drafter turns the engineer\'s red-marked layouts into finished '
        'sheets, asks about anything ambiguous, and hands them back for the '
        'engineer to check and seal.',
    answer: Exemption.holds,
    why:
        'This is what the clause was written for. The engineer directed the '
        'work, decided everything that had to be decided, and is the one whose '
        'seal goes on the result.',
    source: 'eth-dpe-q2',
  ),
  ExemptionRound(
    subject: 'rebar rearranged in the field',
    scene:
        'A contractor\'s field engineer finds the corner too congested to '
        'place the reinforcement as drawn, rearranges the bars so they fit, '
        'and tells the engineer of record at the next site meeting.',
    answer: Exemption.finalCall,
    why:
        'Telling somebody afterwards is not being under their charge. The bars '
        'were changed by whoever changed them, and reinforcement in a corner '
        'is a design decision however practical the reason for moving it was.',
    source: 'eth-dpe-q2',
  ),
  ExemptionRound(
    subject: 'a model run in another office',
    scene:
        'An Engineer Intern in a satellite office builds and runs the '
        'hydraulic model for a culvert crossing. Nobody in that office is '
        'licensed and nobody elsewhere is directing the work.',
    answer: Exemption.noCharge,
    why:
        'The intern\'s certificate is not a licence and it is not responsible '
        'charge either. Somebody licensed has to be directing the work, and '
        'being in a different building from anybody who is does not count.',
    source: 'eth-dpe-q2',
  ),
];

class _DoesItHoldGameState extends State<DoesItHoldGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-hold',
    chapterId: 'ethics',
    total: exemptionRounds.length,
    sourceProblemIdOf: (round) => exemptionRounds[round].source,
  )..addListener(_onSession);

  Exemption? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ExemptionRound get _round => exemptionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does the Exemption Hold',
        closing:
            'Two conditions, both required. Somebody licensed has to be in '
            'responsible charge, and the final design decisions have to be '
            'theirs. Break either one and the work needs a licence, however '
            'ordinary it looked.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: exemptionBrief,
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
            'UNLICENSED WORK, TWO CONDITIONS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scene,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 16),
          for (final e in Exemption.values) ...[
            if (e != Exemption.values.first) const SizedBox(height: 8),
            _ExemptionRow(
              key: ValueKey('exemption-${e.name}'),
              title: switch (e) {
                Exemption.holds => 'The exemption holds',
                Exemption.noCharge => 'Nobody licensed is in charge of it',
                Exemption.finalCall => 'They are making the final call',
              },
              note: switch (e) {
                Exemption.holds => 'both conditions are met',
                Exemption.noCharge => 'there is nothing to hang it from',
                Exemption.finalCall => 'the decision was theirs, not the PE\'s',
              },
              selected: _picked == e,
              locked: answered,
              isTruth: e == r.answer,
              onTap: answered ? null : () => setState(() => _picked = e),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'MODEL LAW 170.20 C',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'THE OTHER CONDITION',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExemptionRow extends StatelessWidget {
  const _ExemptionRow({
    super.key,
    required this.title,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String title;
  final String note;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
