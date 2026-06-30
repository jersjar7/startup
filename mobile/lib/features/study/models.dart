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

/// The full lesson: teaching blocks + practice problems.
class Lesson {
  Lesson({
    required this.id,
    required this.name,
    required this.application,
    required this.content,
    required this.problems,
  });

  final String id;
  final String name;
  final String application;
  final List<ContentBlock> content;
  final List<Problem> problems;

  /// The teaching section headings — the "topics" shown on the lesson hub.
  List<String> get topics =>
      content.where((b) => b.type == 'heading').map((b) => b.body).toList();

  /// Blocks before the first heading — the lesson intro.
  List<ContentBlock> get intro =>
      content.takeWhile((b) => b.type != 'heading').toList();

  /// Each topic with its blocks (heading + everything until the next heading).
  List<({String heading, List<ContentBlock> blocks})> sections() {
    final out = <({String heading, List<ContentBlock> blocks})>[];
    for (var i = 0; i < content.length; i++) {
      if (content[i].type == 'heading') {
        final blocks = <ContentBlock>[content[i]];
        var j = i + 1;
        while (j < content.length && content[j].type != 'heading') {
          blocks.add(content[j]);
          j++;
        }
        out.add((heading: content[i].body, blocks: blocks));
      }
    }
    return out;
  }

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
        id: j['id'] as String,
        name: j['name'] as String,
        application: (j['application'] ?? '') as String,
        content: (j['content'] as List? ?? [])
            .map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
        problems: (j['problems'] as List? ?? [])
            .map((e) => Problem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One teaching block: text | heading | formula | callout | diagram.
class ContentBlock {
  ContentBlock({required this.type, this.body = '', this.latex, this.label, this.variant});

  final String type;
  final String body;
  final String? latex;
  final String? label;
  final String? variant; // callout: warning | tip | exam

  factory ContentBlock.fromJson(Map<String, dynamic> j) => ContentBlock(
        type: j['type'] as String,
        body: (j['body'] ?? '') as String,
        latex: j['latex'] as String?,
        label: j['label'] as String?,
        variant: j['variant'] as String?,
      );
}

class Choice {
  Choice({required this.id, required this.text});
  final String id;
  final String text;
  factory Choice.fromJson(Map<String, dynamic> j) =>
      Choice(id: j['id'] as String, text: (j['text'] ?? '') as String);
}

class Step {
  Step({required this.text, this.latex});
  final String text;
  final String? latex;
  factory Step.fromJson(Map<String, dynamic> j) =>
      Step(text: (j['text'] ?? '') as String, latex: j['latex'] as String?);
}

class Figure {
  Figure({required this.component, required this.figureId});
  final String component;
  final String figureId;
  static Figure? fromJson(Map<String, dynamic>? j) {
    if (j == null || j['figureId'] == null) return null;
    return Figure(component: (j['component'] ?? '') as String, figureId: j['figureId'] as String);
  }
}

class Problem {
  Problem({
    required this.id,
    required this.statement,
    required this.choices,
    required this.correctAnswerId,
    required this.difficulty,
    required this.eli5,
    required this.steps,
    this.handbookPage,
    this.figure,
  });

  final String id;
  final String statement;
  final List<Choice> choices;
  final String correctAnswerId;
  final String difficulty;
  final String eli5;
  final List<Step> steps;
  final String? handbookPage;
  final Figure? figure;

  factory Problem.fromJson(Map<String, dynamic> j) => Problem(
        id: j['id'] as String,
        statement: (j['statement'] ?? '') as String,
        choices: (j['choices'] as List? ?? [])
            .map((e) => Choice.fromJson(e as Map<String, dynamic>))
            .toList(),
        correctAnswerId: (j['correctAnswerId'] ?? '') as String,
        difficulty: (j['difficulty'] ?? 'medium') as String,
        eli5: (j['eli5'] ?? '') as String,
        steps: (j['steps'] as List? ?? [])
            .map((e) => Step.fromJson(e as Map<String, dynamic>))
            .toList(),
        handbookPage: j['handbookPage'] as String?,
        figure: Figure.fromJson(j['diagram'] as Map<String, dynamic>?),
      );
}
