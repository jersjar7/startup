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
      // Lesson eighteen's three problems ARE its three layers, counting then
      // binomial then normal, so its three items land one to one on them.
      'same-pick',
      'build-the-binomial',
      'shade-the-tail',
      // Lesson nineteen the same: expected value, the variance shortcut, and
      // combining independent spreads are one problem each.
      'where-it-balances',
      'mind-the-order',
      'add-the-squares',
      'what-goes-under', // the margin formula, which is one problem
      'which-cell-hurts', // chi-square, which is one problem's whole content
      // Ethics lesson two has three problems and they ARE its three topics:
      // competence and the seal, conflicts and consent, and what you may claim
      // about past work. One item each, by construction.
      'can-you-seal-it',
      'who-has-to-agree',
      'can-you-claim-that',
      // Ethics lesson three, likewise: the exemption clause and the
      // practice-or-title distinction are one problem each.
      'does-it-hold',
      'practice-or-title',
      'what-is-missing-yet', // the licensure ladder, which is one problem
      'is-there-a-deal', // contract formation, which is one problem
      'which-delivery', // the delivery methods, which is one problem
      // Ethics lesson six: the standard of care and the two clocks are one
      // problem each, and the four elements draw on two.
      'is-that-negligence',
      'which-clock-ran-out',
      'over-the-whole-life', // life-cycle analysis, which is one problem
      'which-rate', // nominal against effective, which is one problem
      'which-side-wins', // the break-even chart, which is one problem
      'what-is-the-saving', // the payback saving, which is one problem
      // The cantilever is the only problem in the lesson with a spread load
      // in it, and where that load adds up to is the whole item.
      'where-it-all-acts',
      // The crane problem is the only one in the lesson with a moment in it,
      // and these two items are both about moments: one asks which distance
      // is the arm, the other which way each force turns the body.
      'which-distance-counts',
      'which-ones-turn-it',
      // Inflation is one problem in the lesson and the only one with a rate
      // in it, so every round is built from it.
      'match-the-dollars',
      // The decision tree is one problem in the lesson and it is the only
      // one with a probability in it, so every round is built from it.
      'roll-it-back',
      'acute-or-obtuse', // the negative-cosine trap, which is one problem
      // The section problem is the only one in the lesson that asks for a
      // single member's force, and where to take the cut is the whole item.
      'where-do-you-cut',
      // Belt friction is one problem in the lesson and the only one with a
      // drum in it, so every round is built from it.
      'which-side-is-tight',
      // Lesson forty has three problems and they ARE its three topics: what a
      // two-force member is, what a lever does, and what the thing is called.
      // One item each, by construction.
      'along-it-or-not',
      'does-it-multiply',
      'frame-truss-or-machine',
      // The rectangle problem is the only one in the lesson about where the
      // material sits, and where it sits is the whole item.
      'rank-by-stiffness',
      // The composite problem is the only one in the lesson with more than one
      // piece in it, and which piece carries the section is the whole item.
      'which-barely-matters',
      // The crate problem is the only one in the lesson with a coefficient in
      // it, and comparing the thread angle to the friction angle is the whole
      // item.
      'will-it-hold-itself',
      // The rectangle problem is the only one in the lesson that names a
      // section property, and which property a job needs is the whole item.
      'which-second-moment',
      // The thermal problem is the only one in the lesson with a temperature
      // in it, and what a restrained bar does is the whole item.
      'does-it-build-stress',
      // The hollow-shaft problem is the only one in the lesson with a wall in
      // it, and which area the thin-walled formula wants is the whole item.
      'which-area-twists-it',
      // The transformed section problem is the only one in the lesson about
      // what the two materials feel, and the join is the whole item.
      'same-strain',
      // The plastic moment problem is the only one in the lesson about
      // yielding, and how far it has spread is the whole item.
      'how-far-has-it-yielded',
      // The pinned column problem is the only one in the lesson that names a
      // section property, and which axis it folds about is the whole item.
      'which-way-does-it-fold',
      // The slender column problem is the only one in the lesson that checks
      // against yield, and that check is the whole item.
      'buckle-or-squash',
      // The projectile problem is the only one in the lesson with a flight in
      // it, and reading that flight is the whole item.
      'tap-the-trajectory',
      // The curved road problem is the only one in the lesson with a bend in
      // it, and telling the two accelerations apart is the whole item.
      'speeding-up-or-turning',
      // The grinding wheel problem is the only one in the lesson that relates
      // a spin to a speed, and reading that off the body is the whole item.
      'same-spin-different-speed',
      // The cylinder problem is the only one in the lesson about what it
      // takes to spin something up, and comparing arrangements is the whole
      // item.
      'harder-to-spin',
      // The block on the slope is the only problem in the lesson with a free
      // body worth drawing, and taking the weight apart is the whole item.
      'which-piece-drives-it',
      // The pump problem is the only one in the lesson about power, and which
      // way efficiency runs is the whole item.
      'more-in-than-out',
      // The barrier problem is the only one in the lesson about a force
      // acting over a time, and trading force against time is the whole item.
      'stretch-the-time',
      // The spring and mass problem is the only one in the lesson with a
      // system to pull aside and let go, and how it settles is the whole
      // item.
      'how-it-settles',
      // Chapter eight lesson three has three problems and they ARE its three
      // topics: thermal movement, what the furnace does, and the lever rule.
      // One item each, by construction.
      'which-one-moves-most',
      'out-of-the-furnace',
      'which-arm',
      // The mix selection problem is the only one in the lesson that names an
      // exposure, and matching a mix to a job is the whole item.
      'what-this-job-needs',
      // The sieve problem is the only one in the lesson about gradation, and
      // what its one number means is the whole item.
      'coarse-or-fine',
      // Chapter eight lesson eight has three problems and they ARE its three
      // topics: what moisture does to timber, the mortar order, and which way
      // the adjustment factors push. One item each, by construction.
      'above-the-point',
      'which-mortar',
      'does-it-go-up',
      // The table problem is the only one in the lesson with properties in
      // it, and crossing candidates off against requirements is the whole
      // item.
      'check-every-box',
      // Chapter nine lesson one has three problems and they ARE its three
      // topics: the three linked properties, viscosity, and capillary rise.
      // One item each, by construction.
      'which-property',
      'which-drags-more',
      'which-tube-climbs',
      // The manometer is the only problem in the lesson with a U-tube in it,
      // and walking it a step at a time is the whole item.
      'walk-the-manometer',
      // The buoyancy problem is the only one in the lesson with a floating
      // body in it, and which way it goes is the whole item.
      'float-or-sink',
      // Continuity is one problem in the lesson and the square in it is the
      // whole item, as is the jet problem and its head.
      'how-much-faster',
      'how-fast-the-jet',
      // The Reynolds problem is the only one in the lesson with a flow regime
      // in it, and reading the number against the thresholds is the item. So
      // is the fittings problem and its addition.
      'laminar-or-turbulent',
      'add-up-the-losses',
      // The jet problem is the only one in the lesson with a free jet in it,
      // and how far the face turns the water is the whole item. The bend
      // problem is the only one with a bend in it, and which way the push
      // comes out is the whole of the other.
      'which-target-takes-more',
      'where-the-block-goes',
      // Chapter ten lesson one has three problems and they ARE its three
      // topics: the bearing, the slope shot and the traverse check. Reading
      // a bearing off a plan and choosing the conversion rule are two
      // different skills and the lesson names both as traps, so the bearing
      // problem carries two items and the slope problem one.
      'find-it-on-the-plan',
      'which-rule-turns-it',
      'which-length-is-which',
      // The leveling lesson's first problem is one setup and its third is
      // the loop closure, so reading a pair of rods and reading a tolerance
      // each lean on the one problem that has them.
      'higher-or-lower',
      'which-run-is-allowed-more',
      // The traverse lesson has one problem per topic as well: the course
      // and its two signs, the precision ratio, and the compass rule.
      'plus-or-minus',
      'which-course-takes-the-most',
      'which-traverse-closed-better',
      // The offsets problem is the only one in the area lesson with a
      // baseline in it, and the weights are the whole of the two rules. The
      // quadrilateral is the only one with enough corners to list wrongly.
      'what-weight-does-it-get',
      'does-the-listing-close',
      // The station run is the only problem in the earthwork lesson with
      // more than two sections in it, so the round about skipping one leans
      // on it alone.
      'can-you-skip-a-section',
      // The quadrant question is the whole of the coordinate lesson's third
      // problem.
      'what-do-you-add',
      // The degree of curve problem is the only one in the curve lesson
      // with a degree of curve in it, and comparing two of them is the
      // whole item.
      'which-curve-is-sharper',
      // The channel problem is the only one in the open-channel lesson with
      // a wetted perimeter to get wrong: the pipe runs full and the third
      // problem is about roughness. Six ways of getting one perimeter wrong
      // is the item, and it is on purpose.
      'what-the-water-touches',
    ], reason: 'a NEW item now leans on one problem: intended, or an accident?');
  });
}
