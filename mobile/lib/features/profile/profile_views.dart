import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../games/game_catalog.dart';
import '../shared/widgets/kit.dart';
import '../shared/widgets/raccoon_peek.dart';
import '../study/chapter_bands.dart' show cardNameFor;

/// Profile as a page of type, not a stack of tiles (owner, 2026-10-16:
/// "your excessive use of containers is really affecting the design").
///
/// The fog ground carries everything. A headline says where the student is,
/// three facts sit under it as big numbers with words beside them, and one
/// pill at the bottom does the one thing worth doing next, with the raccoon
/// peeking over it. Nothing here repeats a tab: the Daily has its own and is
/// never offered here.
///
/// Two faces. Every student opens the app with nothing done in it, so
/// [ProfileFirst] is what everybody sees first; [ProfileUnderway] takes over
/// at the first cleared round and never gives way back. Underway counts
/// rounds, the smallest thing that moves, so one round already shows.

/// What the website already knows, when it knows anything.
class WebsiteFacts {
  const WebsiteFacts({
    required this.mastery,
    required this.daysStudied,
    this.focus,
  });

  final int mastery;
  final int daysStudied;

  /// The chapter costing the most exam points (focusChapters).
  final ChapterMap? focus;

  bool get any => mastery > 0 || daysStudied > 0;
}

/// The exam date: unset, or days to go and the date in words.
class ExamFacts {
  const ExamFacts({this.days, this.label});

  final int? days;
  final String? label; // "Wed, Nov 18"

  bool get set => days != null;
}

/// Nothing done in the app yet.
class ProfileFirst extends StatelessWidget {
  const ProfileFirst({
    super.key,
    required this.top,
    required this.name,
    required this.exam,
    required this.onStart,
    required this.onExam,
    this.website,
    this.onMastery,
    this.onDays,
    this.passCard = false,
    this.onPassCard,
  });

  final Widget top;
  final String name;
  final ExamFacts exam;
  final WebsiteFacts? website;

  /// A pass is on record (it can be, from the website, before the app has
  /// been used at all). The card takes the exam's place for good.
  final bool passCard;
  final VoidCallback? onPassCard;
  final void Function(ChapterMap chapter) onStart;
  final VoidCallback onExam;
  final VoidCallback? onMastery;
  final VoidCallback? onDays;

  @override
  Widget build(BuildContext context) {
    final web = website != null && website!.any ? website : null;
    final start = web?.focus ?? chapterMaps['mathematics']!;
    final lessons = chapterMaps.values.fold<int>(
      0,
      (s, c) => s + c.lessons.length,
    );
    return _Page(
      top: top,
      // A name when there is one; the sentence stands without it.
      headline: web == null
          ? _named(name, 'your FE prep starts here.')
          : _named(name, 'your website work came with you.'),
      facts: [
        if (web == null) ...[
          _Fact(
            big: '${chapterMaps.length}',
            unit: 'chapters',
            line: 'Everything the FE Civil exam covers',
          ),
          _Fact(
            big: '$lessons',
            unit: 'lessons',
            line: 'A few minutes each, one at a time',
          ),
        ] else ...[
          _Fact(
            big: '${web.daysStudied}',
            unit: web.daysStudied == 1 ? 'day' : 'days',
            line: 'Studied on the website',
            onTap: onDays,
          ),
          _Fact(
            big: '${web.mastery}%',
            unit: 'mastery',
            line: 'Not a probability of passing',
            onTap: onMastery,
          ),
        ],
        if (passCard)
          _PassCardFact(onTap: onPassCard)
        else
          _ExamFact(exam: exam, onTap: onExam),
      ],
      // The chapter goes under the pill: "Start with Structural
      // Engineering" does not fit one.
      action: 'Start here',
      // One line, the chapter trimmed first, as on the underway face.
      underLead: cardNameFor(start),
      under: web == null ? 'where most begin' : 'most points left',
      onAction: () => onStart(start),
    );
  }
}

/// At least one round cleared in the app.
class ProfileUnderway extends StatelessWidget {
  const ProfileUnderway({
    super.key,
    required this.top,
    required this.name,
    required this.lessonName,
    this.chapterName = '',
    required this.roundsInLesson,
    required this.roundsCleared,
    required this.daysStudied,
    required this.exam,
    required this.onCarryOn,
    required this.onDays,
    required this.onExam,
    this.mastery,
    this.onMastery,
    this.passCard = false,
    this.onPassCard,
    this.allDone = false,
  });

  final Widget top;
  final String name;
  final String lessonName;

  /// The chapter's short name ("Statics", "Mechanics of Materials").
  final String chapterName;

  final bool passCard;
  final VoidCallback? onPassCard;

  /// Every lesson in the app cleared.
  final bool allDone;
  final int roundsInLesson;
  final int roundsCleared;
  final int daysStudied;
  final ExamFacts exam;

  /// Website mastery, shown once there is any.
  final int? mastery;
  final VoidCallback onCarryOn;
  final VoidCallback onDays;
  final VoidCallback onExam;
  final VoidCallback? onMastery;

