import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rotation_figures.dart';

/// Harder to Spin — the second item for `rigid-body-kinematics-mass-moi`.
///
/// The handbook hands you the mass moment of inertia of every standard shape
/// and the parallel axis theorem to move it, so nothing here is derived. What
/// decides the answer is where the mass sits relative to the axis you are
/// spinning about, and that is a judgment made by looking: the same mass in
/// the same size of body can be twice as hard to spin, or twelve times, purely
/// because of how it is spread and where the axis is.
///
/// Every pair here has the SAME mass, so the comparison is only ever about
/// arrangement.
class HarderToSpinGame extends StatefulWidget {
  const HarderToSpinGame({super.key});

  @override
  State<HarderToSpinGame> createState() => _HarderToSpinGameState();
}

@immutable
class PairRound2 {
  const PairRound2({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Body left;
  final Body right;
  final String why;
  final String source;

  /// Which takes more to spin up. Worked out from the table entries and the
  /// transfer term, never declared beside the round.
  int get answer => left.inertia > right.inertia ? 0 : 1;

  /// How much more, which the feedback quotes.
  double get ratio => left.inertia > right.inertia
      ? left.inertia / right.inertia
      : right.inertia / left.inertia;

  /// The room both drawings have to share, so they are drawn to one scale.
  double get frame {
    var most = 0.0;
    for (final b in [left, right]) {
      final reach = b.spin == Spin.offset
          ? b.offset + b.radius
          : (b.kind == Shape3.rod ? b.length / 2 : b.radius);
      if (reach > most) most = reach;
    }
    return most * 1.1;
  }
}

const pairRounds2 = <PairRound2>[
  PairRound2(
    subject: 'a hoop against a solid disc',
    setting:
        'Both four kilograms, both half a meter across, both spun about the '
        'axis through the middle. One has its mass out at the rim and the '
        'other has it spread all the way through.',
    left: Body(kind: Shape3.hoop, mass: 4, radius: 0.25),
    right: Body(kind: Shape3.disc, mass: 4, radius: 0.25),
    why:
        'The hoop, by exactly two. Every gram of the hoop sits at the full '
        'radius, while the disc has most of its material closer in where it '
        'hardly counts. The table says m r squared against a half m r '
        'squared, and that factor of two is the whole difference between the '
        'two arrangements of the same four kilograms.',
    source: 'dyn-rbk-q3',
  ),
  PairRound2(
    subject: 'a rod spun two ways',
    setting:
        'The same two meter rod, three kilograms. On the left it turns about '
        'its middle, on the right about one end.',
    left: Body(kind: Shape3.rod, mass: 3, length: 2),
    right: Body(kind: Shape3.rod, mass: 3, length: 2, spin: Spin.end),
    why:
        'About the end, and by four times. Nothing about the rod changed, only '
        'where the axis is: a twelfth of m L squared becomes a third of it. '
        'This is the parallel axis theorem in its plainest form, the transfer '
        'term being three times the centroidal one, and it is why a long '
        'spanner swung from its end feels so heavy.',
    source: 'dyn-rbk-q3',
  ),
  PairRound2(
    subject: 'a sphere against a cylinder',
    setting:
        'Both six kilograms, both three hundred millimeters across, both spun '
        'about their own middle.',
    left: Body(kind: Shape3.sphere, mass: 6, radius: 0.15),
    right: Body(kind: Shape3.cylinder, mass: 6, radius: 0.15, length: 0.2),
    why:
        'The cylinder, though only by a quarter: a half m r squared against '
        'two fifths. A sphere pulls more of its material in toward the middle '
        'than a cylinder of the same radius does, so it is the easier of the '
        'two to spin. Both are table entries and neither is worth deriving.',
    source: 'dyn-rbk-q3',
  ),
  PairRound2(
    subject: 'the lesson\'s own cylinder, moved',
    setting:
        'A twelve kilogram cylinder two hundred millimeters across. On the '
        'left it spins about its own axis; on the right the axis is half a '
        'meter away.',
    left: Body(kind: Shape3.cylinder, mass: 12, radius: 0.1, length: 0.3),
    right: Body(
      kind: Shape3.cylinder,
      mass: 12,
      radius: 0.1,
      length: 0.3,
      spin: Spin.offset,
      offset: 0.5,
    ),
    why:
        'The offset one, and it is not close: about fifty times. The lesson\'s '
        'own hard problem is this pair, and its point is how completely the '
        'transfer term takes over once the axis is further away than the body '
        'is wide. Dropping the m d squared there is not a small error, and '
        'dropping the centroidal term instead barely changes the answer.',
    source: 'dyn-rbk-q3',
  ),
  PairRound2(
    subject: 'the same body, two distances',
    setting:
        'The same eight kilogram disc, carried on an arm. On the left the axis '
        'is half a meter away, on the right a whole meter.',
    left: Body(
      kind: Shape3.disc,
      mass: 8,
      radius: 0.12,
      spin: Spin.offset,
      offset: 0.5,
    ),
    right: Body(
      kind: Shape3.disc,
      mass: 8,
      radius: 0.12,
      spin: Spin.offset,
      offset: 1,
    ),
    why:
        'The further one, by about four times. The transfer term carries the '
        'distance SQUARED, so doubling the arm quadruples what it takes to '
        'spin the thing up. It is the same squared distance that runs through '
        'the second moment of area in the statics chapter, doing the same job '
        'for a different quantity.',
    source: 'dyn-rbk-q3',
  ),
  PairRound2(
    subject: 'a disc spun flat or tipped',
    setting:
        'One five kilogram disc, four hundred millimeters across. On the left '
        'it spins the way a wheel does; on the right it is tipped over and '
        'spun about a line across its face.',
    left: Body(kind: Shape3.disc, mass: 5, radius: 0.2),
    right: Body(kind: Shape3.disc, mass: 5, radius: 0.2, spin: Spin.diameter),
    why:
        'The way a wheel spins, by two. Turning it about a line across its '
        'face brings half its material close to that line, so a half m r '
        'squared drops to a quarter. Same disc, same mass, same radius, and '
        'the axis alone decides. That is the one question worth asking of any '
        'table entry: which axis is this line of the table talking about?',
    source: 'dyn-rbk-q3',
  ),
];

class _HarderToSpinGameState extends State<HarderToSpinGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'harder-to-spin',
    chapterId: 'dynamics',
    total: pairRounds2.length,
    sourceProblemIdOf: (round) => pairRounds2[round].source,
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

  PairRound2 get _round => pairRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Harder to Spin',
        closing:
            'Same mass, same size, and what is left is where the material sits '
            'and where the axis is. Mass at the rim counts for everything and '
            'mass near the axis counts for almost nothing. Move the axis off '
            'the body and the transfer term, m d squared, takes over '
            'completely.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: spinInertiaBrief,
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
            'TAP THE ONE THAT TAKES MORE TO SPIN UP',
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
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Panel(
                    body: i == 0 ? r.left : r.right,
                    frame: r.frame,
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered ? null : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'same mass on both sides. the ring marks the axis',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$I = I_c + md^2$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'THAT IS THE HEAVY ONE TO SPIN'
                  : 'THE OTHER ONE',
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
    required this.body,
    required this.frame,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Body body;
  final double frame;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: BodyPainter(body: body, frame: frame, tone: tone),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
