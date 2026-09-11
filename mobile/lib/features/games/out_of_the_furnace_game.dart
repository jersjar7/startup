import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'thermal_figures.dart';

/// Out of the Furnace — the second item for
/// `thermal-processing-phase-diagrams`.
///
/// The lesson's processing problem is not arithmetic at all: it describes a
/// heat treatment in a sentence and asks what comes out. That sentence is
/// really a shape, temperature against time, and the rule for reading it is
/// two questions long: did it get hot enough to be austenite, and how fast
/// did it come down from there. So the shape is drawn and the rule is applied
/// to it, which is the same reasoning the exam wants and none of the words
/// that usually carry it.
class OutOfTheFurnaceGame extends StatefulWidget {
  const OutOfTheFurnaceGame({super.key});

  @override
  State<OutOfTheFurnaceGame> createState() => _OutOfTheFurnaceGameState();
}

@immutable
class FurnaceRound {
  const FurnaceRound({
    required this.subject,
    required this.setting,
    required this.cool,
    required this.options,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Cool cool;

  /// What is offered, in the order it is offered.
  final List<Comes> options;
  final String why;
  final String source;

  Comes get answer => cool.outcome;
}

/// A quench: up to 900, held, and down to room temperature in moments.
const _waterQuench = Cool(
  legs: [
    Offset(0, 20),
    Offset(0.8, 900),
    Offset(2, 900),
    Offset(2.1, 20),
    Offset(2.6, 20),
  ],
  outcome: Comes.hardBrittle,
);

/// The same trip up, and most of a day coming down.
const _furnaceCool = Cool(
  legs: [
    Offset(0, 20),
    Offset(0.8, 900),
    Offset(2, 900),
    Offset(9, 20),
    Offset(9.6, 20),
  ],
  outcome: Comes.softDuctile,
);

/// Quenched, then put back in at four hundred and held there.
const _tempered = Cool(
  legs: [
    Offset(0, 20),
    Offset(0.8, 900),
    Offset(2, 900),
    Offset(2.1, 20),
    Offset(2.7, 400),
    Offset(4.4, 400),
    Offset(5.4, 20),
    Offset(6, 20),
  ],
  outcome: Comes.hardTough,
);

/// Heated to five hundred, which is not austenite, and quenched from there.
const _tooCool = Cool(
  legs: [
    Offset(0, 20),
    Offset(0.8, 500),
    Offset(2, 500),
    Offset(2.1, 20),
    Offset(2.6, 20),
  ],
  outcome: Comes.unchanged,
);

/// An oil quench: slower than water, still far too fast to transform.
const _oilQuench = Cool(
  legs: [
    Offset(0, 20),
    Offset(0.8, 900),
    Offset(2, 900),
    Offset(2.5, 20),
    Offset(3, 20),
  ],
  outcome: Comes.hardBrittle,
);

/// Cooled slowly down through the transformation, and only then quenched.
const _lateQuench = Cool(
  legs: [
    Offset(0, 20),
    Offset(0.8, 900),
    Offset(2, 900),
    Offset(6, 600),
    Offset(6.1, 20),
    Offset(6.6, 20),
  ],
  outcome: Comes.softDuctile,
);

const furnaceRounds = <FurnaceRound>[
  FurnaceRound(
    subject: 'straight into the water',
    setting:
        'Held at nine hundred until it is all austenite, then dropped into '
        'cold water. It is at room temperature in seconds.',
    cool: _waterQuench,
    options: [
      Comes.softDuctile,
      Comes.hardBrittle,
      Comes.hardTough,
      Comes.unchanged
    ],
    why:
        'Martensite: hard and brittle. The carbon has nowhere to go. Forming '
        'the equilibrium mixture needs atoms to move, moving takes time, and '
        'this drop gives them none, so the structure is trapped mid change. '
        'That is the lesson\'s whole rule, and it is why a quenched part is '
        'hard enough to be useful and brittle enough to be dangerous.',
    source: 'mat-tpd-q2',
  ),
  FurnaceRound(
    subject: 'left in the furnace overnight',
    setting:
        'The same nine hundred, and then the furnace is simply switched off. '
        'It takes most of a day to reach room temperature.',
    cool: _furnaceCool,
    options: [
      Comes.hardBrittle,
      Comes.unchanged,
      Comes.softDuctile,
      Comes.hardTough
    ],
    why:
        'Ferrite and cementite, the soft and ductile pair, which together are '
        'pearlite. All the time in the world means the atoms do move, so the '
        'steel arrives at the structure the phase diagram says it should '
        'have. Same steel, same top temperature, opposite properties: the '
        'rate is the whole story.',
    source: 'mat-tpd-q2',
  ),
  FurnaceRound(
    subject: 'quenched, then put back in',
    setting:
        'Quenched from nine hundred, then reheated to four hundred, held '
        'there a while and cooled.',
    cool: _tempered,
    options: [
      Comes.hardTough,
      Comes.hardBrittle,
      Comes.softDuctile,
      Comes.unchanged
    ],
    why:
        'Tempered martensite: it keeps most of the hardness and loses most of '
        'the brittleness. Four hundred is nowhere near austenite, so nothing '
        'transforms back; the reheat simply lets the trapped structure relax. '
        'Almost nothing is used in the as quenched state, so this second trip '
        'through the furnace is the normal end of the story.',
    source: 'mat-tpd-q2',
  ),
  FurnaceRound(
    subject: 'never got hot enough',
    setting:
        'Heated to five hundred, held, and quenched into water just as hard '
        'as the first one was.',
    cool: _tooCool,
    options: [
      Comes.hardBrittle,
      Comes.softDuctile,
      Comes.unchanged,
      Comes.hardTough
    ],
    why:
        'Nothing to speak of. Quenching only makes martensite if there is '
        'austenite to trap, and austenite does not exist until about seven '
        'hundred and twenty seven degrees. Five hundred is a warm piece of '
        'the same steel it was before. The speed of a quench is only half the '
        'rule: it has to start from up in the shaded band.',
    source: 'mat-tpd-q2',
  ),
  FurnaceRound(
    subject: 'quenched into oil instead',
    setting:
        'Nine hundred again, then into oil. Oil pulls the heat out more '
        'slowly than water, but the part is still cold within the minute.',
    cool: _oilQuench,
    options: [
      Comes.unchanged,
      Comes.hardTough,
      Comes.hardBrittle,
      Comes.softDuctile
    ],
    why:
        'Martensite again. What matters is the RATE, not what the tank is '
        'full of: a minute is still far too quick for the atoms to rearrange. '
        'Oil is chosen over water for awkward shapes because a gentler quench '
        'cracks fewer of them, and it is still a quench.',
    source: 'mat-tpd-q2',
  ),
  FurnaceRound(
    subject: 'cooled slowly first, quenched afterwards',
    setting:
        'From nine hundred it is cooled slowly over hours to six hundred, and '
        'only then dropped into water.',
    cool: _lateQuench,
    options: [
      Comes.hardBrittle,
      Comes.hardTough,
      Comes.unchanged,
      Comes.softDuctile
    ],
    why:
        'Soft and ductile, and this is the round worth remembering. By six '
        'hundred the steel has already crossed the line slowly and done its '
        'transforming: there is no austenite left to trap, so the quench '
        'comes too late to do anything. What decides the structure is how '
        'fast it went THROUGH the change, not how it was handled afterwards.',
    source: 'mat-tpd-q2',
  ),
];

class _OutOfTheFurnaceGameState extends State<OutOfTheFurnaceGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'out-of-the-furnace',
    chapterId: 'materials',
    total: furnaceRounds.length,
    sourceProblemIdOf: (round) => furnaceRounds[round].source,
  )..addListener(_onSession);

  Comes? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FurnaceRound get _round => furnaceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Out of the Furnace',
        closing:
            'Two questions read any heat treatment. Did it get up into the '
            'austenite band, and how fast did it come down through the '
            'change? Fast from up there is martensite, hard and brittle. Slow '
            'is ferrite and cementite, soft and ductile. A reheat afterwards '
            'is tempering, which keeps the hardness and takes away the worst '
            'of the brittleness.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: furnaceBrief,
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
            'WHAT COMES OUT OF THIS',
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
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: CoolPainter(cool: r.cool),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'time is not to scale between rounds. read the slope, not the width',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (final option in r.options) ...[
            _Choice(
              label: option.plain,
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
                  ? 'THAT IS WHAT COMES OUT'
                  : 'NOT FROM THIS ONE',
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
