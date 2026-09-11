import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'crack_figures.dart';
import 'lesson_brief.dart';

/// Which One Cracks First — the second item for `hardness-impact-fatigue`.
///
/// Both fracture problems in this lesson are the same formula solved for a
/// different letter, and the arithmetic in them belongs on paper. What does
/// not is the shape of the thing: a crack and a stress only mean something
/// together, the crack is under a square root so growth hurts less than it
/// looks, and toughness is what the material brings to the argument. Two
/// plates side by side is the only way to ask that without asking for a
/// number, and it is the question an inspector actually has.
class WhichCracksFirstGame extends StatefulWidget {
  const WhichCracksFirstGame({super.key});

  @override
  State<WhichCracksFirstGame> createState() => _WhichCracksFirstGameState();
}

/// Which plate runs out of toughness first as both are loaded up together.
enum Goes { left, right, together }

extension GoesWords on Goes {
  String get plain => switch (this) {
        Goes.left => 'The left one',
        Goes.right => 'The right one',
        Goes.together => 'Neither: they are in the same trouble',
      };
}

@immutable
class FirstRound {
  const FirstRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Plate left;
  final Plate right;
  final String why;
  final String source;

  /// Worked out from the two plates, never declared. Whichever is using more
  /// of its own toughness is the one that goes first.
  Goes get answer {
    final gap = (left.usedUp - right.usedUp).abs() /
        (left.usedUp > right.usedUp ? left.usedUp : right.usedUp);
    if (gap < 0.02) return Goes.together;
    return left.usedUp > right.usedUp ? Goes.left : Goes.right;
  }

  /// How far apart the two are, for a test that refuses a round nobody could
  /// call without a calculator.
  double get ratio => left.usedUp > right.usedUp
      ? left.usedUp / right.usedUp
      : right.usedUp / left.usedUp;
}

const firstRounds = <FirstRound>[
  FirstRound(
    subject: 'one crack longer than the other',
    setting:
        'The same steel, the same pull. Only the crack that was found is '
        'different.',
    left: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 5,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
    right: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 12,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
    why:
        'The longer crack, but by less than you would guess. The crack sits '
        'under a square root, so going from five millimeters to twelve, which '
        'is nearly two and a half times, drives the crack tip only about one '
        'and a half times as hard. That square root is the reason a structure '
        'can carry a crack at all and be inspected rather than condemned.',
    source: 'mat-hif-q2',
  ),
  FirstRound(
    subject: 'one pulled harder than the other',
    setting:
        'The same steel and the same crack. One plate is carrying far more '
        'load.',
    left: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 10,
      stress: 120,
      toughness: 46,
      material: 'steel',
    ),
    right: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 10,
      stress: 210,
      toughness: 46,
      material: 'steel',
    ),
    why:
        'The one pulled harder, and this time straight through: stress is not '
        'under the root, so nearly twice the stress drives the crack nearly '
        'twice as hard. Of the two things you can change about a cracked '
        'plate, taking load off it does more than any amount of hoping about '
        'the crack.',
    source: 'mat-hif-q2',
  ),
  FirstRound(
    subject: 'the same flaw in two metals',
    setting:
        'The same crack and the same pull, in steel and in aluminum. Only the '
        'toughness is different.',
    left: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 8,
      stress: 100,
      toughness: 46,
      material: 'steel',
    ),
    right: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 8,
      stress: 100,
      toughness: 24,
      material: 'aluminum',
    ),
    why:
        'The aluminum. Toughness is the one number the material brings, and '
        'it says how hard a crack tip can be driven before the crack runs. '
        'This aluminum has about half the steel\'s, so the same flaw at the '
        'same stress leaves it about half as far from going. This is why the '
        'lesson gives a table of toughness by material and not one number.',
    source: 'mat-hif-q3',
  ),
  FirstRound(
    subject: 'four times the crack at half the pull',
    setting:
        'The same steel. The right hand plate has four times the crack and is '
        'carrying half as much.',
    left: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 5,
      stress: 240,
      toughness: 46,
      material: 'steel',
    ),
    right: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 20,
      stress: 120,
      toughness: 46,
      material: 'steel',
    ),
    why:
        'Neither, and this is the round that shows what the square root '
        'means. Four times the crack is only twice the driving force, so '
        'halving the stress cancels it exactly. A big crack at a low stress '
        'and a small crack at a high one can sit at precisely the same place, '
        'which is why neither number tells you anything on its own.',
    source: 'mat-hif-q2',
  ),
  FirstRound(
    subject: 'an edge crack against an internal one',
    setting:
        'Both cracks measure six millimeters on the drawing. The same steel, '
        'the same pull.',
    left: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 6,
      stress: 220,
      toughness: 46,
      material: 'steel',
    ),
    right: Plate(
      flaw: Flaw.internal,
      crackMm: 6,
      stress: 220,
      toughness: 46,
      material: 'steel',
    ),
    why:
        'The edge crack, and by a wide margin, though the tape measure says '
        'they are the same. An edge crack has an open face behind it, so its '
        'whole six millimeters is the a, and it carries the bigger geometry '
        'factor as well. The internal one is 2a, so it goes in as three. Two '
        'separate penalties, both decided by where the crack is.',
    source: 'mat-hif-q3',
  ),
  FirstRound(
    subject: 'the longer crack that is in less trouble',
    setting:
        'The left hand crack measures ten millimeters on the drawing and the '
        'right hand one eight. The same steel, the same pull.',
    left: Plate(
      flaw: Flaw.internal,
      crackMm: 10,
      stress: 220,
      toughness: 46,
      material: 'steel',
    ),
    right: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 8,
      stress: 220,
      toughness: 46,
      material: 'steel',
    ),
    why:
        'The right hand one, which is the shorter crack on the drawing. It is '
        'an edge crack, so all eight millimeters are the a, while the '
        'internal ten goes in as five. Reading a crack off a report without '
        'reading where it is will have you worrying about the wrong plate.',
    source: 'mat-hif-q3',
  ),
];

class _WhichCracksFirstGameState extends State<WhichCracksFirstGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-cracks-first',
    chapterId: 'materials',
    total: firstRounds.length,
    sourceProblemIdOf: (round) => firstRounds[round].source,
  )..addListener(_onSession);

  Goes? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FirstRound get _round => firstRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Cracks First',
        closing:
            'A crack length on its own says nothing. What matters is the '
            'stress times the root of the crack, held against what the '
            'material can take. The root is why a crack that has doubled is '
            'not twice as dangerous, the stress is the part you can do '
            'something about, and where the crack sits decides what length '
            'even goes in.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: toughnessBrief,
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
            'WHICH ONE GOES FIRST',
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
                    plate: i == 0 ? r.left : r.right,
                    selected: _picked == (i == 0 ? Goes.left : Goes.right),
                    locked: answered,
                    isTruth: r.answer == (i == 0 ? Goes.left : Goes.right),
                    onTap: answered
                        ? null
                        : () => setState(
                            () => _picked = i == 0 ? Goes.left : Goes.right),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$K = Y\sigma\sqrt{\pi a}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Goes.together.plain,
            selected: _picked == Goes.together,
            locked: answered,
            isTruth: r.answer == Goes.together,
            onTap: answered
                ? null
                : () => setState(() => _picked = Goes.together),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
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
    required this.plate,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Plate plate;
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
          height: 190,
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
                painter: PlatePainter(plate: plate),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
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
