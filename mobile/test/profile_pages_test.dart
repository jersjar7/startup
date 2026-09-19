import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/profile/exam_date_screen.dart';
import 'package:mobile/features/profile/mastery_model.dart';
import 'package:mobile/features/profile/mastery_screen.dart';
import 'package:mobile/features/profile/study_days_screen.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import 'support/fonts.dart';

/// The three pages behind the Profile tiles (references 16, 04, 17): the
/// mastery breakdown, the exam date, the study calendar. Photographed with
/// the clock pinned, and the numbers checked against the website's rules.

Widget _app(Widget home) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..user = {'email': 'r@school.edu', 'examDate': '2026-11-28'}
    ..status = AuthStatus.authenticated;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: home,
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 60)),
  );
  await tester.pumpAndSettle();
}

void _phone(WidgetTester tester, [double height = 844]) {
  tester.view.physicalSize = Size(390, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

const _sample = <String, int>{
  'mathematics': 62,
  'statistics': 35,
  'ethics': 84,
  'economics': 51,
  'statics': 48,
  'dynamics': 12,
  'mechanics-materials': 27,
  'fluid-mechanics': 9,
  'water-resources': 21,
  'structural': 16,
  'transportation': 6,
};

void main() {
  setUpAll(loadBrandFonts);
  setUp(() => appClock = () => DateTime(2026, 9, 18, 10));
  tearDown(() => appClock = DateTime.now);

  test('the weighted figure is the website\'s, not a plain average', () {
    // 62*13 + 35*4 + 84*4 + 51*4 + 48*8 + 12*4 + 27*8 + 9*4 + 21*14 + 16*13 + 6*10
    // = 806+140+336+204+384+48+216+36+294+208+60 = 2732, over 110 questions.
    expect(weightedMastery(_sample), 25);
    expect(weightedMastery({}), 0);
    expect(stageName(84), 'Mastered');
    expect(stageName(51), 'Familiar');
    expect(stageName(12), 'Building');
    expect(stageName(9), 'New');
  });

  test('focus is low mastery times high weight, mastered chapters out', () {
    expect(
      focusChapters(_sample),
      // (100-21)*14 = 1106, (100-0)*11 = 1100, (100-16)*13 = 1092.
      ['water-resources', 'geotechnical', 'structural'],
    );
    expect(focusChapters(_sample).first, 'water-resources');
    expect(focusChapters({'ethics': 95}), isNot(contains('ethics')));
  });

  testWidgets('concept mastery: the breakdown', (tester) async {
    _phone(tester, 1700);
    await tester.pumpWidget(_app(const MasteryScreen(mastery: _sample)));
    await _settle(tester);
    expect(find.text('25%', findRichText: true), findsOneWidget);
    expect(find.text('MASTERED'), findsOneWidget); // ethics
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/mastery.png'),
    );
  });

  testWidgets('exam day: the date on the account, ready to change', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_app(const ExamDateScreen(initial: '2026-11-28')));
    await _settle(tester);
    expect(find.text('Nov 28'), findsOneWidget);
    expect(find.text('71 days out'), findsOneWidget);
    expect(find.text('Clear the date'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/exam-date.png'),
    );

    // A month chip keeps the day where it can; the strip follows.
    await tester.tap(find.text('DEC'));
    await tester.pumpAndSettle();
    expect(find.text('Dec 28'), findsOneWidget);
  });

  testWidgets('exam day: nothing set yet starts today', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const ExamDateScreen()));
    await _settle(tester);
    expect(find.text('Sep 18'), findsOneWidget);
    expect(find.text('today'), findsOneWidget);
    expect(find.text('No date yet'), findsOneWidget);
  });

  testWidgets('days studied: the calendar', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _app(
        const StudyDaysScreen(
          count: 27,
          days: [
            '2026-08-03',
            '2026-09-01',
            '2026-09-02',
            '2026-09-04',
            '2026-09-05',
            '2026-09-08',
            '2026-09-09',
            '2026-09-11',
            '2026-09-12',
            '2026-09-15',
            '2026-09-16',
          ],
        ),
      ),
    );
    await _settle(tester);
    expect(find.text('10 OF 18 DAYS'), findsOneWidget);
    expect(find.text('September'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home/study-days.png'),
    );

    await tester.tap(find.text('AUG'));
    await tester.pumpAndSettle();
    expect(find.text('August'), findsOneWidget);
    expect(find.text('1 OF 31 DAYS'), findsOneWidget);
  });
}
