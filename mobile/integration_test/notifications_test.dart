import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/notifications/notification_plan.dart';
import 'package:mobile/core/notifications/notifications.dart';

/// Proves the reminders reach the operating system.
///
/// The unit tests cover WHAT is scheduled and WHEN, against a fake clock, and
/// they are the ones that guard the rules. They cannot tell you that iOS or
/// Android accepted a single one of them, because a plugin channel does not
/// exist in a widget test. This runs on a real simulator or device, arms the
/// schedule and then asks the operating system what it is actually holding.
///
///     flutter test integration_test/notifications_test.dart -d <device id>
///
/// WHAT THIS DOES NOT COVER, and cannot: the permission dialog itself. Nothing
/// can tap it in an automated run, and `xcrun simctl privacy` grants calendar,
/// contacts, photos, location and several others but has no notifications
/// service, so it cannot be pre-approved either. Permission is therefore set
/// directly here and the dialog is left to be checked by hand on a device.
///
/// Everything after that point is real: pendingNotificationRequests is answered
/// by the operating system and reports what it is actually holding, whether or
/// not the app is authorised to display any of it.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('the operating system accepts the whole schedule', (tester) async {
    final n = Notifications();
    await n.init();
    await n.setEnabled(true); // the dialog cannot be answered here, see above
    final exam = DateTime.now().add(const Duration(days: 45));
    await n.rearm(examDay: exam.toIso8601String().substring(0, 10));

    final pending = await n.pending();
    expect(pending, isNotEmpty, reason: 'nothing was queued');

    // The plan and the queue have to agree. A silent drop is the failure mode
    // worth catching: iOS keeps 64 and discards the rest without a word.
    final planned = notificationPlan(
      now: DateTime.now(),
      examDay: exam.toIso8601String().substring(0, 10),
    );
    expect(pending.length, planned.length,
        reason: 'the operating system kept ${pending.length} of ${planned.length}');
    expect(pending.length, lessThanOrEqualTo(64));

    final ids = pending.map((p) => p.id).toSet();
    expect(ids.length, pending.length, reason: 'two notifications share an id');
    for (final p in pending) {
      expect(p.title, isNotNull);
      expect(p.body, isNotNull);
    }
  });

  testWidgets('a distant exam does not overflow the queue', (tester) async {
    final n = Notifications();
    await n.init();
    await n.setEnabled(true);

    final exam = DateTime.now().add(const Duration(days: 400));
    await n.rearm(examDay: exam.toIso8601String().substring(0, 10));

    final pending = await n.pending();
    expect(pending.length, lessThanOrEqualTo(maxPending));
    expect(pending, isNotEmpty);
  });

  testWidgets('turning them off clears everything', (tester) async {
    final n = Notifications();
    await n.init();
    await n.setEnabled(true);
    await n.rearm(examDay: DateTime.now().add(const Duration(days: 30))
        .toIso8601String()
        .substring(0, 10));
    expect(await n.pending(), isNotEmpty);

    await n.setEnabled(false);
    expect(await n.pending(), isEmpty);
  });

  testWidgets('re-arming replaces rather than stacking', (tester) async {
    final n = Notifications();
    await n.init();
    await n.setEnabled(true);
    final day = DateTime.now().add(const Duration(days: 30))
        .toIso8601String()
        .substring(0, 10);

    await n.rearm(examDay: day);
    final first = (await n.pending()).length;
    await n.rearm(examDay: day);
    await n.rearm(examDay: day);
    expect((await n.pending()).length, first,
        reason: 'arming three times left more than one copy');
  });
}
