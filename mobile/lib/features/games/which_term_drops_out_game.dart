import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'bearing_figures.dart';

/// Which Term Drops Out — the first item for `bearing-capacity`.
///
/// The bearing capacity equation has three terms and most exam problems kill
/// at least one of them before the arithmetic starts. A soil with no
/// cohesion loses the first, a footing on the surface loses the second, and
/// a clay with no friction angle loses the third, because the factor that
/// multiplies it is zero. Knowing which term is missing is most of knowing
/// what the answer will look like.
class WhichTermDropsOutGame extends StatefulWidget {
  const WhichTermDropsOutGame({super.key});

  @override
  State<WhichTermDropsOutGame> createState() =>
      _WhichTermDropsOutGameState();
}

/// Which of the three terms a round is about.
enum Piece4 { cohesion, depth, width, none }

@immutable
class TermRound3 {
  const TermRound3({
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
  final Piece4 answer;
  final String why;
  final String source;

  static String label(Piece4 which) => switch (which) {
        Piece4.cohesion => 'The cohesion term',
        Piece4.depth => 'The depth term, from the soil beside the footing',
        Piece4.width => 'The width term, from the soil under it',
        Piece4.none => 'None of them: all three are there',
      };
}

const _onClay = Footing(
    width: 6, depth: 0, cohesion: 1500, unitWeight: 115,
    nc: 5.14, nq: 1, nGamma: 0);
const _onSand = Footing(
    width: 4, depth: 3, cohesion: 0, unitWeight: 120,
    nc: 30.14, nq: 18.40, nGamma: 15.07);
const _mixed = Footing(
    width: 5, depth: 3, cohesion: 500, unitWeight: 115,
    nc: 14.83, nq: 6.40, nGamma: 3.54);
const _sandOnSurface = Footing(
    width: 4, depth: 0, cohesion: 0, unitWeight: 120,
    nc: 30.14, nq: 18.40, nGamma: 15.07);
const _buriedClay = Footing(
    width: 6, depth: 4, cohesion: 1500, unitWeight: 115,
    nc: 5.14, nq: 1, nGamma: 0);

const termGoneRounds = <TermRound3>[
  TermRound3(
    subject: 'a footing on the surface of a clay',
    asked:
        'A strip footing laid on the surface of a clay, with the friction '
        'angle taken as zero. Which term survives?',
    footing: _onClay,
    answer: Piece4.cohesion,
    why:
        'Only the cohesion term. With the footing on the surface there is no '
        'soil beside it to hold the failure down, so the depth term is zero, '
        'and with no friction angle the width factor is zero too. The whole '
        'capacity is the undrained strength times 5.14, which is worth '
        'remembering as a number in its own right.',
    source: 'geo-bc-q1',
  ),
  TermRound3(
    subject: 'a buried footing on a sand',
    asked:
        'A footing three feet down in a clean sand with no cohesion at all. '
        'Which term is missing?',
    footing: _onSand,
    answer: Piece4.cohesion,
    why:
        'The cohesion term, since a clean sand has none. The other two do the '
        'whole job, and on this footing the depth term alone is nearly twice '
        'the width term, which is a good reason to bury a footing rather than '
        'widen it.',
    source: 'geo-bc-q2',
  ),
  TermRound3(
    subject: 'what burying it buys',
    asked:
        'The same sand footing is moved from three feet down to the surface. '
        'Which term goes?',
    footing: _sandOnSurface,
    answer: Piece4.depth,
    why:
        'The depth term, and with it about two thirds of the capacity. The '
        'soil beside a buried footing has to be pushed up and out of the way '
        'before the footing can fail, and that is what the term is worth. A '
        'footing on the surface of a clean sand has remarkably little to '
        'stand on.',
    source: 'geo-bc-q2',
  ),
  TermRound3(
    subject: 'the clay with no friction',
    asked:
        'In the undrained clay case the third factor is given as zero. What '
        'does that kill?',
    footing: _buriedClay,
    answer: Piece4.width,
    why:
        'The width term. It is the one that comes from the weight of the soil '
        'under the footing shearing sideways, and with no friction angle '
        'there is nothing to shear against: the factor is zero however wide '
        'the footing is. Which means a wider footing on an undrained clay '
        'does not raise its bearing PRESSURE at all.',
    source: 'geo-bc-q1',
  ),
  TermRound3(
    subject: 'a soil with a bit of everything',
    asked:
        'A footing three feet down in a soil with 500 of cohesion and a '
        'friction angle of 20 degrees. Which term drops out?',
    footing: _mixed,
    answer: Piece4.none,
    why:
        'None of them: this is the full equation, and the lesson\'s own hard '
        'problem. All three terms are there and the cohesion one is the '
        'largest of the three, which is usual in a soil with any cohesion at '
        'all. Dropping any of them is an error worth several thousand pounds '
        'a square foot.',
    source: 'geo-bc-q3',
  ),
  TermRound3(
    subject: 'the same clay, buried',
    asked:
        'The clay footing from the first round is buried four feet deep. '
        'Which term comes back?',
    footing: _buriedClay,
    answer: Piece4.depth,
    why:
        'The depth term, though it is a modest one here: for an undrained '
        'clay its factor is exactly one, so it is worth just the weight of '
        'the soil alongside. Useful, unspectacular, and easy to leave out. '
        'The width term stays at zero however deep the footing goes.',
    source: 'geo-bc-q1',
  ),
];

class _WhichTermDropsOutGameState extends State<WhichTermDropsOutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-term-drops-out',
    chapterId: 'geotechnical',
    total: termGoneRounds.length,
    sourceProblemIdOf: (round) => termGoneRounds[round].source,
  )..addListener(_onSession);

  Piece4? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TermRound3 get _round => termGoneRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Term Drops Out',
        closing:
            'Three terms, and most problems kill one before the arithmetic '
            'starts. No cohesion and the first goes. On the surface and the '
            'second goes, which on a clean sand is most of the capacity. No '
            'friction angle and the third goes, because its factor is zero, '
            'which is why a wider footing on an undrained clay buys no '
            'pressure at all. When a soil has some of everything, all three '
            'are there and the cohesion one is usually the largest.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: terzaghiBrief,
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
            'WHICH OF THE THREE',
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
              r"$q_{ult} = cN_c + \gamma' D_f N_q + \tfrac{1}{2}\gamma' B "
              r"N_\gamma$",
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Piece4.values) ...[
            _Choice(
              label: TermRound3.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Piece4.values.last) const SizedBox(height: 8),
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
