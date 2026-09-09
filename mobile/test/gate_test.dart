import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/game_audit.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/games/game_progress.dart';

/// THE GATE.
///
/// Every rule here was written the day a real mistake got through, and it now
/// runs against every item ever built rather than living in the head of
/// whoever wrote the last one.
///
/// It checks HONESTY, never FORM. Nothing here says what an item may ask or
/// how it may be answered: an item is free to invent whatever interaction its
/// lesson calls for, and several already have.
void main() {
  final audits = auditAllGames();

  GameAudit auditFor(String gameId) =>
      audits.firstWhere((a) => a.gameId == gameId);

  test('every built item is described to the gate', () {
    // An item that skips the audit skips every rule below it, so the catalog
    // is the authority on what must be covered.
    final built = <String>[
      for (final chapter in chapterMaps.values)
        for (final lesson in chapter.lessons)
          for (final game in lesson.builtGames) game.id,
    ];
    for (final id in built) {
      expect(() => auditFor(id), returnsNormally,
          reason: '$id is playable but not audited');
    }
    expect(audits.length, built.length);
  });

  test('the catalog and the item agree on how long the board is', () {
    // They disagreed once: the map could not tell finished work from unstarted
    // work on a cold launch because only the item knew its own length.
    for (final audit in audits) {
      expect(audit.rounds.length, GameProgress.roundsIn(audit.gameId),
          reason: '${audit.gameId} declares a different number of rounds');
    }
  });

  test('every round names the problem it was authored from', () {
    // Provenance is the whole accuracy story: an item that traces to nothing
    // was invented, and inventions are where wrong content comes from.
    for (final audit in audits) {
      for (var i = 0; i < audit.rounds.length; i++) {
        final source = audit.rounds[i].source;
        expect(source, startsWith(audit.problemPrefix),
            reason: '${audit.gameId} round ${i + 1} cites $source, which is '
                'not a problem in ${audit.lessonId}');
      }
    }
  });

  test('no round offers the same choice twice', () {
    // A repeated option means two right answers or a wasted slot. Positional
    // items are exempt and say so: tapping a term in an equation, two plus
    // signs are two different PLACES, not the same choice offered twice.
    for (final audit in audits) {
      for (var i = 0; i < audit.rounds.length; i++) {
        final round = audit.rounds[i];
        final options = round.options;
        if (options.isEmpty || round.positional) continue;
        expect(options.toSet().length, options.length,
            reason: '${audit.gameId} round ${i + 1} repeats an option');
      }
    }
  });

  test('every round has exactly one answer, and it exists', () {
    for (final audit in audits) {
      for (var i = 0; i < audit.rounds.length; i++) {
        final r = audit.rounds[i];
        if (r.options.isEmpty) continue;
        expect(r.answer, isNotNull,
            reason: '${audit.gameId} round ${i + 1} has choices but no answer');
        expect(r.answer! >= 0 && r.answer! < r.options.length, isTrue,
            reason: '${audit.gameId} round ${i + 1} points outside its own '
                'choices');
      }
    }
  });

  test('a board is long enough to be worth opening', () {
    for (final audit in audits) {
      expect(audit.rounds.length, greaterThanOrEqualTo(4),
          reason: '${audit.gameId} is too short to be a sitting');
    }
  });

  test('an item draws on more than one problem, or says why not', () {
    // Not a hard rule: some items legitimately drill one problem's trap from
    // every angle. It reports, so a lesson that leans on a single problem is
    // a decision rather than an accident.
    final single = <String>[];
    for (final audit in audits) {
      if (audit.rounds.map((r) => r.source).toSet().length == 1) {
        single.add(audit.gameId);
      }
    }
    expect(single, [
      'perpendicular-flip', // the easement problem and its two traps
      'discriminant-gate', // the quadratic problem's own tip
      'grade-sense', // the station trap, from every angle
      'resolve-it', // the components trap, from both axes
      'balance-both-sides', // completing the square, which is one problem
      'which-way-simpler', // by parts, which is one problem's whole content
      'both-sides', // the DNE trap, which lives in one problem
      'stretch-it', // sizing a direction, which is one problem's whole content
      'which-region', // the halving trap, which lives in the plot problem
      'copy-it-down', // relative against absolute, one problem's whole content
      'happens-first', // precedence, likewise
      // Lesson fifteen's three problems ARE the three constructs, one each,
      // so its three items land one to one on them by construction.
      'fill-the-trace',
      'first-true-wins',
      'where-it-stops',
      'can-it-start', // bracketing, which is one problem's whole content
      'what-weights', // naming the two columns, one problem's whole content
      'r-or-r2', // r against r squared, which is one problem's whole content
      'acute-or-obtuse', // the negative-cosine trap, which is one problem
    ], reason: 'a NEW item now leans on one problem: intended, or an accident?');
  });
}
