import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/email_hint.dart';
import 'package:mobile/features/shared/widgets/kit.dart';

import 'support/fonts.dart';

/// The email placeholder. Its whole job is to show the shape of an address
/// without naming a kind of person, so what is checked is that the domain
/// really does change on its own, that it stops the moment someone types, and
/// that no single domain can monopolise the field.

Widget _field(TextEditingController c, {bool reduceMotion = false}) =>
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: XLField(
              controller: c,
              label: 'Email',
              hint: emailHintPrefix,
              hintTail: emailHintDomains,
              hintTailEvery: emailHintEvery,
            ),
          ),
        ),
      ),
    );

/// Every domain currently painted anywhere in the field.
Set<String> _showing(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .where(emailHintDomains.contains)
    .toSet();

void main() {
  setUpAll(loadBrandFonts);
  tearDown(() => debugEmailHintStatic = null);

  test('the list is an example, not a rule', () {
    expect(emailHintPrefix, 'you@');
    for (final d in emailHintDomains) {
      expect(d, contains('.'));
      expect(d, isNot(contains('@')));
    }
    // School belongs here as one of several. Alone it reads as a requirement,
    // which is what the whole change is about.
    expect(emailHintDomains, contains('school.edu'));
    expect(
      emailHintDomains.where((d) => d.endsWith('.edu')).length,
      lessThan(emailHintDomains.length),
      reason: 'the list has to reach past school',
    );
    expect(emailHintEvery, const Duration(milliseconds: 1500));
  });

  testWidgets('the domain rolls on its own, and the head never moves', (
    tester,
  ) async {
    final c = TextEditingController();
    addTearDown(c.dispose);
    await tester.pumpWidget(_field(c));

    expect(find.text(emailHintPrefix), findsOneWidget);
    expect(_showing(tester), {emailHintDomains.first});

    // Walk four turns of the clock. Each turn crosses one tick and then lets
    // the roll finish, landing clear of the next tick, so the domain is never
    // read mid roll. Each turn has to land on the next domain in the list, and
    // the head has to stay exactly where it was.
    final headAt = tester.getTopLeft(find.text(emailHintPrefix));
    await tester.pump(const Duration(milliseconds: 600));
    for (var turn = 1; turn <= 4; turn++) {
      await tester.pump(const Duration(milliseconds: 900)); // lands on the tick
      await tester.pump(const Duration(milliseconds: 600)); // the roll finishes
      expect(
        _showing(tester),
        {emailHintDomains[turn % emailHintDomains.length]},
        reason: 'turn $turn',
      );
      expect(tester.getTopLeft(find.text(emailHintPrefix)), headAt);
    }
  });

  testWidgets('both domains are on screen mid roll, one above the other', (
    tester,
  ) async {
    final c = TextEditingController();
    addTearDown(c.dispose);
    await tester.pumpWidget(_field(c));

    await tester.pump(emailHintEvery);
    await tester.pump(const Duration(milliseconds: 180));

    expect(_showing(tester), {emailHintDomains[0], emailHintDomains[1]});
    final leaving = tester.getTopLeft(find.text(emailHintDomains[0])).dy;
    final arriving = tester.getTopLeft(find.text(emailHintDomains[1])).dy;
    expect(
      leaving,
      lessThan(arriving),
      reason: 'the old one travels up and out, the next comes up after it',
    );
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('typing stops it, clearing starts it again', (tester) async {
    final c = TextEditingController();
    addTearDown(c.dispose);
    await tester.pumpWidget(_field(c));

    await tester.enterText(find.byType(TextField), 'me@');
    await tester.pump();
    expect(find.text(emailHintPrefix), findsNothing);
    expect(_showing(tester), isEmpty);

    // And the clock does not keep running behind the typing.
    await tester.pump(emailHintEvery * 3);
    expect(_showing(tester), isEmpty);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(_showing(tester), {emailHintDomains.first});
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('it holds still when the phone asks for less motion', (
    tester,
  ) async {
    final c = TextEditingController();
    addTearDown(c.dispose);
    await tester.pumpWidget(_field(c, reduceMotion: true));

    expect(_showing(tester), {emailHintDomains.first});
    await tester.pump(emailHintEvery * 4);
    expect(_showing(tester), {emailHintDomains.first});
  });

  testWidgets('a test can pin it, which also stops the clock', (tester) async {
    debugEmailHintStatic = 'school.edu';
    final pinned = emailHintField();
    expect(pinned.head, 'you@school.edu');
    expect(pinned.tail, isNull);

    debugEmailHintStatic = null;
    final rolling = emailHintField();
    expect(rolling.head, emailHintPrefix);
    expect(rolling.tail, emailHintDomains);
  });
}
