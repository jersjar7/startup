import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Is There a Deal Yet — the first item for `engineering-contracts`.
///
/// The lesson's easy problem is a list of elements with a formality hidden in
/// it, and a list is a poor way to learn something that happens in a
/// conversation. Offer, acceptance and consideration are MOMENTS. They arrive
/// in an order, one line kills the one before it, and the exact turn where an
/// exchange becomes binding is the thing worth being able to see.
///
/// So the exchange is on screen as it happened and the answer is the line
/// where it became a contract, or the honest finding that it never did.
class IsThereADealGame extends StatefulWidget {
  const IsThereADealGame({super.key});

  @override
  State<IsThereADealGame> createState() => _IsThereADealGameState();
}

@immutable
class Line {
  const Line(this.who, this.text);

  final String who;
  final String text;
}

@immutable
class DealRound {
  const DealRound({
    required this.subject,
    required this.lines,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;
  final List<Line> lines;

  /// The line it became binding on, or [noDeal] when it never did.
  final int answer;
  final String rule;
  final String why;
  final String source;
}

/// Tapped instead of a line, when nothing enforceable ever formed.
const noDeal = -1;

const dealRounds = <DealRound>[
  DealRound(
    subject: 'a culvert study',
    lines: [
      Line('Owner', 'Would you be able to take a look at our culvert?'),
      Line('Engineer', 'I can. I would do the study for eight thousand.'),
      Line('Owner', 'Do it. I will send the deposit today.'),
      Line('Engineer', 'Good. I will start Monday.'),
    ],
    answer: 2,
    rule: 'offer, acceptance, consideration',
    why:
        'The first line is an inquiry and nothing is on the table yet. The '
        'second puts a price on it, which is the offer, and the third takes it '
        'and promises money, which is the acceptance and the consideration '
        'arriving together.',
    source: 'eth-con-q1',
  ),
  DealRound(
    subject: 'a price that moved',
    lines: [
      Line('Owner', 'We will pay eight thousand for the drainage report.'),
      Line('Engineer', 'Not at that scope. Ten thousand and I will do it.'),
      Line('Owner', 'Ten it is.'),
      Line('Engineer', 'I will send the agreement over.'),
    ],
    answer: 2,
    rule: 'a counter-offer replaces the offer',
    why:
        'The second line looks like a haggle and is legally a rejection. The '
        'original eight thousand is gone and cannot be accepted afterwards, '
        'and what is on the table from then on is the engineer\'s ten.',
    source: 'eth-con-q1',
  ),
  DealRound(
    subject: 'a favor between neighbors',
    lines: [
      Line('Neighbor', 'Could you look over my deck drawings sometime?'),
      Line('Engineer', 'Of course. I will do it this weekend, no charge.'),
      Line('Neighbor', 'That is very kind, thank you.'),
      Line('Engineer', 'No trouble at all.'),
    ],
    answer: noDeal,
    rule: 'no consideration',
    why:
        'A promise to do something for nothing is a gift rather than a '
        'contract, however sincerely it is meant. Nothing of value moves the '
        'other way, so there is nothing a court would enforce.',
    source: 'eth-con-q1',
  ),
  DealRound(
    subject: 'a public procurement',
    lines: [
      Line('City', 'Request for proposals: design services, bids by the 4th.'),
      Line('Firm', 'Our proposal, at four hundred thousand, is attached.'),
      Line('City', 'Council has awarded the work to you at your price.'),
      Line('Firm', 'Thank you. Mobilising next week.'),
    ],
    answer: 2,
    rule: 'an invitation is not an offer',
    why:
        'A request for proposals invites offers and is not one. The firm\'s '
        'proposal is the offer, and the award is the acceptance, which is why '
        'losing bidders have nothing to enforce.',
    source: 'eth-con-q1',
  ),
  DealRound(
    subject: 'a yes with a condition on it',
    lines: [
      Line('Owner', 'Sixty thousand for the survey and the base mapping.'),
      Line('Engineer', 'Yes, provided we can start in June.'),
      Line('Owner', 'June works.'),
      Line('Engineer', 'Then we are on.'),
    ],
    answer: 2,
    rule: 'a conditional yes is a counter-offer',
    why:
        'Acceptance has to match the offer as it stands. Adding a condition '
        'sends it back across the table, and the deal forms when the other '
        'side takes the condition rather than when the word yes was said.',
    source: 'eth-con-q1',
  ),
  DealRound(
    subject: 'a seal for hire',
    lines: [
      Line('Builder', 'Seal these without reviewing them and I will pay two '
          'thousand.'),
      Line('Engineer', 'Send them over.'),
      Line('Builder', 'On the way, with the money.'),
      Line('Engineer', 'Received.'),
    ],
    answer: noDeal,
    rule: 'no lawful purpose',
    why:
        'Every other element is present and it is still not a contract. A '
        'court will not enforce an agreement whose purpose is unlawful, so '
        'neither of these two has anything to sue the other over.',
    source: 'eth-con-q1',
  ),
];

class _IsThereADealGameState extends State<IsThereADealGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'is-there-a-deal',
    chapterId: 'ethics',
    total: dealRounds.length,
    sourceProblemIdOf: (round) => dealRounds[round].source,
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

  DealRound get _round => dealRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Is There a Deal Yet',
        closing:
            'An offer, taken as it stands, with something of value moving both '
            'ways. A counter-offer kills the offer before it. An invitation is '
            'not an offer. And no amount of agreement makes a contract out of '
            'a favor or out of something unlawful.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: formationBrief,
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
            'TAP THE LINE IT BECAME BINDING ON',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _LineRow(
              key: ValueKey('line-$i'),
              line: r.lines[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          const SizedBox(height: 12),
          _NoDealRow(
            selected: _picked == noDeal,
            locked: answered,
            isTruth: r.answer == noDeal,
            onTap: answered ? null : () => setState(() => _picked = noDeal),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'WHAT DECIDED IT',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(r.rule, style: AppTheme.code(size: 13)),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE MOMENT' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// One turn of the exchange, laid out as it was said.
class _LineRow extends StatelessWidget {
  const _LineRow({
    super.key,
    required this.line,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Line line;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                line.who.toUpperCase(),
                style: AppTheme.overline(color: AppColors.ink3),
              ),
              const SizedBox(height: 3),
              Text(
                line.text,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoDealRow extends StatelessWidget {
  const _NoDealRow({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

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
      key: const ValueKey('line-none'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: const Text(
            'It never became a contract at all.',
            style: TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
