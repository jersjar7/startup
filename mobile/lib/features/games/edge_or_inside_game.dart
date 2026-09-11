import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'crack_figures.dart';
import 'lesson_brief.dart';

/// Edge or Inside — the first item for `hardness-impact-fatigue`.
///
/// The fracture formula is one line and both of this lesson's fracture
/// problems are lost in the same place: the two numbers you put into it are
/// decided by WHERE the crack is, not by the arithmetic. An edge crack takes
/// a geometry factor of 1.1 and its whole depth. An internal crack takes 1.0
/// and half of its length. Getting either wrong moves the answer by more than
/// any rounding ever will, and both are read off a picture, which is the part
/// worth doing on a phone.
class EdgeOrInsideGame extends StatefulWidget {
  const EdgeOrInsideGame({super.key});

  @override
  State<EdgeOrInsideGame> createState() => _EdgeOrInsideGameState();
}

/// The two decisions travel together, so they are chosen together.
enum Pick { sharpWhole, sharpHalf, flatWhole, flatHalf }

extension PickParts on Pick {
  double get y =>
      this == Pick.sharpWhole || this == Pick.sharpHalf ? 1.1 : 1.0;

  bool get half => this == Pick.sharpHalf || this == Pick.flatHalf;
}

@immutable
class CrackRound {
  const CrackRound({
    required this.subject,
    required this.plate,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final Plate plate;

  /// The four readings of the same picture, in the order they are offered.
  final List<Pick> options;
  final Pick answer;
  final String why;
  final String source;

  /// What each choice puts into the formula, with this round's own numbers.
  String labelFor(Pick pick) {
    final mm = pick.half ? plate.crackMm / 2 : plate.crackMm;
    final shown =
        mm == mm.roundToDouble() ? mm.round().toString() : mm.toStringAsFixed(1);
    return 'Y = ${pick.y}   a = $shown mm';
  }
}

const crackRounds = <CrackRound>[
  CrackRound(
    subject: 'the lesson\'s steel plate',
    plate: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 10,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
    options: [Pick.sharpWhole, Pick.flatWhole, Pick.sharpHalf, Pick.flatHalf],
    answer: Pick.sharpWhole,
    why:
        'An edge crack, so 1.1, and the whole ten millimeters. There is no '
        'halving here: halving belongs to internal cracks, where the length '
        'you can see is twice the a the formula wants. One more step before '
        'it goes in: ten millimeters is 0.010 meters, and leaving it in '
        'millimeters puts the answer out by a factor of more than thirty.',
    source: 'mat-hif-q2',
  ),
  CrackRound(
    subject: 'a flaw found by ultrasound, well inside the plate',
    plate: Plate(
      flaw: Flaw.internal,
      crackMm: 10,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
    options: [Pick.flatHalf, Pick.sharpWhole, Pick.flatWhole, Pick.sharpHalf],
    answer: Pick.flatHalf,
    why:
        'Internal, so the factor is 1.0 and the a is HALF the length you can '
        'see: five millimeters. An internal crack is described as being of '
        'length 2a for exactly this reason. Using the whole ten would say the '
        'plate is in far more trouble than it is.',
    source: 'mat-hif-q3',
  ),
  CrackRound(
    subject: 'the same plate, inspected a year later',
    plate: Plate(
      flaw: Flaw.internal,
      crackMm: 24,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
    options: [Pick.sharpHalf, Pick.flatHalf, Pick.sharpWhole, Pick.flatWhole],
    answer: Pick.flatHalf,
    why:
        'Still internal, so still 1.0 and still half: twelve millimeters. '
        'Growing does not change where a crack is. What it changes is how '
        'much of the toughness is spent, and since the a is under a square '
        'root, a crack that has grown from ten to twenty four is not twice as '
        'dangerous but about one and a half times.',
    source: 'mat-hif-q3',
  ),
  CrackRound(
    subject: 'the aluminum component, cracked from the far edge',
    plate: Plate(
      flaw: Flaw.edgeRight,
      crackMm: 6,
      stress: 200,
      toughness: 24,
      material: 'aluminum',
    ),
    options: [Pick.flatWhole, Pick.sharpHalf, Pick.sharpWhole, Pick.flatHalf],
    answer: Pick.sharpWhole,
    why:
        'An edge is an edge, whichever side it is on: 1.1, and the whole six '
        'millimeters. What has changed here is the material, not the '
        'geometry. Aluminum has about half the toughness of this steel, so '
        'the same crack at the same stress is much nearer the edge of going.',
    source: 'mat-hif-q3',
  ),
  CrackRound(
    subject: 'a small internal flaw',
    plate: Plate(
      flaw: Flaw.internal,
      crackMm: 5,
      stress: 260,
      toughness: 46,
      material: 'steel',
    ),
    options: [Pick.sharpWhole, Pick.flatHalf, Pick.flatWhole, Pick.sharpHalf],
    answer: Pick.flatHalf,
    why:
        'Internal: 1.0, and half of five is two and a half millimeters. Small '
        'flaws are where the halving does the most damage to an answer, '
        'because the numbers are small enough that nobody notices the factor '
        'of two until the stress comes out well over what the plate can '
        'really take.',
    source: 'mat-hif-q3',
  ),
  CrackRound(
    subject: 'a crack that has run in from the edge',
    plate: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 20,
      stress: 150,
      toughness: 46,
      material: 'steel',
    ),
    options: [Pick.flatHalf, Pick.sharpHalf, Pick.flatWhole, Pick.sharpWhole],
    answer: Pick.sharpWhole,
    why:
        'Edge again: 1.1 and the whole twenty millimeters. Notice the plate '
        'is at a lower stress than the earlier ones and is still in more '
        'trouble than any of them, because the crack has grown so much. A '
        'crack length and a stress only mean something together.',
    source: 'mat-hif-q2',
  ),
];

class _EdgeOrInsideGameState extends State<EdgeOrInsideGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'edge-or-inside',
    chapterId: 'materials',
    total: crackRounds.length,
    sourceProblemIdOf: (round) => crackRounds[round].source,
  )..addListener(_onSession);

  Pick? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CrackRound get _round => crackRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Edge or Inside',
        closing:
            'Where the crack is decides both numbers. From an edge: the '
            'factor is 1.1 and the a is the whole depth. Inside the plate: '
            'the factor is 1.0 and the a is half the length, because an '
            'internal crack is described as 2a. Then convert to meters before '
            'anything else happens.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: crackBrief,
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
            'WHAT GOES INTO THE FORMULA',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$K_{IC} = Y\sigma\sqrt{\pi a}$',
              style: const TextStyle(fontSize: 18, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: PlatePainter(plate: r.plate),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in r.options) ...[
            _Choice(
              label: r.labelFor(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'BOTH NUMBERS RIGHT'
                  : 'ONE OF THE TWO IS WRONG',
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
            style: AppTheme.mono(size: 14, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
