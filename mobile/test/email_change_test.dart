import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/profile/account_extras.dart';

import 'support/fonts.dart';

/// Until 2026-10-07 an email address could never be changed, and "resend
/// verification" mailed the SAME address, so anybody who mistyped theirs at
/// sign-up was stuck for good: able to study, because verification gates
/// nothing, but never receiving anything we send. One real account has been in
/// that state since 2 October on a domain with no mail server at all.

class _Api extends ApiClient {
  _Api({this.failWith});

  /// The server's refusal, when there is one.
  final String? failWith;
  final posts = <(String, Map<String, dynamic>?)>[];

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    posts.add((path, body));
    if (failWith != null) throw ApiException(failWith!, statusCode: 400);
    return <String, dynamic>{'ok': true};
  }

  @override
  Future<dynamic> get(String path) async =>
      <String, dynamic>{'email': 'fixed@school.edu', 'emailVerified': false};
}

AuthController _auth(_Api api, {bool verified = false}) =>
    AuthController(api: api, storage: AppStorage())
      ..user = {'email': 'enail@sc.edu', 'emailVerified': verified}
      ..status = AuthStatus.authenticated;

Widget _host(AuthController auth, Widget child) => ChangeNotifierProvider.value(
  value: auth,
  child: MaterialApp(
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    home: Scaffold(backgroundColor: AppColors.cream, body: child),
  ),
);

Future<void> _fill(WidgetTester t, String email, String password) async {
  final fields = find.byType(TextField);
  await t.enterText(fields.at(0), email);
  await t.enterText(fields.at(1), password);
  await t.tap(find.text('Change email'));
  await t.pumpAndSettle();
}

void main() {
  setUpAll(loadBrandFonts);

  group('the row', () {
    testWidgets('says when the address was never confirmed', (t) async {
      // The symptom of the bug: everything we send is being lost and nothing
      // else on the phone says so.
      final auth = _auth(_Api());
      await t.pumpWidget(_host(auth, EmailRow(auth: auth)));
      await t.pumpAndSettle();
      expect(find.text('enail@sc.edu'), findsOneWidget);
      expect(find.text('Not confirmed'), findsOneWidget);
    });

    testWidgets('says nothing extra once it is confirmed', (t) async {
      final auth = _auth(_Api(), verified: true);
      await t.pumpWidget(_host(auth, EmailRow(auth: auth)));
      await t.pumpAndSettle();
      expect(find.text('Not confirmed'), findsNothing);
    });
  });

  group('changing it', () {
    testWidgets('sends the address and the password together', (t) async {
      // Without the password, a few minutes with an unlocked phone is enough
      // to move somebody's account to another address.
      final api = _Api();
      final auth = _auth(api);
      await t.pumpWidget(_host(auth, EmailEditor(auth: auth)));
      await t.pumpAndSettle();
      await _fill(t, 'fixed@school.edu', 'hunter2');

      final call = api.posts.firstWhere((p) => p.$1 == '/auth/change-email');
      expect(call.$2!['email'], 'fixed@school.edu');
      expect(call.$2!['password'], 'hunter2');
    });

    testWidgets('trims an address people paste with a space', (t) async {
      final api = _Api();
      final auth = _auth(api);
      await t.pumpWidget(_host(auth, EmailEditor(auth: auth)));
      await t.pumpAndSettle();
      await _fill(t, '  fixed@school.edu ', 'hunter2');
      final call = api.posts.firstWhere((p) => p.$1 == '/auth/change-email');
      expect(call.$2!['email'], 'fixed@school.edu');
    });

    testWidgets('leaves the page when it worked', (t) async {
      var done = false;
      final auth = _auth(_Api());
      await t.pumpWidget(
        _host(auth, EmailEditor(auth: auth, onDone: () => done = true)),
      );
      await t.pumpAndSettle();
      await _fill(t, 'fixed@school.edu', 'hunter2');
      expect(done, isTrue);
    });

    testWidgets('shows the server\'s own words when it refuses', (t) async {
      // The server already says what to do rather than what went wrong, so it
      // is shown as it is rather than replaced with something vaguer.
      final auth = _auth(_Api(failWith: 'Password is incorrect.'));
      await t.pumpWidget(_host(auth, EmailEditor(auth: auth)));
      await t.pumpAndSettle();
      await _fill(t, 'fixed@school.edu', 'wrong');
      expect(find.text('Password is incorrect.'), findsOneWidget);
    });

    testWidgets('stays put and keeps what was typed when it refuses', (t) async {
      // A wrong password must not cost them the address they just typed.
      var done = false;
      final auth = _auth(_Api(failWith: 'Password is incorrect.'));
      await t.pumpWidget(
        _host(auth, EmailEditor(auth: auth, onDone: () => done = true)),
      );
      await t.pumpAndSettle();
      await _fill(t, 'fixed@school.edu', 'wrong');
      expect(done, isFalse);
      final field = t.widget<TextField>(find.byType(TextField).at(0));
      expect(field.controller!.text, 'fixed@school.edu');
    });

    testWidgets('says the new address has to be confirmed', (t) async {
      final auth = _auth(_Api());
      await t.pumpWidget(_host(auth, EmailEditor(auth: auth)));
      await t.pumpAndSettle();
      expect(find.textContaining('send a link to the new'), findsOneWidget);
    });

    testWidgets('offers a way back when it is a page inside the sheet', (t) async {
      final auth = _auth(_Api());
      await t.pumpWidget(_host(auth, EmailEditor(auth: auth, onDone: () {})));
      await t.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
    });
  });
}
