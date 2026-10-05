import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/onboarding/welcome_screen.dart';
import 'package:mobile/features/games/chapter_map_screen.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/profile/exam_date_screen.dart';
import 'package:mobile/features/profile/mastery_screen.dart';
import 'package:mobile/features/profile/profile_tab.dart';
import 'package:mobile/features/profile/study_days_screen.dart';
import 'package:mobile/features/splash/splash_screen.dart';
import 'package:mobile/features/study/content_repository.dart';
import 'package:mobile/features/study/study_tab.dart';

import 'support/fonts.dart';

/// Every screen, on every phone the app will meet.
///
/// The app is built at 390 by 844 and the goldens are all taken there, so a
/// screen that only works at that one size would never be caught. These are
/// the logical sizes of the phones in use: the smallest iPhone Apple still
/// supports through the largest Pro Max.
const _phones = <String, Size>{
  'SE 1st gen': Size(320, 568),
  'SE 2nd and 3rd': Size(375, 667),
  'iPhone 13 and 14': Size(390, 844),
  'iPhone 15 and 16': Size(393, 852),
  'iPhone 16 Pro': Size(402, 874),
  'Pro Max': Size(430, 932),
};

Widget _wrap(Widget home) {
  final auth = AuthController(api: ApiClient(), storage: AppStorage())
    ..user = {
      'firstName': 'Jerson',
      'email': 'j@x.edu',
      'currentStreak': 6,
      'examDate': '2026-11-18',
    }
    ..status = AuthStatus.authenticated
    // Already toured: these tests are about the screen, not the tour, which
    // otherwise opens over it on first launch.
    ..onboardingSeen = true;
  return ChangeNotifierProvider<AuthController>.value(
    value: auth,
    child: MaterialApp(
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: AppColors.fog, body: home),
    ),
  );
}

const _sample = <String, ChapterMastery>{
  'mathematics': ChapterMastery(total: 62, desk: 62),
  'statics': ChapterMastery(total: 48, desk: 48),
  'ethics': ChapterMastery(total: 84, desk: 84),
};

void main() {
  setUpAll(loadBrandFonts);
  setUp(() => appClock = () => DateTime(2026, 10, 2, 10));
  tearDown(() => appClock = DateTime.now);

  final screens = <String, Widget Function()>{
    'splash': () => const SplashScreen(),
    'welcome': () => const WelcomeScreen(),
    'profile': () => const ProfileTab(),
    'study': () => const StudyTab(),
    'chapter map': () =>
        ChapterMapScreen(chapter: chapterMaps['mechanics-materials']!),
    'mastery': () => const MasteryScreen(mastery: _sample),
    'exam date': () => const ExamDateScreen(initial: '2026-11-18'),
    'study days': () => const StudyDaysScreen(count: 11, days: ['2026-10-01']),
  };

  for (final phone in _phones.entries) {
    testWidgets('every screen lays out on a ${phone.key}', (tester) async {
      tester.view.physicalSize = phone.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final broken = <String>[];
      for (final screen in screens.entries) {
        await tester.pumpWidget(_wrap(screen.value()));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)),
        );
        await tester.pump(const Duration(milliseconds: 400));
        final boom = tester.takeException();
        if (boom != null) {
          broken.add('${screen.key}: $boom'.split('\n').first);
        }
      }
      expect(broken, isEmpty, reason: broken.join('\n'));
    });
  }
}
