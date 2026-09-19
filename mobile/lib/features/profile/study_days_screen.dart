import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart' show appClock;

/// The calendar behind the butter "days studied" tile (reference 17): the
/// count as the hero, then a month at a time with each studied day a
/// charcoal disc. The list comes from the server (`/sync/study-days`); the
/// count is the same cumulative one the tile and the website show.
class StudyDaysScreen extends StatefulWidget {
  const StudyDaysScreen({super.key, required this.count, this.days});

  /// The cumulative days-studied count on the account.
  final int count;

  /// The studied days, YYYY-MM-DD, when the caller already has them (tests
  /// do); otherwise they are fetched.
  final List<String>? days;

  @override
  State<StudyDaysScreen> createState() => _StudyDaysScreenState();
}

class _StudyDaysScreenState extends State<StudyDaysScreen> {
  late final DateTime _today;
  late DateTime _month;
  Set<String>? _days;
  bool _failed = false;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final now = appClock();
    _today = DateTime(now.year, now.month, now.day);
    _month = DateTime(_today.year, _today.month, 1);
    if (widget.days != null) {
      _days = widget.days!.toSet();
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final data =
          await context.read<AuthController>().api.get('/sync/study-days')
              as Map<String, dynamic>;
      if (!mounted) return;
      setState(
        () => _days = ((data['days'] as List?) ?? []).cast<String>().toSet(),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// The earliest studied day on record, or null.
  DateTime? get _since {
    final days = _days;
    if (days == null || days.isEmpty) return null;
    final first = days.reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
    return DateTime.tryParse(first);
  }

  /// This month back to the first studied month, newest first.
  List<DateTime> get _monthStarts {
    final since = _since ?? _today;
    final oldest = DateTime(since.year, since.month, 1);
    final out = <DateTime>[];
    for (
      var m = _month.isAfter(oldest)
          ? DateTime(_today.year, _today.month, 1)
          : oldest;
      !m.isBefore(oldest);
      m = DateTime(m.year, m.month - 1, 1)
    ) {
      out.add(m);
    }
    return out.isEmpty ? [DateTime(_today.year, _today.month, 1)] : out;
  }

  @override
  Widget build(BuildContext context) {
    final days = _days ?? const <String>{};
    final since = _since;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final elapsed = _month.year == _today.year && _month.month == _today.month
        ? _today.day
        : _month.isBefore(_today)
        ? daysInMonth
        : 0;
    var studiedThisMonth = 0;
    for (var d = 1; d <= daysInMonth; d++) {
      if (days.contains(_iso(DateTime(_month.year, _month.month, d)))) {
        studiedThisMonth++;
      }
    }
    // Monday-first grid.
    final lead = _month.weekday - 1;
    final months = _monthStarts;

    return Scaffold(
      backgroundColor: AppColors.butter,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    'DAYS STUDIED',
                    style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text.rich(
                TextSpan(
                  text: '${widget.count}',
                  style: AppTheme.display(
                    size: 124,
                    height: 0.82,
                    tracking: -0.07,
                  ),
                  children: [
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: widget.count == 1 ? 'day' : 'days',
                      style: AppTheme.display(
                        size: 28,
                        weight: FontWeight.w700,
                        height: 0.82,
                        tracking: -0.03,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _failed
                    ? 'Could not load your days. Pull back and try again.'
                    : since == null
                    ? 'Every day you play a game or open a lesson counts once, '
                          'and the number only ever goes up.'
                    : 'Since ${_months[since.month - 1].substring(0, 3)} ${since.day}. '
                          'Every day you play a game or open a lesson counts once, '
                          'and the number only ever goes up.',
                style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (final m in months) ...[
                      _MonthChip(
                        label: _months[m.month - 1].substring(0, 3),
                        on: m == _month,
                        onTap: () => setState(() => _month = m),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _months[_month.month - 1],
                    style: AppTheme.display(size: 34),
                  ),
                  const Spacer(),
                  Text(
                    elapsed == 0 ? '' : '$studiedThisMonth OF $elapsed DAYS',
                    style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final w in const [
                    'MO',
                    'TU',
                    'WE',
                    'TH',
                    'FR',
                    'SA',
                    'SU',
                  ])
                    Center(
                      child: Text(
                        w,
                        style: AppTheme.eyebrow(color: AppColors.mutedOnLight),
                      ),
                    ),
                  for (var i = 0; i < lead; i++) const SizedBox.shrink(),
                  for (var d = 1; d <= daysInMonth; d++)
                    _Cell(
                      day: d,
                      studied: days.contains(
                        _iso(DateTime(_month.year, _month.month, d)),
                      ),
                      today: DateTime(_month.year, _month.month, d) == _today,
                      future: DateTime(
                        _month.year,
                        _month.month,
                        d,
                      ).isAfter(_today),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.on,
    required this.onTap,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: on ? AppColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          widthFactor: 1,
          child: Opacity(
            opacity: on ? 1 : 0.7,
            child: Text(
              label.toUpperCase(),
              style: AppTheme.eyebrow(
                size: 13,
                color: on ? AppColors.butter : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.day,
    required this.studied,
    required this.today,
    required this.future,
  });

  final int day;
  final bool studied;
  final bool today;
  final bool future;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: studied
            ? AppColors.charcoal
            : today
            ? AppColors.cream
            : Colors.transparent,
      ),
      child: Center(
        child: Opacity(
          opacity: studied || today ? 1 : (future ? 0.28 : 0.6),
          child: Text(
            '$day',
            style: AppTheme.mono(
              size: 14,
              weight: FontWeight.w600,
              color: studied ? AppColors.butter : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
