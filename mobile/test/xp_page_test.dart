import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/profile/xp_page.dart';

Map<String, dynamic> _state({int phoneToday = 35}) => {
  'totalXp': 1240,
  'xp': {
    'phone': 340,
    'web': 900,
    'phoneToday': phoneToday,
    'phoneDailyCap': 60,
  },
};

void main() {
  test('reads the split from the account state', () {
    final s = XpSplit.fromState(_state())!;
    expect((s.total, s.phone, s.web, s.phoneToday, s.phoneDailyCap), (
      1240,
      340,
      900,
      35,
      60,
    ));
    expect(s.phoneFullToday, isFalse);
    expect(XpSplit.fromState(_state(phoneToday: 60))!.phoneFullToday, isTrue);
    // A server from before the split.
    expect(XpSplit.fromState({'totalXp': 5}), isNull);
  });

  Widget app(Future<Map<String, dynamic>> Function() load) => MaterialApp(
    home: XpScreen(total: 1200, load: load),
  );

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('shows the total, both halves, and today', (tester) async {
    tall(tester);
    await tester.pumpWidget(app(() async => _state()));
    await tester.pumpAndSettle();
    expect(find.text('1,240'), findsOneWidget);
    expect(find.text('340'), findsOneWidget);
    expect(find.text('900'), findsOneWidget);
    expect(find.text('35 of 60'), findsOneWidget);
    expect(find.textContaining('up to 60 a day'), findsWidgets);
    expect(find.textContaining('They are not mastery'), findsOneWidget);
  });

  testWidgets('says so when today\'s app XP is full', (tester) async {
    tall(tester);
    await tester.pumpWidget(app(() async => _state(phoneToday: 60)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Full for today'), findsOneWidget);
  });

  testWidgets('with no signal, the total stays and the split says why', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(app(() async => throw Exception('offline')));
    await tester.pumpAndSettle();
    expect(find.text('1,200'), findsOneWidget);
    expect(find.textContaining('could not be reached'), findsOneWidget);
    expect(find.text('IN THE APP'), findsNothing);
  });

  group('a long name on the account sheet', () {
    double sizeOf(WidgetTester tester) =>
        tester.widget<Text>(find.byType(Text)).style!.fontSize!;

    Widget row(String name, double width) => MaterialApp(
      home: Center(
        child: SizedBox(width: width, child: ShrinkingName(name)),
      ),
    );

    testWidgets('a short one stays full size', (tester) async {
      await tester.pumpWidget(row('Jerson T.', 160));
      expect(sizeOf(tester), 24);
    });

    testWidgets('a long one gets smaller before it is cut', (tester) async {
      await tester.pumpWidget(row('Maximiliano R.', 150));
      final size = sizeOf(tester);
      expect(size, lessThan(24));
      expect(size, greaterThanOrEqualTo(18));
    });

    testWidgets('never below 18', (tester) async {
      await tester.pumpWidget(row('Bartholomew-Alessandro Q.', 120));
      expect(sizeOf(tester), 18);
    });
  });
}
