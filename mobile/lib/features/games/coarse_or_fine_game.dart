import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'aggregate_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Coarse or Fine — the second item for `aggregate-properties`.
///
/// The fineness modulus problem is one division, and the division is not the
/// point of it. What the number MEANS is: a single index of how coarse a sand
/// is, read off a gradation curve. So the curves are drawn and the round asks
/// which sand carries the bigger modulus, which is the same question a
/// specification asks when it says a concrete sand must fall between 2.3 and
/// 3.1. One round gives two very different sands the same modulus, because an
/// index that summarizes a curve cannot describe its shape.
class CoarseOrFineGame extends StatefulWidget {
  const CoarseOrFineGame({super.key});

  @override
  State<CoarseOrFineGame> createState() => _CoarseOrFineGameState();
}

/// Which of the two sands, or neither.
enum Coarser { first, second, alike }

extension CoarserWords on Coarser {
  String get plain => switch (this) {
        Coarser.first => 'The blue one',
        Coarser.second => 'The orange one',
        Coarser.alike => 'Neither: the same modulus',
      };
}

@immutable
class SieveRound {
  const SieveRound({
    required this.subject,
    required this.asked,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Grading left;
  final Grading right;
  final String why;
  final String source;

  /// Worked out from the two gradings, never declared.
  Coarser get answer {
    final gap = left.fm - right.fm;
    if (gap.abs() < 0.05) return Coarser.alike;
    return gap > 0 ? Coarser.first : Coarser.second;
  }

  double get spread => (left.fm - right.fm).abs();
}

const _medium = Grading(
  name: 'A',
  passing: [100, 97, 85, 65, 40, 15, 4],
);

const _fine = Grading(
  name: 'B',
  passing: [100, 100, 95, 82, 58, 25, 8],
);

const _coarse = Grading(
  name: 'A',
  passing: [96, 78, 58, 38, 20, 8, 2],
);

/// A sand with a real coarse fraction in it: a fifth of it sits above the
/// No 4 sieve.
const _beforeScreen = Grading(
  name: 'A',
  passing: [95, 80, 62, 45, 28, 12, 3],
);

/// The same sand with that coarse fraction screened off, which leaves the
/// rest of it to make up the whole hundred percent.
const _screened = Grading(
  name: 'B',
  passing: [100, 100, 78, 56, 35, 15, 4],
);

/// A gap graded sand: almost nothing between the No 8 and the No 30.
const _gapped = Grading(
  name: 'B',
  passing: [100, 92, 62, 60, 58, 12, 1],
);

/// Smooth, and with the same modulus as the gapped one.
const _smooth = Grading(
  name: 'A',
  passing: [100, 90, 74, 56, 38, 20, 7],
);

const sieveRounds = <SieveRound>[
  SieveRound(
    subject: 'two concrete sands',
    asked: 'Tap the one with the bigger fineness modulus.',
    left: _medium,
    right: _fine,
    why:
        'The blue one. It lets less through every sieve, so more is retained '
        'on each of them, and the modulus is the retained percentages added '
        'up. A curve sitting LOWER on this chart is the coarser sand, which '
        'is worth fixing in your head because the axis says passing and the '
        'index says fineness.',
    source: 'mat-agg-q2',
  ),
  SieveRound(
    subject: 'the same two, other way round',
    asked: 'Tap the one with the bigger fineness modulus.',
    left: _fine,
    right: _medium,
    why:
        'The orange one this time, and it is the same pair of sands. A higher '
        'modulus means COARSER, which reads backwards off the word fineness: '
        'a fine sand fills the small sieves and is held back by almost '
        'nothing, so its cumulative retained percentages are small.',
    source: 'mat-agg-q2',
  ),
  SieveRound(
    subject: 'a sand and a grit',
    asked: 'Tap the one with the bigger fineness modulus.',
    left: _coarse,
    right: _fine,
    why:
        'The blue one, by a long way: about 4.0 against 2.3. A concrete sand '
        'is normally specified between 2.3 and 3.1, so the blue one is not a '
        'sand at all by that standard and the orange one is at the fine end '
        'of it. That range is what the modulus exists to police.',
    source: 'mat-agg-q2',
  ),
  SieveRound(
    subject: 'the coarse end screened off',
    asked:
        'The orange sand is the blue one with everything above the No 4 sieve '
        'taken out. Tap the one with the bigger modulus.',
    left: _beforeScreen,
    right: _screened,
    why:
        'The blue one, the sand as it came: about 3.75 against 3.1. Taking '
        'the coarsest particles out can only move the curve up and the '
        'modulus down, and a fifth of this sand sat above that sieve, so it '
        'moves a long way. What is left has to make up the whole hundred '
        'percent, which is why the finer end of the orange curve sits higher '
        'too.',
    source: 'mat-agg-q2',
  ),
  SieveRound(
    subject: 'one with a gap in it',
    asked:
        'The orange sand has almost nothing between the No 8 and the No 30 '
        'sieves. Tap the one with the bigger modulus.',
    left: _smooth,
    right: _gapped,
    why:
        'Neither: they come to the same modulus. This is the honest limit of '
        'the index. It adds up seven numbers and cannot tell a smooth '
        'distribution from one with a hole in it, and those two behave '
        'nothing alike: the gap graded sand leaves voids that have to be '
        'filled with paste. The modulus is a summary, not a gradation.',
    source: 'mat-agg-q2',
  ),
  SieveRound(
    subject: 'which one needs more paste',
    asked:
        'Same question as ever: tap the one with the bigger fineness '
        'modulus.',
    left: _coarse,
    right: _medium,
    why:
        'The blue one again. Coarser means less surface area for the paste to '
        'coat, so a coarse sand needs less of it, which is the reason mix '
        'designers care about the modulus at all. It is not a quality score. '
        'It is a number that tells you how much cement paste the sand is '
        'going to ask for.',
    source: 'mat-agg-q2',
  ),
];

class _CoarseOrFineGameState extends State<CoarseOrFineGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'coarse-or-fine',
    chapterId: 'materials',
    total: sieveRounds.length,
    sourceProblemIdOf: (round) => sieveRounds[round].source,
  )..addListener(_onSession);

