import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/profile/about_story.dart';
import 'package:mobile/features/profile/account_extras.dart';
import 'package:mobile/features/profile/contact_page.dart';

import 'support/fonts.dart';

/// The tester's point 12, in the app: Contact us and the About story, both
/// inside the account sheet.

class _Api extends ApiClient {
  _Api({this.refuse});

  final String? refuse;
  final posts = <(String, Map<String, dynamic>?)>[];

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    posts.add((path, body));
    if (refuse != null) throw ApiException(refuse!, statusCode: 429);
    return <String, dynamic>{'ok': true};
  }
}

AuthController _auth(_Api api) =>
    AuthController(api: api, storage: AppStorage())
      ..user = {'email': 'sam@byu.edu', 'emailVerified': true}
      ..status = AuthStatus.authenticated;

Widget _host(AuthController auth, {Widget? account}) =>
    ChangeNotifierProvider.value(
      value: auth,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: AppColors.cream,
          body: SingleChildScrollView(
            child: AccountSheetHost(
              auth: auth,
              account:
                  account ??
                  Builder(
                    builder: (context) => Column(
                      children: [
                        TextButton(
                          onPressed: () =>
                              AccountSheetHost.of(context)?.showContact(),
                          child: const Text('open contact'),
                        ),
                        TextButton(
                          onPressed: () =>
                              AccountSheetHost.of(context)?.showAbout(),
                          child: const Text('open about'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );

void main() {
  setUpAll(() async {
    await loadBrandFonts();
    PackageInfo.setMockInitialValues(
      appName: 'FE for Raccoons',
      packageName: 'com.fe4raccoons.mobile',
      version: '1.0.0',
      buildNumber: '1144',
      buildSignature: '',
    );
  });

  void tall(WidgetTester t) {
    t.view.physicalSize = const Size(400, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  testWidgets('a message goes to the server and is thanked', (t) async {
    tall(t);
    final api = _Api();
    await t.pumpWidget(_host(_auth(api)));
    await t.tap(find.text('open contact'));
    await t.pumpAndSettle();
    expect(find.byType(ContactPage), findsOneWidget);
    expect(find.textContaining('writes back to sam@byu.edu'), findsOneWidget);

    await t.tap(find.text('Send it'));
    await t.pumpAndSettle();
    expect(find.text('Write a message first.'), findsOneWidget);
    expect(api.posts, isEmpty);

    await t.enterText(find.byType(EditableText), 'Could you add a dark mode?');
    await t.tap(find.text('Send it'));
    await t.pumpAndSettle();
    expect(api.posts.single.$1, '/feedback/contact');
    expect(api.posts.single.$2, containsPair('source', 'app'));
    expect(
      api.posts.single.$2,
      containsPair('message', 'Could you add a dark mode?'),
    );
    expect(find.text('Sent. Thank you.'), findsOneWidget);

    await t.tap(find.text('Back to the account'));
    await t.pumpAndSettle();
    expect(find.text('open contact'), findsOneWidget);
  });

  testWidgets('the server\'s reason shows when it refuses', (t) async {
    tall(t);
    final api = _Api(refuse: 'That is plenty for one hour. Thank you.');
    await t.pumpWidget(_host(_auth(api)));
    await t.tap(find.text('open contact'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(EditableText), 'again');
    await t.tap(find.text('Send it'));
    await t.pumpAndSettle();
    expect(find.text('That is plenty for one hour. Thank you.'), findsOneWidget);
  });

  testWidgets('About tells the story, and reaches Contact us', (t) async {
    tall(t);
    await t.pumpWidget(_host(_auth(_Api())));
    await t.tap(find.text('open about'));
    await t.pumpAndSettle();
    expect(find.text('Why this exists'), findsOneWidget);
    for (final (heading, _) in aboutStory) {
      if (heading != null) expect(find.text(heading), findsOneWidget);
    }
    final contact = find.text('Contact us');
    await t.scrollUntilVisible(contact, 300, scrollable: find.byType(Scrollable).last);
    await t.tap(contact);
    await t.pumpAndSettle();
    expect(find.byType(ContactPage), findsOneWidget);
  });

  test('the story matches the website\'s About page', () {
    // Both carry the owner's words; one changed alone would tell two stories.
    final web = File('../src/about/About.jsx')
        .readAsStringSync()
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
    for (final (heading, paragraphs) in aboutStory) {
      if (heading != null) expect(web, contains(heading));
      for (final p in paragraphs) {
        expect(web, contains(p.replaceAll(RegExp(r'\s+'), ' ')), reason: p);
      }
    }
  });
}
