import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'curve_figures.dart';
import 'lesson_brief.dart';

/// True or Engineering — the second item for `stress-strain-material-behavior`.
///
/// One test, two curves. The lesson's hardest problem is the conversion
/// between them, and the conversion is arithmetic; what is not arithmetic is
/// knowing which curve a quoted number came off, why one of them turns over
/// and comes down when the steel is plainly not getting weaker, and why they
/// are the same line until the stretching gets serious. That is reading a
/// picture, so the picture is what the round asks about.
class TrueOrEngineeringGame extends StatefulWidget {
  const TrueOrEngineeringGame({super.key});

  @override
  State<TrueOrEngineeringGame> createState() => _TrueOrEngineeringGameState();
}

/// Which of the two curves a round is asking for.
enum Reading { machine, real, same }

extension ReadingWords on Reading {
  String get plain => switch (this) {
        Reading.machine => 'The engineering curve',
        Reading.real => 'The true curve',
        Reading.same => 'Neither: they are the same line here',
      };
}

@immutable
class ReadRound {
  const ReadRound({
    required this.subject,
    required this.asked,
    required this.specimen,
    required this.answer,
    required this.why,
    required this.source,
    this.waistLine = false,
    this.elasticBand = false,
  });

  final String subject;
  final String asked;

  /// Whether this round marks the necking point or the elastic stretch,
  /// because it asks about one of them.
  final bool waistLine;
  final bool elasticBand;
  final Specimen specimen;
  final Reading answer;
  final String why;
  final String source;
}

/// The lesson's own necking problem: five hundred and twenty megapascals at
/// fifteen percent stretch, which is where its true stress of five hundred and
/// ninety eight comes from.
const _necked = Specimen(
  label: 'the lesson\'s specimen',
  e: 200000,
  yieldStress: 400,
  ultimate: 520,
  fractureStrain: 0.24,
  necksTo: 0.8,
  areaAtBreak: 0.5,
);

/// Mild steel, with the flat run at yield that only mild steel has.
const _mildSteel = Specimen(
  label: 'mild steel',
  e: 200000,
  yieldStress: 250,
  ultimate: 400,
  fractureStrain: 0.26,
  plateau: 0.014,
  necksTo: 0.75,
  areaAtBreak: 0.5,
);

const readingRounds = <ReadRound>[
  ReadRound(
    subject: 'the end of the test',
    asked: 'Tap the curve that comes back DOWN before the bar breaks.',
    specimen: _mildSteel,
    answer: Reading.machine,
    why:
        'The engineering one. It keeps dividing by the area the bar started '
        'with, so once the waist draws in and the machine can pull less, the '
        'number it plots falls. Nothing about the steel got weaker. The other '
        'curve, which divides by the waist that is actually there, climbs all '
        'the way to the break.',
    source: 'mat-ssm-q1',
  ),
  ReadRound(
    subject: 'the first tenth of a percent',
    asked:
        'The bar has barely moved and still springs back. Tap the curve that '
        'is higher there.',
    specimen: _mildSteel,
    elasticBand: true,
    answer: Reading.same,
    why:
        'Neither. They differ by one plus the strain, and the strain here is '
        'about a thousandth, so the two are the same line to any accuracy you '
        'could read. This is why nobody bothers with true stress for '
        'elastic design: it is the same number. The pair only part company '
        'once the stretching is measured in percent.',
    source: 'mat-ssm-q3',
  ),
  ReadRound(
    subject: 'the top of the report',
    asked:
        'Tap the curve whose highest point is the ultimate tensile strength.',
    specimen: _necked,
    answer: Reading.machine,
    why:
        'The engineering one. Ultimate tensile strength is DEFINED as the '
        'highest engineering stress, which is why it is a number you can look '
        'up and compare between steels. The true curve has no peak at all: it '
        'rises until the bar parts, so its top is just wherever the test '
        'happened to end.',
    source: 'mat-ssm-q1',
  ),
  ReadRound(
    subject: 'the waist has started',
    asked:
        'The bar has begun to draw down in the middle. Tap the curve that '
        'keeps climbing from here on.',
    specimen: _necked,
    waistLine: true,
    answer: Reading.real,
    why:
        'The true one. The force is falling, but the area it is spread over '
        'is falling faster, so the stress in the steel that is left keeps '
        'going up right to the break. The waist is where the bar fails, and '
        'this is the curve that describes what is happening there.',
    source: 'mat-ssm-q3',
  ),
  ReadRound(
    subject: 'a number off a mill certificate',
    asked:
        'A report gives 520 megapascals at a stretch of 15 percent. Tap the '
        'curve that number was read off.',
    specimen: _necked,
    answer: Reading.machine,
    why:
        'The engineering one, because that is what a testing machine reports '
        'unless somebody says otherwise. Converted, the true stress at that '
        'same instant is 520 times 1.15, about 598. Note which way the '
        'conversion goes: true is the bigger number. Dividing instead of '
        'multiplying gives 452, which is the wrong side of the right answer.',
    source: 'mat-ssm-q3',
  ),
  ReadRound(
    subject: 'before the waist forms',
    asked:
        'Up to here, one curve is the other multiplied by one plus the '
        'strain. Tap the bigger of the two.',
    specimen: _necked,
    waistLine: true,
    answer: Reading.real,
    why:
        'The true one, always, once there is any stretch at all. One plus the '
        'strain is bigger than one, and multiplying by it can only raise the '
        'number. That is the sense check for the conversion: if your true '
        'stress came out SMALLER than the engineering stress, you divided '
        'when you should have multiplied.',
    source: 'mat-ssm-q3',
  ),
];

