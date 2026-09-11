import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'energy_figures.dart';
import 'lesson_brief.dart';

/// Where the Energy Goes — the first item for `work-energy-power`.
///
/// The work energy theorem is bookkeeping: what the thing started with, plus
/// anything put in, minus anything rubbed away, is what it ends with. Every
/// problem in this lesson is that one sentence with different buckets filled
/// in, and reading which buckets a situation HAS is the step before any
/// arithmetic.
///
/// So the story is told in words and three sets of before and after bars are
/// drawn. Only one of them is the story.
class WhereTheEnergyGoesGame extends StatefulWidget {
  const WhereTheEnergyGoesGame({super.key});

  @override
  State<WhereTheEnergyGoesGame> createState() =>
      _WhereTheEnergyGoesGameState();
}

@immutable
class LedgerRound {
  const LedgerRound({
    required this.subject,
    required this.setting,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The three accounts on offer, in the order they are drawn.
  final List<Ledger> options;

  final int answer;
  final String why;
  final String source;

  Ledger get truth => options[answer];

  /// One scale for the row, so a taller bar really is more energy.
  double get tallest {
    var most = 0.0;
    for (final o in options) {
      if (o.tallest > most) most = o.tallest;
    }
    return most;
  }
}

const ledgerRounds = <LedgerRound>[
  LedgerRound(
    subject: 'a block down a frictionless ramp',
    setting:
        'A block is let go at the top of a smooth ramp and slides to the '
        'bottom. This is the lesson\'s own first problem.',
    options: [
      // Height turns into movement, and nothing is lost.
      Ledger(heightStart: 100, movingEnd: 100),
      // Something rubbed away that should not have been.
      Ledger(heightStart: 100, movingEnd: 60, gone: 40),
      // Movement at the top that it never had.
      Ledger(heightStart: 60, movingStart: 40, movingEnd: 100),
    ],
    answer: 0,
    why:
        'The first. All of the height turns into movement and none of it goes '
        'anywhere else, because the ramp is smooth: that is what makes it a '
        'conservation problem. The second rubs energy away on a surface the '
        'problem says has no friction. The third gives the block speed at the '
        'top, and it was let go from rest.',
    source: 'dyn-wep-q1',
  ),
  LedgerRound(
    subject: 'a block sliding to a stop',
    setting:
        'A block is already moving along a flat floor and friction brings it '
        'to a standstill. Nothing goes up or down.',
    options: [
      Ledger(movingStart: 100, heightEnd: 100),
      Ledger(movingStart: 100, gone: 100),
      Ledger(movingStart: 100, movingEnd: 100),
    ],
    answer: 1,
    why:
        'The second, and the after bar is nothing but what friction took. The '
        'floor is flat so no height is involved either end, and the block '
        'stops so there is no movement left: every joule it had is rubbed away '
        'as heat. That is the lesson\'s hardest problem, and it is why energy '
        'methods give the stopping distance without ever finding the time.',
    source: 'dyn-wep-q3',
  ),
  LedgerRound(
    subject: 'a pump lifting water',
    setting:
        'A pump lifts water twenty meters up a pipe at a steady rate. The '
        'water leaves as slowly as it arrived.',
    options: [
      Ledger(added: 100, heightEnd: 80, gone: 20),
      Ledger(heightStart: 100, movingEnd: 100),
      Ledger(added: 80, heightEnd: 100),
    ],
    answer: 0,
    why:
        'The first. Something OUTSIDE is putting energy in here, which is the '
        'motor, and not all of it reaches the water: the rest is lost in the '
        'pump. That is exactly what efficiency means. The third has more '
        'coming out than went in, which no machine has ever managed.',
    source: 'dyn-wep-q2',
  ),
  LedgerRound(
    subject: 'a spring launching a block',
    setting:
        'A compressed spring is released and pushes a block along a smooth '
        'level track.',
    options: [
      Ledger(springStart: 100, gone: 100),
      Ledger(springStart: 100, movingEnd: 100),
      Ledger(movingStart: 100, springEnd: 100),
    ],
    answer: 1,
    why:
        'The second. A spring is a STORE, not a loss: what was squeezed into '
        'it comes back out as movement, and the total never changes. The third '
        'is the same event run backwards, which is a block compressing a '
        'spring, and that is a perfectly good problem in its own right, just '
        'not this one.',
    source: 'dyn-wep-q1',
  ),
  LedgerRound(
    subject: 'a block sliding down a rough ramp',
    setting:
        'The same ramp as the first round, but this one is rough. The block '
        'reaches the bottom moving, but not as fast as it would have.',
    options: [
      Ledger(heightStart: 100, movingEnd: 100),
      Ledger(heightStart: 100, movingEnd: 70, gone: 30),
      Ledger(heightStart: 100, heightEnd: 70, gone: 30),
    ],
    answer: 1,
    why:
        'The second. The height is all spent either way; the difference is '
        'that friction takes a share of it and only the rest turns into '
        'speed. This is the full form of the theorem with its one extra term, '
        'and it is the only one of the three bars where the after side is '
        'shorter than the before side.',
    source: 'dyn-wep-q3',
  ),
  LedgerRound(
    subject: 'a ball thrown straight up',
    setting:
        'A ball leaves a hand moving fast and is caught at the top of its '
        'flight, where it is momentarily still. Ignore the air.',
    options: [
      Ledger(movingStart: 100, movingEnd: 100),
      Ledger(movingStart: 100, gone: 100),
      Ledger(movingStart: 100, heightEnd: 100),
    ],
    answer: 2,
    why:
        'The third. All the movement it left with has become height by the '
        'time it stops at the top, and none of it is lost, so the two bars '
        'are the same size. Being momentarily still is not the same as having '
        'no energy: it is all sitting in the height, ready to come back.',
    source: 'dyn-wep-q1',
  ),
];

class _WhereTheEnergyGoesGameState extends State<WhereTheEnergyGoesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-the-energy-goes',
    chapterId: 'dynamics',
    total: ledgerRounds.length,
    sourceProblemIdOf: (round) => ledgerRounds[round].source,
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

  LedgerRound get _round => ledgerRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where the Energy Goes',
        closing:
            'What it started with, plus anything put in, minus anything rubbed '
            'away, is what it ends with. A spring stores and gives back. '
            'Friction takes and never returns. A motor adds from outside. Read '
            'which of those a problem has before you write a single term.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: ledgerBrief,
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
            'TAP THE ACCOUNT THAT MATCHES',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Panel(
              ledger: r.options[i],
              tallest: r.tallest,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'all three to one scale',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ACCOUNT' : 'A DIFFERENT STORY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.ledger,
    required this.tallest,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Ledger ledger;
  final double tallest;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 116,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: LedgerPainter(ledger: ledger, tallest: tallest),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
