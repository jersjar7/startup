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
import 'package:mobile/features/profile/exam_outcome_card.dart';

import 'support/fonts.dart';

/// Not an assertion suite. This renders the real outcome widgets so the owner
/// can compare them against the real email side by side, which is the only
/// way to judge whether the two surfaces say the same thing.

class _Api extends ApiClient {
  @override
  Future<dynamic> post(String p, [Map<String, dynamic>? b]) async => {'ok': true};
  @override
  Future<dynamic> get(String p) async => <String, dynamic>{'email': 'a@b.com'};
}

AuthController _auth() => AuthController(api: _Api(), storage: AppStorage())
  ..user = {'email': 'a@b.com', 'firstName': 'Jerson', 'examDate': '2026-10-20'}
  ..status = AuthStatus.authenticated;

/// Their weakest chapter against its exam share, which is what the fail
/// ending names. Water Resources deliberately lowest.
const _mastery = {
  'mathematics': 62, 'statics': 71, 'dynamics': 58, 'mechanics': 64,
  'materials': 55, 'fluids': 49, 'hydraulics': 31, 'geotechnical': 52,
  'structural': 60, 'transportation': 44, 'construction': 57,
  'surveying': 66, 'economics': 73, 'ethics': 80, 'statistics': 68,
};

Widget _host(AuthController auth, Widget child, {Color ground = AppColors.fog}) =>
    ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: ground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      ),
    );

Future<void> _shot(WidgetTester t, String name) async {
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('shots/$name.png'));
}

void main() {
  setUpAll(loadBrandFonts);

  testWidgets('every outcome state the app can show', (t) async {
    t.view.physicalSize = const Size(1170, 2100);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);

    // A1 — the card as it sits on the home screen, with its X.
    var auth = _auth();
    await t.pumpWidget(_host(auth, ExamOutcomeCard(key: UniqueKey(), auth: auth, mastery: _mastery)));
    await t.pumpAndSettle();
    await _shot(t, 'a1-home-card');

    // N2 — the same question with no way out, where the notification lands.
    auth = _auth();
    await t.pumpWidget(_host(
      auth,
      ExamOutcomeCard(key: UniqueKey(), auth: auth, dismissible: false, via: 'notification', mastery: _mastery),
      ground: AppColors.butter,
    ));
    await t.pumpAndSettle();
    await _shot(t, 'n2-no-way-out');

    // N3 — the attempt step, reached by answering.
    await t.tap(find.text('I passed'));
    await t.pumpAndSettle();
    await _shot(t, 'n3-which-attempt');

    // A2 — the fail ending, which names their weakest chapter.
    auth = _auth();
    await t.pumpWidget(_host(
      auth,
      ExamOutcomeCard(key: UniqueKey(), auth: auth, mastery: _mastery, onSetExamDate: () {}),
    ));
    await t.pumpAndSettle();
    await t.tap(find.text('Not this time'));
    await t.pumpAndSettle();
    await t.tap(find.text('First'));
    await t.pumpAndSettle();
    await _shot(t, 'a2-after-a-fail');

    // A3 — the no-show ending, which diagnoses nothing.
    auth = _auth();
    await t.pumpWidget(_host(
      auth,
      ExamOutcomeCard(key: UniqueKey(), auth: auth, mastery: _mastery, onSetExamDate: () {}),
    ));
    await t.pumpAndSettle();
    await t.tap(find.text('I did not sit it'));
    await t.pumpAndSettle();
    await _shot(t, 'a3-after-a-no-show');
  });
}