  @override
  Widget build(BuildContext context) {
    final left = roundsInLesson - roundsCleared;
    final greeting = allDone
        ? 'Every lesson done'
        : daysStudied <= 1
        ? 'Good start'
        : 'Welcome back';
    return _Page(
      top: top,
      headline: name.isEmpty ? '$greeting.' : '$greeting, $name.',
      facts: [
        if (allDone)
          _Fact(
            big: '${chapterMaps.length}',
            unit: 'chapters',
            line: 'Every round of every one. The Daily keeps them warm',
          )
        else
          _Fact(
            big: '$left',
            unit: left == 1 ? 'round left' : 'rounds left',
            line: 'In $lessonName',
            bar: roundsInLesson == 0 ? 0 : roundsCleared / roundsInLesson,
          ),
        _Fact(
          big: '$daysStudied',
          unit: daysStudied == 1 ? 'day studied' : 'days studied',
          line: daysStudied == 1
              ? 'Come back tomorrow to make it two'
              : 'Across the app and the website',
          onTap: onDays,
        ),
        if (passCard)
          _PassCardFact(onTap: onPassCard)
        else if (mastery != null && mastery! > 0)
          _Fact(
            big: '$mastery%',
            unit: 'mastery',
            line: 'Not a probability of passing',
            onTap: onMastery,
          )
        else
          _ExamFact(exam: exam, onTap: onExam),
      ],
      action: allDone ? 'Review in Study' : 'Carry on',
      // "Statics · Round 7 of 18" on one line (owner, 2026-10-16): the
      // chapter gives way when space runs out, the round count never does.
      underLead: allDone || chapterName.isEmpty ? null : chapterName,
      under: allDone
          ? 'Any chapter, any time'
          : 'Round ${roundsCleared + 1} of $roundsInLesson',
      onAction: onCarryOn,
    );
  }
}

/// "Sam, your FE prep starts here." or, with no name, "Your FE prep starts
/// here."
String _named(String name, String rest) => name.isEmpty
    ? '${rest[0].toUpperCase()}${rest.substring(1)}'
    : '$name, $rest';

/// The pass card, once a pass is recorded: for good, so nobody has to find
/// the email again (ADR 0023).
class _PassCardFact extends StatelessWidget {
  const _PassCardFact({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You passed the FE.',
                  style: AppTheme.display(
                    size: 28,
                    height: 1.1,
                    tracking: -0.04,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your pass card',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedOnLight,
          ),
        ],
      ),
    );
  }
}

/// The shared page: the date and avatar, the headline, the facts, and the
/// one pill with the raccoon on it.
class _Page extends StatelessWidget {
  const _Page({
    required this.top,
    required this.headline,
    required this.facts,
    required this.action,
    required this.under,
    required this.onAction,
    this.underLead,
  });

  final Widget top;
  final String headline;
  final List<Widget> facts;
  final String action;
  final String under;

  /// Said before [under] on the same line, and the part that is trimmed
  /// when the line is too long for the phone.
  final String? underLead;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          top,
          const SizedBox(height: 18),
          Text(
            headline,
            style: AppTheme.display(size: 46, height: 0.98, tracking: -0.045),
          ),
          const SizedBox(height: 30),
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) const SizedBox(height: 22),
            facts[i],
          ],
          // The raccoon stands on the pill, so its head always has room
          // above it, however tall the facts run.
          const SizedBox(height: RaccoonPeek.height + 12),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Brand green, not charcoal: the raccoon's nose is charcoal and
              // vanished into a charcoal pill (owner, 2026-10-16).
              PillButton(
                label: action,
                onTap: onAction,
                fill: AppColors.forest,
              ),
              const Positioned(
                left: 26,
                top: -RaccoonPeek.baseline,
                child: IgnorePointer(child: RaccoonPeek()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (underLead != null) ...[
                Flexible(
                  child: Text(
                    underLead!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono(
                      size: 12,
                      color: AppColors.mutedOnLight,
                    ),
                  ),
                ),
                Text(
                  ' · ',
                  style: AppTheme.mono(size: 12, color: AppColors.mutedOnLight),
                ),
              ],
              // Never trimmed while there is a lead to give way; trimmed
              // itself only when it is the whole line.
              if (underLead != null)
                Text(
                  under,
                  maxLines: 1,
                  style: AppTheme.mono(size: 12, color: AppColors.mutedOnLight),
                )
              else
                Flexible(
                  child: Text(
                    under,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono(
                      size: 12,
                      color: AppColors.mutedOnLight,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

/// A big number with its unit on the baseline, and one line of words.
class _Fact extends StatelessWidget {
  const _Fact({
    required this.big,
    required this.unit,
    required this.line,
    this.bar,
    this.onTap,
  });

  final String big;
  final String unit;
  final String line;

  /// A thin bar under the line, 0 to 1, for something under way.
  final double? bar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              big,
              style: AppTheme.display(size: 52, height: 0.9, tracking: -0.06),
            ),
            const SizedBox(width: 8),
            Text(
              unit,
              style: AppTheme.display(
                size: 20,
                weight: FontWeight.w700,
                tracking: -0.02,
              ),
            ),
            if (onTap != null) ...[
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedOnLight,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          line,
          style: AppTheme.body(size: 15, color: AppColors.mutedOnLight),
        ),
        if (bar != null) ...[const SizedBox(height: 10), _Bar(fraction: bar!)],
      ],
    );
    if (onTap == null) return body;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: body,
    );
  }
}

/// The exam date, or a plain question with a link when there is none. Never
/// a countdown to a date the student did not give us.
class _ExamFact extends StatelessWidget {
  const _ExamFact({required this.exam, required this.onTap});

  final ExamFacts exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (exam.set) {
      return _Fact(
        big: '${exam.days}',
        unit: exam.days == 1 ? 'day to the exam' : 'days to the exam',
        line: exam.label ?? '',
        onTap: onTap,
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When is your exam?',
            style: AppTheme.display(size: 28, height: 1.1, tracking: -0.04),
          ),
          const SizedBox(height: 6),
          const Text(
            'Set the date',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: double.infinity,
        height: 8,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: AppColors.pipOff)),
            FractionallySizedBox(
              widthFactor: fraction.clamp(0.03, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