  Coarser? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SieveRound get _round => sieveRounds[_session.round];

  int? _index(Coarser? which) => switch (which) {
        Coarser.first => 0,
        Coarser.second => 1,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Coarse or Fine',
        closing:
            'The modulus adds up what each sieve held back, so a higher one '
            'means COARSER, which reads backwards off its name. On the chart '
            'the lower curve is the coarser sand. A concrete sand is normally '
            'asked to sit between 2.3 and 3.1, and two sands can share a '
            'modulus and still be nothing alike, because one number cannot '
            'carry the shape of a curve.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gradingBrief,
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
            'TAP THE COARSER SAND',
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
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 240);
              final gradings = [r.left, r.right];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = GradingPainter.nearest(
                            size, gradings, details.localPosition);
                        if (hit == null) return;
                        setState(() => _picked =
                            hit == 0 ? Coarser.first : Coarser.second);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: GradingPainter(
                        gradings: gradings,
                        picked: _index(_picked),
                        answer: answered ? _index(r.answer) : null,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            answered
                ? 'modulus: blue ${r.left.fm.toStringAsFixed(2)}, '
                    'orange ${r.right.fm.toStringAsFixed(2)}'
                : 'percent passing each sieve, coarse sieves on the left',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Coarser.alike.plain,
            selected: _picked == Coarser.alike,
            locked: answered,
            isTruth: r.answer == Coarser.alike,
            onTap:
                answered ? null : () => setState(() => _picked = Coarser.alike),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE COARSER ONE' : 'THE OTHER WAY',
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
