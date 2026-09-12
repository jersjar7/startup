import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pile_figures.dart';

/// Tip or Shaft — the first item for `deep-foundations`.
///
/// A pile holds a load up two ways at once, and each way has its own unit
/// resistance and its own area. The lesson's wrong answers are reporting
/// one of the two and calling it the capacity, and putting the shaft area
/// with the tip resistance.
class TipOrShaftGame extends StatefulWidget {
  const TipOrShaftGame({super.key});

  @override
  State<TipOrShaftGame> createState() => _TipOrShaftGameState();
}

@immutable
class PileRound {
  const PileRound({
    required this.subject,
    required this.asked,
    required this.pile,
    this.showResistances = true,
    required this.onRock,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Pile pile;

  /// The opening round asks what holds a pile up at all, so it draws a pile
  /// with nothing on it.
  final bool showResistances;
  final bool onRock;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own pile: 400 kN under the tip, 600 kN down the shaft, a
/// thousand altogether.
const _theLessonPile = Pile(
  tipResistance: 2000,
  tipArea: 0.20,
  skinFriction: 50,
  shaftArea: 12,
);

/// A short pile driven onto rock: almost all of it is the tip.
const _onRock = Pile(
  tipResistance: 9000,
  tipArea: 0.20,
  skinFriction: 15,
  shaftArea: 6,
);

/// A long pile in deep uniform clay, with nothing firm to reach.
const _inClay = Pile(
  tipResistance: 900,
  tipArea: 0.20,
  skinFriction: 45,
  shaftArea: 28,
);

const pileRounds = <PileRound>[
  PileRound(
    subject: 'the two ways a pile holds up a load',
    asked: 'A pile carries its load by which means?',
    pile: _theLessonPile,
    showResistances: false,
    onRock: false,
    options: [
      'Bearing under the tip only',
      'Friction along the shaft only',
      'Both at once: bearing under the tip and friction along the shaft',
      'The weight of the pile itself',
    ],
    answer: 2,
    why:
        'Both at once, and the capacity is their sum. The tip works like a '
        'very small footing and the shaft works like a long rough surface '
        'gripping the soil. Reporting only one of the two is the commonest '
        'wrong answer in this calculation, and the lesson offers both halves '
        'as choices.',
    source: 'geo-dfn-q1',
  ),
  PileRound(
    subject: 'which area goes with which resistance',
    asked:
        'The tip resistance is in kilopascals and so is the skin friction. '
        'What multiplies each of them?',
    pile: _theLessonPile,
    onRock: false,
    options: [
      'The tip resistance times the area of the TIP, and the skin friction '
          'times the surface area of the SHAFT',
      'Both times the tip area',
      'Both times the shaft area',
      'Both times the length of the pile',
    ],
    answer: 0,
    why:
        'Each pressure gets its own area. The tip area is small, a fraction '
        'of a square meter. The shaft area is the whole side of the pile and '
        'runs into tens of square meters. Swapping them is the other trap '
        'the lesson names, and it throws the answer out by a factor of '
        'fifty or more.',
    source: 'geo-dfn-q1',
  ),
  PileRound(
    subject: 'a pile driven onto rock',
    asked:
        'This pile is short and driven until it sits on rock. Where does most '
        'of its capacity come from?',
    pile: _onRock,
    onRock: true,
    options: [
      'The shaft, since friction acts over a bigger area',
      'The tip, which is resting on something very strong',
      'Neither: a pile on rock carries nothing',
      'They are always equal',
    ],
    answer: 1,
    why:
        'The tip. A small area against something enormously strong still '
        'beats a large area against a weak grip, and a pile driven to refusal '
        'on rock is called an end-bearing pile for that reason. Its shaft '
        'friction is real, and it is a small part of the total.',
    source: 'geo-dfn-q1',
  ),
  PileRound(
    subject: 'a long pile in uniform clay',
    asked:
        'This one is long, in deep clay, with nothing firm anywhere below it. '
        'Now where does the capacity come from?',
    pile: _inClay,
    onRock: false,
    options: [
      'The tip, as always',
      'Neither: it must be driven deeper',
      'The shaft, which is a large area of grip, with a small tip on soft '
          'ground below it',
      'The weight of the soil above the tip',
    ],
    answer: 2,
    why:
        'The shaft, which is why this is called a friction pile. The tip is '
        'sitting on the same soft clay everything else is in, so it brings '
        'very little, while the shaft has tens of square meters of contact. '
        'Making the pile longer buys more shaft, which is the whole design '
        'move.',
    source: 'geo-dfn-q1',
  ),
  PileRound(
    subject: 'a student who stopped early',
    asked:
        'On the lesson\'s pile, one student reports 400 kN and another 600 '
        'kN, and the right answer is 1,000. What happened?',
    pile: _theLessonPile,
    onRock: false,
    options: [
      'They used the wrong units',
      'Each reported one of the two parts and stopped there',
      'They both used the wrong areas',
      'One of them is right',
    ],
    answer: 1,
    why:
        'Each found one half and called it the answer: 400 is the tip alone '
        'and 600 the shaft alone. The two numbers being suspiciously round '
        'and adding to the fourth choice on the list is the tell. Work both '
        'and add them, every time.',
    source: 'geo-dfn-q1',
  ),
  PileRound(
    subject: 'what a bigger tip buys',
    asked:
        'This pile is redesigned with twice the tip area and the same length. '
        'What happens to the capacity?',
    pile: _theLessonPile,
    onRock: false,
    options: [
      'It doubles',
      'Nothing changes',
      'The tip part doubles, and that is under half the total here',
      'It quadruples',
    ],
    answer: 2,
    why:
        'Only the tip part moves, and here the tip is the smaller half, so '
        'the total goes up by well under a half. That is worth knowing before '
        'paying for a bigger section: in a friction pile, length buys '
        'capacity and width buys much less of it.',
    source: 'geo-dfn-q1',
  ),
];

class _TipOrShaftGameState extends State<TipOrShaftGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'tip-or-shaft',
    chapterId: 'geotechnical',
    total: pileRounds.length,
    sourceProblemIdOf: (round) => pileRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  PileRound get _round => pileRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Tip or Shaft',
        closing:
            'Bearing under the tip plus friction along the shaft, each with '
            'its own area: a small tip area and a large shaft area. On rock '
            'the tip does the work. In deep uniform clay the shaft does. '
            'Reporting either half on its own is the wrong answer the lesson '
            'prints, twice.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: pileCapacityBrief,
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
            'WHERE THE CAPACITY IS',
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
            height: 226,
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
                  painter: PilePainter(
                    pile: r.pile,
                    showResistances: r.showResistances || answered,
                    bearsOnRock: r.onRock,
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
