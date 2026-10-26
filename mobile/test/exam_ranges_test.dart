import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/games/game_catalog.dart';
import 'package:mobile/features/study/chapter_bands.dart';
import 'package:mobile/features/study/study_tab.dart';

// The question counts come from the NCEES FE Civil specification in use
// since July 2020 (research/civil/fe-civil-cbt-spec.pdf). It has 14 areas:
// Mathematics and Statistics are one area worth 8 to 12 together.
void main() {
  test('every chapter carries the current spec range', () {
    const spec = {
      'mathematics': '8 to 12',
      'statistics': '8 to 12',
      'ethics': '4 to 6',
      'economics': '5 to 8',
      'statics': '8 to 12',
      'dynamics': '4 to 6',
      'mechanics-materials': '7 to 11',
      'materials': '5 to 8',
      'fluid-mechanics': '6 to 9',
      'surveying': '6 to 9',
      'water-resources': '10 to 15',
      'structural': '10 to 15',
      'geotechnical': '10 to 15',
      'transportation': '9 to 14',
      'construction': '8 to 12',
    };
    for (final e in spec.entries) {
      expect(
        chapterMaps[e.key]!.examLine,
        startsWith('${e.value} questions'),
        reason: e.key,
      );
    }
  });

  test('the shared area says so, briefly, on the Study tile', () {
    expect(examWeight(chapterMaps['mathematics']!), '8 to 12 with Stats');
    expect(examWeight(chapterMaps['statistics']!), '8 to 12 with Math');
    expect(examWeight(chapterMaps['structural']!), '10 to 15 on the exam');
  });

  test('a band counts the shared area once', () {
    // Mathematics and Statistics 8-12, Ethics 4-6, Economics 5-8.
    expect(chapterBands.first.examRange, '17-26 q');
  });
}
