import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_controller.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/async_view.dart';
import 'content_repository.dart';
import 'exercise_screen.dart';
import 'models.dart';

/// Tab 2 — Review: the missed problems, grouped by chapter. Mirror-the-web
/// (automatic weak-spots only, no guilt counters). Empty state stays calm.
class ReviewTab extends StatefulWidget {
  const ReviewTab({super.key});

  @override
  State<ReviewTab> createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  late final ContentRepository _repo;
  late Future<_Data> _future;

  @override
  void initState() {
    super.initState();
    _repo = ContentRepository(context.read<AuthController>().api);
    _future = _load();
  }

  Future<_Data> _load() async {
    final results = await Future.wait([_repo.reviewItems(), _repo.chapters()]);
    final items = results[0] as List<ReviewItem>;
    final chapters = results[1] as List<Chapter>;
    final names = {for (final c in chapters) c.id: c};
    return _Data(items, names);
  }

  void _reload() => setState(() => _future = _load());

  void _start(List<ReviewItem> items) {
    final byId = {for (final it in items) it.problem.id: it.chapterId};
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => ExerciseScreen(
            problems: items.map((it) => it.problem).toList(),
            title: 'Review',
            onComplete: (answers) => _repo.postReview([
              for (final a in answers)
                {'problemId': a.problemId, 'isCorrect': a.isCorrect, 'topicId': byId[a.problemId]},
            ]),
          ),
        ))
        .then((_) => _reload()); // refresh due list when they come back
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AsyncView<_Data>(
        future: _future,
        onRetry: _reload,
        builder: (data) => data.items.isEmpty ? _empty() : _list(data),
      ),
    );
  }

  Widget _list(_Data data) {
    // group by chapter, preserve chapter order
    final counts = <String, int>{};
    for (final it in data.items) {
      counts[it.chapterId] = (counts[it.chapterId] ?? 0) + 1;
    }
    final chapters = counts.keys.toList()
      ..sort((a, b) => (data.names[a]?.num ?? 99).compareTo(data.names[b]?.num ?? 99));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review', style: AppTheme.heading(size: 27)),
              const SizedBox(height: 6),
              const Text(
                "The problems you've missed, here to lock in. Get one right twice and it graduates.",
                style: TextStyle(color: AppColors.ink3, fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        const Divider(height: 20, indent: 20, endIndent: 20),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chapters.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final ch = data.names[chapters[i]];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 26,
                      child: Text((ch?.num ?? 0).toString().padLeft(2, '0'),
                          style: AppTheme.mono(size: 12, color: AppColors.ink3)),
                    ),
                    Expanded(
                      child: Text(ch?.name ?? chapters[i],
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14.5)),
                    ),
                    Text('${counts[chapters[i]]} due',
                        style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: AppColors.ember)),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: AppButton(label: 'Start review · ${data.items.length}', onPressed: () => _start(data.items)),
        ),
      ],
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review', style: AppTheme.heading(size: 27)),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: AppColors.forestBg, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 34, color: AppColors.forest),
                  ),
                  const SizedBox(height: 20),
                  Text('All caught up', style: AppTheme.heading(size: 20)),
                  const SizedBox(height: 10),
                  const SizedBox(
                    width: 260,
                    child: Text(
                      'Miss a problem in a lesson and it shows up here to re-practice. Get it right twice and it graduates for good.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.ink2, fontSize: 13.5, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Data {
  _Data(this.items, this.names);
  final List<ReviewItem> items;
  final Map<String, Chapter> names;
}
