import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/auth/email_hint.dart';

/// The email placeholder. Its whole job is to show the shape of an address
/// without naming a kind of person, so what is checked is that no single
/// domain can monopolise it and that school is one option among several.

void main() {
  tearDown(() => debugEmailHint = null);

  test('every placeholder is an address, and none of them is required', () {
    for (final h in emailHints) {
      expect(h, startsWith('you@'));
      expect(h, contains('.'));
    }
    // School belongs here, as one of several. Alone it reads as a rule, which
    // is what sent a student who had already graduated looking for a .edu.
    expect(emailHints, contains('you@school.edu'));
    expect(
      emailHints.where((h) => h.endsWith('.edu')).length,
      lessThan(emailHints.length),
      reason: 'the list has to reach past school',
    );
  });

  test('the whole list is reachable, so no domain is effectively fixed', () {
    final seen = <String>{};
    for (var seed = 0; seed < 200; seed++) {
      seen.add(emailHint(Random(seed)));
    }
    expect(seen, unorderedEquals(emailHints));
  });

  test('a test can pin it, and unpinning gives the list back', () {
    debugEmailHint = 'you@example.com';
    expect(emailHint(), 'you@example.com');
    debugEmailHint = null;
    expect(emailHints, contains(emailHint()));
  });
}
