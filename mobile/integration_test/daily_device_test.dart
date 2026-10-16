import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/notifications/notification_plan.dart';
import 'package:mobile/core/notifications/notifications.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/daily/daily_calendar.dart';
import 'package:mobile/features/daily/daily_models.dart';
import 'package:mobile/features/daily/daily_share.dart';

/// The Daily's parts that only a real phone can answer for. Everything else
/// about the Daily is walked in test/daily_journeys_test.dart, which is
/// faster and runs on every change; these run before a TestFlight build:
///
///     flutter test integration_test/daily_device_test.dart -d <simulator id>
///
/// See docs/mobile/TEST-JOURNEYS.md for what is checked where, and what is
/// still checked by hand (the share sheet itself, which nothing automated
/// can dismiss, and the notification permission dialog).
/// Since iOS 26 the simulator holds no scheduled notification for an app
/// that is not allowed to show them, and nothing automated can answer the
/// permission dialog. Grant it once per simulator, then run:
///
///     applesimutils --byId <simulator id> \
///       --bundle com.fe4raccoons.mobile --setPermissions notifications=YES
Future<void> _needsPermission() async {
  final ios = FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  final perm = await ios?.checkPermissions();
  if (ios != null && perm?.isEnabled != true) {
    fail(
      'This simulator has not allowed the app to show notifications, so iOS '
      'holds none. Grant it first (see _needsPermission).',
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('iOS holds the Daily reminders, and drops today\'s once it is '
      'played', (tester) async {
    await _needsPermission();
    final n = Notifications();
    await n.init();
    await n.setEnabled(true);
    await n.rearm(examDay: null);
    await n.dailyState(streak: 0);

    final today = dayKey(DateTime.now());
    final before = await n.pending();
    final ready = before.where((p) => p.title == 'Today\'s Daily is ready');
    expect(ready, isNotEmpty, reason: 'no morning Daily reminder queued');
    expect(
      before.where((p) => (p.title ?? '').contains('No.')),
      isEmpty,
      reason: 'a reminder shows a Daily number (ADR 0022)',
    );

    // Played today: today's evening reminder must go, tomorrow's stay.
    await n.dailyState(lastPlayedDay: today, streak: 1);
    final after = await n.pending();
    expect(after, isNotEmpty);
    // Ids are the day since 2020 times eight plus the kind (see
    // notification_plan.dart), so today's evening one has a known id.
    final d = DateTime.now();
    final days = DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime.utc(2020)).inDays;
    final tonight = days * 8 + NotifyKind.daily.index;
    expect(
      after.where((p) => p.id == tonight),
      isEmpty,
      reason: 'today\'s evening reminder survived a played Daily',
    );
    expect(
      after.where((p) => p.id == (days + 1) * 8 + NotifyKind.daily.index),
      isNotEmpty,
      reason: 'tomorrow\'s evening reminder went too',
    );
  });

  testWidgets('the share card renders to a real picture', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: const DailyShareCard(
                date: '2026-10-16',
                mine: DailyMine(
                  score: 16,
                  total: 18,
                  ms: 161000,
                  rounds: [
                    [true, true, true, true, true, true],
                    [true, false, true, true, true, true],
                    [true, true, true, false, true, true],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final bytes = await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 3);
      return image.toByteData(format: ui.ImageByteFormat.png);
    });
    // A blank or failed render is a few hundred bytes; a card is tens of KB.
    expect(bytes, isNotNull);
    expect(bytes!.lengthInBytes, greaterThan(20000));
  });
}
