import 'package:mobile/features/games/asphalt_figures.dart';
import 'package:mobile/features/games/in_what_order_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/per_million_what_game.dart';
import 'package:mobile/features/games/tap_the_voids_game.dart';
import 'package:mobile/features/games/traffic_flow_figures.dart';

import 'builder.dart';

/// The three phase 0 games as pack data.
///
/// Every string the original screen shows is copied here by hand, which is
/// exactly what the parity test exists to catch: a word out of place shows
/// up as a picture that differs.

Map<String, Object?> perMillionWhat() {
  // The panel is 196 tall with a one pixel border, so the painter gets 194.
  const height = 194.0;
  return {
    'type': 'pick-one',
    'id': 'per-million-what',
    'chapter': 'transportation',
    'title': 'Per Million What',
    'closing':
        'A crash count means nothing until it is set against the traffic '
        'that was exposed. Annualize the daily count so the periods '
        'match, scale to a million so the answer is readable, and carry '
        'the length as well when it is a stretch of road rather than a '
        'junction. A busier place with more crashes can be the safer one.',
    'overline': 'CRASHES AGAINST TRAFFIC',
    'right': 'THAT IS IT',
    'wrong': 'NOT THAT ONE',
    'figureHeight': 196,
    'brief': briefJson(crashRateBrief, 'crash rate brief'),
    'rounds': [
      for (final (i, r) in exposureRounds.indexed)
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
                ExposurePainter(rate: r.rate, answered: answered).paint,
                height,
                what: 'per-million-what round $i',
              ),
          },
        },
    ],
  };
}

Map<String, Object?> tapTheVoids() {
  const height = 250.0;
  return {
    'type': 'tap-figure',
    'id': 'tap-the-voids',
    'chapter': 'materials',
    'title': 'Tap the Voids',
    'closing':
        'Three bands and a bracket. Air voids are the air over the WHOLE '
        'specimen. VMA is the air and the binder together, the whole '
        'space between the stones. VFA is the binder as a share of that '
        'bracket, never of the whole mix. And the term the VMA formula '
        'subtracts is the stone, which is why it comes out near eighty '
        'six and the VMA near fourteen.',
    'overline': 'TAP THE PART',
    'note':
        'one specimen by volume. the voids are drawn far bigger than '
        'they are, or nothing could be pointed at',
    'right': 'THAT IS THE PART',
    'wrong': 'NOT THAT PART',
    'figureHeight': height,
    'brief': briefJson(voidsBrief, 'voids brief'),
    'rounds': [
      for (final (i, r) in voidRounds.indexed)
        {
          'subject': r.subject,
          'asked': r.asked,
          'answer': r.answer.name,
          'why': r.why,
          'source': r.source,
          // The original checks the pieces in their declared order.
          'regions': [
            for (final piece in Piece2.values)
              {
                'id': piece.name,
                'ops': regionOf(
                  (size) => PuckPainter.rectOf(size, r.puck, piece).inflate(6),
                  height,
                  'tap-the-voids round $i region ${piece.name}',
                ),
              },
          ],
          'figure': {
            for (final picked in [null, ...Piece2.values])
              for (final locked in [false, true])
                if (!(locked && picked == null))
                  '${picked?.name ?? '-'}|${locked ? 1 : 0}': record(
                    PuckPainter(
                      puck: r.puck,
                      picked: picked,
                      answer: r.answer,
                      locked: locked,
                    ).paint,
                    height,
                    what: 'tap-the-voids round $i ${picked?.name}/$locked',
                  ),
          },
        },
    ],
  };
}

Map<String, Object?> inWhatOrder() => {
  'type': 'order',
  'id': 'in-what-order',
  'chapter': 'ethics',
  'title': 'In What Order',
  'closing':
      'Closest party first, then up the chain, and the authority when '
      'the chain runs out. The exception is imminent danger, which stops '
      'the work before anything else happens. And one action on every '
      'board is one nobody should take.',
  'overline': 'TAP THE THREE, IN ORDER',
  'hint': 'one of the four is not taken at all',
  'neverLabel': 'THE ONE NOBODY TAKES',
  'right': 'IN THAT ORDER',
  'wrong': 'NOT THAT ORDER',
  'brief': briefJson(escalationBrief, 'escalation brief'),
  'rounds': [
    for (final r in ladderRounds)
      {
        'scenario': r.scenario,
        'actions': r.actions,
        'order': r.order,
        'never': r.never,
        'why': r.why,
        'source': r.source,
      },
  ],
};
