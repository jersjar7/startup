import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/study/study_tab.dart';

/// The shell opens on Profile, with Profile on the left and Study on the
/// right (owner's call, 2026-09-13).
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('opens on Profile; Study is the right-hand tab', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final auth = AuthController(api: ApiClient(), storage: AppStorage())
      ..user = {'firstName': 'Jerson', 'email': 'j@example.com'}
      ..status = AuthStatus.authenticated;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: auth,
        child: MaterialApp(theme: AppTheme.light, home: const HomeShell()),
      ),
    );
    await tester.pump();

    // Profile is what is showing. Study exists in the stack but is not the
    // visible child.
    expect(find.byType(ProfileTab), findsOneWidget);
    final study = find.byType(StudyTab, skipOffstage: false);
    expect(study, findsOneWidget);
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);

    // The dock is icon-only; the items carry their names as semantics.
    final profileTab = tester.getCenter(find.bySemanticsLabel('Profile'));
    final studyTab = tester.getCenter(find.bySemanticsLabel('Study'));
    expect(profileTab.dx, lessThan(studyTab.dx));

    await tester.tap(find.bySemanticsLabel('Study'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);

    // Profile fires two requests at a server that is not there; let their
    // timeouts run out before the tree is torn down.
    await tester.pump(const Duration(minutes: 2));
  });
}
