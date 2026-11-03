import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tablet.dart';
import '../games/game_catalog.dart';
import '../league/league_coin.dart';
import '../league/league_model.dart';
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
    this.league,
    this.onLeague,
  });

  final Widget top;
  final String name;
  final ExamFacts exam;
  final WebsiteFacts? website;

  /// This week's league, once the student has joined it: the fourth figure
  /// (owner, 2026-11-01, "four in Profile"; ADR 0037).
  final LeagueView? league;
  final VoidCallback? onLeague;

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
          if (_shows(league)) _LeagueFact(view: league!, onTap: onLeague),
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
    required this.headline,
    required this.onCarryOn,
    required this.onDays,
    required this.onExam,
    this.mastery,
    this.onMastery,
    this.passCard = false,
    this.onPassCard,
    this.allDone = false,
    this.league,
    this.onLeague,
  });

  /// This week's league, once joined: the fourth figure (ADR 0037).
  final LeagueView? league;
  final VoidCallback? onLeague;

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

  /// Worked out by [underwayHeadline], from what is true today.
  final String headline;

  /// Website mastery, shown once there is any.
  final int? mastery;
  final VoidCallback onCarryOn;
  final VoidCallback onDays;
  final VoidCallback onExam;
  final VoidCallback? onMastery;

  @override
  Widget build(BuildContext context) {
    final left = roundsInLesson - roundsCleared;
    return _Page(
      top: top,
      headline: headline,
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
        if (_shows(league)) _LeagueFact(view: league!, onTap: onLeague),
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

/// What Profile's headline says once work is under way (owner, 2026-10-16):
/// what is true about the student today, never a phrase picked at random.
/// Checked in order, first match wins. Pure, so every case is tested.
///
/// [run] is the days in a row ending on that day (`runToLastDay` on the
/// account), never the cumulative days studied, which the account calls
/// `currentStreak` for history's sake.
///
/// [lastStudyAtOpen] is the last day studied as it stood when the app
/// opened, so a round played a minute ago does not count as an earlier visit.
String underwayHeadline({
  required String name,
  required DateTime today,
  String? lastStudyAtOpen,
  int run = 0,
  int totalDays = 0,
  int? examDays,
  String? chapterJustDone,
  bool allDone = false,
}) {
  String said(String s) => name.isEmpty ? '$s.' : '$s, $name.';
  if (allDone) return said('Every lesson done');
  final last = DateTime.tryParse(lastStudyAtOpen ?? '');
  final day = DateTime(today.year, today.month, today.day);
  final away = last == null
      ? null
      : day.difference(DateTime(last.year, last.month, last.day)).inDays;
  if (away == 0) return said('Back for more');
  // Days in a row, alive only while the last one is today or yesterday. A
  // run that broke is never mentioned: the count that matters is the total,
  // which never resets (service/streak.js).
  if (run >= 3 && away != null && away <= 1) return said('$run days running');
  if (away != null && away >= 3) return said('Good to see you again');
  if (examDays != null && examDays >= 0 && examDays <= 14) {
    return examDays <= 3 ? said('Almost there') : said('$examDays days to go');
  }
  if (chapterJustDone != null) return '$chapterJustDone, done.';
  // The first day, and only the first: a returning student whose last day
  // did not arrive is still welcomed back.
  if (last == null && totalDays <= 1) return said('Good start');
  return said('Welcome back');
}

/// "Sam, your FE prep starts here." or, with no name, "Your FE prep starts
/// here."
String _named(String name, String rest) => name.isEmpty
    ? '${rest[0].toUpperCase()}${rest.substring(1)}'
    : '$name, $rest';

/// The league line shows once the student is on this week's board; before
/// their first XP of the week there is no place to show.
bool _shows(LeagueView? v) => v != null && v.joined && v.me != null;

/// "4th in Silver", the coin beside it, and the week under it.
class _LeagueFact extends StatelessWidget {
  const _LeagueFact({required this.view, this.onTap});

  final LeagueView view;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final me = view.me!;
    return Semantics(
      button: onTap != null,
      label:
          '${ordinal(me.place)} in the ${view.metal.label} league, '
          'of ${view.rows.length} this week',
      child: ExcludeSemantics(
        child: _Fact(
          big: ordinal(me.place),
          unit: 'in ${view.metal.label}',
          trailing: LeagueCoin(metal: view.metal, size: 26),
          line: 'Of ${view.rows.length} this week, ends Saturday',
          onTap: onTap,
        ),
      ),
    );
  }
}

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
    final size = AppTablet.of(context);
    if (size == SizeClass.expanded) return _expanded(context);
    if (size == SizeClass.medium) return _medium(context);
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
          ..._pill(),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  /// The pill with the raccoon on it, and the mono line under it.
  List<Widget> _pill() => [
    Stack(
      clipBehavior: Clip.none,
      children: [
        // Brand green, not charcoal: the raccoon's nose is charcoal and
        // vanished into a charcoal pill (owner, 2026-10-16).
        PillButton(label: action, onTap: onAction, fill: AppColors.forest),
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
              style: AppTheme.mono(size: 12, color: AppColors.mutedOnLight),
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
              style: AppTheme.mono(size: 12, color: AppColors.mutedOnLight),
            ),
          ),
      ],
    ),
  ];

  /// The pill capped at the tablet's pill width (TABLET.md section 7).
  Widget _cappedPill() => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: AppTablet.pillMax),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _pill(),
    ),
  );

  /// T09: the headline and the pill on the left, the facts on the right.
  Widget _expanded(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTablet.paneX,
        AppTablet.spaceTop,
        AppTablet.paneX + 8,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          top,
          const SizedBox(height: 40),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headline,
                        style: AppTheme.display(
                          size: 96,
                          height: 0.94,
                          tracking: -0.05,
                        ),
                      ),
                      const SizedBox(height: RaccoonPeek.height + 32),
                      const Spacer(),
                      _cappedPill(),
                      const SizedBox(height: AppTablet.spaceTop),
                    ],
                  ),
                ),
                const SizedBox(width: 64),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppTablet.paneX),
                    child: _FactLook(
                      look: FactLookData.tablet,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < facts.length; i++) ...[
                            if (i > 0) const SizedBox(height: 46),
                            facts[i],
                          ],
                          const SizedBox(height: AppTablet.spaceTop),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// T09p: the fact Carry on acts on leads, the other three in a row under
  /// it, Carry on bottom right.
  Widget _medium(BuildContext context) {
    final rest = facts.skip(1).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTablet.paneX,
        AppTablet.spaceTop,
        AppTablet.paneX + 8,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          top,
          const SizedBox(height: 40),
          Text(
            headline,
            style: AppTheme.display(size: 92, height: 0.94, tracking: -0.05),
          ),
          const SizedBox(height: 46),
          const Spacer(),
          if (facts.isNotEmpty)
            _FactLook(look: FactLookData.lead, child: facts.first),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: 56),
            _FactLook(
              look: FactLookData.row,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < rest.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppTablet.paneGap),
                    Expanded(child: rest[i]),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: RaccoonPeek.height + 32),
          const Spacer(),
          Align(alignment: Alignment.centerRight, child: _cappedPill()),
          const SizedBox(height: AppTablet.spaceTop),
        ],
      ),
    );
  }
}

