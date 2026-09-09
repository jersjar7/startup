import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cross_figures.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Which Way Does It Turn — the first item for `cross-product-applications`.
///
/// A moment is a cross product, and the half of it a student can actually
/// check on sight is which way the thing turns. That is the right-hand rule,
/// and it is also where the lesson's first trap lives: swapping the two
/// vectors flips the answer, so r cross F and F cross r are opposite moments.
/// Two rounds here are the same pair in the two orders, which is a thing to
/// watch happen rather than a sentence to agree with. A third possibility is
/// on every round, because two vectors along the same line turn nothing at
/// all, and a student who has only ever seen curls will not expect it.
class WhichWayTurnsGame extends StatefulWidget {
  const WhichWayTurnsGame({super.key});

  @override
  State<WhichWayTurnsGame> createState() => _WhichWayTurnsGameState();
}

@immutable
class TurnRound {
  const TurnRound({
    required this.ask,
    required this.first,
    required this.second,
    required this.firstLabel,
    required this.secondLabel,
    required this.why,
    required this.source,
  });

  final String ask;

  /// The one on the left of the cross, and the one on the right. Order is the
  /// whole point, so they are named rather than numbered.
  final Vec first;
  final Vec second;
  final String firstLabel;
  final String secondLabel;
  final String why;
  final String source;

  /// The k component of the cross product, which in a flat drawing is the
  /// whole of it. Worked out here so a round cannot disagree with its arrows.
  double get k => first.x * second.y - first.y * second.x;

  Turn get answer {
    if (k.abs() < 1e-9) return Turn.none;
    return k > 0 ? Turn.counter : Turn.clockwise;
  }
}

const turnRounds = <TurnRound>[
  TurnRound(
    ask: 'A force pushes up at the end of a horizontal arm.',
    first: Vec(3, 0),
    second: Vec(0, 5),
    firstLabel: 'r',
    secondLabel: 'F',
    why:
        'Sweep from r round to F the short way and it goes counterclockwise, '
        'so the moment points out of the page. That is the right-hand rule: '
        'fingers along r, curl to F, thumb comes at you.',
    source: 'math-cpa-q1',
  ),
  TurnRound(
    ask: 'A weight hangs off an arm that reaches out and up.',
    first: Vec(3, 4),
    second: Vec(0, -5),
    firstLabel: 'r',
    secondLabel: 'F',
    why:
        'A downward pull on an arm reaching up and to the right turns it '
        'clockwise, into the page. This is the worked moment problem with the '
        'zeros left off.',
    source: 'math-cpa-q2',
  ),
  TurnRound(
    ask: 'The same two arrows as the last round, crossed the other way round.',
    first: Vec(0, -5),
    second: Vec(3, 4),
    firstLabel: 'F',
    secondLabel: 'r',
    why:
        'Same arrows, opposite answer. A cross product changes sign when you '
        'swap the order, which is why a moment is r cross F and never F cross '
        'r. Getting this backwards reverses every moment in the problem.',
    source: 'math-cpa-q2',
  ),
  TurnRound(
    ask: 'A horizontal push at the top of a vertical post.',
    first: Vec(0, 4),
    second: Vec(3, 0),
    firstLabel: 'r',
    secondLabel: 'F',
    why:
        'Up the post, then push to the right, and the post rotates clockwise '
        'about its base. Nothing here is in the first quadrant twice, and the '
        'rule still only cares about the sweep from the first to the second.',
    source: 'math-cpa-q1',
  ),
  TurnRound(
    ask: 'The force runs straight along the arm.',
    first: Vec(2, 2),
    second: Vec(4, 4),
    firstLabel: 'r',
    secondLabel: 'F',
    why:
        'No turn at all. A force pointing straight along the arm cannot '
        'rotate anything about the pivot, and the cross product of two arrows '
        'on the same line is zero. A vector crossed with itself is the same '
        'story.',
    source: 'math-cpa-q1',
  ),
  TurnRound(
    ask: 'Two edges of a plot, taken in the order they are written.',
    first: Vec(4, 0),
    second: Vec(2, 3),
    firstLabel: 'u',
    secondLabel: 'v',
    why:
        'Counterclockwise, so u cross v points out of the page. For an area '
        'this only decides the sign, and the area is the size of it either '
        'way. For a moment the sign is the answer.',
    source: 'math-cpa-q3',
  ),
];

class _WhichWayTurnsGameState extends State<WhichWayTurnsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-turns',
    chapterId: 'mathematics',
    total: turnRounds.length,
    sourceProblemIdOf: (round) => turnRounds[round].source,
  )..addListener(_onSession);

  Turn? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TurnRound get _round => turnRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Does It Turn',
        closing:
            'Sweep from the first arrow to the second: counterclockwise means '
            'the cross product comes out of the page, clockwise means it goes '
            'in, and two arrows on one line turn nothing. Swapping the order '
            'swaps the answer.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: rightHandBrief,
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
            'SWEEP FROM THE FIRST TO THE SECOND',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Which way does ${r.firstLabel} cross ${r.secondLabel} turn?',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: VectorPainter(
                    span: 6,
                    between: (r.first, r.second),
                    arrows: [
                      Arrow(
                        r.first,
                        color: AppColors.ember,
                        label: r.firstLabel,
                      ),
                      Arrow(
                        r.second,
                        color: AppColors.forest,
                        label: r.secondLabel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final turn in Turn.values) ...[
                if (turn != Turn.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _TurnCard(
                    key: ValueKey('turn-${turn.name}'),
                    turn: turn,
                    selected: _picked == turn,
                    locked: answered,
                    isTruth: r.answer == turn,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = turn),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (r.answer == Turn.none ? 'NOTHING TURNS' : 'THAT WAY')
                  : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _TurnCard extends StatelessWidget {
  const _TurnCard({
    super.key,
    required this.turn,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Turn turn;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  // Broken over two lines on purpose: "counterclockwise" is one word too long
  // for a third of a phone, and letting it wrap on its own splits it mid-word.
  static const _labels = {
    Turn.counter: ('Counter\nclockwise', 'out of the page'),
    Turn.clockwise: ('Clockwise', 'into the page'),
    Turn.none: ('No turn', 'the cross is zero'),
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

    final glyphColor = (locked && isTruth)
        ? AppColors.forest
        : (locked && selected)
        ? AppColors.error
        : selected
        ? AppColors.ember
        : AppColors.ink2;

    final (label, detail) = _labels[turn]!;
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 46,
                width: double.infinity,
                child: CustomPaint(
                  painter: TurnGlyphPainter(turn: turn, color: glyphColor),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 34,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTheme.heading(size: 12.5, height: 1.2),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                textAlign: TextAlign.center,
                style: AppTheme.mono(size: 9, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
