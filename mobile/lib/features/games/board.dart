import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/app_button.dart';
import 'game_progress.dart';
import 'game_sync.dart';
import 'lesson_brief.dart';

/// Shared plumbing for one sitting: which round is up, what is left, what has
/// been sent to the server, and the done screen. Nothing here decides what a
/// round asks — every game writes its own question, its own picture and its
/// own wrong-answer wording.
///
/// The rules it enforces come from the north star: no clock, no lives, a
/// bounded set with a visible end, and a miss that comes back rather than
/// punishes.
class BoardSession extends ChangeNotifier {
  BoardSession({
    required this.gameId,
    required this.chapterId,
    required this.total,
    required this.sourceProblemIdOf,
  }) {
    GameProgress.registerRounds(gameId, total);
    _restore();
  }

  final String gameId;
  final String chapterId;
  final int total;

  /// Which web problem a given round was authored from.
  final String Function(int round) sourceProblemIdOf;

  final List<int> _queue = [];
  final Set<int> _seen = {};
  final List<GameEvent> _pending = [];

  int _cursor = 0;
  bool? _correct;
  bool _syncFailed = false;

  /// Rounds are 0-based here and 1-based on the wire.
  int get round => _queue.isEmpty ? 0 : _queue[_cursor % _queue.length];
  bool get answered => _correct != null;
  bool? get correct => _correct;
  bool get syncFailed => _syncFailed;
  int get clearedCount => GameProgress.instance.roundsCleared(gameId).length;
  int get firstTryCount => GameProgress.instance.firstTryCount(gameId);
  bool get done => clearedCount >= total;

  /// True when this sitting picked up rounds finished earlier.
  bool get resumed => _resumedWith > 0;
  int _resumedWith = 0;

  void _restore() {
    final cleared = GameProgress.instance.roundsCleared(gameId);
    _resumedWith = cleared.length;
    _queue
      ..clear()
      ..addAll(
        [for (var i = 0; i < total; i++) i].where((i) => !cleared.contains(i)),
      );
    _cursor = 0;
  }

  void submit({required bool ok, required BuildContext context}) {
    final r = round;
    _correct = ok;
    if (ok) {
      GameProgress.instance.markRoundCleared(
        gameId,
        r,
        firstTry: !_seen.contains(r),
      );
    } else {
      _queue.add(r); // comes back later in the same sitting
    }
    _seen.add(r);
    _pending.add(
      GameEvent(
        sourceProblemId: sourceProblemIdOf(r),
        chapterId: chapterId,
        gameId: gameId,
        round: r + 1,
        correct: ok,
      ),
    );
    notifyListeners();
    // Send as we go, so leaving half way never loses the work.
    _flush(context);
  }

  Future<void> _flush(BuildContext context) async {
    if (_pending.isEmpty) return;
    final batch = List.of(_pending);
    // No signed-in account in scope (widget tests, previews): the round still
    // counts locally, there is simply nowhere to send it.
    AuthController? auth;
    try {
      auth = context.read<AuthController>();
    } catch (_) {
      return;
    }
    final api = auth.api;
    final ok = await GameSync(api).push(batch);
    if (ok) _pending.removeWhere(batch.contains);
    _syncFailed = !ok;
    notifyListeners();
  }

  void next() {
    _correct = null;
    _cursor++;
    notifyListeners();
  }

  void restart() {
    GameProgress.instance.reset(gameId);
    _seen.clear();
    _pending.clear();
    _correct = null;
    _syncFailed = false;
    _restore();
    notifyListeners();
  }
}

/// The frame every sitting shares: a close button, a progress bar, the game's
/// own body, and one button along the bottom.
class BoardShell extends StatelessWidget {
  const BoardShell({
    super.key,
    required this.session,
    required this.child,
    required this.buttonLabel,
    required this.onButton,
    this.brief,
  });

  final BoardSession session;
  final Widget child;
  final String buttonLabel;
  final VoidCallback? onButton;

  /// The concept behind THIS item, reachable mid-round. Forgetting what a term
  /// means should send you to the explanation, not out of the app.
  final BriefSection? brief;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _BoardHeader(session: session, brief: brief),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    child,
                    const SizedBox(height: 20),
                    AppButton(label: buttonLabel, onPressed: onButton),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({required this.session, required this.brief});

  final BoardSession session;
  final BriefSection? brief;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.ink3,
              size: 22,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: session.clearedCount / session.total,
                minHeight: 8,
                backgroundColor: AppColors.creamDark,
                valueColor: const AlwaysStoppedAnimation(AppColors.forest),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${session.clearedCount}/${session.total}',
            style: AppTheme.mono(size: 13, color: AppColors.ink2),
          ),
          if (brief != null)
            IconButton(
              tooltip: brief!.title,
              onPressed: () => showConcept(context, brief!),
              icon: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.ink3,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

/// The panel under the question after an answer: green when right, red when
/// wrong, carrying the game's own explanation.
class BoardFeedback extends StatelessWidget {
  const BoardFeedback({
    super.key,
    required this.correct,
    required this.title,
    required this.body,
  });

  final bool correct;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: correct ? AppColors.forestBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.overline(
              color: correct ? AppColors.forest : AppColors.error,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          if (!correct) ...[
            const SizedBox(height: 6),
            const Text(
              'It comes back later in this set.',
              style: TextStyle(fontSize: 12.5, color: AppColors.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

/// The end of a sitting. Bounded, quiet, and honest about where the real work
/// happens.
class BoardDone extends StatelessWidget {
  const BoardDone({
    super.key,
    required this.session,
    required this.title,
    required this.closing,
  });

  final BoardSession session;
  final String title;

  /// The one line that says what they now know, and what it does not prove.
  final String closing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'ALL DONE',
                style: AppTheme.overline(color: AppColors.forest),
              ),
              const SizedBox(height: 10),
              Text(title, style: AppTheme.heading(size: 32)),
              const SizedBox(height: 16),
              Text(
                'You finished all ${session.total}. '
                '${session.firstTryCount} landed on the first try.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.ink2,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  closing,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.ink2,
                  ),
                ),
              ),
              if (session.syncFailed) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sunbeamBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Some of this did not reach your account, so it has not '
                    'counted toward your mastery yet.',
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              AppButton(label: 'Start over', onPressed: session.restart),
              const SizedBox(height: 10),
              AppButton(
                label: 'Done',
                ghost: true,
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
