import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/device_word.dart';
import '../../core/notifications/notifications.dart';
import '../../core/notifications/reminders_ask.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/road.dart';
import '../../core/theme/tablet.dart';
import '../shared/widgets/kit.dart';

/// The invitation to turn reminders on (mobile/design/reminders-ask, the
/// owner's approved mocks A1, A1n, A2, A3 and T-A1).
///
/// Our own soft ask first; the system dialog only after "Remind me", since
/// iOS shows it once. The copy never names a time of day (owner,
/// 2026-11-04): the plan's hours can move.

/// Where the invitation gets its [Notifications]; replaced in tests.
@visibleForTesting
Notifications Function() remindersNotifications = Notifications.new;

/// Offers the invitation if the rules allow it ([mayAskFor]); counts it as
/// used the moment it shows.
Future<void> offerReminders(
  BuildContext context, {
  required AskMoment moment,
  int streak = 1,
  String? lessonName,
  Notifications? notifications,
}) async {
  final n = notifications ?? remindersNotifications();
  if (!await RemindersAsk.mayAsk(moment, n)) return;
  if (!context.mounted) return;
  // Never over something else: a sheet, a badge, another screen.
  final route = ModalRoute.of(context);
  if (route != null && !route.isCurrent) return;
  await RemindersAsk.recordShown(moment);
  if (!context.mounted) return;
  await showRemindersAskSheet(
    context,
    moment: moment,
    streak: streak,
    lessonName: lessonName,
    notifications: n,
  );
}

/// How long after the road's finishing moment the lesson invitation rises.
const remindersAskSettleMs = 400;

/// The lesson invitation waits for the road to open: the whole finishing
/// moment (or its quiet fade under Reduce Motion), then [remindersAskSettleMs].
Duration lessonAskDelay(BuildContext context) {
  final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final moment = reduce ? AppRoad.reducedFadeMs : AppRoad.momentMs;
  return Duration(milliseconds: moment.round() + remindersAskSettleMs);
}

Future<void> showRemindersAskSheet(
  BuildContext context, {
  required AskMoment moment,
  int streak = 1,
  String? lessonName,
  required Notifications notifications,
}) {
  final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Not now',
    barrierColor: AppColors.scrim,
    transitionDuration: Duration(milliseconds: reduce ? 200 : 500),
    pageBuilder: (_, _, _) => RemindersAskSheet(
      moment: moment,
      streak: streak,
      lessonName: lessonName,
      notifications: notifications,
    ),
    // DESIGN.md: up 60 with a fade, 0.5 s. Reduce Motion: the fade alone.
    transitionBuilder: (_, animation, _, child) {
      final t = CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.2, 0.8, 0.2, 1),
      );
      final faded = FadeTransition(opacity: t, child: child);
      if (reduce) return faded;
      return AnimatedBuilder(
        animation: t,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, 60 * (1 - t.value)),
          child: c,
        ),
        child: faded,
      );
    },
  );
}

enum _Stage { ask, asking, on, denied }

class RemindersAskSheet extends StatefulWidget {
  const RemindersAskSheet({
    super.key,
    required this.moment,
    required this.notifications,
    this.streak = 1,
    this.lessonName,
  });

  final AskMoment moment;
  final Notifications notifications;
  final int streak;
  final String? lessonName;

  /// The confirmed state closes itself after this (SPEC, "After yes").
  static const autoClose = Duration(seconds: 2);

  @override
  State<RemindersAskSheet> createState() => _RemindersAskSheetState();
}

class _RemindersAskSheetState extends State<RemindersAskSheet> {
  var _stage = _Stage.ask;
  double _drag = 0;
  Timer? _close;

