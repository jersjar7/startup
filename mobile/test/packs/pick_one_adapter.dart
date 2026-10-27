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
