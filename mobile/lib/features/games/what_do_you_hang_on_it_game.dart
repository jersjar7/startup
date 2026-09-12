import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'virtual_work_figures.dart';

/// What Do You Hang On It — the first item for `deflection-virtual-work`.
///
/// The lesson's three problems are all arithmetic and belong on paper. What
/// the phone can carry is the step before the arithmetic, which is also the
/// step every wrong answer starts at: the unit load has to MATCH the
/// quantity wanted, sit AT the point wanted, and act in a SECOND analysis of
/// its own with the real loads taken off. Get those three right and the sum
/// is bookkeeping; get any of them wrong and no amount of careful arithmetic
/// saves the answer.
class WhatDoYouHangOnItGame extends StatefulWidget {
  const WhatDoYouHangOnItGame({super.key});

  @override
  State<WhatDoYouHangOnItGame> createState() => _WhatDoYouHangOnItGameState();
}

@immutable
class HangRound {
  const HangRound({
    required this.subject,
    required this.asked,
    required this.probe,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Probe probe;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const hangRounds = <HangRound>[
  HangRound(
    subject: 'the lesson\'s own cantilever',
    asked:
        'A cantilever carries a load at its free end. You want to know how '
        'far that end drops.',
    probe: Probe(
      stand: Stand.cantilever,
      measured: Measured.drop,
      at: 1,
      loadAt: 1,
      realLoad: 'the real load',
    ),
    options: [
      'A downward unit force at the free end',
      'A unit moment at the free end',
      'A downward unit force at the built-in end',
      'A second copy of the real load at the free end',
    ],
    answer: 0,
    why:
        'A downward unit force at the free end. The rule has two halves and '
        'both matter: the virtual load goes WHERE the answer is wanted, and '
        'it is the same KIND of thing as the answer. A movement wants a '
        'force, and a downward one because down is the direction being '
        'measured. A unit load at the built-in end would be measuring a '
        'point that cannot move at all.',
    source: 'str-dvw-q3',
  ),
  HangRound(
    subject: 'a rotation, not a movement',
    asked:
        'A simple span carries a load at midspan. You want the SLOPE of the '
        'beam where it meets the left support, not a deflection.',
    probe: Probe(
      stand: Stand.simpleBeam,
      measured: Measured.turn,
      at: 0,
      realLoad: 'the real load',
    ),
    options: [
      'A unit moment at the left support',
      'A unit downward force at the left support',
      'A unit moment at midspan',
      'A unit downward force at midspan',
    ],
    answer: 0,
    why:
        'A unit moment at the left support. The virtual load has to be the '
        'partner of what is being asked for: a force pairs with a movement, '
        'a moment pairs with a rotation. Hang a unit FORCE on that support '
        'and the sum measures how far the support moves, which is nothing, '
        'because the support is what is holding the beam up.',
    source: 'str-dvw-q2',
  ),
  HangRound(
    subject: 'sideways, not down',
    asked:
        'A loaded truss spreads a little as it sags. You want to know how far '
        'the marked joint moves SIDEWAYS.',
    probe: Probe(
      stand: Stand.truss,
      measured: Measured.sway,
      at: 1,
      loadAt: 0.3333,
      realLoad: 'the real load',
    ),
    options: [
      'A horizontal unit force at that joint',
      'A downward unit force at that joint',
      'A horizontal unit force at the other support',
      'A unit force along the member that reaches the joint',
    ],
    answer: 0,
    why:
        'A horizontal unit force at that joint. The unit load points in the '
        'direction you want measured, and nothing else about the structure '
        'changes. Hang it downward and you get a perfectly good answer to a '
        'question nobody asked, which is how far the joint drops. The '
        'direction of the unit load IS the question.',
    source: 'str-dvw-q1',
  ),
  HangRound(
    subject: 'both loads at once',
    asked:
        'The same simple span, and now you want the midspan deflection. The '
        'real load is still sitting there. What does the truss or beam carry '
        'while you work out the virtual forces?',
    probe: Probe(
      stand: Stand.simpleBeam,
      measured: Measured.drop,
      at: 0.5,
      realLoad: 'the real load',
    ),
    options: [
      'The unit load alone, in a separate analysis of its own',
      'The unit load added on top of the real load',
      'The real load alone, scaled down to one unit',
      'A unit load at each support instead',
    ],
    answer: 0,
    why:
        'The unit load alone. There are two analyses of the same structure '
        'and they never share a drawing: the real loads give the real forces, '
        'and the unit load BY ITSELF gives the virtual ones. The formula then '
        'multiplies them together term by term. Adding the unit load to the '
        'real load gives one set of forces that is neither, and the product '
        'that follows is meaningless.',
    source: 'str-dvw-q2',
  ),
  HangRound(
    subject: 'a joint with nothing on it',
    asked:
        'The real load hangs at one joint of the truss, and the deflection '
        'wanted is at a DIFFERENT joint, one with nothing applied to it.',
    probe: Probe(
      stand: Stand.truss,
      measured: Measured.drop,
      at: 0.6667,
      loadAt: 0.3333,
      realLoad: 'the real load',
    ),
    options: [
      'A downward unit force at the empty joint anyway',
      'Nothing: with no load on it, that joint does not move',
      'A downward unit force at the loaded joint',
      'A unit moment at the empty joint',
    ],
    answer: 0,
    why:
        'A downward unit force at the empty joint anyway. Everything in a '
        'loaded structure moves, whether or not a load is sitting on it, and '
        'the unit load is not a load in the ordinary sense: it is the '
        'question, written in a form the equation can answer. Put it on the '
        'joint you are asking about, every time.',
    source: 'str-dvw-q1',
  ),
  HangRound(
    subject: 'where the table runs out',
    asked:
        'A simple span carries a load at midspan and you want the deflection '
        'at the QUARTER point. The handbook table gives the midspan value '
        'only.',
    probe: Probe(
      stand: Stand.simpleBeam,
      measured: Measured.drop,
      at: 0.25,
      realLoad: 'the real load',
    ),
    options: [
      'A unit force at the quarter point, and work the integral',
      'A unit force at midspan, since that is what the table covers',
      'The midspan formula, taken as close enough',
      'A unit moment at the quarter point',
    ],
    answer: 0,
    why:
        'A unit force at the quarter point. The table is a shortcut for cases '
        'that match it exactly, and the moment a question asks about a point '
        'the table does not list, the shortcut is gone and the unit-load '
        'method is what is left. It is worth checking the table first, which '
        'is why the lesson says so, but checking is not the same as forcing a '
        'fit.',
    source: 'str-dvw-q2',
  ),
];

class _WhatDoYouHangOnItGameState extends State<WhatDoYouHangOnItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-do-you-hang-on-it',
    chapterId: 'structural',
    total: hangRounds.length,
    sourceProblemIdOf: (round) => hangRounds[round].source,
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

  HangRound get _round => hangRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Do You Hang On It',
        closing:
            'The virtual load matches the quantity wanted, a force for a '
            'movement and a moment for a rotation, and it sits at the point '
            'wanted, pointing the way you want measured. It acts alone, in a '
            'second analysis with the real loads off, and the two sets of '
            'forces are multiplied together afterward. Every part of that is '
            'decided before a single number is worked out.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: unitLoadBrief,
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
            'WHAT GOES ON THE STRUCTURE',
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
            height: answered ? 268 : 172,
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
                  painter: ProbePainter(probe: r.probe, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\delta = \sum \frac{n N L}{A E}$',
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
