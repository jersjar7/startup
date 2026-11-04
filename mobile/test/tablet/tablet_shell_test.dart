import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/home/home_shell.dart';
import 'package:mobile/features/shared/widgets/kit.dart';
import 'package:mobile/features/study/study_tab.dart' show appClock;

import '../support/fonts.dart';
import 'tablet_support.dart';

/// On a tablet window the dock becomes a rail down the left edge; under 600
/// (a phone, or an iPad split beside the Handbook) it is the phone's dock,
/// exactly (ADR 0039).
Widget _app({bool guest = false}) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..onboardingSeen = true;
  if (guest) {
    auth
      ..guest = true
      ..status = AuthStatus.unauthenticated;
  } else {
    auth
      ..user = {
        'firstName': 'Jerson',
        'email': 'j@x.edu',
        'examDate': '2027-01-15',
      }
      ..status = AuthStatus.authenticated;
  }
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    ),
  );
}

Future<void> _drain(WidgetTester tester) =>
    tester.pump(const Duration(minutes: 2));

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    PackageInfo.setMockInitialValues(
      appName: 'FE for Raccoons',
      packageName: 'com.fe4raccoons.mobile',
      version: '1.0.0',
      buildNumber: '1100',
      buildSignature: '',
    );
    appClock = () => DateTime(2026, 11, 3, 10);
  });

  for (final (name, size) in [
    ('landscape', landscape),
    ('portrait', portrait),
  ]) {
    testWidgets('a tablet window has the rail, top to bottom ($name)', (
      tester,
    ) async {
      setWindow(tester, size);
      await tester.pumpWidget(_app());
      await settle(tester);
      expect(find.byType(SideRail), findsOneWidget);
      expect(find.byType(BottomDock), findsNothing);
      final rail = tester.getRect(find.byType(SideRail));
      expect(rail.left, 0);
      expect(rail.width, 104);
      expect(rail.height, size.height);
      final p = tester.getCenter(find.bySemanticsLabel('Profile'));
      final s = tester.getCenter(find.bySemanticsLabel('Study'));
      final d = tester.getCenter(find.bySemanticsLabel(RegExp(r'^Daily')));
      expect(p.dy, lessThan(s.dy));
      expect(s.dy, lessThan(d.dy));
      expect(p.dx, s.dx);
      HomeShell.select(HomeTab.study);
      await settle(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/tablet/shell-study-$name.png'),
      );
      await _drain(tester);
    });
  }

  testWidgets('half an iPad beside the Handbook is the phone: the dock', (
    tester,
  ) async {
    setWindow(tester, splitHalf);
    await tester.pumpWidget(_app());
    await settle(tester);
    expect(find.byType(SideRail), findsNothing);
    expect(find.byType(BottomDock), findsOneWidget);
    HomeShell.select(HomeTab.study);
    await settle(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../goldens/tablet/shell-study-split.png'),
    );
    await _drain(tester);
  });

  testWidgets('the tab survives a rotation and a split', (tester) async {
    setWindow(tester, landscape);
    await tester.pumpWidget(_app());
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Daily')));
    await tester.pump(const Duration(milliseconds: 300));
    for (final size in [portrait, splitHalf, phone, landscape]) {
      tester.view.physicalSize = size;
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack)).index,
        HomeTab.daily.index,
        reason: 'at $size',
      );
    }
    await _drain(tester);
  });

  testWidgets('a guest gets the rail too, with its grey dots', (tester) async {
    setWindow(tester, landscape);
    await tester.pumpWidget(_app(guest: true));
    await settle(tester);
    expect(find.byType(SideRail), findsOneWidget);
    expect(find.byKey(const ValueKey('dock-dot-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('dock-dot-2')), findsOneWidget);
    await _drain(tester);
  });

  // The rail beside a pushed page listens to the tab in front. The shell
  // once wrote that tab while it was building, so picking a tab on that rail
  // rebuilt the page's rail in the middle of the shell's build (a debug
  // assertion, "setState() or markNeedsBuild() called during build").
  testWidgets('a tab picked on the rail beside a page builds cleanly', (
    tester,
  ) async {
    setWindow(tester, landscape);
    await tester.pumpWidget(_app());
    await settle(tester);
    final shell = tester.element(find.byType(HomeShell));
    Navigator.of(shell).push(
      MaterialPageRoute<void>(
        builder: (_) => const BesideRail(child: Scaffold(body: Text('page'))),
      ),
    );
    await settle(tester);
    expect(find.text('page'), findsOneWidget);
    await tester.tap(find.text('Study').last);
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('page'), findsNothing);
    expect(HomeShell.current.value, HomeTab.study.index);
    await _drain(tester);
  });
}
