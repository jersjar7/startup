import '../games/game_catalog.dart';
import '../study/content_repository.dart';

/// The one number per chapter, for the weighting and the focus list.
Map<String, int> totalsOf(Map<String, ChapterMastery> m) => {
  for (final e in m.entries) e.key: e.value.total,
};

/// How many of the FE Civil exam's 110 questions each chapter gets, the same
/// figures the website weights by (`src/data/exam-bank/index.js`,
/// EXAM_DISTRIBUTION). One source for one number: the phone's mastery row and
/// the website's dashboard must agree.
const examWeights = <String, int>{
  'mathematics': 13,
  'statistics': 4,
  'ethics': 4,
  'economics': 4,
  'statics': 8,
  'dynamics': 4,
  'mechanics-materials': 8,
  'materials': 4,
  'fluid-mechanics': 4,
  'surveying': 4,
  'water-resources': 14,
  'structural': 13,
  'geotechnical': 11,
  'transportation': 10,
  'construction': 5,
};

/// Chapter mastery weighted by exam questions, rounded. Chapters missing from
/// [mastery] count as zero, as they do on the website.
int weightedMastery(Map<String, int> mastery) {
  var total = 0, weighted = 0;
  for (final entry in examWeights.entries) {
    total += entry.value;
    weighted += (mastery[entry.key] ?? 0) * entry.value;
  }
  return total == 0 ? 0 : (weighted / total).round();
}

/// The stage word for a chapter, the website's thresholds.
String stageName(int pct) {
  if (pct >= 80) return 'Mastered';
  if (pct >= 50) return 'Familiar';
  if (pct >= 10) return 'Building';
  return 'New';
}

/// The chapters where effort moves the weighted number most: low mastery
/// times high weight, strongest first, mastered ones left out.
List<String> focusChapters(Map<String, int> mastery, {int limit = 3}) {
  final rows = [
    for (final id in chapterMaps.keys)
      if ((mastery[id] ?? 0) < 90)
        (id, (100 - (mastery[id] ?? 0)) * (examWeights[id] ?? 0)),
  ]..sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final r in rows.take(limit)) r.$1];
}

/// "11 to 17 questions on the real exam" -> "11–17 Q".
String weightChip(ChapterMap chapter) {
  final m = RegExp(r'^(\d+) to (\d+)').firstMatch(chapter.examLine);
  return m == null ? '' : '${m.group(1)}–${m.group(2)} Q';
}
