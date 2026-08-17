import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/mastery_ring.dart';
import 'lesson_screen.dart';
import 'models.dart';
import 'progress_models.dart';
import 'content_repository.dart';
import 'package:provider/provider.dart';
import '../auth/auth_controller.dart';

/// Tab 1, Level 2 — chapter detail: subtopics as a numbered-hairline accordion
/// grouping the lessons. Header carries the chapter mastery ring.
class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key, required this.chapter, required this.masteryPct});

  final Chapter chapter;
  final int masteryPct;

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  int? _open = 0; // first subtopic open by default

  // Progress is fetched separately and never blocks the page: the content is
  // already loaded, so a slow or failed progress call must not stop somebody
  // reading a chapter.
  //
  // `null` means NOT KNOWN, which is not the same as "untouched" and must never
  // be drawn as though the user has done nothing. `_progressFailed` records a
  // real failure so the screen can say the markers are unavailable instead of
  // quietly reporting zeros.
  ChapterProgress? _progress;
  bool _progressFailed = false;

  /// The chapter's own copy of its mastery percent. Seeded from the list that
  /// pushed this screen, then refreshed here, because the pushed-in value is a
  /// snapshot from whenever the chapter list last loaded.
  late int _pct;

  late final ContentRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ContentRepository(context.read<AuthController>().api);
    _pct = widget.masteryPct;
    _refresh();
  }

  /// Load progress and mastery. Called on open AND every time a lesson pops back
  /// to this screen.
  ///
  /// The reload matters because this screen is PUSHED over, not navigated away
  /// from: its State stays alive underneath the lesson, so nothing re-runs when
  /// the lesson closes. Fetching only in initState meant finishing a lesson's
  /// three exercises left the marker unchanged until you backed out of the
  /// chapter entirely and came in again, which destroyed the State and forced a
  /// fresh fetch. The website never showed this because there each level is a
  /// route, so returning to a chapter remounts it and refetches.
  Future<void> _refresh() async {
    // Mastery is best-effort by contract (returns {} on failure), so it cannot
    // throw the progress load away. Kept separate for that reason.
    _repo.mastery().then((m) {
      final p = m[widget.chapter.id];
      if (mounted && p != null && p != _pct) setState(() => _pct = p);
    });
    try {
      final p = await _repo.chapterProgress(widget.chapter.id);
      // Clear the failure notice: a later call succeeding means the markers are
      // available again, and leaving the notice up would contradict them.
      if (mounted) setState(() { _progress = p; _progressFailed = false; });
    } catch (_) {
      // Keep any progress already on screen. Losing markers we hold because a
      // refresh failed would be a downgrade, not honesty.
      if (mounted && _progress == null) setState(() => _progressFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ch = widget.chapter;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back row
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.chevron_left, size: 20, color: AppColors.ink2),
                label: Text('Chapters',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink2)),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chapter ${ch.num.toString().padLeft(2, '0')} · ${ch.qs} exam Qs',
                                style: AppTheme.overline()),
                            const SizedBox(height: 4),
                            Text(ch.name, style: AppTheme.heading(size: 26)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      MasteryRing(pct: _pct, size: 46),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ch.context,
                      style: const TextStyle(
                          color: AppColors.ink2, fontSize: 12.5, height: 1.5)),
                  const SizedBox(height: 14),
                    if (_progressFailed)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Progress markers are unavailable right now. Your work is saved — this is only the display.',
                          style: TextStyle(fontSize: 11, color: AppColors.ink3, height: 1.4),
                        ),
                      ),
                  const Divider(height: 1),
                  for (var i = 0; i < ch.subtopics.length; i++)
                    _SubtopicTile(
                      index: i,
                      subtopic: ch.subtopics[i],
                      open: _open == i,
                      onToggle: () => setState(() => _open = _open == i ? null : i),
                      onLesson: (l) => _openLesson(ch, ch.subtopics[i], l),
                      isLast: i == ch.subtopics.length - 1,
                      progress: _progress,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: AppButton(
                label: 'Practice all ${ch.name} problems',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chapter practice coming next')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLesson(Chapter ch, Subtopic st, LessonRef l) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LessonScreen(
        chapterId: ch.id,
        lessonId: l.id,
        lessonName: l.name,
        subtopicName: st.name,
      ),
    ));
    // The exercise screen awaits its POST before popping, so anything answered
    // in there is already recorded by the time we get here.
    if (mounted) _refresh();
  }
}

class _SubtopicTile extends StatelessWidget {
  const _SubtopicTile({
    required this.index,
    required this.subtopic,
    required this.open,
    required this.onToggle,
    required this.onLesson,
    required this.isLast,
    required this.progress,
  });

  final int index;
  final Subtopic subtopic;
  final bool open;
  final VoidCallback onToggle;
  final void Function(LessonRef) onLesson;
  final bool isLast;
  /// null while progress is unknown — the row then shows the plain lesson count
  /// rather than a fraction, because "0 of 9" would be a claim we cannot make.
  final ChapterProgress? progress;

