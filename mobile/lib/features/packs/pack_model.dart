import 'package:flutter/widgets.dart';

import '../games/lesson_brief.dart';
import '../games/mechanics_pictures.dart' show ConceptPair, ConceptPicture;
import 'drawing/drawing_painter.dart';
import 'games/order_game.dart';
import 'games/pick_one_game.dart';
import 'games/tap_figure_game.dart';

/// One game as a pack describes it (ADR 0030): which game type plays it,
/// and everything that makes it this lesson's game.
class PackGame {
  PackGame(this.json, {this.pack});

  final Map<String, Object?> json;

  /// The pack and version it came from (`fe-civil@1`), for reports.
  final String? pack;

  String get id => json['id']! as String;
  String get type => json['type']! as String;
  String get chapterId => json['chapter']! as String;
  String get title => json['title']! as String;
  String get closing => json['closing']! as String;
  String text(String key) => json[key]! as String;
  List<Map<String, Object?>> get rounds =>
      (json['rounds']! as List).cast<Map<String, Object?>>();

  late final BriefSection? brief = json['brief'] == null
      ? null
      : briefFromJson(json['brief']! as Map<String, Object?>);

  /// The screen for this game, or null when this app has no such game type
  /// (the lesson then asks for an update; ADR 0030, section 5).
  Widget? screen() => switch (type) {
    'pick-one' => PackPickOneGame(game: this),
    'tap-figure' => PackTapFigureGame(game: this),
    'order' => PackOrderGame(game: this),
    _ => null,
  };
}

/// A recorded drawing, as [DrawingPainter] takes it.
Object ops(Object? raw) => raw!;

BriefSection briefFromJson(Map<String, Object?> j) {
  List<(String, String)> pairs(Object? raw) => [
    for (final p in (raw as List?) ?? const [])
      ((p as List)[0] as String, p[1] as String),
  ];
  final picture = j['picture'] as Map<String, Object?>?;
  return BriefSection(
    title: j['title']! as String,
    body: (j['body'] as String?) ?? '',
    formula: j['formula'] as String?,
    formulas: pairs(j['formulas']),
    handbook: j['handbook'] as String?,
    picture: picture == null ? null : () => _picture(picture),
    steps: pairs(j['steps']),
    lesson: j['lesson'] as String?,
    spoken: [
      for (final p in (j['spoken'] as List?) ?? const [])
        ((p as List)[0] as String, p[1] as String, p[2] as String),
    ],
  );
}

Widget _picture(Map<String, Object?> p) {
  switch (p['kind']) {
    case 'column':
      return Column(
        children: [
          for (final c in p['children']! as List)
            _picture(c! as Map<String, Object?>),
        ],
      );
    case 'gap':
      return SizedBox(height: (p['h']! as num).toDouble());
  }
  final height = (p['h']! as num).toDouble();
  switch (p['kind']) {
    case 'one':
      return ConceptPicture(
        painter: DrawingPainter(ops(p['ops'])),
        caption: p['caption']! as String,
        height: height,
      );
    case 'pair':
      final left = p['left']! as Map<String, Object?>;
      final right = p['right']! as Map<String, Object?>;
      return ConceptPair(
        left: DrawingPainter(ops(left['ops'])),
        right: DrawingPainter(ops(right['ops'])),
        leftCaption: left['caption']! as String,
        rightCaption: right['caption']! as String,
        height: height,
      );
    default:
      throw UnsupportedError('Unknown picture layout ${p['kind']}');
  }
}
