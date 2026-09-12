import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/cpm_figures.dart';
import 'package:mobile/features/games/when_can_it_start_game.dart';
import 'package:mobile/features/games/how_long_in_all_game.dart';
import 'package:mobile/features/games/which_way_the_pass_runs_game.dart';
import 'package:mobile/features/games/what_float_is_game.dart';
import 'package:mobile/features/games/the_chain_with_no_slack_game.dart';
import 'package:mobile/features/games/earned_value_figures.dart';
import 'package:mobile/features/games/which_variance_is_which_game.dart';
import 'package:mobile/features/games/what_it_will_cost_game.dart';

void main() {
  // The network the three scheduling lessons share.
  const shared = Network(tasks: [
    Task(name: 'A', days: 3),
    Task(name: 'B', days: 4, after: ['A']),
    Task(name: 'C', days: 2, after: ['A']),
    Task(name: 'D', days: 6, after: ['B']),
    Task(name: 'E', days: 3, after: ['B', 'C']),
  ]);

  group('the forward pass', () {
    test('early starts and finishes match the lesson', () {
      expect(shared.earlyStart['E'], 7);
      expect(shared.earlyFinish['E'], 10);
      expect(shared.earlyFinish['C'], 5);
      expect(shared.duration, 13);
    });

    test('a merge waits for the latest predecessor', () {
      // E waits on B, which finishes at 7, and C, which finishes at 5.
      expect(shared.earlyStart['E'],
          shared.earlyFinish['B']);
      expect(shared.earlyStart['E'],
          greaterThan(shared.earlyFinish['C']!));
    });

    test('two activities behind the same one start together', () {
      expect(shared.earlyStart['B'], shared.earlyStart['C']);
    });

    test('a simple chain adds its durations', () {
      const chain = Network(tasks: [
        Task(name: 'A', days: 4),
        Task(name: 'B', days: 6, after: ['A']),
        Task(name: 'D', days: 2, after: ['B']),
      ]);
      expect(chain.duration, 12);
    });

    test('the four activity network runs twelve days, not fifteen', () {
      const four = Network(tasks: [
        Task(name: 'A', days: 4),
        Task(name: 'B', days: 6, after: ['A']),
        Task(name: 'C', days: 3, after: ['A']),
        Task(name: 'D', days: 2, after: ['B', 'C']),
      ]);
      expect(four.duration, 12);
      // Adding every duration would give fifteen, which is the lesson's
      // own wrong answer.
      expect(four.tasks.fold<double>(0, (a, t) => a + t.days), 15);
      expect(four.criticalPath, ['A', 'B', 'D']);
      expect(four.totalFloatOf('C'), 3);
    });

    test('lengthening the slack branch moves the critical path', () {
      const flipped = Network(tasks: [
        Task(name: 'A', days: 4),
        Task(name: 'B', days: 6, after: ['A']),
        Task(name: 'C', days: 9, after: ['A']),
        Task(name: 'D', days: 2, after: ['B', 'C']),
      ]);
      expect(flipped.duration, 15);
      expect(flipped.criticalPath, ['A', 'C', 'D']);
      expect(flipped.isCritical('B'), isFalse);
    });
  });

  group('the backward pass', () {
    test('late starts and finishes match the lesson', () {
      expect(shared.lateStart['C'], 8);
      expect(shared.lateFinish['B'], 7);
      expect(shared.lateStart['D'], 7);
      expect(shared.lateFinish['D'], 13);
    });

    test('a burst must clear the earliest of its successors', () {
      // B feeds D, whose late start is 7, and E, whose late start is 10.
      expect(shared.lateFinish['B'], shared.lateStart['D']);
      expect(shared.lateFinish['B'], lessThan(shared.lateStart['E']!));
    });

    test('the backward pass starts from the project duration', () {
      expect(shared.lateFinish['D'], shared.duration);
      expect(shared.lateFinish['E'], shared.duration);
    });

    test('late start is the late finish less the duration', () {
      for (final t in shared.tasks) {
        expect(shared.lateStart[t.name],
            shared.lateFinish[t.name]! - t.days,
            reason: t.name);
      }
    });
  });

  group('float and the critical path', () {
    test('total float matches the lesson for C', () {
      expect(shared.totalFloatOf('C'), 5);
      // And the two ways of working it out agree.
      expect(shared.lateFinish['C']! - shared.earlyFinish['C']!, 5);
    });

    test('free float is the smaller of the two', () {
      expect(shared.freeFloatOf('C'), 2);
      expect(shared.freeFloatOf('C'),
          lessThanOrEqualTo(shared.totalFloatOf('C')));
    });

    test('every activity has free float no larger than its total', () {
      for (final t in shared.tasks) {
        expect(shared.freeFloatOf(t.name),
            lessThanOrEqualTo(shared.totalFloatOf(t.name) + 0.0001),
            reason: t.name);
      }
    });

    test('the critical chain has no float and is the longest path', () {
      expect(shared.criticalPath, ['A', 'B', 'D']);
      for (final name in shared.criticalPath) {
        expect(shared.totalFloatOf(name), closeTo(0, 0.0001), reason: name);
      }
      final length = shared.criticalPath
          .fold<double>(0, (sum, n) => sum + shared.named(n).days);
      expect(length, shared.duration);
    });

    test('two equally long paths are both critical', () {
      const tied = Network(tasks: [
        Task(name: 'A', days: 2),
        Task(name: 'B', days: 5, after: ['A']),
        Task(name: 'C', days: 5, after: ['A']),
        Task(name: 'D', days: 1, after: ['B', 'C']),
      ]);
      expect(tied.isCritical('B'), isTrue);
      expect(tied.isCritical('C'), isTrue);
    });
  });

  group('the scheduling items', () {
    test('every round that names an activity names one in its network', () {
      for (final r in startRounds) {
        if (r.highlight != null) {
          expect(r.network.tasks.map((t) => t.name), contains(r.highlight),
              reason: r.subject);
        }
      }
      for (final r in lengthRounds) {
        if (r.highlight != null) {
          expect(r.network.tasks.map((t) => t.name), contains(r.highlight),
              reason: r.subject);
        }
      }
      for (final r in passRounds) {
        if (r.highlight != null) {
          expect(r.network.tasks.map((t) => t.name), contains(r.highlight),
              reason: r.subject);
        }
      }
    });

    test('the items keep the answer moving between the slots', () {
      for (final answers in [
        startRounds.map((r) => r.answer).toList(),
        lengthRounds.map((r) => r.answer).toList(),
        passRounds.map((r) => r.answer).toList(),
        totalFloatRounds.map((r) => r.answer).toList(),
        criticalRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });

  group('earned value', () {
    test('the cost variance matches the lesson and reads over budget', () {
      const p = Progress(planned: 420000, earned: 400000, actual: 450000);
      expect(p.costVariance, -50000);
      expect(p.overBudget, isTrue);
    });

    test('the schedule variance is a different subtraction', () {
      const p = Progress(planned: 500000, earned: 420000, actual: 480000);
      expect(p.scheduleVariance, -80000);
      expect(p.costVariance, -60000);
      // The lesson prints the cost variance as a wrong answer to the
      // schedule question, and they are genuinely different numbers.
      expect(p.scheduleVariance, isNot(p.costVariance));
    });

    test('behind schedule and under budget is a real combination', () {
      const p = Progress(planned: 300000, earned: 270000, actual: 250000);
      expect(p.behindSchedule, isTrue);
      expect(p.overBudget, isFalse);
      expect(p.scheduleVariance, -30000);
      expect(p.costVariance, 20000);
    });

    test('both variances start from the earned value', () {
      const p = Progress(planned: 500000, earned: 420000, actual: 480000);
      expect(p.costVariance, p.earned - p.actual);
      expect(p.scheduleVariance, p.earned - p.planned);
    });
  });

  group('forecasting', () {
    const job = Progress(
      planned: 700000,
      earned: 600000,
      actual: 750000,
      budget: 2000000,
    );

    test('the cost index matches the lesson, and inverting it does not', () {
      expect(job.costIndex, closeTo(0.80, 0.001));
      expect(job.actual / job.earned, closeTo(1.25, 0.001));
    });

    test('the estimate to complete divides by the index', () {
      expect(job.remainingAtBudget, 1400000);
      expect(job.toComplete, closeTo(1750000, 1));
      expect(job.toComplete, greaterThan(job.remainingAtBudget));
    });

    test('the estimate at completion adds what is already spent', () {
      expect(job.atCompletion, closeTo(2500000, 1));
      expect(job.atCompletion, job.actual + job.toComplete);
      expect(job.atCompletion, greaterThan(job.budget!));
    });

    test('an index of one forecasts the original budget', () {
      const even = Progress(
        planned: 700000,
        earned: 700000,
        actual: 700000,
        budget: 2000000,
      );
      expect(even.costIndex, 1);
      expect(even.atCompletion, closeTo(2000000, 1));
    });

    test('an index above one forecasts a saving', () {
      const good = Progress(
        planned: 700000,
        earned: 700000,
        actual: 560000,
        budget: 2000000,
      );
      expect(good.costIndex, greaterThan(1));
      expect(good.atCompletion, lessThan(good.budget!));
    });

    test('the two earned value items keep the answer moving', () {
      for (final answers in [
        valueRounds.map((r) => r.answer).toList(),
        forecastRounds.map((r) => r.answer).toList(),
      ]) {
        expect(answers.toSet().length, greaterThan(2),
            reason: 'the correct option sits in too few positions');
      }
    });
  });

}
