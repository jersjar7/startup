import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/profile/pass_card.dart';

import 'support/fonts.dart';

/// The card a student publishes under their own name, so the rules here are
/// about what it is allowed to claim. Two of them exist because the alternative
/// was caught before it shipped: it must never invent a name, and it must never
/// print a per-chapter question count, because ours are from the NCEES
/// specification that was retired in 2020.
///
/// The golden is also the parity check against the web renderer. The two are
/// separate implementations of one design, and a change to either that is not a
/// change to both shows up here.

void main() {
  setUpAll(loadBrandFonts);

  group('what the card says', () {
    test('appends EIT so nobody has to know the abbreviation', () {
      final d = PassCardData.from(firstName: 'Jerson', lastName: 'Garcia');
      expect(d.name, 'Jerson Garcia, EIT');
      expect(d.hasName, isTrue);
    });

    test('takes a first name alone', () {
      expect(PassCardData.from(firstName: 'Jerson').name, 'Jerson, EIT');
    });

    test('says it has no name rather than inventing one', () {
      // Account creation has never collected a name, so this is the ordinary
      // case. The caller has to ask before drawing.
      final d = PassCardData.from();
      expect(d.name, isNull);
      expect(d.hasName, isFalse);
    });

    test('ignores whitespace that is not a name', () {
      expect(PassCardData.from(firstName: '  ', lastName: '').hasName, isFalse);
    });

    test('reads as a month and year, never a precise day', () {
      final d = PassCardData.from(
        firstName: 'A',
        answeredAt: DateTime(2026, 10, 20),
      );
      expect(d.when, 'October 2026');
    });

    test('falls back to now when the answer carries no timestamp', () {
      final d = PassCardData.from(firstName: 'A', now: DateTime(2026, 4, 2));
      expect(d.when, 'April 2026');
    });
  });

  group('what both renderers must agree on', () {
    test('the fifteen chapters, with no number against any of them', () {
      expect(passCardChapters, hasLength(15));
      for (final name in passCardChapters) {
        expect(RegExp(r'\d').hasMatch(name), isFalse,
            reason: '$name carries a figure the card cannot stand behind');
      }
    });

    test('only the total is printed, which both sources agree on', () {
      expect(passCardTotalQuestions, 110);
    });

    test('the link preview ratio the social networks crop to', () {
      expect(passCardWidth / passCardHeight, closeTo(1.91, 0.01));
    });

    test('exports at 2x so it survives a retina timeline', () {
      expect(passCardWidth * passCardExportScale, 2400);
    });

    test('the fifteen rows finish above the title block', () {
      const lastRow = 72.0 + 14 * 25.6;
      const titleRule = passCardHeight - 78;
      expect(lastRow, lessThan(titleRule));
    });
  });

  group('drawn', () {
    Widget host(PassCardData data) => MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Center(
        child: SizedBox(
          width: passCardWidth,
          height: passCardHeight,
          child: CustomPaint(painter: PassCardPainter(data)),
        ),
      ),
    );

    testWidgets('the card, named', (t) async {
      t.view.physicalSize = const Size(passCardWidth, passCardHeight);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(PassCardData.from(
        firstName: 'Jerson',
        lastName: 'Garcia',
        answeredAt: DateTime(2026, 10, 20),
      )));
      await t.pumpAndSettle();
      await expectLater(
        find.byType(CustomPaint).last,
        matchesGoldenFile('goldens/pass-card/named.png'),
      );
    });

    testWidgets('the card with no name draws no name, not a placeholder', (t) async {
      t.view.physicalSize = const Size(passCardWidth, passCardHeight);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(PassCardData.from(answeredAt: DateTime(2026, 10, 20))));
      await t.pumpAndSettle();
      await expectLater(
        find.byType(CustomPaint).last,
        matchesGoldenFile('goldens/pass-card/nameless.png'),
      );
    });

    testWidgets('renders at export size without throwing', (t) async {
      final image = await renderPassCard(PassCardData.from(firstName: 'Jerson'));
      expect(image.width, 2400);
      expect(image.height, 1254);
      image.dispose();
    });
  });
}
