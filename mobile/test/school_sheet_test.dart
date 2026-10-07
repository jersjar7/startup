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
  @override
  Future<dynamic> post(String p, [Map<String, dynamic>? b]) async => {'ok': true};
  @override
  Future<dynamic> put(String p, [Map<String, dynamic>? b]) async => {'ok': true};
  @override
  Future<dynamic> get(String p) async => <String, dynamic>{'email': 'a@b.com'};
}

AuthController _auth() => AuthController(api: _Api(), storage: AppStorage())
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
