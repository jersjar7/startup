import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'statics_figures.dart';

/// Which Ones Turn It — the third item for `force-systems-resultants`.
///
/// The lesson's warning is about sign convention: pick one direction as
/// positive and hold it for the whole problem. That is not advice about
/// bookkeeping, it is a claim that every force on a body has a rotational
/// sense you can read off the picture before any arithmetic happens.
///
/// So no magnitudes are given and nothing is summed. Every force on the board
/// is asked one question, which way does this one turn the body, and the
/// answer is the set that turns it clockwise. Two rounds contain a force whose
/// line runs through the pin, which turns it neither way and has to be left
/// alone. One is a couple, where both forces turn it the same way, which is
/// the whole reason a couple has a moment at all.
class WhichOnesTurnItGame extends StatefulWidget {
  const WhichOnesTurnItGame({super.key});

  @override
  State<WhichOnesTurnItGame> createState() => _WhichOnesTurnItGameState();
}

@immutable
class SenseRound {
  const SenseRound({
    required this.subject,
    required this.setting,
    required this.scene,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Scene scene;
  final String why;
  final String source;

  /// The z moment of one force about the pin, in the round's own units. Sign
  /// is all that is used: negative turns the body clockwise on a figure drawn
  /// with y upward.
  double momentOf(int i) {
    final f = scene.forces[i];
    final r = f.at - scene.pivot;
    return r.dx * f.dir.dy - r.dy * f.dir.dx;
  }

  /// Worked out from the geometry rather than declared beside it.
  Set<int> get answer => {
        for (var i = 0; i < scene.forces.length; i++)
          if (momentOf(i) < -0.0001) i,
      };

  String senseOf(int i) {
    final m = momentOf(i);
    if (m.abs() < 0.0001) return 'neither, its line runs through the pin';
    return m < 0 ? 'clockwise' : 'counterclockwise';
  }
}

/// The row under every figure, for a board where nothing turns it that way.
const nothingTurnsIt = 'None of them turns it that way';

const senseRounds = <SenseRound>[
  SenseRound(
    subject: 'a cantilever off a pinned end',
    setting:
        'The beam is pinned at the left end. Three loads sit along it and none '
        'of their sizes is given, which does not matter for this question.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(8, 0)],
      ],
      pivot: Offset(0, 0),
      forces: [
        StaticForce(Offset(3, 0), Offset(0, -1), 'A', lineOfAction: false),
        StaticForce(Offset(6, 0), Offset(0, 1), 'B', lineOfAction: false),
        StaticForce(Offset(7.6, 0), Offset(0, 1), 'C', lineOfAction: false),
      ],
    ),
    why:
        'Only A. Everything sits to the right of the pin, so a downward force '
        'rolls the beam clockwise and an upward one rolls it back. Which side '
        'of the pin a force sits on matters exactly as much as which way it '
        'points.',
    source: 'stat-fsr-q3',
  ),
  SenseRound(
    subject: 'a bar pinned in the middle',
    setting:
        'The pin is halfway along and there is a force on either side of it.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(10, 0)],
      ],
      pivot: Offset(5, 0),
      forces: [
        StaticForce(Offset(1, 0), Offset(0, -1), 'A', lineOfAction: false),
        StaticForce(Offset(9, 0), Offset(0, -1), 'B', lineOfAction: false),
        StaticForce(Offset(2.6, 0), Offset(0, 1), 'C', lineOfAction: false),
      ],
    ),
    why:
        'B and C. They point in opposite directions and turn the bar the same '
        'way, because they are on opposite sides of the pin. A is the mirror '
        'of B and turns it the other way. Reading the arrow without reading '
        'the side gets half of these wrong.',
    source: 'stat-fsr-q3',
  ),
  SenseRound(
    subject: 'a mast pinned at its base',
    setting:
        'Three forces on a vertical mast, pinned where it meets the ground.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(0, 6)],
      ],
      pivot: Offset(0, 0),
      forces: [
        StaticForce(Offset(0, 6), Offset(1, 0), 'A', lineOfAction: false),
        StaticForce(Offset(0, 6), Offset(0, 1), 'B'),
        StaticForce(Offset(0, 3), Offset(-1, 0), 'C', lineOfAction: false),
      ],
    ),
    why:
        'Only A. B pulls straight up the mast and its line runs through the '
        'pin, so it turns nothing at all however hard it pulls. C pushes the '
        'other way from A and turns the mast counterclockwise.',
    source: 'stat-fsr-q3',
  ),
  SenseRound(
    subject: 'an L bracket on a wall',
    setting:
        'The bracket rises and then reaches out. It is pinned at the bottom '
        'and loaded at two places.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(0, 5), Offset(4, 5)],
      ],
      pivot: Offset(0, 0),
      forces: [
        StaticForce(Offset(4, 5), Offset(0, -1), 'A', lineOfAction: false),
        StaticForce(Offset(0, 3), Offset(1, 0), 'B', lineOfAction: false),
        StaticForce(Offset(4, 5), Offset(0, 1), 'C', lineOfAction: false),
      ],
    ),
    why:
        'A and B. A hangs off the end of the reach and rolls the bracket over. '
        'B pushes the upright sideways partway up, which does the same thing '
        'from somewhere else entirely. C is A turned around and it lifts the '
        'corner back.',
    source: 'stat-fsr-q3',
  ),
  SenseRound(
    subject: 'a couple on a bar',
    setting:
        'Two equal and opposite forces on the same bar, with the pin sitting '
        'between them.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(10, 0)],
      ],
      pivot: Offset(5, 0),
      forces: [
        StaticForce(Offset(3, 0), Offset(0, 1), 'A', lineOfAction: false),
        StaticForce(Offset(7, 0), Offset(0, -1), 'B', lineOfAction: false),
      ],
    ),
    why:
        'Both of them. Opposite directions on opposite sides of the pin come '
        'to the same sense, which is what a couple IS: two forces that cancel '
        'as forces and add as a turn. Move the pin anywhere on the bar and the '
        'answer does not change.',
    source: 'stat-fsr-q3',
  ),
  SenseRound(
    subject: 'a sign post pushed the other way',
    setting:
        'Three forces on a post pinned at the ground, and the question is the '
        'same one.',
    scene: Scene(
      members: [
        [Offset(0, 0), Offset(0, 5)],
      ],
      pivot: Offset(0, 0),
      forces: [
        StaticForce(Offset(0, 5), Offset(-1, 0), 'A', lineOfAction: false),
        StaticForce(Offset(0, 5), Offset(0, 1), 'B'),
        StaticForce(Offset(0, 2), Offset(-1, 0), 'C', lineOfAction: false),
      ],
    ),
    why:
        'None of them. Both of the sideways forces push the same way and both '
        'turn it counterclockwise, and the one running up the post turns it '
        'neither way. An empty answer is a real answer, and being sure of it '
        'is worth as much as spotting the ones that do.',
    source: 'stat-fsr-q3',
  ),
];

