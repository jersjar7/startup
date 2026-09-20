import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../../core/storage/app_storage.dart';
import '../shared/widgets/kit.dart';
import 'feedback_sheet.dart';
import 'game_catalog.dart';
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

  /// The board is over AND the student has read the last answer. Showing the
  /// summary the instant the final round is graded skips the explanation,
  /// which is the part worth reading.
  bool get finished => done && !answered;

  /// What the button says while an answer is on screen.
  String get advanceLabel => done ? 'See how you did' : 'Next';

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

/// The frame every sitting shares (reference 13): a round close button, the
/// rounds as pips, a mono counter, the book; the game's own body; the flag
/// above the pill along the bottom. Every ground is fog.
class BoardShell extends StatefulWidget {
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
  State<BoardShell> createState() => _BoardShellState();
}

class _BoardShellState extends State<BoardShell> {
  final _storage = AppStorage();

  /// The one-time cues. The book's dot shows until the book is tapped; the
  /// flag's after the first wrong answer ever, until the flag is tapped.
  bool _bookDot = false;
  bool _flagDot = false;
  bool _flagSeen = true;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSession);
    _load();
  }

  @override
  void didUpdateWidget(BoardShell old) {
    super.didUpdateWidget(old);
    if (old.session != widget.session) {
      old.session.removeListener(_onSession);
      widget.session.addListener(_onSession);
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSession);
    super.dispose();
  }

  Future<void> _load() async {
    final bookSeen = await _storage.bookDotSeen();
    final flagSeen = await _storage.flagDotSeen();
    final missed = await _storage.missedOnce();
    if (!mounted) return;
    setState(() {
      _bookDot = !bookSeen;
      _flagSeen = flagSeen;
      _flagDot = missed && !flagSeen;
    });
  }

  void _onSession() {
    final s = widget.session;
    if (s.answered && s.correct == false && !_flagSeen && !_flagDot) {
      _storage.setMissedOnce();
      setState(() => _flagDot = true);
    }
  }

  void _openBook() {
    if (_bookDot) {
      _storage.setBookDotSeen();
      setState(() => _bookDot = false);
    }
    showConcept(context, widget.brief!);
  }

  void _openFlag() {
    if (!_flagSeen) {
      _storage.setFlagDotSeen();
      setState(() {
        _flagSeen = true;
        _flagDot = false;
      });
    }
    final s = widget.session;
    showFeedbackSheet(
      context,
      gameId: s.gameId,
      gameName: gameDefFor(s.gameId)?.name ?? s.gameId,
      chapterId: s.chapterId,
      round: s.round + 1,
      answered: s.answered,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Pips(
                      count: session.total,
                      filled: session.clearedCount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${session.clearedCount}/${session.total}',
                    style: AppTheme.eyebrow(),
                  ),
                  if (widget.brief != null) ...[
                    const SizedBox(width: 12),
                    CueButton(
                      icon: Icons.menu_book_outlined,
                      label: widget.brief!.title,
                      dot: _bookDot,
                      onTap: _openBook,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.child,
                    const SizedBox(height: 18),
                    // The flag, right above the pill on the right: about this
                    // round, not about the frame (owner's placement).
                    Align(
                      alignment: Alignment.centerRight,
                      child: CueButton(
                        icon: Icons.outlined_flag_rounded,
                        label: 'Something unclear?',
                        dot: _flagDot,
                        size: 44,
                        onTap: _openFlag,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PillButton(
                      label: widget.buttonLabel,
                      onTap: widget.onButton,
                    ),
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

/// A cream round button with an optional one-time ember dot on its shoulder.
class CueButton extends StatelessWidget {
  const CueButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.dot = false,
    this.size = 48,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dot;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        RoundIconButton(
          icon: icon,
          label: label,
          onTap: onTap,
          size: size,
          fill: AppColors.cream,
          iconColor: AppColors.charcoal,
        ),
        if (dot)
          Positioned(
            top: 1,
            right: 1,
            child: IgnorePointer(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.ember,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.fog, width: 2.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The panel under the question after an answer: spring when right, peach
/// when wrong, carrying the game's own explanation.
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
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: correct ? AppColors.spring : AppColors.peach,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The games wrote their titles as overlines ("NOT THAT ONE"), and
          // 375 of them read as one voice that way: an eyebrow, not a shout.
          Text(title, style: AppTheme.eyebrow()),
          const SizedBox(height: 8),
          Text(
            body,
            style: AppTheme.body(
              size: 16,
              weight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          if (!correct) ...[
            const SizedBox(height: 8),
            Text(
              'It comes back later in this set.',
              style: AppTheme.body(
                size: 13,
                weight: FontWeight.w500,
                color: AppColors.charcoal.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The end of a sitting (reference 13c): the count as the hero on a spring
/// tile, first tries and the lesson as half tiles, and the honest line about
/// where the real work happens.
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
    final total = session.total;
    final first = session.firstTryCount;
    final missed = total - first;
    final game = gameDefFor(session.gameId);
    final lesson = _lessonOf(session.gameId);
    final lessonDone = lesson == null
        ? null
        : GameProgress.instance.clearedIn(lesson);

    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.close_rounded,
                    label: 'Close',
                    onTap: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                height: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.spring,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('ALL DONE', style: AppTheme.eyebrow()),
                        const Spacer(),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            (game?.name ?? '').toUpperCase(),
                            maxLines: 2,
                            textAlign: TextAlign.right,
                            style: AppTheme.eyebrow(),
                          ),
                        ),
                      ],
                    ),
                    Text.rich(
                      TextSpan(
                        text: '$total',
                        style: AppTheme.display(
                          size: 120,
                          height: 0.8,
                          tracking: -0.07,
                        ),
                        children: [
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: 'of $total',
                            style: AppTheme.display(
                              size: 28,
                              weight: FontWeight.w700,
                              height: 0.8,
                              tracking: -0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      missed == 0
                          ? 'Every one on the first try.'
                          : '$first on the first try. The $missed you missed '
                                'came back and you got ${missed == 1 ? 'it' : 'them'}.',
                      style: AppTheme.body(size: 15, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _HalfTile(
                      color: AppColors.cream,
                      eyebrow: 'FIRST TRY',
                      value: '$first',
                      unit: 'of $total',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HalfTile(
                      color: AppColors.butter,
                      eyebrow: 'LESSON',
                      value: '${lessonDone ?? 0}',
                      unit: lesson == null
                          ? ''
                          : 'of ${lesson.builtGames.length} done',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(title, style: AppTheme.display(size: 22, height: 1.1)),
              const SizedBox(height: 8),
              Text(
                closing,
                style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
              ),
              if (session.syncFailed) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Some of this did not reach your account, so it has not '
                    'counted toward your mastery yet.',
                    style: AppTheme.body(size: 14),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              Row(
                children: [
                  TextAction(label: 'Start over', onTap: session.restart),
                  const SizedBox(width: 14),
                  Expanded(
                    child: PillButton(
                      label: 'Done',
                      onTap: () => context.canPop()
                          ? context.pop()
                          : context.go('/home'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static LessonNode? _lessonOf(String gameId) {
    for (final chapter in chapterMaps.values) {
      for (final lesson in chapter.lessons) {
        if (lesson.games.any((g) => g.id == gameId)) return lesson;
      }
    }
    return null;
  }
}

class _HalfTile extends StatelessWidget {
  const _HalfTile({
    required this.color,
    required this.eyebrow,
    required this.value,
    required this.unit,
  });

  final Color color;
  final String eyebrow;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(eyebrow, style: AppTheme.eyebrow()),
          Text.rich(
            TextSpan(
              text: value,
              style: AppTheme.display(size: 56, height: 0.82, tracking: -0.06),
              children: [
                const TextSpan(text: ' '),
                TextSpan(
                  text: unit,
                  // The parent span's tight tracking would be inherited.
                  style: AppTheme.body(
                    size: 14,
                    weight: FontWeight.w600,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
