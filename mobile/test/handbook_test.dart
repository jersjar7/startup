import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/handbook.dart';

void main() {
  test('names the edition before the page', () {
    expect(handbookLabel('Handbook p. 182'), 'Handbook $handbookEdition, p. 182');
    expect(handbookLabel('Handbook pp. 200-201'),
        'Handbook $handbookEdition, pp. 200-201');
  });

  test('leaves a section label on one line', () {
    expect(handbookLabel('Handbook, consolidation'), 'Handbook, consolidation');
    expect(handbookLabel('FE Handbook, spreadsheet section'),
        'FE Handbook, spreadsheet section');
  });

  test('leaves other references and labelled ones alone', () {
    expect(handbookLabel('MUTCD, signal warrants'), 'MUTCD, signal warrants');
    expect(handbookLabel('Model Rules, contracts'), 'Model Rules, contracts');
    final once = handbookLabel('Handbook p. 5, Model Rules B.6, B.8');
    expect(handbookLabel(once), once);
  });
}
