import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/kit.dart';
import '../study/study_tab.dart' show appClock;

/// "When's the big day?" (reference 04): set, change or clear the exam date
/// from the phone. A spring ground, month chips, the date as the hero, a
/// seven-day strip to pick the day, save at the bottom right and the clear
/// at the bottom left. The website's rule applies: within a year from today.
class ExamDateScreen extends StatefulWidget {
  const ExamDateScreen({super.key, this.initial});

  /// The date on the account, YYYY-MM-DD, or null when none is set.
  final String? initial;

  @override
  State<ExamDateScreen> createState() => _ExamDateScreenState();
}

class _ExamDateScreenState extends State<ExamDateScreen> {
  late DateTime _today;
  late DateTime _picked;
  bool _saving = false;
  String? _error;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  static const _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    final now = appClock();
    _today = DateTime(now.year, now.month, now.day);
    final initial = widget.initial == null
        ? null
        : DateTime.tryParse(widget.initial!);
    _picked = initial != null && !initial.isBefore(_today)
        ? DateTime(initial.year, initial.month, initial.day)
        : _today;
  }

  /// The twelve months a date can fall in, this one first.
  List<DateTime> get _monthStarts => [
    for (var i = 0; i < 13; i++) DateTime(_today.year, _today.month + i, 1),
  ];

  DateTime get _latest => DateTime(_today.year + 1, _today.month, _today.day);

  bool _allowed(DateTime d) => !d.isBefore(_today) && !d.isAfter(_latest);

  void _pickMonth(DateTime start) {
    final last = DateTime(start.year, start.month + 1, 0).day;
    var d = DateTime(start.year, start.month, _picked.day.clamp(1, last));
    if (d.isBefore(_today)) d = _today;
    if (d.isAfter(_latest)) d = _latest;
    setState(() => _picked = d);
  }

  /// The strip: the picked day in the middle, three each side, clipped to
  /// the month's own days.
  List<DateTime> get _strip {
    final first = DateTime(_picked.year, _picked.month, 1);
    final last = DateTime(_picked.year, _picked.month + 1, 0);
    var start = _picked.subtract(const Duration(days: 3));
    if (start.isBefore(first)) start = first;
    var end = start.add(const Duration(days: 6));
    if (end.isAfter(last)) {
      end = last;
      start = end.subtract(const Duration(days: 6));
      if (start.isBefore(first)) start = first;
    }
    return [
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1)))
        d,
    ];
  }

  String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _write(String? iso) async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final auth = context.read<AuthController>();
    try {
      await auth.api.put('/user/profile', {'examDate': iso});
      await auth.refreshMe();
      if (!mounted) return;
      Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not reach the server. Try again in a moment.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = widget.initial != null;
    final out = _picked.difference(_today).inDays;
    final outLabel = out == 0
        ? 'today'
        : out == 1
        ? '1 day out'
        : '$out days out';

    return Scaffold(
      backgroundColor: AppColors.spring,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundIconButton(
                icon: Icons.chevron_left_rounded,
                label: 'Back',
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 30),
              Text("When's the\nbig day?", style: AppTheme.display(size: 48)),
              const Spacer(),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    for (final m in _monthStarts) ...[
                      _MonthChip(
                        label: _months[m.month - 1],
                        on: m.year == _picked.year && m.month == _picked.month,
                        onTap: () => _pickMonth(m),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '${_months[_picked.month - 1]} ${_picked.day}',
                style: AppTheme.display(size: 96, height: 0.9, tracking: -0.06),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    _weekdayNames[_picked.weekday - 1].toUpperCase(),
                    style: AppTheme.eyebrow(size: 13),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        outLabel,
                        style: AppTheme.mono(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.spring,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  for (final d in _strip)
                    Expanded(
                      child: _DayCell(
                        weekday: _weekdays[d.weekday - 1],
                        day: d.day,
                        on: d == _picked,
                        enabled: _allowed(d),
                        onTap: () => setState(() => _picked = d),
                      ),
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: AppTheme.body(size: 14, color: AppColors.charcoal),
                ),
              ],
              const SizedBox(height: 34),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextAction(
                    label: hasDate ? 'Clear the date' : 'No date yet',
                    onTap: _saving
                        ? () {}
                        : hasDate
                        ? () => _write(null)
                        : () => Navigator.of(context).maybePop(),
                  ),
                  RoundNextButton(
                    label: 'Save',
                    loading: _saving,
                    onTap: () => _write(_iso(_picked)),
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
                color: on ? AppColors.spring : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.weekday,
    required this.day,
    required this.on,
    required this.enabled,
    required this.onTap,
  });

  final String weekday;
  final int day;
  final bool on;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 92,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: on ? AppColors.charcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: AppTheme.eyebrow(
                  size: 11,
                  color: on ? AppColors.spring : AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$day',
                style: AppTheme.display(
                  size: on ? 26 : 22,
                  height: 1,
                  tracking: -0.03,
                  color: on ? AppColors.spring : AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
