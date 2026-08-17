import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Per-chapter progress, parsed from GET /progress/chapter/:id.
///
/// The rules here are NOT re-decided for mobile. They were settled on the
/// website (see docs/progress-markers.md) and this mirrors them exactly:
/// five states, three brand colours, no red, and fractions counted in
/// EXERCISES rather than whole lessons.

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
  /// `attempted` shares ember with `one-correct` on purpose: with the capsule the
  /// two are already told apart by whether any segment is filled, so the hue does
  /// not have to carry that difference as well.
  Color? get color => switch (state) {
        'attempted' => AppColors.ember,
        'one-correct' => AppColors.ember,
        'two-correct' => AppColors.sunbeam,
        'complete' => AppColors.forest,
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
