import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/games/game_catalog.dart';

/// A round names the concept it belongs to as the website does (owner,
/// 2026-10-17), so the app's lesson names have to stay the website's.
String chapterOf(File f) =>
    f.path.split('src/data/lessons/').last.split(Platform.pathSeparator).first;

void main() {
  final website = <String, String>{};
  for (final f in Directory('../src/data/lessons').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.js')) continue;
    final head = f.readAsStringSync();
    final id = RegExp(
      r"""^\s*["']?id["']?:\s*["']([^"']+)["']""",
      multiLine: true,
    ).firstMatch(head);
    final name = RegExp(
      r"""^\s*["']?name["']?:\s*(['"])(.+?)\1,""",
      multiLine: true,
    ).firstMatch(head);
    if (id != null && name != null) {
      // The source is JavaScript, so undo its two escapes.
      website['${chapterOf(f)}/${id.group(1)!}'] = name
          .group(2)!
          .replaceAll(r"\'", "'")
          .replaceAll(r'\u2019', '\u2019');
    }
  }

  test('every lesson on the phone has the website\'s name', () {
    expect(website, isNotEmpty);
    for (final chapter in chapterMaps.values) {
      for (final lesson in chapter.lessons) {
        expect(
          lesson.name,
          website['${chapter.id}/${lesson.id}'],
          reason: '${chapter.id}/${lesson.id}',
        );
      }
    }
  });

  test('every round and every concept sheet knows its lesson', () {
    for (final chapter in chapterMaps.values) {
      for (final lesson in chapter.lessons) {
        for (final game in lesson.games) {
          expect(lessonForGame(game.id), same(lesson));
          if (game.brief != null) {
            expect(lessonForBrief(game.brief!), isNotNull, reason: game.id);
          }
        }
      }
    }
  });
}
