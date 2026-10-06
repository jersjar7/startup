import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_plan.dart';

/// Hands the plan to the operating system, and nothing else.
///
/// All of it is LOCAL. Every alert the app sends is decided by two facts the
/// phone already holds, the exam date and whether anything was studied today,
/// so none of it needs a server, a push certificate or a network connection.
/// That also means the schedule can be tested properly, which a remote push
/// cannot be. See [notificationPlan] for every decision about what and when.
///
/// Permission is asked for lazily, the first time there is actually something
/// to schedule, rather than on first launch. Somebody who has just opened the
/// app has not yet been given a reason to say yes.
class Notifications {
  Notifications({FlutterLocalNotificationsPlugin? plugin, this.now = DateTime.now})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() now;

  /// Which notification was tapped to open the app, if any.
  ///
  /// Read once by whoever acts on it and then cleared. The outcome question is
  /// the only one that leads anywhere specific: tapping it has to land on the
  /// question, not on wherever the app happened to be, or the tap has cost the
  /// person something and given them nothing.
  static final tapped = ValueNotifier<NotifyKind?>(null);

  /// Set when the app was launched BY a notification rather than opened with
  /// one already running. Checked at startup, since the callback fires before
  /// any screen exists to react to it.
  static NotifyKind? launchedBy;

