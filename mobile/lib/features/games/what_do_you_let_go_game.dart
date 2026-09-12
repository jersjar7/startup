import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'redundant_figures.dart';

/// What Do You Let Go — the first item for `indeterminate-structures`.
///
/// The count itself belongs to the determinacy lesson and is an item there
/// already. What is new here is what you DO about the count: release as many
/// things as the count is over by, carry each released thing as an unknown,
/// and pay for the missing equilibrium equations with deflection conditions.
/// Which thing to release is a free choice, and the condition that replaces
/// it is always the movement that the real support would not have allowed.
class WhatDoYouLetGoGame extends StatefulWidget {
  const WhatDoYouLetGoGame({super.key});

  @override
  State<WhatDoYouLetGoGame> createState() => _WhatDoYouLetGoGameState();
}

@immutable
class LetGoRound {
  const LetGoRound({
    required this.subject,
    required this.asked,
    required this.span,
    required this.release,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Span span;

  /// What the right answer lets go of, which is what the figure draws once
  /// the round is over.
  final Release release;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const letGoRounds = <LetGoRound>[
  LetGoRound(
    subject: 'the lesson\'s own propped cantilever',
    asked:
        'Built in at one end, propped on a roller at the other. The count says '
        'it is over by one. What single release leaves something statics alone '
        'can finish?',
    span: Span(ends: Ends.fixedRoller),
    release: Release.theProp,
    options: [
      'Let the prop go, and carry its force as the unknown',
      'Let the built-in end go, and carry its three reactions as unknowns',
      'Let the prop and the built-in moment go together',
      'Nothing: statics can already finish it',
    ],
    answer: 0,
    why:
        'Let the prop go. What is left is a plain cantilever, which statics '
        'can finish on its own, and the prop force becomes the one unknown '
        'you carry through. Release the built-in end instead and the beam is '
        'left sitting on a single roller, which is a mechanism and no use to '
        'anybody. Release two things and you have gone one too far: the count '
        'was over by one, so you let exactly one thing go.',
    source: 'str-ind-q1',
  ),
  LetGoRound(
    subject: 'somebody else\'s choice',
    asked:
        'A colleague releases the MOMENT at the built-in end instead, putting '
        'a hinge there and carrying that moment as the unknown. Does that '
        'work?',
    span: Span(ends: Ends.fixedRoller),
    release: Release.theFixedMoment,
    options: [
      'Yes: it leaves a simply supported beam, and the final forces come out '
          'the same',
      'No: the prop is the only thing that may be released',
      'No: the beam becomes a mechanism',
      'Yes, but the forces will come out different from the other choice',
    ],
    answer: 0,
    why:
        'Yes. Releasing the end moment leaves a pin where the wall was, so '
        'the beam is simply supported and determinate, and the released '
        'moment is the unknown. The redundant is a CHOICE: any release that '
        'leaves a stable determinate structure is allowed, and the finished '
        'answer is the same either way because the real structure does not '
        'care which route you took to it. Choose whichever leaves the easier '
        'deflection to work out.',
    source: 'str-ind-q1',
  ),
  LetGoRound(
    subject: 'what pins the number down',
    asked:
        'The prop has been released and the beam is a cantilever carrying the '
        'load plus the unknown prop force. What fixes the value of that '
        'force?',
    span: Span(ends: Ends.fixedRoller),
    release: Release.theProp,
    options: [
      'The deflection under the prop has to come back to zero',
      'The bending moment at the prop has to be zero',
      'The vertical forces have to add up to zero',
      'The deflection at midspan has to be zero',
    ],
    answer: 0,
    why:
        'The deflection under the prop has to come back to zero, because in '
        'the real structure there is a support sitting there and it does not '
        'let the beam move. That is the condition that buys you the extra '
        'equation. The moment at the prop IS zero, but that was already true '
        'and tells you nothing new, and the vertical force equation has '
        'already been spent by statics.',
    source: 'str-ind-q2',
  ),
  LetGoRound(
    subject: 'a moment released instead',
    asked:
        'A beam built in at both ends. One end moment is released, leaving a '
        'pin there, and that moment is carried as the unknown. What condition '
        'sets its value?',
    span: Span(ends: Ends.fixedFixed),
    release: Release.theFixedMoment,
    options: [
      'The slope of the beam at that end has to come back to zero',
      'The moment at that end has to be zero',
      'The deflection at midspan has to be zero',
      'No condition is needed once the moment has been released',
    ],
    answer: 0,
    why:
        'The slope there has to come back to zero, because a wall does not '
        'let the beam turn. Notice the pattern: whatever you release, the '
        'condition that replaces it is the movement the real support was '
        'preventing. Release a force and you owe a deflection; release a '
        'moment and you owe a rotation.',
    source: 'str-ind-q3',
  ),
  LetGoRound(
    subject: 'after the number comes out',
    asked:
        'The prop force has been worked out from the deflection condition. '
        'What gets you the rest of the reactions?',
    span: Span(ends: Ends.fixedRoller),
    release: Release.theProp,
    options: [
      'Put it back on the released beam and finish with ordinary statics',
      'Start the whole beam again with every unknown at once',
      'Work the deflections out a second time with the prop force in place',
      'The other reactions cannot be found by statics at all',
    ],
    answer: 0,
    why:
        'Put it back and finish with statics. Once the redundant has a number '
        'it is just another known force on a determinate beam, and the wall '
        'reaction and the wall moment come straight out of the usual three '
        'equations. That is the whole shape of the force method: one hard '
        'step to buy one number, then bookkeeping.',
    source: 'str-ind-q2',
  ),
  LetGoRound(
    subject: 'why bother',
    asked:
        'Why does an indeterminate structure need any of this in the first '
        'place?',
    span: Span(ends: Ends.fixedFixed),
    release: Release.theFixedMoment,
    options: [
      'Equilibrium has run out of equations, so a deflection condition has to '
          'supply the rest',
      'The structure is unstable until something is released',
      'The released structure carries the load better',
      'Because the question is asking for a deflection',
    ],
    answer: 0,
    why:
        'Equilibrium has run out. Three equations is all a flat structure '
        'gets, and an indeterminate one has more unknowns than that, so '
        'something outside statics has to make up the difference: how much '
        'the thing actually bends. An indeterminate structure is not unstable '
        'in the least, it is the opposite, which is why real buildings are '
        'full of them.',
    source: 'str-ind-q1',
  ),
];

class _WhatDoYouLetGoGameState extends State<WhatDoYouLetGoGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-do-you-let-go',
    chapterId: 'structural',
    total: letGoRounds.length,
    sourceProblemIdOf: (round) => letGoRounds[round].source,
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

  LetGoRound get _round => letGoRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Do You Let Go',
        closing:
            'Release as many things as the count is over by, carry each one '
            'as an unknown, and pay for it with the movement the real support '
            'would not have allowed: a released force owes a deflection, a '
            'released moment owes a rotation. Which thing you release is your '
            'choice and the finished answer is the same either way. Then put '
            'the number back and let statics finish.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: redundantBrief,
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
            'WHAT DO YOU RELEASE',
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
            height: answered ? 250 : 158,
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
                  painter: ReleasePainter(
                    span: r.span,
                    release: r.release,
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
              r'$DSI = \text{unknowns} - 3$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
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
