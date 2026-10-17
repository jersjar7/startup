import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../daily/daily_calendar.dart';
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart' show appClock;

/// Where the account's XP came from, as `GET /api/account/state` derives it
/// (its `xp` block, added 2026-10-17).
@immutable
class XpSplit {
  const XpSplit({
    required this.total,
    required this.phone,
    required this.web,
    required this.phoneToday,
    required this.phoneDailyCap,
  });

  /// Null when the server sent no split (one older than the block).
  static XpSplit? fromState(Map<String, dynamic> state) {
    final xp = (state['xp'] as Map?)?.cast<String, dynamic>();
    if (xp == null) return null;
    int n(Object? v) => (v as num?)?.toInt() ?? 0;
    return XpSplit(
      total: n(state['totalXp']),
      phone: n(xp['phone']),
      web: n(xp['web']),
      phoneToday: n(xp['phoneToday']),
      phoneDailyCap: n(xp['phoneDailyCap']),
    );
  }

  final int total;
  final int phone;
  final int web;
  final int phoneToday;
  final int phoneDailyCap;

  bool get phoneFullToday => phoneDailyCap > 0 && phoneToday >= phoneDailyCap;
}

/// The XP behind the account sheet's figure, opened by tapping it (owner,
/// 2026-10-17): the total, the app and the website apart, today's app
/// allowance, and how it is earned. The phone's XP is capped per day on the
/// server (`service/xp.js`), and a cap nobody can see reads as rounds that
/// did not count.
class XpScreen extends StatefulWidget {
  const XpScreen({super.key, required this.total, this.load});

  /// The figure the sheet showed, so the page opens on the same number.
  final int total;

  /// Reads the account's state; the signed-in account's by default.
  final Future<Map<String, dynamic>> Function()? load;

  @override
  State<XpScreen> createState() => _XpScreenState();
}

class _XpScreenState extends State<XpScreen> {
  XpSplit? _split;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final load =
          widget.load ??
          () async =>
              await context.read<AuthController>().api.get(
                    '/account/state?date=${dayKey(appClock())}',
                  )
                  as Map<String, dynamic>;
      final split = XpSplit.fromState(await load());
      if (!mounted) return;
      setState(() {
        _split = split;
        _failed = split == null;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) => XpPage(
    total: _split?.total ?? widget.total,
    split: _split,
    failed: _failed,
  );
}

/// The page itself, given the numbers, so a test can draw any state.
///
/// Fog ground, the total as the hero (reference 16), the two halves as cream
/// tiles, today's allowance as a bar, and the rates in one cream card.
class XpPage extends StatelessWidget {
  const XpPage({
    super.key,
    required this.total,
    this.split,
    this.failed = false,
  });

  final int total;
  final XpSplit? split;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final s = split;
    return Scaffold(
      backgroundColor: AppColors.fog,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          children: [
            Row(
              children: [
                RoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  label: 'Back',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
                Text(
                  'TOTAL XP',
                  style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _thousands(total),
                      style: AppTheme.display(
                        size: 118,
                        height: 0.82,
                        tracking: -0.07,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('XP', style: AppTheme.display(size: 26, tracking: -0.03)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Points for practice, in the app and on the website. They '
              'rank the leaderboard. They are not mastery.',
              style: AppTheme.body(size: 16, color: AppColors.mutedOnLight),
            ),
            const SizedBox(height: 26),
            if (failed)
              Text(
                'The server could not be reached, so where it came from '
                'is not shown. Try again with a signal.',
                style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: _Half(label: 'IN THE APP', value: s?.phone),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Half(label: 'ON THE WEBSITE', value: s?.web),
                  ),
                ],
              ),
              if (s != null && s.phoneDailyCap > 0) ...[
                const SizedBox(height: 30),
                _Today(split: s),
              ],
            ],
            const SizedBox(height: 30),
            Text('HOW IT IS EARNED', style: AppTheme.eyebrow()),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The rates are the server's (service/xp.js).
                  _Rate(
                    where: 'In the app',
                    how:
                        '5 for each round right, 2 for a miss, up to '
                        '${s?.phoneDailyCap ?? 60} a day.',
                  ),
                  const SizedBox(height: 14),
                  const _Rate(
                    where: 'On the website',
                    how:
                        '10 for each problem right, 5 for a miss, and 25 '
                        'more for finishing a practice session.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Half extends StatelessWidget {
  const _Half({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.eyebrow(size: 11)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value == null ? '...' : _thousands(value!),
              style: AppTheme.display(size: 44, height: 0.9, tracking: -0.05),
            ),
          ),
        ],
      ),
    );
  }
}

/// Today's app XP against the daily allowance.
class _Today extends StatelessWidget {
  const _Today({required this.split});

  final XpSplit split;

  @override
  Widget build(BuildContext context) {
    final s = split;
    final share = (s.phoneToday / s.phoneDailyCap).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('TODAY IN THE APP', style: AppTheme.eyebrow()),
            const Spacer(),
            Text(
              '${s.phoneToday} of ${s.phoneDailyCap}',
              style: AppTheme.mono(size: 13, weight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Semantics(
          label: '${s.phoneToday} of ${s.phoneDailyCap} XP from the app today',
          child: ExcludeSemantics(
            child: Container(
              height: 12,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppColors.pipOff,
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                widthFactor: share,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          s.phoneFullToday
              ? 'Full for today. Rounds still count toward your concepts, '
                    'and the app\'s XP starts again tomorrow.'
              : 'The app gives up to ${s.phoneDailyCap} a day, so a phone '
                    'never outscores the desk.',
          style: AppTheme.body(size: 14, color: AppColors.mutedOnLight),
        ),
      ],
    );
  }
}

class _Rate extends StatelessWidget {
  const _Rate({required this.where, required this.how});

  final String where;
  final String how;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          where,
          style: AppTheme.display(
            size: 17,
            weight: FontWeight.w700,
            height: 1.2,
            tracking: -0.02,
          ),
        ),
        const SizedBox(height: 3),
        Text(how, style: AppTheme.body(size: 14, color: AppColors.ink2)),
      ],
    );
  }
}

String _thousands(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
