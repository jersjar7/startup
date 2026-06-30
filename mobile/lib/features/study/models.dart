// Study content models, parsed from the /content API (which serializes the
// website's bundled content). Mirrors the Chapter -> Subtopic -> Lesson spine.

class Chapter {
  Chapter({
    required this.id,
    required this.num,
    required this.name,
    required this.qs,
    required this.accent,
    required this.context,
    required this.subtopics,
  });

  final String id;
  final int num;
  final String name;
  final String qs; // exam-question range, e.g. "7–11"
  final String accent;
  final String context;
  final List<Subtopic> subtopics;

  int get lessonCount => subtopics.fold(0, (n, s) => n + s.lessons.length);

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
        id: j['id'] as String,
        num: j['num'] as int,
        name: j['name'] as String,
        qs: (j['qs'] ?? '') as String,
        accent: (j['accent'] ?? 'ember') as String,
        context: (j['context'] ?? '') as String,
        subtopics: (j['subtopics'] as List? ?? [])
            .map((e) => Subtopic.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Subtopic {
  Subtopic({required this.id, required this.name, required this.application, required this.lessons});

  final String id;
  final String name;
  final String application;
  final List<LessonRef> lessons;

  factory Subtopic.fromJson(Map<String, dynamic> j) => Subtopic(
        id: j['id'] as String,
        name: j['name'] as String,
        application: (j['application'] ?? '') as String,
        lessons: (j['lessons'] as List? ?? [])
            .map((e) => LessonRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A lesson as it appears in the nav (name + one-liner). The full lesson
/// (content blocks + problems) is fetched separately when opened.
class LessonRef {
  LessonRef({required this.id, required this.name, required this.application});

  final String id;
  final String name;
  final String application;

  factory LessonRef.fromJson(Map<String, dynamic> j) => LessonRef(
        id: j['id'] as String,
        name: j['name'] as String,
        application: (j['application'] ?? '') as String,
      );
}
