import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/async_view.dart';
import 'content_repository.dart';
import 'exercise_screen.dart';
import 'lesson_content.dart';
import 'models.dart';

/// Tab 1, Level 3 — the lesson, read top to bottom in ONE scroll, then
/// Practice. Mirrors the website's `LessonContent`, which renders every block
/// inline with no drilling.
///
/// This replaced an "overview + topics" design where each heading pushed its
/// own sub-screen. Driven on a phone, that produced screens holding a single
/// formula and one line of text with ~80% of the display blank, because a
/// heading really does own that little: the bank's median lesson is 13 blocks
/// under 3 headings. The typical lesson cost three taps and three back-presses
/// to read three formulas that fit comfortably on one scroll.
///
/// It also buried the exam-day callouts, which are the LAST blocks in a lesson
/// and so landed at the bottom of the final sub-screen, the least-visited
/// corner of the lesson.
///
/// No table of contents replaced it. With a median of 3 headings it would cost
/// more vertical space above the fold than it saves in scrolling, and the web
/// does not have one either.
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.chapterId,
    required this.lessonId,
    required this.lessonName,
    required this.subtopicName,
  });

  final String chapterId;
  final String lessonId;
  final String lessonName;
  final String subtopicName;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final ContentRepository _repo;
  late Future<Lesson> _future;

  // The lesson name lives in the page heading AND in the app bar, but never at
  // the same time: the bar's copy fades in only once the heading has scrolled
  // off. Showing both at rest reads as a mistake; showing neither loses your
  // place on the longest lessons, which run past three screens.
  final _scroll = ScrollController();
  bool _titleInBar = false;

  @override
  void initState() {
    super.initState();
    _repo = ContentRepository(context.read<AuthController>().api);
    _future = _repo.lesson(widget.chapterId, widget.lessonId);
    _scroll.addListener(() {
      final show = _scroll.hasClients && _scroll.offset > 64;
      if (show != _titleInBar) setState(() => _titleInBar = show);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _record(List<AnswerLog> answers) async {
    try {
      await _repo.api.post('/sessions', {
        'topicId': widget.chapterId,
        'answers': answers
            .map((a) => {'problemId': a.problemId, 'isCorrect': a.isCorrect})
            .toList(),
      });
    } catch (_) {/* session recording is best-effort */}
  }

  void _practice(Lesson lesson) {
    if (lesson.problems.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExerciseScreen(
        problems: lesson.problems,
        title: lesson.name,
        onComplete: _record,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedOpacity(
          opacity: _titleInBar ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Text(widget.lessonName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
      ),
      body: AsyncView<Lesson>(
        future: _future,
        onRetry: () => setState(() => _future = _repo.lesson(widget.chapterId, widget.lessonId)),
        builder: (lesson) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                children: [
                  Text(widget.subtopicName.toUpperCase(), style: AppTheme.overline()),
                  const SizedBox(height: 4),
                  Text(lesson.name, style: AppTheme.heading()),
                  const SizedBox(height: 6),
                  // The WHOLE lesson, in order. Passing lesson.content rather
                  // than intro + sections also stops dropping the second and
                  // later intro blocks, which the old split silently did.
                  ...renderBlocks(lesson.content),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: AppButton(
                label: 'Practice · ${lesson.problems.length} problems',
                onPressed: () => _practice(lesson),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
