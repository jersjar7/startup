import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../games/board.dart';
import '../../shared/widgets/engineering_grid.dart';
import '../drawing/drawing_painter.dart';
import '../pack_model.dart';

/// Game type "tap-figure": the student answers by tapping a part of the
/// drawing.
///
/// Built from Tap the Voids, screen for screen. Each round carries its
/// tappable regions, in the order the original checked them, and one
/// drawing per state, keyed `"<picked or ->|<0 or 1 for answered>"`.
class PackTapFigureGame extends StatefulWidget {
  const PackTapFigureGame({super.key, required this.game});

  final PackGame game;

  @override
  State<PackTapFigureGame> createState() => _PackTapFigureGameState();
}

class _PackTapFigureGameState extends State<PackTapFigureGame> {
  PackGame get _game => widget.game;

  late final BoardSession _session = BoardSession(
    gameId: _game.id,
    chapterId: _game.chapterId,
    total: _game.rounds.length,
    sourceProblemIdOf: (round) => _game.rounds[round]['source']! as String,
  )..addListener(_onSession);

  String? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Map<String, Object?> get _round => _game.rounds[_session.round];

  /// Which region a tap landed on, first match wins.
  static String? _hit(Map<String, Object?> round, Size size, Offset tap) {
    for (final raw in round['regions']! as List) {
      final region = raw as Map<String, Object?>;
      for (final step in drawingSteps(ops(region['ops']), size.width)) {
        final op = step! as List<Object?>;
        if (op[0] != 'rect') {
          throw UnsupportedError('Region shape ${op[0]}');
        }
        double n(int i) => drawingNumber(op[i], size.width);
        if (Rect.fromLTRB(n(1), n(2), n(3), n(4)).contains(tap)) {
          return region['id']! as String;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: _game.title,
        closing: _game.closing,
      );
    }

    final answered = _session.answered;
    final r = _round;
    final answer = r['answer']! as String;
    final figure = r['figure']! as Map<String, Object?>;
    final state = '${_picked ?? '-'}|${answered ? 1 : 0}';

    return BoardShell(
      session: _session,
      brief: _game.brief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () =>
                      _session.submit(ok: _picked == answer, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _game.text('overline'),
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r['subject']! as String,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r['asked']! as String,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(
                box.maxWidth,
                (_game.json['figureHeight']! as num).toDouble(),
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = _hit(r, size, details.localPosition);
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: DrawingPainter(ops(figure[state])),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            _game.text('note'),
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? _game.text('right')
                  : _game.text('wrong'),
              body: r['why']! as String,
            ),
          ],
        ],
      ),
    );
  }
}
