import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Grounds, or Not — the second item for
/// `licensure-path-disciplinary-action`.
///
/// The lesson's medium problem is a felony with nothing to do with
/// engineering, and its rule is one clause long: ANY felony is grounds,
/// whether or not it touches the practice. Misdemeanours are the opposite
/// shape, and only count when they involve dishonesty or the practice itself.
/// A student who learns one of those and not the other gets half the questions
/// in this topic.
///
/// Four events at once, each answered on its own, because the distinction only
/// becomes visible next to its neighbours. A parking fine beside a felony is
/// obvious; a falsified timesheet beside a speeding ticket is the actual
/// lesson.
class GroundsOrNotGame extends StatefulWidget {
  const GroundsOrNotGame({super.key});

  @override
  State<GroundsOrNotGame> createState() => _GroundsOrNotGameState();
}

@immutable
class Event {
  const Event(this.text, this.grounds);

  final String text;

  /// Whether this alone is grounds for the board to act.
  final bool grounds;
}

@immutable
class GroundsRound {
  const GroundsRound({
    required this.subject,
    required this.who,
    required this.events,
    required this.why,
    required this.source,
  });

  final String subject;

  /// Whose conduct is being looked at, which decides which section applies.
  final String who;
  final List<Event> events;
  final String why;
  final String source;
}

const groundsRounds = <GroundsRound>[
  GroundsRound(
    subject: 'a licensee and a bad year',
    who: 'A licensed PE',
    events: [
      Event('Convicted of tax fraud, a felony', true),
      Event('Three unpaid parking fines', false),
      Event('A misdemeanour for falsifying a timesheet', true),
      Event('A speeding ticket on the way to site', false),
    ],
    why:
        'Any felony counts, related to engineering or not. A misdemeanour only '
        'counts when it involves dishonesty or the practice itself, which is '
        'why the timesheet is grounds and the speeding is not.',
    source: 'eth-lpd-q2',
  ),
  GroundsRound(
    subject: 'the work itself',
    who: 'A licensed PE',
    events: [
      Event('Negligence in a foundation design', true),
      Event('Taking on work outside their area of competence', true),
      Event('A disagreement with a client about a finish', false),
      Event('A felony conviction for assault', true),
    ],
    why:
        'Three of the four. Negligence, incompetence and any felony are each '
        'grounds on their own, and disagreeing with a client about a finish is '
        'a Tuesday.',
    source: 'eth-lpd-q2',
  ),
  GroundsRound(
    subject: 'somebody who never held a licence',
    who: 'A person who has never been licensed',
    events: [
      Event('Offering engineering design services for pay', true),
      Event('Working as a drafter under a licensed engineer', false),
      Event('Using the title Professional Engineer on a card', true),
      Event('Presenting another engineer\'s seal as their own', true),
    ],
    why:
        'The section aimed at unlicensed people covers practising, claiming '
        'the title, and using somebody else\'s seal. Drafting under an '
        'engineer\'s direction is the work the exemption exists to allow.',
    source: 'eth-lpd-q3',
  ),
  GroundsRound(
    subject: 'the licence itself',
    who: 'A licensed PE',
    events: [
      Event('Fraud in the application that obtained the licence', true),
      Event('Failing to comply with a rule the board has made', true),
      Event('A misdemeanour noise complaint about a party', false),
      Event('One complaint from a client, investigated and dismissed', false),
    ],
    why:
        'How the licence was obtained matters as much as what is done with it. '
        'A dismissed complaint is not a finding, and a noise complaint touches '
        'neither honesty nor practice.',
    source: 'eth-lpd-q2',
  ),
  GroundsRound(
    subject: 'the seal, and who is behind it',
    who: 'A licensed PE',
    events: [
      Event('Taking a job in a new field after training in it properly', false),
      Event('Sealing work prepared by somebody they did not supervise', true),
      Event('Reporting a colleague\'s material error to the board', false),
      Event('Letting an intern use their seal on a submittal', true),
    ],
    why:
        'A seal is not lent and it is not delegated. Moving into a new field '
        'after actually training in it is how careers work, and reporting a '
        'colleague is an obligation rather than an offence.',
    source: 'eth-lpd-q2',
  ),
  GroundsRound(
    subject: 'a firm with a word in its name',
    who: 'A person whose licence was revoked',
    events: [
      Event('Employing licensed engineers who seal all the work', false),
      Event('Naming the company Advanced Engineering Solutions', true),
      Event('Practising while the licence is revoked', true),
      Event('Keeping the company accounts and paying the staff', false),
    ],
    why:
        'A revoked licensee is an unlicensed person, and the word in the '
        'company name needs board authorisation they cannot get. Hiring '
        'licensed engineers and running the books are both perfectly ordinary; '
        'neither of them repairs the name.',
    source: 'eth-lpd-q3',
  ),
];

