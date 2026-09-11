import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'fiber_figures.dart';
import 'lesson_brief.dart';

/// Along or Across — the first item for `composite-materials`.
///
/// Two formulas, and picking between them is the whole question: the load
/// running ALONG the fibers gives the additive rule and a stiff composite,
/// and across them gives the reciprocal one and a soft composite that the
/// matrix governs. Which applies is read off a drawing, not worked out, and
/// the lesson's own problem names the reciprocal answer as its first wrong
/// choice. Density is in here too, because it has no direction at all.
class AlongOrAcrossGame extends StatefulWidget {
  const AlongOrAcrossGame({super.key});

  @override
  State<AlongOrAcrossGame> createState() => _AlongOrAcrossGameState();
}

/// The three expressions a composite question ever wants.
enum Mixes { additive, reciprocal, plainAverage }

extension MixesParts on Mixes {
  String get tex => switch (this) {
        Mixes.additive => r'$f_1 E_1 + f_2 E_2$',
        Mixes.reciprocal => r'$\left(\dfrac{f_1}{E_1} + \dfrac{f_2}{E_2}\right)^{-1}$',
        Mixes.plainAverage => r'$\dfrac{E_1 + E_2}{2}$',
      };

  String get plain => switch (this) {
        Mixes.additive => 'the additive rule',
        Mixes.reciprocal => 'the reciprocal rule',
        Mixes.plainAverage => 'a plain average',
      };
}

@immutable
class LayRound {
  const LayRound({
    required this.subject,
    required this.setting,
    required this.blend,
    required this.lay,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Blend blend;
  final Lay lay;
  final List<Mixes> options;
  final Mixes answer;
  final String why;
  final String source;
}

/// The lesson's carbon and epoxy: 230 against 3.5, forty percent fiber.
const _carbon = Blend(
  fiberE: 230,
  matrixE: 3.5,
  fiberShare: 0.40,
  fiberName: 'carbon fiber',
  matrixName: 'epoxy',
);

/// Its steel fiber composite.
const _steel = Blend(
  fiberE: 200,
  matrixE: 3,
  fiberShare: 0.25,
  fiberName: 'steel fiber',
  matrixName: 'matrix',
);

/// Its glass and polymer, quoted here by the moduli rather than the
/// densities, since the shape of the question is the same either way.
const _glass = Blend(
  fiberE: 72,
  matrixE: 3,
  fiberShare: 0.30,
  fiberName: 'glass fiber',
  matrixName: 'polymer',
);

const layRounds = <LayRound>[
  LayRound(
    subject: 'a pultruded rod, pulled end to end',
    setting:
        'The fibers run the length of the rod and the load pulls along it. '
        'Which expression gives the modulus?',
    blend: _carbon,
    lay: Lay.along,
    options: [Mixes.additive, Mixes.reciprocal, Mixes.plainAverage],
    answer: Mixes.additive,
    why:
        'The additive rule. Along the fibers both materials are forced to '
        'stretch by the same amount, so each carries its share of the load in '
        'proportion to its stiffness AND its volume, and the moduli add up '
        'weighted by volume. This is the case the exam asks about nearly '
        'every time: 94 gigapascals for this one.',
    source: 'mat-com-q2',
  ),
  LayRound(
    subject: 'the same rod, squeezed sideways',
    setting:
        'The same rod, with the load now pressing across the fibers rather '
        'than along them.',
    blend: _carbon,
    lay: Lay.across,
    options: [Mixes.reciprocal, Mixes.plainAverage, Mixes.additive],
    answer: Mixes.reciprocal,
    why:
        'The reciprocal rule, and the answer collapses: about 5.8 '
        'gigapascals, against 94 the other way round. Across the fibers both '
        'materials carry the same stress and the soft epoxy simply gives way, '
        'so the composite is barely stiffer than the epoxy. A composite is a '
        'material with a direction, and this is the number that proves it.',
    source: 'mat-com-q2',
  ),
  LayRound(
    subject: 'a column wrap',
    setting:
        'Carbon fabric is wrapped around a column with the fibers running '
        'around it, hoop wise. The column is then loaded straight down.',
    blend: _carbon,
    lay: Lay.across,
    options: [Mixes.plainAverage, Mixes.additive, Mixes.reciprocal],
    answer: Mixes.reciprocal,
    why:
        'The reciprocal rule, because the axial load runs ACROSS those '
        'fibers. The wrap does very little for axial stiffness, and that is '
        'not what it is for: it is there to hold the column together '
        'sideways, where the fibers do run along the load. Direction is the '
        'whole design.',
    source: 'mat-com-q2',
  ),
  LayRound(
    subject: 'the weight of the thing',
    setting:
        'Now the density of the same glass and polymer panel, whichever way '
        'it happens to be loaded, rather than its stiffness.',
    blend: _glass,
    lay: Lay.across,
    options: [Mixes.additive, Mixes.plainAverage, Mixes.reciprocal],
    answer: Mixes.additive,
    why:
        'The additive rule, whichever way the fibers run. Density is just a '
        'weighted average by volume and has no direction in it at all: thirty '
        'percent of one plus seventy percent of the other. Only the STIFFNESS '
        'cares which way the load goes.',
    source: 'mat-com-q1',
  ),
  LayRound(
    subject: 'a deck panel spanning between beams',
    setting:
        'The fibers are laid along the span and the panel bends under '
        'traffic, stretching the bottom face along its length.',
    blend: _glass,
    lay: Lay.along,
    options: [Mixes.reciprocal, Mixes.additive, Mixes.plainAverage],
    answer: Mixes.additive,
    why:
        'The additive rule again: the stretching runs along the fibers, which '
        'is why the fibers were laid that way. This is what a designer does '
        'with a composite that nobody can do with steel, and it is also why a '
        'panel loaded the wrong way round is so much worse than people '
        'expect.',
    source: 'mat-com-q2',
  ),
  LayRound(
    subject: 'a rule that is never right',
    setting:
        'A steel fiber composite, one quarter fiber by volume, pulled along '
        'the fibers.',
    blend: _steel,
    lay: Lay.along,
    options: [Mixes.plainAverage, Mixes.reciprocal, Mixes.additive],
    answer: Mixes.additive,
    why:
        'The additive rule, and notice what the plain average would have '
        'given: a hundred and one gigapascals, as if the two were half and '
        'half. They are not, and the volume fractions are doing real work '
        'here. The real answer is 52. Whenever a composite answer comes out '
        'near the middle of the two materials, check the fractions.',
    source: 'mat-com-q1',
  ),
];

class _AlongOrAcrossGameState extends State<AlongOrAcrossGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'along-or-across',
    chapterId: 'materials',
    total: layRounds.length,
    sourceProblemIdOf: (round) => layRounds[round].source,
  )..addListener(_onSession);

  Mixes? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LayRound get _round => layRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Along or Across',
        closing:
            'Along the fibers, both materials stretch together and the moduli '
            'add up by volume: a stiff composite. Across them, both carry the '
            'same stress and the soft matrix gives way, so the reciprocals '
            'add and the answer is always the smaller one. Density takes the '
            'additive rule whatever the direction, because weight has no '
            'direction in it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: blendBrief,
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
            'WHICH RULE APPLIES',
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
              height: 210,
              width: double.infinity,
              child: CustomPaint(
                painter: BlendPainter(blend: r.blend, lay: r.lay),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in r.options) ...[
            _Choice(
              tex: option.tex,
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
                  ? 'THAT IS ${r.answer.plain.toUpperCase()}'
                  : 'THAT IS ${_picked!.plain.toUpperCase()}',
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
    required this.tex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String tex;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathText(
            tex,
            style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
