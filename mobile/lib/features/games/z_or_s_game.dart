import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Z or S — the second item for `steel-beams`.
///
/// Two section moduli sit next to each other in the steel tables and they
/// are not interchangeable. Z is what the shape is worth once the whole
/// section has yielded, S is what it is worth when the outermost fiber just
/// reaches yield, and Z is the larger by a tenth or more. The plastic moment
/// wants Z, in either design method; S turns up inside the buckling equation
/// and wherever a section is still elastic.
class ZOrSGame extends StatefulWidget {
  const ZOrSGame({super.key});

  @override
  State<ZOrSGame> createState() => _ZOrSGameState();
}

@immutable
class ModulusRound {
  const ModulusRound({
    required this.subject,
    required this.asked,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const modulusRounds = <ModulusRound>[
  ModulusRound(
    subject: 'the lesson\'s own beam',
    asked:
        'A compact W shape with full lateral bracing, checked by LRFD. What '
        'gives the nominal moment?',
    options: [
      'The yield stress times Z, the plastic modulus',
      'The yield stress times S, the elastic modulus',
      'Whichever of the two the table lists first',
      'The average of the two',
    ],
    answer: 0,
    why:
        'Yield stress times Z. A braced compact shape does not stop at first '
        'yield: the yielding spreads through the section until the whole of '
        'it is at the yield stress, and Z is the property that describes that '
        'state. S would describe the moment at which the outermost fiber '
        'first yields, which the beam passes on its way up.',
    source: 'str-sb-q1',
  ),
  ModulusRound(
    subject: 'the same beam under the other method',
    asked:
        'The identical beam is now checked by allowable stress design '
        'instead. Which modulus gives the nominal moment?',
    options: [
      'Z again: the nominal moment is the same, and ASD divides it by 1.67',
      'S, because allowable stress design is an elastic method',
      'Z, but only if the beam is also compact',
      'Neither: allowable stress design uses a stress, not a moment',
    ],
    answer: 0,
    why:
        'Z again. The nominal strength of a member is a property of the '
        'member and does not change with the method used to check it. LRFD '
        'multiplies that nominal moment by 0.90 and allowable stress design '
        'divides it by 1.67 instead. Pairing the elastic modulus with '
        'allowable stress design is a habit left over from an older code, and '
        'it understates the beam.',
    source: 'str-sb-q1',
  ),
  ModulusRound(
    subject: 'which one is bigger',
    asked: 'For a rolled W shape, how do the two compare?',
    options: [
      'Z is the larger, by something like a tenth to a seventh',
      'S is the larger, by about the same margin',
      'They are equal for a symmetric shape',
      'It depends on the yield stress',
    ],
    answer: 0,
    why:
        'Z is larger, typically by ten to fifteen per cent for a W shape. '
        'That is the whole reason plastic design is worth having: the section '
        'has real strength left after its outer fiber first yields. Reaching '
        'for S when the question wanted Z throws that margin away and quietly '
        'undersells the beam by about a tenth.',
    source: 'str-sb-q1',
  ),
  ModulusRound(
    subject: 'inside the buckling equation',
    asked:
        'The lateral-torsional buckling formula has a term reading 0.7 times '
        'the yield stress times a modulus. Which one is it?',
    options: [
      'S, the elastic modulus',
      'Z, the plastic modulus',
      'Either: the 0.7 makes the difference immaterial',
      'The web modulus',
    ],
    answer: 0,
    why:
        'S. A beam that buckles sideways is still elastic when it goes, so '
        'the bottom end of the sloping band is described by the elastic '
        'modulus, cut to 0.7 of yield to allow for the residual stresses '
        'rolling leaves in the flanges. The two moduli both appear in that '
        'one equation, which is exactly why it is worth knowing which is '
        'which.',
    source: 'str-sb-q3',
  ),
  ModulusRound(
    subject: 'where each one comes from',
    asked: 'What is the difference between the two, physically?',
    options: [
      'S describes the section when its outer fiber first yields; Z describes '
          'it when every fiber has',
      'S is for bending and Z is for shear',
      'S is measured about the weak axis and Z about the strong one',
      'S allows for residual stress and Z does not',
    ],
    answer: 0,
    why:
        'First yield against full yield. The elastic modulus comes from a '
        'stress that varies straight from tension to compression across the '
        'depth, with the peak just reaching yield. The plastic modulus comes '
        'from a section yielded right through, half at yield in tension and '
        'half in compression. Same shape, two states, two numbers in the '
        'table.',
    source: 'str-sb-q1',
  ),
  ModulusRound(
    subject: 'what it costs to confuse them',
    asked:
        'Somebody uses S where the plastic moment was wanted. What happens to '
        'the answer?',
    options: [
      'The capacity comes out roughly a tenth too small, and the beam looks '
          'worse than it is',
      'The capacity comes out roughly a tenth too large',
      'Nothing: the reduction factor makes up the difference',
      'The answer is unusable, being out by a factor of ten',
    ],
    answer: 0,
    why:
        'About a tenth too small, which is the dangerous kind of wrong: the '
        'number is plausible, it is on the safe side, and nothing about it '
        'looks like an error. It will cost a mark on the exam and a heavier '
        'beam in practice. The lesson names this one directly, which is a '
        'good sign of how often it happens.',
    source: 'str-sb-q2',
  ),
];

class _ZOrSGameState extends State<ZOrSGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'z-or-s',
    chapterId: 'structural',
    total: modulusRounds.length,
    sourceProblemIdOf: (round) => modulusRounds[round].source,
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

  ModulusRound get _round => modulusRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Z or S',
        closing:
            'Z is the section yielded right through and S is the section at '
            'first yield, which makes Z the larger by a tenth or more. The '
            'plastic moment uses Z in BOTH design methods, since the nominal '
            'strength belongs to the member and not to the method. S turns up '
            'where the steel is still elastic, which on this lesson means '
            'inside the buckling equation.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: modulusBrief,
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
            'WHICH MODULUS',
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
          const SizedBox(height: 14),
          if (answered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE TWO OF THEM',
                    style: AppTheme.overline(color: AppColors.ink3),
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    r'$M_p = F_y Z_x \quad \text{(yielded right through)}$',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 6),
                  MathText(
                    r'$M_y = F_y S_x \quad \text{(the outer fiber only)}$',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.charcoal),
                  ),
                ],
              ),
            ),
          if (answered) const SizedBox(height: 14),
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
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
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
