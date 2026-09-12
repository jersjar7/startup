import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'slope_figures.dart';

/// What Holds the Wedge — the third item for `slope-stability`.
///
/// A block of soil on a planar slip surface is the clearest picture in the
/// chapter of what a factor of safety is: everything holding it divided by
/// everything pushing it down the plane. The weight does both jobs, split by
/// the angle of the surface, and the cohesion adds a third term that owes
/// nothing to the weight at all.
class WhatHoldsTheWedgeGame extends StatefulWidget {
  const WhatHoldsTheWedgeGame({super.key});

  @override
  State<WhatHoldsTheWedgeGame> createState() =>
      _WhatHoldsTheWedgeGameState();
}

@immutable
class WedgeRound {
  const WedgeRound({
    required this.subject,
    required this.asked,
    required this.wedge,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Wedge2 wedge;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _lessonWedge =
    Wedge2(cohesionForce: 120, weight: 400, slipAngle: 25, friction: 20);
const _noCohesion =
    Wedge2(cohesionForce: 0, weight: 400, slipAngle: 25, friction: 20);

const wedgeRounds = <WedgeRound>[
  WedgeRound(
    subject: 'what drives it',
    asked:
        'The wedge weighs 400 and sits on a surface sloping at 25 degrees. '
        'Which part of that weight is trying to slide it?',
    wedge: _lessonWedge,
    options: [
      'The part along the surface: the weight times the sine of the angle',
      'The whole weight',
      'The part across the surface: the weight times the cosine',
      'The weight divided by the cosine',
    ],
    answer: 0,
    why:
        'The component ALONG the plane, which is the weight times the sine. '
        'That is the only part trying to move the block. Steepen the surface '
        'and the sine grows, which is the whole reason a steeper slip plane '
        'is a more dangerous one.',
    source: 'geo-slp-q3',
  ),
  WedgeRound(
    subject: 'what holds it on',
    asked:
        'And which part of the same weight is helping to hold it?',
    wedge: _lessonWedge,
    options: [
      'The part across the surface, since friction is proportional to it',
      'The part along the surface',
      'None of it: only the cohesion holds it',
      'All of it, since the weight resists motion',
    ],
    answer: 0,
    why:
        'The component ACROSS the plane, the weight times the cosine, because '
        'that is what presses the block onto the surface and friction is '
        'proportional to how hard it is pressed. So the weight does both '
        'jobs, and the angle of the plane decides how it is split: the '
        'steeper the plane, the more of it drives and the less holds.',
    source: 'geo-slp-q3',
  ),
  WedgeRound(
    subject: 'the third term',
    asked:
        'The cohesion along the surface contributes 120. What does that '
        'number depend on?',
    wedge: _lessonWedge,
    options: [
      'The cohesion of the soil and the LENGTH of the surface, and not the '
          'weight at all',
      'The weight of the wedge',
      'The friction angle',
      'The slope of the surface only',
    ],
    answer: 0,
    why:
        'Cohesion times length. It owes nothing to the weight, which makes it '
        'the term that saves shallow slips: a thin wedge weighs little and so '
        'has little friction to call on, but its slip surface is just as long '
        'and the cohesion along it is undiminished.',
    source: 'geo-slp-q3',
  ),
  WedgeRound(
    subject: 'the lesson\'s own wedge',
    asked:
        'With 120 of cohesion, a weight of 400, a slip angle of 25 degrees '
        'and 20 degrees of friction, what is the factor of safety about?',
    wedge: _lessonWedge,
    options: [
      'About 1.5: roughly 250 holding against roughly 170 driving',
      'About 0.8: the friction alone against the driving force',
      'About 2.1: everything holding against the cohesion',
      'Exactly 1.0, since the wedge is on the point of moving',
    ],
    answer: 0,
    why:
        'About 1.5. The two holding terms come to roughly 250, the driving '
        'component to roughly 170, and their ratio is the answer. The lesson '
        'offers 0.78 as a choice, which is what you get by dropping the '
        'cohesion, and that single omission turns a safe slope into a failing '
        'one.',
    source: 'geo-slp-q3',
  ),
  WedgeRound(
    subject: 'dropping the cohesion',
    asked:
        'Somebody forgets the cohesion term on that same wedge. What happens '
        'to the answer?',
    wedge: _noCohesion,
    options: [
      'It falls to about 0.78, and the slope is reported as failing',
      'It rises, since there is less to work out',
      'Nothing much: cohesion is a small term',
      'It becomes exactly one',
    ],
    answer: 0,
    why:
        'It falls to about 0.78. Here the cohesion was almost half of '
        'everything holding the wedge, so leaving it out is not a small '
        'error: it reverses the verdict. In a clay the cohesion term is '
        'usually the larger of the two, and in a clean sand it is not there '
        'at all.',
    source: 'geo-slp-q3',
  ),
  WedgeRound(
    subject: 'what a factor of safety is',
    asked:
        'In every form the lesson gives, what is the factor of safety made '
        'of?',
    wedge: _lessonWedge,
    options: [
      'Everything resisting, over everything driving',
      'Everything driving, over everything resisting',
      'The difference between them',
      'The resisting force alone',
    ],
    answer: 0,
    why:
        'Resisting over driving, always that way up, so that more than one '
        'means safe. The infinite slope version is the same fraction with '
        'everything canceled down to two tangents, and the wedge version is '
        'the same fraction written out in full. Turning it over is the wrong '
        'answer the lesson offers on its very first problem.',
    source: 'geo-slp-q1',
  ),
];

class _WhatHoldsTheWedgeGameState extends State<WhatHoldsTheWedgeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-holds-the-wedge',
    chapterId: 'geotechnical',
    total: wedgeRounds.length,
    sourceProblemIdOf: (round) => wedgeRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WedgeRound get _round => wedgeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Holds the Wedge',
        closing:
            'The weight does both jobs: its component along the plane drives '
            'the slide, its component across the plane presses the block down '
            'and buys friction, and the angle of the plane decides the split. '
            'The cohesion adds a term that depends on the LENGTH of the '
            'surface and not on the weight at all, which is what saves '
            'shallow slips. And the factor of safety is always resisting over '
            'driving.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: wedgeBrief,
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
            'WHAT DOES WHAT',
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
            height: 206,
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
                  painter: WedgePainter(wedge: r.wedge, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$FS = \frac{cL_s + W\cos\alpha\tan\phi}{W\sin\alpha}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
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
