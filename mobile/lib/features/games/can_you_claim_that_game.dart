import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Can You Claim That — the third item for
/// `obligations-employers-clients-peers`.
///
/// The lesson's hard problem is about a line in a marketing brochure. A
/// partner managed a bridge, a subconsultant designed it, and the brochure
/// says the firm did the bridge. That is a rule about a SENTENCE, and the only
/// honest way to practice it is to put sentences in front of somebody and ask
/// which one they are allowed to write.
///
/// Every wrong line here is true in some narrow reading and misleading in the
/// way it will be read, which is exactly what the rule is aimed at: not lying
/// outright, but taking credit that belongs to somebody else.
class CanYouClaimThatGame extends StatefulWidget {
  const CanYouClaimThatGame({super.key});

  @override
  State<CanYouClaimThatGame> createState() => _CanYouClaimThatGameState();
}

@immutable
class ClaimRound {
  const ClaimRound({
    required this.subject,
    required this.facts,
    required this.claims,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What actually happened, stated flatly.
  final String facts;

  /// Three lines somebody wants to put in front of a client.
  final List<String> claims;

  /// The one you are allowed to write.
  final int answer;
  final String rule;
  final String why;
  final String source;
}

const claimRounds = <ClaimRound>[
  ClaimRound(
    subject: 'a bridge the firm managed',
    facts:
        'A senior partner was project manager on the Route 9 bridge. The '
        'design was performed by a subconsultant who is no longer with the '
        'firm.',
    claims: [
      'Our firm designed the Route 9 bridge.',
      'Our bridge design portfolio includes the Route 9 bridge.',
      'Our firm managed delivery of the Route 9 bridge. Design by others.',
    ],
    answer: 2,
    rule: 'C.1',
    why:
        'Managing a project is real work and it is worth saying. It is not '
        'designing the bridge, and a prospective client choosing you for '
        'bridge design is reading it as though it were.',
    source: 'eth-oec-q3',
  ),
  ClaimRound(
    subject: 'one system on a treatment plant',
    facts:
        'You were one of six engineers on a water treatment plant. You '
        'designed the chemical feed system and nothing else.',
    claims: [
      'I designed the chemical feed system at the Elm Street plant.',
      'I designed the Elm Street water treatment plant.',
      'I led the design team for the Elm Street water treatment plant.',
    ],
    answer: 0,
    rule: 'C.1',
    why:
        'Name what you did and it is impressive enough. Dropping the qualifier '
        'turns one system into a whole plant, and calling yourself the lead '
        'adds a role that belonged to somebody else.',
    source: 'eth-oec-q3',
  ),
  ClaimRound(
    subject: 'work that came with a new hire',
    facts:
        'Your firm recently hired an engineer who designed a well field at a '
        'previous employer. Your firm had no involvement in that project.',
    claims: [
      'Our firm has delivered well field projects of this scale.',
      'Our staff include the engineer who designed the Harbor well field, '
          'completed at a previous firm.',
      'Our well field experience includes the Harbor project.',
    ],
    answer: 1,
    rule: 'C.1',
    why:
        'The person\'s experience came with them and the firm\'s did not. '
        'Saying whose experience it is and where it was earned is both honest '
        'and, to anybody hiring, the more useful sentence.',
    source: 'eth-oec-q3',
  ),
  ClaimRound(
    subject: 'a review, not a design',
    facts:
        'You performed an independent peer review of a dam rehabilitation '
        'design prepared by another firm. You did not prepare any of it.',
    claims: [
      'We provided engineering services on the Rock Creek dam rehabilitation.',
      'We rehabilitated the Rock Creek dam.',
      'We performed the independent peer review of the Rock Creek dam '
          'rehabilitation.',
    ],
    answer: 2,
    rule: 'C.1',
    why:
        'The vague one is the dangerous one. "Provided engineering services" '
        'is technically true of a peer review and will be read as having done '
        'the design, and being read that way is the point of writing it.',
    source: 'eth-oec-q3',
  ),
  ClaimRound(
    subject: 'a project that never got built',
    facts:
        'You completed the full design of a transit center. Funding collapsed '
        'and it was never constructed.',
    claims: [
      'We designed the Midtown transit center, which was not constructed.',
      'We delivered the Midtown transit center, on schedule and on budget.',
      'Our completed projects include the Midtown transit center.',
    ],
    answer: 0,
    rule: 'C.1',
    why:
        'You did the work and you may say so. What you may not do is let it '
        'stand as a finished building, and the honest version costs you a '
        'clause and nothing else.',
    source: 'eth-oec-q3',
  ),
  ClaimRound(
    subject: 'a role that grew in the telling',
    facts:
        'You checked the reinforcement schedules on a parking structure. '
        'Another engineer designed the structure and sealed it.',
    claims: [
      'I was part of the design team on the Ninth Street parking structure.',
      'I checked the reinforcement schedules on the Ninth Street parking '
          'structure.',
      'I worked on the structural design of the Ninth Street parking '
          'structure, from concept through construction.',
    ],
    answer: 1,
    rule: 'C.1',
    why:
        'Both of the others are the kind of true that is meant to be '
        'misheard. Checking schedules is a real contribution and describing it '
        'plainly is the only version that survives somebody asking a follow-up '
        'question.',
    source: 'eth-oec-q3',
  ),
];

class _CanYouClaimThatGameState extends State<CanYouClaimThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'can-you-claim-that',
    chapterId: 'ethics',
    total: claimRounds.length,
    sourceProblemIdOf: (round) => claimRounds[round].source,
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

  ClaimRound get _round => claimRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Can You Claim That',
        closing:
            'Say what you did, and say who did the rest. The rule is not '
            'aimed at outright lies, it is aimed at sentences that are true if '
            'you read them slowly and flattering if you do not.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: claimsBrief,
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
            'WHICH LINE MAY YOU WRITE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHAT ACTUALLY HAPPENED',
                  style: AppTheme.overline(color: AppColors.ink3),
                ),
                const SizedBox(height: 8),
                Text(
                  r.facts,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.5,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.claims.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ClaimRow(
              key: ValueKey('claim-$i'),
              text: r.claims[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
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
              title: _session.correct! ? 'YOU MAY SAY THAT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _ClaimRow extends StatelessWidget {
  const _ClaimRow({
    super.key,
    required this.text,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String text;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