class _TrueOrEngineeringGameState extends State<TrueOrEngineeringGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'true-or-engineering',
    chapterId: 'materials',
    total: readingRounds.length,
    sourceProblemIdOf: (round) => readingRounds[round].source,
  )..addListener(_onSession);

  Reading? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ReadRound get _round => readingRounds[_session.round];

  int? _glowOf(ReadRound r, bool answered) {
    if (answered) {
      return switch (r.answer) {
        Reading.machine => BothPainter.engineering,
        Reading.real => BothPainter.truth,
        Reading.same => null,
      };
    }
    return switch (_picked) {
      Reading.machine => BothPainter.engineering,
      Reading.real => BothPainter.truth,
      _ => null,
    };
  }

  int? _wrongOf(ReadRound r, bool answered) {
    if (!answered || _picked == r.answer) return null;
    return switch (_picked) {
      Reading.machine => BothPainter.engineering,
      Reading.real => BothPainter.truth,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'True or Engineering',
        closing:
            'One test, two ways of dividing. Engineering keeps the area the '
            'bar started with, so its curve turns over and comes down once '
            'the waist forms, and its peak is the ultimate strength everybody '
            'quotes. True divides by the waist that is there, so it climbs to '
            'the break and is always the bigger of the two. Below yield they '
            'are the same line.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final frame = Frame.over([r.specimen], headroom: 1.85);

    return BoardShell(
      session: _session,
      brief: trueStressBrief,
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
            'TAP THE CURVE',
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
              final size = Size(box.maxWidth, 230);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = BothPainter.nearest(
                          r.specimen,
                          frame,
                          size,
                          details.localPosition,
                        );
                        if (hit == null) return;
                        setState(() => _picked = hit == BothPainter.truth
                            ? Reading.real
                            : Reading.machine);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: BothPainter(
                        specimen: r.specimen,
                        frame: frame,
                        glow: _glowOf(r, answered),
                        wrong: _wrongOf(r, answered),
                        named: answered,
                        waistLine: r.waistLine,
                        elasticBand: r.elasticBand,
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
            'both drawn against the stretch the machine reports',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\sigma_T = \sigma(1 + \varepsilon)$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Reading.same.plain,
            selected: _picked == Reading.same,
            locked: answered,
            isTruth: r.answer == Reading.same,
            onTap:
                answered ? null : () => setState(() => _picked = Reading.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER ONE',
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
