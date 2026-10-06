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
/// It appears at the top of the home screen rather than as a dialog, and the X
/// puts it away at once. Somebody who failed is being asked about it, so the
/// card has to be easy to dismiss and must not celebrate before it knows.
///
/// There is deliberately NO permanent "never ask me" here (owner, 2026-10-06).
/// After the exam this is a departing user with perhaps one or two opens left,
/// so a one-tap way to remove themselves from the only dataset that matters
/// costs more than it protects. What makes that fair rather than nagging is
/// that the sequence ends itself: four asks across sixty days and then silence,
/// with the X giving immediate relief every time.

/// Date-only, matching how the account stores an exam date.
String _today(DateTime now) => now.toIso8601String().substring(0, 10);

/// Nine days, the same as the email. Results for the computer-based FE arrive
/// within about seven to ten days, so the answer is known but the day is still
/// recent enough to be remembered precisely.
const outcomeAskAfterDays = 9;

/// When each ask is due, in days after the exam. Mirrors ASK_DAYS in
/// service/examOutcome.js, so the phone and the email are equally persistent
/// rather than the phone giving up after one dismissal (owner, 2026-10-06).
///
/// Four touches and then silence. The sequence exists because non-response is
/// biased: somebody who failed is less likely to say so, and a pass rate built
/// from mostly passers is inflated and worse than no data at all.
const outcomeAskDays = [outcomeAskAfterDays, 16, 30, 60];

/// Whether the card belongs on screen. Pure, so it is the thing under test.
bool shouldAskOutcome(Map<String, dynamic>? user, DateTime now) {
  if (user == null) return false;
  // Only an explicit refusal, or an answer, ends it.
  if (user['examOutcomeResolved'] == true) return false;
  final iso = user['examDate'] as String?;
  if (iso == null || iso.isEmpty) return false;
  final exam = DateTime.tryParse(iso);
  if (exam == null) return false;

  // Putting the card away moves to the next ask rather than ending the
  // sequence. After the fourth it goes quiet for good.
  final put = (user['examOutcomeSnoozes'] as int?) ?? 0;
  if (put >= outcomeAskDays.length) return false;

  final due = DateTime.utc(exam.year, exam.month, exam.day + outcomeAskDays[put]);
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

  /// The X. Not an answer: it moves to the next ask in the sequence, the same
  /// way the email does, so one dismissal does not end the question forever.
  Future<void> _snooze() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.auth.snoozeExamOutcome();
    } catch (_) {
      /* never trap anyone behind a research question */
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
                onTap: _busy ? null : _snooze,
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              ],
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
