import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/game_progress.dart';

/// A new phone rebuilds its map from the server's log (audit F8): every
/// cleared round on any phone comes back, misses do not, nothing local is
/// lost, and first-try is read from the order of events.
Map<String, dynamic> ev(
  String item, {
  String grade = 'gotIt',
  String source = 'ios',
}) => {'itemId': item, 'grade': grade, 'source': source};

void main() {
  setUp(() {
    GameProgress.instance.reset('perpendicular-flip');
    GameProgress.instance.reset('grade-sense');
  });

  test(
    'clears the rounds the log says were cleared, and counts first tries',
    () {
      final p = GameProgress.instance;
      final added = p.applyServerEvents([
        ev('math-slq-q2:perpendicular-flip:1'),
        ev('math-slq-q2:perpendicular-flip:2', grade: 'forgot'),
        ev('math-slq-q2:perpendicular-flip:2'),
        ev('math-slq-q1:grade-sense:1', grade: 'forgot'),
      ]);
      expect(added, 2);
      expect(p.roundsCleared('perpendicular-flip'), {0, 1});
      expect(p.firstTryCount('perpendicular-flip'), 1);
      expect(p.isStarted('grade-sense'), isFalse);
    },
  );

  test(
    'ignores web events, cards and unknown games, and never removes local work',
    () {
      final p = GameProgress.instance;
      p.markRoundCleared('grade-sense', 3, firstTry: true);
      final added = p.applyServerEvents([
        ev('math-slq-q2:perpendicular-flip:1', source: 'web'),
        ev('math-slq-q1:fc'),
        ev('math-slq-q1:no-such-game:1'),
        ev('math-slq-q1:grade-sense:4'), // the round it already has, 1-based
      ]);
      expect(added, 0);
      expect(p.roundsCleared('grade-sense'), {3});
      expect(p.isStarted('perpendicular-flip'), isFalse);
    },
  );

  test('a whole game from the log is cleared on this phone', () {
    final p = GameProgress.instance;
    p.applyServerEvents([
      for (var r = 1; r <= 8; r++) ev('math-slq-q2:perpendicular-flip:$r'),
    ]);
    expect(p.isCleared('perpendicular-flip'), isTrue);
    expect(p.firstTryCount('perpendicular-flip'), 8);
  });

  test('the account read folds in the rounds and first tries per game', () {
    final p = GameProgress.instance;
    p.markRoundCleared('grade-sense', 0, firstTry: true);
    final added = p.applyServerGames({
      'perpendicular-flip': {
        'rounds': [1, 2, 3],
        'firstTry': 2,
      },
      'grade-sense': {
        'rounds': [1, 2],
        'firstTry': 2,
      },
      'no-such-game': {
        'rounds': [1],
        'firstTry': 1,
      },
    });
    expect(added, 4);
    expect(p.roundsCleared('perpendicular-flip'), {0, 1, 2});
    expect(p.firstTryCount('perpendicular-flip'), 2);
    expect(p.roundsCleared('grade-sense'), {0, 1});
    expect(p.firstTryCount('grade-sense'), 2);
  });
}
