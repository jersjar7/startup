import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../games/game_catalog.dart';
import '../games/game_progress.dart';

/// The badges the app awards (tester's point 8, owner 2026-10-16).
///
/// Nineteen of them: a chapter's drawing for that chapter's first finished
/// lesson, and four milestones. None of them touches mastery (ADR 0020):
/// they say what was done, never how well it is known.
///
/// Nothing new is stored for them. They are worked out on the phone from
/// what it already keeps in sync with the server, the rounds cleared and the
/// Daily streak, so a student signing in on a new phone has the same badges
/// the moment their progress arrives. See docs/mobile/badges.md.
@immutable
class AppBadge {
  const AppBadge({
    required this.id,
    required this.title,
    required this.shortName,
    required this.line,
    required this.how,
    this.chapterId,
  });

  /// Also the id of the drawing on the coin (badge_marks.dart).
  final String id;

  /// Said large on the earned moment.
  final String title;

  /// Fits on one line under the coin on the Badges page.
  final String shortName;

  /// Said under the title once it is earned.
  final String line;

  /// How to earn it, said while it is not earned yet.
  final String how;

  /// Set for a chapter's badge.
  final String? chapterId;

  bool get isChapter => chapterId != null;

  /// Its place in the Rive file's list of drawings. The order is the
  /// contract: `mobile/rive/badge/gen.py` builds the drawings in this order.
  int get markIndex => allBadges.indexOf(this);
}

/// The names each chapter goes by on a badge: the full name on the earned
/// moment, a short one under the coin.
const _chapterNames = {
  'mathematics': ('Mathematics', 'Math'),
  'statistics': ('Probability and Statistics', 'Statistics'),
  'ethics': ('Ethics', 'Ethics'),
  'economics': ('Engineering Economics', 'Economics'),
  'statics': ('Statics', 'Statics'),
  'dynamics': ('Dynamics', 'Dynamics'),
  'mechanics-materials': ('Mechanics of Materials', 'Mechanics'),
  'materials': ('Materials', 'Materials'),
  'fluid-mechanics': ('Fluid Mechanics', 'Fluids'),
  'surveying': ('Surveying', 'Surveying'),
  'water-resources': ('Water Resources', 'Water'),
  'structural': ('Structural', 'Structural'),
  'geotechnical': ('Geotechnical', 'Geotech'),
  'transportation': ('Transportation', 'Transport'),
  'construction': ('Construction', 'Construction'),
};

final List<AppBadge> chapterBadges = [
  for (final id in chapterMaps.keys)
    AppBadge(
      id: id,
      chapterId: id,
      title: _chapterNames[id]!.$1,
      shortName: _chapterNames[id]!.$2,
      line: 'Your first lesson in ${_chapterNames[id]!.$1}, done.',
      how: 'Finish any lesson in ${_chapterNames[id]!.$1}.',
    ),
];

const List<AppBadge> milestoneBadges = [
  AppBadge(
    id: 'flawless',
    title: 'Flawless',
    shortName: 'Flawless',
    line: 'A whole lesson, every round right the first time.',
    how: 'Finish a lesson with every round right the first time.',
  ),
  AppBadge(
    id: 'first-daily',
    title: 'First Daily',
    shortName: 'First Daily',
    line: 'Your first Daily, done.',
    how: 'Play a Daily.',
  ),
  AppBadge(
    id: 'daily-7',
    title: 'Seven in a row',
    shortName: '7 in a row',
    line: 'Seven Dailies, seven days running.',
    how: 'Play the Daily seven days running.',
  ),
  AppBadge(
    id: 'every-chapter',
    title: 'Every chapter',
    shortName: 'All chapters',
    line: 'A round played in all fifteen chapters.',
    how: 'Play a round in every one of the fifteen chapters.',
  ),
];

final List<AppBadge> allBadges = [...chapterBadges, ...milestoneBadges];

AppBadge? badgeById(String id) {
  for (final b in allBadges) {
    if (b.id == id) return b;
  }
  return null;
}

/// Which badges [progress] and the best Daily run have earned.
Set<String> earnedBadgeIds(GameProgress progress, {required int dailyBest}) {
  final earned = <String>{};
  var flawless = false;
  var everyChapter = true;
  for (final chapter in chapterMaps.values) {
    if (!progress.hasTouched(chapter)) everyChapter = false;
    for (final lesson in chapter.lessons) {
      if (progress.stateOf(lesson) != LessonState.cleared) continue;
      earned.add(chapter.id);
      if (!flawless &&
          lesson.builtGames.every(
            (g) => progress.firstTryCount(g.id) >= GameProgress.roundsIn(g.id),
          )) {
        flawless = true;
      }
    }
  }
  if (flawless) earned.add('flawless');
  if (dailyBest >= 1) earned.add('first-daily');
  if (dailyBest >= 7) earned.add('daily-7');
  if (everyChapter) earned.add('every-chapter');
  return earned;
}

/// What the phone remembers for badges, and the badges waiting to be shown.
///
/// Rounds are already kept by [GameProgress]. The one other thing badges
/// need is the account's longest Daily run, which the server sends with
/// every Daily ([noteDailyBest]); it is kept here so the Badges page is right
/// without a connection.
///
/// A badge is only ever ANNOUNCED at the moment it is earned on this phone:
/// [watch] compares what was earned before and after a round. Badges that
/// arrive with a restore or a sign-in are simply there, never a burst of
/// celebrations for work done months ago on another phone.
class BadgeLedger {
  BadgeLedger._();

  static const _kDailyBest = 'badge_daily_best';

  /// The account's longest run of Dailies on consecutive days.
  static final dailyBest = ValueNotifier<int>(0);

  /// Badges earned and not yet shown, oldest first.
  static final pending = ValueNotifier<List<String>>(const []);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getInt(_kDailyBest) ?? 0;
      if (v > dailyBest.value) dailyBest.value = v;
    } catch (_) {
      // No storage (a widget test): it starts at zero and the server's next
      // Daily answer sets it.
    }
  }

  static Set<String> earnedNow() =>
      earnedBadgeIds(GameProgress.instance, dailyBest: dailyBest.value);

  /// Runs [change] and queues any badge it earned.
  static void watch(VoidCallback change) {
    final before = earnedNow();
    change();
    _queue(earnedNow().difference(before));
  }

  /// The server's word on the longest Daily run. [announce] is for the
  /// answer to a Daily just played; a plain fetch only updates the record.
  static Future<void> noteDailyBest(int best, {bool announce = false}) async {
    if (best <= dailyBest.value) return;
    final before = earnedNow();
    dailyBest.value = best;
    if (announce) _queue(earnedNow().difference(before));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kDailyBest, best);
    } catch (_) {}
  }

  static void _queue(Set<String> fresh) {
    final ordered = [
      for (final b in allBadges)
        if (fresh.contains(b.id) && !pending.value.contains(b.id)) b.id,
    ];
    if (ordered.isEmpty) return;
    pending.value = [...pending.value, ...ordered];
  }

  /// Takes every waiting badge, for the screen about to show them.
  static List<String> takePending() {
    final out = pending.value;
    pending.value = const [];
    return out;
  }

  /// A signed-out phone forgets the account's Daily run.
  static Future<void> clear() async {
    dailyBest.value = 0;
    pending.value = const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kDailyBest);
    } catch (_) {}
  }

  @visibleForTesting
  static void debugReset() {
    dailyBest.value = 0;
    pending.value = const [];
  }
}
