import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'venn_figures.dart';

/// How Do They Sit — the fourth item for `probability-distributions`.
///
/// The lesson has four topics and the other three games take one each:
/// counting, the binomial, and the normal tail. Nothing touches the laws of
/// probability, which is the addition rule, the multiplication rule, and the
/// two conditions that decide which form of each you are allowed to use.
///
/// Those conditions are the whole exam question and none of them is
/// arithmetic. Can both happen at once, and does the first change the odds of
/// the second. Answer those and the rule falls out. Get them wrong and you
/// subtract an overlap that is not there, or multiply two probabilities that
/// were never independent.
///
/// The trap worth the price of the game: mutually exclusive and independent
/// sound like the same kind of statement and are opposites. Two events that
/// cannot both happen are as dependent as events get, because one happening
/// drops the other to zero.
class HowDoTheySitGame extends StatefulWidget {
  const HowDoTheySitGame({super.key});

  @override
  State<HowDoTheySitGame> createState() => _HowDoTheySitGameState();
}

@immutable
class LinkRound {
  const LinkRound({
    required this.subject,
    required this.first,
    required this.second,
    required this.pairing,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The two events, in the round's own words.
  final String first;
  final String second;

  final Pairing pairing;
  final String why;
  final String source;

  /// Worked out from the facts of the scenario, never declared beside it.
  Link get answer => pairing.link;
}

const linkRounds = <LinkRound>[
  LinkRound(
    subject: 'one roll of one die',
    first: 'it comes up 3',
    second: 'it comes up 5',
    pairing: Pairing(
      oneTrial: true,
      canCoexist: false,
      firstChangesSecond: true,
    ),
    why:
        'They cannot both happen. One die, one roll, one face upward, so there '
        'is no overlap and nothing to subtract: the chance of a 3 or a 5 is '
        'simply one sixth plus one sixth. Note what this is NOT. These two are '
        'about as far from independent as events get, because a 3 drops the '
        'chance of a 5 straight to zero.',
    source: 'stat-dist-q1',
  ),
  LinkRound(
    subject: 'two dice, thrown together',
    first: 'the first die shows 3',
    second: 'the second die shows 5',
    pairing: Pairing(
      oneTrial: false,
      canCoexist: true,
      firstChangesSecond: false,
    ),
    why:
        'One does not affect the other. Two separate dice, and neither of them '
        'knows what the other did, so the chance of both is one sixth times '
        'one sixth. Almost the same sentence as the round before, and a '
        'different world: there the two faces were competing for one die, here '
        'they have one each.',
    source: 'stat-dist-q1',
  ),
  LinkRound(
    subject: 'two cards, the first one kept',
    first: 'the first card is an ace',
    second: 'the second card is an ace',
    pairing: Pairing(
      oneTrial: false,
      canCoexist: true,
      firstChangesSecond: true,
    ),
    why:
        'The first changes the odds of the second. Take an ace out and there '
        'are three left in fifty one cards rather than four in fifty two, so '
        'the second probability has to be the conditional one. Drawing without '
        'replacement is the commonest way a problem quietly makes two events '
        'dependent.',
    source: 'stat-dist-q1',
  ),
  LinkRound(
    subject: 'two cards, the first one put back',
    first: 'the first card is an ace',
    second: 'the second card is an ace',
    pairing: Pairing(
      oneTrial: false,
      canCoexist: true,
      firstChangesSecond: false,
    ),
    why:
        'One does not affect the other now. The identical two sentences as the '
        'last round, and the only thing that changed is a card going back in '
        'the pack. With replacement the deck is the same both times, so the '
        'two probabilities multiply straight out. Read the problem for that '
        'detail before anything else.',
    source: 'stat-dist-q1',
  ),
  LinkRound(
    subject: 'one concrete cylinder, tested twice',
    first: 'it passes at seven days',
    second: 'it passes at twenty eight days',
    pairing: Pairing(
      oneTrial: false,
      canCoexist: true,
      firstChangesSecond: true,
    ),
    why:
        'The first changes the odds of the second. Both can certainly happen, '
        'so they are not exclusive, but they are not independent either: a '
        'batch strong at seven days is usually strong at twenty eight. '
        'Independence is a claim about the world, and out on a real site it is '
        'usually the wrong claim.',
    source: 'stat-dist-q2',
  ),
  LinkRound(
    subject: 'one soil sample, one classification',
    first: 'it is classified as sand',
    second: 'it is classified as clay',
    pairing: Pairing(
      oneTrial: true,
      canCoexist: false,
      firstChangesSecond: true,
    ),
    why:
        'They cannot both happen. One sample gets one classification, so the '
        'two are exclusive and their probabilities simply add. The test to '
        'apply is always the same and it takes a second: could both of these '
        'be true at once? If not, there is no overlap term at all.',
    source: 'stat-dist-q1',
  ),
];

class _HowDoTheySitGameState extends State<HowDoTheySitGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-do-they-sit',
    chapterId: 'statistics',
    total: linkRounds.length,
    sourceProblemIdOf: (round) => linkRounds[round].source,
  )..addListener(_onSession);

  Link? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LinkRound get _round => linkRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Do They Sit',
        closing:
            'Two questions, asked in this order. Could both happen at once? If '
            'not they are exclusive and their probabilities simply add. If so, '
            'does the first change the odds of the second? If not you may '
            'multiply them straight out, and if so you need the conditional. '
            'Exclusive and independent are not two words for one idea. They '
            'are opposites.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: lawsBrief,
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
            'HOW DO THESE TWO SIT TOGETHER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          _Event(letter: 'A', text: r.first, tone: AppColors.emberBg),
          const SizedBox(height: 8),
          _Event(letter: 'B', text: r.second, tone: AppColors.sunbeamBg),
          if (answered) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 175,
                width: double.infinity,
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: CustomPaint(
                    painter: VennPainter(
                      link: r.answer,
                      left: 'A',
                      right: 'B',
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final option in Link.values) ...[
            _LinkButton(
              key: ValueKey('link-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Link.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS HOW THEY SIT' : 'NOT QUITE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Event extends StatelessWidget {
  const _Event({required this.letter, required this.text, required this.tone});

  final String letter;
  final String text;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(letter, style: AppTheme.mono(size: 13, color: AppColors.ink3)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Link option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Link.exclusive: 'They cannot both happen',
    Link.independent: 'One does not affect the other',
    Link.dependent: 'One changes the odds of the other',
  };

  static const _notes = {
    Link.exclusive: 'mutually exclusive, so nothing to subtract',
    Link.independent: 'independent, so the two just multiply',
    Link.dependent: 'dependent, so the second one is conditional',
  };

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
          height: 58,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _titles[option]!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _notes[option]!,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
