import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Per-chapter progress, parsed from GET /progress/chapter/:id.
///
/// The rules come from the website (see docs/progress-markers.md): five states,
/// no red, "correct" means EVER got it right, markers only improve, and
/// fractions counted in EXERCISES rather than whole lessons.
///
/// The one place mobile now differs is the palette. The web's three-colour
/// ladder (ember, sunbeam, forest) was a way to encode HOW MANY in a single dot,
/// which was the only channel a dot had. The capsule encodes that in its fill
/// height, so the ladder became a second encoding of the same number and was
/// dropped. See the colour comment below.

/// One lesson's state. `state` is the server's word, kept verbatim so the two
/// clients cannot drift into disagreeing about what "complete" means.
class LessonProgress {
  const LessonProgress({
    required this.correct,
    required this.answered,
    required this.total,
    required this.state,
  });

  final int correct;
  final int answered;
  final int total;
  final String state; // untouched | attempted | one-correct | two-correct | complete

  factory LessonProgress.fromJson(Map<String, dynamic> j) => LessonProgress(
        correct: (j['correct'] ?? 0) as int,
        answered: (j['answered'] ?? 0) as int,
        total: (j['total'] ?? 3) as int,
        state: (j['state'] ?? 'untouched') as String,
      );

  /// The capsule's outline colour, and the fill colour for however many segments
  /// are filled. null means "draw nothing" — untouched reserves its space but
  /// shows no marker.
  ///
  /// ONE COLOUR for every drawn state, and it is forest — the same green the
  /// exercise screen paints a CORRECT answer.
  ///
  /// That matching is the point. Under the old ladder a lesson with 1 of 3 right
  /// was drawn in ember, which is the colour this app uses for a WRONG answer one
  /// screen deeper. It reported a right answer in the wrong-answer colour. Green
  /// segments now mean exactly what green means everywhere else here: correct
  /// answers, accumulating.
  ///
  /// Known and accepted: forest also means "done" elsewhere on this screen (the
  /// mastery ring, the subtopic fraction when every exercise is right), so green
  /// now appears on lessons nowhere near finished. Fill HEIGHT carries that
  /// difference instead of hue, and a third-full capsule reads nothing like a
  /// solid one.
  ///
  /// Also brings the screen back inside the brand rule of at most two accents per
  /// section: the ladder could put ember, sunbeam and forest in one open subtopic.
  Color? get color => switch (state) {
        'attempted' || 'one-correct' || 'two-correct' || 'complete' => AppColors.forest,
        _ => null,
      };

  /// The same sentence the website shows, and the marker's accessible label.
  String? get explanation => switch (state) {
        'attempted' => 'Started, no exercises correct yet',
        'one-correct' => '1 of $total exercises correct',
        'two-correct' => '2 of $total exercises correct',
        'complete' => 'All $total exercises correct',
        _ => null,
      };
}

class SubtopicProgress {
  const SubtopicProgress({
    required this.complete,
    required this.total,
    required this.exercisesCorrect,
    required this.exercisesTotal,
  });

  final int complete;
  final int total;
  final int exercisesCorrect;
  final int exercisesTotal;

  factory SubtopicProgress.fromJson(Map<String, dynamic> j) => SubtopicProgress(
        complete: (j['complete'] ?? 0) as int,
        total: (j['total'] ?? 0) as int,
        exercisesCorrect: (j['exercisesCorrect'] ?? 0) as int,
        exercisesTotal: (j['exercisesTotal'] ?? 0) as int,
      );

  /// Counts EXERCISES, not finished lessons. Counting lessons made a subtopic
  /// holding real partial work report "0 of 3" while the markers inside it
  /// showed otherwise — a header that contradicts its own rows is worse than
  /// no header.
  String get label => '$exercisesCorrect of $exercisesTotal exercises';

  bool get allDone => exercisesTotal > 0 && exercisesCorrect >= exercisesTotal;
}

class ChapterProgress {
  const ChapterProgress({required this.lessons, required this.subtopics});

  final Map<String, LessonProgress> lessons;
  final Map<String, SubtopicProgress> subtopics;

  factory ChapterProgress.fromJson(Map<String, dynamic> j) => ChapterProgress(
        lessons: ((j['lessons'] ?? {}) as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, LessonProgress.fromJson(v as Map<String, dynamic>))),
        subtopics: ((j['subtopics'] ?? {}) as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, SubtopicProgress.fromJson(v as Map<String, dynamic>))),
      );
}
