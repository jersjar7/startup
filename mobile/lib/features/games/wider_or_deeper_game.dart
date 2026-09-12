import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'bearing_figures.dart';

/// Wider or Deeper — the second item for `bearing-capacity`.
///
/// A footing that will not do can be made wider or it can be buried deeper,
/// and which of those helps depends entirely on the soil. On a sand both
/// work and burying works better. On an undrained clay widening the footing
/// raises the pressure it can take by nothing at all, since the term that
/// would have grown has a factor of zero. That is a design decision the
/// equation answers on sight.
class WiderOrDeeperGame extends StatefulWidget {
  const WiderOrDeeperGame({super.key});

  @override
  State<WiderOrDeeperGame> createState() => _WiderOrDeeperGameState();
}

/// What to do about a footing that is short of capacity.
enum Remedy { wider, deeper, both, neither }

@immutable
class FixRound {
  const FixRound({
    required this.subject,
    required this.asked,
    required this.footing,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Footing footing;
  final Remedy answer;
  final String why;
  final String source;

  static String label(Remedy which) => switch (which) {
        Remedy.wider => 'Widening it raises the pressure it can take',
        Remedy.deeper => 'Burying it deeper does, and widening does not',
        Remedy.both => 'Both help, and burying helps more',
        Remedy.neither => 'Neither changes the pressure it can take',
      };
}

const _clay = Footing(
    width: 6, depth: 3, cohesion: 1500, unitWeight: 115,
    nc: 5.14, nq: 1, nGamma: 0);
const _sand = Footing(
    width: 4, depth: 3, cohesion: 0, unitWeight: 120,
    nc: 30.14, nq: 18.40, nGamma: 15.07);
const _sandSurface = Footing(
    width: 4, depth: 0, cohesion: 0, unitWeight: 120,
    nc: 30.14, nq: 18.40, nGamma: 15.07);

const fixRounds = <FixRound>[
  FixRound(
    subject: 'a footing on a clay',
    asked:
        'A footing on an undrained clay is short of bearing capacity. Does '
        'making it wider raise the pressure the soil can take?',
    footing: _clay,
    answer: Remedy.deeper,
    why:
        'No. The width only appears in the third term, and for an undrained '
        'clay that term has a factor of zero, so widening changes the '
        'pressure not at all. Burying it deeper does help, through the depth '
        'term. Widening a footing on clay still helps the STRUCTURE, of '
        'course, by spreading the same load over more area, but the soil is '
        'not getting any stronger.',
    source: 'geo-bc-q1',
  ),
  FixRound(
    subject: 'a footing on a sand',
    asked:
        'The same question on a clean sand with a friction angle of 30 '
        'degrees. Wider, deeper, or both?',
    footing: _sand,
    answer: Remedy.both,
    why:
        'Both, and burying helps more. A sand has large factors on both the '
        'depth and the width terms, and the depth factor here is bigger than '
        'the width one, and it is not halved the way the width term is. Foot '
        'for foot, going down beats going out.',
    source: 'geo-bc-q2',
  ),
  FixRound(
    subject: 'the surface footing on sand',
    asked:
        'A footing laid on the surface of that same sand. What is the '
        'quickest way to give it some capacity?',
    footing: _sandSurface,
    answer: Remedy.both,
    why:
        'Bury it. On the surface the depth term is zero and the whole '
        'capacity comes from the width term, which is modest: this is close '
        'to the weakest thing you can build on a sand. Three feet of burial '
        'roughly triples it. Widening helps too, but not like that.',
    source: 'geo-bc-q2',
  ),
  FixRound(
    subject: 'why depth does anything at all',
    asked:
        'Why does burying a footing raise the pressure the soil beneath it '
        'can take?',
    footing: _sand,
    answer: Remedy.deeper,
    why:
        'Because the soil beside a buried footing has to be lifted and pushed '
        'out of the way before the footing can punch down: a bearing failure '
        'is soil moving sideways and then up. The deeper it sits, the more '
        'soil is in the way, and the depth term is what that is worth.',
    source: 'geo-bc-q2',
  ),
  FixRound(
    subject: 'below the water table',
    asked:
        'The site floods and the sand is now below the water table, which '
        'halves the effective unit weight. Do widening and burying still '
        'help?',
    footing: _sand,
    answer: Remedy.both,
    why:
        'Both still help, but from a lower starting point: the depth and '
        'width terms are weights, and buoyant soil weighs about half as much, '
        'so both terms halve. The site has lost half its bearing capacity '
        'without anything being built or dug, which is one of the less '
        'obvious things a rising water table does.',
    source: 'geo-bc-q3',
  ),
  FixRound(
    subject: 'the flooded clay',
    asked:
        'The clay site floods too. Does widening the footing help NOW?',
    footing: _clay,
    answer: Remedy.deeper,
    why:
        'Still no. Widening was worth nothing before the flood and it is '
        'worth nothing after it, because the term it would have grown has a '
        'factor of zero either way. Note also that the clay lost far less to '
        'the flooding than the sand did, since most of its capacity is '
        'cohesion and cohesion has no unit weight in it at all.',
    source: 'geo-bc-q1',
  ),
];

class _WiderOrDeeperGameState extends State<WiderOrDeeperGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'wider-or-deeper',
    chapterId: 'geotechnical',
    total: fixRounds.length,
    sourceProblemIdOf: (round) => fixRounds[round].source,
  )..addListener(_onSession);

  Remedy? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FixRound get _round => fixRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Wider or Deeper',
        closing:
            'On a sand both help and burying helps more, because the depth '
            'factor is the larger and the width term is halved besides. On an '
            'undrained clay widening raises the pressure the soil can take by '
            'nothing at all, since that term has a factor of zero, though it '
            'still spreads the structural load. Burying works because the '
            'soil beside the footing has to be shifted before it can fail. '
            'And a rising water table halves both of the weight terms.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: footingFixBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT WOULD HELP',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 216,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter:
                      FootingPainter(footing: r.footing, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$N_\gamma = 0 \text{ when } \phi = 0$",
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Remedy.values) ...[
            _Choice(
              label: FixRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Remedy.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
