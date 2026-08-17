import '../../core/network/api_client.dart';
import 'models.dart';
import 'progress_models.dart';

/// Reads study content from the backend (/content/*) and the user's per-chapter
/// mastery (/diagnostic/mastery). Caches the chapter structure for the session.
class ContentRepository {
  ContentRepository(this.api);

  final ApiClient api;
  List<Chapter>? _chapters;

  Future<List<Chapter>> chapters() async {
    if (_chapters != null) return _chapters!;
    final data = await api.get('/content/chapters') as List;
    _chapters = data
        .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
        .toList();
    return _chapters!;
  }

  /// Per-chapter progress for the signed-in user. Read-only; everything it
  /// returns is derived from answers already recorded, so it needs no writes and
  /// no migration.
  ///
  /// Deliberately NOT swallowed into a default on failure: the caller must be
  /// able to tell "no progress" from "we do not know", because rendering an
  /// unknown state as untouched tells somebody they have done nothing when they
  /// may have done plenty.
  Future<ChapterProgress> chapterProgress(String chapterId) async {
    final data = await api.get('/progress/chapter/$chapterId') as Map<String, dynamic>;
    return ChapterProgress.fromJson(data);
  }

  Future<Lesson> lesson(String chapterId, String lessonId) async {
    final data = await api.get('/content/lessons/$chapterId/$lessonId') as Map<String, dynamic>;
    return Lesson.fromJson(data);
  }

  Future<Problem> problem(String id) async {
    final data = await api.get('/content/problems/$id') as Map<String, dynamic>;
    return Problem.fromJson(data);
  }

  /// The due review queue: each missed problem (resolved) with its chapter id.
  Future<List<ReviewItem>> reviewItems() async {
    final data = await api.get('/review?count=8') as Map<String, dynamic>;
    final items = (data['problems'] as List? ?? []);
    final resolved = await Future.wait(items.map((it) async {
      final m = it as Map<String, dynamic>;
      return ReviewItem(
        problem: await problem(m['problemId'] as String),
        chapterId: m['topicId'] as String,
      );
    }));
    return resolved;
  }

  /// Record review answers so the spaced-repetition schedule advances/graduates.
  Future<void> postReview(List<Map<String, dynamic>> answers) async {
    try {
      await api.post('/review', {'answers': answers});
    } catch (_) {/* best-effort */}
  }

  /// chapterId -> mastery percent (0–100). Empty if it can't be loaded — the UI
  /// just shows everything as "New" rather than failing.
  Future<Map<String, int>> mastery() async {
    try {
      final data = await api.get('/diagnostic/mastery') as Map<String, dynamic>;
      final cm = (data['chapterMastery'] as Map?) ?? {};
      return cm.map((k, v) {
        final pct = (v is Map ? v['totalMastery'] : null) as num?;
        return MapEntry(k as String, (pct ?? 0).round());
      });
    } catch (_) {
      return {};
    }
  }
}