class _WhichOnesTurnItGameState extends State<WhichOnesTurnItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-ones-turn-it',
    chapterId: 'statics',
    total: senseRounds.length,
    sourceProblemIdOf: (round) => senseRounds[round].source,
  )..addListener(_onSession);

  final _picked = <int>{};
  bool _none = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SenseRound get _round => senseRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Ones Turn It',
        closing:
            'Which way a force turns a body depends on which side of the point '
            'it sits as much as on which way it points. A force aimed through '
            'the point turns it neither way. And two opposite forces on '
            'opposite sides turn it the same way, which is why a couple is a '
            'turn with no push behind it.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer;

    return BoardShell(
      session: _session,
      brief: senseBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked.clear();
                _none = false;
              });
              _session.next();
            }
          : (_picked.isEmpty && !_none
                ? null
                : () => _session.submit(
                    ok: _none
                        ? truth.isEmpty
                        : _picked.length == truth.length &&
                            _picked.containsAll(truth),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHICH ONES TURN IT CLOCKWISE',
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
            'tap every arrow that does, which may be none',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          _Figure(
            scene: r.scene,
            picked: _none ? const <int>{} : _picked,
            locked: answered,
            truths: truth,
            onTap: answered
                ? null
                : (i) => setState(() {
                      _none = false;
                      if (!_picked.add(i)) _picked.remove(i);
                    }),
          ),
          const SizedBox(height: 8),
          _NoneRow(
            selected: _none,
            locked: answered,
            isTruth: truth.isEmpty,
            onTap: answered
                ? null
                : () => setState(() {
                      _picked.clear();
                      _none = !_none;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'EACH ONE',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < r.scene.forces.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${r.scene.forces[i].label}   ${r.senseOf(i)}',
                  style: AppTheme.code(size: 12),
                ),
              ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SET' : 'NOT THAT SET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.scene,
    required this.picked,
    required this.locked,
    required this.truths,
    required this.onTap,
  });

  final Scene scene;
  final Set<int> picked;
  final bool locked;
  final Set<int> truths;
  final void Function(int)? onTap;

  static const _height = 250.0;

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
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MomentPainter(
                        scene: scene,
                        mode: SceneMode.forces,
                        selected: null,
                        chosen: picked,
                        locked: locked,
                        truth: -1,
                        truths: truths,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < scene.forces.length; i++)
                    _zone(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _zone(int i, Size size) {
    final f = scene.forces[i];
    final origin = scene.toScreen(f.at, size);
    final len = f.dir.distance;
    final unit = Offset(f.dir.dx / len, -f.dir.dy / len);
    // Centerd on the arrow's middle rather than on where it is applied, so
    // that two forces at the same point do not share one target.
    final center = origin + unit * 30;
    const box = 52.0;

    return Positioned(
      key: ValueKey('force-$i'),
      left: center.dx - box / 2,
      top: center.dy - box / 2,
      width: box,
      height: box,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

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
      key: const ValueKey('nothing-turns'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            nothingTurnsIt,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