/// How big a fact is drawn. The phone's sizes unless a tablet layout says
/// otherwise (TABLET.md section 7, "tile number").
class FactLookData {
  const FactLookData({
    required this.big,
    required this.unit,
    required this.lineSize,
    this.unitUnder = false,
  });

  final double big;
  final double unit;
  final double lineSize;

  /// The unit on its own line under the figure (the row of three, T09p).
  final bool unitUnder;

  static const phone = FactLookData(big: 52, unit: 20, lineSize: 15);
  static const tablet = FactLookData(big: 84, unit: 28, lineSize: 17);
  static const lead = FactLookData(big: 150, unit: 40, lineSize: 17);
  static const row = FactLookData(
    big: 76,
    unit: 24,
    lineSize: 17,
    unitUnder: true,
  );
}

class _FactLook extends InheritedWidget {
  const _FactLook({required this.look, required super.child});

  final FactLookData look;

  static FactLookData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_FactLook>()?.look ??
      FactLookData.phone;

  @override
  bool updateShouldNotify(_FactLook old) => old.look != look;
}

/// A big number with its unit on the baseline, and one line of words.
class _Fact extends StatelessWidget {
  const _Fact({
    required this.big,
    required this.unit,
    required this.line,
    this.bar,
    this.onTap,
    this.trailing,
  });

  final String big;
  final String unit;
  final String line;

  /// Something small after the unit (the league's coin).
  final Widget? trailing;

  /// A thin bar under the line, 0 to 1, for something under way.
  final double? bar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final look = _FactLook.of(context);
    final unitText = Text.rich(
      TextSpan(
        text: unit,
        children: [
          // The coin rides the unit's line, centred on its letters.
          if (trailing != null && !look.unitUnder)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: trailing,
              ),
            ),
        ],
      ),
      style: AppTheme.display(
        size: look.unit,
        weight: FontWeight.w700,
        tracking: -0.02,
      ),
    );
    final chevron = onTap == null
        ? null
        : const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedOnLight,
          );
    final figure = Text(
      big,
      style: AppTheme.display(size: look.big, height: 0.9, tracking: -0.06),
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (look.unitUnder) ...[
          Row(
            children: [
              figure,
              if (trailing != null) ...[
                const SizedBox(width: 12),
                SizedBox.square(
                  dimension: look.unit * 1.5,
                  child: FittedBox(child: trailing),
                ),
              ],
              if (chevron != null) ...[const Spacer(), chevron],
            ],
          ),
          const SizedBox(height: 8),
          unitText,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              figure,
              SizedBox(width: look == FactLookData.phone ? 8 : 14),
              if (look == FactLookData.phone)
                unitText
              else
                Expanded(child: unitText),
              if (chevron != null) ...[
                if (look == FactLookData.phone) const Spacer(),
                chevron,
              ],
            ],
          ),
        SizedBox(height: look == FactLookData.phone ? 4 : 10),
        Text(
          line,
          style: AppTheme.body(
            size: look.lineSize,
            color: AppColors.mutedOnLight,
          ),
        ),
        if (bar != null) ...[
          SizedBox(height: look == FactLookData.phone ? 10 : 18),
          _Bar(fraction: bar!),
        ],
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
