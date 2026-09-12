import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'steel_figures.dart';

/// How Far Between Braces — the first item for `steel-beams`.
///
/// A steel beam's bending capacity is not a property of the section alone.
/// The same beam reaches its full plastic moment when its compression flange
/// is held often enough and rather less when it is not, and the exam
/// question is almost always which of those three situations the beam is in.
/// The arithmetic of the sloping middle band belongs on paper. Reading the
/// bracing off the drawing does not.
class HowFarBetweenBracesGame extends StatefulWidget {
  const HowFarBetweenBracesGame({super.key});

  @override
  State<HowFarBetweenBracesGame> createState() =>
      _HowFarBetweenBracesGameState();
}

@immutable
class BraceRound {
  const BraceRound({
    required this.subject,
    required this.asked,
    required this.beam,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Braced beam;
  final String why;
  final String source;

  /// The drawing decides, so the round cannot claim a band its own lengths
  /// do not give.
  Gets get answer => beam.reach;

  static String label(Gets which) => switch (which) {
        Gets.fullPlastic => 'The full plastic moment, with no reduction',
        Gets.inelastic => 'Less than that, part way down the sloping band',
        Gets.elastic => 'Much less: the flange buckles while still elastic',
      };
}

const braceRounds = <BraceRound>[
  BraceRound(
    subject: 'a slab on top',
    asked:
        'A floor beam with a concrete slab cast on its top flange, right '
        'along the span. What can this beam reach?',
    beam: Braced(span: 30, braceEvery: 0, lp: 8, lr: 25, continuous: true),
    why:
        'The full plastic moment. A slab sitting on the compression flange '
        'holds it everywhere, so the unbraced length is zero and there is '
        'nothing for the flange to buckle into. When a problem says fully '
        'braced or continuously supported, the whole buckling check can be '
        'skipped, which is the lesson saying so in as many words.',
    source: 'str-sb-q1',
  ),
  BraceRound(
    subject: 'braces close together',
    asked:
        'A bare steel beam with braces every 6 feet. For this shape the full '
        'strength limit is 8 feet and the buckling limit is 25. What can it '
        'reach?',
    beam: Braced(span: 30, braceEvery: 6, lp: 8, lr: 25),
    why:
        'The full plastic moment again. Inside the first limit the flange '
        'cannot go anywhere before the section yields right through, so the '
        'beam reaches everything the steel has. Bracing more often than that '
        'buys nothing in bending: the capacity has already stopped rising.',
    source: 'str-sb-q1',
  ),
  BraceRound(
    subject: 'braces further apart',
    asked:
        'The same beam, but now braced only every 15 feet. Same two limits, 8 '
        'and 25 feet. What can it reach?',
    beam: Braced(span: 30, braceEvery: 15, lp: 8, lr: 25),
    why:
        'Part way down the sloping band, which is the lesson\'s own hard '
        'problem. Between the two limits the capacity slides from the plastic '
        'moment at one end toward a lower value at the other, and where it '
        'lands is a straight-line interpolation on the unbraced length. The '
        'beam is neither at full strength nor anywhere near the elastic '
        'bottom.',
    source: 'str-sb-q3',
  ),
  BraceRound(
    subject: 'a long way between braces',
    asked:
        'A roof beam braced only at its two ends, 30 feet apart. The same '
        'limits of 8 and 25 feet. What can it reach?',
    beam: Braced(span: 30, braceEvery: 30, lp: 8, lr: 25),
    why:
        'Much less. Past the second limit the compression flange goes over '
        'sideways while the steel is still elastic, so the beam never gets '
        'near yielding anywhere. A beam in this band is being decided by its '
        'bracing rather than by its steel, and the honest fix is another '
        'brace rather than a heavier section.',
    source: 'str-sb-q3',
  ),
  BraceRound(
    subject: 'right on the first limit',
    asked:
        'Braces exactly 8 feet apart, with the full strength limit at 8 feet. '
        'What can this beam reach?',
    beam: Braced(span: 32, braceEvery: 8, lp: 8, lr: 25),
    why:
        'The full plastic moment. The limit is the last length that still '
        'gets everything, not the first length that loses something, so '
        'landing exactly on it keeps the whole capacity. A foot further apart '
        'and the sloping band starts, though only just: nothing falls off a '
        'cliff at that point.',
    source: 'str-sb-q1',
  ),
  BraceRound(
    subject: 'a stockier shape',
    asked:
        'A different, stockier shape whose limits are 14 and 40 feet, braced '
        'every 12 feet. What can it reach?',
    beam: Braced(span: 36, braceEvery: 12, lp: 14, lr: 40),
    why:
        'The full plastic moment, on the same 12 foot spacing that put the '
        'first beam into the sloping band. The two limits are properties of '
        'the SHAPE, tabulated for each one, so a wide flange is good for a '
        'longer unbraced length than a narrow deep one. There is no universal '
        'bracing spacing: look the shape up.',
    source: 'str-sb-q3',
  ),
];

class _HowFarBetweenBracesGameState extends State<HowFarBetweenBracesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-far-between-braces',
    chapterId: 'structural',
    total: braceRounds.length,
    sourceProblemIdOf: (round) => braceRounds[round].source,
  )..addListener(_onSession);

  Gets? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BraceRound get _round => braceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Far Between Braces',
        closing:
            'The same section is worth different amounts depending on how '
            'often its compression flange is held. Inside the first limit it '
            'reaches everything the steel has. Between the two limits the '
            'capacity slides down a straight line. Past the second it buckles '
            'while still elastic and the bracing, not the steel, is deciding '
            'the beam. Both limits belong to the shape and are looked up, not '
            'remembered.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: bracingBrief,
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
            'WHAT CAN THIS BEAM REACH',
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
            height: 214,
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
                  painter: BracePainter(beam: r.beam, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$M_n = M_p = F_y Z_x \text{ when } L_b \le L_p$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Gets.values) ...[
            _Choice(
              label: BraceRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Gets.values.last) const SizedBox(height: 8),
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
