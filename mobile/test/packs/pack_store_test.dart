import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/router.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/games/game_progress.dart';
import 'package:mobile/features/games/per_million_what_game.dart';
import 'package:mobile/features/games/perpendicular_flip_game.dart';
import 'package:mobile/features/packs/games/pick_one_game.dart';
import 'package:mobile/features/packs/pack_store.dart';
import 'package:mobile/features/packs/update_needed_screen.dart';

import '../support/fonts.dart';

/// Phase 2 of the move to content packs: the app holds a pack, updates it
/// quietly, and plays from it only when switched on (ADR 0030; migration
/// plan, rules 3 to 5).

final _published = Directory('../service/packs/fe-civil');

Map<String, Object?> _manifest() =>
    jsonDecode(File('${_published.path}/manifest.json').readAsStringSync())
        as Map<String, Object?>;

String _publishedText() => File(
  '${_published.path}/${(_manifest()['latest']! as Map)['file']}',
).readAsStringSync();

/// The published pack, as a later version: same games, new number.
String _asVersion(int version, {String? title}) {
  final json = jsonDecode(_publishedText()) as Map<String, Object?>;
  json['version'] = version;
  if (title != null) {
    ((json['games']! as Map)['per-million-what']! as Map)['title'] = title;
  }
  return jsonEncode(json);
}

String _sha(String text) => sha256.convert(utf8.encode(text)).toString();

/// A server with one exam on it. [online] false is a phone with no signal.
class _Server extends ApiClient {
  _Server(this.text, {this.format = 1, String? sha})
    : version = (jsonDecode(text) as Map)['version'] as int,
      sha = sha ?? _sha(text);

  final String text;
  final int version;
  final int format;
  final String sha;
  bool online = true;
  final asked = <String>[];
  final posted = <String, List<Map<String, dynamic>?>>{};

  String get file => 'fe-civil-v$version-${sha.substring(0, 12)}.json';

  void _check(String path) {
    asked.add(path);
    if (!online) {
      throw ApiException("Couldn't reach the server.", isNetwork: true);
    }
  }

  @override
  Future<dynamic> get(String path) async {
    _check(path);
    return {
      'exam': 'fe-civil',
      'format': format,
      'version': version,
      'file': file,
      'sha256': sha,
    };
  }

  @override
  Future<String> getText(String path) async {
    _check(path);
    return text;
  }

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    (posted[path] ??= []).add(body);
    return <String, dynamic>{'ok': true};
  }
}

