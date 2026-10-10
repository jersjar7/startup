import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../auth/auth_controller.dart';
import 'mastery_model.dart';

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

  final due = DateTime.utc(
    exam.year,
    exam.month,
    exam.day + outcomeAskDays[put],
  );
  return _today(now).compareTo(_today(due)) >= 0;
}

class ExamOutcomeCard extends StatefulWidget {
  const ExamOutcomeCard({
    super.key,
    required this.auth,
    this.onDone,
    this.dismissible = true,
    this.via = 'app',
    this.mastery,
    this.onSetExamDate,
  });

  final AuthController auth;
  final VoidCallback? onDone;

  /// False when the person arrived here by tapping the notification. They
  /// came to answer, so the X is not offered and the only way forward is one
  /// of the three answers (owner, 2026-10-06).
  ///
  /// Not a trap: the system back gesture still works. It is simply not the
  /// path of least resistance any more, which is the point.
  final bool dismissible;

  /// Which surface the answer came from. Recorded so the share of "I did not
  /// sit it" can be compared across surfaces: if forcing a choice is pushing
  /// people to the cheapest tap rather than the true one, that is where it
  /// will show, and it is worth knowing rather than assuming.
  final String via;

  /// Per chapter, used only to name the weakest one to somebody who has to
  /// sit again. Null is fine: the ending just loses that line.
  final Map<String, int>? mastery;

  /// Opens the exam date screen. The one concrete next step for anybody who
  /// failed or did not sit, and the thing that re-arms every reminder.
  final VoidCallback? onSetExamDate;

  @override
  State<ExamOutcomeCard> createState() => _ExamOutcomeCardState();
}

class _ExamOutcomeCardState extends State<ExamOutcomeCard> {
  bool _busy = false;
  bool _askingAttempt = false;
  bool _passed = false;

  /// What to say once the answer is in. Thanking somebody and vanishing is
  /// the wrong ending for the two answers that matter most: a person who
  /// failed and a person who did not turn up are both about to sit again,
  /// and they are the most motivated users on the platform.
  _Ending? _ending;

  Future<void> _answer({required bool sat, bool? passed, int? attempt}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.auth.setExamOutcome(
        sat: sat,
        passed: passed,
        attemptNumber: attempt,
        via: widget.via,
      );
    } catch (_) {
      // Never trap anyone behind a research question. If it did not save, the
      // card simply comes back next time.
    }
    if (!mounted) return;
    final ending = _endingFor(sat: sat, passed: passed);
    if (ending == null) {
      widget.onDone?.call();
      setState(() => _busy = false);
      return;
    }
    setState(() {
      _busy = false;
      _ending = ending;
    });
  }

  /// A pass needs nothing more than thanks. The other two do.
  _Ending? _endingFor({required bool sat, bool? passed}) {
    if (sat && passed == true) return null;
    final weakest = _weakestChapter();
    if (!sat) {
      // No weakest chapter here: they did not sit it, so there is nothing to
      // diagnose and naming one would be a panel the copy never refers to.
      return const _Ending(
        heading: 'That happens.',
        body:
            'Plenty of people move their date. Set a new one and the app '
            'will pick the work back up around it.',
      );
    }
    return _Ending(
      heading: 'Then the next one is the one that counts.',
      body:
          'Only about a third of repeat takers pass, and the usual reason is '
          'that nothing changed about how they studied. Here is the part that '
          'was costing you the most.',
      weakest: weakest,
    );
  }

  /// The chapter where effort moves the weighted number most: low mastery
  /// against a high share of the exam. Already computed for the mastery page.
  String? _weakestChapter() {
    final m = widget.mastery;
    if (m == null || m.isEmpty) return null;
    final ids = focusChapters(m, limit: 1);
    if (ids.isEmpty) return null;
    return chapterMaps[ids.first]?.name;
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

  Widget _buildEnding(_Ending e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT NOW',
          style: AppTheme.eyebrow(size: 11, color: AppColors.ink2),
        ),
        const SizedBox(height: 12),
        Text(e.heading, style: AppTheme.display(size: 26, height: 1.08)),
        const SizedBox(height: 8),
        Text(
          e.body,
          style: AppTheme.body(size: 14, color: AppColors.ink2, height: 1.5),
        ),
        if (e.weakest != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEAKEST, AGAINST ITS SHARE OF THE EXAM',
                  style: AppTheme.eyebrow(size: 9.5, color: AppColors.ink3),
                ),
                const SizedBox(height: 6),
                Text(
                  e.weakest!,
                  style: AppTheme.display(size: 20, height: 1.15),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (widget.onSetExamDate != null)
          _Choice(
            label: 'Set a new exam date',
            onTap: () {
              widget.onSetExamDate!();
              widget.onDone?.call();
            },
          ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: widget.onDone,
            child: Text(
              'Not now',
              style: AppTheme.body(
                size: 14,
                color: AppColors.ink2,
                weight: FontWeight.w600,
              ).copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.butter,
        borderRadius: BorderRadius.circular(32),
      ),
      child: _ending != null
          ? _buildEnding(_ending!)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'HOW DID IT GO?',
                        style: AppTheme.eyebrow(
                          size: 11,
                          color: AppColors.ink2,
                        ),
                      ),
                    ),
                    if (widget.dismissible)
                      GestureDetector(
                        onTap: _busy ? null : _snooze,
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.ink2,
                        ),
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
                    style: AppTheme.body(
                      size: 14,
                      color: AppColors.ink2,
                      height: 1.5,
                    ),
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
                    style: AppTheme.body(
                      size: 14,
                      color: AppColors.ink2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final n in [1, 2, 3])
                        _Choice(
                          label: n == 1
                              ? 'First'
                              : (n == 2 ? 'Second' : 'Third or more'),
                          onTap: _busy
                              ? null
                              : () => _answer(
                                  sat: true,
                                  passed: _passed,
                                  attempt: n,
                                ),
                        ),
                      _Choice(
                        label: 'Rather not say',
                        onTap: _busy
                            ? null
                            : () => _answer(sat: true, passed: _passed),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

/// What the card says once a fail or a no-show is recorded.
class _Ending {
  const _Ending({required this.heading, required this.body, this.weakest});

  final String heading;
  final String body;
  final String? weakest;
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
