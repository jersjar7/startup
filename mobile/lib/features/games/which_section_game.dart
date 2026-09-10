import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Section — the third item for `licensure-path-disciplinary-action`.
///
/// The lesson's own tip says to ask one question first: is this person
/// licensed. Everything else follows from the answer, because the grounds for
/// disciplining a licensee and the grounds for fining somebody who is not
/// licensed are two different lists in two different sections.
///
/// The hard problem turns on that fork and on one word inside it. A licence
/// that has been REVOKED is not a licence, so a revoked engineer is an
/// unlicensed person and lands in the second list, which is not where anybody
/// expects to find somebody who used to be a PE.
class WhichSectionGame extends StatefulWidget {
  const WhichSectionGame({super.key});

  @override
  State<WhichSectionGame> createState() => _WhichSectionGameState();
}

enum Section { licensee, unlicensed, neither }

@immutable
class SectionRound {
  const SectionRound({
    required this.subject,
    required this.scene,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scene;
  final Section answer;
  final String why;
  final String source;
}

const sectionRounds = <SectionRound>[
  SectionRound(
    subject: 'a felony with nothing to do with the work',
    scene:
        'A currently licensed engineer with an unblemished professional record '
        'is convicted of tax fraud.',
    answer: Section.licensee,
    why:
        'They hold a licence, so the board reaches them through the list that '
        'applies to licensees. Any felony is on that list, and the clean '
        'record affects what the board does rather than whether it may act.',
    source: 'eth-lpd-q2',
  ),
  SectionRound(
    subject: 'somebody who never applied',
    scene:
        'A person with an engineering degree and no licence advertises '
        'structural design services and takes on paid work.',
    answer: Section.unlicensed,
    why:
        'No licence has ever existed, so there is nothing for the board to '
        'suspend or revoke. The other list is what covers them, and it works '
        'by fine, with each day of continued violation counted separately.',
    source: 'eth-lpd-q3',
  ),
  SectionRound(
    subject: 'unpleasant, and competent',
    scene:
        'A licensed engineer is short and dismissive with a client through a '
        'difficult project. The work itself is competent, on time and code '
        'compliant.',
    answer: Section.neither,
    why:
        'Being hard to deal with is not one of the grounds. The board is not '
        'a manners tribunal, and stretching the disciplinary sections to cover '
        'rudeness spends their weight on something they were not built for.',
    source: 'eth-lpd-q2',
  ),
  SectionRound(
    subject: 'the word on the door, three years later',
    scene:
        'Someone whose licence was revoked three years ago runs a company '
        'called Advanced Engineering Solutions. Licensed engineers on the '
        'staff seal all of the work.',
    answer: Section.unlicensed,
    why:
        'Revoked means unlicensed, and this is where the question is usually '
        'lost. The word in the company name needs an authorisation they cannot '
        'hold, and the licensed staff sealing the drawings does not change '
        'whose name is on the door.',
    source: 'eth-lpd-q3',
  ),
  SectionRound(
    subject: 'a field they have not worked in',
    scene:
        'A licensed engineer whose whole career has been in transportation '
        'accepts and completes a structural assessment of an existing '
        'building, without training in it.',
    answer: Section.licensee,
    why:
        'Practising outside your area of competence is on the licensee list, '
        'and holding a licence is exactly what makes it reachable. A licence '
        'is not a general permission and the board treats it as one document '
        'with limits.',
    source: 'eth-lpd-q2',
  ),
  SectionRound(
    subject: 'a renewal that never happened',
    scene:
        'An engineer forgets to renew and the licence expires. Eight months '
        'later they are still sealing drawings with the old seal.',
    answer: Section.unlicensed,
    why:
        'An expired licence is not a licence, so this is the unlicensed list '
        'rather than the licensee one. Using an expired, suspended or revoked '
        'licence is named in it, and eight months is eight months of separate '
        'offenses.',
    source: 'eth-lpd-q3',
  ),
];

class _WhichSectionGameState extends State<WhichSectionGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-section',
    chapterId: 'ethics',
    total: sectionRounds.length,
    sourceProblemIdOf: (round) => sectionRounds[round].source,
  )..addListener(_onSession);

  Section? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SectionRound get _round => sectionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Section',
        closing:
            'Ask whether they hold a licence before anything else. Revoked, '
            'suspended and expired all mean the same thing for this question, '
            'which is that they do not, and that puts them on the other list '
            'entirely.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: sectionsBrief,
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
            'WHICH LIST REACHES THEM',
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
          for (final s in Section.values) ...[
            if (s != Section.values.first) const SizedBox(height: 8),
            _SectionRow(
              key: ValueKey('section-${s.name}'),
              title: switch (s) {
                Section.licensee => 'The licensee list',
                Section.unlicensed => 'The unlicensed list',
                Section.neither => 'Neither. Not a ground at all.',
              },
              note: switch (s) {
                Section.licensee => 'suspend, revoke, fine or reprimand',
                Section.unlicensed => 'fined, and each day counts again',
                Section.neither => 'the board has nothing to reach',
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
              title: _session.correct! ? 'THAT IS THE LIST' : 'THE OTHER LIST',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
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
