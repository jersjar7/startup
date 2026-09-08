import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Stretch It to Fit — the second item for `vector-basics-unit-vectors`.
///
/// The lesson's tip is one line: to put a force along a known direction, find
/// the unit vector and multiply by the magnitude. Answered by working the
/// multiplier up and down with a thumb while the arrow grows under it, because
/// the thing worth learning is that direction and size come apart. Half the
/// rounds hand over a direction that is NOT unit length, where the multiplier
/// is not the magnitude, which is the reason anybody normalizes at all. A
/// negative multiplier turns the arrow around, and that is a round too.
class StretchItGame extends StatefulWidget {
  const StretchItGame({super.key});

  @override
  State<StretchItGame> createState() => _StretchItGameState();
}

@immutable
class StretchRound {
  const StretchRound({
    required this.direction,
    required this.shown,
    required this.wantLength,
    required this.opposite,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The arrow handed over. Unit length in some rounds and not in others.
  final Vec direction;

  /// How that arrow is written on the card.
  final String shown;

  /// How long the finished arrow has to be.
  final double wantLength;

  /// True when the finished arrow has to point the other way.
  final bool opposite;

  /// The multiplier that does it.
  final int answer;
  final String why;
  final String source;

  bool get isUnit => (direction.length - 1).abs() < 1e-9;
}

const stretchRounds = <StretchRound>[
  StretchRound(
    direction: Vec(0.6, 0.8),
    shown: r'\hat{u} = 0.6\hat{i} + 0.8\hat{j}',
    wantLength: 5,
    opposite: false,
    answer: 5,
    why:
        'This one is already unit length, so the multiplier IS the magnitude. '
        'Five times it gives three across and four up, which is a five long '
        'arrow.',
    source: 'math-vbu-q2',
  ),
  StretchRound(
    direction: Vec(3, 4),
    shown: r'\vec{d} = 3\hat{i} + 4\hat{j}',
    wantLength: 10,
    opposite: false,
    answer: 2,
    why:
        'This arrow is already 5 long, so ten times it would be fifty. The '
        'multiplier is only the magnitude when the direction is unit length, '
        'and that is the entire reason for dividing by the length first.',
    source: 'math-vbu-q2',
  ),
  StretchRound(
    direction: Vec(0.8, -0.6),
    shown: r'\hat{u} = 0.8\hat{i} - 0.6\hat{j}',
    wantLength: 4,
    opposite: false,
    answer: 4,
    why:
        'A negative component is not a shorter arrow, it is an arrow pointing '
        'down as it goes across. The length still comes out at one before '
        'scaling.',
    source: 'math-vbu-q2',
  ),
  StretchRound(
    direction: Vec(0, 1),
    shown: r'\hat{u} = 0\hat{i} + 1\hat{j}',
    wantLength: 3,
    opposite: true,
    answer: -3,
    why:
        'A negative multiplier turns the arrow around and keeps it on the '
        'same line. Three long, pointing down.',
    source: 'math-vbu-q2',
  ),
  StretchRound(
    direction: Vec(-4, 3),
    shown: r'\vec{d} = -4\hat{i} + 3\hat{j}',
    wantLength: 10,
    opposite: false,
    answer: 2,
    why:
        'Five long again, so doubling gets you ten. Notice the direction is '
        'untouched by the scaling: only the size changed.',
    source: 'math-vbu-q2',
  ),
  StretchRound(
    direction: Vec(0.6, -0.8),
    shown: r'\hat{u} = 0.6\hat{i} - 0.8\hat{j}',
    wantLength: 5,
    opposite: true,
    answer: -5,
    why:
        'Unit length, so five is the size, and the minus is what sends it the '
        'other way. This is how a force is written along a line when it '
        'pushes rather than pulls.',
    source: 'math-vbu-q2',
  ),
];

class _StretchItGameState extends State<StretchItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stretch-it',
    chapterId: 'mathematics',
    total: stretchRounds.length,
    sourceProblemIdOf: (round) => stretchRounds[round].source,
  )..addListener(_onSession);

  int _k = 1;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StretchRound get _round => stretchRounds[_session.round];

  static const _span = 8;
  static const _kMin = -6;
  static const _kMax = 6;

  void _step(int by) {
    if (_session.answered) return;
    setState(() => _k = (_k + by).clamp(_kMin, _kMax));
  }

  /// [signed] is for the leading component, which keeps its own minus; the
  /// trailing one hands its sign to the separator instead.
  String _component(double v, String hat, {bool signed = false}) {
    final rounded = (v * 100).round() / 100;
    final size = rounded.abs();
    final text = size == size.roundToDouble()
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(1);
    return '${signed && rounded < 0 ? '-' : ''}$text$hat';
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stretch It to Fit',
        closing:
            'A direction and a size are two separate things. The unit vector '
            'carries the direction, the multiplier carries the size, and a '
            'negative one turns it around.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final scaled = r.direction * _k.toDouble();

    return BoardShell(
      session: _session,
      brief: unitVectorBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _k = 1);
              _session.next();
            }
          : () => _session.submit(ok: _k == r.answer, context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIZE IT ALONG THE LINE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            'Make an arrow ${r.wantLength.toStringAsFixed(0)} long along this '
            'direction${r.opposite ? ', pointing the OTHER way.' : '.'}',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(r.shown, fontSize: 17),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 270,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: VectorPainter(
                    span: _span,
                    guide: r.direction,
                    arrows: [
                      Arrow(
                        r.direction,
                        color: AppColors.ink3,
                        faint: true,
                        label: 'given',
                      ),
                      if (_k != 0)
                        Arrow(
                          scaled,
                          color: answered
                              ? (_session.correct!
                                    ? AppColors.forest
                                    : AppColors.error)
                              : AppColors.ember,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Stepper(
            value: _k,
            locked: answered,
            onStep: _step,
            reads:
                '${_component(scaled.x, 'i', signed: true)} '
                '${scaled.y < 0 ? '-' : '+'} ${_component(scaled.y, 'j')}',
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT LENGTH' : 'NOT THAT LONG',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The multiplier, worked with a thumb. The components update as it moves and
/// the LENGTH does not: reading the length off a readout would be the answer.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.locked,
    required this.onStep,
    required this.reads,
  });

  final int value;
  final bool locked;
  final void Function(int by) onStep;
  final String reads;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StepButton(
                key: const ValueKey('step-down'),
                icon: Icons.remove_rounded,
                onTap: locked ? null : () => onStep(-1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'MULTIPLIER',
                      style: AppTheme.overline(color: AppColors.ink3),
                    ),
                    const SizedBox(height: 2),
                    Text('$value', style: AppTheme.heading(size: 28)),
                  ],
                ),
              ),
              _StepButton(
                key: const ValueKey('step-up'),
                icon: Icons.add_rounded,
                onTap: locked ? null : () => onStep(1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              reads,
              textAlign: TextAlign.center,
              style: AppTheme.mono(size: 14, color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.emberBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 60,
          height: 56,
          child: Icon(icon, color: AppColors.ember, size: 24),
        ),
      ),
    );
  }
}
