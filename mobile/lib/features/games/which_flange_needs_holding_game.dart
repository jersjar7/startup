import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'steel_figures.dart';

/// Which Flange Needs Holding — the third item for `steel-beams`.
///
/// Lateral-torsional buckling is a compression flange going over sideways,
/// so bracing only counts when it holds the flange that is being squashed.
/// In a sagging span that is the top one and a slab does the job for
/// nothing. Over a support the bending is the other way round, the BOTTOM
/// flange is the one in compression, and the slab overhead is no help at all
/// where it is most needed.
class WhichFlangeNeedsHoldingGame extends StatefulWidget {
  const WhichFlangeNeedsHoldingGame({super.key});

  @override
  State<WhichFlangeNeedsHoldingGame> createState() =>
      _WhichFlangeNeedsHoldingGameState();
}

@immutable
class FlangeRound {
  const FlangeRound({
    required this.subject,
    required this.asked,
    required this.part,
    required this.sagging,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;

  /// What the drawing lights up while the question is being asked.
  final Part2 part;
  final bool sagging;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const flangeRounds = <FlangeRound>[
  FlangeRound(
    subject: 'the middle of a simple span',
    asked:
        'A simply supported beam sagging under its load. Which part of the '
        'section is in compression, and so is the part that can buckle '
        'sideways?',
    part: Part2.none,
    sagging: true,
    options: [
      'The top flange',
      'The bottom flange',
      'The web',
      'The whole section equally',
    ],
    answer: 0,
    why:
        'The top flange. A sagging beam is squashed along the top and '
        'stretched along the bottom, and it is the squashed flange that wants '
        'to go over sideways, dragging the section into a twist as it does. '
        'The stretched flange is quite happy: tension keeps things straight.',
    source: 'str-sb-q1',
  ),
  FlangeRound(
    subject: 'over a support',
    asked:
        'The same beam runs continuously over an interior support, where it '
        'hogs instead of sagging. Which flange is in compression THERE?',
    part: Part2.none,
    sagging: false,
    options: [
      'The bottom flange',
      'The top flange',
      'Neither: the moment is zero over a support',
      'Both, because the moment reverses',
    ],
    answer: 0,
    why:
        'The bottom one. Over a support the beam curves the other way, so the '
        'bottom is squashed and the top is stretched. This is the round worth '
        'remembering: the flange that needs holding is not always the one on '
        'top, and the place where it is not is exactly the place with a slab '
        'sitting uselessly overhead.',
    source: 'str-sb-q1',
  ),
  FlangeRound(
    subject: 'what a brace has to do',
    asked: 'What does a lateral brace actually have to prevent?',
    part: Part2.topFlange,
    sagging: true,
    options: [
      'The compression flange moving sideways, and the section twisting with '
          'it',
      'The beam deflecting downward',
      'The web buckling under shear',
      'The beam rotating about its own length at the supports only',
    ],
    answer: 0,
    why:
        'Sideways movement of the compression flange, and the twist that goes '
        'with it. A brace that only stops the beam going down does nothing '
        'for this failure, which is why a steel joist sitting on a beam is '
        'not automatically a brace: it has to be connected so that it holds '
        'the flange against moving out of plane.',
    source: 'str-sb-q1',
  ),
  FlangeRound(
    subject: 'a slab in the span',
    asked:
        'A concrete slab is cast on the top flange of a simply supported '
        'beam. Does it brace the compression flange?',
    part: Part2.topFlange,
    sagging: true,
    options: [
      'Yes, continuously: the unbraced length is effectively zero',
      'No: concrete cannot brace steel',
      'Only at the points where shear studs are welded on',
      'Only if the slab is thicker than the flange',
    ],
    answer: 0,
    why:
        'Yes, and everywhere. The slab is attached along the whole length and '
        'the compression flange is the one it is attached to, so there is '
        'nowhere for that flange to go. This is why so many floor beams need '
        'no buckling check at all: the lesson says to skip it, and this is '
        'the situation it means.',
    source: 'str-sb-q1',
  ),
  FlangeRound(
    subject: 'the same slab, over the support',
    asked:
        'That same slab, over the interior support of a continuous beam. Does '
        'it brace the flange in compression there?',
    part: Part2.bottomFlange,
    sagging: false,
    options: [
      'No: the compression flange there is the bottom one, and the slab is '
          'nowhere near it',
      'Yes: the slab braces the whole section wherever it is cast',
      'Yes, but only for half the unbraced length',
      'No, but the support itself counts as a brace for the whole region',
    ],
    answer: 0,
    why:
        'No. The slab holds the top flange, and over the support the top '
        'flange is the one in tension, which needed no help. The bottom '
        'flange is being squashed with nothing attached to it, so the '
        'unbraced length there runs from one point of real bottom flange '
        'restraint to the next. Continuous beams are braced underneath near '
        'their supports for exactly this reason.',
    source: 'str-sb-q3',
  ),
  FlangeRound(
    subject: 'the shear',
    asked:
        'Leaving bending aside, which part of the section is taken to carry '
        'the shear?',
    part: Part2.web,
    sagging: true,
    options: [
      'The web alone, its depth times its thickness',
      'The two flanges, since they are the thickest parts',
      'The whole cross-sectional area',
      'The web and one flange',
    ],
    answer: 0,
    why:
        'The web alone, taken as the full depth times the web thickness. The '
        'flanges are busy carrying the bending and contribute almost nothing '
        'to shear, so the code hands the whole job to the web and multiplies '
        'by 0.6 of the yield stress, which is where steel starts to slide '
        'rather than stretch. For most rolled shapes there is no reduction '
        'factor on top of that at all.',
    source: 'str-sb-q2',
  ),
];

class _WhichFlangeNeedsHoldingGameState
    extends State<WhichFlangeNeedsHoldingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-flange-needs-holding',
    chapterId: 'structural',
    total: flangeRounds.length,
    sourceProblemIdOf: (round) => flangeRounds[round].source,
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

  FlangeRound get _round => flangeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Flange Needs Holding',
        closing:
            'Buckling is a compression flange going sideways, so a brace only '
            'counts if it holds THAT flange and stops the section twisting. '
            'Sagging, it is the top one, and a slab braces it for nothing. '
            'Hogging over a support, it is the bottom one, and the slab '
            'overhead is no use at all. Shear is a separate story and belongs '
            'entirely to the web.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: flangeBrief,
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
            'WHAT IS IN COMPRESSION',
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
            height: 176,
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
                  painter: ShapePainter(
                    part: r.part,
                    sagging: r.sagging,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$V_n = 0.6 F_y A_w, \quad A_w = d\,t_w$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
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
