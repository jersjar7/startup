import '../../core/network/api_client.dart';
import 'models.dart';

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

  Future<Lesson> lesson(String chapterId, String lessonId) async {
    final data = await api.get('/content/lessons/$chapterId/$lessonId') as Map<String, dynamic>;
    return Lesson.fromJson(data);
  }

  Future<Problem> problem(String id) async {
    final data = await api.get('/content/problems/$id') as Map<String, dynamic>;
    return Problem.fromJson(data);
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
