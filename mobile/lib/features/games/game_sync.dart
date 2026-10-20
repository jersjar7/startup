import 'dart:io' show Platform;
import 'dart:math';

import '../../core/network/api_client.dart';
import '../../core/notifications/notifications.dart';

/// One graded moment inside a game: the student answered, we know whether they
/// got it, and we know which real problem the item came from.
class GameEvent {
  GameEvent({
    required this.sourceProblemId,
    required this.chapterId,
    required this.gameId,
    required this.round,
    required this.correct,
    DateTime? ts,
    String? eventId,
  }) : ts = ts ?? DateTime.now(),
       eventId = eventId ?? GameSync.newEventId();

  /// How a guest's round is kept on the phone until they have an account
  /// (guest_log.dart), and read back to send it.
  Map<String, dynamic> toJson() => {
    'sourceProblemId': sourceProblemId,
    'chapterId': chapterId,
    'gameId': gameId,
    'round': round,
    'correct': correct,
    'ts': ts.millisecondsSinceEpoch,
    'eventId': eventId,
  };

  static GameEvent? fromJson(Map<String, dynamic> j) {
    try {
      return GameEvent(
        sourceProblemId: j['sourceProblemId'] as String,
        chapterId: j['chapterId'] as String,
        gameId: j['gameId'] as String,
        round: (j['round'] as num).toInt(),
        correct: j['correct'] as bool,
        ts: DateTime.fromMillisecondsSinceEpoch((j['ts'] as num).toInt()),
        eventId: j['eventId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// The web problem this item was authored from. Mastery is keyed by it.
  final String sourceProblemId;
  final String chapterId;
  final String gameId;
  final int round;
  final bool correct;
  final DateTime ts;

  /// Made once, when the round is answered, and sent with every retry: the
  /// server keeps one row per eventId, so a batch whose answer was lost and
  /// is sent again is never counted twice.
  final String eventId;

  /// `<problemId>:<game>:<round>` — the server takes everything before the
  /// first colon as the parent problem, so a game item strengthens the problem
  /// it came from while staying its own review unit.
  String get itemId => '$sourceProblemId:$gameId:$round';
}

/// Pushes game results into the SAME pipeline the web already uses
/// (`POST /api/sync/events`): one brain, one mastery number, one streak.
/// Phone XP is derived server-side and capped there; the games half of a
/// chapter's mastery is 50 times the share of its games cleared, read from
/// these events (service/gamesHalf.js). [pullAll] reads the whole log back,
/// which is how a new phone rebuilds its map.
class GameSync {
  GameSync(this._api);

  final ApiClient _api;

  static final _rand = Random.secure();

  /// The most events the server takes in one push (service/routes/sync.js).
  static const maxBatch = 200;

  static String newEventId() {
    const hex = '0123456789abcdef';
    return List.generate(32, (_) => hex[_rand.nextInt(16)]).join();
  }

  static String _localDate(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')}';

  static String get _source => Platform.isIOS ? 'ios' : 'android';

  /// Returns true when the batch reached the server. A false means the work is
  /// not recorded anywhere — the caller must say so rather than imply it saved.
  Future<bool> push(List<GameEvent> events) async {
    if (events.isEmpty) return true;
    try {
      await _api.post('/sync/events', {
        'events': [
          for (final e in events)
            {
              'eventId': e.eventId,
              'itemId': e.itemId,
              'chapterId': e.chapterId,
              'grade': e.correct ? 'gotIt' : 'forgot',
              'source': _source,
              'ts': e.ts.millisecondsSinceEpoch,
              'localDate': _localDate(e.ts),
            },
        ],
        'device': Platform.isIOS ? 'iPhone' : 'Android',
      });
      // They studied, so tonight's "you have not studied today" is now wrong.
      // The schedule used to be rebuilt only when the Profile tab first loaded,
      // which meant studying in the evening still earned the seven o'clock
      // telling-off. Rebuilt from the newest event rather than from now, so a
      // batch that was queued offline overnight does not credit the wrong day.
      //
      // Never allowed to fail the push: the work IS recorded, and a notification
      // that is merely stale must not be reported as lost study.
      try {
        final latest = events
            .map((e) => e.ts)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        await Notifications().studiedOn(latest);
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Every event on the account, oldest first, from `GET /api/sync/changes`
  /// (paged by cursor, 500 a page). Empty on any failure: the caller keeps
  /// what it has.
  Future<List<Map<String, dynamic>>> pullAll() async {
    final out = <Map<String, dynamic>>[];
    String? cursor;
    try {
      for (var page = 0; page < 40; page++) {
        final path = cursor == null
            ? '/sync/changes'
            : '/sync/changes?since=$cursor';
        final data = await _api.get(path) as Map<String, dynamic>;
        final events = (data['events'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        out.addAll(events);
        final next = data['cursor'] as String?;
        if (events.length < 500 || next == null || next == cursor) break;
        cursor = next;
      }
    } catch (_) {
      return const [];
    }
    return out;
  }
}
