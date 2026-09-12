import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rc_figures.dart';

/// Stirrups or Not — the second item for `rc-flexure-shear`.
///
/// Working out what the concrete can carry is arithmetic and belongs on
/// paper. What the exam is really asking is which of four answers the
/// section has landed on, and those four are a ladder: under half of what
/// the concrete can do, nothing is needed; up to all of it, minimum
/// stirrups; past it, stirrups worked out for the difference; and past four
/// times the concrete, no spacing will save the section and it has to grow.
class StirrupsOrNotGame extends StatefulWidget {
  const StirrupsOrNotGame({super.key});

  @override
  State<StirrupsOrNotGame> createState() => _StirrupsOrNotGameState();
}

@immutable
class ShearRound {
  const ShearRound({
    required this.subject,
    required this.asked,
    required this.check,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final ShearCheck check;
  final String why;
  final String source;

  /// The numbers decide, so a round cannot disagree with its own figure.
  Stirrups get answer => check.verdict;

  static String label(Stirrups which) => switch (which) {
        Stirrups.none => 'No stirrups at all',
        Stirrups.minimum => 'Minimum stirrups only',
        Stirrups.designed => 'Stirrups worked out for the difference',
        Stirrups.tooSmall => 'None will do: the section has to grow',
      };
}

const shearRounds = <ShearRound>[
  ShearRound(
    subject: 'the lesson\'s own beam',
    asked:
        'The concrete in this beam can carry 26 kips of shear on its own and '
        'the factored shear at the section is 22 kips. What does the section '
        'need?',
    check: ShearCheck(concrete: 26.3, demand: 22),
    why:
        'Stirrups worked out for the difference. The concrete is worth 26 '
        'kips but only three quarters of that may be leaned on, which is 19.7 '
        'kips, and the demand is past it. The stirrups then carry what is '
        'left over once the demand has been divided by the same three '
        'quarters. This is the lesson\'s own problem and the answer is close: '
        'reading the ladder the wrong way round here costs the whole mark.',
    source: 'str-rfs-q2',
  ),
  ShearRound(
    subject: 'a lightly loaded end',
    asked:
        'Same beam, same concrete, but the factored shear here is only 7 '
        'kips. Now what?',
    check: ShearCheck(concrete: 26.3, demand: 7),
    why:
        'Nothing at all. Below HALF of what may be leaned on, which is about '
        '9.9 kips here, the code asks for no stirrups. Notice that the '
        'threshold is half of the usable capacity and not half of the '
        'concrete: the resistance factor comes first, then the halving.',
    source: 'str-rfs-q2',
  ),
  ShearRound(
    subject: 'in between',
    asked: 'And if the factored shear at the section were 15 kips?',
    check: ShearCheck(concrete: 26.3, demand: 15),
    why:
        'Minimum stirrups. Between half the usable capacity and all of it, '
        'the concrete can carry the shear but the code will not let you trust '
        'it alone: a nominal cage goes in to hold the crack together and to '
        'give the beam some warning before it fails. Nothing has to be '
        'designed here, but something has to be there.',
    source: 'str-rfs-q2',
  ),
  ShearRound(
    subject: 'a heavily loaded beam',
    asked:
        'A bigger beam whose concrete is worth 42 kips, carrying a factored '
        'shear of 70 kips at the section. What does it need?',
    check: ShearCheck(concrete: 42.5, demand: 70),
    why:
        'Stirrups worked out for the difference, and this is the lesson\'s '
        'hard problem. The demand over the factor comes to 93 kips, the '
        'concrete carries 42 of them, and the stirrups are sized for the '
        'remaining 51, which sets the spacing. Plenty to do, but the section '
        'itself is nowhere near its limit.',
    source: 'str-rfs-q3',
  ),
  ShearRound(
    subject: 'past what any cage can hold',
    asked:
        'The same 42 kip concrete, but now the factored shear is 200 kips. '
        'Can it be stirruped?',
    check: ShearCheck(concrete: 42.5, demand: 200),
    why:
        'No: the section has to grow. There is a ceiling on what stirrups may '
        'be asked to carry, four times the concrete\'s own share, and past it '
        'the concrete between the bars crushes however close together they '
        'are put. Reaching for a tighter spacing here is the wrong instinct, '
        'and it is what the exam is checking with a number this large.',
    source: 'str-rfs-q3',
  ),
  ShearRound(
    subject: 'right at the line',
    asked:
        'A section where the factored shear lands exactly on what may be '
        'leaned on, 19.7 kips against a concrete worth 26.3. What does it '
        'need?',
    check: ShearCheck(concrete: 26.3, demand: 19.725),
    why:
        'Minimum stirrups. Landing exactly on the threshold puts you in the '
        'band below it, not above: designed stirrups are wanted only once the '
        'demand PASSES what the concrete can be trusted with. On the exam the '
        'numbers rarely land on the line, but knowing which side the line '
        'belongs to is what tells you the bands are three and not two.',
    source: 'str-rfs-q2',
  ),
];

class _StirrupsOrNotGameState extends State<StirrupsOrNotGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stirrups-or-not',
    chapterId: 'structural',
    total: shearRounds.length,
    sourceProblemIdOf: (round) => shearRounds[round].source,
  )..addListener(_onSession);

  Stirrups? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ShearRound get _round => shearRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stirrups or Not',
        closing:
            'Four answers on one ladder. Under half of what the concrete may '
            'be leaned on, nothing. Up to all of it, a minimum cage to hold '
            'the crack and give some warning. Past it, stirrups sized for the '
            'difference. And past four times the concrete\'s own share, no '
            'spacing will do and the section has to grow. The resistance '
            'factor comes off the concrete before any of those comparisons, '
            'never after.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: stirrupBrief,
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
            'WHAT DOES THE SECTION NEED',
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
          Container(
            height: 168,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ShearLadderPainter(
                    check: r.check,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$V_c = 2\lambda\sqrt{f_c^{\prime}}\,b_w d \qquad \phi = 0.75$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Stirrups.values) ...[
            _Choice(
              label: ShearRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Stirrups.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
