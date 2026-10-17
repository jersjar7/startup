import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/shared/widgets/kit.dart';

/// The one big text field every form uses (owner, 2026-10-17: the Contact
/// us message stayed on one line, opened lowercase, and the keyboard never
/// went away).

Widget _page(Widget field) => MaterialApp(
  home: Scaffold(
    body: Column(
      children: [
        Padding(padding: const EdgeInsets.all(24), child: field),
        const SizedBox(height: 200, child: Center(child: Text('elsewhere'))),
      ],
    ),
  ),
);

TextField _field(WidgetTester t) => t.widget<TextField>(find.byType(TextField));

void main() {
  testWidgets('a message wraps, opens on a capital and offers autocorrect', (
    t,
  ) async {
    await t.pumpWidget(
      _page(
        XLField(
          controller: TextEditingController(),
          label: 'Your message',
          hint: 'Your message',
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
    final f = _field(t);
    expect(f.maxLines, 6);
    expect(f.minLines, 1);
    expect(f.textCapitalization, TextCapitalization.sentences);
    expect(f.autocorrect, isTrue);
    expect(f.textInputAction, TextInputAction.newline);
  });

  testWidgets('a long message shows more than one line of what was typed', (
    t,
  ) async {
    final text = TextEditingController();
    await t.pumpWidget(
      _page(
        XLField(
          controller: text,
          label: 'Your message',
          hint: 'Your message',
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
    final oneLine = t.getSize(find.byType(TextField)).height;
    text.text = 'This is a long message about a round that looked wrong to me '
        'and I want to explain exactly why it did.';
    await t.pump();
    // A second line of type (24 point at 1.2) is about 29 points more.
    expect(t.getSize(find.byType(TextField)).height, greaterThan(oneLine + 24));
  });

  testWidgets('an email stays one plain line', (t) async {
    await t.pumpWidget(
      _page(
        XLField(
          controller: TextEditingController(),
          label: 'Email',
          hint: 'you@school.edu',
          keyboardType: TextInputType.emailAddress,
        ),
      ),
    );
    final f = _field(t);
    expect(f.maxLines, 1);
    expect(f.textCapitalization, TextCapitalization.none);
    expect(f.autocorrect, isFalse);
    expect(f.textInputAction, TextInputAction.done);
  });

  testWidgets('a name still opens on capitals', (t) async {
    await t.pumpWidget(
      _page(
        XLField(
          controller: TextEditingController(),
          label: 'First name',
          hint: 'First name',
          textCapitalization: TextCapitalization.words,
        ),
      ),
    );
    expect(_field(t).textCapitalization, TextCapitalization.words);
  });

  testWidgets('tapping anywhere else puts the keyboard away', (t) async {
    await t.pumpWidget(
      _page(
        XLField(
          controller: TextEditingController(),
          label: 'Your message',
          hint: 'Your message',
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
    bool focused() =>
        t.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
    await t.tap(find.byType(TextField));
    await t.pump();
    expect(focused(), isTrue);
    await t.tap(find.text('elsewhere'));
    await t.pump();
    expect(focused(), isFalse);
  });
}
