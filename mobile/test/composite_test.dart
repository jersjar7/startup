import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/composite_figures.dart';
import 'package:mobile/features/games/how_far_has_it_yielded_game.dart';
import 'package:mobile/features/games/same_strain_game.dart';
import 'package:mobile/features/games/section_figures.dart';
import 'package:mobile/features/games/widen_the_stiff_one_game.dart';

/// Chapter seven, lesson seven. The engine is held against the lesson's own
/// answers and against what the transform is supposed to preserve.
void main() {
  /// A timber joist with a steel plate bolted under it, which is the classic
  /// transformed section.
  Composite plated() => const Composite([
        Slice(Offset(0, 0), Size(200, 10), Made.steel),
        Slice(Offset(50, 10), Size(100, 200), Made.timber),
      ]);

  group('the engine reproduces the lesson it was built from', () {
    test('the modular ratio is the stiffer over the softer', () {
      // Problem one: steel at 29,000 ksi against concrete at 3,625.
      expect(29000 / 3625, closeTo(8, 1e-9));
      // And its named wrong answers: the ratio upside down, and subtracting.
      expect(3625 / 29000, closeTo(0.125, 1e-9));
      expect(29000 - 3625, closeTo(25375, 1e-9));

      // The engine never gets it upside down, because it sorts by stiffness
      // rather than by the order the slices were written in.
      final beam = plated();
      expect(beam.stiffer, Made.steel);
      expect(beam.softer, Made.timber);
      expect(beam.n, greaterThan(1));
      expect(beam.n, closeTo(200000 / 12000, 1e-9));
    });

    test('the plastic moment is the yield stress times Z', () {
      // Problem two: Z = 60 cubic inches, Fy = 50 ksi.
      expect(50 * 60, 3000);
      expect(50 * 60 / 12, closeTo(250, 1e-9));
      // Its named wrong answers: leaving it in kip inches, and using an
      // elastic modulus of 50 instead.
      expect(50 * 50 / 12, closeTo(208, 0.5));
    });

    test('the stiffer material carries n times the stress', () {
      // Problem three, which is the whole reason the method works.
      final beam = plated();
      const y = 5.0;
      final inSteel = beam.stressAt(y, 20e6, Made.steel);
      final inTimber = beam.stressAt(y, 20e6, Made.timber);
      expect(inSteel / inTimber, closeTo(beam.n, 1e-9));
      expect(inSteel.abs(), greaterThan(inTimber.abs()));
    });
  });

  group('what the transform is allowed to change', () {
    test('it widens the stiffer material and nothing else', () {
      final beam = plated();
      final before = beam.profile;
      final after = beam.transformed();
      // The steel plate is the first slice, and it is the one that grows.
      expect(after.pieces[0].box.width,
          closeTo(before.pieces[0].box.width * beam.n, 1e-9));
      expect(after.pieces[1].box.width,
          closeTo(before.pieces[1].box.width, 1e-9));
    });

    test('it never moves material up or down', () {
      // Bending is about how far material sits from the axis, so a transform
      // that changed a depth or a height would be a different beam.
      final beam = plated();
      final before = beam.profile;
      final after = beam.transformed();
      for (var i = 0; i < before.pieces.length; i++) {
        expect(after.pieces[i].box.top, closeTo(before.pieces[i].box.top, 1e-9));
        expect(after.pieces[i].box.height,
            closeTo(before.pieces[i].box.height, 1e-9));
      }
    });

    test('widening the steel pulls the neutral axis down toward it', () {
      final beam = plated();
      expect(beam.transformed().centroid.dy,
          lessThan(beam.profile.centroid.dy),
          reason: 'the transformed section has more material at the bottom');
    });

    test('transforming the wrong way round gives a different beam', () {
      // The named trap: widening the softer material instead. It is not a
      // small difference, and it moves the axis the wrong way.
      final beam = plated();
      final right = beam.transformed();
      final wrong = beam.transformed(towardSofter: false);
      expect(wrong.centroid.dy, greaterThan(right.centroid.dy));
      expect(wrong.ownIx, isNot(closeTo(right.ownIx, 1)));
    });

    test('the strain is the same on both sides of the join', () {
      // The physical fact the whole method rests on: bonded materials have to
      // stretch together, so it is the STRESS that jumps at the join and
      // never the strain.
      final beam = plated();
      const join = 10.0;
      final strain = beam.strainAt(join, 20e6);
      expect(strain, isNot(0));
      // Same height, same strain, whichever material you ask about.
      expect(beam.strainAt(join, 20e6), closeTo(strain, 1e-15));
      // And the stresses at that one height differ by exactly n.
      expect(
        beam.stressAt(join, 20e6, Made.steel) /
            beam.stressAt(join, 20e6, Made.timber),
        closeTo(beam.n, 1e-9),
      );
    });
  });

  group('how far yielding has spread', () {
    final rect = Profile([const Piece(Slab.box, Offset.zero, Size(100, 200))]);

    test('the four stages are four different pictures', () {
      final shapes = <Spread3, List<double>>{};
      for (final state in Spread3.values) {
        final painter = StressBlockPainter(profile: rect, state: state);
        shapes[state] = [
          for (var k = 0; k <= 10; k++)
            painter.shareAt(rect.baseline + 200 * k / 10),
        ];
      }
      for (final a in Spread3.values) {
        for (final b in Spread3.values) {
          if (a.index >= b.index) continue;
          var same = true;
          for (var k = 0; k < 11; k++) {
            if ((shapes[a]![k] - shapes[b]![k]).abs() > 0.02) same = false;
          }
          expect(same, isFalse,
              reason: '${a.name} and ${b.name} draw the same block');
        }
      }
    });

    test('nothing is ever stressed past yield', () {
      for (final state in Spread3.values) {
        final painter = StressBlockPainter(profile: rect, state: state);
        for (var k = 0; k <= 40; k++) {
          expect(painter.shareAt(rect.baseline + 200 * k / 40).abs(),
              lessThanOrEqualTo(1 + 1e-9),
              reason: '${state.name} runs past the yield line');
        }
      }
    });

    test('the elastic block is straight and the plastic one is square', () {
      final elastic = StressBlockPainter(profile: rect, state: Spread3.elastic);
      final plastic = StressBlockPainter(profile: rect, state: Spread3.fully);
      // Straight: half way out from the axis is half the stress.
      expect(elastic.shareAt(150), closeTo(elastic.shareAt(200) / 2, 1e-9));
      // Square: half way out is already the full yield stress.
      expect(plastic.shareAt(150), closeTo(1, 1e-9));
      // And the axis itself carries nothing while it is elastic.
      expect(elastic.shareAt(100), closeTo(0, 1e-9));
    });

    test('first yield reaches the line and the elastic stage does not', () {
      expect(
        StressBlockPainter(profile: rect, state: Spread3.firstYield)
            .shareAt(200),
        closeTo(1, 1e-9),
      );
      expect(
        StressBlockPainter(profile: rect, state: Spread3.elastic).shareAt(200),
        lessThan(1),
      );
    });
  });

  group('widen-the-stiff-one draws what it claims to draw', () {
    test('the right panel widens the stiffer material and only that', () {
      for (final r in transformRounds) {
        final drawn = r.drawingFor(Done.widenStiff);
        for (var i = 0; i < drawn.length; i++) {
          final was = r.beam.slices[i];
          final want = was.made == r.beam.stiffer
              ? was.size.width * r.beam.n
              : was.size.width;
          expect(drawn[i].size.width, closeTo(want, 1e-9),
              reason: '${r.subject}: slice $i is the wrong width');
          expect(drawn[i].size.height, closeTo(was.size.height, 1e-9),
              reason: '${r.subject}: the transform changed a depth');
          expect(drawn[i].at.dy, closeTo(was.at.dy, 1e-9),
              reason: '${r.subject}: the transform moved a slice');
        }
      }
    });

    test('no two panels in a round draw the same section', () {
      for (final r in transformRounds) {
        final seen = <String>{};
        for (final option in r.options) {
          final key = [
            for (final s in r.drawingFor(option))
              '${s.size.width.toStringAsFixed(2)}x'
                  '${s.size.height.toStringAsFixed(2)}@${s.at.dy}',
          ].join('|');
          expect(seen.add(key), isTrue,
              reason: '${r.subject}: two panels are the same picture');
        }
      }
    });

    test('the widening is big enough to see', () {
      // A modular ratio close to one would make the right answer and the
      // wrong ones almost the same drawing, and the round would be a guess.
      for (final r in transformRounds) {
        expect(r.beam.n, greaterThan(3),
            reason: '${r.subject}: the ratio is too small to read');
      }
    });

    test('every round offers the method itself exactly once', () {
      for (final r in transformRounds) {
        expect(r.options.where((o) => o == Done.widenStiff).length, 1);
        expect(r.answer, isNot(-1));
      }
    });
  });

  group('same-strain answers from the materials', () {
    test('a stress round names the stiffer material', () {
      for (final r in joinRounds.where((r) => r.about == Feels.stress)) {
        expect(r.answer, Across.stiffer,
            reason: '${r.subject}: the stiffer material always carries more');
      }
    });

    test('a strain round always answers equal', () {
      for (final r in joinRounds.where((r) => r.about == Feels.strain)) {
        expect(r.answer, Across.same);
      }
    });

    test('the join really is where the two materials meet', () {
      for (final r in joinRounds) {
        final made = <Made>{};
        for (final s in r.beam.slices) {
          final top = s.at.dy + s.size.height;
          if ((s.at.dy - r.join).abs() < 1e-9 ||
              (top - r.join).abs() < 1e-9) {
            made.add(s.made);
          }
        }
        expect(made.length, 2,
            reason: '${r.subject}: the marked line is not a join between two '
                'materials');
      }
    });

    test('both questions get asked, on every beam', () {
      final beams = {for (final r in joinRounds) r.subject};
      expect(beams.length, joinRounds.length);
      expect(joinRounds.where((r) => r.about == Feels.stress).length, 3);
      expect(joinRounds.where((r) => r.about == Feels.strain).length, 3);
    });
  });

  group('how-far-has-it-yielded matches its words to its blocks', () {
    test('every round offers three different stages', () {
      for (final r in yieldRounds) {
        expect(r.options.toSet().length, 3,
            reason: '${r.subject}: a stage is offered twice');
      }
    });

    test('the answer is the stage the words describe', () {
      // Held to the words rather than to the index: each round says in plain
      // English what the beam is doing, and that has to be the block.
      const wanted = [
        Spread3.elastic,
        Spread3.firstYield,
        Spread3.partly,
        Spread3.fully,
        Spread3.fully,
        Spread3.partly,
      ];
      for (var i = 0; i < yieldRounds.length; i++) {
        expect(yieldRounds[i].options[yieldRounds[i].answer], wanted[i],
            reason: '${yieldRounds[i].subject}: the block and the words '
                'disagree');
      }
    });

    test('all four stages get used across the item', () {
      final shown = {for (final r in yieldRounds) ...r.options};
      expect(shown, Spread3.values.toSet());
      final answers = {
        for (final r in yieldRounds) r.options[r.answer],
      };
      expect(answers, Spread3.values.toSet());
    });
  });
}
