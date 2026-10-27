import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../games/board.dart';
import '../pack_model.dart';

/// Game type "order": some of the actions on the board are taken, in order,
/// and the rest are left alone.
///
/// Built from In What Order, screen for screen.
class PackOrderGame extends StatefulWidget {
  const PackOrderGame({super.key, required this.game});

  final PackGame game;

  @override
  State<PackOrderGame> createState() => _PackOrderGameState();
}

class _PackOrderGameState extends State<PackOrderGame> {
  PackGame get _game => widget.game;

  late final BoardSession _session = BoardSession(
    gameId: _game.id,
    gameName: _game.title,
    pack: _game.pack,
    chapterId: _game.chapterId,
    total: _game.rounds.length,
    sourceProblemIdOf: (round) => _game.rounds[round]['source']! as String,
  )..addListener(_onSession);

  /// The actions taken, in the order they were tapped.
  final _taken = <int>[];

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Map<String, Object?> get _round => _game.rounds[_session.round];

  List<int> get _order => (_round['order']! as List).cast<int>();

  void _tap(int i) {
    setState(() {
      if (_taken.contains(i)) {
        _taken.remove(i);
      } else if (_taken.length < _order.length) {
        _taken.add(i);
      }
    });
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
    final order = _order;
    final actions = (r['actions']! as List).cast<String>();
    final ok =
        _taken.length == order.length &&
        List.generate(
          order.length,
          (i) => _taken[i] == order[i],
        ).every((x) => x);

    return BoardShell(
      session: _session,
      brief: _game.brief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_taken.clear);
              _session.next();
            }
          : (_taken.length != order.length
                ? null
                : () => _session.submit(ok: ok, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _game.text('overline'),
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r['scenario']! as String,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _game.text('hint'),
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _StepRow(
              key: ValueKey('step-$i'),
              text: actions[i],
              step: _taken.indexOf(i),
              rightStep: answered ? order.indexOf(i) : -1,
              locked: answered,
              onTap: answered ? null : () => _tap(i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              _game.text('neverLabel'),
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              r['never']! as String,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.charcoal,
              ),
            ),
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

class _StepRow extends StatelessWidget {
  const _StepRow({
    super.key,
    required this.text,
    required this.step,
    required this.rightStep,
    required this.locked,
    required this.onTap,
  });

  final String text;

  /// Where the student put this one, or minus one if they left it alone.
  final int step;

  /// Where it actually belongs, once the answer is in. Minus one for an
  /// action nobody takes.
  final int rightStep;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && rightStep >= 0) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && step >= 0) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (step >= 0) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    final badge = locked
        ? (rightStep >= 0 ? '${rightStep + 1}' : (step >= 0 ? 'x' : ''))
        : (step >= 0 ? '${step + 1}' : '');

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.isEmpty ? null : border,
                  border: Border.all(
                    color: badge.isEmpty ? AppColors.line : border,
                  ),
                ),
                child: Text(
                  badge,
                  style: AppTheme.mono(size: 12, color: AppColors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
