import 'dart:io' show Platform;
import 'dart:math';

import '../../core/network/api_client.dart';

/// One graded moment inside a game: the student answered, we know whether they
/// got it, and we know which real problem the item came from.
class GameEvent {
  GameEvent({
    required this.sourceProblemId,
    required this.chapterId,
    required this.gameId,
    required this.round,
    required this.correct,
  }) : ts = DateTime.now();

  /// The web problem this item was authored from. Mastery is keyed by it.
  final String sourceProblemId;
  final String chapterId;
  final String gameId;
  final int round;
  final bool correct;
  final DateTime ts;

  /// `<problemId>:<game>:<round>` — the server takes everything before the
  /// first colon as the parent problem, so a game item strengthens the problem
  /// it came from while staying its own review unit.
  String get itemId => '$sourceProblemId:$gameId:$round';
}

/// Pushes game results into the SAME pipeline the phone's cards and the web
/// already use (`POST /api/sync/events`): one brain, one mastery number, one
/// streak. Phone XP is derived server-side and capped there, and phone-only
/// evidence is capped at 60% chapter mastery (see service/mastery.js).
class GameSync {
  GameSync(this._api);

  final ApiClient _api;

  static final _rand = Random.secure();

  static String _eventId() {
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
              'eventId': _eventId(),
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
      return true;
    } catch (_) {
      return false;
    }
  }
}
