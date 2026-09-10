import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'friction_figures.dart';
import 'lesson_brief.dart';

/// Is It About to Move — the first item for `friction`.
///
/// The lesson's warning callout is the whole of this one, and it is the most
/// expensive misreading in the chapter: friction is not a number you compute,
/// it is a CEILING. It sits at whatever value holds the thing still, anywhere
/// from nothing up to the maximum, and it only reaches the maximum at the
/// instant motion is impending.
///
/// So there is no arithmetic here at all. A situation is drawn and described,
/// and the answer is how hard friction is working right now. What decides it
/// is whether the words have told you the thing is on the verge, which is
/// exactly what has to be read off an exam problem before any formula is
/// worth writing down.
class IsItAboutToMoveGame extends StatefulWidget {
  const IsItAboutToMoveGame({super.key});

  @override
  State<IsItAboutToMoveGame> createState() => _IsItAboutToMoveGameState();
}

@immutable
class VergeRound {
  const VergeRound({
    required this.subject,
    required this.setting,
    required this.rig,
    required this.push,
    required this.pushLabel,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Rig rig;

  /// What is being applied along the surface, in newtons. On a ramp with
  /// nobody touching it this is zero and gravity does the asking instead.
  final double push;

  final String? pushLabel;
  final String why;
  final String source;

  /// Everything trying to slide it: a hand on it, and the part of its own
  /// weight that runs down the slope.
  double get demand => push + rig.slideDemand;

  /// Worked out by holding the demand against the ceiling, never declared
  /// beside the round.
  Grip get answer {
    if (demand < 0.5) return Grip.none;
    if ((demand - rig.ceiling).abs() < 1.0) return Grip.atTheLimit;
    return Grip.matching;
  }
}

const vergeRounds = <VergeRound>[
  VergeRound(
    subject: 'a crate that is not going anywhere',
    setting:
        'A crate stands on a level concrete floor. Someone leans on it with a '
        'steady shove and it does not budge. It is nowhere near going over.',
    rig: Rig(weight: 500, mu: 0.40),
    push: 120,
    pushLabel: 'a shove',
    why:
        'Just enough to hold it, and no more than that. Friction here is '
        'exactly as big as the shove, because if it were any bigger the crate '
        'would slide BACKWARD, and if it were any smaller it would slide '
        'forward. The floor could give a great deal more, and it is not being '
        'asked to.',
    source: 'stat-fri-q1',
  ),
  VergeRound(
    subject: 'the same crate, on the point of going',
    setting:
        'They lean harder and harder. At one particular push the crate is just '
        'about to break away, and one more newton would start it moving.',
    rig: Rig(weight: 500, mu: 0.40),
    push: 200,
    pushLabel: 'harder still',
    why:
        'The most the floor can give, and this is the ONLY moment it is. '
        'Impending motion is what puts friction at its ceiling, which is why '
        'the maximum force before sliding is the one thing this arrangement '
        'can be asked for. Read the words: about to move means use the '
        'maximum.',
    source: 'stat-fri-q1',
  ),
  VergeRound(
    subject: 'a crate nobody is touching',
    setting:
        'The same crate on the same floor. Everyone has gone home. Nothing is '
        'pushing it in any direction.',
    rig: Rig(weight: 500, mu: 0.40),
    push: 0,
    pushLabel: null,
    why:
        'Nothing at all. There is no tendency to slide, so there is nothing '
        'for friction to resist and it sits at zero. The floor is still '
        'perfectly capable of two hundred newtons. Capability is not force, '
        'and the formula gives you the first, not the second.',
    source: 'stat-fri-q1',
  ),
  VergeRound(
    subject: 'a block sitting on a gentle slope',
    setting:
        'A block rests on a ramp that is not tilted very far. It has been '
        'sitting there all morning and shows no sign of moving.',
    rig: Rig(weight: 800, mu: 0.60, rampDeg: 20),
    push: 0,
    pushLabel: null,
    why:
        'Just enough to hold it. Gravity is asking for the part of the weight '
        'that runs down the slope and friction is quietly matching it. This '
        'ramp could hold a good deal steeper before it let go, so nothing here '
        'is at any limit.',
    source: 'stat-fri-q3',
  ),
  VergeRound(
    subject: 'the same slope, tilted until it lets go',
    setting:
        'The ramp is jacked up a degree at a time. At one angle the block '
        'trembles and is on the point of sliding down.',
    rig: Rig(weight: 800, mu: 0.60, rampDeg: 30.9638),
    push: 0,
    pushLabel: null,
    why:
        'The most it can give. This angle has a name, the angle of repose, and '
        'it is where the slope has finally asked for everything the surface '
        'has. It does not depend on the weight one bit: a block twice as heavy '
        'lets go at exactly the same tilt.',
    source: 'stat-fri-q3',
  ),
  VergeRound(
    subject: 'a crate with something heavy stacked on it',
    setting:
        'Back on the level floor, and a second crate has been stacked on top '
        'of the first. Together they are far heavier. Still nobody is pushing.',
    rig: Rig(weight: 1400, mu: 0.40),
    push: 0,
    pushLabel: null,
    why:
        'Still nothing. All that weight has raised the ceiling and changed the '
        'friction not at all, because friction answers what is asked of it and '
        'nothing is being asked. Reaching for the formula whenever a big '
        'normal force appears is the habit this round is here to break.',
    source: 'stat-fri-q1',
  ),
];

class _IsItAboutToMoveGameState extends State<IsItAboutToMoveGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'is-it-about-to-move',
    chapterId: 'statics',
    total: vergeRounds.length,
    sourceProblemIdOf: (round) => vergeRounds[round].source,
  )..addListener(_onSession);

