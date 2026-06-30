import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/async_view.dart';
import '../shared/widgets/math_text.dart';
import 'content_repository.dart';
import 'exercise_screen.dart';
import 'lesson_content.dart';
import 'models.dart';

/// Tab 1, Level 3 — the lesson hub: intro, the list of topics (tap to read),
/// and Practice. Mirrors the "overview + topics" design.
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

  @override
  void initState() {
    super.initState();
    _repo = ContentRepository(context.read<AuthController>().api);
    _future = _repo.lesson(widget.chapterId, widget.lessonId);
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
      appBar: AppBar(),
      body: AsyncView<Lesson>(
        future: _future,
        onRetry: () => setState(() => _future = _repo.lesson(widget.chapterId, widget.lessonId)),
        builder: (lesson) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                children: [
                  Text(widget.subtopicName.toUpperCase(), style: AppTheme.overline()),
                  const SizedBox(height: 4),
                  Text(lesson.name, style: AppTheme.heading()),
                  const SizedBox(height: 12),
                  if (lesson.intro.isNotEmpty)
                    MathText(lesson.intro.first.body,
                        style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.ink2)),
                  const SizedBox(height: 18),
                  Text('IN THIS LESSON', style: AppTheme.overline()),
                  const SizedBox(height: 8),
                  _TopicList(lesson: lesson),
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

class _TopicList extends StatelessWidget {
  const _TopicList({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final sections = lesson.sections();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 16, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => _TopicReader(title: sections[i].heading, blocks: sections[i].blocks),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: Text('${i + 1}',
                          style: AppTheme.mono(size: 12, weight: FontWeight.w700, color: AppColors.ember)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(sections[i].heading,
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCBBFAE)),
                  ],
                ),
              ),
            ),
            if (i < sections.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _TopicReader extends StatelessWidget {
  const _TopicReader({required this.title, required this.blocks});

  final String title;
  final List<ContentBlock> blocks;

  @override
  Widget build(BuildContext context) {
    // Skip the leading heading block (it's the screen title).
    final body = blocks.where((b) => b.type != 'heading').toList();
    return Scaffold(
      appBar: AppBar(title: Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 16))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: renderBlocks(body),
      ),
    );
  }
}
