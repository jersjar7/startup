import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'composite_figures.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';
import 'stress_figures.dart';

/// How Far Has It Yielded — the third item for
/// `transformed-sections-plastic`.
///
/// The plastic moment is one multiplication, F y times Z, and the arithmetic
/// belongs on paper. What the phone can do is show what the words mean. Load a
/// ductile beam and the stress through its depth starts as a straight line,
/// touches yield at the two faces, then eats inward from both faces leaving an
/// elastic core, and finally goes square: that last picture is the plastic
/// moment, and the gap between the second picture and the fourth is the
/// reserve the shape factor measures.
class HowFarHasItYieldedGame extends StatefulWidget {
  const HowFarHasItYieldedGame({super.key});

  @override
  State<HowFarHasItYieldedGame> createState() =>
      _HowFarHasItYieldedGameState();
}

@immutable
class YieldRound {
  const YieldRound({
    required this.subject,
    required this.asked,
    required this.section,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What state of the beam is being described, in words.
  final String asked;

  final Profile section;

  /// The three blocks on offer, in the order they are drawn.
  final List<Spread3> options;

  /// Which one matches. Checked by the tests against what the block actually
  /// draws rather than taken on trust.
  final int answer;

  final String why;
  final String source;
}

final _rect = boxSection(120, 260);
final _wide = iSection(
  depth: 300,
  flangeWidth: 160,
  flangeThickness: 22,
  webThickness: 10,
);

final yieldRounds = <YieldRound>[
  YieldRound(
    subject: 'a steel beam under a modest moment',
    asked:
        'The beam is carrying well under what it can take, and nothing in it '
        'has yielded. Which block is this?',
    section: _rect,
    options: [Spread3.elastic, Spread3.firstYield, Spread3.fully],
    answer: 0,
    why:
        'The first: a straight line from nothing at the neutral axis to '
        'something short of yield at the faces. This is every beam in the '
        'bending lesson, and M c over I is the formula for exactly this '
        'picture. The dotted lines either side are where yield would be.',
    source: 'mom-tsp-q2',
  ),
  YieldRound(
    subject: 'the moment raised until something gives',
    asked:
        'The moment has been raised until the outermost fibers have just '
        'reached yield, and nothing further in has. Which block?',
    section: _rect,
    options: [Spread3.partly, Spread3.firstYield, Spread3.elastic],
    answer: 1,
    why:
        'The second, a straight line that just touches the yield line at both '
        'faces. This is the YIELD moment, F y times the elastic section '
        'modulus S, and it is the end of the bending lesson. It is not the end '
        'of the beam: everything inside those faces is still working well '
        'below yield, and it has more to give.',
    source: 'mom-tsp-q2',
  ),
  YieldRound(
    subject: 'pushed past first yield',
    asked:
        'The load has been raised further. The outer parts have yielded, and '
        'a core in the middle is still elastic. Which block?',
    section: _rect,
    options: [Spread3.firstYield, Spread3.fully, Spread3.partly],
    answer: 2,
    why:
        'The third. The outer bands sit flat against the yield line, because a '
        'ductile material that has yielded goes on stretching without carrying '
        'any more, and the straight part left in the middle is the elastic '
        'core. The beam is bending visibly by now and has still not reached '
        'its capacity.',
    source: 'mom-tsp-q2',
  ),
  YieldRound(
    subject: 'as far as it goes',
    asked:
        'The section has yielded all the way through, top to bottom. Which '
        'block, and what is the moment called?',
    section: _rect,
    options: [Spread3.partly, Spread3.elastic, Spread3.fully],
    answer: 2,
    why:
        'The third, two square blocks pushing opposite ways. This is the '
        'PLASTIC moment, M p equals F y times Z, and Z is the plastic section '
        'modulus that goes with this square picture. Using the elastic S here '
        'is the lesson\'s named trap: S belongs to the triangle, Z belongs to '
        'the square, and Z is the larger of the two.',
    source: 'mom-tsp-q2',
  ),
  YieldRound(
    subject: 'a wide flange steel beam, fully plastic',
    asked:
        'Same question on a wide flange section: yielded right through. Which '
        'block?',
    section: _wide,
    options: [Spread3.fully, Spread3.elastic, Spread3.partly],
    answer: 0,
    why:
        'The first, and the block is the same square shape whatever the '
        'section looks like, because it only says what the STRESS is doing. '
        'What the shape changes is how much reserve there was: the shape '
        'factor Z over S is about one and a half for a rectangle and only '
        'about one and a tenth for a wide flange, because a wide flange '
        'already has most of its material out at the faces where it yields '
        'first.',
    source: 'mom-tsp-q2',
  ),
  YieldRound(
    subject: 'the same rectangle, one step back',
    asked:
        'Between first yield and fully plastic, which block is the one the '
        'beam is in for most of that journey?',
    section: _rect,
    options: [Spread3.elastic, Spread3.partly, Spread3.firstYield],
    answer: 1,
    why:
        'The second. Yielding does not happen everywhere at once: it starts at '
        'the faces and works inward while the moment keeps climbing, and that '
        'in between state is where a ductile beam spends the whole of its '
        'reserve. It is also what makes the failure gradual, which is the '
        'warning a brittle section never gives you.',
    source: 'mom-tsp-q2',
  ),
];

class _HowFarHasItYieldedGameState extends State<HowFarHasItYieldedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-far-has-it-yielded',
    chapterId: 'mechanics-materials',
    total: yieldRounds.length,
    sourceProblemIdOf: (round) => yieldRounds[round].source,
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

  YieldRound get _round => yieldRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Far Has It Yielded',
        closing:
            'Straight line, then touching yield at the faces, then eating '
            'inward with an elastic core, then square all the way through. '
            'The second picture is F y times S and the last is F y times Z. '
            'The gap between them is the shape factor: about half as much '
            'again for a rectangle, about a tenth for a wide flange.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: plasticBrief,
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
            'TAP THE BLOCK THAT MATCHES',
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
          for (var i = 0; i < r.options.length; i++) ...[
            _Block(
              section: r.section,
              state: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'the dotted lines are where yield sits',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT STAGE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.section,
    required this.state,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Profile section;
  final Spread3 state;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: StressBlockPainter(
                  profile: section,
                  state: state,
                  tone: tone,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
