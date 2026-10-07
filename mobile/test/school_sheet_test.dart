@Tags(['shots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/profile/account_extras.dart';

import 'support/fonts.dart';

/// Tapping "School" used to open a second bottom sheet on top of the account
/// one, leaving the first visible behind at its own taller height. It now swaps
/// the content of the sheet it is already in, which only works if there is a
/// visible way back.

class _Api extends ApiClient {
  _Api({this.suggest = const []});

  /// What the suggestions endpoint returns, and what was saved.
  final List<String> suggest;
  final posts = <(String, Map<String, dynamic>?)>[];

  @override
  Future<dynamic> post(String p, [Map<String, dynamic>? b]) async {
    posts.add((p, b));
    return {'ok': true};
  }

  @override
  Future<dynamic> put(String p, [Map<String, dynamic>? b]) async {
    posts.add((p, b));
    return {'ok': true};
  }

  @override
  Future<dynamic> get(String p) async {
    if (p.startsWith('/auth/schools')) return <String, dynamic>{'schools': suggest};
    return <String, dynamic>{'email': 'a@b.com'};
  }
}

AuthController _auth([_Api? api]) =>
    AuthController(api: api ?? _Api(), storage: AppStorage())
      ..user = {'email': 'a@b.com'}
      ..status = AuthStatus.authenticated;

void main() {
  setUpAll(loadBrandFonts);

  Widget host(AuthController auth) => ChangeNotifierProvider.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.cream,
        body: AccountSheetHost(
          auth: auth,
          account: Column(
            mainAxisSize: MainAxisSize.min,
            children: [SchoolRow(auth: auth)],
          ),
        ),
      ),
    ),
  );

  testWidgets('the school form replaces the account content in place', (t) async {
    t.view.physicalSize = const Size(1170, 1400);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final auth = _auth();
    await t.pumpWidget(host(auth));
    await t.pumpAndSettle();
    expect(find.text('School'), findsOneWidget);
    expect(find.text('Where do you study?'), findsNothing);

    await t.tap(find.text('School'));
    await t.pumpAndSettle();

    // The form is showing, and the row it came from is gone rather than
    // sitting behind it.
    expect(find.text('Where do you study?'), findsOneWidget);
    expect(find.byType(SchoolRow), findsNothing);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('shots/school-in-place.png'),
    );
  });

  testWidgets('there is a visible way back, not just a gesture', (t) async {
    t.view.physicalSize = const Size(1170, 1400);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final auth = _auth();
    await t.pumpWidget(host(auth));
    await t.pumpAndSettle();
    await t.tap(find.text('School'));
    await t.pumpAndSettle();

    final back = find.text('Account');
    expect(back, findsOneWidget, reason: 'a gesture nobody can see is not a way out');

    await t.tap(back);
    await t.pumpAndSettle();
    expect(find.text('Where do you study?'), findsNothing);
    expect(find.byType(SchoolRow), findsOneWidget);
  });

  suggestionTests();

  testWidgets('the keyboard does not open itself', (t) async {
    t.view.physicalSize = const Size(1170, 1400);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final auth = _auth();
    await t.pumpWidget(host(auth));
    await t.pumpAndSettle();
    await t.tap(find.text('School'));
    await t.pumpAndSettle();

    // One tap should open the form, not the form AND the focus AND the keyboard.
    final field = tester_focusedEditable(t);
    expect(field, isFalse, reason: 'the field should wait to be tapped');
  });
}

/// Whether anything editable currently holds focus.
bool tester_focusedEditable(WidgetTester t) {
  final focused = FocusManager.instance.primaryFocus;
  return focused != null && focused.context?.widget is EditableText;
}

/// Free text was measured and found to produce nothing usable: 19 users had
/// given a school and there were 19 distinct names, with "UCI" and "University
/// of California, Irvine" counted as separate institutions. Suggestions make it
/// likely that two students at one university type the same thing. They are
/// only ever a shortcut: whatever is in the box is what gets saved.
void suggestionTests() {
  testWidgets('suggests schools once enough has been typed', (t) async {
    t.view.physicalSize = const Size(1170, 1800);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final api = _Api(suggest: const ['University of California, Irvine']);
    final auth = _auth(api);
    await t.pumpWidget(_suggestHost(auth));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).first, 'irv');
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();

    expect(find.text('University of California, Irvine'), findsOneWidget);
  });

  testWidgets('tapping one fills the field', (t) async {
    t.view.physicalSize = const Size(1170, 1800);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final api = _Api(suggest: const ['Clemson University']);
    final auth = _auth(api);
    await t.pumpWidget(_suggestHost(auth));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).first, 'clem');
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();
    await t.tap(find.text('Clemson University'));
    await t.pumpAndSettle();

    final field = t.widget<TextField>(find.byType(TextField).first);
    expect(field.controller!.text, 'Clemson University');
  });

  testWidgets('always says a school not listed is still accepted', (t) async {
    t.view.physicalSize = const Size(1170, 1800);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final api = _Api(suggest: const ['Clemson University']);
    await t.pumpWidget(_suggestHost(_auth(api)));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'clem');
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();

    expect(find.textContaining('Not listed'), findsOneWidget);
  });

  testWidgets('saves what was typed even when nothing matched', (t) async {
    // The directory is a seed and always will be incomplete. An unknown
    // university must never block somebody from answering.
    t.view.physicalSize = const Size(1170, 1800);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    final api = _Api(suggest: const []);
    final auth = _auth(api);
    await t.pumpWidget(_suggestHost(auth));
    await t.pumpAndSettle();

    await t.enterText(
      find.byType(TextField).first,
      'Universidad Nacional de Ingeniería',
    );
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();
    expect(find.textContaining('Not listed'), findsNothing);

    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    final saved = api.posts.map((p) => p.$2.toString()).join(' ');
    expect(saved, contains('Universidad Nacional de Ingeniería'));
  });
}

Widget _suggestHost(AuthController auth) => ChangeNotifierProvider.value(
  value: auth,
  child: MaterialApp(
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: AppColors.cream,
      body: SchoolEditor(auth: auth),
    ),
  ),
);