  /// Avoids a package dependency for one lookup.
  static NotifyKind? _kindNamed(String? name) {
    for (final k in NotifyKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }

  static void _onTap(NotificationResponse r) {
    final kind = _kindNamed(r.payload);
    if (kind == null) return;
    tapped.value = kind;
  }

  static const _askedKey = 'notif_permission_asked';
  static const _enabledKey = 'notif_enabled';

  /// Android needs a channel; iOS needs nothing until permission is asked.
  static const _channel = AndroidNotificationChannel(
    'study_reminders',
    'Study reminders',
    description: 'The evening nudge, exam countdowns and the morning after.',
    importance: Importance.defaultImportance,
  );

  bool _ready = false;
  bool _broken = false;

  /// Everything here goes through a plugin, and a plugin can be absent: in a
  /// widget test, on a platform that does not implement it, or when the host
  /// has torn the channel down. None of that is a reason for the profile
  /// screen to fail, so every entry point is guarded and a failure means
  /// "no reminders" rather than "no app".
  Future<T?> _guard<T>(Future<T> Function() body) async {
    if (_broken) return null;
    try {
      return await body();
    } catch (e) {
      _broken = true;
      debugPrint('[notifications] unavailable, carrying on without them: $e');
      return null;
    }
  }

  /// Safe to call more than once. Does not ask for permission.
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      // Version 5 returns a TimezoneInfo, not a bare string.
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // A phone that will not name its zone still gets notifications, just in
      // whatever the package defaults to. Better than none.
    }
    await _plugin.initialize(
      onDidReceiveNotificationResponse: _onTap,
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Asked for separately and deliberately, not on the first frame.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // A notification that launched the app from cold is not delivered through
    // the callback above, so it has to be asked for.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      final payload = launch!.notificationResponse?.payload;
      launchedBy = _kindNamed(payload);
      if (launchedBy != null) tapped.value = launchedBy;
    }
    _ready = true;
  }

  /// Whether this phone has ever been asked. Used to decide whether to show
  /// the explanation first.
  Future<bool> hasBeenAsked() async =>
      await _guard(() async =>
          (await SharedPreferences.getInstance()).getBool(_askedKey) ?? false) ??
      false;

  /// Whether reminders are on, as far as the app is concerned. The operating
  /// system has the final say and can revoke it from Settings at any time.
  Future<bool> isEnabled() async =>
      await _guard(() async =>
          (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false) ??
      false;

  Future<void> setEnabled(bool on) async {
    await _guard(() async {
      (await SharedPreferences.getInstance()).setBool(_enabledKey, on);
      if (!on) await cancelAll();
    });
  }

  /// Asks the operating system. Returns whether reminders can now be shown.
  Future<bool> requestPermission() async =>
      await _guard(_requestPermission) ?? false;

  Future<bool> _requestPermission() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_askedKey, true);

    bool granted = false;
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      granted = await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      // Android 13 and up needs a runtime permission; below that it is implicit.
      granted = await android.requestNotificationsPermission() ?? true;
    }
    await prefs.setBool(_enabledKey, granted);
    return granted;
  }

  /// The last inputs the schedule was built from.
  ///
  /// Kept because the two things that invalidate a schedule happen far from the
  /// screen that builds it: saving a new exam date, and studying. Before this
  /// existed, [rearm] ran only when the Profile tab first loaded, so a student
  /// who moved their exam date was counted down to the old one until the next
  /// cold launch, and somebody who studied in the evening was still told off at
  /// seven for not having studied.
  static String? _lastExamDay;
  static String? _lastStudyDay;

  /// Replaces the whole schedule with the current plan.
  ///
  /// Cancel-then-schedule rather than reconcile: the plan is at most sixty
  /// items, the ids are deterministic, and a reconcile that drifts would leave
  /// a student being nudged about an exam they have already sat.
  Future<void> rearm({String? examDay, String? lastStudyDay}) async {
    _lastExamDay = examDay ?? _lastExamDay;
    _lastStudyDay = lastStudyDay ?? _lastStudyDay;
    if (!await isEnabled()) return;
    await _guard(() => _rearm(examDay: _lastExamDay, lastStudyDay: _lastStudyDay));
  }

  /// The exam date moved, or was cleared. Rebuild against whatever it is now.
  ///
  /// Assigns rather than going through [rearm]'s `??`, because null here means
  /// "they cleared it" and must drop the old date, not fall back to it. Clearing
  /// the date and keeping its countdowns would be the worse of the two bugs.
  ///
  /// Takes the day explicitly rather than reading it back from the server: the
  /// caller has just written it, and a refresh that failed would otherwise leave
  /// the schedule pointing at the old date silently.
  Future<void> examDayChanged(String? examDay) async {
    _lastExamDay = examDay;
    if (!await isEnabled()) return;
    await _guard(() => _rearm(examDay: _lastExamDay, lastStudyDay: _lastStudyDay));
  }

  /// Something was studied today, so today's evening reminder is now wrong.
  ///
  /// Cheap to call on every successful sync: [rearm] rebuilds a fixed plan from
  /// fixed inputs, so calling it twice in a day changes nothing the second time.
  Future<void> studiedOn(DateTime day) => rearm(
    lastStudyDay: '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}',
  );

  /// Test seam. The cached inputs are static, so one test's schedule would
  /// otherwise leak into the next.
  static void resetCachedInputs() {
    _lastExamDay = null;
    _lastStudyDay = null;
  }

  @visibleForTesting
  static String? get debugExamDay => _lastExamDay;

  @visibleForTesting
  static String? get debugStudyDay => _lastStudyDay;

  Future<void> _rearm({String? examDay, String? lastStudyDay}) async {
    await init();
    final plan = notificationPlan(
      now: now(),
      examDay: examDay,
      lastStudyDay: lastStudyDay,
    );
    await cancelAll();
    for (final n in plan) {
      try {
        await _plugin.zonedSchedule(
          id: n.id,
          title: n.title,
          body: n.body,
          scheduledDate: tz.TZDateTime.from(n.when, tz.local),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: n.kind.name,
        );
      } catch (e) {
        // One rejected notification must never stop the rest being armed.
        debugPrint('[notifications] could not schedule ${n.kind}: $e');
      }
    }
  }

  Future<void> cancelAll() async {
    await _guard(() async {
      await init();
      await _plugin.cancelAll();
    });
  }

  /// What is actually queued. Used by the integration check, since the only
  /// honest way to know the operating system accepted a schedule is to ask it.
  Future<List<PendingNotificationRequest>> pending() async =>
      await _guard(() async {
        await init();
        return _plugin.pendingNotificationRequests();
      }) ??
      const [];
}
