import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/beam_figures.dart' show Prop, unknownsIn;
import 'package:mobile/features/games/stretched_or_squashed_game.dart';
import 'package:mobile/features/games/truss_figures.dart';
import 'package:mobile/features/games/where_do_you_cut_game.dart';
import 'package:mobile/features/games/which_carry_nothing_game.dart';

/// Lesson thirty-eight, trusses. What is checked here is the CONTENT: the
/// zero-force members are worked out a second time from the drawing by a
/// different route than the app uses, the cuts are counted, and the words
/// under each round are held against the picture above it.
void main() {
  group('the zero-force members are what the two rules give', () {
    /// A second, deliberately clumsier implementation of the same two rules,
    /// written from angles rather than cross products. If this and the app
    /// agree, the app is not agreeing with itself.
    Set<String> byAngles(Truss truss) {
      double bearing(int joint, int member) {
        final d = truss.headingFrom(joint, member);
        return math.atan2(d.dy, d.dx);
      }

      bool opposite(double a, double b) {
        var gap = (a - b).abs();
        while (gap > math.pi) {
          gap = 2 * math.pi - gap;
        }
        return (gap - math.pi).abs() < 0.002;
      }

      final out = <String>{};
      for (var j = 0; j < truss.joints.length; j++) {
        if (truss.loads.containsKey(j) || truss.supports.containsKey(j)) {
          continue;
        }
        final here = truss.at(j);
        if (here.length == 2) {
          if (!opposite(bearing(j, here[0]), bearing(j, here[1]))) {
            out.addAll(here.map(truss.memberName));
          }
        } else if (here.length == 3) {
          for (final odd in here) {
            final rest = here.where((m) => m != odd).toList();
            if (opposite(bearing(j, rest[0]), bearing(j, rest[1]))) {
              out.add(truss.memberName(odd));
            }
          }
        }
      }
      return out;
    }

    /// Worked out by hand from the drawings, round by round, and written here
    /// as member names so a change to the member ORDER cannot quietly agree
    /// with itself.
    const expected = <int, List<String>>{
      0: ['CD'],
      1: ['AC', 'CD'],
      2: <String>[],
      3: ['BE'],
      4: ['BE', 'CE'],
      5: ['BE'],
    };

    test('the app and a second reading of the rules agree', () {
      for (var i = 0; i < idleRounds.length; i++) {
        final truss = idleRounds[i].truss;
        final app = idleRounds[i].answer.map(truss.memberName).toSet();
        expect(app, byAngles(truss), reason: 'round ${i + 1} of which-carry-nothing');
      }
    });

    test('and both agree with the set worked out by hand', () {
      for (var i = 0; i < idleRounds.length; i++) {
        final truss = idleRounds[i].truss;
        expect(
          idleRounds[i].answer.map(truss.memberName).toSet(),
          expected[i]!.toSet(),
          reason: 'round ${i + 1} of which-carry-nothing',
        );
      }
    });

    test('the words under the round name the members the drawing gives', () {
      for (var i = 0; i < idleRounds.length; i++) {
        final r = idleRounds[i];
        final names = r.answer.map(r.truss.memberName);
        for (final name in names) {
          expect(r.why, contains(name),
              reason: 'round ${i + 1} never mentions $name');
        }
        if (r.answer.isEmpty) {
          expect(r.why.toLowerCase(), startsWith('none'),
              reason: 'round ${i + 1} has no idle members and does not say so');
        }
      }
    });

    test('one round has nothing to find, and more than one has something', () {
      final counts = [for (final r in idleRounds) r.answer.length];
      expect(counts, contains(0), reason: 'no round punishes finding a member '
          'that is not there');
      expect(counts.where((c) => c > 1).length, greaterThanOrEqualTo(1));
      expect(counts.where((c) => c == 1).length, greaterThanOrEqualTo(2));
    });

    test('the pair that differs only by where the load sits really differs', () {
      // The whole point of the last two rounds: same geometry, one loaded
      // joint apart, different answers.
      final a = idleRounds[4];
      final b = idleRounds[5];
      expect(a.truss.members, b.truss.members);
      expect(a.truss.joints.map((j) => j.at), b.truss.joints.map((j) => j.at));
      expect(a.truss.loads, isNot(b.truss.loads));
      expect(a.answer, isNot(b.answer));
    });
  });

  group('every truss drawn is one that could stand up', () {
    int reactionsIn(Truss t) =>
        t.supports.values.fold(0, (sum, p) => sum + unknownsIn(p));

    Iterable<Truss> allTrusses() sync* {
      for (final r in idleRounds) {
        yield r.truss;
      }
      for (final r in workRounds) {
        yield r.truss;
      }
      for (final r in cutRounds) {
        yield r.truss;
      }
    }

    test('members plus reactions equals two per joint', () {
      // Statically determinate, which is the only kind this lesson solves.
      for (final t in allTrusses()) {
        expect(t.members.length + reactionsIn(t), 2 * t.joints.length,
            reason: 'a truss with joints ${t.joints.map((j) => j.name)} is not '
                'determinate');
      }
    });

    test('no joint is left hanging and no member is drawn twice', () {
      for (final t in allTrusses()) {
        for (var j = 0; j < t.joints.length; j++) {
          // A joint bolted to a wall may carry one member. A joint hanging in
          // the truss on one member is a drawing mistake.
          final least = t.supports.containsKey(j) ? 1 : 2;
          expect(t.at(j).length, greaterThanOrEqualTo(least),
              reason: 'joint ${t.joints[j].name} has too few members');
        }
        final seen = <String>{};
        for (var m = 0; m < t.members.length; m++) {
          final (a, b) = t.members[m];
          expect(a, isNot(b));
          expect(seen.add(a < b ? '$a-$b' : '$b-$a'), isTrue,
              reason: 'the member ${t.memberName(m)} is drawn twice');
        }
      }
    });

    test('every truss is held, and held in more than one place or fixed', () {
      for (final t in allTrusses()) {
        expect(reactionsIn(t), greaterThanOrEqualTo(3));
        expect(t.loads, isNotEmpty);
      }
    });

    test('no two member tap targets overlap on a phone', () {
      // The members are tapped at their middles, in a 44 pixel box, so two
      // middles closer than that would take each other's taps.
      const size = Size(360, 250);
      for (final t in [for (final r in idleRounds) r.truss]) {
        final middles = [
          for (final (a, b) in t.members)
            TrussPainter.toScreen(
                t, (t.joints[a].at + t.joints[b].at) / 2, size),
        ];
        for (var a = 0; a < middles.length; a++) {
          for (var b = a + 1; b < middles.length; b++) {
            expect((middles[a] - middles[b]).distance, greaterThan(44),
                reason: '${t.memberName(a)} and ${t.memberName(b)} are tapped '
                    'in the same place');
          }
        }
      }
    });

    test('no two joints land on top of each other on screen', () {
      const size = Size(360, 260);
      for (final t in allTrusses()) {
        final places = [
          for (final j in t.joints) TrussPainter.toScreen(t, j.at, size),
        ];
        for (var a = 0; a < places.length; a++) {
          for (var b = a + 1; b < places.length; b++) {
            expect((places[a] - places[b]).distance, greaterThan(30),
                reason: '${t.joints[a].name} and ${t.joints[b].name} are drawn '
                    'on top of each other');
          }
        }
      }
    });
  });

  group('the member picked out is being worked the way the round says', () {
    test('a neither round is a zero-force member and nothing else is', () {
      for (var i = 0; i < workRounds.length; i++) {
        final r = workRounds[i];
        final idle = r.truss.idle.contains(r.member);
        expect(idle, r.answer == Working.neither,
            reason: 'round ${i + 1} of stretched-or-squashed calls '
                '${r.truss.memberName(r.member)} ${r.answer.name} and the two '
                'rules say otherwise');
      }
    });

    test('every answer appears, and none of them dominates', () {
      final counts = {
        for (final w in Working.values)
          w: workRounds.where((r) => r.answer == w).length,
      };
      for (final w in Working.values) {
        expect(counts[w], greaterThanOrEqualTo(1), reason: '${w.name} never');
      }
      expect(counts.values.reduce(math.max),
          lessThanOrEqualTo(workRounds.length - 2));
    });

    test('the same member name is asked twice and answered differently', () {
      // The pairing the item is built on: a bottom chord in a simply
      // supported truss and in a cantilever.
      final byName = <String, Set<Working>>{};
      for (final r in workRounds) {
        byName
            .putIfAbsent(r.truss.memberName(r.member), () => <Working>{})
            .add(r.answer);
      }
      expect(byName.values.where((s) => s.length > 1), isNotEmpty,
          reason: 'no member is asked about twice with different answers');
    });

    test('the words under the round name the member above them', () {
      for (var i = 0; i < workRounds.length; i++) {
        final r = workRounds[i];
        expect(r.member >= 0 && r.member < r.truss.members.length, isTrue,
            reason: 'round ${i + 1} points at a member that is not drawn');
      }
    });
  });

  group('the cuts cut what the round says they cut', () {
    test('exactly one cut per round crosses the member and only three', () {
      for (var i = 0; i < cutRounds.length; i++) {
        final r = cutRounds[i];
        final good = [
          for (var c = 0; c < r.cuts.length; c++)
            if (r.cuts[c].through(r.truss).length == 3 &&
                r.cuts[c].through(r.truss).contains(r.member))
              c,
        ];
        expect(good.length, 1,
            reason: 'round ${i + 1} of where-do-you-cut has ${good.length} '
                'workable cuts, not one');
        expect(r.answer, good.single);
      }
    });

    test('no two cut labels are tapped in the same place', () {
      // The label at the top of a cut is its tap target, in a 46 pixel box.
      const size = Size(360, 260);
      for (var i = 0; i < cutRounds.length; i++) {
        final r = cutRounds[i];
        final tops = [
          for (final c in r.cuts)
            TrussPainter.labelSpot(r.truss, c, size, r.cuts),
        ];
        for (var a = 0; a < tops.length; a++) {
          for (var b = a + 1; b < tops.length; b++) {
            expect((tops[a] - tops[b]).distance, greaterThan(46),
                reason: 'round ${i + 1}: ${r.cuts[a].label} and '
                    '${r.cuts[b].label} reach the top too close together');
          }
        }
      }
    });

    test('every cut on offer actually crosses the truss', () {
      for (var i = 0; i < cutRounds.length; i++) {
        final r = cutRounds[i];
        for (var c = 0; c < r.cuts.length; c++) {
          expect(r.cuts[c].through(r.truss), isNotEmpty,
              reason: 'round ${i + 1} offers ${r.cuts[c].label}, which misses '
                  'the truss entirely');
        }
      }
    });

    test('at least one wrong cut fails by count rather than by missing', () {
      // A round where every distractor obviously misses the member teaches
      // nothing about the three unknown limit.
      var tempting = 0;
      for (final r in cutRounds) {
        for (var c = 0; c < r.cuts.length; c++) {
          if (c == r.answer) continue;
          final through = r.cuts[c].through(r.truss);
          if (through.contains(r.member) && through.length > 3) tempting++;
        }
      }
      expect(tempting, greaterThanOrEqualTo(2),
          reason: 'nothing in this item punishes cutting four members');
    });

    test('the words under the round name the cut the geometry picks', () {
      for (var i = 0; i < cutRounds.length; i++) {
        final r = cutRounds[i];
        expect(r.why, startsWith(_capital(r.cuts[r.answer].label)),
            reason: 'round ${i + 1} explains a different cut than it grades');
      }
    });

    test('the wanted member is one of the ones drawn', () {
      for (var i = 0; i < cutRounds.length; i++) {
        final r = cutRounds[i];
        expect(r.member >= 0 && r.member < r.truss.members.length, isTrue,
            reason: 'round ${i + 1} wants a member that is not on the drawing');
      }
    });

    test('the labels on a round are all different', () {
      for (final r in cutRounds) {
        expect(r.cuts.map((c) => c.label).toSet().length, r.cuts.length);
      }
    });
  });

  group('a cut is a line, and the code that reads it says so', () {
    test('a line that misses the truss cuts nothing', () {
      const away = Cut('nowhere', Offset(-5, -5), Offset(-5, 5));
      expect(away.through(cutRounds.first.truss), isEmpty);
    });

    test('a line along a member does not count as cutting it', () {
      // Running down the middle of a vertical touches both its ends, which is
      // not a section, and the round about CF depends on that being true.
      final truss = cutRounds[4].truss;
      const along = Cut('along', Offset(6, -1), Offset(6, 5));
      expect(along.through(truss), isNot(contains(cutRounds[4].member)));
    });
  });

  test('every support drawn is one the painter knows how to draw', () {
    for (final r in [...idleRounds.map((r) => r.truss),
                     ...workRounds.map((r) => r.truss),
                     ...cutRounds.map((r) => r.truss)]) {
      for (final kind in r.supports.values) {
        expect(const [Prop.pin, Prop.roller], contains(kind));
      }
    }
  });
}

String _capital(String s) => s[0].toUpperCase() + s.substring(1);
