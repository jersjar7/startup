import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'statics_figures.dart';

/// Which Arrow Is That — the first item for `force-systems-resultants`.
///
/// Both of the lesson's resolution problems have the same trap and it is not
/// arithmetic: the components come out right and get attached to the wrong
/// directions. Sine where cosine belongs, or the vertical leg applied to the
/// horizontal component.
///
/// So the arithmetic is done for you. The force is drawn with both of its
/// components beside it to one scale, one number is named, and the question is
/// which arrow that number belongs to. A swap is then not a notation slip but
/// a claim that the shorter arrow is the longer one, which is visible.
///
/// Two rounds use the same three numbers on mirrored triangles, and the answer
/// moves. One round measures its angle from the VERTICAL, where the cosine
/// goes with the vertical component and every memorized rule points the wrong
/// way.
class WhichArrowIsThatGame extends StatefulWidget {
  const WhichArrowIsThatGame({super.key});

  @override
  State<WhichArrowIsThatGame> createState() => _WhichArrowIsThatGameState();
}

@immutable
class ArrowRound {
  const ArrowRound({
    required this.subject,
    required this.setting,
    required this.dx,
    required this.dy,
    required this.named,
    required this.answer,
    required this.angleFrom,
    this.angleLabel = '',
    this.xLabel = '',
    this.yLabel = '',
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The legs of the triangle, in the round's own units. The picture is drawn
  /// from these, so a round cannot describe one shape and draw another.
  final double dx;
  final double dy;

  /// The one number on the board, written the way the exam writes it.
  final String named;

  /// 0 the horizontal component, 1 the vertical, 2 the whole force.
  final int answer;

  final AngleFrom angleFrom;
  final String angleLabel;
  final String xLabel;
  final String yLabel;

  final String why;
  final String source;
}

const arrowRounds = <ArrowRound>[
  ArrowRound(
    subject: 'a cable on a bridge anchor',
    setting:
        'A cable pulls on the anchor with 500 newtons, at 35 degrees above the '
        'horizontal. One of the three arrows is 410 newtons.',
    dx: 409.6,
    dy: 286.8,
    named: '410 N',
    answer: 0,
    angleFrom: AngleFrom.horizontal,
    angleLabel: '35 deg',
    why:
        'The horizontal one. The angle opens off the horizontal axis, so the '
        'horizontal component is the one next to it and it takes the cosine, '
        'which is the larger of the two below 45 degrees. Handing 410 to the '
        'vertical arrow claims the short arrow is the long one.',
    source: 'stat-fsr-q1',
  ),
  ArrowRound(
    subject: 'a guy wire on a sign gantry',
    setting:
        'The wire pulls with 800 newtons at 60 degrees above the horizontal. '
        'One of the arrows is 693 newtons.',
    dx: 400,
    dy: 692.8,
    named: '693 N',
    answer: 1,
    angleFrom: AngleFrom.horizontal,
    angleLabel: '60 deg',
    why:
        'The vertical one, and the angle is still measured off the horizontal. '
        'Past 45 degrees the component taking the cosine is the SHORTER one, '
        'so any rule of thumb about the big number going across the bottom '
        'falls over here.',
    source: 'stat-fsr-q1',
  ),
  ArrowRound(
    subject: 'a deadman anchor behind a wall',
    setting:
        'The cable runs 5 meters out and 12 meters up to the anchor and pulls '
        'with 1,300 newtons. One of the arrows is 500 newtons.',
    dx: 5,
    dy: 12,
    named: '500 N',
    answer: 0,
    angleFrom: AngleFrom.none,
    xLabel: '5 m',
    yLabel: '12 m',
    why:
        'The horizontal one. Five out and twelve up over a length of thirteen, '
        'so the horizontal component is five thirteenths of 1,300. The '
        'horizontal leg goes with the horizontal component, every time, and no '
        'angle was needed to see it.',
    source: 'stat-fsr-q2',
  ),
  ArrowRound(
    subject: 'the same anchor, laid the other way',
    setting:
        'The same 1,300 newton cable, but this run goes 12 meters out and 5 '
        'meters up. One of the arrows is 500 newtons again.',
    dx: 12,
    dy: 5,
    named: '500 N',
    answer: 1,
    angleFrom: AngleFrom.none,
    xLabel: '12 m',
    yLabel: '5 m',
    why:
        'The vertical one this time. Same force, same three numbers, legs '
        'swapped, and the answer moves with the picture rather than with the '
        'arithmetic. This is the trap the lesson names, drawn twice so it '
        'cannot be answered from memory.',
    source: 'stat-fsr-q2',
  ),
  ArrowRound(
    subject: 'a stay on a formwork brace',
    setting:
        'The stay runs 8 feet across and 6 feet up and carries 1,000 pounds. '
        'One of the arrows is 1,000 pounds.',
    dx: 8,
    dy: 6,
    named: '1,000 lb',
    answer: 2,
    angleFrom: AngleFrom.none,
    xLabel: '8 ft',
    yLabel: '6 ft',
    why:
        'The force itself. A component is always SHORTER than the force it '
        'came from, so the full magnitude can only belong to the diagonal. If '
        'a component ever comes out equal to the force, something has been '
        'divided by the wrong thing.',
    source: 'stat-fsr-q2',
  ),
  ArrowRound(
    subject: 'a hanger off a bridge soffit',
    setting:
        'The hanger pulls with 600 newtons, at 25 degrees from the VERTICAL. '
        'One of the arrows is 544 newtons.',
    dx: 253.6,
    dy: 543.8,
    named: '544 N',
    answer: 1,
    angleFrom: AngleFrom.vertical,
    angleLabel: '25 deg',
    why:
        'The vertical one. The cosine goes with whichever axis the angle is '
        'measured FROM, and here that is the vertical. Reaching for cosine '
        'equals horizontal without looking at where the angle sits is how this '
        'one is lost.',
    source: 'stat-fsr-q1',
  ),
];

class _WhichArrowIsThatGameState extends State<WhichArrowIsThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-arrow-is-that',
    chapterId: 'statics',
    total: arrowRounds.length,
    sourceProblemIdOf: (round) => arrowRounds[round].source,
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

  ArrowRound get _round => arrowRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Arrow Is That',
        closing:
            'The cosine goes with the axis the angle is measured FROM, and the '
            'horizontal leg goes with the horizontal component. Neither rule '
            'is about which number is bigger. A component is always shorter '
            'than the force it came from, which is the one check worth making '
            'every time.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: resolveBrief,
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
            'WHICH ARROW IS ${r.named}',
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
          const SizedBox(height: 6),
          Text(
            'tap the arrow on the drawing',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          _Figure(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT ONE' : 'A DIFFERENT ARROW',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The triangle, with a tap zone over each of its three arrows.
///
/// The zones are strips rather than boxes around the arrows, because the two
/// components meet at a corner and any shape tight enough to follow one of
/// them would overlap the other there.
class _Figure extends StatelessWidget {
  const _Figure({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final ArrowRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 230.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 20,
          major: 100,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: ForceTrianglePainter(
                    dx: round.dx,
                    dy: round.dy,
                    angleFrom: round.angleFrom,
                    angleLabel: round.angleLabel,
                    xLabel: round.xLabel,
                    yLabel: round.yLabel,
                    selected: picked,
                    locked: locked,
                    truth: round.answer,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              // The bottom strip is the horizontal component's.
              Positioned(
                key: const ValueKey('arrow-0'),
                left: ForceTrianglePainter.gutter * 2,
                right: 0,
                bottom: 0,
                height: 44,
                child: _Zone(onTap: onTap == null ? null : () => onTap!(0)),
              ),
              // The left strip is the vertical component's.
              Positioned(
                key: const ValueKey('arrow-1'),
                left: 0,
                top: 0,
                bottom: 0,
                width: ForceTrianglePainter.gutter * 2 + 18,
                child: _Zone(onTap: onTap == null ? null : () => onTap!(1)),
              ),
              // Everything else is the force.
              Positioned(
                key: const ValueKey('arrow-2'),
                left: ForceTrianglePainter.gutter * 2 + 18,
                right: 0,
                top: 0,
                bottom: 44,
                child: _Zone(onTap: onTap == null ? null : () => onTap!(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Zone extends StatelessWidget {
  const _Zone({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox.expand(),
      );
}
