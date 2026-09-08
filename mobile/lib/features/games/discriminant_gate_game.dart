import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Discriminant Gate — the second item for `straight-lines-quadratics`.
///
/// The student never works out b² − 4ac. Either the curve is drawn and they
/// say how many times it meets the axis, or the value is handed to them and
/// they pick the curve it describes. That is the lesson's own tip made
/// tappable: check the discriminant first and you can throw answers out before
/// solving anything.
class DiscriminantGateGame extends StatefulWidget {
  const DiscriminantGateGame({super.key});

  @override
  State<DiscriminantGateGame> createState() => _DiscriminantGateGameState();
}

/// A parabola described by which way it opens and where its vertex sits. Root
/// count follows from those two facts alone, which is the whole point.
@immutable
class Para {
  const Para({required this.opensUp, required this.vertexY});

  final bool opensUp;

  /// Positive is above the axis, negative below, zero sitting on it.
  final double vertexY;

  int get roots {
    if (vertexY == 0) return 1;
    final crosses = opensUp ? vertexY < 0 : vertexY > 0;
    return crosses ? 2 : 0;
  }
}

enum GateAsk { countFromCurve, curveFromValue }

@immutable
class Gate {
  const Gate({
    required this.ask,
    required this.curves,
    required this.answer,
    this.statement,
    this.context,
  });

  final GateAsk ask;

  /// One curve for [GateAsk.countFromCurve]; three to choose between for
  /// [GateAsk.curveFromValue].
  final List<Para> curves;

  /// Root count for countFromCurve; index into [curves] for curveFromValue.
  final int answer;

  /// The discriminant as given to the student, never as something to work out.
  final String? statement;
  final String? context;
}

const gateRounds = <Gate>[
  Gate(
    ask: GateAsk.countFromCurve,
    context:
        'A vertical curve is modeled by a quadratic. Where does it meet '
        'the road below?',
    curves: [Para(opensUp: true, vertexY: -1.1)],
    answer: 2,
  ),
  Gate(
    ask: GateAsk.curveFromValue,
    statement: r'b^2 - 4ac = -18',
    curves: [
      Para(opensUp: true, vertexY: -1.1),
      Para(opensUp: true, vertexY: 0.9),
      Para(opensUp: true, vertexY: 0),
    ],
    answer: 1,
  ),
  Gate(
    ask: GateAsk.countFromCurve,
    curves: [Para(opensUp: false, vertexY: 1.2)],
    answer: 2,
  ),
  Gate(
    ask: GateAsk.curveFromValue,
    statement: r'b^2 - 4ac = 0',
    curves: [
      Para(opensUp: true, vertexY: 0.9),
      Para(opensUp: true, vertexY: 0),
      Para(opensUp: true, vertexY: -1.1),
    ],
    answer: 1,
  ),
  Gate(
    ask: GateAsk.countFromCurve,
    context: 'A projectile launched from an embankment, height against time.',
    curves: [Para(opensUp: false, vertexY: -0.8)],
    answer: 0,
  ),
  Gate(
    ask: GateAsk.curveFromValue,
    statement: r'b^2 - 4ac = 242',
    curves: [
      Para(opensUp: false, vertexY: -0.8),
      Para(opensUp: false, vertexY: 0),
      Para(opensUp: false, vertexY: 1.2),
    ],
    answer: 2,
  ),
  Gate(
    ask: GateAsk.countFromCurve,
    curves: [Para(opensUp: true, vertexY: 0)],
    answer: 1,
  ),
  Gate(
    ask: GateAsk.countFromCurve,
    context: 'A cable sag curve that never reaches the datum.',
    curves: [Para(opensUp: true, vertexY: 0.9)],
    answer: 0,
  ),
];

const _countLabels = ['No real roots', 'One root', 'Two real roots'];

