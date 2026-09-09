import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Who May Do That — the first item for
/// `definitions-practice-of-engineering`.
///
/// The lesson's easy problem turns on two words that sound alike and are not:
/// an Engineer Intern is CERTIFIED and a Professional Engineer is LICENSED.
/// Passing the FE is a milestone rather than an authority, and the exam tests
/// that by handing an intern a seal and seeing what they do with it.
///
/// So the answer is a rank rather than a yes or a no: the lowest standing that
/// is enough for the action on screen. Half of these need nobody licensed at
/// all, which is the other half of the lesson, and the intern tier turns out
/// to be surprisingly narrow.
class WhoMayDoThatGame extends StatefulWidget {
  const WhoMayDoThatGame({super.key});

  @override
  State<WhoMayDoThatGame> createState() => _WhoMayDoThatGameState();
}

enum Standing { anyone, intern, licensed }

@immutable
class StandingRound {
  const StandingRound({
    required this.subject,
    required this.action,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The thing somebody wants to do.
  final String action;

  /// The lowest standing that is enough for it.
  final Standing answer;
  final String rule;
  final String why;
  final String source;
}

const standingRounds = <StandingRound>[
  StandingRound(
    subject: 'drainage plans for a subdivision',
    action:
        'Sign and seal a set of drainage plans for a residential subdivision.',
    answer: Standing.licensed,
    rule: 'Model Law 110.20 A',
    why:
        'A seal is an act of licensure and nothing else grants it. Passing the '
        'FE is a milestone on the way, and a licensed engineer reading the '
        'plans afterwards does not lend their authority to somebody else\'s '
        'signature.',
    source: 'eth-dpe-q1',
  ),
  StandingRound(
    subject: 'calculations somebody else will seal',
    action:
        'Prepare the drainage calculations, working to the direction of the '
        'licensed engineer who will seal them.',
    answer: Standing.anyone,
    rule: 'Model Law 170.20 C',
    why:
        'The exemption exists for exactly this. A subordinate working under a '
        'licensed engineer\'s responsible charge needs no licence of their '
        'own, provided the final design decisions are not theirs.',
    source: 'eth-dpe-q2',
  ),
  StandingRound(
    subject: 'what goes on the business card',
    action: 'Put "Engineer Intern" after your name on a business card.',
    answer: Standing.intern,
    rule: 'Model Law 110.20 A.2',
    why:
        'The title is certified by the board and belongs to whoever has earned '
        'it. It is also close to the whole of what the certificate gets you, '
        'which is the honest shape of this tier.',
    source: 'eth-dpe-q1',
  ),
  StandingRound(
    subject: 'how the company website describes you',
    action:
        'Be described as a Professional Engineer on your company\'s website.',
    answer: Standing.licensed,
    rule: 'Model Law 110.20 A.3(b)',
    why:
        'You do not have to do any engineering to break this one. Being '
        'represented as a Professional Engineer when you are not is the '
        'violation on its own, by sign, card, letterhead or website.',
    source: 'eth-dpe-q1',
  ),
  StandingRound(
    subject: 'shop drawings against the design set',
    action:
        'Compare a fabricator\'s shop drawings to the design drawings and flag '
        'the differences for the engineer of record.',
    answer: Standing.anyone,
    rule: 'Model Law 170.20 C',
    why:
        'Lining two documents up and saying where they disagree is a '
        'comparison, not a design decision. The engineer of record decides '
        'what to do about each difference, and that is where the judgment '
        'lives.',
    source: 'eth-dpe-q2',
  ),
  StandingRound(
    subject: 'the next exam',
    action: 'Sit the Professional Engineer examination.',
    answer: Standing.intern,
    rule: 'Model Law 130.10',
    why:
        'The FE comes first and the certificate that follows it is what puts '
        'you in the queue for the second exam. The order is fixed and the '
        'experience requirement sits between them.',
    source: 'eth-dpe-q1',
  ),
];

class _WhoMayDoThatGameState extends State<WhoMayDoThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'who-may-do-that',
    chapterId: 'ethics',
    total: standingRounds.length,
    sourceProblemIdOf: (round) => standingRounds[round].source,
  )..addListener(_onSession);

  Standing? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StandingRound get _round => standingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Who May Do That',
        closing:
            'Certified and licensed are different words. An Engineer Intern '
            'has passed the FE and may hold the title; a Professional Engineer '
            'is licensed and may seal. And a great deal of real engineering '
            'work needs no licence at all, as long as somebody licensed is in '
            'responsible charge of it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: standingBrief,
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
            'THE LOWEST STANDING THAT IS ENOUGH',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              r.action,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 16),
          for (final standing in Standing.values) ...[
            if (standing != Standing.values.first) const SizedBox(height: 8),
            _StandingRow(
              key: ValueKey('standing-${standing.name}'),
              rung: standing.index,
              title: switch (standing) {
                Standing.anyone => 'Anyone',
                Standing.intern => 'An Engineer Intern',
                Standing.licensed => 'Only a licensed PE',
              },
              note: switch (standing) {
                Standing.anyone => 'no licence needed for this',
                Standing.intern => 'certified by the board, not licensed',
                Standing.licensed => 'licensed by the board',
              },
              selected: _picked == standing,
              locked: answered,
              isTruth: standing == r.answer,
              onTap: answered
                  ? null
                  : () => setState(() => _picked = standing),
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
              title: _session.correct! ? 'THAT IS THE TIER' : 'A DIFFERENT TIER',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    super.key,
    required this.rung,
    required this.title,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  /// How high up the ladder this one sits, from zero.
  final int rung;
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
          child: Row(
            children: [
              // The three tiers are a ladder, so they are drawn as one. The
              // question is the LOWEST rung that is enough, and three
              // identical rows do not say that.
              SizedBox(
                width: 26,
                height: 34,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: 6,
                    height: 10.0 + rung * 12,
                    decoration: BoxDecoration(
                      color: border == AppColors.line
                          ? AppColors.ink3.withValues(alpha: 0.55)
                          : border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }
}
