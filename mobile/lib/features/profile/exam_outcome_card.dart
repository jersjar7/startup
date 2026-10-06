import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';

/// Nine days after the exam, the one question worth interrupting for.
///
/// Whether somebody sat the exam and whether they passed are the two records
/// the platform has never collected, and without them there is no way to show
/// a department that any of this works, no way to calibrate a readiness
/// prediction, and no way to learn what coverage actually corresponds to a
/// pass. Everything else the app measures is a proxy for this.
///
/// It appears at the top of the home screen rather than as a dialog, and it
/// can be put away. Somebody who failed is being asked about it, so the card
/// has to be easy to dismiss and must not celebrate before it knows.

/// Date-only, matching how the account stores an exam date.
String _today(DateTime now) => now.toIso8601String().substring(0, 10);

/// Nine days, the same as the email. Results for the computer-based FE arrive
/// within about seven to ten days, so the answer is known but the day is still
/// recent enough to be remembered precisely.
const outcomeAskAfterDays = 9;

/// Whether the card belongs on screen. Pure, so it is the thing under test.
bool shouldAskOutcome(Map<String, dynamic>? user, DateTime now) {
  if (user == null) return false;
  if (user['examOutcomeResolved'] == true) return false;
  final iso = user['examDate'] as String?;
  if (iso == null || iso.isEmpty) return false;
  final exam = DateTime.tryParse(iso);
  if (exam == null) return false;
  final due = DateTime.utc(exam.year, exam.month, exam.day + outcomeAskAfterDays);
  return _today(now).compareTo(_today(due)) >= 0;
}

class ExamOutcomeCard extends StatefulWidget {
  const ExamOutcomeCard({super.key, required this.auth, this.onDone});

  final AuthController auth;
  final VoidCallback? onDone;

  @override
  State<ExamOutcomeCard> createState() => _ExamOutcomeCardState();
}

class _ExamOutcomeCardState extends State<ExamOutcomeCard> {
  bool _busy = false;
  bool _askingAttempt = false;
  bool _passed = false;

  Future<void> _answer({required bool sat, bool? passed, int? attempt}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.auth.setExamOutcome(sat: sat, passed: passed, attemptNumber: attempt);
      widget.onDone?.call();
    } catch (_) {
      // Never trap anyone behind a research question. If it did not save, the
      // card simply comes back next time.
      widget.onDone?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.auth.declineExamOutcome();
    } catch (_) {
      /* same: the card comes back rather than blocking */
    }
    widget.onDone?.call();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'HOW DID IT GO?',
                  style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
                ),
              ),
              GestureDetector(
                onTap: _busy ? null : _decline,
                child: Icon(Icons.close, size: 20, color: AppColors.ink2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_askingAttempt) ...[
            Text(
              'Your exam has been and gone.',
              style: AppTheme.display(size: 26, height: 1.08),
            ),
            const SizedBox(height: 8),
            Text(
              'Telling us is how we learn which study patterns actually lead to '
              'a pass, which makes this better for everyone sitting it after you.',
              style: AppTheme.body(size: 14, color: AppColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Choice(
                    label: 'I passed',
                    onTap: _busy
                        ? null
                        : () => setState(() {
                            _passed = true;
                            _askingAttempt = true;
                          }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Choice(
                    label: 'Not this time',
                    onTap: _busy
                        ? null
                        : () => setState(() {
                            _passed = false;
                            _askingAttempt = true;
                          }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _busy ? null : () => _answer(sat: false),
              child: Text(
                'I did not sit it',
                style: AppTheme.body(
                  size: 14,
                  color: AppColors.ink2,
                  weight: FontWeight.w600,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ] else ...[
            Text(
              _passed ? 'Congratulations.' : 'Thank you for saying.',
              style: AppTheme.display(size: 26, height: 1.08),
            ),
            const SizedBox(height: 8),
            Text(
              _passed
                  ? 'One last thing: which attempt was it?'
                  : 'The repeat population is studied far less than the first-time '
                        'one. Which attempt was this?',
              style: AppTheme.body(size: 14, color: AppColors.ink2, height: 1.5),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final n in [1, 2, 3])
                  _Choice(
                    label: n == 1 ? 'First' : (n == 2 ? 'Second' : 'Third or more'),
                    onTap: _busy
                        ? null
                        : () => _answer(sat: true, passed: _passed, attempt: n),
                  ),
                _Choice(
                  label: 'Rather not say',
                  onTap: _busy ? null : () => _answer(sat: true, passed: _passed),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTheme.body(size: 14.5, weight: FontWeight.w600),
        ),
      ),
    );
  }
}
