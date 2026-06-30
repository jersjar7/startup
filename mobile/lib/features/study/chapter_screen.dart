import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/mastery_ring.dart';
import 'models.dart';

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
                      MasteryRing(pct: widget.masteryPct, size: 46),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(ch.context,
                      style: const TextStyle(
                          color: AppColors.ink2, fontSize: 12.5, height: 1.5)),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  for (var i = 0; i < ch.subtopics.length; i++)
                    _SubtopicTile(
                      index: i,
                      subtopic: ch.subtopics[i],
                      open: _open == i,
                      onToggle: () => setState(() => _open = _open == i ? null : i),
                      onLesson: (l) => _openLesson(ch, ch.subtopics[i], l),
                      isLast: i == ch.subtopics.length - 1,
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

  void _openLesson(Chapter ch, Subtopic st, LessonRef l) {
    // L3 (lesson hub) is built next; navigate there once it exists.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${l.name} — lesson screen coming next')),
    );
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
  });

  final int index;
  final Subtopic subtopic;
  final bool open;
  final VoidCallback onToggle;
  final void Function(LessonRef) onLesson;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accent = open ? AppColors.ember : AppColors.ink3;
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
                  child: Text(subtopic.name,
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: open ? AppColors.ember : AppColors.charcoal)),
                ),
                Text('${subtopic.lessons.length} lessons',
                    style: const TextStyle(fontSize: 11, color: AppColors.ink3)),
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
                  _LessonRow(lesson: subtopic.lessons[j], onTap: () => onLesson(subtopic.lessons[j])),
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
  const _LessonRow({required this.lesson, required this.onTap});

  final LessonRef lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(color: Color(0xFFD9CDB8), shape: BoxShape.circle),
            ),
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
