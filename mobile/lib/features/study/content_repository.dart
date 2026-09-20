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
    final data =
        await api.get('/progress/chapter/$chapterId') as Map<String, dynamic>;
    return ChapterProgress.fromJson(data);
  }

  Future<Lesson> lesson(String chapterId, String lessonId) async {
    final data =
        await api.get('/content/lessons/$chapterId/$lessonId')
            as Map<String, dynamic>;
    return Lesson.fromJson(data);
  }

  Future<Problem> problem(String id) async {
    final data = await api.get('/content/problems/$id') as Map<String, dynamic>;
    return Problem.fromJson(data);
  }

  /// chapterId -> the chapter's mastery, both halves. Empty if it can't be
  /// loaded — the UI just shows everything as "New" rather than failing.
  Future<Map<String, ChapterMastery>> mastery() async {
    try {
      final data = await api.get('/diagnostic/mastery') as Map<String, dynamic>;
      final cm = (data['chapterMastery'] as Map?) ?? {};
      return {
        for (final e in cm.entries)
          if (e.value is Map)
            e.key as String: ChapterMastery.fromJson(e.value as Map),
      };
    } catch (_) {
      return {};
    }
  }
}

/// One chapter's mastery as the server composes it: one number, two halves.
/// The desk half is the website's study curve (with the diagnostic as its
/// floor), 0 to 100; the games half is 50 times the share of the chapter's
/// games cleared on the phone, 0 to 50; the number is their sum, at most 100.
class ChapterMastery {
  const ChapterMastery({
    required this.total,
    this.desk = 0,
    this.games = 0,
    this.gamesCleared = 0,
    this.gamesTotal = 0,
  });

  factory ChapterMastery.fromJson(Map m) {
    int n(String k) => ((m[k] as num?) ?? 0).round();
    return ChapterMastery(
      total: n('totalMastery'),
      desk: n('deskScore'),
      games: n('gamesHalf'),
      gamesCleared: n('gamesCleared'),
      gamesTotal: n('gamesTotal'),
    );
  }

  final int total;
  final int desk;
  final int games;
  final int gamesCleared;
  final int gamesTotal;

  /// Games have taken this chapter as far as they can.
  bool get gamesDone => gamesTotal > 0 && gamesCleared >= gamesTotal;
}