  bool get _daily => widget.moment == AskMoment.daily;

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) Navigator.of(context).pop();
  }

  Future<void> _remindMe() async {
    setState(() => _stage = _Stage.asking);
    final on = await widget.notifications.turnOn();
    if (!mounted) return;
    setState(() => _stage = on ? _Stage.on : _Stage.denied);
    if (on) _close = Timer(RemindersAskSheet.autoClose, _dismiss);
  }

  String get _title => switch (_stage) {
    _Stage.on => 'Reminders on.',
    _ when _daily => 'Don\'t let day 1 be your only day.',
    _ => 'One lesson down.\nDon\'t stop at one.',
  };

  String _body(BuildContext context) => switch (_stage) {
    _Stage.on when _daily => 'We will nudge you so the streak keeps going.',
    _Stage.on => 'We will nudge you so the road keeps moving.',
    _Stage.denied =>
      'Notifications are off for this app in your '
          '${deviceNounOf(context)} settings.',
    _ when _daily =>
      'Most streaks end on a busy day, not a hard one. '
          'We can remind you, so yours does not.',
    _ =>
      'We can remind you to keep going. A few minutes a day beats '
          'a night of cramming.',
  };

  @override
  Widget build(BuildContext context) {
    final big = AppTablet.isTablet(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;

    final top = _daily
        ? _StreakBlock(streak: widget.streak, big: big)
        : Text(
            '${(widget.lessonName ?? 'Lesson').toUpperCase()} · CLEARED',
            style: AppTheme.eyebrow(color: AppColors.forest),
          );

    final words = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Grabber(),
        const SizedBox(height: 26),
        top,
        const SizedBox(height: 22),
        BalancedText(
          _title,
          style: AppTheme.display(size: big ? 42 : 38, height: 1),
        ),
        const SizedBox(height: 14),
        Text(
          _body(context),
          style: AppTheme.body(
            size: big ? 17 : 16,
            height: 1.45,
            color: AppColors.ink2,
            // Inter untracked, not the Material body's 0.25.
          ).copyWith(letterSpacing: 0),
        ),
      ],
    );
    // Moment 2 is at least 424 tall with the buttons at its foot, so only
    // the cleared node shows above it. A min-size column given a minimum
    // height spreads the space between its two groups.
    final foot = bottom > 34 ? bottom : 34.0;
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: _daily ? 0 : 424 - 12 - foot),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          words,
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const SizedBox(height: 32), _actions(big)],
          ),
        ],
      ),
    );

    final sheet = Material(
      color: AppColors.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(big ? 32 : 24, 12, big ? 32 : 24, foot),
        child: content,
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: big ? AppTablet.paneSheetMax : double.infinity,
        ),
        child: GestureDetector(
          // A swipe down is "Not now".
          onVerticalDragUpdate: (d) =>
              setState(() => _drag = (_drag + d.delta.dy).clamp(0, 600)),
          onVerticalDragEnd: (d) {
            if (_drag > 80 || (d.primaryVelocity ?? 0) > 700) {
              _dismiss();
            } else {
              setState(() => _drag = 0);
            }
          },
          child: Transform.translate(offset: Offset(0, _drag), child: sheet),
        ),
      ),
    );
  }

  Widget _actions(bool big) {
    // The text action's own 6 of padding sits outside the column's edge, so
    // its words line up with the title's.
    Widget text(String label, VoidCallback onTap) => Transform.translate(
      offset: const Offset(-6, 0),
      child: TextAction(label: label, onTap: onTap),
    );
    Widget done() => SizedBox(
      width: 180,
      child: PillButton(label: 'Done', onTap: _dismiss),
    );

    switch (_stage) {
      case _Stage.on:
        return Row(children: [const Spacer(), done()]);
      case _Stage.denied:
        // iOS opens the app's own page in Settings; elsewhere the line says
        // where to go.
        final settings = defaultTargetPlatform == TargetPlatform.iOS;
        return Row(
          children: [
            if (settings)
              text('Settings', () => launchUrl(Uri.parse('app-settings:'))),
            const Spacer(),
            done(),
          ],
        );
      case _Stage.ask:
      case _Stage.asking:
        final pill = PillButton(
          label: 'Remind me',
          onTap: _stage == _Stage.ask ? _remindMe : null,
        );
        return Row(
          children: [
            if (big) const Spacer(),
            text('Not now', _dismiss),
            const SizedBox(width: 6),
            if (big)
              SizedBox(width: 258, child: pill)
            else
              Expanded(child: pill),
          ],
        );
    }
  }
}

/// The streak the way the Daily draws it: a butter block, the figure at the
/// foot, the eyebrow at the top right.
class _StreakBlock extends StatelessWidget {
  const _StreakBlock({required this.streak, required this.big});

  final int streak;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: big ? 132 : 116,
      padding: EdgeInsets.symmetric(
        vertical: big ? 24 : 20,
        horizontal: big ? 28 : 22,
      ),
      decoration: BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$streak',
                  style: AppTheme.display(
                    size: big ? 84 : 76,
                    height: 0.8,
                    tracking: -0.06,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'day streak',
                  style: AppTheme.body(
                    size: big ? 19 : 17,
                    weight: FontWeight.w600,
                  ).copyWith(letterSpacing: 0),
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.topRight,
            child: Text('STREAK', style: AppTheme.eyebrow()),
          ),
        ],
      ),
    );
  }
}

/// A headline wrapped the way CSS `text-wrap: balance` does: as many lines
/// as it needs, each as even as it can be, so a title never ends on a
/// stranded word. Text with its own line breaks is left as written.
class BalancedText extends StatelessWidget {
  const BalancedText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  /// How much wider than the box one line may be and still be shrunk to it.
  static const shrinkTolerance = 1.04;

  @override
  Widget build(BuildContext context) {
    if (text.contains('\n')) return Text(text, style: style);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final max = box.maxWidth;
        TextPainter at(double w) => TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: direction,
          textScaler: scaler,
        )..layout(maxWidth: w);
        if (!max.isFinite) return Text(text, style: style);
        // A line that misses by a few points is shrunk to fit rather than
        // broken (a 640 tablet sheet and DM Sans's real widths).
        final natural = at(double.infinity).width;
        if (natural > max && natural <= max * shrinkTolerance) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(text, style: style, maxLines: 1),
          );
        }
        final lines = at(max).computeLineMetrics().length;
        if (lines <= 1) return Text(text, style: style);
        var lo = max / lines;
        var hi = max;
        while (hi - lo > 1) {
          final mid = (lo + hi) / 2;
          if (at(mid).computeLineMetrics().length > lines) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: hi.ceilToDouble(),
            child: Text(text, style: style),
          ),
        );
      },
    );
  }
}
