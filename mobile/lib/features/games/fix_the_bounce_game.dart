import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'deflection_figures.dart';
import 'lesson_brief.dart';

/// Fix the Bounce — the second item for `beam-deflections`.
///
/// The lesson opens by saying deflection, not strength, is what usually
/// decides a beam. That turns into an engineer's question rather than a
/// student's: the floor bounces, and you can change one thing. Which change
/// buys the most?
///
/// It is answerable without arithmetic if you can read the table: the span
/// carries a third or a fourth power, the depth carries a third through I, the
/// width and the load carry only a first, and the material carries E, which is
/// the one that separates timber from steel. Every option here is worked out
/// from the table entry rather than declared.
class FixTheBounceGame extends StatefulWidget {
  const FixTheBounceGame({super.key});

  @override
  State<FixTheBounceGame> createState() => _FixTheBounceGameState();
}

/// One thing you could change about the beam.
@immutable
class Cure {
  const Cure(
    this.label, {
    this.span = 1,
    this.load = 1,
    this.e = 1,
    this.i = 1,
  });

  final String label;

  /// What each quantity is multiplied by.
  final double span;
  final double load;
  final double e;
  final double i;
}

@immutable
class BounceRound {
  const BounceRound({
    required this.subject,
    required this.setting,
    required this.entry,
    required this.span,
    required this.cures,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Entry entry;

  /// In millimeters, for the drawing and for the arithmetic both.
  final double span;

  final List<Cure> cures;
  final String why;
  final String source;

  /// A starting point. Only the ratios between the options matter, so the
  /// numbers themselves never reach the screen.
  static const _load = 10.0;
  static const _e = 12000.0;
  static const _i = 60e6;

  double sagWith(Cure c) => entry.sag(
        load: _load * c.load,
        span: span * c.span,
        e: _e * c.e,
        i: _i * c.i,
      );

  double get sagNow => sagWith(const Cure(''));

  /// Which change leaves the beam sagging least. Worked out by putting every
  /// option through the table.
  int get answer {
    var best = double.infinity;
    var at = 0;
    for (var i = 0; i < cures.length; i++) {
      final sag = sagWith(cures[i]);
      if (sag < best - 1e-12) {
        best = sag;
        at = i;
      }
    }
    return at;
  }
}

const bounceRounds = <BounceRound>[
  BounceRound(
    subject: 'a bouncy floor',
    setting:
        'A timber joist carrying floorboards over a four meter room feels '
        'springy underfoot. It is strong enough. You can make one change.',
    entry: Entry.ssUdl,
    span: 4000,
    cures: [
      Cure('Take a quarter off the span', span: 0.75),
      Cure('Make the joist twice as wide', i: 2),
      Cure('Use a timber twenty percent stiffer', e: 1.2),
    ],
    why:
        'Shorten it. The span comes in to the FOURTH power under a spread '
        'load, so taking a quarter off leaves less than a third of the sag. '
        'Doubling the width only halves it, because width goes into I once. '
        'Span is always the first thing to look at, and it is usually the '
        'hardest thing to change, which is why floors are designed around it.',
    source: 'mm-bdf-q2',
  ),
  BounceRound(
    subject: 'a balcony that moves',
    setting:
        'A steel cantilever two meters out from the wall carries a load at its '
        'tip, and the tip moves more than anybody is comfortable with.',
    entry: Entry.cantPoint,
    span: 2000,
    cures: [
      Cure('Halve how far it sticks out', span: 0.5),
      Cure('Make the beam twice as wide', i: 2),
      Cure('Use a steel of twice the strength', e: 1),
    ],
    why:
        'Halve the reach. Length is cubed on a cantilever tip, so half the '
        'reach is an eighth of the movement. Twice the width is only half. And '
        'the third option does NOTHING at all: a stronger steel has exactly '
        'the same modulus of elasticity, around 200 GPa for every grade. '
        'Strength and stiffness are different properties, and only stiffness '
        'is in this table.',
    source: 'mm-bdf-q1',
  ),
  BounceRound(
    subject: 'a beam under one heavy load',
    setting:
        'A simply supported steel beam with a single load at midspan sags '
        'twice what the specification allows.',
    entry: Entry.ssPoint,
    span: 6000,
    cures: [
      Cure('Use a higher grade of steel', e: 1),
      Cure('Add a quarter to the depth', i: 1.953),
      Cure('Take a tenth off the span', span: 0.9),
    ],
    why:
        'Deepen it. A quarter more depth is nearly double the I, because depth '
        'is CUBED in the second moment of area, and that cuts the sag almost '
        'in half. A tenth off the span saves about a quarter. The higher grade '
        'steel changes nothing whatever: same E, same sag, and you have paid '
        'more for it.',
    source: 'mm-bdf-q1',
  ),
  BounceRound(
    subject: 'fifty millimeters of extra timber',
    setting:
        'A hundred by two hundred joist needs to be stiffer. You have fifty '
        'millimeters of extra timber to spend and you can spend it on either '
        'dimension.',
    entry: Entry.ssUdl,
    span: 4000,
    cures: [
      Cure('Make it 150 wide and 200 deep', i: 1.5),
      Cure('Make it 100 wide and 250 deep', i: 1.953),
      Cure('Use a timber a third stiffer', e: 1.333),
    ],
    why:
        'Spend it on depth. The same fifty millimeters gives you half as much '
        'again on the width and nearly DOUBLE on the depth, because the width '
        'counts once and the depth counts three times over. It is also why a '
        'joist is laid on edge and never on its side, and why the extra timber '
        'beats the better timber here.',
    source: 'mm-bdf-q2',
  ),
  BounceRound(
    subject: 'a beam with room to grow',
    setting:
        'A simply supported beam under a spread load. The three changes below '
        'are all things the job will allow.',
    entry: Entry.ssUdl,
    span: 5000,
    cures: [
      Cure('Halve the load it carries', load: 0.5),
      Cure('Double the depth', i: 8),
      Cure('Take a quarter off the span', span: 0.75),
    ],
    why:
        'Double the depth: eight times the I is an eighth of the sag, which '
        'beats everything else here. Halving the load only halves the sag, '
        'because load comes in once. Note how the ranking moved from the first '
        'round: a quarter off the span was the winner there and comes third '
        'here, because this time the other change is much bigger. Read the '
        'powers AND the sizes.',
    source: 'mm-bdf-q2',
  ),
  BounceRound(
    subject: 'timber against steel',
    setting:
        'The same joist, the same span, the same load. One of the changes on '
        'offer is to make it out of something else entirely.',
    entry: Entry.ssUdl,
    span: 4000,
    cures: [
      Cure('Halve the load on each joist', load: 0.5),
      Cure('Add a fifth to the depth', i: 1.728),
      Cure('Use steel instead of timber, same size', e: 16.7),
    ],
    why:
        'Steel, and it is not close: around 200 GPa against 12, so the same '
        'shape sags about a sixteenth as much. This is the one place the '
        'material really does decide the answer. Worth holding against the '
        'last lesson, where neither stress formula had E in it at all: the '
        'material does not change what a beam FEELS, only how far it moves.',
    source: 'mm-bdf-q1',
  ),
];

class _FixTheBounceGameState extends State<FixTheBounceGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'fix-the-bounce',
    chapterId: 'mechanics-materials',
    total: bounceRounds.length,
    sourceProblemIdOf: (round) => bounceRounds[round].source,
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

  BounceRound get _round => bounceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Fix the Bounce',
        closing:
            'Span carries a third or a fourth power. Depth carries a third '
            'through I. Width and load carry only a first. The material '
            'carries E, which is nothing between two steels and everything '
            'between timber and steel. Read the powers, then read the sizes.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: bounceBrief,
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
            'WHICH CHANGE BUYS THE MOST',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 118,
              child: CustomPaint(
                painter: SagPainter(entry: r.entry, span: r.span),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${r.entry.plain}, sagging as it stands',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.cures.length; i++) ...[
            _Choice(
              label: r.cures[i].label,
              note: answered
                  ? _share(r.sagWith(r.cures[i]) / r.sagNow)
                  : null,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT BUYS THE MOST' : 'ANOTHER BUYS MORE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }

  /// How much of the sag is left, in plain words rather than as a number to
  /// be computed with.
  String _share(double ratio) {
    if (ratio > 0.995) return 'leaves it exactly as it was';
    final percent = (ratio * 100).round();
    return 'leaves about $percent percent of the sag';
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final String? note;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontSize: 15, color: AppColors.charcoal),
              ),
              if (note != null) ...[
                const SizedBox(height: 3),
                Text(
                  note!,
                  style: AppTheme.mono(
                    size: 11,
                    color: isTruth ? AppColors.forest : AppColors.ink3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
