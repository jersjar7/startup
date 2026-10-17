import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/theme_mode.dart';
import 'package:mobile/features/profile/account_extras.dart';

/// Point 9, dark mode ("Warm night", owner 2026-10-17): every token has a
/// day and a night value, the phone's setting decides unless the student
/// chose, and switching repaints the app without closing anything.

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Appearance.choice.value = AppearanceChoice.automatic;
    AppPalette.dark = false;
  });
  tearDown(() => AppPalette.dark = false);

  group('a token', () {
    test('answers for the mode it is used in', () {
      expect(AppColors.fog.toARGB32(), 0xFFE3DFD7);
      AppPalette.dark = true;
      expect(AppColors.fog.toARGB32(), 0xFF1B1A18);
      expect(AppColors.charcoal.toARGB32(), 0xFFF2ECE2);
    });

    test('a bright accent and what sits on it stay put', () {
      AppPalette.dark = true;
      expect(AppColors.spring.toARGB32(), 0xFF63F0A8);
      expect(AppColors.onAccent.toARGB32(), 0xFF2C2C2C);
      // A spring FIELD turns down instead.
      expect(AppColors.springField.toARGB32(), isNot(0xFF63F0A8));
    });

    test('text keeps its contrast at night', () {
      AppPalette.dark = true;
      double lum(Color c) {
        double lin(double v) => v <= 0.03928
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
      }

      double ratio(Color a, Color b) {
        final x = lum(a), y = lum(b);
        return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
      }

      // The pairs the app is built from, read as it reads them at night.
      for (final (text, ground, min) in [
        (AppColors.charcoal, AppColors.fog, 4.5),
        (AppColors.charcoal, AppColors.cream, 4.5),
        (AppColors.charcoal, AppColors.creamDark, 4.5),
        (AppColors.charcoal, AppColors.butter, 4.5),
        (AppColors.charcoal, AppColors.peach, 4.5),
        (AppColors.charcoal, AppColors.springField, 4.5),
        (AppColors.mutedOnLight, AppColors.fog, 4.5),
        (AppColors.mutedOnLight, AppColors.cream, 4.5),
        (AppColors.forest, AppColors.fog, 4.5),
        (AppColors.ember, AppColors.fog, 4.5),
        (AppColors.onTile, AppColors.tile, 4.5),
        (AppColors.onAccent, AppColors.spring, 4.5),
        (AppColors.cream, AppColors.charcoal, 4.5),
        (AppColors.springOnDark, AppColors.charcoal, 3.0),
      ]) {
        expect(
          ratio(text, ground),
          greaterThanOrEqualTo(min),
          reason:
              '${text.toARGB32().toRadixString(16)} on '
              '${ground.toARGB32().toRadixString(16)}',
        );
      }
    });
  });

  test('a sheet stands off the dimmed screen behind it at night', () {
    // Owner, 2026-10-17: the sheet was the colour of the screen behind it.
    AppPalette.dark = true;
    double lum(Color c) => 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
    for (final scrim in [AppColors.scrim, AppColors.scrimDefault]) {
      final behind = lum(AppColors.fog) * (1 - scrim.a);
      expect(lum(AppColors.sheet), greaterThan(behind * 2.5));
    }
    // And a tile on the sheet stands off the sheet.
    expect(lum(AppColors.creamDark), greaterThan(lum(AppColors.sheet) * 1.15));
  });

  group('the choice', () {
    test('automatic follows the phone, and the others do not', () {
      expect(
        Appearance.resolve(AppearanceChoice.automatic, Brightness.dark),
        isTrue,
      );
      expect(
        Appearance.resolve(AppearanceChoice.automatic, Brightness.light),
        isFalse,
      );
      expect(
        Appearance.resolve(AppearanceChoice.light, Brightness.dark),
        isFalse,
      );
      expect(
        Appearance.resolve(AppearanceChoice.dark, Brightness.light),
        isTrue,
      );
    });

    test('is kept on the phone', () async {
      await Appearance.set(AppearanceChoice.dark);
      Appearance.choice.value = AppearanceChoice.automatic;
      await Appearance.load();
      expect(Appearance.choice.value, AppearanceChoice.dark);
    });
  });

  testWidgets('switching repaints every kind of thing, in place', (t) async {
    // Each of these keeps something from its first paint, and a const one
    // looks unchanged to Flutter in both modes. Measured on 2026-10-17: a
    // rounded tile and every piece of text stayed their day colours until
    // ThemeModeHost reset them.
    final boundary = GlobalKey();
    var built = 0;
    Widget band(Widget child) => SizedBox(width: 50, height: 20, child: child);
    await t.pumpWidget(
      ThemeModeHost(
        child: MaterialApp(
          home: RepaintBoundary(
            key: boundary,
            child: Material(
              color: const Color(0xFF808080),
              child: Align(
                alignment: Alignment.topLeft,
                child: Builder(
                  builder: (context) {
                    built++;
                    return Column(
                      key: const ValueKey('ground'),
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        band(
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.fog,
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        band(const ColoredBox(color: AppColors.fog)),
                        band(CustomPaint(painter: _Paper())),
                        band(
                          const Text(
                            '\u2588\u2588\u2588\u2588\u2588',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ),
                        band(
                          const Icon(
                            Icons.square,
                            size: 20,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Future<List<int>> lightest() async {
      final ro =
          boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      late List<int> out;
      await t.runAsync(() async {
        final im = await ro.toImage();
        final bytes = (await im.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        out = [
          for (var band = 0; band < 5; band++)
            [
              for (var y = band * 20 + 2; y < band * 20 + 18; y++)
                for (var x = 1; x < 48; x++)
                  bytes.getUint8((y * im.width + x) * 4),
            ].reduce(math.max),
        ];
      });
      return out;
    }

    Future<void> settle() async {
      for (var i = 0; i < 4; i++) {
        await t.pump();
        await t.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
      }
      await t.pump();
    }

    final route = ModalRoute.of(
      t.element(find.byKey(const ValueKey('ground'))),
    );
    final day = await lightest();
    // fog is light by day; the text and icon are charcoal on a grey ground.
    expect(day.take(3), everyElement(greaterThan(200)));
    final before = built;

    await Appearance.set(AppearanceChoice.dark);
    await settle();
    expect(AppPalette.dark, isTrue);
    final night = await lightest();
    expect(night.take(3), everyElement(lessThan(60)), reason: 'grounds turn');
    expect(night.skip(3), everyElement(greaterThan(200)), reason: 'ink turns');
    expect(built, greaterThan(before), reason: 'everything builds again');
    // The same route, so whatever was open is still open.
    expect(
      ModalRoute.of(t.element(find.byKey(const ValueKey('ground')))),
      same(route),
    );

    await Appearance.set(AppearanceChoice.automatic);
    await settle();
    expect(AppPalette.dark, isFalse, reason: 'the test phone is light');
    expect((await lightest()).take(3), everyElement(greaterThan(200)));
  });

  testWidgets('the account sheet offers Auto, Light and Dark', (t) async {
    await t.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppearanceRow())),
    );
    expect(find.text('APPEARANCE'), findsNothing);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('AUTO'), findsOneWidget);
    await t.tap(find.text('DARK'));
    await t.pump();
    expect(Appearance.choice.value, AppearanceChoice.dark);
  });
}

class _Paper extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.cream);

  // A board that never asks to repaint, like most of the games' figures.
  @override
  bool shouldRepaint(_Paper old) => false;
}
