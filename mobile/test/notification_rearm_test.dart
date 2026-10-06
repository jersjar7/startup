import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/notifications/notifications.dart';

/// The schedule used to be rebuilt in exactly one place: the Profile tab's
/// first load, which is once per app launch. The two things that actually
/// invalidate it happen elsewhere, so both went unnoticed until a student felt
/// them:
///
///   * moving the exam date left every countdown, every quiet day and the
///     outcome question itself pointing at the old one;
///   * studying in the evening still earned the seven o'clock "you have not
///     studied today".
///
/// What is guarded here is that the inputs survive between call sites, that
/// clearing the date clears it rather than falling back, and that neither path
/// can throw into the caller.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Notifications.resetCachedInputs();
    // Reminders off: rearm returns before it touches the plugin, which is what
    // makes these runnable without a platform. The caching happens first and is
    // what this file is about.
    SharedPreferences.setMockInitialValues({'notif_enabled': false});
  });

  group('the inputs survive between call sites', () {
    test('a date given once is still used when only study is reported', () async {
      final n = Notifications();
      await n.rearm(examDay: '2026-04-10', lastStudyDay: '2026-03-01');
      await n.studiedOn(DateTime(2026, 3, 2));
      expect(Notifications.debugExamDay, '2026-04-10');
      expect(Notifications.debugStudyDay, '2026-03-02');
    });

    test('study reported first is not wiped by a later date change', () async {
      final n = Notifications();
      await n.studiedOn(DateTime(2026, 3, 2));
      await n.examDayChanged('2026-06-01');
      expect(Notifications.debugStudyDay, '2026-03-02');
      expect(Notifications.debugExamDay, '2026-06-01');
    });
  });

  group('moving the exam date', () {
    test('replaces the old one', () async {
      final n = Notifications();
      await n.rearm(examDay: '2026-04-10');
      await n.examDayChanged('2026-06-01');
      expect(Notifications.debugExamDay, '2026-06-01');
    });

    test('clearing it drops the date rather than falling back', () async {
      // The worse of the two bugs: a cleared date that keeps its countdowns
      // means somebody is reminded about an exam they told us they are not
      // sitting. rearm's `??` would have done exactly that.
      final n = Notifications();
      await n.rearm(examDay: '2026-04-10');
      await n.examDayChanged(null);
      expect(Notifications.debugExamDay, isNull);
    });
  });

  group('studying', () {
    test('records the calendar day, zero padded', () async {
      await Notifications().studiedOn(DateTime(2026, 3, 2, 18, 45));
      expect(Notifications.debugStudyDay, '2026-03-02');
    });

    test('a later session the same day is not a different day', () async {
      final n = Notifications();
      await n.studiedOn(DateTime(2026, 3, 2, 9));
      await n.studiedOn(DateTime(2026, 3, 2, 21));
      expect(Notifications.debugStudyDay, '2026-03-02');
    });
  });

  test('neither path throws when there is no plugin behind it', () async {
    // Both call sites sit after a write that already succeeded. A notification
    // failure must never surface as a failed save or a failed sync.
    final n = Notifications();
    await expectLater(n.examDayChanged('2026-04-10'), completes);
    await expectLater(n.studiedOn(DateTime(2026, 3, 2)), completes);
  });
}