  Grip? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  VergeRound get _round => vergeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Is It About to Move',
        closing:
            'Friction is a ceiling, not a value. It sits at whatever holds the '
            'thing still and reaches its maximum only at the instant motion is '
            'impending. Before writing the formula down, find the words in the '
            'problem that say the thing is about to move. If they are not '
            'there, the maximum is not the answer.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: ceilingBrief,
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
            'HOW HARD IS FRICTION WORKING',
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: BlockPainter(
                    rig: r.rig,
                    showPush: r.push > 0,
                    pushLabel: r.pushLabel,
                    grip: answered ? r.answer : null,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Grip.values) ...[
            _GripButton(
              key: ValueKey('grip-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Grip.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT SITS' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _GripButton extends StatelessWidget {
  const _GripButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Grip option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Grip.matching: 'Just enough to hold it',
    Grip.atTheLimit: 'The most this surface can give',
    Grip.none: 'Nothing at all',
  };

  static const _notes = {
    Grip.matching: 'below the ceiling, with room to spare',
    Grip.atTheLimit: 'at the ceiling, on the verge of moving',
    Grip.none: 'nothing is trying to slide it',
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

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 36,
                child: CustomPaint(painter: _GripGlyph(option)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _titles[option]!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _notes[option]!,
                      style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A block on a floor with the friction arrow drawn at the length this answer
/// means, so the three choices can be told apart without reading them.
class _GripGlyph extends CustomPainter {
  const _GripGlyph(this.option);

  final Grip option;

  @override
  void paint(Canvas canvas, Size size) {
    final floor = size.height - 8;
    final ink = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.3;
    canvas.drawLine(Offset(2, floor), Offset(size.width - 2, floor), ink);
    for (var x = 6.0; x < size.width - 2; x += 8) {
      canvas.drawLine(Offset(x, floor), Offset(x - 5, floor + 6), ink);
    }

    final box = Rect.fromLTWH(size.width / 2 - 13, floor - 22, 26, 22);
    canvas.drawRect(box, Paint()..color = AppColors.cream);
    canvas.drawRect(
      box,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    if (option == Grip.none) return;

    // The arrow runs along the floor, from under the block backward.
    final full = option == Grip.atTheLimit ? 20.0 : 11.0;
    final root = Offset(size.width / 2 - 13, floor - 5);
    final tip = root - Offset(full, 0);
    final paint = Paint()
      ..color = AppColors.forest
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(root, tip, paint);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + 6, tip.dy - 3.6)
        ..lineTo(tip.dx + 6, tip.dy + 3.6)
        ..close(),
      Paint()..color = AppColors.forest,
    );
  }

  @override
  bool shouldRepaint(_GripGlyph old) => old.option != option;
}