class _GroundsOrNotGameState extends State<GroundsOrNotGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'grounds-or-not',
    chapterId: 'ethics',
    total: groundsRounds.length,
    sourceProblemIdOf: (round) => groundsRounds[round].source,
  )..addListener(_onSession);

  /// One answer per event, or null where the student has not said yet.
  final _said = <int, bool>{};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GroundsRound get _round => groundsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Grounds, or Not',
        closing:
            'Any felony, whatever it was about. A misdemeanour only when it '
            'involves dishonesty or the practice. And for somebody who is not '
            'licensed at all, the grounds are practising, claiming the title, '
            'and using a seal that is not theirs.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final ready = _said.length == r.events.length;

    return BoardShell(
      session: _session,
      brief: disciplineBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_said.clear);
              _session.next();
            }
          : (!ready
                ? null
                : () => _session.submit(
                    ok: [
                      for (var i = 0; i < r.events.length; i++)
                        _said[i] == r.events[i].grounds,
                    ].every((x) => x),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GROUNDS FOR THE BOARD TO ACT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.who,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'answer each one on its own',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.events.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _EventRow(
              index: i,
              event: r.events[i],
              said: _said[i],
              locked: answered,
              onSay: answered
                  ? null
                  : (value) => setState(() => _said[i] = value),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'ALL FOUR' : 'NOT ALL FOUR',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// One event with its own pair of answers, because the round is four small
/// questions rather than one large one.
class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.index,
    required this.event,
    required this.said,
    required this.locked,
    required this.onSay,
  });

  final int index;
  final Event event;
  final bool? said;
  final bool locked;
  final void Function(bool value)? onSay;

  @override
  Widget build(BuildContext context) {
    final wrong = locked && said != event.grounds;
    final border = locked
        ? (wrong ? AppColors.error : AppColors.forest)
        : (said == null ? AppColors.line : AppColors.ember);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: locked
            ? (wrong ? AppColors.errorBg : AppColors.forestBg)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: border,
          width: border == AppColors.line ? 1 : 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              event.text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          for (final value in [true, false]) ...[
            if (!value) const SizedBox(width: 6),
            _Pip(
              key: ValueKey('event-$index-${value ? 'yes' : 'no'}'),
              label: value ? 'Yes' : 'No',
              // After the answer, the pip that is highlighted is the TRUE one,
              // so the row reads as a corrected answer sheet.
              on: locked ? event.grounds == value : said == value,
              locked: locked,
              onTap: onSay == null ? null : () => onSay!(value),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip({
    super.key,
    required this.label,
    required this.on,
    required this.locked,
    required this.onTap,
  });

  final String label;
  final bool on;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = locked ? AppColors.forest : AppColors.ember;
    return Material(
      color: on ? color : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: on ? color : AppColors.line),
          ),
          child: Text(
            label,
            style: AppTheme.mono(
              size: 12,
              color: on ? AppColors.white : AppColors.ink3,
            ),
          ),
        ),
      ),
    );
  }
}
