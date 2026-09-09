import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Can You Seal It — the first item for
/// `obligations-employers-clients-peers`.
///
/// The lesson's easy problem is a competence question and both of its traps
/// are ways of borrowing competence you do not have: adjacent experience that
/// is nearly right, and a colleague's review standing in for your own
/// qualification. The rules do not lend it. A seal says the work is in your
/// field AND was prepared under your responsible charge, and the exam picks at
/// whichever half of that a scenario is missing.
///
/// The third answer is the one people forget exists. Coordinating a whole
/// project is allowed as long as each technical segment carries the seal of
/// whoever prepared it, so "seal my part" is a real answer and not a hedge.
class CanYouSealItGame extends StatefulWidget {
  const CanYouSealItGame({super.key});

  @override
  State<CanYouSealItGame> createState() => _CanYouSealItGameState();
}

enum Seal { yes, no, myPart }

@immutable
class SealRound {
  const SealRound({
    required this.subject,
    required this.situation,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;
  final String situation;
  final Seal answer;

  /// The rule it turns on, shown with the answer.
  final String rule;
  final String why;
  final String source;
}

const sealRounds = <SealRound>[
  SealRound(
    subject: 'a roundabout, offered as freelance work',
    situation:
        'You have years of highway alignment and signalized intersection work '
        'behind you and have never designed a roundabout. A freelance '
        'roundabout design is offered to you.',
    answer: Seal.no,
    rule: 'B.1',
    why:
        'Neighbouring experience is not the same technical field. Roundabouts '
        'carry their own geometry, deflection and capacity methods, and being '
        'good at the intersection next door does not qualify you for this one.',
    source: 'eth-oec-q1',
  ),
  SealRound(
    subject: 'calculations from another office',
    situation:
        'Structural calculations arrive from your firm\'s other office. You '
        'read them carefully and they look sound. Nobody who prepared them '
        'reports to you or works under your direction.',
    answer: Seal.no,
    rule: 'B.2',
    why:
        'Responsible charge means direct control and personal supervision, not '
        'a careful read. Reviewing work you did not direct is worth doing and '
        'it is not what a seal certifies.',
    source: 'eth-oec-q1',
  ),
  SealRound(
    subject: 'a multidiscipline set you are coordinating',
    situation:
        'You are the project engineer on a pump station. The structural sheets '
        'were prepared and sealed by the structural engineer, the electrical '
        'by the electrical engineer. The civil sheets are yours.',
    answer: Seal.myPart,
    rule: 'B.3',
    why:
        'Coordinating the whole set is allowed, and it does not put the other '
        'disciplines under your seal. Each technical segment is sealed by '
        'whoever prepared it, and yours is the civil.',
    source: 'eth-oec-q1',
  ),
  SealRound(
    subject: 'your own design, drafted by your technician',
    situation:
        'The grading design is yours, in your own field, drafted by a '
        'technician who sits in your team and works to your direction '
        'throughout.',
    answer: Seal.yes,
    rule: 'B.2',
    why:
        'Both halves are satisfied. It is your field and it was prepared under '
        'your responsible charge, which is what direct control and personal '
        'supervision mean. A drafter working to your direction does not put '
        'the work out of your reach.',
    source: 'eth-oec-q1',
  ),
  SealRound(
    subject: 'a favour for a colleague',
    situation:
        'A colleague\'s licence lapsed last month while renewal is processed. '
        'The drawings are theirs, in their field, and they ask you to seal '
        'them so the submittal is not held up.',
    answer: Seal.no,
    rule: 'B.2',
    why:
        'It is not your work and it was not prepared under your direction, and '
        'the reason for asking does not change either of those. A seal for '
        'somebody else\'s convenience is the clearest version of this rule '
        'there is.',
    source: 'eth-oec-q1',
  ),
  SealRound(
    subject: 'a geotechnical report with a structural check in it',
    situation:
        'You are the geotechnical engineer of record. The report contains a '
        'retaining wall stability check performed by a structural engineer in '
        'your firm, who has sealed that appendix.',
    answer: Seal.myPart,
    rule: 'B.3',
    why:
        'The same rule inside one document. The geotechnical work is yours to '
        'seal and the appendix belongs to whoever prepared it, and neither '
        'seal reaches across the binding.',
    source: 'eth-oec-q1',
  ),
];

class _CanYouSealItGameState extends State<CanYouSealItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'can-you-seal-it',
    chapterId: 'ethics',
    total: sealRounds.length,
    sourceProblemIdOf: (round) => sealRounds[round].source,
  )..addListener(_onSession);

  Seal? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SealRound get _round => sealRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Can You Seal It',
        closing:
            'Two halves, both required: it has to be your technical field, and '
            'it has to have been prepared under your responsible charge. '
            'Coordinating a whole project is fine, and it leaves every other '
            'discipline sealed by the person who did it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: competenceBrief,
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
            'DOES YOUR SEAL GO ON IT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.situation,
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
          for (final seal in Seal.values) ...[
            if (seal != Seal.values.first) const SizedBox(height: 8),
            _SealRow(
              key: ValueKey('seal-${seal.name}'),
              title: switch (seal) {
                Seal.yes => 'Yes, seal it',
                Seal.no => 'No, not yours to seal',
                Seal.myPart => 'Seal your part of it only',
              },
              note: switch (seal) {
                Seal.yes => 'your field, and prepared under your direction',
                Seal.no => 'either the field or the charge is missing',
                Seal.myPart => 'the rest carries the seal of whoever did it',
              },
              selected: _picked == seal,
              locked: answered,
              isTruth: seal == r.answer,
              onTap: answered ? null : () => setState(() => _picked = seal),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text('THE RULE', style: AppTheme.overline(color: AppColors.ink3)),
            const SizedBox(height: 4),
            Text(r.rule, style: AppTheme.code(size: 13)),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS RIGHT' : 'NOT QUITE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SealRow extends StatelessWidget {
  const _SealRow({
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