class _DiscriminantGateGameState extends State<DiscriminantGateGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'discriminant-gate',
    chapterId: 'mathematics',
    total: gateRounds.length,
    // Every round is drawn from the lesson's quadratic problem and its traps.
    sourceProblemIdOf: (_) => 'math-slq-q3',
  )..addListener(_onSession);

  int? _choice;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Gate get _gate => gateRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Discriminant Gate',
        closing:
            'Below the axis on both sides means two roots, touching means '
            'one, clear of it means none. On the exam that lets you throw out '
            'answers before you solve anything. Finding the roots themselves '
            'is still desk work.',
      );
    }

    final answered = _session.answered;

    return BoardShell(
      session: _session,
      brief: discriminantBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choice = null);
              _session.next();
            }
          : (_choice == null
                ? null
                : () => _session.submit(
                    ok: _choice == _gate.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _gate.ask == GateAsk.countFromCurve
                ? 'HOW MANY REAL ROOTS'
                : 'WHICH CURVE IS IT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            _gate.ask == GateAsk.countFromCurve
                ? (_gate.context ??
                      'Read the curve. Where does it meet the axis?')
                : 'This quadratic has the discriminant below. Tap the curve '
                      'that matches it.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          if (_gate.ask == GateAsk.countFromCurve)
            ..._countBody()
          else
            ..._pickBody(),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ONE',
              body: _explain(),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _countBody() {
    return [
      _CurveCard(para: _gate.curves.first, height: 200),
      const SizedBox(height: 16),
      for (var i = 2; i >= 0; i--) ...[
        _OptionButton(
          label: _countLabels[i],
          selected: _choice == i,
          locked: _session.answered,
          correct: _session.answered && i == _gate.answer,
          onTap: _session.answered ? null : () => setState(() => _choice = i),
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _pickBody() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Center(child: MathBlock(_gate.statement!, fontSize: 20)),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          for (var i = 0; i < _gate.curves.length; i++) ...[
            Expanded(
              child: GestureDetector(
                onTap: _session.answered
                    ? null
                    : () => setState(() => _choice = i),
                child: _CurveCard(
                  para: _gate.curves[i],
                  height: 116,
                  selected: _choice == i,
                  correct: _session.answered && i == _gate.answer,
                  wrong: _session.answered && _choice == i && i != _gate.answer,
                ),
              ),
            ),
            if (i < _gate.curves.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    ];
  }

  String _explain() {
    final ok = _session.correct!;
    if (_gate.ask == GateAsk.countFromCurve) {
      final n = _gate.answer;
      final truth = switch (n) {
        2 =>
          'The curve passes through the axis twice, so b² − 4ac is '
              'positive and there are two real roots.',
        1 =>
          'The curve only touches the axis, so b² − 4ac is exactly zero '
              'and both roots are the same number.',
        _ =>
          'The curve never reaches the axis, so b² − 4ac is negative and '
              'there is no real root at all.',
      };
      return ok
          ? truth
          : 'Look at where the curve sits against the axis. $truth';
    }
    final target = _gate.curves[_gate.answer];
    final sign = target.roots == 2
        ? 'A positive discriminant cuts the axis twice.'
        : target.roots == 1
        ? 'A discriminant of zero touches the axis once.'
        : 'A negative discriminant never reaches the axis.';
    return ok ? sign : 'Not that one. $sign';
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.locked,
    required this.correct,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && correct) {
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 1.5,
            ),
          ),
          child: Text(label, style: AppTheme.heading(size: 16, height: 1.2)),
        ),
      ),
    );
  }
}

class _CurveCard extends StatelessWidget {
  const _CurveCard({
    required this.para,
    required this.height,
    this.selected = false,
    this.correct = false,
    this.wrong = false,
  });

  final Para para;
  final double height;
  final bool selected;
  final bool correct;
  final bool wrong;

  @override
  Widget build(BuildContext context) {
    final border = correct
        ? AppColors.forest
        : wrong
        ? AppColors.error
        : selected
        ? AppColors.ember
        : AppColors.line;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border,
          width: border == AppColors.line ? 1 : 2.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: EngineeringGrid(
            minor: 16,
            major: 80,
            child: CustomPaint(
              painter: ParaPainter(
                para: para,
                color: correct
                    ? AppColors.forest
                    : wrong
                    ? AppColors.error
                    : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared with the lesson brief, which draws the same three curves.
class ParaPainter extends CustomPainter {
  ParaPainter({required this.para, required this.color});

  final Para para;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final axisY = size.height * 0.56;

    canvas.drawLine(
      Offset(0, axisY),
      Offset(size.width, axisY),
      Paint()
        ..color = AppColors.charcoal.withValues(alpha: 0.45)
        ..strokeWidth = 2,
    );

    // Vertex offset in pixels; vertexY is in "grid squares" above the axis.
    final vertex = Offset(size.width / 2, axisY - para.vertexY * 26);
    // Chosen so the arms reach roughly the top (or bottom) of the card at the
    // edges, whatever the card's size.
    final k = 3.4 * size.height / (size.width * size.width);
    final path = Path();
    for (double x = 0; x <= size.width; x += 3) {
      final dx = x - vertex.dx;
      // Screen y grows downward, so "opens up" subtracts.
      final y = vertex.dy + (para.opensUp ? -1 : 1) * k * dx * dx;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(ParaPainter old) => old.para != para || old.color != color;
}
