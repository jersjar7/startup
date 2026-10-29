import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/games/game_audit.dart';

import 'published.dart';

/// Check 5 of the migration plan: the item checks (the game audit, see
/// gate_test.dart) hold for the pack's copy of every game. The audit reads
/// the built-in rounds, so this checks that the pack carries exactly those
/// rounds: the same problems, in the same order, the same choices and the
/// same right answer, in the lesson the audit names.
///
/// Reads the latest pack the server publishes, which is what students get.

void main() {
  final pack = latestPublished(Directory('../service/packs/fe-civil'));
  final games = (pack['games']! as Map).cast<String, Map<String, Object?>>();
  final lessons = (pack['lessons']! as Map).cast<String, Map>();
  final audits = {for (final a in auditAllGames()) a.gameId: a};

  for (final MapEntry(key: id, value: game) in games.entries) {
    test('$id carries the audited rounds', () {
      final audit = audits[id];
      expect(audit, isNotNull, reason: '$id is packed but never audited');
      final lesson = lessons.entries
          .firstWhere((l) => (l.value['games'] as List).contains(id))
          .key;
      expect(lesson.split('/').last, audit!.lessonId);

      final rounds = (game['rounds']! as List).cast<Map<String, Object?>>();
      expect(rounds.length, audit.rounds.length);
      for (var i = 0; i < rounds.length; i++) {
        final r = rounds[i], a = audit.rounds[i];
        expect(r['source'], a.source, reason: '$id round ${i + 1}');
        if (game['type'] == 'pick-one' && a.options.isNotEmpty) {
          final options = (r['options']! as List).cast<String>();
          expect(
            options.length,
            a.options.length,
            reason: '$id round ${i + 1}',
          );
          expect(r['answer'], a.answer, reason: '$id round ${i + 1}');
          // A few audits name enum values where the screen shows words,
          // and a round laid out as its own screen carries the words it
          // shows; those are checked by position and answer above.
          if (r['screen'] == null && a.options.any((o) => o.contains(' '))) {
            expect(options, a.options, reason: '$id round ${i + 1}');
          }
        }
      }
    });
  }
}
