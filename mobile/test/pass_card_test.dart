import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/theme/app_colors.dart';
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

/// The caption must sit inside the card's bottom padding.
const _bottomPad = 40.0;

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
        expect(
          RegExp(r'\d').hasMatch(name),
          isFalse,
          reason: '$name carries a figure the card cannot stand behind',
        );
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

    test('one book per chapter', () {
      expect(passCardBooks, hasLength(passCardChapters.length));
    });

    test('the stack finishes above the title block', () {
      const bottomBook =
          PassCardStack.top +
          14 * PassCardStack.step +
          PassCardStack.bookHeight;
      const titleRule = passCardHeight - passCardTitleFromBottom;
      expect(bottomBook, lessThan(titleRule));
    });

    test('the title rule stops short of the stack and its caption', () {
      expect(passCardTitleRuleEnd, lessThan(PassCardStack.x));
      expect(passCardTitleRuleEnd, lessThan(PassCardStack.captionX));
      expect(PassCardStack.captionY, lessThan(passCardHeight - _bottomPad));
    });
  });

  group('drawn', () {
    Widget host(PassCardData data, ui.Image? peek) => MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Center(
        child: SizedBox(
          width: passCardWidth,
          height: passCardHeight,
          child: CustomPaint(painter: PassCardPainter(data, peek: peek)),
        ),
      ),
    );

    testWidgets('the card, named', (t) async {
      t.view.physicalSize = const Size(passCardWidth, passCardHeight);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final peek = await t.runAsync(loadPassCardPeek);
      expect(peek, isNotNull, reason: 'the raccoon asset must load');
      await t.pumpWidget(
        host(
          PassCardData.from(
            firstName: 'Jerson',
            lastName: 'Garcia',
            answeredAt: DateTime(2026, 10, 20),
          ),
          peek,
        ),
      );
      await t.pumpAndSettle();
      await expectLater(
        find.byType(CustomPaint).last,
        matchesGoldenFile('goldens/pass-card/named.png'),
      );
    });

    testWidgets('the card with no name draws no name, not a placeholder', (
      t,
    ) async {
      t.view.physicalSize = const Size(passCardWidth, passCardHeight);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      final peek = await t.runAsync(loadPassCardPeek);
      await t.pumpWidget(
        host(PassCardData.from(answeredAt: DateTime(2026, 10, 20)), peek),
      );
      await t.pumpAndSettle();
      await expectLater(
        find.byType(CustomPaint).last,
        matchesGoldenFile('goldens/pass-card/nameless.png'),
      );
    });

    // The card is posted to other platforms, so it is the light design even
    // when the phone is in dark mode. Same golden as the named card.
    testWidgets('dark mode draws the same light card', (t) async {
      t.view.physicalSize = const Size(passCardWidth, passCardHeight);
      t.view.devicePixelRatio = 1.0;
      addTearDown(t.view.reset);
      AppPalette.dark = true;
      addTearDown(() => AppPalette.dark = false);
      final peek = await t.runAsync(loadPassCardPeek);
      await t.pumpWidget(
        host(
          PassCardData.from(
            firstName: 'Jerson',
            lastName: 'Garcia',
            answeredAt: DateTime(2026, 10, 20),
          ),
          peek,
        ),
      );
      await t.pumpAndSettle();
      expect(AppPalette.dark, isTrue, reason: 'the painter puts the mode back');
      await expectLater(
        find.byType(CustomPaint).last,
        matchesGoldenFile('goldens/pass-card/named.png'),
      );
    });

    testWidgets('renders at export size without throwing', (t) async {
      final image = (await t.runAsync(
        () => renderPassCard(PassCardData.from(firstName: 'Jerson')),
      ))!;
      expect(image.width, 2400);
      expect(image.height, 1254);
      image.dispose();
    });
  });
}
