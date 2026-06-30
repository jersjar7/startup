import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/async_view.dart';
import '../shared/widgets/mastery_ring.dart';
import 'chapter_screen.dart';
import 'content_repository.dart';
import 'models.dart';

/// Tab 1, Level 1 — the chapter list (ring-forward). The home of the app.
class StudyTab extends StatefulWidget {
  const StudyTab({super.key});

  @override
  State<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends State<StudyTab> {
  late final ContentRepository _repo;
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _repo = ContentRepository(context.read<AuthController>().api);
    _future = _load();
  }

  Future<_Data> _load() async {
    final results = await Future.wait([_repo.chapters(), _repo.mastery()]);
    return _Data(results[0] as List<Chapter>, results[1] as Map<String, int>);
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final first = context.select<AuthController, String?>((a) => a.user?['firstName'] as String?);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(first != null && first.isNotEmpty ? 'Hey, $first' : 'Hey there',
                    style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.ink3)),
                const SizedBox(height: 2),
                Text('Chapters', style: AppTheme.heading(size: 27)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          Expanded(
            child: AsyncView<_Data>(
              future: _future,
              onRetry: _retry,
              builder: (data) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.chapters.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final ch = data.chapters[i];
                  final pct = data.mastery[ch.id] ?? 0;
                  return _ChapterRow(chapter: ch, pct: pct);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({required this.chapter, required this.pct});

  final Chapter chapter;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChapterScreen(chapter: chapter, masteryPct: pct)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            MasteryRing(pct: pct, size: 42),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600, fontSize: 14.5, height: 1.2)),
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 11.5),
                      children: [
                        TextSpan(
                          text: AppColors.masteryStage(pct),
                          style: TextStyle(
                              color: pct > 0 ? AppColors.masteryColor(pct) : AppColors.ink3,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' · ${chapter.qs} Qs', style: const TextStyle(color: AppColors.ink3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCBBFAE)),
          ],
        ),
      ),
    );
  }
}

class _Data {
  _Data(this.chapters, this.mastery);
  final List<Chapter> chapters;
  final Map<String, int> mastery;
}
