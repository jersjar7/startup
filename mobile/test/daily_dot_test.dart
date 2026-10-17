import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/daily/daily_calendar.dart';
import 'package:mobile/features/daily/daily_repository.dart';
import 'package:mobile/features/shared/widgets/kit.dart';

/// The ember dot on the dock's Daily button (owner, 2026-10-17): from the
/// start of each day until all three games are finished.

class _Server extends ApiClient {
  _Server({this.offline = false, this.puzzle});

  final bool offline;
  final Map<String, dynamic>? puzzle;

  @override
  Future<dynamic> get(String path) async {
    if (offline) throw Exception('no signal');
    return puzzle;
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    if (offline) throw Exception('no signal');
    return <String, dynamic>{};
  }
}

Map<String, dynamic> _puzzle(String date, {bool played = false}) => {
  'number': 3,
  'date': date,
  'games': <dynamic>[],
  'total': 9,
  'mine': null,
  'streak': {'current': 0, 'best': 0, 'playedToday': played},
};

void main() {
  final today = DateTime(2026, 10, 17, 9);
  final key = dayKey(today);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DailyDone.clear();
  });

  group('when the dot shows', () {
    test('until today is finished, and again the next day', () async {
      expect(DailyDone.dueOn(today), isTrue);
      await DailyDone.note(key);
      expect(DailyDone.dueOn(today), isFalse);
      expect(DailyDone.dueOn(today.add(const Duration(days: 1))), isTrue);
    });

    test('never before the first Daily', () {
      expect(DailyDone.dueOn(DateTime(2026, 10, 1)), isFalse);
    });

    test('survives a restart and is forgotten on sign out', () async {
      await DailyDone.note(key);
      DailyDone.day.value = null;
      await DailyDone.load();
      expect(DailyDone.dueOn(today), isFalse);
      await DailyDone.clear();
      await DailyDone.load();
      expect(DailyDone.dueOn(today), isTrue);
    });
  });

  group('what clears it', () {
    test('finishing all three games, even with no signal', () async {
      final repo = DailyRepository(_Server(offline: true));
      final sent = await repo.submit(
        number: 3,
        date: key,
        rounds: [
          [true],
        ],
        ms: 1000,
      );
      expect(sent, isNull, reason: 'kept to send later');
      expect(DailyDone.dueOn(today), isFalse);
    });

    test('a Daily already played, here or on another phone', () async {
      final repo = DailyRepository(
        _Server(puzzle: _puzzle(key, played: true)),
      );
      await repo.today(today);
      expect(DailyDone.dueOn(today), isFalse);
    });

    test('not opening the Daily without finishing it', () async {
      final repo = DailyRepository(_Server(puzzle: _puzzle(key)));
      await repo.today(today);
      expect(DailyDone.dueOn(today), isTrue);
    });
  });

  group('the dock', () {
    Widget dock(Set<int> dots) => MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomDock(
          items: const [
            DockItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
            ),
            DockItem(
              icon: Icons.wb_sunny_outlined,
              activeIcon: Icons.wb_sunny_rounded,
              label: 'Daily',
              dotLabel: "today's not played yet",
            ),
          ],
          index: 0,
          onSelect: (_) {},
          dots: dots,
        ),
      ),
    );

    testWidgets('draws the dot and says it out loud', (tester) async {
      await tester.pumpWidget(dock({1}));
      expect(find.byKey(const ValueKey('dock-dot-1')), findsOneWidget);
      expect(
        find.bySemanticsLabel("Daily, today's not played yet"),
        findsOneWidget,
      );
      await tester.pumpWidget(dock({}));
      expect(find.byKey(const ValueKey('dock-dot-1')), findsNothing);
      expect(find.bySemanticsLabel('Daily'), findsOneWidget);
    });
  });
}
