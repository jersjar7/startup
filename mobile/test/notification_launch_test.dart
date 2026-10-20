import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/notifications/notification_plan.dart';
import 'package:mobile/core/notifications/notifications.dart';

/// The system answers "which notification launched the app" with the same
/// notification for as long as the app runs. Every round sent makes a new
/// Notifications and initialises it, so reading that answer each time sent a
/// student back to the Daily tab after every round of a session opened from
/// the morning reminder (owner's phone, 2026-10-19).
class _LaunchedByDaily implements FlutterLocalNotificationsPlugin {
  int launchReads = 0;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  T? resolvePlatformSpecificImplementation<
    T extends FlutterLocalNotificationsPlatform
  >() => null;

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async {
    launchReads++;
    return NotificationAppLaunchDetails(
      true,
      notificationResponse: NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: NotifyKind.daily.name,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Notifications.debugResetLaunch();
  });

  test('the notification that launched the app is acted on once, however '
      'many times reminders are rearmed', () async {
    final plugin = _LaunchedByDaily();

    await Notifications(plugin: plugin).init();
    expect(Notifications.tapped.value, NotifyKind.daily);

    // The home screen acts on it and clears it.
    Notifications.tapped.value = null;

    // Then a round is answered, its sync rearms the reminders through a new
    // Notifications, and the launch must not be replayed.
    for (var round = 0; round < 3; round++) {
      await Notifications(plugin: plugin).init();
      expect(Notifications.tapped.value, isNull, reason: 'round $round');
    }
    expect(plugin.launchReads, 1);
  });
}