void main() {
  late Directory home;
  late PackStore store;

  setUp(() {
    home = Directory.systemTemp.createTempSync('packs-');
    store = PackStore(folder: () async => home)..appVersion = '1.2.0';
  });
  tearDown(() => home.deleteSync(recursive: true));

  group('the pack inside the app', () {
    test('is a version the server published, byte for byte', () {
      final bundled = File('assets/packs/fe-civil.json').readAsStringSync();
      final versions = [
        for (final v in _manifest()['versions']! as List) (v as Map)['sha256'],
      ];
      expect(versions, contains(_sha(bundled)));
    });

    testWidgets('loads with no network at all', (tester) async {
      await tester.runAsync(store.load);
      expect(store.pack!.exam, 'fe-civil');
      expect(store.game('per-million-what'), isNotNull);
      expect(store.pack!.label, startsWith('fe-civil@'));
    });
  });

  group('updating', () {
    testWidgets('a newer version downloads, is checked, and is used from '
        'then on, even after a restart', (tester) async {
      await tester.runAsync(store.load);
      final was = store.pack!.version;
      final server = _Server(_asVersion(was + 1, title: 'Per Million What 2'));

      expect(await tester.runAsync(() => store.refresh(server)), isTrue);
      expect(store.pack!.version, was + 1);
      expect(store.game('per-million-what')!.title, 'Per Million What 2');

      final again = PackStore(folder: () async => home);
      await tester.runAsync(again.load);
      expect(again.pack!.version, was + 1);
    });

    testWidgets('nothing is downloaded when the version is not newer', (
      tester,
    ) async {
      await tester.runAsync(store.load);
      final server = _Server(_publishedText());
      expect(await tester.runAsync(() => store.refresh(server)), isFalse);
      expect(server.asked, ['/packs/fe-civil']);
    });

    testWidgets('a file that does not match its hash is thrown away', (
      tester,
    ) async {
      await tester.runAsync(store.load);
      final was = store.pack!.version;
      final server = _Server(_asVersion(was + 1), sha: 'f' * 64);
      expect(await tester.runAsync(() => store.refresh(server)), isFalse);
      expect(store.pack!.version, was);
    });

    testWidgets('a layout this app cannot read is left alone', (tester) async {
      await tester.runAsync(store.load);
      final was = store.pack!.version;
      final server = _Server(_asVersion(was + 1), format: 2);
      expect(await tester.runAsync(() => store.refresh(server)), isFalse);
      expect(server.asked, ['/packs/fe-civil']);
      expect(store.pack!.version, was);
    });

    testWidgets('offline, nothing changes and nothing breaks', (tester) async {
      await tester.runAsync(store.load);
      final server = _Server(_asVersion(99))..online = false;
      expect(await tester.runAsync(() => store.refresh(server)), isFalse);
      expect(store.game('per-million-what'), isNotNull);
    });

    testWidgets('a download damaged on disk is ignored at the next start', (
      tester,
    ) async {
      await tester.runAsync(store.load);
      final was = store.pack!.version;
      await tester.runAsync(() => store.refresh(_Server(_asVersion(was + 1))));
      final dir = Directory('${home.path}/packs/fe-civil');
      final saved = dir.listSync().whereType<File>().firstWhere(
        (f) => f.path.contains('-v${was + 1}-'),
      );
      saved.writeAsStringSync(_asVersion(was + 1, title: 'Tampered'));

      final again = PackStore(folder: () async => home);
      await tester.runAsync(again.load);
      expect(again.pack!.version, was);
    });

    testWidgets('a round in progress keeps the version it opened with', (
      tester,
    ) async {
      await tester.runAsync(store.load);
      final playing = store.game('per-million-what')!;
      await tester.runAsync(
        () => store.refresh(
          _Server(_asVersion(store.pack!.version + 1, title: 'Renamed')),
        ),
      );
      expect(playing.title, 'Per Million What');
      expect(store.game('per-million-what')!.title, 'Renamed');
    });
  });

  group('which screen a student gets', () {
    testWidgets('switched off, every student gets the built-in game', (
      tester,
    ) async {
      await tester.runAsync(store.load);
      expect(packsOn, isFalse);
      expect(
        playScreenFor('per-million-what', store: store),
        isA<PerMillionWhatGame>(),
      );
    });

    testWidgets('switched on, the pack plays it', (tester) async {
      await tester.runAsync(store.load);
      expect(
        playScreenFor('per-million-what', store: store, on: true),
        isA<PackPickOneGame>(),
      );
    });

    testWidgets('switched on, an app too old for the lesson asks for an '
        'update, and only for that lesson', (tester) async {
      await tester.runAsync(store.load);
      store.appVersion = '1.1.0';
      expect(
        playScreenFor('per-million-what', store: store, on: true),
        isA<UpdateNeededScreen>(),
      );
      // A game the pack does not hold still plays as it always has. Every
      // game is in the pack now, so a later version leaves one out.
      final json = jsonDecode(_asVersion(store.pack!.version + 1)) as Map;
      (json['games']! as Map).remove('perpendicular-flip');
      for (final lesson in (json['lessons']! as Map).values) {
        ((lesson as Map)['games']! as List).remove('perpendicular-flip');
      }
      await tester.runAsync(() => store.refresh(_Server(jsonEncode(json))));
      expect(store.game('perpendicular-flip'), isNull);
      expect(
        playScreenFor('perpendicular-flip', store: store, on: true),
        isA<PerpendicularFlipGame>(),
      );
    });
  });

  group('the update screen', () {
    setUpAll(loadBrandFonts);

    // The smallest and largest phones, at normal and the largest text size,
    // day and night: nothing runs off the screen and the button is reachable.
    for (final size in const [Size(320, 568), Size(390, 844), Size(430, 932)]) {
      for (final scale in const [1.0, 2.0]) {
        for (final dark in const [false, true]) {
          testWidgets('fits ${size.width.toInt()} wide at text x$scale'
              '${dark ? ', night' : ''}', (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            var opened = 0;
            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                ),
                child: MaterialApp(
                  theme: dark ? AppTheme.dark : AppTheme.light,
                  debugShowCheckedModeBanner: false,
                  home: UpdateNeededScreen(openStore: () async => opened++),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            final button = find.text('Update the app');
            await tester.ensureVisible(button);
            await tester.pumpAndSettle();
            await tester.tap(button);
            await tester.pumpAndSettle();
            expect(opened, 1);
          });
        }
      }
    }

    testWidgets('says what to do in plain words and opens the store', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: UpdateNeededScreen(openStore: () async => opened++),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../goldens/packs/update-needed.png'),
      );
      // Rule 5: no version numbers, no "pack".
      final words = tester
          .widgetList<RichText>(find.byType(RichText))
          .map((t) => t.text.toPlainText())
          .join(' ');
      expect(words.toLowerCase(), isNot(contains('pack')));
      expect(words, isNot(matches(RegExp(r'\d+\.\d+'))));
      await tester.tap(find.text('Update the app'));
      expect(opened, 1);
    });
  });

  group('reports from a pack round', () {
    setUpAll(loadBrandFonts);

    testWidgets('name the game and the pack version the student saw', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'book_dot_seen': true});
      FlutterSecureStorage.setMockInitialValues({});
      GameProgress.instance.reset('per-million-what');
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(store.load);
      final server = _Server(_publishedText());
      final auth = AuthController(api: server, storage: AppStorage())
        ..status = AuthStatus.authenticated;
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthController>.value(
          value: auth,
          child: MaterialApp.router(
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) =>
                      playScreenFor('per-million-what', store: store, on: true),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();

      final flag = find.byTooltip('Something unclear?');
      await tester.ensureVisible(flag);
      await tester.pumpAndSettle();
      await tester.tap(flag);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Which million?');
      await tester.tap(find.text('Send it'));
      await tester.pumpAndSettle();

      final sent = server.posted['/feedback/game']!.single!;
      expect(sent['gameId'], 'per-million-what');
      expect(sent['gameName'], 'Per Million What');
      expect(sent['pack'], store.pack!.label);
    });
  });
}
