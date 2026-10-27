import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../games/board.dart';
import '../../shared/widgets/engineering_grid.dart';
import '../drawing/drawing_painter.dart';
import '../pack_model.dart';

/// Game type "pick-one": a question over a drawing, four answers, pick one.
///
/// Built from Per Million What, screen for screen, so that game plays the
/// same from a pack as it did built in. Each round's drawing comes in two
/// states, before the answer ("ask") and after it ("done").
class PackPickOneGame extends StatefulWidget {
  const PackPickOneGame({super.key, required this.game});

  final PackGame game;

  @override
  State<PackPickOneGame> createState() => _PackPickOneGameState();
}

class _PackPickOneGameState extends State<PackPickOneGame> {
  PackGame get _game => widget.game;

  late final BoardSession _session = BoardSession(
    gameId: _game.id,
    gameName: _game.title,
    pack: _game.pack,
    chapterId: _game.chapterId,
    total: _game.rounds.length,
    sourceProblemIdOf: (round) => _game.rounds[round]['source']! as String,
  )..addListener(_onSession);

  void _onSession() => setState(() {});

  int? _picked;

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Map<String, Object?> get _round => _game.rounds[_session.round];

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
    final options = (r['options']! as List).cast<String>();
    final answer = r['answer']! as int;
    final figure = r['figure']! as Map<String, Object?>;

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
          Container(
            height: (_game.json['figureHeight']! as num).toDouble(),
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
                  painter: DrawingPainter(
                    ops(figure[answered ? 'done' : 'ask']),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < options.length; i++) ...[
            _Choice(
              label: options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != options.length - 1) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
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
