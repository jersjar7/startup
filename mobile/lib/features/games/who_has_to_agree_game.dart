import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Who Has to Agree — the second item for
/// `obligations-employers-clients-peers`.
///
/// The lesson's medium problem is a conflict between two clients and its two
/// traps sit on either side of the answer: carrying on quietly because the
/// scopes look different, and refusing outright because a conflict sounds
/// fatal. The rules take a middle line and they are specific about it. Full
/// disclosure, and written agreement from ALL interested parties.
///
/// So the question is not what to do, it is WHO has to say yes, and the answer
/// is a set rather than a single name. Two rounds have nobody in it at all,
/// because a gratuity and a public-body conflict are not things consent can
/// repair.
class WhoHasToAgreeGame extends StatefulWidget {
  const WhoHasToAgreeGame({super.key});

  @override
  State<WhoHasToAgreeGame> createState() => _WhoHasToAgreeGameState();
}

@immutable
class ConsentRound {
  const ConsentRound({
    required this.subject,
    required this.arrangement,
    required this.parties,
    required this.answer,
    required this.rule,
    required this.why,
    required this.source,
  });

  final String subject;
  final String arrangement;

  /// Everyone on offer. The last is always the one that says no arrangement
  /// works, so that a round can have no consenting party at all.
  final List<String> parties;

  /// Indices into [parties] whose written agreement is required.
  final List<int> answer;
  final String rule;
  final String why;
  final String source;
}

/// The chip that ends every round's list.
const noConsent = 'No consent makes this acceptable';

const consentRounds = <ConsentRound>[
  ConsentRound(
    subject: 'stormwater work for two cities at once',
    arrangement:
        'You are designing City A\'s stormwater system. City B asks your firm '
        'to evaluate City A\'s system for deficiencies, as part of a '
        'regulatory dispute between them.',
    parties: ['City A', 'City B', 'The state regulator', noConsent],
    answer: [0, 1],
    rule: 'B.4, B.6 and B.7',
    why:
        'Both cities are interested parties and both have to agree in writing. '
        'The scopes being different does not help: what you already know about '
        'City A\'s system is the conflict, and knowing it is not something you '
        'can undo by keeping the files shut.',
    source: 'eth-oec-q2',
  ),
  ConsentRound(
    subject: 'design fee and inspection fee on one job',
    arrangement:
        'You designed the structure for the owner. The contractor now offers '
        'to pay you separately to carry out the special inspections on the '
        'same building.',
    parties: [
      'The owner',
      'The contractor',
      'The building authority',
      noConsent,
    ],
    answer: [0, 1],
    rule: 'B.7',
    why:
        'Payment from two parties on the same subject matter, so both of them '
        'have to know and both have to agree in writing. The building '
        'authority has plenty to say about inspections and it is not a party '
        'to your fee arrangements.',
    source: 'eth-oec-q2',
  ),
  ConsentRound(
    subject: 'a contractor with tickets to spare',
    arrangement:
        'A contractor bidding on your project offers you a pair of season '
        'tickets, and says plainly that it is just a thank you for the smooth '
        'paperwork last year.',
    parties: ['Your employer', 'The client', 'The contractor', noConsent],
    answer: [3],
    rule: 'B.5',
    why:
        'Some things are not conflicts to be managed. A gratuity from somebody '
        'bidding on your work is refused, and nobody has the standing to '
        'consent to it on your behalf, your employer included.',
    source: 'eth-oec-q2',
  ),
  ConsentRound(
    subject: 'your own firm bidding to a body you sit on',
    arrangement:
        'You serve on a city advisory board that awards engineering contracts. '
        'Your firm wants to bid on one of them.',
    parties: ['The board', 'The city', 'Your firm', noConsent],
    answer: [3],
    rule: 'B.8',
    why:
        'The rule runs both ways: you cannot decide on your firm\'s work, and '
        'your firm cannot take work from a body you sit on. Disclosure does '
        'not open that door, and neither does stepping out of the room.',
    source: 'eth-oec-q2',
  ),
  ConsentRound(
    subject: 'evening work for one of the firm\'s clients',
    arrangement:
        'A client of the firm you work for asks you to do a small private '
        'study for them in the evenings, paid directly to you.',
    parties: ['Your employer', 'The client', 'The licensing board', noConsent],
    answer: [0, 1],
    rule: 'B.6 and B.7',
    why:
        'Two people are paying you around the same relationship, so both have '
        'to know. The board licenses you and does not sign off your side '
        'work, and telling it instead of them helps nobody.',
    source: 'eth-oec-q2',
  ),
  ConsentRound(
    subject: 'soils data from the site next door',
    arrangement:
        'A new client asks whether you have any subsurface data for the street '
        'their site is on. You do, from a job you did for a different client '
        'two doors down.',
    parties: [
      'The client who paid for the borings',
      'Your employer',
      'The new client',
      noConsent,
    ],
    answer: [0],
    rule: 'B.4',
    why:
        'The information belongs to the client whose money found it, and only '
        'they can release it. Your employer has no say in that and the new '
        'client cannot consent to being given somebody else\'s property.',
    source: 'eth-oec-q2',
  ),
];

class _WhoHasToAgreeGameState extends State<WhoHasToAgreeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'who-has-to-agree',
    chapterId: 'ethics',
    total: consentRounds.length,
    sourceProblemIdOf: (round) => consentRounds[round].source,
  )..addListener(_onSession);

  final _picked = <int>{};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ConsentRound get _round => consentRounds[_session.round];

  void _toggle(int i, int last) {
    setState(() {
      // "No consent" cannot share a board with a consenting party, so tapping
      // it clears the rest and tapping a party clears it.
      if (i == last) {
        _picked
          ..clear()
          ..add(i);
        return;
      }
      _picked.remove(last);
      if (!_picked.add(i)) _picked.remove(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Who Has to Agree',
        closing:
            'Full disclosure and written agreement from everyone with an '
            'interest, which is usually more than one name. And some things '
            'consent cannot repair: a gratuity from a bidder, and work taken '
            'from a body you sit on.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final last = r.parties.length - 1;
    final truth = r.answer.toSet();

    return BoardShell(
      session: _session,
      brief: consentBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picked.clear);
              _session.next();
            }
          : (_picked.isEmpty
                ? null
                : () => _session.submit(
                    ok: _picked.length == truth.length &&
                        _picked.containsAll(truth),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHOSE WRITTEN AGREEMENT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.arrangement,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'tap everyone who has to agree, which may be nobody',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.parties.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _PartyRow(
              key: ValueKey('party-$i'),
              name: r.parties[i],
              selected: _picked.contains(i),
              locked: answered,
              isTruth: truth.contains(i),
              onTap: answered ? null : () => _toggle(i, last),
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
              title: _session.correct! ? 'THAT IS EVERYONE' : 'NOT THAT SET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    super.key,
    required this.name,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String name;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: selected || (locked && isTruth) ? border : null,
                  border: Border.all(
                    color: selected || (locked && isTruth)
                        ? border
                        : AppColors.line,
                  ),
                ),
                child: selected || (locked && isTruth)
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
