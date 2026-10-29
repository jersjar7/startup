import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/shared/widgets/math_text.dart';

void main() {
  test('a long formula breaks after its signs, each keeping its spacing', () {
    expect(formulaPieces(r'E\,[\text{N/mm}^2] \times \alpha \times \Delta T'), [
      r'E\,[\text{N/mm}^2] \times{}',
      r'\alpha \times{}',
      r'\Delta T',
    ]);
    expect(formulaPieces(r'M = \frac{wL^2}{8} + P a'), [
      r'M ={}',
      r'\frac{wL^2}{8} +{}',
      r'P a',
    ]);
  });

  test('a sign inside braces, a power or at the start is no break', () {
    expect(formulaPieces(r'-x^{-1} + 10^-3'), [r'-x^{-1} +{}', r'10^-3']);
    expect(formulaPieces(r'\left( a + b \right) \le c'), [
      r'\left( a + b \right) \le{}',
      'c',
    ]);
  });

  test('a sentence set as text breaks between its words', () {
    expect(formulaPieces(r'\text{one answer, at one place}'), [
      r'\text{one }',
      r'\text{answer, }',
      r'\text{at }',
      r'\text{one }',
      r'\text{place}',
    ]);
  });

  testWidgets('a formula that fits is drawn whole', (tester) async {
    tester.view.physicalSize = const Size(320, 200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MathText(r'Here $a = b$.'))),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap).hitTestable(), findsNothing);
  });

  testWidgets('a formula wider than the phone breaks and does not run off', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const long =
        r'$E\,[\text{N/mm}^2] \times \alpha\,[1/^\circ\text{C}] \times '
        r'\Delta T\,[^\circ\text{C}] \times E\,[\text{N/mm}^2] \times '
        r'\alpha\,[1/^\circ\text{C}]$';
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MathText(long))),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap).hitTestable(), findsOneWidget);
  });
}
