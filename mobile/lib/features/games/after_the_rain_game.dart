import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'slope_figures.dart';
import 'steeper_than_its_friction_game.dart' show Stands, BankRound;

/// After the Rain — the second item for `slope-stability`.
///
/// Steady seepage down a slope roughly HALVES its factor of safety, because
/// buoyancy takes about half the weight out of what presses the grains
/// together while the full weight goes on driving the slide. That one factor
/// is why slopes that stood for years fail in a wet winter, and why the
/// lesson says to check for seepage before anything else.
class AfterTheRainGame extends StatefulWidget {
  const AfterTheRainGame({super.key});

  @override
  State<AfterTheRainGame> createState() => _AfterTheRainGameState();
}

@immutable
class RainRound {
  const RainRound({
    required this.subject,
    required this.asked,
    required this.bank,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Bank bank;
  final String why;
  final String source;

  Stands get answer {
    final fs = bank.factorOfSafety;
    if ((fs - 1).abs() < 0.02) return Stands.onTheEdge;
    return fs > 1 ? Stands.holds : Stands.slides;
  }
}

const rainRounds = <RainRound>[
  RainRound(
    subject: 'the lesson\'s own slope, soaked',
    asked:
        'The 20 degree slope in the 34 degree sand, which stood at 1.85 when '
        'it was dry, is now fully saturated with seepage running down it. '
        'What does it do?',
    bank: Bank(slopeAngle: 20, friction: 34, seeping: true),
    why:
        'It slides. Buoyancy cuts the effective weight roughly in half, so '
        'the factor of safety goes from 1.85 to about 0.93 and the slope is '
        'past failing. Nothing was added to it and nothing was dug out of it: '
        'it rained. This is the lesson\'s own pair of problems and it is the '
        'most useful thing in the card.',
    source: 'geo-slp-q2',
  ),
  RainRound(
    subject: 'the marginal slope, soaked',
    asked:
        'The loose silty slope that stood at 1.1 when dry, 24 degrees in a 26 '
        'degree soil, gets the same rain. What does it do?',
    bank: Bank(slopeAngle: 24, friction: 26, seeping: true),
    why:
        'It slides, and not narrowly: about 0.55. A dry factor of safety near '
        'one has no room for the halving that seepage brings, which is why a '
        'slope that has stood through every summer for twenty years can go in '
        'a single wet week. The rain did not weaken the soil, it changed what '
        'the grains feel.',
    source: 'geo-slp-q2',
  ),
  RainRound(
    subject: 'why it halves',
    asked:
        'Why does seepage cut the factor of safety roughly in half rather '
        'than by some other amount?',
    bank: Bank(slopeAngle: 20, friction: 34, seeping: true),
    why:
        'Because the factor it brings is the buoyant unit weight over the '
        'saturated one, and for ordinary soils those are about two to one: '
        'soil weighs roughly twice what it weighs under water. The full '
        'weight still drives the slide while only the buoyant part presses '
        'the grains together, and that is the whole of the halving.',
    source: 'geo-slp-q2',
  ),
  RainRound(
    subject: 'a slope built for it',
    asked:
        'The same 34 degree sand, but the slope is cut back to 15 degrees and '
        'then soaked. What does it do?',
    bank: Bank(slopeAngle: 15, friction: 34, seeping: true),
    why:
        'It holds, at about 1.26. Flattening the slope is the crudest and '
        'most reliable answer there is to a stability problem, and a slope '
        'designed for the wet case rather than the dry one is a slope that '
        'survives its first winter. The dry factor of safety here would have '
        'been 2.5, which looks wasteful until it rains.',
    source: 'geo-slp-q2',
  ),
  RainRound(
    subject: 'what a drain does',
    asked:
        'A drainage blanket is installed so that the seepage never develops '
        'on the same 20 degree slope. What does the slope do?',
    bank: Bank(slopeAngle: 20, friction: 34),
    why:
        'It holds, back at 1.85. Draining a slope is not a small improvement, '
        'it is a doubling, which is why drains are the first thing designed '
        'into a cut and the first thing to check when an old slope starts '
        'moving. The soil never changed: only whether water was running '
        'through it.',
    source: 'geo-slp-q2',
  ),
  RainRound(
    subject: 'a gentle slope in a poor soil, wet',
    asked:
        'A 10 degree slope in a 30 degree soil, with seepage. What does it '
        'do?',
    bank: Bank(slopeAngle: 10, friction: 30, seeping: true),
    why:
        'It holds, at about 1.6, because it was flat enough to spare the '
        'halving. Notice what decides it: not whether the slope is wet, but '
        'whether it was built with enough margin to survive being wet. Every '
        'slope in a rainy climate should be checked in the state it will '
        'spend its worst week in.',
    source: 'geo-slp-q2',
  ),
];

class _AfterTheRainGameState extends State<AfterTheRainGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'after-the-rain',
    chapterId: 'geotechnical',
    total: rainRounds.length,
    sourceProblemIdOf: (round) => rainRounds[round].source,
  )..addListener(_onSession);

  Stands? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RainRound get _round => rainRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'After the Rain',
        closing:
            'Seepage down a slope roughly halves its factor of safety, '
            'because buoyancy takes half the weight out of what presses the '
            'grains together while the whole weight goes on driving the '
            'slide. A dry factor of safety near one has no room for that. '
            'Flattening the slope and draining it are the two answers, and '
            'draining is worth a doubling on its own.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: seepageSlopeBrief,
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
            'AND NOW IT IS WET',
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
            height: 204,
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
                  painter: BankPainter(bank: r.bank, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$FS = \frac{\gamma'}{\gamma_{sat}}\cdot"
              r"\frac{\tan\phi}{\tan\beta}$",
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Stands.values) ...[
            _Choice(
              label: BankRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Stands.values.last) const SizedBox(height: 8),
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
