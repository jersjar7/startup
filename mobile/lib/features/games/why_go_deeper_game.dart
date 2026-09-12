import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pile_figures.dart';

/// Why Go Deeper — the second item for `deep-foundations`.
///
/// Why a deep foundation is chosen, which is about performance and never
/// about price, and what changes once the piles come in a group. The
/// lesson prints no group problem of its own, so the group rounds are
/// authored from its text and cite the problem that sets the scene.
class WhyGoDeeperGame extends StatefulWidget {
  const WhyGoDeeperGame({super.key});

  @override
  State<WhyGoDeeperGame> createState() => _WhyGoDeeperGameState();
}

@immutable
class DeepRound {
  const DeepRound({
    required this.subject,
    required this.asked,
    required this.piles,
    required this.onFooting,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;

  /// How many piles the drawing shows.
  final int piles;

  /// Or a shallow footing instead.
  final bool onFooting;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const deepRounds = <DeepRound>[
  DeepRound(
    subject: 'eight meters of soft clay',
    asked:
        'A heavily loaded column sits on eight meters of soft clay over dense '
        'gravel. Why use piles rather than a footing?',
    piles: 1,
    onFooting: false,
    options: [
      'Because piles are always cheaper than footings',
      'To carry the load through the weak clay down to the gravel, so the '
          'settlement stays small',
      'To put more pressure on the clay',
      'Because a footing can never be used under a column',
    ],
    answer: 1,
    why:
        'To get past the clay. A footing would put its whole load into the '
        'soft layer, which would settle far more than the building could '
        'take. The piles hand the load to the gravel instead. Note what the '
        'reason is NOT: it is not price, and piles usually cost more.',
    source: 'geo-dfn-q2',
  ),
  DeepRound(
    subject: 'the answer that is backwards',
    asked:
        'One of the choices said the point was to increase the bearing '
        'pressure on the soft clay. What is wrong with it?',
    piles: 1,
    onFooting: true,
    options: [
      'Nothing: more pressure means more capacity',
      'The clay is the layer you are trying to take load OFF, not put more '
          'onto',
      'Pressure cannot be increased by a foundation',
      'It is right, but only for sands',
    ],
    answer: 1,
    why:
        'It has the aim backwards. The whole point of going deep is to '
        'relieve the weak layer of the load, not to press it harder. Watch '
        'for choices that state the opposite of the goal: they read '
        'plausibly because every word in them is a real term.',
    source: 'geo-dfn-q2',
  ),
  DeepRound(
    subject: 'settlement, not just strength',
    asked:
        'Suppose the soft clay could just carry the load without failing. '
        'Would a footing then be acceptable?',
    piles: 1,
    onFooting: true,
    options: [
      'Yes: if it does not fail, it is adequate',
      'Not necessarily: a soft clay can be strong enough and still settle far '
          'more than the structure can take',
      'Yes, as long as the load is central',
      'No: footings are never allowed on clay',
    ],
    answer: 1,
    why:
        'Not necessarily. Bearing capacity and settlement are two separate '
        'questions, and on soft compressible clay the settlement one usually '
        'governs. A foundation that will not collapse but drops four inches '
        'has still failed the building.',
    source: 'geo-dfn-q2',
  ),
  DeepRound(
    subject: 'what a group does',
    asked:
        'Nine piles are driven close together and capped as a group. Is the '
        'group as strong as nine single piles?',
    piles: 3,
    onFooting: false,
    options: [
      'Yes, always: capacity simply adds',
      'It is stronger: the cap helps',
      'Not necessarily: in clay a group can carry less than the sum of its '
          'piles',
      'It carries exactly a third',
    ],
    answer: 2,
    why:
        'Not necessarily, and in clays it usually carries less. The piles are '
        'close enough that each one is working the same soil as its '
        'neighbors, so they get in each other\'s way. The ratio of the group '
        'capacity to the sum of the singles is called the group efficiency, '
        'and in clay it is below one.',
    source: 'geo-dfn-q2',
  ),
  DeepRound(
    subject: 'how deep the group is felt',
    asked:
        'How far down does the ground feel a pile GROUP, compared with one '
        'pile carrying the same share?',
    piles: 3,
    onFooting: false,
    options: [
      'Deeper: the separate zones merge into one much larger one',
      'The same depth: the piles are the same length',
      'Less deep, because the load is shared',
      'It cannot be compared',
    ],
    answer: 0,
    why:
        'Deeper. A single pile stresses a modest bulb of soil around its tip. '
        'A group of them makes one big bulb the size of the whole cap, and a '
        'wide load reaches much further down. That is why a group can find a '
        'compressible layer well below the tips that no single pile would '
        'have noticed.',
    source: 'geo-dfn-q2',
  ),
  DeepRound(
    subject: 'and so the group settles',
    asked:
        'Given that, how does the settlement of the group compare with the '
        'settlement of a single pile under the same load per pile?',
    piles: 3,
    onFooting: false,
    options: [
      'Less, because there are more piles',
      'The same',
      'More, because the deeper soil is being squeezed as well',
      'None at all: piles do not settle',
    ],
    answer: 2,
    why:
        'More. The load reaches soil the single pile never touched, and '
        'whatever is compressible down there gets squeezed too. A pile group '
        'is checked for settlement as a block, not pile by pile, for exactly '
        'this reason.',
    source: 'geo-dfn-q2',
  ),
];

class _WhyGoDeeperGameState extends State<WhyGoDeeperGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'why-go-deeper',
    chapterId: 'geotechnical',
    total: deepRounds.length,
    sourceProblemIdOf: (round) => deepRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  DeepRound get _round => deepRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Why Go Deeper',
        closing:
            'Piles are chosen to get the load past a layer that would settle, '
            'not because they are cheap, and never to press the weak layer '
            'harder. Once they come in a group the arithmetic changes again: '
            'in clay the group can carry less than the sum of its piles, and '
            'it stresses the ground deeper and settles more.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: goingDeepBrief,
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
            'WHY NOT A FOOTING',
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
            height: 214,
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
                  painter: DepthPainter(
                    piles: r.piles,
                    onFooting: r.onFooting,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
