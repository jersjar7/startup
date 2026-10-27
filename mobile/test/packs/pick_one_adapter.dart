import 'dart:ui';

import 'package:mobile/core/theme/app_colors.dart';

import 'builder.dart';

/// One round of a pick-one game, as the generated adapters hand it over.
typedef PickRound = ({
  String subject,
  String asked,
  List<String> options,
  int answer,
  String why,
  String source,
  Draw Function(bool answered) draw,
});

/// A pick-one game as pack data: the standard screen (overline, subject,
/// question, a drawing on the grid, the answers in a list), with each
/// round's drawing recorded before and after answering.
Map<String, Object?> pickOne({
  required String id,
  required String chapter,
  required String title,
  required String closing,
  required String overline,
  required String right,
  required String wrong,
  required int figureHeight,
  required Map<String, Object?> brief,
  required List<PickRound> rounds,
}) {
  // The panel has a one pixel border, so the painter gets two less.
  final height = figureHeight - 2.0;
  return {
    'type': 'pick-one',
    'id': id,
    'chapter': chapter,
    'title': title,
    'closing': closing,
    'overline': overline,
    'right': right,
    'wrong': wrong,
    'figureHeight': figureHeight,
    'brief': brief,
    'rounds': [
      for (final (i, r) in rounds.indexed)
        {
          'subject': r.subject,
          'asked': r.asked,
          'options': r.options,
          'answer': r.answer,
          'why': r.why,
          'source': r.source,
          'figure': {
            for (final answered in [false, true])
              answered ? 'done' : 'ask': record(
                r.draw(answered),
                height,
                what: '$id round $i',
              ),
          },
        },
    ],
  };
}

/// One round of a pick-one game laid out as its own screen of blocks.
typedef ScreenRound = ({
  List<String> options,
  List<String>? tex,
  int answer,
  String why,
  String source,
  List<Map<String, Object?>> screen,
});

/// A pick-one game whose rounds each carry their screen as blocks (see the
/// pack's pick-one game for the blocks).
Map<String, Object?> pickScreen({
  required String id,
  String chapter = 'dynamics',
  required String title,
  required String closing,
  required String right,
  required String wrong,
  required Map<String, Object?> brief,
  double choicePad = 13,
  required List<ScreenRound> rounds,
}) => {
  'type': 'pick-one',
  'id': id,
  'chapter': chapter,
  'title': title,
  'closing': closing,
  'right': right,
  'wrong': wrong,
  'brief': brief,
  'rounds': [
    for (final r in rounds)
      {
        'options': r.options,
        'tex': ?r.tex,
        if (choicePad != 13) 'choicePad': choicePad,
        'answer': r.answer,
        'why': r.why,
        'source': r.source,
        'screen': r.screen,
      },
  ],
};

Map<String, Object?> gap(num h, {String? when}) => {'gap': h, 'when': ?when};

/// The usual top of a round: the overline, the problem's subject and its
/// setting.
List<Map<String, Object?>> heading(
  String overline,
  String subject,
  String setting,
) => [
  {'overline': overline, 'color': 'ember'},
  gap(6),
  {'mono': subject, 'size': 11.5, 'color': 'ink3'},
  gap(10),
  {'text': setting},
];

/// The answers with [space] after each, then once answered that space
/// again and the feedback.
List<Map<String, Object?>> answers(num space) => [
  {'choices': true, 'space': space, 'last': true},
  ...feedbackAfter(space),
];

/// Once answered: a gap of [space], then the feedback.
List<Map<String, Object?>> feedbackAfter(num space) => [
  gap(space, when: 'done'),
  {'feedback': true},
];

/// A recorded drawing block, in both states. A panel's border takes a
/// pixel each side, so its painter gets two less.
Map<String, Object?> figure(
  Draw Function(bool answered) draw,
  Object h, {
  required String frame,
  required String what,
}) {
  double at(bool answered) {
    final v = switch (h) {
      {'ask': final num ask, 'done': final num done} => answered ? done : ask,
      final num n => n,
      _ => throw ArgumentError(h),
    };
    return v.toDouble() - (frame == 'panel' ? 2 : 0);
  }

  return {
    'figure': {
      for (final answered in [false, true])
        answered ? 'done' : 'ask': record(
          draw(answered),
          at(answered),
          what: what,
        ),
    },
    'h': h,
    'frame': frame,
  };
}

/// The ink a drawing answer takes in each state, for games that tint the
/// drawing as well as the border.
Color toneOf(String state) => switch (state) {
  'right' => AppColors.forest,
  'wrong' => AppColors.error,
  'picked' => AppColors.ember,
  _ => AppColors.info,
};

/// Answers that are drawings, one panel per answer (see the pack's pick-one
/// game). A panel's border is one pixel until it is picked, then two, so
/// the drawing inside is recorded at both sizes. With [toned] the drawing
/// itself changes with the state (`paint` gets the state to draw it in);
/// without, only its size does.
Map<String, Object?> panels(
  List<void Function(Canvas canvas, Size size, String state)> paint, {
  required double h,
  double pad = 0,
  bool row = false,
  num space = 8,
  bool last = true,
  required bool toned,
  required String what,
}) {
  Object at(int i, String state) => record(
    (canvas, size) => paint[i](canvas, size, state),
    h - 2 * pad - (state == 'idle' ? 2 : 4),
    // A panel in a row of two is under half the game's width.
    range: (60, 1000),
    what: '$what panel $i $state',
  );
  return {
    'panels': [
      for (var i = 0; i < paint.length; i++)
        {
          for (final state
              in toned
                  ? const ['idle', 'picked', 'right', 'wrong']
                  : const ['idle', 'on'])
            state: at(i, state),
        },
    ],
    'h': h,
    if (pad != 0) 'pad': pad,
    if (row) 'row': true,
    'space': space,
    if (last) 'last': true,
  };
}

/// A drawing answered by tapping near one of its marks (see the pack's
/// pick-one game): drawn for every mark picked, or none, before and after
/// the answer, with each mark's place recorded as a circle of the reach a
/// tap has.
Map<String, Object?> tapMarks({
  required void Function(Canvas canvas, Size size, int? mark, bool answered)
  paint,
  required int marks,
  required Offset Function(Size size, int mark) at,
  required double within,
  required List<int> hits,
  required double h,
  required String what,
}) => {
  'tap': {
    for (final mark in [null, for (var i = 0; i < marks; i++) i])
      for (final answered in [false, true])
        '${mark ?? '-'}|${answered ? 1 : 0}': record(
          (canvas, size) => paint(canvas, size, mark, answered),
          h,
          what: '$what mark $mark ${answered ? 'answered' : 'open'}',
        ),
  },
  'targets': record(
    (canvas, size) {
      for (var i = 0; i < marks; i++) {
        canvas.drawCircle(at(size, i), within, Paint());
      }
    },
    h,
    what: '$what marks',
  ),
  'within': within,
  'hits': hits,
  'h': h,
};
