import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pile_figures.dart';

/// Which Way the Friction Acts — the third item for `deep-foundations`.
///
/// Shaft friction is usually a resistance, and sometimes it is a load. What
/// decides is which of the two, the soil or the pile, is moving down faster
/// than the other. The lesson's warning is that downdrag ADDS to the load
/// and must not be counted as capacity.
class WhichWayTheFrictionActsGame extends StatefulWidget {
  const WhichWayTheFrictionActsGame({super.key});

  @override
  State<WhichWayTheFrictionActsGame> createState() =>
      _WhichWayTheFrictionActsGameState();
}

@immutable
class DowndragRound {
  const DowndragRound({
    required this.subject,
    required this.asked,
    required this.pile,
    required this.dragging,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Pile pile;

  /// Whether the ground around this pile is settling past it.
  final bool dragging;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _pile = Pile(
  tipResistance: 2000,
  tipArea: 0.20,
  skinFriction: 50,
  shaftArea: 12,
);

const downdragRounds = <DowndragRound>[
  DowndragRound(
    subject: 'fill placed over soft clay',
    asked:
        'New fill is placed over a soft clay that a pile passes through. The '
        'clay consolidates and settles past the pile. What acts on the shaft?',
    pile: _pile,
    dragging: true,
    options: [
      'Friction that adds to the pile capacity',
      'Negative skin friction, a downward drag that ADDS to the load',
      'An upward buoyant force',
      'Nothing, because the two move together',
    ],
    answer: 1,
    why:
        'Downdrag. The soil is going down faster than the pile, so it hangs '
        'on the shaft on its way past and pulls the pile down with it. That '
        'is a load the pile has to carry on top of the building, and the '
        'lesson is blunt about it: it does not help.',
    source: 'geo-dfn-q3',
  ),
  DowndragRound(
    subject: 'what decides the direction',
    asked: 'What decides which way the shaft friction acts?',
    pile: _pile,
    dragging: true,
    options: [
      'Whether the soil is clay or sand',
      'Whether the pile is driven or drilled',
      'Which of the two, the soil or the pile, is moving down relative to the '
          'other',
      'Whether the pile is in compression',
    ],
    answer: 2,
    why:
        'Relative movement, and nothing else. A pile pushed down through '
        'still soil rubs upward against it and is held. Soil settling past a '
        'still pile rubs downward on it and loads it. Same surface, same '
        'grip, opposite sign, decided by which one is going down faster.',
    source: 'geo-dfn-q3',
  ),
  DowndragRound(
    subject: 'a pile under its working load',
    asked:
        'This pile is simply carrying a building, in ground that is not '
        'settling. Which way does the shaft friction act now?',
    pile: _pile,
    dragging: false,
    options: [
      'Upward, helping to hold the pile up',
      'Downward, as always',
      'It acts sideways',
      'There is no friction unless the soil moves',
    ],
    answer: 0,
    why:
        'Upward, which is the normal case: the pile is trying to go down and '
        'the soil resists it. This is the skin friction that counts toward '
        'capacity. Downdrag is the exception, and it needs settling ground '
        'to happen.',
    source: 'geo-dfn-q3',
  ),
  DowndragRound(
    subject: 'the arithmetic of it',
    asked:
        'A pile has downdrag on the upper part of its shaft. How does that '
        'enter the design?',
    pile: _pile,
    dragging: true,
    options: [
      'As extra capacity on the resistance side',
      'It is ignored: it cancels out',
      'As an extra load on the demand side, and that part of the shaft gives '
          'no resistance either',
      'As a reduction in the end bearing only',
    ],
    answer: 2,
    why:
        'It goes on the load side, and it costs twice: the drag adds to what '
        'the pile must carry, AND the stretch of shaft doing the dragging is '
        'not holding the pile up. A pile through settling fill can end up '
        'needing far more capacity than the building alone would suggest.',
    source: 'geo-dfn-q3',
  ),
  DowndragRound(
    subject: 'where it comes from',
    asked: 'Which site is most likely to give a pile downdrag?',
    pile: _pile,
    dragging: true,
    options: [
      'Dense sand with the water table well below',
      'Rock near the surface',
      'A site where new fill has just been placed over compressible clay',
      'Any site at all, equally',
    ],
    answer: 2,
    why:
        'New fill over soft clay, which is the lesson\'s own case. The fill '
        'squeezes the clay, the clay consolidates for years, and everything '
        'in that ground goes down except the piles. Lowering a water table '
        'does the same thing, for the same reason.',
    source: 'geo-dfn-q3',
  ),
  DowndragRound(
    subject: 'the choice that reverses it',
    asked:
        'One of the wrong answers called it positive skin friction that '
        'increases capacity. Why is that tempting?',
    pile: _pile,
    dragging: true,
    options: [
      'Because friction along a shaft usually IS a resistance, and the sign '
          'is the only thing that has changed',
      'Because the words mean the same thing',
      'Because downdrag really does help in sands',
      'It is not tempting at all',
    ],
    answer: 0,
    why:
        'Because nine times out of ten shaft friction is exactly that, a '
        'resistance, and only the direction of the relative movement has '
        'flipped. The words are almost the same and the sign is the whole '
        'difference, which is why this one catches people who know the '
        'material.',
    source: 'geo-dfn-q3',
  ),
];

class _WhichWayTheFrictionActsGameState
    extends State<WhichWayTheFrictionActsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-the-friction-acts',
    chapterId: 'geotechnical',
    total: downdragRounds.length,
    sourceProblemIdOf: (round) => downdragRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  DowndragRound get _round => downdragRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way the Friction Acts',
        closing:
            'Shaft friction points whichever way the relative movement tells '
            'it to. Pile going down through still soil: it holds the pile up. '
            'Soil settling past a still pile: it drags the pile down, adds to '
            'the load, and gives no resistance over that stretch. New fill '
            'over compressible clay is the case that makes it happen.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: downdragBrief,
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
            'WHICH WAY IT RUBS',
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
                    downdrag: r.dragging,
                    showDirection: answered,
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