  @override
  Widget build(BuildContext context) {
    final accent = open ? AppColors.ember : AppColors.ink3;
    final sub = progress?.subtopics[subtopic.id];
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text((index + 1).toString().padLeft(2, '0'),
                      style: AppTheme.mono(size: 12, color: AppColors.ink3)),
                ),
                Expanded(
                  // The fraction sits UNDER the name rather than beside it: at
                  // phone width there is no room for both on one line, and the
                  // website stacks it the same way at 390px.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subtopic.name,
                          style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: open ? AppColors.ember : AppColors.charcoal)),
                      const SizedBox(height: 2),
                      Text(
                        sub == null
                            ? '${subtopic.lessons.length} lessons'
                            : sub.label,
                        style: AppTheme.mono(
                          size: 11,
                          color: (sub?.allDone ?? false) ? AppColors.forest : AppColors.ink3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20, color: accent),
              ],
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 6),
            child: Column(
              children: [
                for (var j = 0; j < subtopic.lessons.length; j++) ...[
                  _LessonRow(
                    lesson: subtopic.lessons[j],
                    onTap: () => onLesson(subtopic.lessons[j]),
                    progress: progress?.lessons[subtopic.lessons[j].id],
                  ),
                  if (j < subtopic.lessons.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.onTap, required this.progress});

  final LessonRef lesson;
  final VoidCallback onTap;
  /// null = progress not known. Draws the same neutral bullet the row has always
  /// had, NOT an "untouched" marker — claiming somebody has done nothing when we
  /// simply have not been told is the one thing these markers must never do.
  final LessonProgress? progress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _LessonMarker(progress: progress),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.name,
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14, height: 1.2)),
                  if (lesson.application.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(lesson.application,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.ink3)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBBFAE)),
          ],
        ),
      ),
    );
  }
}

/// The five-state progress marker: a small vertical capsule cut into three
/// segments, one per exercise, filling bottom-up as answers come right.
///
///   untouched     nothing drawn (space reserved so names stay aligned)
///   attempted     outlined capsule, dividers showing, nothing filled
///   one-correct   bottom segment filled, ember
///   two-correct   bottom two filled, sunbeam
///   complete      all three filled, forest
///
/// Replaced a single dot. The capsule carries the COUNT in its shape, not only
/// in its hue, so it survives colour blindness and a quick glance in a way the
/// dot did not — the dot could only ever say "some progress" and leave the
/// amount to the colour.
///
/// All filled segments share one colour and that colour tracks the count, so a
/// finished lesson is unmistakably solid green when scanning a chapter. Giving
/// each segment its own fixed colour was considered and rejected: it reads
/// better up close but leaves a done lesson tricolour, which is exactly what a
/// scan needs to pick out.
///
/// **The segments are a count, not an identity.** The server sends `correct` and
/// `answered`, never WHICH problems, so a filled second segment does not mean
/// "question 2 was right". The long-press text says the count in words for that
/// reason, and it is why the fill is always contiguous from the bottom.
///
/// Long-press explains it. A colour alone is not self-explanatory, and the
/// website's hover tooltip has no equivalent on a touch screen — without this
/// the markers would be a private language. Tooltip also supplies the semantics
/// label, so screen readers read the same sentence.
class _LessonMarker extends StatelessWidget {
  const _LessonMarker({required this.progress});

  static const double _w = 8; // capsule width
  static const double _seg = 6; // one segment's height
  static const double _div = 1; // divider hairline
  static const double _gap = 12; // space to the lesson name
  // 3 segments + 2 dividers, plus the 1px border top and bottom.
  static const double _h = _seg * 3 + _div * 2 + 2;

  final LessonProgress? progress;

  @override
  Widget build(BuildContext context) {
    const box = EdgeInsets.only(right: _gap);
    final p = progress;

    // Unknown: the neutral bullet this row has always shown. Deliberately still
    // a dot — it is not a state of the capsule, it is the absence of one.
    if (p == null) {
      return Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.only(right: _gap + 1),
        decoration: const BoxDecoration(color: Color(0xFFD9CDB8), shape: BoxShape.circle),
      );
    }

    final colour = p.color;
    // Untouched: hold the space so lesson names stay aligned, draw nothing.
    // Must match the drawn capsule's footprint exactly, or untouched rows sit
    // left of their neighbours and the column wobbles.
    if (colour == null) {
      return const SizedBox(width: _w + _gap, height: _h);
    }

    // Segments are built top-down because that is the paint order, but FILL is
    // counted from the bottom: index 2 is the bottom segment.
    final rows = <Widget>[];
    for (var i = 0; i < 3; i++) {
      final fromBottom = 2 - i;
      final filled = fromBottom < p.correct;
      rows.add(Container(height: _seg, color: filled ? colour : Colors.transparent));
      if (i < 2) {
        // A divider between two filled segments has to contrast with the fill,
        // so it switches to the page colour there. Between empty segments it
        // stays the state colour, which is what makes the "all wrong" capsule
        // read as three empty slots rather than one hollow tube.
        final belowFilled = (2 - (i + 1)) < p.correct;
        rows.add(Container(height: _div, color: belowFilled ? AppColors.cream : colour));
      }
    }

    final capsule = Container(
      width: _w,
      height: _h,
      margin: box,
      decoration: BoxDecoration(
        border: Border.all(color: colour, width: 1),
        borderRadius: BorderRadius.circular(_w / 2),
      ),
      // Clip so the fill follows the rounded ends instead of squaring them off.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_w / 2),
        child: Column(children: rows),
      ),
    );

    return Tooltip(
      message: p.explanation ?? '',
      triggerMode: TooltipTriggerMode.longPress,
      child: capsule,
    );
  }
}
